/*******************************************************************************
 * FT_SSLConnection.as
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
	
	import com.ZG.Utility.*;
	import com.hurlant.crypto.cert.*;
	import com.hurlant.crypto.tls.*;
	import com.hurlant.util.der.PEM;
	
	import flash.utils.*;
	import flash.events.*;
	import flash.utils.ByteArray;
	
	
	public class FT_SSLConnection extends FT_SocketConnection
	{
		
		/*TODO: delete 
		private var _savedData:ByteArray = null;
		private var _curData:ByteArray = null;
		private var _curChunk:int = 0;
		private var _offset:int = 0;*/
		
		
		public function FT_SSLConnection()
		{
			super();
			Init();			
		}
		//-------------------------------------------
		override protected function Init():void
		{
			if(_socket == null)
			{
				// socket is a regular socket - need to create a TLS socket here			
				_socket = new TLSSocket();
				_socket.ignoreHostIdentity = (FT_Prefs.GetInstance().GetCheckHostIdentity()==false); 
			}
		}
		
		//---------------------------------------------
		override public function Connect():Boolean
		{
			
			var ret:Boolean = true;
			try
			{
				//TODO: get port from host
				// get cert from prefs
				var port:int=FT_Prefs.GetInstance().GetProxyPort();
				var cert:String = FT_Prefs.GetInstance().GetProxyCert();
				var addr:String = FT_Prefs.GetInstance().GetProxyAddress();
				
				if( port > 0 && 
					ZG_StringUtils.IsValidString(cert) && 
					ZG_StringUtils.IsValidString(addr))
				{								
					// prepare CA store and set the certifcate we got from user
					// TODO: Propagate expired certificate error to UI
					var config:TLSConfig = new TLSConfig(TLSEngine.CLIENT);
					config.CAStore = new X509CertificateCollection();
					var x509:X509Certificate = new X509Certificate(PEM.readCertIntoArray(cert));
					config.CAStore.addCertificate(x509);
				
					_socket.connect(addr,port,config);
				}
				else
				{
					throw (new Error("Invalid host, port or certificate"));
				}									
			}
			catch(e:Error)
			{
				errMessage = e.message;
				//TODO: maybe dispatch event to ui or to object that is using this ?
				trace("Failed to connect: " + errMessage);
				
				ret = false;
				
			}
			return ret;
		}
		//-------------------------------------------------------
		// TODO: delete, now working in TLSEngine.as
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
		
		
	}// class

	
	
	

}
