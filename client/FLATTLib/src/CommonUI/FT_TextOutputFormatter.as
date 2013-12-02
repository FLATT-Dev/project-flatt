/*******************************************************************************
 * FT_TextOutputFormatter.as
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
package CommonUI
{
	import FLATTPlugin.*;
	import Exec.*;
	import com.ZG.Utility.*;
	
	public class FT_TextOutputFormatter
	{
		private var _name:String="";// name of plugin of task.
		private var _prevHost:String="";
		private var _isTask:Boolean;
		
		protected static var STR_STYLE_DEF:String ="<style type='text/css'>"+
			"span.ExecSuccess {color:black;font-weight:bold;font-size:9pt}"+
			"span.ExecErr {color:red;font-weight:bold;font-size:9pt}"+
			"span.ExecWarn {color:#ffA500;font-weight:bold;font-size:9pt}"+
			"span.FontNormal8 {font-weight:normal;font-size:8pt} "+
			"span.FontNormal9 {font-weight:normal;font-size:9pt} </style>";
		
		protected static var STR_NORMAL_ROW:String ="<tr><td><span class='FontNormal9'>%d.&nbsp;%s:&nbsp;%s</span>"+
													"&nbsp;<td><span class='ExecSuccess'>OK</span>";
		
		protected static var STR_ERR_ROW:String ="<tr><td><span class='FontNormal9'>%d.&nbsp;%s:&nbsp;%s</span>&nbsp;"+
												"<td><span class='ExecErr'>Error</span>";
		
		protected static var STR_PLUGIN_ROW:String ="<tr><td><span class='FontNormal8'>%s</span>";
													//"<td><span class='ExecErr'>Error</span>";
		
		
		protected static var STR_WARN_ROW:String ="<tr><td><span class='FontNormal9'>%d.&nbsp;%s:&nbsp;%s</span>&nbsp;"+
			"<td><span class='ExecWarn'>Warning</span>";
		
		
		protected static var STR_SPAN_NORMAL8:String ="<span class='FontNormal8'>";
		protected static var STR_SPAN_NORMAL9:String ="<span class='FontNormal9'>";
		protected static var STR_SPAN_SUCCESS:String ="<span class='ExecSuccess'>";
		protected static var STR_SPAN_CLOSE:String="</span>";
		protected static var STR_SPAN_ERR:String="<span class='ExecErr'>";
		protected static var STR_SPAN_WARN:String="<span class='ExecWarn'>";
		protected static var STR_SPAN_FONT_NORMAL:String="<span class='FontNormal'>";
		protected static var STR_NBSP:String="&nbsp;";
		protected static var STR_TABLE:String = "<TABLE>"
		protected static var STR_TABLE_CLOSE:String="</TABLE>";
		protected static var STR_HEADER:String = "<hr><span class='ExecSuccess'>Host '%s'</span><br>"
		protected static var STR_NEXT_ROW_MARKER:String = "<!--next_row-->"; // where next data will go in table row
		protected static var STR_NEXT_HOST_MARKER:String = "<!--next_host-->"; // where next host will go
		protected static var STR_BODY_OPEN:String = "<body>";
		protected static var STR_BODY_CLOSE:String = "</body>";
		//
		public function FT_TextOutputFormatter()
		{
			
		}
		//------------------------------
		//Format  text output. Handles out of sequence data packets and inserts them under the correct host
		public function FormatOutput(curString:String,result:String,data:String,host:String,itemIndex:int,pluginName:String):String
		{
			var ret:String ="";
			var currentString:String = curString;
			var isNewHost:Boolean = false;
			// determine if this is a taks based on the last 2 parameters that are task  specicic
			var isTask:Boolean = (itemIndex >=0 && (pluginName!=null && pluginName.length > 0));
			data = ZG_StringUtils.ConvertToHtmlLineBreaks(ZG_StringUtils.CleanupHtmlTags(data));
			
			if(curString == null)
			{
				return ret;
			}
			var hostIndex:int = FindHost(curString,host);
			// on the first run insert the body tag
			if(currentString.indexOf(STR_BODY_OPEN) == -1)
			{
				ret = STR_BODY_OPEN + STR_STYLE_DEF;
			}
			// make sure the host does has not been added already
			//if(_prevHost!= host /*&& ((hostIndex = curString.indexOf(host)) == -1)*/)
			/*{
				isNewHost = true;
				//if(isTask)
				{
					// If we're starting a new host - clear the next row insert marker left inside the table if it exists
					if(currentString.indexOf(STR_NEXT_ROW_MARKER)!=-1)
					{
						currentString = currentString.replace(STR_NEXT_ROW_MARKER,""); 
					}
				}
				_prevHost = host;
				ret+=FormatHeader(host);
				//if(isTask)
				{
					ret+=STR_TABLE;
				}
			}
			else
			{
				// it's an existing host. Find its index
				hostIndex = curString.indexOf(host);
			}*/
			
			if(hostIndex == -1)
			{
				isNewHost = true;				
				// If we're starting a new host - clear the next row insert marker left inside the table if it exists
				if(currentString.indexOf(STR_NEXT_ROW_MARKER)!=-1)
				{
					currentString = currentString.replace(STR_NEXT_ROW_MARKER,""); 
				}			
			
				ret+=FormatHeader(host);
				ret+=STR_TABLE;
			}
						
			ret+=(isTask? FormatTaskOutput((isNewHost? "" : currentString),result,data,itemIndex,pluginName,hostIndex):FormatPluginOutput((isNewHost? "" : currentString),data,hostIndex));
			// make sure there is a closing body tag
			// if it's a new host, replace the new host marker with just created output and move the host marker 
			// do it only if ther is  some output in the current strig
			if( isNewHost )
			{
				if(currentString.indexOf(STR_NEXT_HOST_MARKER)!=-1)
				{
					currentString = currentString.replace(STR_NEXT_HOST_MARKER,ret+STR_NEXT_HOST_MARKER);
					ret = currentString;
				}
			}
			if(ret.indexOf(STR_BODY_CLOSE) == -1)
			{				
				ret+=(STR_NEXT_HOST_MARKER+STR_BODY_CLOSE);
			}
			return ret;
		}
		//----------------------------------------------------
		// Reset to defaults
		public function Reset():void
		{
			_name = "";
			_prevHost = "";
			_isTask = false;
		}
		//-----------------------------------------------------
		private function FormatTaskOutput(curString:String,result:String,data:String,itemIndex:int,pluginName:String,hostIndex:int):String
		{
			 var ret:String ="";
			 
			 var rowType:String = "";
			 // determine what row we're dealing with
			 switch(result)
			 {
				 case FT_PluginExec.EXEC_RESULT_OK:
					 rowType = STR_NORMAL_ROW;
					 break;
				 case FT_PluginExec.EXEC_RESULT_ERR:
					 rowType = STR_ERR_ROW;
					 break;
				 case FT_PluginExec.EXEC_RESULT_WARN:
					 rowType = STR_WARN_ROW;
					 break;					 
			 }
			 
			 
			 var curRow:String = ZG_StringUtils.Sprintf(rowType,itemIndex,pluginName,data);
			 return PostFormat(curRow,curString,hostIndex);
			 
			 /*var replacedStr:String = curString.replace(STR_NEXT_ROW_MARKER,curRow+STR_NEXT_ROW_MARKER);
			 // first time around there is no marker
			 ret = (replacedStr.length > 0 ? replacedStr: curRow);
			 // mark the place where the next row in table will go
			 // only add the table close tag once
			 if(replacedStr== "")
			 {
				 ret+=(STR_NEXT_ROW_MARKER + STR_TABLE_CLOSE);
			 }			 			 
			 return ret;*/
		}
		// with plugins just return the output
		private function FormatPluginOutput(curString:String,data:String,hostIndex:int):String
		{									
			var ret:String ="";			
			var curRow:String = ZG_StringUtils.Sprintf(STR_PLUGIN_ROW,ZG_StringUtils.ConvertToHtmlLineBreaks(data));
			return PostFormat(curRow,curString,hostIndex);
			
			//return  (STR_SPAN_NORMAL8 + ZG_StringUtils.ConvertToHtmlLineBreaks(data) + STR_SPAN_CLOSE);;
		}
		
		//-----------------------------------------------------
		// common post formatting . inserts new text and then does the following:
		// If no next row marker exists - adds it. If it already exists - search for nex row marker after appropriate host
		// and insert new text before the marker
		private function PostFormat(curRow:String,curString:String,hostIndex:int):String
		{
			var ret:String = "";
			if(hostIndex >=0)
			{
				// this host already exists in the current string ( combined output)
				// find it and insert current row before this host's next row marker
				var tableCloseInxex:int = curString.indexOf(STR_TABLE_CLOSE,hostIndex);
				if(tableCloseInxex >=0)
				{					
					ret = curString.substring(0,hostIndex)+ curString.substring(hostIndex,tableCloseInxex)+
											curRow+
											curString.substring(tableCloseInxex,curString.length);
				}
				else
				{
					//his is bad!
					trace ("cannot find next row marker for existing host!");
				}				
			}
			else
			{
				var replacedStr:String = curString.replace(STR_NEXT_ROW_MARKER,curRow+STR_NEXT_ROW_MARKER);
				// first time around there is no marker
				ret = (replacedStr.length > 0 ? replacedStr: curRow);
				// mark the place where the next row in table will go
				// only add the table close tag once
				if(replacedStr== "")
				{
					ret+=(STR_NEXT_ROW_MARKER + STR_TABLE_CLOSE);
				}
			}
			
			return ret;			
		}
		//------------------------------------------------------
		private function FormatHeader(host:String):String
		{
			return(ZG_StringUtils.Sprintf(STR_HEADER,host));
		}
		//--------------------------
		// Still getting occasional false positives finding a host whose name or IP is similar to others..
		private function FindHost(curString:String,host:String):int
		{
			var ret:int = curString.indexOf(host);
			if(ret >=0)
			{
				var potentialHost:String =curString.substr(ret,host.length);
				if(potentialHost == host)
				{
					// rely on the fact that the host is in quotes. the next character after host length should be a quote. if it is not - 
					// it's not the right host but similar, i.e. 10.1.1.10 when we're looking for 10.1.1.1
					var lastChar:String = curString.substr(ret+host.length,1);
					if(lastChar != "'")
					{
						trace("TextOutputFormatter:False positive for host " + host);
						ret = -1;
					}
					
				}
				else
				{
					ret = -1;
				}
			}
			return ret;
		}
		/*//------------------------------------------------------
		public function get isTask():Boolean
		{
			return _isTask;
		}
		//------------------------------------------------------
		public function set isTask(value:Boolean):void
		{
			_isTask = value;
		}*/
		//------------------------------------------------------
		public function get name():String
		{
			return _name;
		}
		//------------------------------------------------------
		public function set name(value:String):void
		{
			_name = value;
		}
	
		
	}
}
