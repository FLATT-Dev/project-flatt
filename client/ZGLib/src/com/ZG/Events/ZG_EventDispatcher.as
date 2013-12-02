/*******************************************************************************
 * ZG_EventDispatcher.as
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
package com.ZG.Events
{
	import com.ZG.Utility.*;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class ZG_EventDispatcher extends EventDispatcher
	{
		public function ZG_EventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		// dispatch an event to UI
		public function DispatchEvent(evtType:String,data:Object=null,xtraData:Array=null):Boolean
		{			
		    return ZG_Utils.ZG_DispatchEvent(this,evtType,data,xtraData);
		}		
		
	}
}
