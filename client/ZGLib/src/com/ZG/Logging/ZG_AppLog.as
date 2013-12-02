/*******************************************************************************
 * ZG_AppLog.as
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
package com.ZG.Logging
{
	// This class handles logging in the application
	
	import com.ZG.Events.*;
	import com.ZG.Utility.*;
	
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	
	import mx.controls.Alert;
	import mx.formatters.DateFormatter;
	
	public class ZG_AppLog extends ZG_EventDispatcher
	{
		private static var s_Instance:ZG_AppLog;
		
		public static const LOG_INFO:String = " [INFO] ";
		public static const LOG_WARN:String = " [WARN] " ;
		public static const LOG_ERR:String = " [ERROR] ";
		
		private var _logFile:File;
		private var _logName:String ="log.txt";
		private var _dateFormatter:DateFormatter = new DateFormatter();
		
		//------------------------------------------------------
		public static function GetInstance():ZG_AppLog
		{			
			if( s_Instance == null )
			{
				s_Instance = new ZG_AppLog();
				
			}				
			return s_Instance;
		}	
		//------------------------------------------------------	
		public function ZG_AppLog(target:IEventDispatcher=null)
		{
			super(target);
			_dateFormatter.formatString = ZG_Strings.STR_DEFAULT_DATE_FORMAT;
		}
		
		//------------------------------------------------------	
		//init the log
		public function Init():void
		{
			_logFile = File.applicationStorageDirectory.resolvePath(logName);
			//write log started
			if(!LogIt("****Application started****",LOG_INFO))
			{
				Alert.show(ZG_Utils.TranslateString("Failed to initialize application log"),
					ZG_Utils.TranslateString("Error"),4,null)
				
			}			
		}
		//-------------------------------------------------
		public function LogIt(text:String,msgType:String = LOG_INFO):Boolean
		{			
			var ret:Boolean = false;
			if(_logFile!=null)
			{
				var date:Date = new Date();
				// maybe make an app object i
				var formattedEntry:String = _dateFormatter.format(new Date()) + msgType +"\r"+text+"\r";
				ret = ZG_FileUtils.WriteFile(_logFile, 
					formattedEntry,
					true, // is text
					FileMode.APPEND);						 
				
				ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_APP_LOG,formattedEntry);
			}
			
			return ret;
		}		
		//------------------------------------------------------------
		public function LoadLog():void
		{
			var logData:String = ZG_FileUtils.ReadFile(_logFile,true) as String;
			if(logData==null)
			{
				logData = ZG_Utils.TranslateString("Error reading  log file!");
			}
			ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_APP_LOG_LOADED,logData);
		}
		//---------------------------------------------------------------
		public function GetLogPath():String
		{
			return _logFile.nativePath;
		}
		//-----------------------------------------------------------------
		public function GetLogDirectory():String
		{
			return _logFile.parent.nativePath;
		}
		
		public function get logName():String
		{
			return _logName;
		}
		
		public function set logName(value:String):void
		{
			_logName = value;
		}	
		
	}
}
