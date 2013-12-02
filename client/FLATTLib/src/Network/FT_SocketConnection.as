/*******************************************************************************
 * FT_SocketConnection.as
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
	import Application.*;
	
	import com.ZG.Logging.*;
	import com.ZG.Utility.*;
	
	import flash.events.*;
	import flash.net.Socket;
	import flash.utils.*;
	import flash.utils.ByteArray;
	
	public class FT_SocketConnection extends FT_Connection
	{
		// Secure conn4ection uses SSL 
		// TODO: Per Adobe, SSL sockets are not supported]
		// on mobile devices.. 
		protected  var _isSecure:Boolean = false;
		protected var _socket:Object;
		
		
		/*TODO:Delete
		private var _savedData:ByteArray = null;
		private var _curData:ByteArray = null;
		private var _curChunk:int = 0;
		private var _offset:int = 0;*/
		//======================================
		public function FT_SocketConnection()
		{
			super();
			Init();
		}
		//===========================================
		override protected function Init():void
		{
			if(_socket == null)
			{
				_socket = new Socket();				
			}
		}
		public function get isSecure():Boolean
		{
			return _isSecure;
		}
		//---------------------------------------------
		public function set isSecure(value:Boolean):void
		{
			_isSecure = value;
		}
		//---------------------------------------------
		override public function Connect():Boolean
		{
			
			var ret:Boolean = true;
			try
			{
				var port:int = FT_Application.GetInstance().GetlocalProxyPort();
				if(port == FT_Application.INVALID_PORT )
				{
					throw  new Error("Invalid proxy port!");
				}
				ZG_AppLog.GetInstance().LogIt("Connecting  to host " +
												FT_Application.GetInstance().sshProxyHost +
												" port " + port);
												
				
				// socket can be null if user canceled the connection from UI
				Init();
				_socket.connect(FT_Application.GetInstance().sshProxyHost,port);					
				
			}
			catch(e:Error)
			{
				errMessage = e.message;
				//TODO: maybe dispatch event to ui or to object that is using this ?
				ZG_AppLog.GetInstance().LogIt("Failed to connect: " + errMessage,ZG_AppLog.LOG_ERR);
				
				ret = false;
												
			}
			return ret;
		}
		//---------------------------------------------
		override public function Disconnect():void
		{
			if( _socket !=null && _socket.connected )
			{
				_socket.flush();
				_socket.close();
				_socket = null;
			}
		}
		//---------------------------------------------
		override public function Read():String
		{
			var bytes:ByteArray = new  ByteArray();
			_socket.readBytes(bytes);
			return (String(bytes));
		}
		//---------------------------------------------
		override public function WriteByteArray(data:ByteArray):void
		{
			_socket.writeBytes(data);
			_socket.flush();
		}
		/*override public function WriteByteArray(data:ByteArray):void
		{
			if(data.length < 16384)
			{
				_socket.writeBytes(data);
				_socket.flush();
				
			}
			else
			{
				
				_savedData = data;
				_savedData.position = 0;
				var timer:Timer = new Timer(3000);// 3 sec , repeat once
				timer.addEventListener(TimerEvent.TIMER, OnSendDataTimerEvent,false,0, true);
				timer.start()
				
			}
			
			
		}
		//--------------------------
		protected function OnSendDataTimerEvent(event:TimerEvent):void
		{
			//var len:int =0;
			
			if(_curData == null)
			{
				_curData = new ByteArray();
			}
			_curData.clear();
			
			if(_savedData.position < _savedData.length)
			{
				_curChunk = Math.min(_savedData.length-_savedData.position,8192);
				_curData.writeBytes(_savedData, _savedData.position, _curChunk);
				_curData.position = 0;
				_socket.writeBytes(_curData);
				_socket.flush();
				_savedData.position+=_curChunk;				
			}
			else
			{
				var timer:Timer = event.currentTarget as Timer;
				if(timer!=null)
				{
					timer.stop();
				}
				_curData.clear();
				_curData = null;
				_savedData.clear();
				_savedData = null;
			}			
		}*/
		//---------------------------------------------
		override public function WriteUTFString(data:String):void
		{
			_socket.writeUTFBytes(data);
			_socket.flush();
			
			ZG_AppLog.GetInstance().LogIt("Sending data to host:\n " + data +"******");				
		}
		//---------------------------------------------
		override public function ConfigureListeners(connectHandler:Function,								   
										   dataHandler:Function,
										   closeHandler:Function,
										   ioErrorHandler:Function,
										   progressHandler:Function,
										   securityErrorHandler:Function):void
			
		{
			_socket.addEventListener(Event.CONNECT, connectHandler);			
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			_socket.addEventListener(Event.CLOSE, closeHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_socket.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler)
		}
		//---------------------------------------------
		override public function LoginAndExecute( data:String /*targetHost:String,
													username:String,
													password:String,
													command:String,
													isRealTime:Boolean*/):void
		{
			// Make sure to add a newline char so the server readLine loop terminates!!!
			SendByteArray(data+ "\n");
			
			
			
			// for socket connection let's wrap data in an XML
			
			
			/*var xml:XML = new XML(<SSHRequest></SSHRequest>);
			
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
			// Make sure to add a newline char so the server readLine loop terminates
			
			//var ba:ByteArray = new ByteArray();					
			//ba.writeUTFBytes(xml.toXMLString() + "\n");
			//WriteByteArray(ba);	
			SendByteArray(xml.toXMLString() + "\n");*/
			/*SendByteArray(BuildProxyRequest(targetHost,
											username,
											password,
											command,
											isRealTime))*/;
		}
		
		//---------------------------------------------
		// Send this to host so it quits when the app quits
		override public function QuitProxy():void
		{
			ZG_AppLog.GetInstance().LogIt("Sending quit request to internal proxy");
			
			var xml:XML = new XML(<SSHRequest></SSHRequest>);
			xml.appendChild(<quit></quit>);
			SendByteArray(xml.toXMLString() + "\n");
		}
		
			
		//---------------------------------------------
		//---------------------------------------------
		//---------------------------------------------

	}
}
