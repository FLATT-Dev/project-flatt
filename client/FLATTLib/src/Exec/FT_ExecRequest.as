/*******************************************************************************
 * FT_ExecRequest.as
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
	
	import FLATTPlugin.FT_Plugin;
	import FLATTPlugin.FT_PluginManager;
	import FLATTPlugin.FT_Task;
	
	import Network.*;
	
	import Repository.*;
	
	import TargetHostManagement.*;
	
	import Utility.*;
	
	import com.ZG.Events.*;
	import com.ZG.Logging.*;
	import com.ZG.UserObjects.ZG_PersistentObject;
	import com.ZG.Utility.*;
	
	import flash.events.*;
	
	import mx.utils.*;

	// ------------------------------------
	/*
		This class represents a request to the proxy to execute a command or multiple
		commands on one or more hosts
	*/
	
		
	public class FT_ExecRequest extends ZG_EventDispatcher
	{
		
		private var CUR_REQ_VERSION:String = "2";
		public static var REQTYPE_CMD_EXEC:int = 0; // action exec
		public static var REQTYPE_HOST_SCAN:int = 1; // host scan
		public static var REQTYPE_REPO: int = 2;		// repo action request
		public static var FT_ACK:String = "6";	// Ack character that we send to host to acknowledge receipt of data
		public static var RESPTYPE_FIN:String="1"; // the server tells us that all its threads are done and we diconnect
		
		
		protected var _connection:FT_Connection;
		// list of commands to execute more than one means it's a task
		private var _pluginList:Array = new Array(); 
		private var _execObjects:Array = new Array();
		private var _targetHost:FT_TargetHost;
		private var _reqType:int = REQTYPE_CMD_EXEC; // default type is command execution
		private var _task:FT_Task;
		private var _fatalErr:String = "";
		private var _xtraData:Array;// extra data that may be passed in. currently used for repo request		
		private var _xmlReq:XML;
		private var _useLocalConnection:Boolean; 	// for some requests, i.e repo, need to override prefs 
													// and only use local conection
		private var _returnData:String = "";
		
		public function FT_ExecRequest(target:IEventDispatcher=null)
		{
			super(target);
		}
	
		public function Rerun():void
		{
			// rerun this request 
			// reset all the objects
			// set their plugin to the first plugin in the list
			//  this is only for tasks
			for( var i:int=0;i < _execObjects.length;++i)
			{				
				_execObjects[i].Reset(_pluginList[0]);
			}
			_returnData = "";
			Connect();			
		}
		//------------------------------------------
		//  the order of plugins should be set correctly if this is a task
		public function PrepareRequest(plugins:Array,
									   host:FT_TargetHost,  
									   reqType:int,
									   task:FT_Task  = null,
									   xtraData:Array = null):FT_PluginExec
		{
		
			_targetHost=host;
			_pluginList= plugins;
			_reqType = reqType;
			_task = task;
			_xtraData = xtraData
						
			PrepareForExecution();
			if(_execObjects!=null && _execObjects.length > 0)
			{
				Connect();
			}
			return((_execObjects == null || _execObjects.length <=0) ? null: _execObjects[0]);
		}
		//------------------------------------------------------
		protected function InitConnection():void
		{
			if(_connection!=null)
			{
				_connection = null; // TODO: remove listeners,if not done the object is not cleaned up
			}
			// use local proxy only if set, otherwise let connection factory decide based on prefs
			if(_useLocalConnection)
			{
				_connection = new FT_SocketConnection();
			}
			else
			{
				_connection = FT_ConnectionFactory.GetConnection();
			}
			_connection.ConfigureListeners(OnConnect,OnData,OnClose,OnIoErr,OnProgress,OnSecurityErr);
		}
		//----------------------------------------------------
		public function Connect():void
		{
			
			if(_xmlReq!=null)
			{			
				InitConnection();
				if(!_connection.Connect())
				{										
					for(var i:int =0; i < _execObjects.length;++i)
					{
						var cur:FT_PluginExec = _execObjects[i] as FT_PluginExec;
						cur.HandleError(i==0 ? 
										"Failed to connect to proxy" : null); // send feedback to UI only once
					}				
					//_execResult = EXEC_RESULT_ERR;	
					//TODO: send feedback to UI - but once, maybe just use the first exec obj for this				
				}
			}
			
			/*UIFeedback(msg);
			
			if(!_connection.Connect())
			{					
				_execResult = EXEC_RESULT_ERR;					
				msg = EXEC_RESULT_ERR + ": "+ _connection.errMessage;
			}*/
			
		}
		//-----------------------------------------
		public function ExecInProgress():Boolean
		{
			// if any of the objects is in in a state that is not Done or canceled - they are in progress
			for(var i:int =0; i < _execObjects.length;++i)
			{
				var objState:String = _execObjects[i].state;
				if(objState != FT_PluginExec.STATE_DONE && objState !=FT_PluginExec.STATE_USER_CANCELED)
				{
					return true
				}
			}
			// none of the objects is in a state other  than (done and canceled) - it is in progress
			return false;
		}
			
		//------------------------------
		// Build a list of exec objects and build an xml request
		
		/*private String s_NewXMLStr =
		"<SSHRequest version=\"2\" id=\"12345\">"+
		"<hosts username=\"hostlist-username\" password=\"hostlist-password\">"+
		"<sshkey>blablabla</sshkey>"+
		"<host addr=\"host1.amazon.com\">"+
		"<sshkey>sshkey1</sshkey>" +
		"</host> " +
		"<host addr=\"host2.amazon.com\">"+
		"<sshkey>sshkey2</sshkey>" +
		"</host> " +
		"<host addr=\"host3.amazon.com\">"+
		"<username>host3-username</username>"+  
		"<password>host3-password</password> " +
		"</host> "+
		"</hosts>"+
		"<commands>"+
		"<command>dW5hbWUgLWE=</command>"+
		"</commands>"+ 
		"<realtime>true</realtime>"+
		"<needsScp>yes</needsScp>"+
		"</SSHRequest>";*/
		//-------------------------------------
		protected function PrepareForExecution():void
		{
					
			// build xml along the way
			_xmlReq = new XML(ZG_XMLUtils.TAG_SSH_REQUEST_OPEN + ZG_XMLUtils.TAG_SSH_REQUEST_CLOSE);
			_xmlReq.@version = CUR_REQ_VERSION;
			_xmlReq.@id = new Date().time;
					
			// append common fields
			_xmlReq.appendChild(<realtime>{true}</realtime>);
			_xmlReq.appendChild(<reqtype>{_reqType}</reqtype>);
			
			// if it's a host scan create one object in the list
			if(_reqType == REQTYPE_HOST_SCAN)
			{
				new FT_HostScanParams().AddToXML(_xmlReq);
				var hostScannerObj:FT_HostScannerExec = new FT_HostScannerExec(null);
				// associate with this request obj
				hostScannerObj.requestObj = this;
				hostScannerObj.HandleConnecting(true);// this sends connecting event to UI which causes the spinner to start spinning
				_execObjects.push(hostScannerObj );
			}
			else if (_reqType == REQTYPE_REPO)
			{
				//repo request parameters is in xtra data[0]				 
				_xmlReq.appendChild(_xtraData[0].ToXML());
				var repoReqObj:FT_RepoExec = new FT_RepoExec(null);
				// associate with this request obj
				repoReqObj.requestObj = this;
				_execObjects.push(repoReqObj );
			}
			else
			{
				if(_targetHost == null && _pluginList == null)
				{
					_xmlReq = null;
					return ;
				}
							
				var hostList:Array = _targetHost.isContainer ? _targetHost.GetChildrenArray():new Array(_targetHost);
				var hostsXml:XML = new  XML(<hosts></hosts>);
				var actionsXml:XML = new XML(<actions></actions>);
				var actionXml:XML = null;
				
				var containerUsername:String = _targetHost.isContainer? _targetHost.username:	"";
				var containerPassword:String = _targetHost.isContainer ? _targetHost.password:	"";
				var containerSshKeyData:String = _targetHost.isContainer ? _targetHost.sshKeyData: "";
										 
				//--set up container username, password and ssh key
				if(containerUsername!="")
				{
					hostsXml.@username=containerUsername;
				}
				else
				{
					// container does not have a user name - try using the master
					hostsXml.@username = FT_Prefs.GetInstance().GetMasterUserName();
				}
				if(containerPassword!="")
				{
					hostsXml.@password=containerPassword;
				}
				else
				{
					// container does not have a password - try using the master
					hostsXml.@password = FT_Prefs.GetInstance().GetMasterPassword();
				}
				if(containerSshKeyData!="")
				{
					hostsXml.@sshkey=containerSshKeyData;
				}
				else
				{
					 hostsXml.@sshkey = ZG_FileUtils.GetEncodedSshKeyData(FT_Prefs.GetInstance().GetMasterSshKeyPath());
				}
				
				/* if host is a container - check if it has a config parameters */
				if(_targetHost.isContainer)
				{
					var configData:String = _targetHost.GetEncodedConfig();
					if(ZG_StringUtils.IsValidString(configData))
					{
						hostsXml.appendChild(<configParams>{configData}</configParams>);
					}
					/* also add the name and possibly guid - add later if needed*/
					hostsXml.@name=_targetHost.name;
					//hostsXml.@guid=_targetHost.guid;
				}
				
				if(_task!=null)
				{
					actionsXml.@name=_task.name;
					actionsXml.@guid=_task.guid;
				}
				// build actions list
				for( var k:int =0; k < _pluginList.length;++k)
				{		
					var curPlugin:FT_Plugin = _pluginList[k];
					
					actionXml = new XML(<action>{ZG_StringUtils.Base64Encode(ZG_StringUtils.Dos2Unix(curPlugin.commandString))}</action>);
					actionXml.@seqnum=k;// change attr to generate a malformed req error from the back end
					actionXml.@name=curPlugin.name;
					actionXml.@guid=curPlugin.guid;
					actionXml.@version=curPlugin.version;
					
					actionsXml.appendChild(actionXml);
				}
				
				// now create a list of exec objects for every host
				for(var i:int =0; i < hostList.length ; ++i)
				{
					var curHost:FT_TargetHost = hostList[i];
					// create exec object and add to list
					// assign the first plugin from the list of plugins
					// for actions it's gonna be just that
					// for tasks - it will be handled when data from execution arrives
					var curExec:FT_PluginExec = new FT_PluginExec(_pluginList[0]);
					curExec.targetHost = curHost;
					curExec.requestObj = this; // associate wth req obj
					curExec.taskName = (_task == null ? null : _task.name); // if it's a task it will be non null
					curExec.appendData = (i >0);	
					
					//Host and plugin must be set up before validation
					if(curExec.HandleValidate(i==0))
					{
						curExec.addEventListener(FT_Events.FT_EVT_PLUGIN_EVENT,
												 FT_PluginManager.GetInstance().OnPluginEvent);
						
											
						hostsXml.appendChild(curHost.ToRequestXML());	
						curExec.HandleConnecting(i==0);
						_execObjects.push(curExec);
					}
					else
					{
						ZG_AppLog.GetInstance().LogIt("FT_ExecRequest: Exec for host "+
													     curHost.host +
														" failed validation");
					}
				}
				
						
				_xmlReq.appendChild(hostsXml);
				_xmlReq.appendChild(actionsXml);
			}					
		}
	
		//-------------------------------------------
		// On connect - login ssh and execute the command
		protected function OnConnect(event:Event):void
		{			
			
			if(_xmlReq!=null)
			{
				
				for(var i:int =0; i < _execObjects.length;++i)
				{
					var cur:FT_PluginExec = _execObjects[i] as FT_PluginExec;
					cur.OnConnect(i==0 ? "Executing FLATT Action...":null);
				}
				
				_connection.LoginAndExecute(_xmlReq.toXMLString())
			}
			else
			{
				UserCanceled();
			}
		}
		//------------------------------
		protected function OnData(event:ProgressEvent):void
		{
			var responses:Array = new Array();
			
			_returnData +=_connection.Read();
			var xmlResponses:Array = ProcessXmlResponses();
			// if the data that came in is not valid xml - add it to local buffer and check again 
			
			for(var i:int =0; i < xmlResponses.length;++i)
			{
				var curResp:String = ProcessData(xmlResponses[i]);
				if (curResp!="")
				{
					_connection.SendByteArray(curResp +"\n");
				}
				else
				{
					//Normally server exec object is associated with the host and when we receive the server packet the host addr is there
					//   and we just send it back to tell the server that we got the packet.
					//   Several exceptions to this are
					//	1. Error on the server side. 
					//	2. Host scan request
					//
					//trace("OnData: response string is empty, not sending response to server.");
				}
			}
		
			
		}
		//----------------------------
		// the proxy waits for response always,
		/*protected function OnData(event:ProgressEvent):void
		{
			var response:String = "";

			var data:String = _connection.Read();
			var xml:XML = ZG_XMLUtils.ValidateResponseXML(data);
			// if the data that came in is not valid xml - add it to local buffer and check again 
			
			if(xml == null)
			{
				// see if we have been accumulating response data on a very large response
				_returnData+=data;
				//trace("FT_ExecRequest: OnData: Accumulating big data..");
				xml = ZG_XMLUtils.ValidateResponseXML(_returnData);
			}
				
			if(xml!=null)
			{
				response = ProcessData(xml);
				_returnData="";
			}	
			
			if(response!="")
			{
				//trace("OnData-Sending ack: " + response);
				_connection.SendByteArray(response+"\n");
				
			}
			else
			{
				//Normally server exec object is associated with the host and when we receive the server packet the host addr is there
				//   and we just send it back to tell the server that we got the packet.
				//   Several exceptions to this are
				//	1. Error on the server side. 
				//	2. Host scan request
				//
				//trace("OnData: response string is empty, not sending response to server.");
			}
		
		}*/
		//----------------------------
		protected function OnClose(event:Event):void
		{
			
			trace("FT_ExecRequest:OnClose!");
			for(var i:int =0; i < _execObjects.length;++i)
			{
				var cur:FT_PluginExec = _execObjects[i] as FT_PluginExec;
				// dont send feedback until all objects' state is  set to done
				// feedback calls into Plugin Manager which sends EXE_END message to the UI
				cur.OnClose(); 
			}
			_execObjects[0].SendFeedback("Execution complete"+ (_fatalErr!=""? ": "+ _fatalErr : ""));
		}
		//------------------------------------------------
		private function OnIoErr(event:IOErrorEvent):void
		{
			
			for(var i:int =0; i < _execObjects.length;++i)
			{
				var cur:FT_PluginExec = _execObjects[i] as FT_PluginExec;
				var msg:String = "";
				if(event.errorID == 2031)
				{
					msg = ZG_Utils.TranslateString("Connection Error "+event.errorID);
				}
				else
				{
					msg = "IO Error: " + event.text;
				}				
				cur.HandleError(i == 0 ? msg : null);
			}
	
		}
		//------------------------------------------------
		private function OnProgress(event:ProgressEvent):void
		{
			trace("FT_PluginExec:OnProgress ");
		}
		//------------------------------------------------
		private function OnSecurityErr(event:SecurityErrorEvent):void
		{
			for(var i:int =0; i < _execObjects.length;++i)
			{
				var cur:FT_PluginExec = _execObjects[i] as FT_PluginExec;
				cur.HandleError(i == 0 ? "Security error" +event.text : null);
			}
		}
		//------------------------------------------
		public function HandleUserCanceled():void
		{
			for(var i:int=0; i < _execObjects.length; ++i )
			{
				// don't call on yourself, done at the end
				_execObjects[i].UserCanceled();			
			}
			_execObjects[0].SendFeedback("Canceled");
			// and cancel self 
			UserCanceled();
		}
		//------------------------------------
		protected function UserCanceled():void
		{
			if(_connection !=null )
			{
				_connection.Disconnect();
			}
		}
		//--------------------------------------------
		protected function ProcessData( xmlData:XML):String
		{
			 
			 var ret:String = ""
			 
			 if(xmlData!=null)
			 {				
				
				if(xmlData.CmdSeqNum == -1)
				{
					
					// Server is indicating a fatal error - for now it's only out of mem err
					// this will be reported in OnClose. Also let the first obj
					// report it in case the server hung - this way at least there is feedback
					// that something is wrong
					if(xmlData.@type == RESPTYPE_FIN)
					{		
						_fatalErr =  ZG_StringUtils.Base64Decode(xmlData.Data);	
					}
					// not associated with a host or command - most likely a generic error
					// Send through in the first exec object					
					_execObjects[0].ProcessData(xmlData);					
				}
				else
				{
					for(var i:int=0; i < _execObjects.length; ++i )
					{
						var cur:FT_PluginExec = _execObjects[i] as FT_PluginExec;
						if(cur.targetHostObj.host == xmlData.Host)
						{
							var cmdSeqNum:int= xmlData.CmdSeqNum;
							if(_pluginList.length > 1 && (cmdSeqNum >=0 && cmdSeqNum < _pluginList.length))
							{
								// this means it's a task. save the sequence number of the plugin that just 
								// finished and its name
								cur.finishedPluginIndex = cmdSeqNum+1;
								cur.finishedPluginName = _pluginList[cmdSeqNum].name;
								cur.plugin = _pluginList[cmdSeqNum];
								
							}
							/*if(cmdSeqNum >=0 && cmdSeqNum+1 < _pluginList.length)
							{
								var nextPlugin:FT_Plugin = _pluginList[cmdSeqNum+1];
								//cur.plugin = nextPlugin;
								
							}*/
							cur.ProcessData(xmlData);
							ret = cur.targetHostObj.host;
							break;
						}				
					}
				}
			 }
			 else
			 {
				 //
			 }	
			 
			 return ret; // tell the caller to send an ack
		}
		//---------------------------------------------
		public function get useLocalConnection():Boolean
		{
			return _useLocalConnection;
		}
		//--------------------------------------------
		public function set useLocalConnection(value:Boolean):void
		{
			_useLocalConnection = value;
		}

		public function get fatalErr():String
		{
			return _fatalErr;
		}

		public function set fatalErr(value:String):void
		{
			_fatalErr = value;
		}
		
		//---------------------------------
		public function get task():ZG_PersistentObject
		{
			return _task;
		}
		//-----------------------------------------
		public function get pluginsList():Array
		{
			return _pluginList;
		}
		//---------------------------
		private function ProcessXmlResponses():Array
		{
			
			var ret:Array = new Array();			
			// process data accumulated so far.
			// if there is a valid response - create xml for it and advance the string past it
			while(true)
			{
				var closeIndex:int = -1;
				var openIndex:int = _returnData.indexOf(ZG_XMLUtils.TAG_SSH_REPONSE_OPEN);
				if(openIndex >=0)
				{
					closeIndex = _returnData.indexOf(ZG_XMLUtils.TAG_SSH_REPONSE_CLOSE,openIndex);
				}
				if(openIndex >=0 && closeIndex>=0)
				{
					try
					{
						var strXml:String = _returnData.substring(openIndex,closeIndex+ZG_XMLUtils.TAG_SSH_REPONSE_CLOSE.length);
						var xml:XML = new XML(strXml);
						ret.push(xml);
					}
					catch(e:Error)
					{
						
					}
					// advance the returndata past this response
					_returnData = _returnData.substr(closeIndex+ZG_XMLUtils.TAG_SSH_REPONSE_CLOSE.length+1);
				}
				else
				{
					break;
				}
			}
			return ret;
		}
			
			
		
	} // end class
	
}
