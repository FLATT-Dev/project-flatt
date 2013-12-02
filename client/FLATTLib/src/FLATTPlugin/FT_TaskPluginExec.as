/*******************************************************************************
 * FT_TaskPluginExec.as
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
	import TargetHostManagement.FT_TargetHost;
	
	import com.ZG.Utility.*;
	
	import mx.collections.ArrayCollection;
	import mx.effects.easing.Back;
	import Exec.FT_PluginExec;

	public class FT_TaskPluginExec extends FT_PluginExec
	{
		private var _curHostIndex:int;		
		private var _curExecutingPluginIndex:int;
		private var _execHost:FT_TargetHost;
		private var _task:FT_Task;
		private var _execAborted:Boolean ;// was the run aborted due to error?
		
		public function FT_TaskPluginExec(task:FT_Task ,execHost:FT_TargetHost)
		{
			_task = task;
			_execHost = execHost;	
			super(null);
			
		}
		//----------------------------------------
		public function ResetExecVars():void
		{
			_curHostIndex = 0;
			_curExecutingPluginIndex = 0;
			_execAborted = false;
			targetHost = null; // force obtaining the first target host again			
			state = STATE_INITIAL ;
		}
		
		//-------------------------------------------------
		// return next host if it exists and increment index.
		// only do  this if a host is a container
		//----------------------------------------
		public function GetNextExecHost():FT_TargetHost
		{
			var host:FT_TargetHost = null;
			if(_execHost.isContainer)
			{
				if((_curHostIndex >=0) &&(_curHostIndex < _execHost.GetChildrenArray().length))
				{
					host = _execHost.GetChildrenArray()[_curHostIndex];
				}					
			}
			else
			{
				//single host - return it if index is 0
				if(_curHostIndex == 0)
				{
					host = _execHost;
				}
			}
			_curHostIndex++;			
			return host;
		}
		//----------------------------------------
		// get a pointer to the currently executing plugin
		public function GetNextPluginRef():FT_PluginRef
		{			
			var taskChildren:ArrayCollection = _task.children;
			var ret:FT_PluginRef = (_curExecutingPluginIndex >= 0)&&
				(_curExecutingPluginIndex < taskChildren.length)? 
				FT_PluginRef(taskChildren.getItemAt(_curExecutingPluginIndex)):
				null;
			_curExecutingPluginIndex++;
			return ret;
		}
		//-------------------------
		// only return name when set, otherwise use plugin name
		// this is used for tasks
		override public function get name():String
		{
			return (_task.name);
		}			
		//-----------------------------------------
		public function get task():FT_Task
		{
			return _task;
		}
		//-----------------------------------------
		public function set task(value:FT_Task):void
		{
			_task = value;
		}
		//-------------------------------------------		
		
		//override public function Run(prevRes:String = null):Boolean	
		override public function ExecStart(prevRes:String = null):Boolean	
		{
			var pluginRef:FT_PluginRef = GetNextPluginRef();
			var host:FT_TargetHost = null;
			
			// check if user canceled 
			if( state == STATE_USER_CANCELED)
			{
				return false;
			}
			// if plugin execution results in an error, the task run is aborted on a given host
			// and we move on to the next host or stop if no more hosts.
			// execAborted is used to determine if the task is still executing ( for UI)
			// set last exec aborted state
			_execAborted = ((prevRes == null)? false: (prevRes == FT_PluginExec.EXEC_RESULT_ERR)) ;
			
			// TODO: unused, delete var resetVars:Boolean = false;
			// make sure to reset everything;
			//execResult = EXCEC_RESULT_OK;
			//returnData = "";
			
			//_pluginExecCount++;
			
			
			// append data if this is a continuation of the run
			// when task begins execuion, prevRes is null
			appendData = (prevRes!=null);
			
			// set up target host and plugin that we're executing
			// if no more plugin refs - we're done executing for this host. 	
			// see if more hosts are available and start executing from the beginning
			if( pluginRef == null )
			{
				// we have no more plugins to run
				// check if there are more hosts
				if(_execHost.isContainer)
				{
					host = GetNextExecHost();
					if( host !=null )
					{
						// reset plugin index and start executing plugins on new host
						_curExecutingPluginIndex = 0;
						//_pluginExecCount = 0;
						pluginRef = GetNextPluginRef();					
					}
				}
				// if it's not a container - we had one host and we're done executing
			}
			else
			{
				// we have more plugins to run - check execution result of the previous plugin
				// If an error occurred - stop executing on this host and move on to the 
				// next one if it's there, otherwise do nothing
				if(prevRes == FT_PluginExec.EXEC_RESULT_ERR)
				{
					if(_execHost.isContainer)
					{
						host = GetNextExecHost();
						_curExecutingPluginIndex = 0;	
						// get the first plugin again and attempt to execute it on a new host
						pluginRef = GetNextPluginRef();
					}										
				}		
				else
				{
					// if this is the first plugin in task,  the host has not been set up yet,
					// otherwise targetHost contains the correct host
					host = targetHostObj; 
				}
				// target host has not been set up yet
				// account for cases when plugin returns an error.
				// If there was an error executing a plugin, don't  reset the hosts so eventually we can get to the end 
				// of the host list
				if(host == null && (prevRes != FT_PluginExec.EXEC_RESULT_ERR))
				{
					host = GetNextExecHost();
				}
			}
			// set up variables for parent
			if(host!=null && pluginRef!=null)
			{
				targetHost = host;
				plugin = pluginRef.plugin;
				// if we have a host and a plugin and about to start executing, make sure that execAborted flag is cleared
				// This way, if a task fails on a host, it will complete on the next one 
				_execAborted = false;
			
				return super.ExecStart();//Run();
			}				
			// return false if the task did not run because there are no more hosts or plugins
			// this ensures that event listener is properly removed.
			return false; 
			
		}
		//-------------------------------------------
		override public function get execInProgress():Boolean
		{
			var hasMoreHosts:Boolean = false;
			var hasMorePlugins:Boolean = false;
			
			if(state == STATE_USER_CANCELED)
			{
				return false;
			}
			if(state == STATE_DONE)
			{
				// if we're in done state - check if there are more hosts and plugins to run
				if(_execHost.isContainer)
				{
					hasMoreHosts =(_curHostIndex < _execHost.children.length);
				}
				hasMorePlugins = (_curExecutingPluginIndex < task.children.length);
				// if there are more plugins in the task to run, or if 
				//there is another host that task needs to run on
				// the plugin index may still be in range so check execAborted flag
				return ( hasMoreHosts ||(hasMorePlugins && !_execAborted) );
				
			}
			return true;
		}		
		//-------------------------------------------
		public function get curExecutingPluginIndex():int
		{
			return _curExecutingPluginIndex;
		}
		//--------------------------------------------
		public function GetCompletedPluginName():String
		{
			var pr:FT_PluginRef = null;
			
			var taskChildren:ArrayCollection = _task.children;
			if(taskChildren.length > 0 )
			{
				var index:int =( _curExecutingPluginIndex > 0 ? _curExecutingPluginIndex-1 : _curExecutingPluginIndex);
				pr = (index >= 0)&& (index < taskChildren.length)? FT_PluginRef(taskChildren.getItemAt(index)):null;
			}
			
			return(pr? pr.name:ZG_Strings.STR_UNDEFINED);
		}
		//--------------------------------------------
		public function get execAborted():Boolean
		{
			return _execAborted;
		}
		//--------------------------------------------
		public function set execAborted(value:Boolean):void
		{
			_execAborted = value;
		}
		
		//------------------------------------------------------------------
		// TODO
		/*override public function HandleUserCanceled():void 
		{
			_execAborted = true;
			UserCanceled();
		}*/

		//--------------------------------------------
		/*public function get pluginExecCount():int
		{
			return pluginExecCount;
		}
		//--------------------------------------------
		public function set pluginExecCount(value:int):void
		{
			_pluginExecCount = value;
		}*/

		
	}
}
