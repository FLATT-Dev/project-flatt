/*******************************************************************************
 * ZG_HtmlTableParser.as
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
	
	public class ZG_HtmlTableParser extends ZG_GenericParser
	{
		/* reasonable number of rows in the table - there has to 
		   be at least the broker name, account info and some trades 
		*/
		public static var MIN_NUM_ROWS:int = 5;
		
		public function ZG_HtmlTableParser(target:IEventDispatcher=null)
		{
			super(target);
			parsedData = new Array();// superclass variable
		}
		
		public override function Parse(inData:Object):void
		{			
			ParseHtml(inData as String);
			
			if( parsedData.length < MIN_NUM_ROWS )
			{			
				SetParseResult(ZG_Utils.TranslateString("ERROR: Failed to parse MetaTrader HTML"),false);					
				parsedData = null;				
			}
			ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_PARSE_COMPLETE,parsedData);	
			
		}
		
		//-----------------------------------
		private function ParseHtml( strHtml:String):void
		{
			var rawRows:Array = null;
			// find everything between table tags
			var table:Array = strHtml.match(/<(table){1}.*?>.*?<(\/table){1}[^>]*?>/gis);
			FindBrokerName(strHtml);
			
			if( table.length )
			{
				// find all rows
				rawRows = table[0].match(/<(tr){1}.*?>.*?<(\/tr){1}[^>]*?>/gis);
									
				if(rawRows && rawRows.length)
				{
					
					
					for( var i:int =0; i < rawRows.length;++i)
					{
						var curRow:ZG_MTTableRow = new ZG_MTTableRow();
						if(curRow.AddColumns(rawRows[i]))
						{
							parsedData.push(curRow);
						}
						
					}
				}
			}
			
		}
		//-------------------------
		/* Find the name of the broker in the HTML. It is after the body tag but before the table tag.
		*/
		private function FindBrokerName(strHtml:String):void
		{
			//var temp:Array = strHtml.match(/<(body){1}.*?>.*?<(\/br){1}[^>]*?>/gis);
			var pos1:int = strHtml.indexOf("<body");
			var pos2 :int = -1;
			var brokerName:String = null;
			if( pos1 >=0)
			{
				pos1  = strHtml.indexOf("<b>",pos1);
				if( pos1 >=0)
				{
					pos1+=3;
					pos2 = strHtml.indexOf("</b>",pos1);
					if( pos2 > pos1)
					{
						brokerName=strHtml.substr(pos1,pos2-pos1);
					}
				}
				
			}
			if(brokerName!=null)
			{
				var row:ZG_MTTableRow = new ZG_MTTableRow();
				row.AddColumn(brokerName);
				parsedData.push(row);
			}
			
		}
		
	}
}
