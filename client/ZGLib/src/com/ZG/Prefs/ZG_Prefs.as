/*******************************************************************************
 * ZG_Prefs.as
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
package com.ZG.Prefs
{
	import com.ZG.Events.ZG_EventDispatcher;
	
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	//------------------------------------------------------
	public class ZG_Prefs extends ZG_EventDispatcher
	{
		
		
		private static var s_IsLocal:Boolean  = true;
		public static const PREF_USERLIST:String = "UserList";
		//private var _prefsMap:Dictionary = new Dictionary();
	
		
		
		public function ZG_Prefs(target:IEventDispatcher=null)
		{
			super(target);
		}		
	
		//------------------------------------------------------
		public function GetPref(key:String):Object
		{
			return null; //_prefsMap[key];
		}
		//------------------------------------------------------
		public function SetPref(key:String,val:Object):void
		{
			//_prefsMap[key] = val;
			SavePrefs();
		}
		//------------------------------------------------------
		public function LoadPrefs():void
		{		
		}
		//-----------------------------------------------------
		public function SavePrefs():void
		{
			
		}
	}//class
}// package
