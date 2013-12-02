/*******************************************************************************
 * ZG_LocalBackupManager.as
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
	import flash.utils.Timer;
	
	
	//  This class handles user locac database backup. 
	// The backup is stored in the same directory as the db file
	// Frequency of backup isdetermined by user in prefs ( TODO )
	public class ZG_LocalBackupManager extends ZG_BackupManager
	{
		
		
		private var _timer:Timer;
		private var _dbPath:String="";
		
		//--------------------------------------------------------------
		public function ZG_LocalBackupManager(target:IEventDispatcher=null)
		{
			super(target);
			_timer = new Timer(DEFAULT_BACKUP_INTERVAL);
			_timer.addEventListener(TimerEvent.TIMER, OnDbBackupTimer,false,0, true);
			
		}
		//------------------------------------------------------------------
		// TODO: Currently only deals with one backup
		// may need to expand to deal with many. Eachu will have its own timer,path and 
		// maybe some backup policy, e.g if the original should be overwritten ,etc
		// for now just back up the main db file once a day
		override public function Init(dbPath: String,interval:uint):void
		{
			_dbPath = dbPath;
			_timer.delay = interval;			
			StopBackup();
			_timer.start();
		}
		//------------------------------------------------------------
		override public function StopBackup():void
		{
			if( _timer.running )
			{
				_timer.stop();
			}
		}
		//---------------------------------------------------------------
		// this just blindly backs up a file once a day
		// TODO: maybe need some limitations of MAX number of files in directory,
		private function OnDbBackupTimer(e:TimerEvent):void
		{
			
			RunBackup(false);
			
		}
		//-----------------------------------------------------------------
		private function OnFileCopy(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE,OnFileCopy);			
			trace("BackupMgr: complete ");
			DispatchEvent(ZG_Event.EVT_BACKUP_DONE);
		}
		private function OnCopyError(e:IOErrorEvent):void
		{
			e.target.removeEventListener(IOErrorEvent.IO_ERROR,OnCopyError);
			trace("BackupMgr:Copy file error ");
			DispatchEvent(ZG_Event.EVT_BACKUP_DONE);
		}
		//----------------------------------------------------
		override public function  RunBackup(stopBackup:Boolean):void
		{
			// turn off timer until this task is done
			if(stopBackup)
			{
				StopBackup();
			}			
			var src:File = File.applicationStorageDirectory.resolvePath(_dbPath);
			
			if(src.exists)
			{			
				var newName:String = src.name +".bak";
				var dest:File = src.resolvePath(src.parent.nativePath + File.separator + newName );
				src.addEventListener(Event.COMPLETE, OnFileCopy);
				src.addEventListener(IOErrorEvent.IO_ERROR,OnCopyError);
				src.copyToAsync(dest,true);
			}
		}
		//--------------------------------------------------------------		
	}
}
