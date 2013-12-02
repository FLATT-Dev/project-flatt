/*******************************************************************************
 * ZG_DbDataSetComparator.as
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
package com.ZG.UserObjects
{
	import flash.data.*;
	import com.ZG.Utility.*;
	
	public class ZG_DbDataSetComparator
	{
		// this class is during consistency check
		// contains table name, old and new data,comparison methods
		
		// src and dst data are arrays of SQLResult objects, each of which contains		
		// arrays of selected rows
		private var _srcData:SQLResult;
		private var _destData:SQLResult;
		private var _tableName:String = "";
		private var _tableSchema:SQLTableSchema;
		
		public function ZG_DbDataSetComparator(tblName:String,tableSchema:SQLTableSchema)
		{
			_tableName = tblName;
			_tableSchema = tableSchema;
		}
		//------------------------------------
		public function AddSource(src:SQLResult):void
		{
			_srcData = src;
		}
		public function AddDestination(dest:SQLResult):void
		{
			_destData = dest;
		}
		//--------------------------------------------
		//find data only  in src set and prepare sql commands from it
		// XXX this code only handles new rows and does not update existing ones
		// for now it's ok, but may be will have to revisit
		public function GetDbCommands():Array
		{
			var cmds:Array = new Array();
			// handle a case where there is no rows in the new table
			if (!ZG_SqlUtils.SqlResultHasData(_srcData))
			{
				return cmds;
			}
			var startIndex: int;
			// easy case - no rows in destination - just copy all rows;
			if( !ZG_SqlUtils.SqlResultHasData(_destData))
			{
				startIndex = 0;
			}
			else
			{			
				startIndex = (_srcData.data.length + _destData.data.length )- _srcData.data.length;
			}
			// dont do anythning if the current table has more rows.. this would be an update
			// which this code does not handle yet
			if ( startIndex < _srcData.data.length )
			{
				for ( var i:int = startIndex; i < _srcData.data.length ; ++i )
				{
					cmds.push(PrepareDbCommand(_srcData.data[i] ,true )); // insert or update
				}
			}
			return cmds;
		}
		
		//-------------------------------------------------------
		//Iterate prepare a SQL command from array of column values
		private function PrepareDbCommand(dbRow:Object,isInsert:Boolean):String
		{
			var res:String;
			if( isInsert )
			{
				
			 	res = "Insert into "+ _tableName;
			 	var colNames:String = "(";
			 	var values:String = "values(";
			 	//
			 	for (var colName:String in dbRow) 
			 	{
           			//todo: skip the _id column
           			if(colName.indexOf("_id")< 0 )
           			{
           				colNames+= colName+ ",";
           				values+= QuoteColumnValue(dbRow[colName],colName) +",";
           			}
     			}
     			// remove last comma
     			
     			colNames = colNames.slice(0,colNames.length-1);    		
     			values = values.slice(0,values.length-1);
     			
     			colNames+=")";
     			values+=")";
     			res+=(colNames + " " + values);
     				
			}
			else
			{
				// TODO if needed
			}
			return res;
		}
		
		//-----------------------------------------------
		// find the column in schema and quote it if its a string
		private function QuoteColumnValue(colVal:String,colName:String):String
		{
			if( _tableSchema !=null )
			{
				for( var i:int = 0; i < _tableSchema.columns.length;++i)
				{
					var curCol:SQLColumnSchema = _tableSchema.columns[i];
					
					if( curCol.name == colName )
					{
						if(curCol.dataType =="text" )
						{
								return ("'"+colVal+"'");
						}
						else
						{
							return colVal;
						}
					}
				}
				// this unlikely 
				trace("column name "+colName +" not found in column schema list ");
			}
			return colVal;
		}

	}
}
