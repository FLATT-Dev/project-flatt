package DesktopApp
{
	import Network.FT_Connection;
	import flash.events.*;
	import flash.desktop.*;
	import flash.utils.*;
	
	
	public class FT_NativeConnection extends FT_Connection
	{
		private var _nativeProcess:NativeProcess = new NativeProcess();
		
		public function FT_NativeConnection()
		{
			super();
		}
		
		//---------------------------------------------
		override public function Connect():void
		{
			
			/*try
			{
				ZG_AppLog.GetInstance().LogIt("Connecting  to host " +
					FT_Application.GetInstance().sshProxyHost +
					" port " +
					FT_Application.GetInstance().sshProxyPort);
				// TODO
				
			}
			catch(e:Error)
			{
				//TODO: maybe dispatch event to ui or to object that is using this ?
				ZG_AppLog.GetInstance().LogIt("Failed to connect",ZG_AppLog.LOG_ERR);
				
			}*/
		}
		//---------------------------------------------
		override public function Disconnect():void
		{
			_nativeProcess.closeInput();
		}
		//---------------------------------------------
		override public function Read():String
		{
			/*var bytes:ByteArray = new  ByteArray();
			_socket.readBytes(bytes);
			return (String(bytes));*/
			return null;
		}
		//---------------------------------------------
		override public function WriteByteArray(data:ByteArray):void
		{
		//	_socket.writeBytes(data);
		//	_socket.flush();
		}
		//---------------------------------------------
		override public function WriteUTFString(data:String):void
		{
			/*_socket.writeUTFBytes(data);
			_socket.flush();
			
			ZG_AppLog.GetInstance().LogIt("Sending data to host:\n " + data +"******");		*/		
		}
		//---------------------------------------------
		override public function ConfigureListeners(connectHandler:Function,								   
													dataHandler:Function,
													closeHandler:Function,
													ioErrorHandler:Function,
													progressHandler:Function,
													securityErrorHandler:Function):void
			
		{
			//_nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, dataHandler);
		//	_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, OnStdIOErr);
			
			/*_socket.addEventListener(Event.CONNECT, connectHandler);			
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			_socket.addEventListener(Event.CLOSE, closeHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_socket.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler)*/
			//TODO
		}
		//---------------------------------------------
		override public function LoginAndExecute( targetHost:String,
												  username:String,
												  password:String,
												  command:String,
												  isRealTime:Boolean):void
		{
			// for socket connection let's wrap data in an XML
			var xml:XML = new XML(<SSHRequest></SSHRequest>);
			
			/*xml.appendChild(<host>{targetHost}</host>);
			xml.appendChild(<username>{username}</username>);
			xml.appendChild(<password>{password}</password>);*/
			
			xml.appendChild(<host>{"ec2-50-17-83-185.compute-1.amazonaws.com"}</host>);
			xml.appendChild(<username>{"andym"}</username>);
			xml.appendChild(<password>{"h0ckey4ever"}</password>);
			
			xml.appendChild(<command>{command}</command>);
			xml.appendChild(<realtime>{isRealTime}</realtime>);
			
			
			// Make sure to add a newline char so the server readLine loop terminates
			this.WriteUTFString(xml.toXMLString() + "\n");
			
			
		}
	}
}