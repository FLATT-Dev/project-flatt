/*******************************************************************************
 * ZG_BackupManager.as
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
package com.ZG.Backup
{
	import com.ZG.Events.*;
	import com.ZG.Utility.*;
	
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	
	
	//  This class handles user locac database backup. 
	// The backup is stored in the same directory as the db file
	// Frequency of backup isdetermined by user in prefs ( TODO )
	public class ZG_BackupManager extends ZG_EventDispatcher
	{
		// do backups twice a day
		public static const DEFAULT_BACKUP_INTERVAL:uint = (1000*60*60)*12;
		private static var s_Instance:ZG_BackupManager;
		private static var s_IsLocal:Boolean  = true;
		
		// unused for now - when > 1 object is needed - expand this
		private  var s_BackupObjects:Array = new Array();
		//--------------------------------------------------------------
		public static function SetLocal(local:Boolean ):void
		{
			ZG_BackupManager.s_IsLocal = local;
		}
		//------------------------------------------------------
	 	public static function GetInstance():ZG_BackupManager
		{			
			if(s_IsLocal)
			{
				if( s_Instance == null )
				{
					s_Instance = new ZG_LocalBackupManager();
				}				
			}
			else
			{
				
				if( s_Instance == null)
				{
					s_Instance = new ZG_BackupManager();
				}
			}
			return s_Instance;
		}	
		//--------------------------------------------------------------
		public function ZG_BackupManager(target:IEventDispatcher=null)
		{
			super(target);
			
		}
		//------------------------------------------------------------------
		// TODO: Currently only deals with one backup
		// may need to expand to deal with many. Eachu will have its own timer,path and 
		// maybe some backup policy, e.g if the original should be overwritten ,etc
		// for now just back up the main db file once a day
		public function Init(dbPath: String,interval:uint):void
		{
			
		}
		//------------------------------------------------------------
		public function StopBackup():void
		{
		}
		
		//----------------------------------------------------
		public function  RunBackup(stopBackup:Boolean):void
		{
		}
		//--------------------------------------------------------------		
	}
}
