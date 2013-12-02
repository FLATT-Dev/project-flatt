/*******************************************************************************
 * FT_ScheduleManager.as
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
package Scheduling
{
	import FLATTPlugin.*;
	import Exec.*;
	import TargetHostManagement.*;
	
	import Utility.*;
	
	import com.ZG.Events.*;
	import com.ZG.UserObjects.*;
	import com.ZG.Utility.*;
	
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.messaging.channels.StreamingAMFChannel;

	public class FT_ScheduleManager extends ZG_EventDispatcher
	{
		private static var s_Instance:FT_ScheduleManager;
		public static const SCHEDULES_DIR:String = "Schedules";
		private var _schedulesDir:File;
		private var _schedules:Array; // array FT_Schedule objects
		
		
		//====================================================
		public function FT_ScheduleManager(target:IEventDispatcher=null)
		{
			super(target);
			_schedules = new Array();
			FT_PluginManager.GetInstance().addEventListener(FT_Events.FT_EVT_SCHEDULE_RESTART,OnScheduleRestart);
		}
		
		//-----------------------------------------------
		public static function GetInstance():FT_ScheduleManager
		{
			if(s_Instance == null )
			{
				s_Instance = new FT_ScheduleManager();
			}
			return s_Instance;
		}
		//-----------------------------------------------------
		public function Initialize():void
		{
			
			/*var temp:Date = new Date();
			temp.minutes +=3;
			
			trace("time is "+temp.time);*/
			FS_ReadSchedules();
		}
		//-------------------------------------------
		private function FS_ReadSchedules():void
		{
			if(EnsureSchedulesDirectory())			
			{
				_schedulesDir.addEventListener(FileListEvent.DIRECTORY_LISTING, ScheduleDirListFunc);
				// start reading plugins from FS
				_schedulesDir.getDirectoryListingAsync();
			}
		}
		//--------------------------------------
		private function ScheduleDirListFunc(event:FileListEvent):void		
		{
			var contents:Array = event.files;		 
			FS_SchedulesList(event.files);
			// this will display them in UI
			DispatchEvent(FT_Events.FT_EVT_SCHEDULES_READY,_schedules);
			RunSchedules();
			
		}
		//------------------------------------------------
		public function RunSchedules():void
		{
			for( var i:int = 0; i < _schedules.length; ++i)
			{
				_schedules[i].Initialize();
			}
		}
		//------------------------------------------------
		// Process files in the schedules directory
		private function FS_SchedulesList(scheduleFiles:Array):void
		{
			for(var i:int =0; i < scheduleFiles.length;++i)
			{
				if(!scheduleFiles[i].isDirectory)
				{
					var newSched:FT_Schedule = new FT_Schedule();
					if(newSched.Read(scheduleFiles[i],null))
					{
						InternalAdd(newSched);
					}			
				}
			}
			_schedules.sortOn("name");
		}
		//---------------------------------------------
		private function EnsureSchedulesDirectory():Boolean
		{					
			_schedulesDir = ZG_FileUtils.EnsureDirectory(_schedulesDir,SCHEDULES_DIR);			
			return (_schedulesDir!=null && _schedulesDir.exists );
		}	
		//-----------------------------------------------
		public function get schedules():Array
		{
			return _schedules;
		}
		//-----------------------------------------------	
		public function DeleteSchedule(item:FT_Schedule):void
		{
			//remove from array and delete file
			
			item.Cleanup();
			item.removeEventListener(FT_Events.FT_EVT_SCHEDULE_EXEC_EVT,OnScheduleExecEvent);
			_schedules.splice(_schedules.indexOf(item),1);
			
			DispatchEvent(FT_Events.FT_EVT_REMOVE_SCHEDULE,item);			
		}
		//-------------------------------------------
		protected function InternalAdd(sched: FT_Schedule):Boolean
		{
						
			/* find out if the file with the same name exists in the list */
			for( var i:int; i < _schedules.length;++i)
			{
				if(_schedules[i].guid == sched.guid)
				{
					return false;
				}
			}			
			// now create a FT_HostConfig object and add it to 
			_schedules.push(sched);
			sched.addEventListener(FT_Events.FT_EVT_SCHEDULE_EXEC_EVT,OnScheduleExecEvent);
			return true;
		}
		
		//-----------------------------------------
		private function OnSaveFileComplete(evt:ZG_Event):void
		{								
			if(evt.type == ZG_Event.EVT_SAVE_FILE_COMPLETE)
			{			
				if(evt.data!=null)
				{
					
				}
			}
		}
		//---------------------------------------
		// calls from UI
		public function AddSchedule(sched:FT_Schedule):void
		{
			
			if(EnsureSchedulesDirectory())
			{
			
				var newFile:File = null;
			
				/* copy the file to the configuration directory */
				try
				{				
					newFile = new File(_schedulesDir.nativePath + File.separator+sched.guid);	
					sched.file = newFile;					
				}
				catch(e:Error)
				{
					trace("Error on AddSchedule: "+e.message);
					newFile = null;
				}
			
				if(newFile!=null)
				{
					if(InternalAdd(sched))
					{
						_schedules.sortOn("name");
						DispatchEvent(FT_Events.FT_EVT_SCHEDULES_READY,_schedules);
					}
				}
			}
		}
		
		//-----------------------
		public function FindSchedule( guid:String):FT_Schedule
		{
			for(var i:int = 0; i < _schedules.length;++i)
			{
				if(_schedules[i].guid == guid )
				{
					return  _schedules[i];
				}
			}
			return null;
		}
		
		//-------------------------------
		// dispatch to UI to start action execution
		private function OnScheduleExecEvent(evt:ZG_Event):void
		{
			// todo: figure out if this is 
			var sched:FT_Schedule = evt.data as FT_Schedule;
			if( sched !=null )
			{
				for( var i :int = 0; i < sched.targetObjects.length; ++i)
				{
					var cur:ZG_PersistentObject = sched.targetObjects[i];
					// TODO: determine if there is already a display container for this object . if so - need to rerun, otherwise first time run
					DoExecuteTarget(cur,sched);
					
				}
			}
			//DispatchEvent(FT_Events.FT_EVT_SCHEDULE_EXEC_EVT,evt);
		}
		//-----------------------------------
		protected function DoExecuteTarget(targetObj:ZG_PersistentObject,sched:FT_Schedule):void
		{
			// isFirstRun flag controls whether or not UI will be reset
			// last paraameter to Execute.. function is whether or not we're executing schedule.
			// This flag tells the display container whether or not UI should be reset.
			// When schedule is run for the first time we want to reset the UI to account 
			// for situiations where the scheduled Action or Task were run manually. 
			// When reset UI is omitted  the result data is just appended to the display
			// which is what we want when executing a schedule
			
			if( targetObj is FT_Plugin )
			{
				// isFirstRun
				FT_PluginManager.GetInstance().ExecutePlugin(new Array(targetObj),sched.host,null,null,sched.guid);
			}
			else if (targetObj is FT_Task )
			{
				FT_PluginManager.GetInstance().ExecuteTask(targetObj as FT_Task ,sched.host,null,sched.guid);
			}
			else 
			{
				trace ("target object is neither plugin nor task : " + targetObj.name);
			}
			
		}
		//-----------------------------------
		// sent by pluginn manager when action or task finished executing
		private function OnScheduleRestart(evt:ZG_Event):void
		{
			
			var pluginRes:FT_PluginResult = evt.data as FT_PluginResult;
			
			if( pluginRes !=null)
			{
				// see if this is a task or plugin
				var execObj:FT_PluginExec = pluginRes.execObj;
				
				var targetObj:ZG_PersistentObject = pluginRes.execObj.requestObj.task;
				if(targetObj == null)
				{
					// this must be just a  plugin
					targetObj = pluginRes.execObj.requestObj.pluginsList[0];
				}
				if( targetObj !=null )
				{
					var schedule: FT_Schedule = FindScheduleForTarget(targetObj.guid);
					if( schedule !=null)
					{
						schedule.SetNextRunDate();
					}
				}
			}
		}
		//-----------------------------
		// find schedule that contains this plugin or task
		protected function FindScheduleForTarget(guid:String):FT_Schedule
		{					
			for(var i:int = 0; i < _schedules.length;++i)
			{
				if(_schedules[i].FindTargetObject(guid)!=null)
				{
					return _schedules[i];
				}			
			}
			return null;
		}		
	}
}
