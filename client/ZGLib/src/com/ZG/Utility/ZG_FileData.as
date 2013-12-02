/*******************************************************************************
 * ZG_FileData.as
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
package com.ZG.Utility
{
	//=======================================
	//This utility class encapsulates the data read from the file and the file extension
	//Used when user selects a file from the file system. The file extension helps the code
	// that gets called when the user makes a selection, determine how to parse the file contents
	
	public class ZG_FileData
	{
		private var _data:Object;
		private var _extension:String = "";
		private var _fileName:String = "";
		//-----------------------------------------------------
		public function ZG_FileData()
		{
		}
		//-----------------------------------------------------
		public function get data():Object
		{
			return _data;
		}
		//-----------------------------------------------------
		public function set data(val:Object):void
		{
			_data = val;
		}
//-----------------------------------------------------
		public function get extension():String
		{
			return _extension;
		}
		//-----------------------------------------------------
		public function set extension(val:String):void
		{
			_extension = val;
		}
		//-----------------------------------------------------
		public function get fileName():String
		{
			return _fileName;
		}
		//-----------------------------------------------------
		public function set fileName(value:String):void
		{
			_fileName = value;
		}

	}
}
