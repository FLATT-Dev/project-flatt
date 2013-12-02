/*******************************************************************************
 * FT_PluginExec.as
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
package Exec
{
	import Application.*;
	
	import Network.*;
	import Network.FT_Connection;
	
	import TargetHostManagement.FT_TargetHost;
	
	import Utility.*;
	import Utility.FT_Events;
	
	import com.ZG.Events.ZG_EventDispatcher;
	import com.ZG.Logging.*;
	import com.ZG.Utility.*;
	
	import flash.events.*;
	import flash.utils.*;
	import FLATTPlugin.FT_Plugin;
	import FLATTPlugin.FT_PluginResult;
	import FLATTPlugin.FT_ReturnDataFIFO;

	//This class handles execution of a plugin command
	
	public class FT_PluginExec extends ZG_EventDispatcher
	{
		
		public static const STATE_CONNECTING:String = "Connecting";
		public static const STATE_EXECUTING:String = "Executing";
		public static const STATE_DONE:String = 	"Completed";		
		public static const STATE_INITIAL:String = 	"Starting";
		public static const STATE_RECEIVING_DATA:String = "Receiving Data";
		public static const STATE_USER_CANCELED:String = "User canceled";
		
		public static const EXEC_RESULT_OK:String = "OK";
		public static const EXEC_RESULT_ERR:String = "Error";
		public static const EXEC_RESULT_WARN:String = "Warning";
		
		
		//TODO: pass the actial plugin
		
		private var _plugin:FT_Plugin; 						// the plugin we're executing		
		protected var _execResult:String = EXEC_RESULT_OK; //Execution result: OK or error string;
		//private var _returnData:String = ""; 			// data returned from exectuting plugin command
		private var _targetHostObj:FT_TargetHost = null; // will be set by creator of this object
		protected var _state:String = STATE_INITIAL;	// object is just created
		private var _appendData:Boolean; // pass through to plugin result which needs to know whether data is appended in  UI
		private var _curMessage:String;
		//private var _executingSiblings:Array = new Array(); //siblings of this object that are executing

		// the command we're executing. It belongs to the plugin and may change 
		//if a user runs through a wizard while this object is execyuting,so save it
		private var _cmd:String = "";
		//protected var _connection:FT_Connection;
		// when executing on a group of hosts
		//private var _initialHost:FT_TargetHost; // save the initial host-used on Rerun	
		private var _pluginResultObj:FT_PluginResult;
		// this is the return data queue. Elements are removed after they are displayed
		private var _returnDataFifo:FT_ReturnDataFIFO = new FT_ReturnDataFIFO();
		//private var _timer:Timer;
		private var _requestObj:FT_ExecRequest;
		
		// used only for tasks -the sequence number and the plugin name of plugin that just finished executing
		// 
		private var _finishedPluginIndex:int =0;
		private var _finishedPluginName:String = "";
		private var _taskName:String = "" ; // used only for task
		
		//=====================
		public function FT_PluginExec(plugin:FT_Plugin)
		{
			super();
			Reset(plugin);			
		}
		//------------------------------
		public function ExecStart(prevRes:String = null):Boolean
		{			
			return true;
		}		
		//-----------------------------------
		public function HandleConnecting(sendUIFeedback:Boolean):void
		{
		
			//_returnData = ""; // reset return data before running
			_returnDataFifo.Clear();
			// reset result  before running. If this object is a task ,result may've been set by a previous run
			_execResult = EXEC_RESULT_OK;
			_state = STATE_CONNECTING;
			
			if(sendUIFeedback)
			{
				UIFeedback("Connecting to host...");
			}
		}
		
		//----------------------------
		public function HandleError(msg:String):void
		{
			//var msg:String = EXEC_RESULT_ERR + " : Failed to connect to proxy.";
			_execResult = EXEC_RESULT_ERR;
			_state = STATE_DONE;
			
			if(msg!=null)
			{
				UIFeedback(msg);
			}
		}
		
		//----------------------------
		public function HandleValidate(sendUIFeedback:Boolean):Boolean
		{
			var validated:Boolean = Validate();
			
			if(!validated)
			{
				var msg:String = ZG_Utils.TranslateString(EXEC_RESULT_ERR + " : Invalid host or command.");
				_execResult = ZG_Utils.TranslateString(EXEC_RESULT_ERR + " :Invalid host or command");
				_state = STATE_DONE;
				
				if(sendUIFeedback)
				{
					UIFeedback(msg);
				}
			}
			return validated;
		}
		
		//-------------------------		
		protected function Validate():Boolean
		{
			return ((targetHostObj!=null && targetHostObj.Validate()) &&
					(_plugin.formattedCmd!=""));
		}
		
		//-------------------------
		// On connect - login ssh and execute the command
		public function OnConnect(msg:String):void
		{
			_state = STATE_EXECUTING;
		/*	_connection.LoginAndExecute(_targetHost.host,
										_targetHost.username,
										_targetHost.password,
										_plugin.formattedCmd,
										_plugin.supportsContinuousData); // can receive data */
			if(msg!=null)
			{
				UIFeedback(msg);
			}
			
			
		}
		//----------------------------
		
		
		//----------------------------
		public function ProcessData(data:XML):void
		{
			//	returnData += _connection.Read();
			//returnData = _connection.Read();
			
			_state = STATE_RECEIVING_DATA;		
			// read data, parse it  add to fifo and call feedback routine which will cause data to be displayed	
			/* XXX! DANGER@@@
				FB 4.6 has a weird bug: when in display variables view the "this" object is expanded exposing
				returnData variable,this  removes a data element from FIFO,
				as if GetData function was actually called! 
				If the returnData not looked at - this does not happen
				MOST BIZARRE! keep an eye on it
			*/
			_returnDataFifo.Add(ParseReturnData(data));
							
			UIFeedback("Receiving data...");						
		}
		//----------------------------
		public function OnClose():void
		{
			// connection closed - send event to UI
			//trace("FT_PluginExec:OnClose ");
			_state = STATE_DONE;			
		}
		//------------------------------------------
		public function SendFeedback(msg:String):void
		{
			
			UIFeedback(msg);
					
		}
		//------------------------------------------------
		public function OnProgress(event:ProgressEvent):void
		{
			trace("FT_PluginExec:OnProgress ");
		}
		//------------------------------
		//Extract data from xml
		//private function ParseReturnData(inData:String):String
		private function ParseReturnData(inData:XML):String
		{
			var outData:String = "";
			try
			{
				outData = ZG_StringUtils.Base64Decode(inData.Data);	
				if(outData.length > 0)				
				{
					SetExecResult(outData,/*xml*/inData.Status);
				}
			}
			catch(e:Error)
			{
				trace("exception in ParseReturnData:"+e.message);
			}	
			return outData;
		}
		
		//-----------------------------------
		// no reason to pass xml, just use the status string
		protected function SetExecResult(outData:String,status:String /*xml:XML*/):void
		{
			/* This is a big ass-umption..
			Look for a string "Error:" or "Warning:"  in the data. 
			If plugin is type  text and its output contain the string "error:" or "warning:" assume 
			that plugin writer wants to indicate that the plugin failed or a warning should be displayed.
			This is only used to format tasks output
			*/
			
			if(IsTask()/*_plugin.returnDataInfo.type == FT_Strings.RTYPE_TEXT*/)
			{
				if(outData.indexOf("rror:") >=0)
				{
					_execResult = EXEC_RESULT_ERR;
				}
				else if (outData.indexOf("rning:") >=0)
				{
					_execResult = EXEC_RESULT_WARN;
				}
				else
				{
					_execResult = status//xml.Status;
				}
			}
			else
			{
				_execResult = status //xml.Status;
			}
			trace("FT_PluginExec:ParseReturnData,status:"+ _execResult);// + "\noutData:\n" + outData);
		}
		//------------------------------
		protected function UIFeedback(message:String):void
		{
			_curMessage = ZG_Utils.TranslateString(message);
			DispatchEvent(FT_Events.FT_EVT_PLUGIN_EVENT,this);
		} 
		//-----------------------------------------
		public function UserCanceled():void
		{			
			_state = STATE_USER_CANCELED;						
		}
		//---------------------------------
		//Reset to a known initial state
		//------------------------------------------
		public function Reset(plugin:FT_Plugin):void
		{
			_state = STATE_INITIAL;
			if(plugin!=null)
			{
				_plugin = plugin;
				//Save command we'll be execuiting. It may change if user goes through
				// wizard while this is running
				_cmd = plugin.formattedCmd;	
			}				
		}
		//------------------------------
		/* Getters/Setters*/
		//-------------------------
		
		//-------------------------
		public function get targetHostObj():FT_TargetHost
		{
			return _targetHostObj;
		}
		//-------------------------
		public function set targetHost(value:FT_TargetHost):void
		{
			_targetHostObj = value;
			
		}
		//-------------------------
		public function get execResult():String
		{
			return _execResult;
		}
		//-------------------------
		public function set execResult(value:String):void
		{
			_execResult = value;
		}
		//-------------------------
		// This removes
		public function get returnData():String
		{
			return _returnDataFifo.Get();
		}

		//-------------------------
		public function get state():String
		{
			return _state;
		}
		//-------------------------
		public function set state(value:String):void
		{
			_state = value;
		}
		//-------------------------
		public function get plugin():FT_Plugin
		{
			return _plugin;
		}
		//-------------------------
		public function set plugin(value:FT_Plugin):void
		{
			_plugin = value;
		}
		//-------------------------
		public function get appendData():Boolean
		{
			return _appendData;
		}
		//-------------------------
		public function set appendData(value:Boolean):void
		{
			_appendData = value;
		}
		//-------------------------
		public function get curMessage():String
		{
			return _curMessage;
		}
		//-------------------------
		public function set curMessage(value:String):void
		{
			_curMessage = value;
		}
		
		//--------------------------------------
		public function get execInProgress():Boolean
		{
			
			return (_requestObj == null ? false: _requestObj.ExecInProgress());
			// == null ? (state!=STATE_DONE && state !=STATE_USER_CANCELED):;
		}	
		//--------------------------------------
		public function get name():String
		{
			return _taskName!=null && _taskName.length > 0 ? _taskName :(_plugin == null ? ZG_Strings.STR_UNDEFINED : _plugin.name);
		}
	
		//-------------------------------------
		public function get pluginResultObj():FT_PluginResult
		{
			return _pluginResultObj;
		}
		//-------------------------------------
		public function set pluginResultObj(value:FT_PluginResult):void
		{
			_pluginResultObj = value;
		}
		//---------------------------------------
		public function HasData():Boolean
		{
			return _returnDataFifo.HasData();
		}
		//---------------------------------------
		public function get requestObj():FT_ExecRequest
		{
			return _requestObj;
		}
		//---------------------------------------
		public function set requestObj(value:FT_ExecRequest):void
		{
			_requestObj = value;
		}
		//---------------------------------------
		public function get finishedPluginIndex():int
		{
			return _finishedPluginIndex;
		}
		
		// used only for tasks
		//---------------------------------------
		public function set finishedPluginIndex(value:int):void
		{
			_finishedPluginIndex = value;
		}
		//---------------------------------------
		public function get finishedPluginName():String
		{
			return _finishedPluginName;
		}
		//---------------------------------------
		public function set finishedPluginName(value:String):void
		{
			_finishedPluginName = value;
		}
		//---------------------------------------
		public function get taskName():String
		{
			return _taskName;
		}
		//---------------------------------------
		public function set taskName(value:String):void
		{
			_taskName = value;
		}
		//------------------------------------
		public function IsTask():Boolean
		{
			return (_taskName!=null && _taskName.length > 0);
		}
	}
}
