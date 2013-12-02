/*******************************************************************************
 * FT_PluginResultFactory.as
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
	
	public class FT_PluginResultFactory
	{
		public function FT_PluginResultFactory()
		{
		}
		
		public static function GetPluginResultObj(dataType:String ):FT_PluginResult
		{
			if( dataType  == FT_Strings.RTYPE_TABLE )
			{
				return new FT_TableResult();
			}
			else if( dataType == FT_Strings.RTYPE_LINECHART )
			{
				return new FT_LinechartResult();
			}
			else if (dataType == FT_Strings.RTYPE_COLUMNCHART )
			{
				return new FT_ColumnChartResult();
			}
			// return base class
			return new FT_PluginResult();
		}
	}
}
