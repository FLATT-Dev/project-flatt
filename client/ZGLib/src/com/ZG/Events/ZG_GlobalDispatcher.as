/*******************************************************************************
 * ZG_GlobalDispatcher.as
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
	import flash.events.IEventDispatcher;

	// events dispatching is funky in flex -  you cannot just dispatch an event and rely on the system to 
	// deliver it to everyone who is listening. Instead, you have to specify the target of an event
	// to the object that is dispatching it. 
	// This is an attempt to work around this limitation.This singlngleton object dispatches events
	// on behalf of transient objects.
	//This is not finished
	public class ZG_GlobalDispatcher extends ZG_EventDispatcher
	{
		private static var s_Instance:ZG_GlobalDispatcher;
		
		public function ZG_GlobalDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		//-----------------------------------------------------------------		
		public static function GetInstance():ZG_GlobalDispatcher
		{						
			if(s_Instance==null)
			{
				s_Instance = new ZG_GlobalDispatcher();
			}				
			return s_Instance;
		}		
		
	}//class
}//package
