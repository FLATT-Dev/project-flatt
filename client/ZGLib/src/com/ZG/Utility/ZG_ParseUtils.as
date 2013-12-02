/*******************************************************************************
 * ZG_ParseUtils.as
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
	// This file contains functions to parse various file formats we understand.
	// Currently supported formats:
	
	//-simple token separated file:Parses the file contents into an array based on the token provided (used to parse symbol file)
	//-.sym file . The format is
	// =<Stock exchange>:<Symbol>, e.g.: =NYSE:AIN
	// XXX!. For parsing complex  formats  override ZG_GenericParser
	
	import com.ZG.Parsers.*;
	import flash.utils.Dictionary;
	import mx.utils.*;
	import mx.controls.Alert;
	
	public class ZG_ParseUtils
	{
		public function ZG_ParseUtils()
		{
		}
		//---------------------------------------------------------------
		// parse a file based on the extension and return the parsed data
		// for now it's an array
		public static function Parse(fileData:ZG_FileData):Object
		{
			if(fileData.extension==ZG_Strings.STR_TEXT_EXT)
			{
				return ParseTextFile(fileData.data);
			}
			else if(fileData.extension==ZG_Strings.STR_SYM_EXT)
			{
				return ParseSymFile(fileData.data as String);
			}
			return null;
		}
		
		public static function ParseTextFile(data:Object):Object
		{
			
			var parser:ZG_SimpleTokenParser = new ZG_SimpleTokenParser();
			parser.Parse(data);
			if( parser.parsedData == null )
			{
				//TODO:Try another format
			}
			return parser.parsedData;		
		}
	
		//---------------------------------------------------
		public static function ParseSymFile(data:String):Array
		{
			
			// TODO: use SymFileParser object
			
			var arr:Array = String(data).split("\r");
			var ret:Array = new Array();
			// Split into lines
			if( arr!=null)
			{
				// each line contains a string in this format:
				//=<Stock exchange>:<Symbol>, e.g.: =NYSE:AIN
				for(var i:int = 0; i < arr.length;++i)
				{
					var arr2:Array = arr[i].split(":");
					if(arr2 && arr2.length >1)
					{
						ret.push(arr2[1]);
					}
				}
			}
			return ret;
		}
		
		//------------------------------------------------------
		public static function ParseKeyValueFile(data:String):Dictionary
		{
			var ret:Dictionary = null;
			var arr:Array = String(data).split("\r");
			if(arr!=null)
			{
				ret = new Dictionary();
				for(var i:int = 0; i < arr.length;++i)
				{
					var arr2:Array = arr[i].split("=");
					if(arr2!=null && arr2.length >1)
					{
						ret[StringUtil.trim(arr2[0])]= StringUtil.trim(arr2[1]);
					}
				}				
			}
			return ret;
		}		
							
	}
	
		

}
