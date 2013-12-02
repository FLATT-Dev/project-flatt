/*******************************************************************************
 * ZG_LocalPrefs.as
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
	import com.ZG.Logging.*;
	import flash.data.*;
	//import flash.filesystem.*;
	import flash.utils.*;
	
	import flash.events.IEventDispatcher;
	//===========================================
	public class ZG_LocalPrefs extends ZG_Prefs
	{
		// an xml containing a list of users and their passwords
		// each user item contains:name, password, language,account type and account
		// expiration date.
		
		
		public function ZG_LocalPrefs(target:IEventDispatcher=null)
		{
			super(target);
		}
		//--------------------------------------------
		override public function LoadPrefs():void	
		{
			
		}
				
		//------------------------------------------------------
		override public function GetPref(key:String):Object
		{			
			var storedValue:ByteArray = EncryptedLocalStore.getItem(key);
			if(storedValue!=null)
			{
				return storedValue.readUTFBytes(storedValue.length); 
			}
			return null;
		}
		//------------------------------------------------------
		override public function SetPref(key:String,val:Object):void
		{
			try
			{
				var bytes:ByteArray = new ByteArray();
				bytes.writeUTFBytes(val as String);
				trace("SetPref:Storing "+bytes.length + " bytes in ELS");
				EncryptedLocalStore.setItem(key, bytes);
				
			}
			catch( e:Error )
			{
				var str:String = "Failed to save pref:key=" + key + " val"+ val + "Error: "+e.message;
				trace(str);
				ZG_AppLog.GetInstance().LogIt(str,ZG_AppLog.LOG_ERR);
			}
		}
		
	}
}
