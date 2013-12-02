/*******************************************************************************
 * FT_ProxyQuitter.as
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
	import Application.*;
	
	import Network.*;
	import Network.FT_Connection;
	
	import Utility.FT_Events;
	
	import com.ZG.Events.ZG_EventDispatcher;
	import com.ZG.Logging.*;
	
	import flash.desktop.*;
	import flash.events.*;
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	
	public class FT_ProxyQuitter extends ZG_EventDispatcher
	{
		private var _connection:FT_Connection;
		private var _completed:Boolean;
		private var _quitApp:Boolean;
	
		
		public function FT_ProxyQuitter(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		//Kicks off executing of the command
		public function QuitProxy():void
		{			
			// if proxy is not running- time out in 10 seconds
			var quitTimer:Timer = new Timer(10000);			
			quitTimer.repeatCount = 1;	
			quitTimer.addEventListener(TimerEvent.TIMER, OnQuitTimerEvent,false,0, true);
			quitTimer.start();
			
			_connection = new FT_SocketConnection(); //This should always be a local socket connection FT_ConnectionFactory.GetConnection();
			_connection.ConfigureListeners(OnConnect,OnData,OnClose,OnIoErr,OnProgress,OnSecurityErr);
			_connection.Connect();
			
		}
		
		//-------------------------
		// On connect - login ssh and execute the command
		private function OnConnect(event:Event):void
		{
			_connection.QuitProxy();			
		}
		//----------------------------
		private function OnData(event:ProgressEvent):void
		{			
			
			//TODO: if realtime-parse data and send message to UI	
		}
		//----------------------------
		private function OnClose(event:Event):void
		{			
			trace("FT_ProxyQuitter:OnClose ");	
			// TODO: send event to app
			if(quitApp)
			{
				FT_Application.GetInstance().QuitApp();
			}
			
		}
		//------------------------------------------------
		private function OnIoErr(event:IOErrorEvent):void
		{
			trace("FT_ProxyQuitter:OnIoErr "+event.text);			
		}
		//------------------------------------------------
		private function OnProgress(event:ProgressEvent):void
		{
			trace("FT_ProxyQuitter:OnProgress ");
		}
		//------------------------------------------------
		private function OnSecurityErr(event:SecurityErrorEvent):void
		{
			trace("FT_ProxyQuitter:OnSecurityErr "+event.text);			
		}
		//------------------------------------------------
		public function get completed():Boolean
		{
			return _completed;
		}
		//------------------------------------------------
		public function set completed(value:Boolean):void
		{
			_completed = value;
		}
		//----------------------------------------------------
		private function OnQuitTimerEvent(e:TimerEvent):void
		{
			//FT_Application.GetInstance().QuitApp();
			OnClose(null);
		}
		//----------------------------------------------------
		public function get quitApp():Boolean
		{
			return _quitApp;
		}
		//----------------------------------------------------
		public function set quitApp(value:Boolean):void
		{
			_quitApp = value;
		}


	}
}
