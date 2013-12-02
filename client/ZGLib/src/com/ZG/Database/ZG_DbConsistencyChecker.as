/*******************************************************************************
 * ZG_DbConsistencyChecker.as
 * 
 * Copyright 2010-2013 Andrew Marder
 * heelcurve5@gmail.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
******************************************************************************/
package com.ZG.Database
{
	import com.ZG.Events.*;
	import com.ZG.UserObjects.*;
	import com.ZG.Utility.*;
	import com.ZG.Logging.*;
	import mx.managers.*;
	
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	//==========================================
	// This class does a consistency check of the database and updates existing db if needed
	// existing db 
	
	public class ZG_DbConsistencyChecker extends ZG_EventDispatcher
	{
		
		private static const STEP_LOAD_TEMPLATE_DB:int 		= 0;
		private static const STEP_LOAD_TEMPLATE_SCHEMA:int 	= 1;
		private static const STEP_LOAD_CUR_DB_SCHEMA:int 	= 2; 
		private static const STEP_MODIFY_CUR_DB:int			= 3; //add new tables, modify existing
		private static const STEP_READ_CUR_DATA:int			= 4; // read rows from current table
		private static const STEP_READ_NEW_DATA:int			= 5; // read rows from template table
		private static const STEP_READ_CUR_VERSION:int		= 6; // read version from current table
		private static const STEP_WRITE_NEW_DATA:int		= 7; // write new data to current table
		private static const STEP_READ_TEMPLATE_VERSION:int= 8; // select the version in teh template
		private static const STEP_WRITE_NEW_VERSION:int = 9;
		
		// list of tables whose values we need to check
		// for now only trade table property table is checked for new values
		// but can be expanded.
		// Also, all new tables that are found in db template are addded to this list
		private var _dbConnection:SQLConnection; // the db we;re cheecking
		private var _dbTemplateConnection:SQLConnection; // what we check against
		private var _dbTemplateName:String = "";
		private var _templateTables:Array = new Array();
		private var _curDbTableMap:Dictionary = new Dictionary();
		private var _modifyDbStatements:Array = new Array();
		//private var _newDataSelectStatements:Array = new Array();
		private var _tablesToRead:Array = new Array();  // read data from these tables 
		private var _currentStep:int;
		// arrays to store new data from new tables an current data from current tables
		// that are always checked , for now it's only TradeTableProperty 
		private var _curComparator:ZG_DbDataSetComparator;
		
		private var _comparatorsList:Array = new Array();
		private var _dataToWrite:Array = new Array();
		private var _curDbVersion:Number = 0;
		private var _newDbVersion:Number = 0;
		//private var _sqlString:String = "";
		
		
		public function ZG_DbConsistencyChecker(target:IEventDispatcher=null)
		{
			super(target);
			// always check the trade properties table
			// TODO: maybe others as well
			_tablesToRead.push(ZG_SqlCmd.TBLNAME_TRADE_PROP);
		}
		
		//--------------------------------------------------
		// main entry point
		public function Run(inConn:SQLConnection,dbTemplateName:String):void
		{
			CursorManager.setBusyCursor();
			_currentStep = STEP_READ_CUR_VERSION;
			
			_dbConnection = inConn;
			_dbTemplateName = dbTemplateName;
			// Start the chain of asynch select requests
			// start off by reading the version table ( which only has 1 row with the version number)
			// if version matches the currently compiled in version - we're done
			// otherwise update the current database with the new tables/columns from the template
			ZG_SqlUtils.SqlSelect(ZG_SqlCmd.CMD_SELECT_DB_VERSION,
		   	  						   OnSQLComplete,
		   	  						   OnSQLError,		   	  						   
		   	  						   0,
						 			  _dbConnection);
		}
		
		
		//--------------------------------------------------		
		private function OnSQLComplete(event:SQLEvent):void
		{	
			RemoveListeners(event);
			ProcessState(event);		
		}
		
		//--------------------------------------------------		
		private function OnSQLError(event:SQLErrorEvent):void
		{
			
			RemoveListeners(event);
			ProcessState(event);	
		}	
		//------------------------------------------------
		private function RemoveListeners(event:Event ):void
		{
			//event.target.removeEventListener(SQLEvent.RESULT,OnSQLComplete);
			//event.target.removeEventListener(SQLErrorEvent.ERROR,OnSQLError);
		}
		//------------------------------------------------
		// this is the state machine that handles all processing
		// -load schema of the current db
		// -load schema of the template
		// -add tables that are present in template to the existing db
		// - don't remove tables that are present in current and not in template ( for speed )
		// -update columns of existing tables (add or remove)
		// -update version of the current db
		// -add rows to new tables ( if any )
		// -If any of the existing tables changed - add new rows
		// 
		private function ProcessState(event:Object):void
		{
			
			var sqlResult:SQLResult;
			
			switch ( _currentStep )
			{
				case STEP_READ_CUR_VERSION:
					if( event is SQLEvent )
					{
						// select cur version did not return an error:look at the version and determine
						// if db needs to be updated
						sqlResult = event.currentTarget.getResult();
						if(ZG_SqlUtils.SqlResultHasData(sqlResult))
						{
							// should be only one row
							// TODO: maybe read more info, like version or whatever
							_curDbVersion = sqlResult.data[0].dbi_version;
							//Step_ReadTemplateDbVersion();							
						}
					}
					//else if (event is SQLErrorEvent)
					//{
						
						// start process by reading tejmplate db
					Step_LoadTemplateDB();
					//}
					break;
					
				case STEP_READ_TEMPLATE_VERSION:
					if( event is SQLEvent )
					{
						//TODO
						// select cur version did not return an error:look at the version and determine
						// if db needs to be updated
						sqlResult = event.currentTarget.getResult();
						if(ZG_SqlUtils.SqlResultHasData(sqlResult))
						{
							// should be only one row
							// TODO: maybe read more info,like mod date
							CompareDbVersions(sqlResult);						
						}
					}
					else if (event is SQLErrorEvent)
					{
						
						FinishedCheck("Cannot read database version from new database");
					}
					break;
				
				case STEP_LOAD_TEMPLATE_DB:
					if( event is SQLEvent )
					{
						// cur db has a version - read temlate version and compare
						if( _curDbVersion > 0 )
						{
							Step_ReadTemplateDbVersion();
						}
						else
						{
							// no version in cur db - load schema of the template	
							// and update existing db			
							Step_LoadSchema(event.target as SQLConnection);
						}
						
					}
					else
					{
						FinishedCheck("Failed to open database template");
					}
					break;
				
				case STEP_LOAD_TEMPLATE_SCHEMA:
				case STEP_LOAD_CUR_DB_SCHEMA:
					if( event is SQLEvent )
					{
						// process schema load
						ProcessLoadSchema(event.target as SQLConnection);
					}
					else
					{
						FinishedCheck("Failed to update database: Load "+
									((event.target == this._dbConnection) ? "user " : " template ")+"failed");
						
					}
					break;
					
				case STEP_MODIFY_CUR_DB:
					if( event is SQLEvent )
					{
						this.Step_ModifyDatabase(false);
					}
					else
					{
						FinishedCheck("Failed to update database:" + event.error);
					}
					break;
					
				case STEP_READ_NEW_DATA:
					if( event is SQLEvent )
					{						
						// create a new comparator and add source data
						// add comparator to list
						sqlResult = event.currentTarget.getResult();
						if( ZG_SqlUtils.SqlResultHasData(sqlResult) )
						{
							// we have some new data - create a comparator object						
							_curComparator = new ZG_DbDataSetComparator(_tablesToRead[0],FindTableSchema(_tablesToRead[0]));
							_curComparator.AddSource(sqlResult);
							_comparatorsList.push(_curComparator);
							// read data from existing table
							Step_ReadData(_tablesToRead[0],_dbConnection);
						}
						else
						{
							// no new data in table -move to the next table
							_tablesToRead.splice(0,1);
							if(_tablesToRead.length > 0 )
							{
								// rread next table from template db
								Step_ReadData(_tablesToRead[0],_dbTemplateConnection);
							}
							else
							{
								// done reading
								Step_WriteData();
							}
						}						
						
					}
					else
					{
						FinishedCheck("Failed to read new data:" + event.error);
					}
					break;
					
				case STEP_READ_CUR_DATA:
					if( event is SQLEvent )
					{						
						_tablesToRead.splice(0,1);
						_curComparator.AddDestination(event.currentTarget.getResult());
						if(_tablesToRead.length > 0 )
						{
							Step_ReadData(_tablesToRead[0],_dbTemplateConnection);
						}
						else
						{
							// read everything.. now write it out
							Step_WriteData();
						}						
					}
					else
					{
						FinishedCheck("Failed to read data from existing table:" + event.error);
					}
					break;
				case STEP_WRITE_NEW_DATA:
					if( event is SQLEvent )
					{
						HandleDataWrite();
					}
					else
					{
						FinishedCheck("Failed to write new default values:" + event.error);
					}
					break;
				
				case STEP_WRITE_NEW_VERSION:
					//write new dbinfo version into the current db
					CleanupAndExit(event is SQLEvent? null : "Failed to save new db version");
					break;				
			}
		}
		//----------------------------------------
		private function Step_LoadTemplateDB():void
		{
			_currentStep = STEP_LOAD_TEMPLATE_DB;
			// this is unlikely -b this code is only called once on startup
			if(_dbTemplateConnection!=null)
			{
				_dbTemplateConnection.close();
				_dbTemplateConnection = null;
			}
			_dbTemplateConnection = new SQLConnection();
			_dbTemplateConnection.addEventListener(SQLEvent.OPEN, OnSQLComplete);
			_dbTemplateConnection.addEventListener(SQLErrorEvent.ERROR,OnSQLError);	
			var templateDb:File = File.applicationDirectory.resolvePath(_dbTemplateName);
			if( templateDb.exists )
			{
				_dbTemplateConnection.openAsync(templateDb, SQLMode.READ);	
			}
			else
			{
				FinishedCheck("Cannot find database template file");
			}
			
		}
			
		//----------------------------------------
		private function FinishedCheck(errMessage:String):void
		{
			CursorManager.removeBusyCursor();
			
			if(errMessage == null )
			{
				// normal completion
				// if the current version number 0 - no db version table was present
				// no need to write version number
				if( _curDbVersion > 0 && _curDbVersion < _newDbVersion )
				{
					Step_WriteDbVersion();
					//when Step_WriteDbVersion completes it calls CleanupAndExit
					return;
					
				}
				
			}
			
			// an error occurred - don't write new version
			CleanupAndExit(errMessage);
			
		
		}	
		//-------------------------------------------------------------
		// exit point
		private function CleanupAndExit(message:String):void
		{
			Cleanup();
			var msg:String = (message == null ? ("Consistency check done, template db v. " +
			_newDbVersion + " user db v. "+ _curDbVersion):message);
			
			ZG_AppLog.GetInstance().LogIt(msg,(message == null ? ZG_AppLog.LOG_INFO :ZG_AppLog.LOG_ERR));
			DispatchEvent(ZG_Event.EVT_DB_CHECK_DONE,ZG_Utils.TranslateString(message));
			
		}
		//------------------------------------------------------------
		// in this step we load schema for given connection
		// also set the step appropriately
		private function Step_LoadSchema(conn:SQLConnection):void
		{
			trace("DbConsistencyChecker:Updating database");
			_currentStep = ((conn == _dbTemplateConnection) ? STEP_LOAD_TEMPLATE_SCHEMA : STEP_LOAD_CUR_DB_SCHEMA);
			conn.addEventListener(SQLEvent.SCHEMA,OnSQLComplete);
			conn.addEventListener(SQLErrorEvent.ERROR,OnSQLError);
			conn.loadSchema(SQLTableSchema);
		}
		//---------------------------------------------------------
		private function ProcessLoadSchema(conn:SQLConnection):void
		{
			
			//var conn:SQLConnection = event.target as SQLConnection
			var errString:String = null;
			var res:SQLSchemaResult = conn.getSchemaResult();
			
			if(res!=null)
			{
				PrepareSchemaData(conn ,res);
				// if it's the schema of the current table- start consistency check
				// otherwise load it
				if( conn == _dbConnection)
				{
					StartConsistencyCheck();
				}
				else if ( conn == _dbTemplateConnection )
				{
					Step_LoadSchema(_dbConnection);
				}
				else
				{
					errString = "unknown Sql connection";
					
				}
			}
			else
			{
				errString = "Load schema failed";
			}
			if (errString !=null )
			{
				FinishedCheck(errString);
			}
		}
		//---------------------------------------------------
		private function Cleanup():void
		{
			//TODO:clean up memory,remove event listeners
			if( _dbTemplateConnection!=null )
			{
				try 
				{
					_dbTemplateConnection.close();
					_dbTemplateConnection.removeEventListener(SQLEvent.RESULT,OnSQLComplete);
					_dbTemplateConnection.removeEventListener(SQLErrorEvent.ERROR,OnSQLError);
				}
				catch( e:Error )
				{
					trace ("error closing template db connection");
				}
				_dbTemplateConnection = null;
				//TODO:revisit, clean up everything
				
			}
		}
		//-------------------------------------------------------
		private function PrepareSchemaData(conn:SQLConnection,schema:SQLSchemaResult):void
		{
			// if it's user db - add tables to map 
			if( conn == this._dbConnection )
			{
				for( var i:int =0; i < schema.tables.length;++i)
				{
					var curTable:SQLTableSchema = schema.tables[i];
					_curDbTableMap[curTable.name ]= curTable;
				}
			}
			else
			{
				// remember array of template db tables
				_templateTables = schema.tables;
			}
		}
		//---------------------------------------------------------
		// Now we got all data that we need : start consistency check
		private function StartConsistencyCheck():void
		{
			// iterate template tables and add missing tables to the old db
			for ( var i:int = 0; i < _templateTables.length;++i)
			{
				var templateTable:SQLTableSchema = _templateTables[i];
				var curTable:SQLTableSchema = _curDbTableMap[templateTable.name];
				
				// this table does not exist in the old schema - add create table 
				// sql command
				if( curTable == null)
				{
					_modifyDbStatements.push(NewSqlStatement(templateTable.sql,_dbConnection));					
					// always copy all rows  from new tables if there are any
					_tablesToRead.push(templateTable.name);
				}
				else
				{
					// update columns of existing table
					UpdateTableColumns(templateTable,curTable);
				}
			}
			
			// now we've gathered all table altering and new table creation commands
			if(_modifyDbStatements.length > 0 )
			{
				//execute commands
				Step_ModifyDatabase( true );// begin transaction
			}
			else
			{
				//TODO: no tables needed to be modified
				// copy data from new tables and existing tables
				// if no tables were modified
				Step_ReadData(_tablesToRead[0],_dbTemplateConnection);
			}			
		}
		
		//-----------------------------------------------------
		private function NewSqlStatement(cmdText:String,conn:SQLConnection):SQLStatement
		{
			var cmd:SQLStatement = new SQLStatement;
			
			cmd.text = cmdText;
			cmd.sqlConnection =  conn; /*isUserConnection ? ZG_LocalDatabaseMgr(ZG_DatabaseMgr.GetInstance()).GetUserDbConnection():
								 ZG_LocalDatabaseMgr(ZG_DatabaseMgr.GetInstance()).GetAppDbConnection();*/				
			cmd.addEventListener(SQLEvent.RESULT,OnSQLComplete);
			cmd.addEventListener(SQLErrorEvent.ERROR,OnSQLError);	
			return cmd;
		}
		//--------------------------------------------------
		private function Step_ModifyDatabase(beginTransaction:Boolean):void
		{
			if( _modifyDbStatements.length > 0 )
			{
				_currentStep = STEP_MODIFY_CUR_DB;
				// remove the statement from list.
				var curCmd:SQLStatement = _modifyDbStatements.pop();
				if( beginTransaction )
				{
					try
					{
						_dbConnection.begin();
					}
					catch (e:Error)
					{
						
					}	
				}			
				curCmd.execute();
			}
			else
			{
				// commit transaction.
				// TODO: send message to ui to update progress
				_dbConnection.commit();
				// cick off read of new data
				Step_ReadData(_tablesToRead[0],_dbTemplateConnection);
				//_currentStep = 
				//TODO:copy data from template to current
				
			}
		}
		
		//-----------------------------------------------------
		// start selecting new data
		private function Step_ReadData(tblName:String,conn:SQLConnection):void
		{
			_currentStep = (conn == _dbTemplateConnection) ? STEP_READ_NEW_DATA : STEP_READ_CUR_DATA;	
				
			ZG_SqlUtils.SqlSelect("Select * from " + tblName,
		   	  						   OnSQLComplete,
		   	  						   OnSQLError,		   	  						   
		   	  						   0,
						 			  conn);	
			
		}
		//-----------------------------------------------------------
		private function Step_ReadTemplateDbVersion():void
		{
			_currentStep = STEP_READ_TEMPLATE_VERSION;	
			ZG_SqlUtils.SqlSelect(ZG_SqlCmd.CMD_SELECT_DB_VERSION,
		   	  						   OnSQLComplete,
		   	  						   OnSQLError,		   	  						   
		   	  						   0,
						 			  _dbTemplateConnection);	
		}
		
		//-----------------------------------------------------
		private function UpdateTableColumns(srcTable:SQLTableSchema,destTable:SQLTableSchema):void
		{
			for ( var i:int=0; i < srcTable.columns.length;++i)
			{
				var curCol:SQLColumnSchema = srcTable.columns[i];
				if(!FindColumn(curCol.name,destTable))
				{
					var addColumnCmd:String = "Alter table " + 
									destTable.name +
									" add column \r"+ 
									curCol.name + 
									" " + 
									curCol.dataType + 
									(curCol.allowNull? "" : " NOT NULL" +
									GetColumnDefault(curCol));
					
					_modifyDbStatements.push(NewSqlStatement(addColumnCmd,_dbConnection));	
				}
			}
		}
		//-----------------------------------------------------
		private function FindColumn(colName:String,table:SQLTableSchema):Boolean
		{
			for( var i:int = 0; i < table.columns.length; ++i )
			{
				if( table.columns[i].name == colName )
				{
										
					return true;
				}
			}
			return false;
		}
		//---------------------------------------------------------------------
		private function Reset():void
		{
			/*not needed as this object is only run once
			
			_currentStep:int = STEP_SELECT_CUR_VERSION;
			_dbConnection = null; 
			_dbTemplateConnection = null; 
			 _dbTemplateName = "";
			 _templateTables.length = 0;
		_curDbTableMap=null;
		
		private var _alterDbStatements:Array = new Array();
		private var _newDataSelectStatements:Array = new Array();
		private var _existingTablesToCheck:Array = new Array(); 
		private var _newTables:Array = new Array();
		private var _currentStep:int = STEP_SELECT_CUR_VERSION;*/
		// 
			
		}
		
		//----------------------------------------------
		// return default value for a column based on its type.
		// we'll be guessing here as  the SQLColumnSchema does not provide this info
		//SO: If allowNull is true:
		// IF type is integer - default is 0
		// If type is text - default is empty string
		private function GetColumnDefault(col:SQLColumnSchema):String
		{
			if(col.allowNull == false)
			{
				if(col.dataType == "integer")
				{
					return " default 0;";
				}
				else if (col.dataType == "float")
				{
					return("default 0.0");
				}
				else if (col.dataType == "text")
				{
					return " default '';";
				}
			}
			return ";";
		}
		//----------------------------------------------
		// compare data from table in _tablesToRead[0]
		// If there are differences - save the data
		// and continue to the next table. If no tables left - we're done
		private function CompareData():void
		{
			/*
			
			// always use first element in array
			var curTable:String = _tablesToRead[0];
			// easy cases first
			if(_newData != null && _newData.data !=null && _newData.data.length > 0 )
			{
				// we got some data in the new table
				// we only insert data into current table
				// because both arrays represent the same table 
				// assume that the order of rows is the same as well
				// assume that num rows in new table is always > than in the current!
				
				
				var startingRow:int;
				if( _curData == null || _curData.data == null 
				
				 =  _newData.length - _curData.data.length;
				if(startingRow > 0 )
				{
					for( var i = startingRow;i < _newData.data.length;++i)
					{
						_dataToWrite.push(_newData[i]);
					}
				}	*	
			}
			// ok, now pop the first element from the array of tables
			// we;re processing
			_tablesToRead.splice(0,1);
			if(_tablesToRead.length > 0 )
			{
				this.Step_ReadData(_tablesToRead[0],_dbTemplateConnection);
			}
			else
			{
				// read everything.. now write it out
				Step_WriteData();
			}
			*/
			
		}	
		//-------------------------------------------------
		private function Step_WriteData():void
		{
			_currentStep = STEP_WRITE_NEW_DATA;
			//prepare insert statement for element 0 of _dataToWrite
			for(var i:int = 0;i < this._comparatorsList.length;++i )
			{
				// database commands from current comparator
				var dbCmds:Array = _comparatorsList[i].GetDbCommands();
				for( var k:int =0; k < dbCmds.length ;++k )
				{
					_dataToWrite.push(NewSqlStatement(dbCmds[k],_dbConnection));
				}
			}
			// now that we have all insert statements - execute them
			if(_dataToWrite.length > 0 )
			{
				// start executing accumulated db statements 			
				_dataToWrite[0].execute();
			}
			else 
			{
				// DONE!!
				FinishedCheck(null);
			}
			
		}
		//-------------------------------------------------------------
		// handle post write
		// if more data - continue writing, otherwise - done with check!
		private function HandleDataWrite():void
		{
			_dataToWrite.splice(0,1);
			if(_dataToWrite.length > 0 )
			{
				_dataToWrite[0].execute();
			}
			else
			{
				FinishedCheck(null);
			}				
		}
		//-----------------------------------------------
		// find the table schema by name on list of table schemas
		private function FindTableSchema(tableName:String):SQLTableSchema
		{
			for ( var i:int = 0; i< _templateTables.length;++i)
			{
				var cur:SQLTableSchema = _templateTables[i];
				if( cur.name == tableName )
				{
					return cur;
				}
			}
			return null;			
			
		}
		//-------------------------------------------------------
		private function CompareDbVersions(result:SQLResult):void
		{
			_newDbVersion = result.data[0].dbi_version;
			if (_curDbVersion == _newDbVersion)
			{
				trace("DbConsistencyChecker: versions are equal");
				FinishedCheck(null);
			}
			else
			{
				// add db info table to list of tables to read. it has the same number
				// and kick off the process.				
				Step_LoadSchema(_dbTemplateConnection);
			}
			
		}
		//-------------------------------------------------------------
		// probably can be an updatye - but maybe it'[s good to keep history of db versions
		private function Step_WriteDbVersion():void
		{
			_currentStep = STEP_WRITE_NEW_VERSION;
			var cmd:String = ZG_StringUtils.Sprintf(ZG_SqlCmd.CMD_INSERT_DB_VERSION,_newDbVersion);
			var sqlStatement:SQLStatement = NewSqlStatement(cmd,_dbConnection);
			sqlStatement.execute();
			
		}
	}
}
