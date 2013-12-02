/*******************************************************************************
 * FT_RepoManager.as
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
	import Licensing.*;
	
	import Network.*;
	
	import Utility.*;
	
	import com.ZG.Events.*;
	import com.ZG.Logging.*;
	import com.ZG.UserObjects.*;
	import com.ZG.Utility.*;
	
	import flash.display.FocusDirection;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.IEventDispatcher;
	import flash.filesystem.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	public class FT_RepoManager extends ZG_EventDispatcher
	{
		public static var REPO_ACTION_NONE:int = 0; // not sure if will be used
		public static var REPO_ACTION_LOAD:int = 1;
		public static var REPO_ACTION_COMMIT:int = 2;
		public static var REPO_ACTION_REMOVE:int = 3;
		public static var REPO_ACTION_DIFF:int = 4;
		public static var REPO_ACTION_LOG:int = 5;
		public static var REPO_ACTION_ADD:int = 6;
		public static var REPO_ACTION_STATUS:int =7;
		public static var REPO_ACTION_REVERT:int = 8;
			
			
		
		
		private static var s_Instance:FT_RepoManager;
		private var _loadedRepos:int = 0;
		private var _numReposToLoad:int = 0;
		private var _repoXmls:XMLList = null;
		public static var REPO_ROOT_DIR:String = "remote_repos";
		private var _rootDir:File;
		private var _executingRepos:Array = new Array();
		private var _curAction:int; // current repo action
		private var _reposColl:ArrayCollection = new ArrayCollection();
		private var _pendingPlugin:ZG_PersistentObject = null // plugin that is pending to be added
		private var _startupUpdateCompleted:Boolean;
		private var _cancelStartupUpdate:Boolean;
		//-------------------------------------------
		public function FT_RepoManager(target:IEventDispatcher=null)
		{
			super(target);
			// create top level remote repos directory.
			_rootDir = ZG_FileUtils.EnsureDirectory(_rootDir,REPO_ROOT_DIR);	
		}
		//-----------------------------------------------------------
		public static function GetInstance():FT_RepoManager
		{
			if(s_Instance == null )
			{
				s_Instance = new FT_RepoManager();
			}
			return s_Instance;
		}
		
		//-------------------------------------------
		// called once startup to load existing repos
		public function StartupInit():void
		{
									
		}
		//-----------------------------------------------------
		// Kick off a repo action
		public function RepoAction(action:int, repo:FT_PluginRepository, params:Array):void
		{
			_curAction = action;
			switch(_curAction)
			{				
				case REPO_ACTION_LOAD:
				{
					if(repo == null)
					{
						LoadRepos(params == null ? false :params[0]);// whether or not to load from disk
					}
					else
					{
						UpdateRepo(repo,params);
					}
					break;
				}
				case REPO_ACTION_ADD:
					AddPlugin(repo,params);
					break;	
				case REPO_ACTION_REMOVE:
					RemovePlugin(repo,params);
					break;
				default:
					GenericAction(repo,params);
					break;
			}
		}
		//---------------------------------------------
		private function GenericAction(repo:FT_PluginRepository,fileList:Array):void
		{
			
			// a generic repo action: send a command and expect free form text output	
			// assumes that no repos are executing
			if(repo.Validate())
			{
				_executingRepos.push(repo);
				dispatchEvent(new Event(FT_Events.FT_EVT_REPO_OP_START));									
				repo.GenericAction(_curAction,fileList);
			}
			else
			{				
				DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,"Operation failed:Invalid repository");	
			}			
		}
		//---------------------------------------------
		private function LoadRepos(loadFromFS:Boolean):void
		{
			// only do it when not already in progress
			if(_executingRepos.length == 0)
			{			
				_loadedRepos = 0; // reset counters	
				_reposColl.removeAll();		
				
				_repoXmls = FT_Prefs.GetInstance().GetReposList();
				var numFailedRepos:int = 0;
				
				if(_repoXmls!=null)
				{
					_numReposToLoad = _repoXmls.length();	
					// reinitoalize because user may add or delete
					dispatchEvent(new Event(FT_Events.FT_EVT_REPO_OP_START));
					for(var i:int = 0; i <_numReposToLoad ;++i)
					{
						if(!LoadRepo(_repoXmls[i],loadFromFS))
						{
							numFailedRepos++;
						}
					}	
					// This is done to prevent the state from staying in progress
					// adjust num to load by subtracting num failed
					_numReposToLoad -=numFailedRepos;
					
					if(_numReposToLoad <=0)
					{
						// no repos can be loaded due to errors
						// send END message so UI can stop the spinner
						dispatchEvent(new Event(FT_Events.FT_EVT_REPO_OP_END));
					}
				}
				else
				{
					dispatchEvent(new Event(FT_Events.FT_EVT_REPO_OP_END));
				}
			}			
		}
		//-------------------------------------------
		private function LoadRepo(repoPrefs:XML,loadFromFS:Boolean):Boolean
		{
			var rep:Repository.FT_PluginRepository = new FT_PluginRepository(repoPrefs);
			if(rep.Validate())
			{
				_executingRepos.push(rep);
				AddRepoEventListeners(rep);			
				rep.Load(null,loadFromFS);
				return true;
			}
			return false;
		}
		//-----------------------------------------------
		// update a given repo - fileList is not used 
		// repo already has  event liste
		public function UpdateRepo(rep:FT_PluginRepository,fileList:Array):void
		{
			_loadedRepos = 0; // reset counters
			_numReposToLoad = 1;
			if(rep.Validate())
			{
				_executingRepos.push(rep);
				dispatchEvent(new Event(FT_Events.FT_EVT_REPO_OP_START));	
				DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,"Updating repository " + rep.name + "...");
				rep.Load(fileList,false);// not from fs
			}
			else
			{
				_numReposToLoad  = 0;
				DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,"Failed to update repository. Check path and URL");	
			}
		}
		//-------------------------------------------------
		private function AddRepoEventListeners(rep:FT_PluginRepository):void
		{
			rep.addEventListener(FT_Events.FT_EVT_REPO_LOADED,OnRepoAction);
			rep.addEventListener(FT_Events.FT_EVT_REPO_ACTION_END,OnRepoAction);
			rep.addEventListener(FT_Events.FT_EVT_REPO_FEEDBACK,OnRepoAction);	
			// not always needed but still
			rep.addEventListener(FT_LicenseManager.FT_EVT_LICENCE_MGR,OnLicenseManagerCheck);
		}
		//--------------------------------------------------
		protected function OnRepoAction(evt:ZG_Event):void
		{
			// on cancel _executinRepos array is cleared indicaing that there are no repos executing.
			if(_executingRepos.length > 0)
			{
				switch (evt.type)
				{
					case FT_Events.FT_EVT_REPO_LOADED:
						OnRepoLoaded(evt);
						break;
					case FT_Events.FT_EVT_REPO_ACTION_END:
						ProcessRepoAction(evt);
						break;
					case FT_Events.FT_EVT_REPO_FEEDBACK:
						//TODO: send feedback event to UI
						DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,evt.data);
						break;
				}
			}
		}
		//--------------------------------------------------
		// event.data contains a string with repo response or a list of 
		// files in case of load
		
		protected function ProcessRepoAction(evt:ZG_Event):void
		{
			// repo action ended - send event to UI
			var feedbackMsg:String = evt.data as String;
			_executingRepos.splice(0,_executingRepos.length);	
			var execResult:String = evt.xtraData == null ? FT_PluginExec.EXEC_RESULT_ERR : evt.xtraData[0];
			var curRepo:FT_PluginRepository = evt.currentTarget as FT_PluginRepository;
			
			if(_curAction == REPO_ACTION_ADD)
			{
				// repo sends these events				
				if(execResult == FT_PluginExec.EXEC_RESULT_OK)
				{
					if(_pendingPlugin!=null)
					{
						// plugin file already exists on the file system
									
						var f:File  = new File(curRepo.filePath + File.separator+_pendingPlugin.guid);
						// just in case, check if the plugin by name exists
						if(!f.exists)
						{
							f= new File(curRepo.filePath + File.separator+_pendingPlugin.name);
						}
						if(f.exists)
						{
							var newPlugin:FT_Plugin = new FT_Plugin();		
							newPlugin.url = curRepo.url;
							newPlugin.Read(f,true);							
							InsertNewPluginInUI(newPlugin,FindContainer(curRepo));
						}
						else
						{
							feedbackMsg="Failed to add Action to repository"
						}
						
					}
				}
				else
				{
					feedbackMsg = "Error adding to repository";
					_pendingPlugin=null; // so on error dirty status does not change
				}				
			}
			else if (_curAction == REPO_ACTION_REMOVE)
			{
				if(execResult == FT_PluginExec.EXEC_RESULT_OK)
				{
					RemovePluginFromUI(_pendingPlugin,FindContainer(evt.currentTarget as FT_PluginRepository));
				}
				else
				{
					feedbackMsg = "Error removing from repository";
				}
				_pendingPlugin=null;
			}
			// done using pending plugin
			if(_pendingPlugin!=null)
			{
				// this is only relevant to commit  during add, but do anyway, won't hurt
				_pendingPlugin.dirty = false;
			}
			
			if(ZG_StringUtils.IsValidString(feedbackMsg))
			{
				// there may be a feedback message there
				DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,feedbackMsg);
			}
			// notify UI that repo operation ended.
			dispatchEvent(new Event(FT_Events.FT_EVT_REPO_OP_END));
		}
		//-------------------------------------------------
		protected function InsertNewPluginInUI(newPlugin:FT_Plugin,repoContainer:FT_RepoContainer):void
		{
			// find the container for this action, insert new plugin. if category does not exist - create it
			var catContainers:ArrayCollection = repoContainer.children;
			var i:int;
			var catContainer:FT_PluginContainer = null;
			// first find the category container
			for(i = 0; i < catContainers.length;++i)
			{
				catContainer = catContainers.getItemAt(i) as FT_PluginContainer;
				if(catContainer.name == newPlugin.category)
				{
					break;
				}
			}
			if(i >=catContainers.length)
			{
				// container is not there -create
				catContainer = new FT_PluginContainer();
				catContainer.name = newPlugin.category;
				
				catContainers.addItem(catContainer);
				// apply sort to collection
				catContainers.refresh();										
			}
			if(catContainer!=null)
			{
				catContainer.AddChild(newPlugin);
				DispatchEvent(FT_Events.FT_EVT_REPO_PUGIN_ADDED,newPlugin);
			}		
		}
		//------------------------------------------------------
		protected function RemovePluginFromUI(plugin:ZG_PersistentObject,repoContainer:FT_RepoContainer):void
		{
			// find the container for this action, insert new plugin. if category does not exist - create it
			
			var catContainers:ArrayCollection = repoContainer.children;
			var i:int;
			var catContainer:FT_PluginContainer = null;
			// first find the category container
			for(i = 0; i < catContainers.length;++i)
			{
				catContainer = catContainers.getItemAt(i) as FT_PluginContainer;
				if(plugin is FT_PluginContainer)
				{
					catContainers.removeItemAt(catContainers.getItemIndex(plugin));
					break;
				}
				else
				{
					if(catContainer.name == FT_Plugin(plugin).category)
					{
						catContainer.DeleteChild(plugin);
						catContainers.refresh();
						break;
					}
				}
			}
			
			
		}
		//--------------------------------------------------
		protected function OnRepoLoaded(evt:ZG_Event):void
		{
			var i:int;
			var repo:FT_PluginRepository = evt.target as FT_PluginRepository;			
			var containers:Array = evt.data as Array;		
			// this is the update case. If container for this repo already exists - need to remove it and re-addit.
			// Maybe the number of Actions changed 
			var topCont:FT_RepoContainer = FindContainer(repo);
			if(topCont!=null)
			{
				// remove existing
				//reposColl.removeItemAt(reposColl.getItemIndex(topCont));	
				//topCont = null;
				// repo exists - remove and readd all children
				topCont.DeleteAllChildren();
			}
					
			// if license is exceeded don't actually add anything,but finish up and signal the UI that repo loading is done
			// if it is the case.
			
			if(!LicenseExceeded(containers))
			{			
				if(containers!=null)
				{
					// see if the container with this name already exists in collection
					// this may be  the case when we're doing a repo update instead of load
						
					// only add repo to ui once, on updates, just delete and re-add repo's items
					var shouldAddToUI:Boolean = (topCont == null);
					// create top container object that is repository itself if it does not exist
					if(topCont == null)
					{
						topCont = new FT_RepoContainer();
						topCont.repo = repo;
					}
					
					for(i = 0; i < containers.length;++i)
					{								
						topCont.AddChild(containers[i]);				
					}
					if(shouldAddToUI)
					{
						// now add to collection
						_reposColl.addItem(topCont);
						// now that we have it loaded, send insert event
						// all this is for compatibility anyway
						var insertObj:ZG_InsertObject = new ZG_InsertObject();
						insertObj.self = reposColl;			
						DispatchEvent(FT_Events.FT_EVT_INSERT_PLUGIN,insertObj);
					}
					// increment number of loaded repos					
				}
			}
			_loadedRepos++;
					
			// all repos finished loading. 
			if(_loadedRepos >= _numReposToLoad)
			{
				dispatchEvent(new Event(FT_Events.FT_EVT_REPO_OP_END));
				// remove the
				_executingRepos.splice(0,_executingRepos.length);
				if(!_startupUpdateCompleted)
				{
					// set the flag that is looked at by the timer in the app
					// this indicates that startup update was completed 
					_startupUpdateCompleted = true;		
				}
			}
		
		}
		//--------------------------------------------------
		public function get reposColl():ArrayCollection
		{
			return _reposColl;
		}
		//--------------------------------------------------
		public function set reposColl(value:ArrayCollection):void
		{
			_reposColl = value;
		}
		//--------------------------------------------------
		protected function OnLicenseManagerCheck(evt:ZG_Event):void
		{
			DispatchEvent(evt.type,evt.data);
		}
		//-----------------------------------------
		// check if num allowed remotes will be exceeded if an array of  plugin containers ( categories) is dded
		// This takes care of a situatiion where we have multiple repositories. Even though each repo checks num allowed plugins, the amount in one
		//repo may not exceed allowed but the sum of plugins in all repos might. In this case don't add the repo that exceeds the amount.
		protected function LicenseExceeded(newContainers:Array):Boolean
		{
			if(newContainers != null )
			{
				if(_reposColl.length > 0)
				{
					var i:int = 0;
					var k:int = 0;
					var numPlugins :int =0;
					var numAllowedPlugins:int = FT_License.LIC_NUM_UNLIMITED;
					// first count all plugins 
					for(i =0; i < newContainers.length;++i)
					{
						numPlugins+=newContainers[i].numChildren;
					}				
					// ok, now go through the current repo items 
					for(i =0; i < _reposColl.length;++i)
					{
						var curRepo:FT_RepoContainer = _reposColl.getItemAt(i) as FT_RepoContainer;
						// add up all plugins in repo
						for( k = 0; k < curRepo.numChildren;++k)
						{
							numPlugins+=curRepo.children.getItemAt(k).numChildren;
						}
						numAllowedPlugins = FT_LicenseManager.GetInstance().LicenseCheck(FT_LicenseManager.LIC_CHECK_NUM_REMOTE_PLUGINS);
						
						if(numAllowedPlugins!= FT_License.LIC_NUM_UNLIMITED  && numPlugins >numAllowedPlugins)
						{
							// license was exceeded - return true.
							DispatchEvent(FT_LicenseManager.FT_EVT_LICENCE_MGR,numPlugins);
							return true;
						}				
					}
				}
			}
			return false;
		}
		//----------------------------------------------------------------
		public function get rootDir():File
		{
			return _rootDir;
		}
		//------------------------------------------------------------
		// Cancel repo action and remove items from executing repos list
		public function CancelRepoAction():Boolean
		{			
			if(_executingRepos.length > 0 )
			{
				_pendingPlugin = null;
				
				for(var i:int = 0; i < _executingRepos.length; ++i )
				{
					_executingRepos[i].HandleUserCanceled();
				}
				_executingRepos.splice(0,_executingRepos.length);
				_loadedRepos = _numReposToLoad = 0;
				dispatchEvent(new Event(FT_Events.FT_EVT_REPO_OP_END));
				
				return true;				
			}
			return false;
		}
		
		//-------------------------------------------------
		private function FindContainer(repo:FT_PluginRepository):FT_RepoContainer
		{
			// Find a repo that belongs to a container in the container collection
			for (var i:int = 0; i <  reposColl.length;++i)
			{
				var curCont:FT_RepoContainer = _reposColl.getItemAt(i) as FT_RepoContainer;
				
				if(curCont!=null && curCont.repo == repo)
				{
					return curCont;
				}
			}
			return null;
		}
		//--------------------------------------------

		// add Action to remote repository.
		// The backend will figure out if this is an add+commit or just an update
		// this only handles a drop on 
		private function AddPlugin(repo:FT_PluginRepository,params:Array):void
		{
			var repoCont:FT_RepoContainer = FindContainer(repo);// Find container for this repo
			var destPlugin:FT_Plugin = null;
			
			if(repoCont !=null && params!=null && params.length >=2)
			{
				var parentObj:ZG_PersistentObject = params[0];
				var srcPlugin :FT_Plugin = params[1];
				destPlugin = repoCont.DeepFindChild(ZG_PersistentObject.SRCH_TYPE_GUID,srcPlugin.guid) as FT_Plugin;
				
				if(destPlugin!=null)
				{
					// action exists in the repo
					// Update it with  the local values and call repo update 
					destPlugin.Copy(srcPlugin);
					destPlugin.Write();
					_curAction = REPO_ACTION_COMMIT;						
					GenericAction(repo,new Array(destPlugin.filePath));
					DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,"Committing changes..");
				}
				else
				{
				
					destPlugin = new FT_Plugin();
					destPlugin.InitFromString(srcPlugin.ToXMLString());
					destPlugin.fileObj = new File(repo.filePath+File.separator+srcPlugin.guid);
					destPlugin.Write();						
					_curAction = REPO_ACTION_ADD;	
					GenericAction(repo,new Array(destPlugin.filePath));
					DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,"Adding " +destPlugin.name+ " to repository" );
					// create a new file and call add repo function
					// TODO:
				}	
				// save the plugin w're adding or comitting. In case of add it will be added to he UI
				// in case of commit need to clear its dirty flag
				_pendingPlugin= destPlugin;
			}
		}
		//--------------------------------------------------
		// sends remove request to repository
		private  function RemovePlugin(repo:FT_PluginRepository,params:Array):void
		{			
			_pendingPlugin=params.length>=1 ? params[0]: null;
			var paths:Array = new Array();
			
			if(_pendingPlugin!=null)
			{
				DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,"Removing item from repository..");
								
				if(_pendingPlugin is FT_Plugin)
				{
					paths.push(_pendingPlugin.filePath);
				}
				else
				{
					// it is a container - delete all items in it
					var children:Array = _pendingPlugin.GetChildrenArray();
					for(var i:int = 0; i < children.length; ++i)
					{
						paths.push(children[i].filePath);
					}
				}
				if(paths.length > 0 )
				{
					GenericAction(repo,paths);
				}
			}
			else
			{
				DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,"Error deleting: no Action selected");
			}
		}
		//----------------------------------------------------------------
		//
		public function SaveLocallyModifiedPlugin(plugin:FT_Plugin):void
		{
			plugin.Write();
			plugin.UpdateCategory(_reposColl);
		}
		//---------------------------------
		// update plugin category that may've changed after local edit or revert
		
		//-------------------------------------------
		// find th ft_pluginrepository object that this item belongs to .
		// can be container or plugin
		public function FindRepoForItem(item:ZG_PersistentObject):FT_PluginRepository
		{
			// traverse all containers and find which one the selected item belongs to 
			if(_reposColl!=null && _reposColl.length > 0)
			{
				for(var i:int = 0; i < _reposColl.length; ++i)
				{
					var curCont:FT_RepoContainer = _reposColl.getItemAt(i) as FT_RepoContainer;
					
					if(curCont!=null)
					{														
						// maybe the repo container itself was selected
						if ((curCont == item) || 
							curCont.DeepFindChild(ZG_PersistentObject.SRCH_TYPE_NAME,item.name)!=null)
						{
							return curCont.repo;
						}
					}
				}
			}
			return null;		
		}
		//-------------------------------------------
		public function RepoActionInProgress():Boolean
		{
			return _executingRepos.length > 0;
		}
		//-------------------------------------------
		public function get startupUpdateCompleted():Boolean
		{
			return _startupUpdateCompleted;
		}
		//-------------------------------------------
		public function set startupUpdateCompleted(value:Boolean):void
		{
			_startupUpdateCompleted = value;
		}
		//------------------------------------------------
		public function UpdateReposOnStartup():void
		{
			// on startup after all repos were read from disk - 
			// need to update with from remote repo
			if(_reposColl.length > 0 )
			{
				
				ZG_AppLog.GetInstance().LogIt("Updating repositories on startup..",ZG_AppLog.LOG_INFO);			
				for( var i:int = 0 ; i < _reposColl.length; ++i)
				{
					
					var curContainer:FT_RepoContainer = _reposColl.getItemAt(i) as FT_RepoContainer;
					if(curContainer != null && curContainer.repo !=null)
					{
						UpdateRepo(curContainer.repo ,null);
					}
				}
			}
		}
		// when user clicks update in UI
		//-------------------------------------------
		public function get cancelStartupUpdate():Boolean
		{
			return _cancelStartupUpdate;
		}
		//-------------------------------------------
		public function set cancelStartupUpdate(value:Boolean):void
		{
			_cancelStartupUpdate = value;
		}

		
	} // class
}
