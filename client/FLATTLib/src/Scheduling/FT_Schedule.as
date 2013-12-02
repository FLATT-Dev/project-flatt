/*******************************************************************************
 * FT_Schedule.as
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
	import Application.*;
	
	import FLATTPlugin.*;
	
	import TargetHostManagement.*;
	import TargetHostManagement.FT_TargetHost;
	
	import Utility.*;
	
	import com.ZG.UserObjects.*;
	import com.ZG.Utility.*;
	import com.ascrypt3.*;
	
	import flash.events.*;
	import flash.filesystem.*;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	/* The schedule uniqueness is determined by the host and time interval
		There may be more than one action or task using the schedule
	
	<FT_Schedule guid="12345" name="my sched" type="0">
		
	<Interval>
		10
	</Interval>
	
	<Host>
	ec2-50-112-70-228.us-west-2.compute.amazonaws.com	
	</Host>
	<NextRunDate>
	0
	</NextRunDate>
	
	
	<TargetObjects>
		<TargetObject guid="1234">
		</TargetObject>
	</TargetObjects>
	
	</FT_Schedule>);
	
	*/
	public class FT_Schedule extends ZG_PersistentObject
	{
		
		public static var TYPE_INTERVALS:String="0";// repeat at given intervals in minutes
		public static var TYPE_DAILY:String = "1";
		public static var TYPE_WEEKLY:String = "2";
		public static var TYPE_MONTHLY:String = "3";
		
		
		protected var _targetObjects:Array = new Array();// can be action or task. more than 1  action or task may have the schedule
		protected var _interval:Number = new Number(0);// only used on recurring
		//protected var _endDate:Date;
		protected var _timer:Timer;
		protected var _disabled:Boolean;
		protected var _host:FT_TargetHost; // host or a group.
		//protected var _repeatCount: int;
		protected var _file:File;
		protected var _initDate:Date; 
		protected var  _nextRunDate:Date; // when the schedule needs to run next. Used for daily, weekly and monthly. Omitted for recurring intervals
		// i.e every 10 mins
	
		public function FT_Schedule()
		{
			super();
			_guid = GUID.create();					
		}		
		//-----------------------------------
		override public function FromXML(strXml:String):void
		{
			var ret:Boolean = true;
			try
			{
				var xml:XML = new XML(strXml);
				_guid = xml.@guid;
				_name = xml.@name;
				_type = xml.@type;
				
				// for type daily and up this is the actual date of the next run  in seconds 
				_interval = xml.Interval;
				
				_nextRunDate = (_type ==  TYPE_INTERVALS ? null : new Date(_interval));
			
				_host = FT_Prefs.GetInstance().FindTargetHost(xml.Host);				
				BuildTargetObjectsList(xml);										
			}
			catch(e:Error)
			{
				
			}		
		}
		//---------------------------------------
		public function Initialize():void
		{
			ResetInitTime();
			
			if(!Process(false))
			{
				/* If the action execution was started don't start the timer. 
				 It is done when the execution completes.
				 * Otherwise start the timer
				 * Interval value is in seconds. The timer expects milliseconds so multiply by 1000
				*/
				StartTimer((_nextRunDate == null ?  _interval : 60) * 1000);
			}
		}
		//----------------------------------------------		
		override public function ToXML():XML
		{
			
			var xml: XML = new XML(<FT_Schedule></FT_Schedule>);
			
			
			xml.@guid = _guid;
			xml.@name = _name;
			xml.@type = _type;
			
			xml.appendChild(<Host>{_host.name}</Host>);			
			xml.appendChild(<Interval>{_interval}</Interval>);
			TargetObjectsToXML(xml);			
			return xml;
		}
		//----------------------------------------------
		override public function Write(param:Object=null):Boolean
		{
			return ZG_FileUtils.WriteFile(_file,ToXML().toString(),true,FileMode.WRITE);			
		}
		//--------------------------------------
		override public function Read(file:File,param1:Object):Boolean
		{
			var ret:Boolean = true;
			
			_file = file;
			try
			{
				var strXml:String = ZG_FileUtils.ReadFile(_file,true) as String;
				FromXML(strXml);
				ret = IsValid();				
			}
			catch(e:Error)
			{
				ret = false
			}
			return ret;
		}
		//--------------------------------------------
		override public function IsValid():Boolean
		{
			return (_guid!="" && _host != null);
		}
		//-----------------------------------------
		override public function Cleanup():void
		{
			if(_file!=null)	
			{
				try
				{
					_file.deleteFile();
				}
				catch(x:Error)
				{
					
				}
				finally
				{
					_file = null;
				}
			}
			// schedule is being deleted - null the timer
			Disable(true);
		}
		
		//-----------------------------------
		/* Used only with recurring interval */
		public function set interval(val:int):void
		{
			_interval = val;
		}
		//-----------------------------------
		public function get interval():int
		{
			return _interval;
		}
		/*
		//-----------------------------------
		public function get repeatCount():int
		{
			return _repeatCount;
		}
		//------------------------------------
		public function set repeatCount(val:int):void
		{
			_repeatCount = val;
		}*/
		//-----------------------
		// process schedule - called on startup or when the schedule is first associated with the action
		private function Process(wasTimerEvent:Boolean):Boolean
		{
			//check the time and determine if schedule needs to run
			// see if it is associated with an Action or Task
			// Cannot run without this.
			var executeTargets:Boolean = false;
			var curDate:Date = new Date();
			
			if(_targetObjects.length > 0)
			{
				switch( _type )
				{
					case TYPE_INTERVALS:
					{
						//get the time delta between current time and init time in minutes
						
						if( wasTimerEvent )
						{
							executeTargets = true; 
						}
						else
						{
							var timeDelta:Number = (curDate.time - _initDate.time) / 6000;
							executeTargets = (timeDelta >= _interval);
						}			
						break;
					}
					default:
						executeTargets = (curDate.time >= _nextRunDate.time);
						break;
					}				
				// start execution when timer exp
				if(executeTargets)
				{
					DispatchEvent(FT_Events.FT_EVT_SCHEDULE_EXEC_EVT,this);				
				}			
			}
			return executeTargets;
		}
		
		//--------------------------------------
		// this is only needed if the type is "intervals"
		public function ResetInitTime():void
		{
			_initDate= new Date();
		}
		//--------------------------------------
		private function StartTimer(interval:int):void
		{
			if(_timer == null)
			{
				// timer accepts milliseconds
				_timer = new Timer(interval,1);
				_timer.addEventListener(TimerEvent.TIMER, OnTimerEvent);
			}
			_timer.start();
		}
		//-----------------------------------
		/* Can be called when a schedule is deleted */
		public function Disable(deleteTimer: Boolean):void
		{
			_disabled = true;
			if(_timer!=null)
			{
				_timer.stop();
				if(deleteTimer)
				{
					_timer.removeEventListener(TimerEvent.TIMER,OnTimerEvent);
					_timer = null;
				}
			}
		}
		//-----------------------------------
		public function set AddTargetObj(val: ZG_PersistentObject):void
		{
			if(FindTargetObject(val.guid) == null)
			{
				_targetObjects.push(val);
			}
		}
		//------------------------------------------------------
		public function set RemoveTargetObj(val: ZG_PersistentObject):void
		{
			if(FindTargetObject(val.guid) == null)
			{
				_targetObjects.splice(_targetObjects.indexOf(val),1);
			}
		}
		//-----------------------------------
		public function get targetObjects():Array
		{
			return _targetObjects;
		}
		//--------------------------------
		public function FindTargetObject(guid:String):ZG_PersistentObject
		{
			for (var i: int; i < _targetObjects.length; ++i )
			{
				if(_targetObjects[i].guid == guid)
				{
					return _targetObjects[i];
				}
			}
			return null;
		}
		
		//----------------------------
		protected function OnTimerEvent(event:TimerEvent):void
		{			
			if(!_disabled)
			{
				//Process(true); // decide if target object need to execute		
				if(!Process(true))
				{
					/* If the action execution was started don't start the timer. It is done when the execution completes.
					* Otherwise start the timer
					*/
					StartTimer((_nextRunDate == null ?  _interval : 1) * 60 * 1000);
				}
			}
		}		
		//---------------------------------
		public function get file():File
		{
			return _file;
		}//---------------------------------
		public function set file(val:File):void
		{
			_file = val;
		}
		//-----------------------------------------
		private function BuildTargetObjectsList(xml:XML):void
		{
			
			var targObjsList:XMLList = xml.TargetObjects.TargetObject;
				
			if(targObjsList!=null)
			{
				for (var i:int =0 ; i < targObjsList.length();++i)
				{
					var curGuid:String = targObjsList[i].@guid;
					var targetObj:ZG_PersistentObject  = FT_PluginManager.GetInstance().FindPlugin(curGuid);
					if( targetObj == null)
					{
						// maybe it's a task
						targetObj = FT_PluginManager.GetInstance().FindTask(curGuid);							
					}
					if( targetObj!=null)
					{
						this._targetObjects.push(targetObj);
					}
				}
			}
			
		}
		//----------------------------------
		private function TargetObjectsToXML(xml:XML):void
		{
			var targetObjectsXml:XML = new XML(<TargetObjects></TargetObjects>);
			
			for( var i: int = 0; i < _targetObjects.length;++i)
			{
				var cur:XML = new XML(<TargetObject></TargetObject>);
				cur.@guid = _targetObjects[i].guid;
				targetObjectsXml.appendChild(cur);
			}
			xml.appendChild(targetObjectsXml);
		}
		//----------------------------------
		public function get host():FT_TargetHost
		{
			return _host;
		}
		//----------------------------------
		public function set host(value:FT_TargetHost):void
		{
			_host = value;
		}
		
		//-----------------------------------
		// Set next run date depending on the type
		// called after schedule completed execution or on program startup
		public function SetNextRunDate():void
		{
			/* by default timer interval is 1 minute.
			var 
			*/
			var ret:Boolean = false;
			switch( _type )
			{				
				case TYPE_INTERVALS:
					ret = true;
					break;
				case TYPE_DAILY:					
					_nextRunDate.date+=1;
					break;
				case TYPE_WEEKLY:
					_nextRunDate.date+=7;
					break;
				case TYPE_MONTHLY:				
					_nextRunDate.month+=1;
					break;	
			}
			// update next run date for types other than INTERVALS
			// interval is used as number of minutes between runs if the type is INTERVALS
			// for  all other types this is the date of the next run in milliseconds 
			if(_type!=TYPE_INTERVALS)
			{
				_interval = _nextRunDate.time;
				Write();
			}
			
			StartTimer((_nextRunDate == null ?  _interval : 1) * 60 * 1000);	
									
			// interval is only used if schedule runs every <n> minutes.
			if(_nextRunDate!=null)
			{
				trace("New date set to " + _nextRunDate.toString());
			}
		}		
		
	}// class end
	
}// pkg end
