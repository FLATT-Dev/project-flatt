/*******************************************************************************
 * FT_LinechartResult.as
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
	import com.ZG.Utility.*;
	import Exec.FT_PluginExec;
	
	public class FT_LinechartResult extends FT_PluginResult
	{
		// linechart result data
		//private static var TEST_DATA:String = "1300044997=1.1,1300135042=4.4,1300145060=8.8,1310145024=2.2";
		public function FT_LinechartResult()
		{
			super();
		}
		//---------------------------------
		override public function GetData(params:Object = null):Object
		{			
			var ret:Array = null;
			if(this.execObj.execResult== FT_PluginExec.EXEC_RESULT_OK)
			{				
				ret = new Array();
				var dataArray:Array = super.GetData().split(",");
				for(var i:int =0; i < dataArray.length;++ i )
				{						
					if(dataArray[i]!="")
					{
						AddPlotPoint(ret,dataArray[i]);
					}
				}
			}
			return ret;
		}
		
		//---------------------------------
		private function AddPlotPoint(ret:Array, plotPoint:String):void
		{
			var pp:Array = plotPoint.split("=");
			if(pp.length >1 && pp[0]!="" && pp[1]!="")
			{
				var ppObj:FT_LinechartPlotPoint = new FT_LinechartPlotPoint();
				// unix epoch is in seconds - flash uses milliseconds
				//var date:Date = new Date(ZG_StringUtils.StringToNumEx(pp[0]) * 1000);
				// a unix date should be returned	
			
				ppObj.xField = pp[0];//date;
				ppObj.yField = pp[1];
				ret.push(ppObj);
			}
		}		
	}
}
