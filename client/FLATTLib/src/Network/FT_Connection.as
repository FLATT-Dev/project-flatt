/*******************************************************************************
 * FT_Connection.as
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
package Network
{
	import TargetHostManagement.*;
	
	import com.ZG.Events.ZG_EventDispatcher;
	import com.ZG.Utility.*;
	
	import flash.events.*;
	import flash.utils.*;
	
	//Base connection class. 
	// Possible subclasses: 
	// SocketConnection
	//SecureSocketConnection
	//NativeProcessConnection
	public class FT_Connection extends ZG_EventDispatcher
	{
		
		private var _errMessage:String = "";
		protected var _hostScanParams:FT_HostScanParams;
		//protected var _useLocalConnection:Boolean; 
		
		public function FT_Connection()
		{
			super(null);
		}
		//===========================================
		public  function Connect():Boolean
		{
			return true;
		}
		//---------------------------------------------
		public  function Disconnect():void
		{
			
		}
		
		//-------------------------------------------------
		// connection specific initialization
		protected function Init():void
		{
			
		}
		//---------------------------------------------
		public  function Read():String
		{
			return "";
		}
		//Configure listeners for this connection
		
		
		public function ConfigureListeners(connectHandler:Function,								   
										   dataHandler:Function,
										   closeHandler:Function,
										   ioErrorHandler:Function,
										   progressHandler:Function,
										   securityErrorHandler:Function):void
		
		{
			addEventListener(Event.CONNECT, connectHandler);			
			addEventListener(DataEvent.DATA, dataHandler);
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(ProgressEvent.PROGRESS, progressHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler)
		}
		
		public  function WriteByteArray(data:ByteArray):void
		{
			
		}
		public  function WriteUTFString(data:String):void
		{
			
		}
		// Login ssh host and execut the command athentication credentials to the host
		// Optionally also sends data. 
		// 
		public function LoginAndExecute(data:String/*targetHost:String,
										username:String,
										password:String,
										command:String,
										isRealTime:Boolean*/):void
		{
			
		}
		
		//------------------------------------------------------------------------
		// For convenience
		public function SendByteArray(data:String):void
		{
			var ba:ByteArray = new ByteArray();					
			ba.writeUTFBytes(data);
			WriteByteArray(ba);			
		}
		//-----------------------------------------------------------------
		public function QuitProxy():void
		{
			
		}
		//---------------------------------------------
		public function get errMessage():String
		{
			return _errMessage;
		}

		public function set errMessage(value:String):void
		{
			_errMessage = value;
		}
		//------------------------------------------
		/* common fucnction to build a request for the other end of connection
			Subclasses override if needed
	    */
		/*public function BuildProxyRequest(targetHost:String,
										username:String,
										password:String,
										command:String,
										isRealTime:Boolean):String
		{
			var xml:XML = new XML(<SSHRequest></SSHRequest>);
			
			xml.appendChild(<host>{targetHost}</host>);
			xml.appendChild(<username>{username}</username>);
			xml.appendChild(<password>{password}</password>);	
			// need to convert line endings to unix, otherwise script may fail
			xml.appendChild(<command>{ZG_StringUtils.Base64Encode(ZG_StringUtils.Dos2Unix(command))}</command>);
			xml.appendChild(<realtime>{isRealTime}</realtime>);
			
			// if it's a multiline command, need additional trickery
			// The a temp file will be created by the server
			// and copied to the host,  then executed. 
			// At the end of execution the file will be deleted
			
			
			if(command.indexOf("\r")>0 || command.indexOf("\n") >=0)
			{
				xml.appendChild(<needsScp>{"yes"}</needsScp>);
			}
			
			// if there are hostscanparams-add them to xml request
			if(_hostScanParams!=null)
			{
				_hostScanParams.AddToXML(xml);
			}
			return (xml.toXMLString() + "\n");			
		}*/
		//------------------------------------------
		public function get hostScanParams():FT_HostScanParams
		{
			return _hostScanParams;
		}
		//------------------------------------------
		public function set hostScanParams(value:FT_HostScanParams):void
		{
			_hostScanParams = value;
		}
		//--------------------------------
		// subclasses override
		public function SetConnectionTimeout(timeout:int):void
		{
			
		}
		//---------------------------------------------
		/*public function get useLocalConnection():Boolean
		{
			return _useLocalConnection;
		}
		//--------------------------------------------
		public function set useLocalConnection(value:Boolean):void
		{
			_useLocalConnection = value;
		}*/

		
	}	
}
