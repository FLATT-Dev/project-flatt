/*******************************************************************************
 * FT_ColumnChartResult.as
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
	import Exec.FT_PluginExec;

	public class FT_ColumnChartResult extends FT_PluginResult
	{
		import com.ZG.Utility.*;
		//-----------------------------------
		private var _columnNames:Array = new Array();
		public function FT_ColumnChartResult()
		{
			super();
		}
		//------------------------------------
		private var _tmpData1:String = "linux1=Partition:255;Ram:335\nlinux2=Part:55;Ram:44\n";
		private var _tmpData2:String ="[Ram,HD]\rlinux1:500,300\rlinux2:700,400\r linux3:1024,800\r"
		
		override public function GetData(params:Object = null):Object
		{
			var ret:Array = new Array();
		
			if(this.execObj.execResult == FT_PluginExec.EXEC_RESULT_OK)
			{				
				// break data into lines.
				// first line is column names
				var lines:Array = super.GetData().split("\n");
				
				for(var i:int = 0; i < lines.length;++i)
				{
					if(i == 0 )
					{
						ParseColumnNames(lines[i]);
					}
					else
					{
						var barObj:Object = ParseBarObject(lines[i]);
						if(barObj!=null)
						{
							ret.push(barObj);
						}
					}
				}				
			}
			return (Validate(ret) ? ret : null );
		}
		//------------------------------------		
		override protected function Validate(data:Object):Boolean
		{
			var arr:Array =  data as Array;
			return (arr!=null && arr.length > 0);
		}
		//------------------------------------
		// column names line is in this form
		//[col name1,col name2...]
		private function ParseColumnNames(src:String):void
		{
			var strippedStr:String = src.substring(src.indexOf("[")+1,src.indexOf("]"));
			if(strippedStr!=null && strippedStr.length > 0 )
			{
				_columnNames = strippedStr.split(",");
			}
		
		}
		//------------------------------------
		// each bbar in the chart has its "categoryField" property set to the name of the object
		// [Ram,HD]\rlinux1:500,300\rlinux2:700,400\r linux3:1024,800\r"
		private function ParseBarObject(src:String):Object
		{
			var ret:Object = null;
			
			var categoryField:String = src.substring(0,src.indexOf(":"));
			if( categoryField!=null && categoryField.length > 0 )
			{
				ret = new Object();
				// TODO: figure out where to put host name!
				ret.categoryField = categoryField; // + "\n("+ execObj.targetHost +")";
				var valuesString:String = src.substring(src.indexOf(":")+1);
				var values:Array = valuesString.split(",");
				// now iterate through column names and create properties of the object
				if(values.length == _columnNames.length)
				{
					for(var i:int = 0; i < _columnNames.length;++i)
					{
						ret[_columnNames[i]] = ZG_StringUtils.CleanupSpaces(values[i]);
					}
				}
				else
				{
					ret = null;
				}
			}
			return ret;							
		}
		//------------------------------------
		public function get columnNames():Array
		{
			return _columnNames;
		}
		//------------------------------------
		public function set columnNames(value:Array):void
		{
			_columnNames = value;
		}

	}
}
