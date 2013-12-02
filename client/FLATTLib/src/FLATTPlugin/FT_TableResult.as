/*******************************************************************************
 * FT_TableResult.as
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
	import com.ZG.Logging.*;
	import com.ZG.Utility.*;
	
	import mx.collections.XMLListCollection;

	
	
	// handles table data that is returned by plugin
	public class FT_TableResult extends FT_PluginResult
	{
		private var _xmlString:String = "";
		
		public function FT_TableResult()
		{
			super();
		}				
		// build an xml from table data received from host.
		// also return column names ( first row is always column names)
		// if we're appending data - column names are passed in
		// TABLE HANDLING
		// XXX! It is very sensitive to separator characters in the data stream!
		//Spent 2 days chasing my tail when separator char was a colon and the proxy server
		// was returning "Failed to connect to host:"
		//
		override public function GetData(params:Object = null):Object
		{
			var colNames:Array = params as Array;
			var data:String = ZG_StringUtils.Unix2Dos(super.GetData(params) as String);
			var dataSeparatorType :String = pluginObj.returnDataInfo.dataSeparatorType;
			var dataSeparatorVal:String =   pluginObj.returnDataInfo.dataSeparatorValue;
			
			
			_xmlString = "<TableData>";
			// TODO: Handle illegal XML chars < and &
			// we're stuck with XML as there is no 
			// way to create an object with variable number of 
			// columns
			// split it into rows
			
			
			
			var dataArr:Array = data.split("\r");
			for ( var i: int = 0; i < dataArr.length;++i)
			{
				// populate column names only if 
				//not appending data.
				//var curRowArray:Array = dataArr[i].split( dataSeparatorVal);
				var curRowString:String = dataArr[i]
				
				if(i == 0 && !appendData || (colNames.length==0))
				{
					// Results may come out of order. Dont rely on the "appendData" flag
					// instead make sure the column names aare populated
					PopulateColumnNames(colNames,null/*curRowArray*/);
				}
				
				if(i == 0 )
				{
					// Insert a special row that displays host name
					PrepareHostRow(colNames);
				}
				var curRowArr:Array = ArrayFromRowData(curRowString,dataSeparatorVal);
				if(curRowArr.length > 0 )
				{
					AddTableDataRow(xml,curRowArr,colNames);	
				}
				
			}
			var xml:XML  = null;			
			
			_xmlString +="</TableData>";
			// now try to make an xml object
			try
			{
				xml = new XML(_xmlString);
			}
			catch(e:Error )
			{
				xml = null;
				trace ("Exception creating table data XML : "+ e.message);
				ZG_AppLog.GetInstance().LogIt("Exception creating Table XML : "+ e.message,ZG_AppLog.LOG_ERR);
			}
			
			if( xml !=null)
			{
				//ZG_AppLog.GetInstance().LogIt("Table XML : "+ xml.toXMLString(),ZG_AppLog.LOG_INFO);
				//trace("Table XML : "+ xml.toXMLString());
			}
			
			return (new XMLListCollection((xml == null) ?  null : (xml.DataRow)));
		}
		//--------------------------------------
		// see if there are column names in the xml and if there are none, -add them
		// This is more reliable than relying on appendData flag
		// For now just look for Col# , when named column support is added - look for 
		// named columns
		private function ColumnNamesPopulated():Boolean
		{
			var ret:int = 0;
			
			for(var i:int = 0; i < pluginObj.returnDataInfo.numColumns;++i)
			{
				if(_xmlString.indexOf("Col#"+(i+1)) >=0)
				{
					ret++;
				}
			}
			return ret == (pluginObj.returnDataInfo.numColumns);
		}
		//---------------------------------------
		private function PopulateColumnNames(colNames:Array,dataArr:Array):void
		{
			
			var i: int;
			for(i= 0; i < pluginObj.returnDataInfo.numColumns;++i)
			{
				colNames.push("Col#"+(i+1));
			}
			
			var missingColumns:int = pluginObj.returnDataInfo.numColumns -i;			
			for( i =0; i < missingColumns;++i)
			{
				// hope this is sufficiently unique for a column name
				// TODO: revisi this
				colNames.push( new Date().time.toString());
			}
			
		}
		//--------------------------------------
		private function AddTableDataRow(xml:XML,dataArr:Array,colNames:Array):void
		{
			_xmlString+= "<DataRow>";
			
			for(var i:int = 0; i <colNames.length;++i)
			{
				var curXmlLine:String = "<"+colNames[i]+">";
				// if there are less values in data ( omitted) - put empty string
				var val:String = (i >= dataArr.length) ? "" : dataArr[i];
				
				curXmlLine += val +
					"</"+colNames[i]+">";
				_xmlString+=(curXmlLine);				
			}
			
			_xmlString+="</DataRow>";
			
		}
		//--------------------------------------
		// cleans up extra separators from array.
		// Array must consist of only values,without separators
		//used for spaces and tabs
		private function CleanupXtraSeparators(src:Array,separator:String):Array
		{
			var ret:Array = new Array();
			
			for( var i:int = 0; i < src.length;++i)
			{
				// skip separators as well as empty strings
				if(src[i]==separator || src[i] == "")
				{									
					continue;
				}								
				ret.push(src[i]);				
			}
			return ret;
		}
		
		//----------------------------------
		//walk the string and find separtators.
		private function ArrayFromRowData(strRow:String,separator:String):Array
		{
			var curString:String = "";
			var separatorCount:int = 0;
			var ret:Array = new Array();
			
			for( var i:int= 0; i < strRow.length;++i)
			{
				var curChar:String = strRow.charAt(i);
				if(curChar == separator)
				{
					// this is the first separator. 
					// add what we've accumulated to the return array and increment separator count
					if(separatorCount == 0)
					{
						ret.push(curString);
						curString = "";						
					}
					separatorCount++;
				}
				else
				{
					//add char to string
					curString+=curChar;
					separatorCount = 0;
				}
				
			}
			// last separator may not be present - add the last string if it's not empty
			if(curString!="")
			{
				ret.push(curString);
			}
			return ret;
		}
		//--------------------------------------------------------
		// Prepare a special row that displays the host name
		// Insert host name as an id of the first data row for a given host
		// so it's easy to find it and insert new data for it
		private function PrepareHostRow(colNames:Array):void
		{
			_xmlString+= "<DataRow host=" +"\""+execObj.targetHostObj.name+"\">";
		
			for(var i:int = 0; i <colNames.length;++i)
			{
				var curXmlLine:String = "<"+colNames[i]+">";
				// if there are less values in data ( omitted) - put empty string
				var val:String = (i == 0? ("Data from " + execObj.targetHostObj.name): "");				
				curXmlLine += val +
					"</"+colNames[i]+">";
				_xmlString+=(curXmlLine);				
			}
			
			_xmlString+="</DataRow>";
			
		}
	}
}
