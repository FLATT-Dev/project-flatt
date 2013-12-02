/*******************************************************************************
 * FT_HostScannerExec.as
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
	import Application.*;
	
	import FLATTPlugin.*;
	import Exec.*;
	import Network.*;
	import Network.FT_Connection;
	
	import TargetHostManagement.FT_TargetHost;
	
	import Utility.*;
	import Utility.FT_Events;
	
	import com.ZG.Events.ZG_EventDispatcher;
	import com.ZG.Logging.*;
	import com.ZG.Utility.*;
	
	import flash.events.*;
	

	public class FT_HostScannerExec extends FT_PluginExec
	{
		public function FT_HostScannerExec(plugin:FT_Plugin)
		{
			super(plugin);
		}		
		//---------------------------------------
		override protected function UIFeedback(message:String):void
		{
			curMessage = ZG_Utils.TranslateString(message);
			DispatchEvent(FT_Events.FT_EVT_HOST_SCAN,this);
		} 
		
		//-------------------------
		// On connect - login ssh and execute the command
		// called by execrequest object. msg is unused
		override public function OnConnect(msg:String):void
		{
			state = STATE_EXECUTING;
			//TODO
			
			//_connection.hostScanParams = new FT_HostScanParams();
			//_connection.LoginAndExecute("","","","",false); // can receive data 	
			//_connection.LoginAndExecute("");
			UIFeedback("Starting host scan..");			
		}
		
		//----------------------------
		override public function OnClose():void
		{
			// connection closed - send event to UI
			trace("FT_HostScannerExec:OnClose ");
			_state = STATE_DONE;
			UIFeedback("Host scan completed:  "+ _execResult);
			
		}
		//----------------------------
		override protected function Validate():Boolean
		{
			return true;
		}
		//---------------------------------
		// only need to set result for this object
		override protected  function SetExecResult(outData:String, status:String):void
		{			
			_execResult = status;			
			//trace("FT_HostScannerExec:ParseReturnData,status:"+ _execResult + "\noutData:\n" + outData);
		}
	}
}
