/*******************************************************************************
 * FT_ReturnDataInfo.as
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
	import Utility.*;
	public class FT_ReturnDataInfo
	{
		
		public static var SEPARATOR_TYPE_SPACE:String = "Space";
		public static var SEPARATOR_TYPE_COMMA:String = "Comma";
		public static var SEPARATOR_TYPE_SEMICOLON:String = "Semicolon";
		public static var SEPARATOR_TYPE_TAB:String = "Tab";
		public static var SEPARATOR_TYPE_COLON:String = "Colon";
		
		private var _type:String = FT_Strings.RTYPE_TEXT;
		private var _numColumns:Number = 0;
		private var _dataSeparator:String = "";
		private var _description:String = "";
		
		public function FT_ReturnDataInfo(xml:XMLList)
		{			 
			 _type = xml.@type;
			_numColumns = xml.NumColumns;
			_dataSeparator = xml.DataSeparator;
			_description = xml.Description;
		}
		//-------------------------	
		public function get dataSeparatorType():String
		{
			return _dataSeparator;
		}
		//-------------------------	
		public function set dataSeparatorType(val:String):void
		{
			_dataSeparator = val;
		}
		//-------------------------	
		public function get dataSeparatorValue():String
		{
			if(_dataSeparator == SEPARATOR_TYPE_SPACE)
			{
				return " ";
			}
			else if(_dataSeparator == SEPARATOR_TYPE_COMMA)
			{
				return ",";
			}
			else if(_dataSeparator == SEPARATOR_TYPE_SEMICOLON)
			{
				return ";";
			}
			else if(_dataSeparator == SEPARATOR_TYPE_TAB)
			{
				return "	";
			}
			else if(_dataSeparator == SEPARATOR_TYPE_COLON)
			{
				return ":";
			}
			// default to space
			return SEPARATOR_TYPE_SPACE;
		}
		//-------------------------	
		// return type is lowercase
		public function get type():String
		{
			return _type;
		}
		//-------------------------	
		public function set type(value:String):void
		{
			_type = value;
		}
		//-------------------------	
		public function get numColumns():Number
		{
			return _numColumns;
		}
		//-------------------------	
		public function set numColumns(value:Number):void
		{
			_numColumns = value;
		}
		//-------------------------	
		public function get description():String
		{
			return _description;
		}
		//-------------------------	
		public function set description(value:String):void
		{
			_description = value;
		}
		//-------------------------	

		//-------------------------	
		//-------------------------	
		//-------------------------	
		//-------------------------	

	}
}
