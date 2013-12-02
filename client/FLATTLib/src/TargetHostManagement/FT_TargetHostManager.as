/*******************************************************************************
 * FT_TargetHostManager.as
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
	import FLATTPlugin.*;
	import Exec.*;
	
	import Utility.*;
	
	import com.ZG.Events.*;
	import com.ZG.Logging.*;
	import com.ZG.Utility.*;
	
	import flash.events.IEventDispatcher;
	
	// this class handles various host management tasks
	// For now it just parses a csv file 
	
	public class FT_TargetHostManager extends ZG_EventDispatcher
	{
		private static var s_Instance:FT_TargetHostManager;
		private var _hostScanRunning:Boolean;
		private var _scannedHostsGrp:FT_TargetHost = null;
		//private var _scannerExec:FT_HostScannerExec;
		private var _execRequest:FT_ExecRequest;
		//====================================================
		public function FT_TargetHostManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		//-----------------------------------------------
		public static function GetInstance():FT_TargetHostManager
		{
			if(s_Instance == null )
			{
				s_Instance = new FT_TargetHostManager();
			}
			return s_Instance;
		}
		//-----------------------------------------------
		public function HandleHostImport(fileData:ZG_FileData):void
		{	
			//set up a new group - do we need logging here? or only on errors?
			var newGroup:FT_TargetHost = new FT_TargetHost();
			newGroup.name = fileData.fileName;
			newGroup.isContainer = true;
			var arr:Array = fileData.data.split("\n");
			
			for( var i:int = 0 ; i < arr.length;++i)
			{
				var newHost:FT_TargetHost = FT_TargetHost.ParseHost(arr[i]);
				if(newHost!=null)
				{
					newGroup.AddChild(newHost);	
				}
			}
			this.DispatchEvent(FT_Events.FT_EVT_HOST_IMPORT_COMPLETE,newGroup);
		}			
		//--------------------------------------------------
		public function RunHostScan():void
		{
			if(!_hostScanRunning)
			{
				_hostScanRunning = true;
				_scannedHostsGrp = null; // clear
				_execRequest = null;
				_execRequest = new FT_ExecRequest();	
				var scannerExec:FT_HostScannerExec =  _execRequest.PrepareRequest(null,
																				 null,
																				 FT_ExecRequest.REQTYPE_HOST_SCAN) as FT_HostScannerExec;																
																				
					scannerExec.addEventListener(FT_Events.FT_EVT_HOST_SCAN,OnHostScanEvent);
				//_scannerExec.Run();
				//_scannerExec.ExecStart();
			}
		}
		//-------------------------------------------------
		private function OnHostScanEvent(evt:ZG_Event):void
		{
			var scanner:FT_HostScannerExec = evt.data as FT_HostScannerExec;
			if(scanner !=null)
			{				
				_hostScanRunning = scanner.execInProgress;
				switch(scanner.state)
				{
					case FT_PluginExec.STATE_CONNECTING:
					case FT_PluginExec.STATE_EXECUTING:
						DispatchEvent(FT_Events.FT_EVT_HOST_SCAN_START);
						break;
					case FT_PluginExec.STATE_DONE:
					case FT_PluginExec.STATE_USER_CANCELED:
						DispatchEvent(FT_Events.FT_EVT_HOST_SCAN_DONE);
						break;
					case FT_PluginExec.STATE_RECEIVING_DATA:
						ProcessHostScanData(scanner);
						break;
				}
			
			}
		}
		//------------------------------
		// parse the data from proxy and call UI to add hosts
		private function ProcessHostScanData(scanner:FT_HostScannerExec):void
		{
			if(_scannedHostsGrp == null)
			{
				_scannedHostsGrp = new FT_TargetHost();
				_scannedHostsGrp.name = "Scanned hosts"; // TODO: get the range from prefs. If range is 0 -
				// return "Scanned Hostst" or something.
				_scannedHostsGrp.isContainer = true;			
			}
			//// TODO: license check! before adding 
			// return data is popped off the queue on access, so it can be
			// obtained only once!
			var hostAddr:String = scanner.returnData;
			if(hostAddr!=null && hostAddr.length >0)
			{
				var newHost:FT_TargetHost = new FT_TargetHost();
				newHost.host = hostAddr;
				_scannedHostsGrp.AddChild(newHost);
				DispatchEvent(FT_Events.FT_EVT_HOST_SCAN_DATA,_scannedHostsGrp);
			}
		}
		//-------------------------------------------
		public function CancelScan():Boolean
		{
			
			if(_execRequest!=null && _execRequest.ExecInProgress())
			{
				_execRequest.HandleUserCanceled();
				return true;
			}
			return false;
		}
		
		
	}
	
}
