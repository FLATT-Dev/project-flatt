/*******************************************************************************
 * ZG_GenericParser.as
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
	import com.ZG.Events.*;
	import com.ZG.Utility.*;
	
	import flash.events.IEventDispatcher;
	
	public class ZG_GenericParser extends ZG_EventDispatcher
	{
		private var _parseResult:Boolean;
		private var _parseMessage:String;
		private var _parsedData:Object;
		
		public function ZG_GenericParser(target:IEventDispatcher=null)
		{
			super(target);
			// Assume success
			parseResult = true;
			parseMessage = "";
		}
		// Subclasses override
		public function Parse(inData:Object):void
		{
			
		}
		public function get parseResult():Boolean
		{
			return _parseResult;
		}
		public function set parseResult(val:Boolean):void
		{
			_parseResult = val;
		}
		
		public function get parseMessage():String
		{
			return _parseMessage;
		}
		public function set parseMessage(val:String):void
		{
			_parseMessage = val;
		}
		
		public function SetParseResult(message:String,val:Boolean):void
		{
			parseResult = val;
			parseMessage = message;
		}
		
		public function get parsedData():Object
		{
			return _parsedData;
		}
		public function set parsedData(val:Object):void
		{
			_parsedData = val;
		}

	}
}
