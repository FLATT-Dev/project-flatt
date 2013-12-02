/*******************************************************************************
 * ZG_SqlUtils.as
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
package com.ZG.Utility
{
	import flash.data.SQLStatement;
	
	public class ZG_SqlUtils
	{
		import com.ZG.Utility.*;
		import com.ZG.Database.*;
		import flash.data.*;
		import flash.events.*;
		
		
		// the command is already prepared..
		// TODO: optimize. This is rather wasteful
		 public static function SqlSelect(cmdText:String,
		 								   sucessProc:Function,
		 								   errorProc:Function, 
		 								   objId:Number,
		 								   connection:SQLConnection
		 								   ):void
		{
			var cmd:SQLStatement = new SQLStatement;
			
			cmd.text = ZG_SqlUtils.FinalPrepareCommand(cmdText,objId);
			cmd.sqlConnection =  connection; /*isUserConnection ? ZG_LocalDatabaseMgr(ZG_DatabaseMgr.GetInstance()).GetUserDbConnection():
								 ZG_LocalDatabaseMgr(ZG_DatabaseMgr.GetInstance()).GetAppDbConnection();*/				
			cmd.addEventListener(SQLEvent.RESULT,sucessProc);
			cmd.addEventListener(SQLErrorEvent.ERROR,errorProc);		
			cmd.execute();
		
		}
		
		// If there is an obj id, sprintf it to the string
		// resolve table language
		public static function FinalPrepareCommand(cmd:String,objId:Number):String
		{
		 	var ret:String = (objId? ZG_StringUtils.Sprintf(cmd,objId):cmd);		 		
		 	return (ZG_Utils.ResolveTableLanguage(ret));
		}
		
		// return abbreviated table name used to identify rows in table
		public static function GetTableAbbreviation(tblName:String):String
		{
			if(tblName =="Broker")
			{
				return "brk";
			}
			if(tblName == "Account")
			{
				return "act";
			}
			if(tblName == "Trade")
			{
				return "trd";
			}
			if(tblName == "TradeFilter")
			{
				return "flt";
			}
			if ( tblName == "TradeLogEntry")
			{
				return "tle";
			}
			if( tblName == "TradeStrategy_en")
			{
				return "strat";
			}
			return "???";
			
		}
		//------------------------------------------
		// shorthand to determine if there is data in sql result 
		public static function SqlResultHasData(result:SQLResult):Boolean
		{
			return( result !=null && result.data !=null && result.data.length > 0 );
		}

	}
}
