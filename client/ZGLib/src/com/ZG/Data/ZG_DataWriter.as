/*******************************************************************************
 * ZG_DataWriter.as
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
	import com.ZG.Events.ZG_EventDispatcher;
	import flash.events.IEventDispatcher;
	import com.ZG.UserObjects.ZG_PersistentObject;
	
	public class ZG_DataWriter extends ZG_EventDispatcher
	{
		
		private static var s_Instance : ZG_DataWriter;	
		
		public static function GetInstance():ZG_DataWriter
		{			
			return s_Instance;
		}	
		public static function SetInstance(val:ZG_DataWriter):void
		{
			s_Instance = val;
		}
		
		public function ZG_DataWriter(target:IEventDispatcher=null)
		{
			super(target);
		}
				
		public function Update(obj:ZG_PersistentObject, forceUpdate:Boolean = false):void
		{
			
		}		
		public function Insert(obj:ZG_PersistentObject):void
		{
			
		}
		
		public function Delete(obj:ZG_PersistentObject):void
		{
			
		}
		
		public function UpdateTradeTableProperties(props:Array):void
		{
			
		}
		
		public function BatchInsert(cmd:String):void
		{
			
		}
	}
}
