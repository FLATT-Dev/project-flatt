/*******************************************************************************
 * ZG_SimpleTokenParser.as
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
package com.ZG.Parsers
{
	import mx.utils.*;
	import flash.utils.Dictionary;
	import com.ZG.Utility.*;
	import com.ZG.Events.*;
	
	public class ZG_SimpleTokenParser extends ZG_GenericParser
	{
		public function ZG_SimpleTokenParser()
		{
			super();
		}
		
		// Subclasses override
		public override function Parse(inData:Object):void
		{
			// first try a simple CR separated file
			parsedData = ParseSimpleTokenFormat(inData as String,"\r");
			
			if(parsedData == null)
			{
				SetParseResult(ZG_Utils.TranslateString("SimpleTokenParser:ERROR"),false);
			}
			ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_PARSE_COMPLETE,parsedData);														
		}
		
		//--------------------------------------------------------
		// assumes that the data we need is after the token
		private function ParseSimpleTokenFormat(inData:String,token:String):Array
		{
			var arr:Array = String(inData).split(token);
			// trim the linefeeds
			if(arr)
			{
				for(var i:int=0;i < arr.length;++i)
				{
					arr[i] = StringUtil.trim(arr[i]);
					// prune empties
					if(arr[i] == "")
					{
						arr.pop();
					}
				}
			}
			return arr;
		}
		
	}
}
