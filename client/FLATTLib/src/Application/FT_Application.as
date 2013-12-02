/*******************************************************************************
 * FT_Application.as
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
package Application
{
	import FLATTPlugin.*;
	
	import Licensing.FT_LicenseManager;
	
	import com.ZG.Events.ZG_EventDispatcher;
	import com.ZG.Logging.*;
	import com.ZG.Prefs.*;
	import com.ZG.Utility.*;
	
	import flash.events.IEventDispatcher;
	import flash.utils.*;
	
	//This class performs application specific maintenance tasks
	public class FT_Application extends ZG_EventDispatcher
	{
		public static var INVALID_PORT:int = -1;
		public static var DEF_SSH_PROXY_HOST:String = "localhost";
		public static var DEF_SSH_PROXY_PORT:int = -1;
		
	
		private var _sshProxyHost:String = DEF_SSH_PROXY_HOST;
		//protected var _sshProxyPort:int = INVALID_PORT;
		protected var _localProxyPort:int = INVALID_PORT;
		
		private static var s_Instance:FT_Application;
		
		private var _lastHostIndex:int;
		private var _hostsList:Array;	
		private var _prefs:ZG_LocalPrefs = new ZG_LocalPrefs();
		
		public function FT_Application(target:IEventDispatcher=null)
		{
			super(target);						
		}
		
		// CLASS VARIABLES
		// Subclasses must create the instance
		public static function SetInstance(instance:FT_Application):void
		{
			s_Instance = instance 
			
		}
		//-------------------------------------------
		public static function GetInstance():FT_Application
		{						
								
			return s_Instance;
		}
		//-------------------------------------------
		//Perform all initialization tasks
		public function Initialize():void
		{
			ZG_AppLog.GetInstance().logName = "FLATTLog.txt";
			ZG_AppLog.GetInstance().Init();
			
			// initialize prefs
			FT_Prefs.GetInstance();
			// argh sending an event every 5 seconds!!
			FT_LicenseManager.GetInstance();
		
			
			//TODO: flesh out what this guy is gonna be doing
			// Probably something similiar to ZG_App is doing ( below)
			
			
			//TODO: Read saved hosts list from database
			
			/* set up event listeners
			ZG_UserDataReader.GetInstance().addEventListener(ZG_Event.EVT_DB_READING_DATA,OnDbReadingData);
			ZG_UserDataReader.GetInstance().addEventListener(ZG_Event.DB_READ_ERROR,OnDbReadError);
			
			
			// load application database - global settings, current user and stuff othe stuff.
			// TODO: this should execute asynchronously so add a handler to execute the code below
			//ZG_DatabaseMgr.GetInstance().LoadDatabase(null);
			//
			var dbName:String =  ZG_Utils.DbNameFromUserName(GetCurrentUser());
			ZG_DatabaseMgr.GetInstance().LoadDatabase(dbName);	
			ZG_BackupManager.GetInstance().Init(dbName,ZG_BackupManager.DEFAULT_BACKUP_INTERVAL);	*/
		}
		//------------------------------------------------------------------
		// Subclasses override
		public function GetIconForObject(obj:Object):Class
		{
			return null;
		}
		
		//------------------------------------------------------------------
		/*public function AddHost(aHost: FT_TargetHost,savedIndex:int):void
		{
			var i:int;
			// add host if not already there
			for( i = 0; i < _hostsList.length;++i)
			{
				if(_hostsList[i].host == aHost.host )
				{
					break;
				}
			}
			if( i >=_hostsList.length )
			{
				// not found - add
				_hostsList.push(aHost);
				_prefs.SetPref(PREF_KEY_HOST_LIST,_hostsList);
			}
			lastHostIndex = savedIndex;
			
		
		}
		//---------------------------------------------------------
		private function LoadPrefs():void
		{
			// load the prefs
			_hostsList = _prefs.GetPref(PREF_KEY_HOST_LIST) as Array;
			_lastHostIndex = _prefs.GetPref(PREF_KEY_LAST_HOST_INDEX) as int;
			if(_hostsList == null )
			{
				_hostsList = new Array();
				_lastHostIndex = 0;
			}
		}
		
		//-----------------------------------------------------------------
		public function SaveHosts():void
		{
			//TODO: save in prefs or db?
		}
		//-----------------------------------------------------------------
		public function ReadHosts():void
		{
			//TODO: read saved list from prefs or db?
		}
		
		//-----------------------------------------------------------------
		// TODO: Return host list stored in prefs
		public function get hostsList():Array
		{
			return _hostsList;			
		}		
		//-----------------------------------------------------------------
		*/
		
		/* Potentially can be configurable */
		//-------------------------------------------
		public function get sshProxyHost():String
		{
			return _sshProxyHost;
		}
		//-------------------------------------------
		public function set sshProxyHost(value:String):void
		{
			_sshProxyHost = value;
		}
		/* Potentially can be configurable */
		//-------------------------------------------
		public function  GetlocalProxyPort():int
		{			
			if(_localProxyPort == INVALID_PORT)
			{				
				_localProxyPort = DiscoverSSHProxyPort();
				
			}
			return _localProxyPort;
		}
		//-------------------------------------------
		/*public function set sshProxyPort(value:int):void
		{
			_sshProxyPort = value;
		}*/
		//----------------------------------------------------
		public function Cleanup():void
		{
			
		}
		//-------------------------------------------
		public function QuitApp():void
		{
			
		}
		protected function DiscoverSSHProxyPort():int
		{
			return INVALID_PORT;
		}
		
		//-----------------------------------------
		public function TrialExpired():Boolean
		{
			return false;
		}
		
		//------------------------------------
		// desktop way
		public function GetVersionString():String
		{
			
				return "";
		}
		
		public function ConfigureProxy():void
		{
			
		}
		//--------------------------
		// subclasses override
		public function ValidateProxy():Boolean
		{
			return true;
		}
		//-----------------
		public function GetProxyVersionString():String
		{
			return "";
		}
	}	

	
}
