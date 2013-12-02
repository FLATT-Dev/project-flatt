/*******************************************************************************
 * FT_RepoExec.as
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
package Repository
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
	

	public class FT_RepoExec extends FT_PluginExec
	{
		
		
		//---------------------------------
		public function FT_RepoExec(plugin:FT_Plugin)
		{
			super(plugin);
		}		
		//---------------------------------------
		override protected function UIFeedback(message:String):void
		{
			// only send events when the object is in done state
			if(state == STATE_DONE || state == STATE_USER_CANCELED)
			{
				// Parent object sends "Execution complete" message
				// Supress it - in the view the appropriate message will be displayed
				if (message.indexOf("complete") >=0)
				{
					message = "";
				}				
			}
			if(message.length > 0 )
			{
				DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,message);
			}
			//and finally check the exec result. If it's an error - send repo action event. otherwise ui is 
			// never updated
			if(this._execResult == EXEC_RESULT_ERR)
			{	
				DispatchEvent(FT_Events.FT_EVT_REPO_ACTION_END,this);
			}
			
		} 
		
		//-------------------------
		// On connect - login ssh and execute the command
		// called by execrequest object. msg is unused
		override public function OnConnect(msg:String):void
		{
			state = STATE_EXECUTING;
		
		}
		
		//----------------------------
		override public function OnClose():void
		{
			// connection closed - send event to UI
			_state = STATE_DONE;			
			DispatchEvent(FT_Events.FT_EVT_REPO_ACTION_END,this);
			
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
		}
	}
}
