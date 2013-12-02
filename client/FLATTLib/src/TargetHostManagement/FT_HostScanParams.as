/*******************************************************************************
 * FT_HostScanParams.as
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
package TargetHostManagement
{
	public class FT_HostScanParams
	{
		
		import Application.*;
		
		private var _startIP:String = "0";
		private var _endIP:String = "0";
		private var _scanConnectTimeout:int = 5; // is 5 seconds enough?
		
		public function FT_HostScanParams()
		{
			// TODO: read from prefs
			// if no prefs - the 0 address signals to use the addressof the box where the proxy is running
			_startIP = FT_Prefs.GetInstance().GetHostScanStartIP();
			_endIP = FT_Prefs.GetInstance().GetHostScanEndIP();
			// TODO: timeout is not exposed.
		}
		//-----------------------------------------
		public function get startIP():String
		{
			return _startIP;
		}
		//-----------------------------------------
		public function set startIP(value:String):void
		{
			_startIP = value;
		}
		//-----------------------------------------
		public function get endIP():String
		{
			return _endIP;
		}
		//-----------------------------------------
		public function set endIP(value:String):void
		{
			_endIP = value;
		}

		public function get scanConnectTimeout():int
		{
			return _scanConnectTimeout;
		}
		//-----------------------------------------
		public function set scanConnectTimeout(value:int):void
		{
			_scanConnectTimeout = value;
		}
		//------------------------------------------------
		//Assumes that the block does not exist
		public function AddToXML(inXml:XML):void
		{
			var scanParamsXml:XML = new XML(<HostScanParams></HostScanParams>);
			scanParamsXml.appendChild(<startIP>{_startIP}</startIP>); 
			scanParamsXml.appendChild(<endIP>{_endIP}</endIP>); 
			scanParamsXml.appendChild(<scanConnectTimeout>{_scanConnectTimeout}</scanConnectTimeout>); 
			inXml.appendChild(scanParamsXml);
		}


	}
}
