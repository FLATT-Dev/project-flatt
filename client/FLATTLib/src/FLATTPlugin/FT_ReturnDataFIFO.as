/*******************************************************************************
 * FT_ReturnDataFIFO.as
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
package FLATTPlugin
{
	// this object represents data returned from host.
	// It keeps a list of host responses and 
	public class FT_ReturnDataFIFO
	{
		private var _dataList:Array = new Array();
		
		public function FT_ReturnDataFIFO()
		{
		}
		//-------------------------------
		public function Add(data:String):void
		{
			if(data.length > 0)
			{
				_dataList.push(data);
			}
		}
		//-------------------------------
		// removes data from list
		public function Get( removeFromList:Boolean = true ):String
		{
			var data:String = "";
			if(_dataList.length > 0)
			{
				data = ( removeFromList ? _dataList.shift(): _dataList[0]);
			}
			return data;
		}
		//------------------------
		public function Clear():void
		{
			_dataList.length = 0;
		}
		//---------------------------
		public function HasData():Boolean
		{
			return (_dataList.length > 0);
		}
	}
}
