/*******************************************************************************
 * ZG_DataReader.as
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
	import com.ZG.Events.*;
	import com.ZG.UserObjects.*;
	import com.ZG.Utility.*;
	
	import mx.collections.*;

	
	/* Base class used for various data objects */
	public class ZG_DataReader extends ZG_EventDispatcher
	{				
		
		//protected var m_RootObj:ZG_ArrayCollection;
		//protected var _rootObj:ZG_PersistentObject;
		protected var _rootList:ArrayCollection;
		protected var _rootObj:ZG_PersistentObject;
		private static var s_Instance : ZG_DataReader;	
		
		public static function GetInstance():ZG_DataReader
		{			
			return s_Instance;
		}	
		public static function SetInstance(val:ZG_DataReader):void
		{
			s_Instance = val;
		}
		
		public function ZG_DataReader()
		{
			super();
			_rootList = new ArrayCollection();
			// add root object here
			_rootObj = new ZG_PersistentObject();
			_rootList.addItem(_rootObj);			
		}
		// this is the root object of the whole tree thing
		public function GetRootObject():ZG_PersistentObject //ArrayCollection
		{
			return _rootObj;
		}
		public function GetRootList():ArrayCollection
		{
			return _rootList;
		}
		
		public function GetChildren(parent:ZG_PersistentObject):void
		{
			
		}	
		
		// dispatch routine that handles updating objects maps and notifying UI
		// applies to filters, strategy, instrument
		public function UI_UpdateObject(obj:ZG_PersistentObject,sendEvent:Boolean,remove:Boolean):void
		{
		}
		
	}
}
