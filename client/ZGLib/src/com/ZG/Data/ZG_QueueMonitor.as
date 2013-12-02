/*******************************************************************************
 * ZG_QueueMonitor.as
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
package com.ZG.Data
{
	import com.ZG.Database.*;
	import com.ZG.Events.ZG_EventDispatcher;
	import com.ZG.UserObjects.ZG_QueueElement;
	
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	// Generic queue monitor.
	// Sets a timer and when the timer fires,processes elements in the queue
	// 
	public class ZG_QueueMonitor extends ZG_EventDispatcher
	{
		// various queue types we support.
		// In case of db   begin and end transaction statements will be
		// executed on the database manager
		
		public static var QUEUE_TYPE_DB:int 			=0;
		public static var QUEUE_TYPE_PLUGIN_EXEC:int 	= 1;
		
		private var _queueType:int;				
		private var _queueElements:Array;
		private var _timer:Timer;
		public static var DEF_INTERVAL:int = 10000; // 
		private var _inTransaction:Boolean;
		
		
		public function ZG_QueueMonitor(target:IEventDispatcher=null)
		{
			super(target);
			// default to queue type DB
			_queueType = QUEUE_TYPE_DB;
			_queueElements = new Array();
			_timer = new Timer(DEF_INTERVAL);
			_timer.addEventListener(TimerEvent.TIMER, OnQueueTimerEvent,false,0, true);
			//_timer.start();
		}
		//-------------------------------------------
		// Adds element to the queue - only if it is not there already
		public function AddElement(obj:Object,func:Function,priority:int):void
		{
			if( FindObject(obj) == null)
			{
				var newEl:ZG_QueueElement = new ZG_QueueElement();
				newEl.func = func;
				newEl.obj = obj;
				newEl.priority = priority;
				_queueElements.push(newEl);
				_queueElements.sortOn("priority",Array.NUMERIC);
			}
			
			if(queueType == QUEUE_TYPE_DB)
			{
				if( _queueElements.length >= 1 )
				{
					if(!_inTransaction)
					{
						trace("QueueMonitor:AddElement - beginning transaction");
						ZG_DatabaseMgr.GetInstance().BeginTransaction(true);
						_inTransaction = true;
						
					}
				}
			}
		}
		//-------------------------------------------
		private function OnQueueTimerEvent(e:TimerEvent):void
		{
			if(_queueElements.length > 0)
			{
				ProcessQueue();
			}
		}
		//-------------------------------------------
		public function ProcessQueue():void
		{
			// grab the first element from the queue it's guaranteed to have higher priority
			// as the array was sorted in ascending order
			if(_queueElements.length)
			{
				var curEl:ZG_QueueElement = _queueElements[0];
				// if func returns suceess - the object successfully executed the function. Otherwise
				// it didi not which means that the element must remain in the queue. 
				if( curEl !=null)
				{
					if(curEl.func(curEl.obj))
					{
						_queueElements.shift();
					}
				}				
			}
			// see if we need to commit the transaction
			else
			{
				if(queueType == QUEUE_TYPE_DB)
				{
					if(_inTransaction )
					{
						ZG_DatabaseMgr.GetInstance().EndTransaction(true);
						_inTransaction = false;
						trace("QueueMonitor:ProcessQueue-ending transaction");
					}
				}
			}
		}
		//---------------------------------------------------------
		private function FindObject(obj:Object):Object
		{
			for(var i:int=0; i < _queueElements.length;++i)
			{
				if(_queueElements[i].obj.id == obj.id)
				{
					return obj;
				}
			}
			return null;
		}
		
		//-------------------------------------------------
		// Public accessor
		public function IsOnQueue(obj:Object):Boolean
		{
			return (FindObject(obj)!=null)			
		}
		//-------------------------------------------------
		public function get queueType():int
		{
			return _queueType;
		}
		//-------------------------------------------------
		public function set queueType(value:int):void
		{
			_queueType = value;
		}
		
		
		
	}
}
