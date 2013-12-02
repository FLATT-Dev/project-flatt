/*******************************************************************************
 * ZG_QueueElement.as
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
	// a  wrapper that represents an element in a queue
	// Contains the queued object and a function pointer that executes on that object
	// also has the priority level 
	public class ZG_QueueElement
	{
		public static var PRIORITY_0:int = 0;
		public static var PRIORITY_1:int = 1;
		public static var PRIORITY_2:int = 2;
		public static var PRIORITY_3:int = 3;
		public static var PRIORITY_4:int = 4;

		
		
		private var _obj:Object;
		private var _func:Function;
		private var _priority:int = PRIORITY_1;
		
		
		public function ZG_QueueElement()
		{
		}
		
		//------------------------------------------------
		public function get obj():Object
		{
			return _obj;
		}
		//------------------------------------------------
		public function set obj(val:Object):void
		{
			_obj = val;;
		}
		//------------------------------------------------
		public function get func():Function
		{
			return _func;
		}
		//------------------------------------------------
		public function set func(val:Function):void
		{
			_func = val;
		}
		//------------------------------------------------
		public function get priority():int
		{
			return _priority;
		}
		//------------------------------------------------
		public function set priority(val:int):void
		{
			_priority = val;
		}
		
	}
}
