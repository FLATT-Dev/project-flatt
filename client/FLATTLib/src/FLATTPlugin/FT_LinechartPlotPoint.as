/*******************************************************************************
 * FT_LinechartPlotPoint.as
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
	// an object representing line chart plot point.
	// an array of such objects is given to the line chart as
	// data provider
	
	public class FT_LinechartPlotPoint
	{
		private var _yField:String = "";
		private var _xField:String = "";;
		
		//--------------------------------
		public function FT_LinechartPlotPoint()
		{
		}
		//--------------------------------
		public function get yField():String
		{
			return _yField;
		}
		//--------------------------------
		public function set yField(value:String):void
		{
			_yField = value;
		}
		//--------------------------------
		public function get xField():String
		{
			return _xField;
		}
		//--------------------------------
		public function set xField(value:String):void
		{
			_xField = value;
		}
		//--------------------------------

	}
}
