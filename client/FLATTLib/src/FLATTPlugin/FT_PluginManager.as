/*******************************************************************************
 * FT_PluginManager.as
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
	
	import FLATTPlugin.*;
	
	import Repository.FT_PluginRepository;
	
	import TargetHostManagement.FT_TargetHost;
	
	import Utility.*;
	import Utility.FT_Events;
	
	import com.ZG.Data.ZG_DataReader;
	import com.ZG.Data.ZG_QueueMonitor;
	import com.ZG.Events.*;
	import com.ZG.Logging.*;
	import com.ZG.UserObjects.*;
	import com.ZG.Utility.*;
	
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.sampler.Sample;
	import flash.utils.*;
	
	import mx.collections.*;
	import Exec.FT_ExecRequest;
	import Exec.FT_PluginExec;

	//TODO:
	/* move read/save functionality into reader and writer objects that may be file system
		or db based, depending on where we execute
	*/

	public class FT_PluginManager extends ZG_DataReader
	{
				
		//================================
		/* This singleton class manages plugins */
	
	
		[Embed(source="/Defaults/test_table1.xml",mimeType="application/octet-stream")]
		protected const DEF_PLG_1:Class;
		
		[Embed(source="/Defaults/test_table2.xml",mimeType="application/octet-stream")]
		protected const DEF_PLG_2:Class;
				
		[Embed(source="/Defaults/top_cpu_sys.xml",mimeType="application/octet-stream")]
		protected const DEF_PLG_3:Class;
		
		[Embed(source="/Defaults/top_cpu_user.xml",mimeType="application/octet-stream")]
		protected const DEF_PLG_4:Class;
		
		[Embed(source="/Defaults/network_test.xml",mimeType="application/octet-stream")]
		protected const DEF_PLG_5:Class;
		
		[Embed(source="/Defaults/test_server_config.xml",mimeType="application/octet-stream")]
		protected const DEF_PLG_6:Class;
		
		//Task plugins
		[Embed(source="/Defaults/step1.xml",mimeType="application/octet-stream")]
		protected const TASK_PLG_1:Class;
		
		[Embed(source="/Defaults/step2.xml",mimeType="application/octet-stream")]
		protected const TASK_PLG_2:Class;
		
		[Embed(source="/Defaults/step3.xml",mimeType="application/octet-stream")]
		protected const TASK_PLG_3:Class;
		
		[Embed(source="/Defaults/task_sample.xml",mimeType="application/octet-stream")]
		protected const DEF_TASK:Class;
		
		private static var s_Instance:FT_PluginManager;
		private var _pluginsDir:File;
		
		public static const PLUGINS_DIR:String = "Plugins";
		public static const DEF_TASK_NAME:String = "task_sample.xml";
		
		// this is a list of all plugins
		private var _containerColl:ArrayCollection = new ArrayCollection();
		private var _tasksColl:ArrayCollection = new ArrayCollection();
		private var _pluginsMap:Dictionary = new Dictionary();
		private var _defCats:Array = new Array( "Validation",
												"Performance",
												"Security",
												"Automation",
												"Monitoring");
		
		public function FT_PluginManager()
		{
			super();
			
			SetupContainerSort();
			// set up sort function for plugin collection ( container collection really)			
			var dataSortField:SortField = new SortField();
			dataSortField.name = "name";
			dataSortField.numeric = false;	
			dataSortField.caseInsensitive = true; // a before Z
			/* Create the Sort object and add the SortField object created earlier to the array of fields to sort on. */
			var byNameSort:Sort = new Sort();
			byNameSort.fields = [dataSortField];			
			/* Set the ArrayCollection object's sort property to our custom sort, and refresh the ArrayCollection. */
			_containerColl.sort = byNameSort;
			
		}
		//-----------------------------------------------------------
		// create default plugins and read plugin directory
		// TODO: load plugins from external source
		// Deal with LOTS of plugins.. for now just read from
		// local directory
		public function Initialize():void
		{			
			FS_ReadPlugins();
		}
		//-----------------------------------------------------------
		
		private function CreateDefaultPlugins():void
		{
			AddPlugin(new FT_Plugin(XML(new DEF_PLG_1())));
			AddPlugin(new FT_Plugin(XML(new DEF_PLG_2())));
			AddPlugin(new FT_Plugin(XML(new DEF_PLG_3())));	
			AddPlugin(new FT_Plugin(XML(new DEF_PLG_4())));			
			AddPlugin(new FT_Plugin(XML(new DEF_PLG_5())));
			AddPlugin(new FT_Plugin(XML(new DEF_PLG_6())));
			
			// Create default task plugins
			AddPlugin(new FT_Plugin(XML(new TASK_PLG_1())));
			AddPlugin(new FT_Plugin(XML(new TASK_PLG_2())));
			AddPlugin(new FT_Plugin(XML(new TASK_PLG_3())));
			
		}
		
		//-----------------------------------------------------------
		// create default task files and add 
		private function CreateDefaultTaskFiles(nonPluginFiles:Array):void
		{
			// create a task file that references default task plugins
			var f:File = new File(_pluginsDir.nativePath+File.separator+DEF_TASK_NAME);
			
			if(ZG_FileUtils.WriteFile(f,(new String(new DEF_TASK())),true,FileMode.WRITE))
			{
				nonPluginFiles.push(f);
			}
		}
		//-----------------------------------------------------------
		// loads all plugins from file system and creates default plugins
		public function FS_CreatePlugins(pluginFiles:Array):void
		{
						
			var i:int
			var allPlugins:Array = new Array();
			var allTasks:Array = new Array();// plugin tasks
			var insertObj:ZG_InsertObject;
			var nonPluginFiles:Array = new Array();
			
			for( i = 0; i < pluginFiles.length;++i)
			{
				var curFile:File = pluginFiles[i];
				
				// create a plugin object and attempt to read it in
				// associate this file with this plugin
				var plugin:FT_Plugin = new FT_Plugin();
				if(plugin.Read(curFile,true))
				{
					AddPlugin(plugin, false);//just read it ,dont write again
				}
				else
				{
					plugin = null;
					// maybe its a task , try reading it
					nonPluginFiles.push(curFile);					
				}				
			}
			allPlugins = ZG_Utils.ToArray(_pluginsMap);
			if(allPlugins.length <=0)
			{
				// no plugins on file system.
				// create defaults and save them
				CreateDefaultPlugins();
				CreateDefaultTaskFiles(nonPluginFiles);
			}
			// get the plugins again
			allPlugins = ZG_Utils.ToArray(_pluginsMap);
			
			var pluginOrganizer:FT_PluginOrganizer = new FT_PluginOrganizer();	
			/* now create  containers(categories) and add plugins to them */
			var containers:Array = pluginOrganizer.OrganizePlugins(allPlugins);
			
			for(i=0;i < containers.length;++i)
			{				
				insertObj = new ZG_InsertObject();
				insertObj.self = containers[i];
				insertObj.insertIntoDB = false;
				DispatchEvent(FT_Events.FT_EVT_INSERT_PLUGIN,insertObj);
			}
			// read all files that are not plugins
			if(nonPluginFiles.length > 0 )
			{
				for(i=0; i < nonPluginFiles.length;++i)
				{
					ReadTask(allTasks,nonPluginFiles[i]);
				}
				/*now send insert event to tasks table */
				for (i=0; i < allTasks.length;++i)
				{
					insertObj = new ZG_InsertObject();
					insertObj.self = allTasks[i];
					insertObj.insertIntoDB = false;
					DispatchEvent(FT_Events.FT_EVT_INSERT_TASK,insertObj);
				}
			}
		}
		//-----------------------------------------------------------
		// read t
		private function FS_ReadPlugins():void
		{
			if(EnsurePluginsDirectory())			
			{
				_pluginsDir.addEventListener(FileListEvent.DIRECTORY_LISTING, DirListHandler);
				// start reading plugins from FS
				_pluginsDir.getDirectoryListingAsync();
			}
		}
		//  private var 	_cancel :Boolean = false;
		//-----------------------------------------------------------
		public static function GetInstance():FT_PluginManager
		{
			if(s_Instance == null )
			{
				s_Instance = new FT_PluginManager();
			}
			return s_Instance;
		}
	 //-----------------------------------------------------------
	// TODO: Make  this asynchronous.. use QueueMonitor
	  public function ExecutePlugin(plugins:Array,
									host:FT_TargetHost,
									execObj:FT_PluginExec,
	  								task: FT_Task,
									scheduleGuid:String = "" ):void
	  {
		
		  var xtraData:Array = new Array();
		  xtraData.push(scheduleGuid);
		  //if exec obj is not null - this is a rerun and everything is already set up
		  if(execObj!=null)
		  {
			  execObj.requestObj.Rerun();
			  DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_START,execObj,xtraData);
		  }
		  else
		  {
		 	// for each host in group create own exec object and run it 
			if(host== null || !CanExecute())
		 	{
			 	return;
		 	}
		 	
		 	var execReq:FT_ExecRequest = new FT_ExecRequest();
		 	var firstExec:FT_PluginExec = execReq.PrepareRequest(plugins,
			 												  	host,
															  	FT_ExecRequest.REQTYPE_CMD_EXEC,
																task);
																
																
			 if( firstExec !=null)
			 {
				 DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_START,firstExec,xtraData);
			 }
			 else
			 {
				 // TODO: Alert maybe? serious error
			 }
		  }
	  }
	  //-------------------------------------------------------------------
	  // start executing a task on one or more hosts
	  // main entry point into the task execuition.
	  // Taskexc object handles plugins in task and multiple hosts
	  public function ExecuteTask(task:FT_Task, host:FT_TargetHost,execObj:FT_TaskPluginExec,scheduleGuid:String = ""):void
	  {			
	
		if(execObj!=null)
		{
			ExecutePlugin(null,null,execObj,null,scheduleGuid);
		}
		else
		{
			ExecutePlugin(task.GetPluginList(),host,null,task,scheduleGuid);
		}
		
	  }
	  //------------------------------------------------------------------
	  public function OnPluginEvent(event:ZG_Event):void
	  {	
		  var execObj:FT_PluginExec = event.data as FT_PluginExec;
		  
		  if(execObj!= null)
		  {
			 var isContinuous: Boolean = true;//(execObj.plugin!=null && execObj.plugin.isCountinuous == false);
			 var pluginResult:FT_PluginResult;
			// create up plugin  object if needed and set it up
			 if(execObj.pluginResultObj == null)
			 {
				 pluginResult= FT_PluginResultFactory.GetPluginResultObj(execObj.plugin.returnDataInfo.type);
				 pluginResult.execObj = execObj;
				 execObj.pluginResultObj = pluginResult;
			 }
			 else
			 {
				 pluginResult = execObj.pluginResultObj;
			 }
			 if(isContinuous)// is this a continuous plugin
			 {
				 switch(execObj.state)
				 {
					/* case FT_PluginExec.STATE_EXECUTING:
						 
						 DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_FEEDBACK,pluginResult);
						 break;
					
					 case FT_PluginExec.STATE_RECEIVING_DATA:
						 DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_FEEDBACK,pluginResult);
						 break;*/
					
					 case FT_PluginExec.STATE_DONE:
					 case FT_PluginExec.STATE_USER_CANCELED:
						 // only remove the listener when object is completely done executing.
						 // this is more important to task exec objects, a
						 //simple plugin exec obj is done when the state is DONE.
						 // 
						 // dont remove the listener for now.Revisit
						 // this object is just first one in the request.
						 // Will have to remove listeners from all objs in the request 
						 // if it is rerun -will have to add again - for now it's ok, revisit later
						 //
						 // 
						 
						/* if(!execObj.execInProgress)
						 {
							 execObj.removeEventListener(FT_Events.FT_EVT_PLUGIN_EVENT,OnPluginEvent);
						 }*/				 
						 DispatchPluginExecEndEvent(pluginResult);
						 
						 if(execObj is FT_TaskPluginExec)
						 {
							 // if this is a task exec object - continue task execution
							// if(!execObj.Run(pluginResult.execResult) && FT_TaskPluginExec(execObj).execAborted)
							 if(!execObj.ExecStart(pluginResult.execResult) && FT_TaskPluginExec(execObj).execAborted)
							 {
								 // This takes care of a case where plugin execution fails on last host.
								 // remove the listener and update rerun button in UI
								 execObj.removeEventListener(FT_Events.FT_EVT_PLUGIN_EVENT,OnPluginEvent);
								 DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_FEEDBACK,pluginResult);
							 }					 
						 }			
						 break;
					 default:
						 DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_FEEDBACK,pluginResult);
						 break;
						 
				 }
			 }
			 else
			 {
				 if(execObj.state == FT_PluginExec.STATE_DONE)
				 {				 
					 // only remove the listener when object is completely done executing.
					 // this is more important to task exec objects, a
					 //simple plugin exec obj is done when the state is DONE.
					 // 
					 if(!execObj.execInProgress)
					 {
						 execObj.removeEventListener(FT_Events.FT_EVT_PLUGIN_EVENT,OnPluginEvent);
					 }
					 
					 // Create result object and copy some info
					 // TODO: maybe this should be done by plugin exec object??
					// var pluginResult:FT_PluginResult = FT_PluginResultFactory.GetPluginResultObj(execObj.plugin.returnDataInfo.type);
					//pluginResult.execObj = execObj;
					 
					 DispatchPluginExecEndEvent(pluginResult);
					 if(execObj is FT_TaskPluginExec)
					 {
						 // if this is a task exec object - continue task execution
						 //if(!execObj.Run(pluginResult.execResult) && FT_TaskPluginExec(execObj).execAborted)
						 if(!execObj.ExecStart(pluginResult.execResult) && FT_TaskPluginExec(execObj).execAborted)
						 {
							 // This takes care of a case where plugin execution fails on last host.
							 // remove the listener and update rerun button in UI
							 execObj.removeEventListener(FT_Events.FT_EVT_PLUGIN_EVENT,OnPluginEvent);
							 DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_FEEDBACK,pluginResult)
						 }					 
					 }					  				  
				 }
				 else
				 {
					 DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_FEEDBACK,pluginResult);
				 } 
			 }
	  	 }
 	}
	  //-----------------------------------------
	  public function StartExecutingPlugin(plugin:FT_Plugin, xtraData:Array = null):void
	  {
		  //send an event to application 
		  DispatchEvent(FT_Events.FT_EVT_EXECUTE_PLUGIN,plugin,xtraData);
	  }
	  //----------------------------------------------
	 private function EnsurePluginsDirectory():Boolean
	  {
	  	
		 _pluginsDir = ZG_FileUtils.EnsureDirectory(_pluginsDir,PLUGINS_DIR);
		/*
		 if(_pluginsDir == null)
	  	{
			_pluginsDir = File.applicationStorageDirectory.resolvePath(PLUGINS_DIR);
	  		if (!_pluginsDir.exists)
	  		{
				_pluginsDir.createDirectory();
	  		}
	  	}*/
	  	return (_pluginsDir!=null && _pluginsDir.exists );
	  }
	 //----------------------------------------------
	  private function DirListHandler(event:FileListEvent):void		
	  {
		  var contents:Array = event.files;		 
		  FS_CreatePlugins(event.files);
	  }
	  //----------------------------------------------
	  // Save plugin or task to plugin directory and add to UI
	  public function Save(obj:ZG_PersistentObject):void
	  {
		if(obj!=null)
		{
			if(EnsurePluginsDirectory())
			{					
				if(obj.Write(_pluginsDir))
				{
					InsertInUI(obj, (obj is FT_Task ? FT_Events.FT_EVT_INSERT_TASK: FT_Events.FT_EVT_INSERT_PLUGIN));
				}			
			}		
		}
				  
	  }
	  // Here the object is inserted in UI and added to plugin manager list of plugins
	  //----------------------------------------------
	  public function InsertInUI(obj:ZG_PersistentObject, evtType:String):void
	  {
		  var insertObj:ZG_InsertObject = new ZG_InsertObject();
		  insertObj.self = obj;
		  insertObj.insertIntoDB = false; // remnant of ZG - unused
		  DispatchEvent(evtType,insertObj);
	  }
	 //----------------------------------------------------
	  // delete plugin or task
	 public function Delete(obj:ZG_PersistentObject,coll:ArrayCollection):void
	 {
		 if(EnsurePluginsDirectory())
		 {		
			obj.Delete(_pluginsDir);
		 }	
		 if( coll!=null)
		 {
			 coll.removeItemAt(coll.getItemIndex(obj));
		 }
	 }
	 //----------------------------------------------------
	public function get containerColl():ArrayCollection
	{
		return _containerColl;
	}
	//-------------------------------------------------
	public function FindPlugin(guid:String):ZG_PersistentObject
	{		
		return _pluginsMap[guid];
	}
	//---------------------------------------------------
	public function FindTask(guid:String):ZG_PersistentObject
	{
		return ZG_ArrayCollection.FindItemBy(_tasksColl,ZG_PersistentObject.SRCH_TYPE_GUID,guid)
	}
	//----------------------------------------------------
	public function get tasksColl():ArrayCollection
	{
		return _tasksColl;
	}
	// generic insertion routine that inserts the object to the
	// appropriate list
	public function Insert(insertObj:ZG_InsertObject):void
	{
		// test for subclass first then base class
		if (insertObj.self is FT_Task)
		{
			InsertTask(insertObj);
		}
		else
		{
			InsertPlugin(insertObj);
		}
	}
	//----------------------------------------------------
	// This is where the object is inserted into the list of plugins
	protected function InsertPlugin(insertObj: ZG_InsertObject):void
	{
		// if the object is a container just insert it
		if (ZG_PersistentObject(insertObj.self).isContainer  )
		{
			AddContainer(insertObj.self);
		}
		else
		{
			var plugin:FT_Plugin = insertObj.self as FT_Plugin;
			var addToContainer:Boolean = false;
			var container:FT_PluginContainer = null;
						
			// find a container if it exists
			container = ZG_Utils.GetObjectByName(plugin.category,_containerColl,false,false) as FT_PluginContainer;				
			// if already got a container - see if this 
			// child already exists
			if(container!=null)
			{
				var curPlugin:FT_Plugin = container.FindChildBy(ZG_PersistentObject.SRCH_TYPE_NAME,plugin.name) as FT_Plugin;
				
				if(curPlugin == null)
				{
					addToContainer = true;							
				}
				else
				{
					//update plugin with new xml
					curPlugin.InitFromString(plugin.ToXMLString());
				}
			}
			else
			{
				// create a new container
				container = new FT_PluginContainer();
				container.name = plugin.category;
				AddContainer(container);
				addToContainer = true;
			}
			if( container!=null && addToContainer )
			{
				container.AddChild(plugin);
			}
		}
		
		//when trades are inserted after mt import,database insertion is done in Account::BatchInsert 
		if(insertObj.insertIntoDB)
		{
			//TODO ZG_DataWriter.GetInstance().Insert(insertObj.self as ZG_PersistentObject);
		}		
	}
	
	//------------------------------------------------------
	private function ReadTask(tasksArray:Array, taskFile:File):void
	{
		var task:FT_Task = new FT_Task();
		if(task.Read(taskFile,true))
		{
			tasksArray.push(task);
		}
	}
	//------------------------------------------------------
	protected function InsertTask(insertObj:ZG_InsertObject):void
	{
		//check if already there
		var task:FT_Task = insertObj.self as FT_Task;
		if(FindTask(task.guid)== null)
		{
			_tasksColl.addItem(insertObj.self);
		}		
	}
	//------------------------------------------------------
	public function SaveTasks():void
	{
		for(var i:int =0; i < _tasksColl.length;++i)
		{
			var cur:FT_Task = _tasksColl.getItemAt(i) as FT_Task;
			if(cur!=null && cur.dirty)
			{
				trace("saving dirty task " + cur.name);
				Save(cur);
			}
		}
	}
	//----------------------------------
	// adds a plugin to plugin manager map and saves it to file
	private function AddPlugin(plg:FT_Plugin,save:Boolean = true ):void
	{
		_pluginsMap[plg.guid] = plg;
		if(save)
		{
			plg.Write(_pluginsDir);
		}	
	}
	//---------------------------------------------------------------------
	// see if user canceled any of the executing objects.
	private function UserCanceled(executingObjects:Array):Boolean
	{
		for (var i:int = 0; i < executingObjects.length;++i)
		{
			if(executingObjects[i].state == FT_PluginExec.STATE_USER_CANCELED)
			{
				return true;
			}
		}
		return false;
	}
	//-------------------------------------------
	// Check if we should even bother executing. For the moment only proxy port is checked
	// may be other things in the future
	protected function CanExecute():Boolean
	{
		
		if(!FT_Application.GetInstance().ValidateProxy())
		{
			DispatchEvent(FT_Events.FT_EVT_EXEC_ERROR,
						  "SSH proxy configuration error. Cannot execute Actions and Tasks.");
			return false;
		}
		return true;
	}
	//--------------------------------------------------------------
	// get a list of categories in current collection
	public function GetCategoryList(includeDefaultCats:Boolean = true):Array
	{
		var ret:Array = new Array();
		if(includeDefaultCats)
		{
			ret = ret.concat(_defCats);
		}
		for(var i: int = 0; i < _containerColl.length; ++i)
		{
		
			var cur:Object  = _containerColl.getItemAt(i);
			if(cur is FT_PluginContainer && (ret.indexOf(cur.name)< 0))
			{
				ret.push(cur.name);
			}
		}
		ret.sort(); // default ascending sort
				
		return ret; ;
		
	}	
	//----------------------------------------------------
	private function AddContainer(container:Object):void
	{
		_containerColl.addItem(container);
		// apply sort to collection
		_containerColl.refresh();		
	}
	
	//-----------------------------------------------------
	// set up sort partameters for containers
	// TODO: get params from prefs?
	private function SetupContainerSort():void
	{
		// set up sort function for pl ugin collection ( container collection really)			
		var dataSortField:SortField = new SortField();
		dataSortField.name = "name";
		dataSortField.numeric = false;	
		dataSortField.caseInsensitive = true; // a before Z
		/* Create the Sort object and add the SortField object created earlier to the array of fields to sort on. */
		var byNameSort:Sort = new Sort();
		byNameSort.fields = [dataSortField];			
		/* Set the ArrayCollection object's sort property to our custom sort, and refresh the ArrayCollection. */
		_containerColl.sort = byNameSort;
	}
	//----------------------------------------------------------------
	private function DispatchPluginExecEndEvent(pluginResult:FT_PluginResult):void
	{
		DispatchEvent(FT_Events.FT_EVT_PLUGIN_EXEC_END,pluginResult);	
		// notify schedule manager that a plugin or a taskk completed execution
		DispatchEvent(FT_Events.FT_EVT_SCHEDULE_RESTART,pluginResult);
	}
	  
	}// class
		    
}
