/*******************************************************************************
 * FT_POSTConnection.as
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
	
	import flash.errors.IOError;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.*;
	
	public class FT_POSTConnection extends FT_Connection
	{
		//=================
		// This is a subclass of FT_COnnection and implements a m HTPP POST of client data
		// to a server
		private var _httpSvc:HTTPService = new HTTPService();
		
		private var _connHandler:Function;
		private var _dataHandler:Function;
		private var _closeHandler:Function;
		//private var _ioErrHandler:Function;
		private var _progressHandler:Function;
		private var _securityHandler:Function;
		private var _data:String = "";
		
		
		public function FT_POSTConnection()
		{
			super();
		}
		
		//----------------------------------------
		override public function ConfigureListeners(connectHandler:Function,								   
													dataHandler:Function,
													closeHandler:Function,
													ioErrorHandler:Function,
													progressHandler:Function,
													securityErrorHandler:Function):void
			
		{
			
			
			
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(ProgressEvent.SOCKET_DATA,dataHandler);
			_httpSvc.addEventListener( ResultEvent.RESULT, LocalCompleteHandler );
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(ProgressEvent.PROGRESS, progressHandler);	
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_httpSvc.addEventListener( FaultEvent.FAULT, LocalErrHandler );
			/*
						
			_httpSvc.addEventListener(Event.CONNECT, connectHandler);
			// we will have to send data event ourselves
			addEventListener(ProgressEvent.SOCKET_DATA,dataHandler);
			_httpSvc.addEventListener(Event.COMPLETE,LocalCompleteHandler);	
			_httpSvc.addEventListener(Event.CLOSE, closeHandler);
			_httpSvc.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_httpSvc.addEventListener(ProgressEvent.PROGRESS, progressHandler);			
			_httpSvc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			*/
			
			//Now save all handlers so that they can be removed if user cancels.
			_connHandler = connectHandler;
			_dataHandler = dataHandler;
			_closeHandler = closeHandler;
			//_ioErrHandler = ioErrorHandler;
			_progressHandler = progressHandler;
			_securityHandler = securityErrorHandler;
		}
		
		//-------------------------------------------------------
		override public function Read():String
		{
			/*var ret:String = "";
			if(_httpSvc!= null)
			{				
				ret = _httpSvc.redata as String;
			}
			return ret;	*/
			return _data;
		}
		//----------------------------------------
		override public function Connect():Boolean
		{
			// TODO: Verify URL here	
			// timer is needed so that UI messages are displayed in proper order
			var connectTimer:Timer = new Timer(1000);	
			connectTimer.addEventListener(TimerEvent.TIMER, OnConnectTimer,false,0, true);
			connectTimer.start();
			return true;
		}
		//----------------------------------
		// Do a post to flatt proxy to get the data
		override public function LoginAndExecute( data:String/*targetHost:String,
												  username:String,
												  password:String,
												  command:String,
												  isRealTime:Boolean*/):void
		{
		
		
			// specify the url to request, the method and result format
			_httpSvc.url = FT_Prefs.GetInstance().GetProxyUrl();
			_httpSvc.method = "POST";
			_httpSvc.resultFormat = "text";
			_httpSvc.contentType= "multipart/form-data";
			_httpSvc.requestTimeout = -1; // no timeout]
			//_httpSvc.send(BuildProxyRequest(targetHost,username,password,command,false));
			// realTime flag must be set t o false by the caller 
			_httpSvc.send(data);
														/*post connection cannot be realtime isRealTime));*/
				
				
				
				
			
			
			/*
			_httpSvc.dataFormat = URLLoaderDataFormat.TEXT;
			_httpSvc.data = BuildProxyRequest(targetHost,
												username,
												password,
												command,
												isRealTime);
			
			
			//"http://ec2-174-129-190-186.compute-1.amazonaws.com/FlattServer/execproxy";
			//"http://localhost:8080/FlattServer/execproxy";
			var servletUrl:String = FT_Prefs.GetInstance().GetProxyUrl();
			var request:URLRequest = new URLRequest(servletUrl);
			request.method = URLRequestMethod.POST
			request.contentType = "multipart/form-data";
			request.data = _httpSvc.data;
			//request.requestHeaders = new Array(new URLRequestHeader("toto", "toto"));
			
			_httpSvc.load(request);*/
			
		}
		//-----------------------------------
		
		protected function LocalCompleteHandler(e:ResultEvent):void
		{
			// at this point data has been loaded
			// NOtify the caller to read data
			_data = e.result as String;
			dispatchEvent(new ProgressEvent(ProgressEvent.SOCKET_DATA));
			// also dispatch "close" event to start data parsing 
			dispatchEvent(new Event(Event.CLOSE));
			RemoveListeners();
		}
		//-----------------------------
		
		private function OnConnectTimer(e:TimerEvent):void
		{
			var timer:Timer = e.target as Timer;
			if(timer !=null)
			{
				timer.stop();
			}
			dispatchEvent(new Event(Event.CONNECT));
			/*if(_httpSvc!=null)
			{
				_httpSvc.dispatchEvent(new Event(Event.CONNECT));
			}*/
		}
		//------------------------------------------
		override public  function Disconnect():void
		{
			
			if (_httpSvc!=null)
			{		
				// throws error if stream is not opened
				try
				{
					_httpSvc.cancel();
					_httpSvc.disconnect();
				}
				catch( e:Error)
				{
					trace("exception thrown closing url loader");
				}
				RemoveListeners();
				_httpSvc = null;
				
			}
		}
		//---------------------------
		// Remove all listeners from loader object.
		// we dont want it to fire events or hold on to memory when we're done
		private function RemoveListeners():void
		{
			// clean up after complete or disconnect			
			removeEventListener(Event.CONNECT, _connHandler);
			removeEventListener(Event.COMPLETE,_dataHandler);
			_httpSvc.removeEventListener(ResultEvent.RESULT,LocalCompleteHandler);	
			removeEventListener(Event.CLOSE, _closeHandler);
			_httpSvc.removeEventListener(FaultEvent.FAULT, LocalErrHandler);
			removeEventListener(ProgressEvent.PROGRESS, _progressHandler);			
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityHandler);
					
		}
		//-----------------------------------
		private function LocalErrHandler(e:FaultEvent):void
		{
			// remap fault event
			var errEv:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			errEv.text="Status:  " + e.statusCode + " Description: " 	+  e.fault.faultString;
			dispatchEvent(errEv);
		}
	}
	
}
