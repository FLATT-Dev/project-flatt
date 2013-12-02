/*******************************************************************************
 * ZG_InsertObject.as
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
	//  This object is used to send events about insertion of various objects
	//into UI
	
	public class ZG_InsertObject
	{
		private var _self:Object;
		private var _insertIntoDB:Boolean;
		
		public function ZG_InsertObject()
		{
		}
		//--------------------------------------
		public function get self():Object
		{
			return _self;
		}
		//--------------------------------------
		public function set self(value:Object):void
		{
			_self = value;
		}
		//--------------------------------------
		public function get insertIntoDB():Boolean
		{
			return _insertIntoDB;
		}
		//--------------------------------------
		public function set insertIntoDB(value:Boolean):void
		{
			_insertIntoDB = value;
		}


	}
}
