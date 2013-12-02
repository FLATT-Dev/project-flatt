/*******************************************************************************
 * FT_PluginRepository.as
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
	/* This class handles remote plugin repository.
	   It reads repository listing and adds plugins and tasks to display list
	*/
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
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.IEventDispatcher;
	import flash.filesystem.*;
	import flash.net.*;
	

	public class FT_PluginRepository extends ZG_EventDispatcher
	{
		
		/* These must match the server side */
		public static var REPO_REQ_UNDEFINED: int  = 0;
		public static var REPO_REQ_CHECKOUT:int  = 1;
		public static var REPO_REQ_UPDATE: int  = 2;
		public static var REPO_REQ_STATUS: int  = 3;
		public static var REPO_REQ_DIFF: int  = 4;
		public static var REPO_REQ_LOG: int  = 5;
		public static var REPO_REQ_COMMIT:  int  = 6;
		public static var REPO_REQ_ADD: int  = 7;
		public static var REPO_REQ_DELETE:int = 8;
		public static var REPO_REQ_REVERT:int = 9;		
		
		private var _requestParams: FT_RepoRequestParams;
		private var _execRequest:FT_ExecRequest;

		//public static var EVT_REPO_LOADED:String ="evtRepoLoaded";
		//private var _url:String = "";
		//private var _rootUrl:String=""
		private var _prefsXml:XML;
		
		public var TAG_REPO_TOP:String = "tree";
		public var TAG_REPO_CONTAINER:String = "container";
		public var TAG_REPO_PLUGIN:String = "plugin";
		
		private var _rootDir:File;
		private var _name:String; // repo name which is the top level directory and also is the repo address without path or http
		
		// the location of the post servlet is hard coded for now. Maybe later derive 
		public static var UPLOAD_SERVLET_URL:String = "/FlattServer/FTRepoServlet";
		public static var PLUGIN_UPLOAD_FAIL:String = "Failed to upload plugin: ";
		
		public function FT_PluginRepository(prefsXml:XML)
		{
			_prefsXml = prefsXml;
			
		}
		//---------------------------------------
		public function Validate():Boolean
		{
			var ret:Boolean = ZG_URLValidator.ValidUrl(_prefsXml.@url);
			if(ret)
			{
				try
				{						
					if(_rootDir==null)
					{											
						var rootPath:String = FT_RepoManager.GetInstance().rootDir.nativePath + 
											  File.separator +
											  ZG_URLValidator.HostAddressFromUrl(_prefsXml.@url);
						_rootDir =  new File(rootPath);
					}						
				}
				catch(e:Error)
				{
					ret = false;
					
				}
			}
			return ret;
		}
		//-------------------------------
		// this either checks out a full repository
		// or does an update of full repo or a directory or file list that was provided
		// validation is done by the caller
		// Optionally loads repo from disk
		public function Load(fileList:Array,loadFromFS:Boolean):void
		{						
			if(loadFromFS)
			{
				LoadFromFS();
			}
			else
			{
				LoadFromNetwork(fileList);
			}							
		}
		//-------------------------------------
		protected function LoadFromNetwork(fileList:Array):void
		{
			var reqType:int = REPO_REQ_UPDATE;
			// reinitialze variables
			Init();			
			// don't attempt to load a repo if it could not be validated			
			if(!_rootDir.exists)
			{
				// garbage collector should do the right thing
				reqType = REPO_REQ_CHECKOUT;
				_rootDir = ZG_FileUtils.EnsureDirectory(_rootDir,_rootDir.nativePath);
			}
			
			// common prefs values i. url, passwd etc are initialized in Init function
			
			_requestParams.reqType = reqType;
			_requestParams.fileList = fileList;
			SendRequest();					
		}
		//---------------------------------------------
		public function GenericAction(action:int, fileList:Array):void
		{
			
			Init(); // reinitialize some svariables
			var reqType:int = ReqTypeFromAction(action);
			
			_requestParams.reqType = reqType;			
			_requestParams.fileList = fileList;
			SendRequest();
			
			
		}
		//--------------------------------------------------
		private function SendRequest():void
		{
			var repoExec:FT_RepoExec = _execRequest.PrepareRequest(null,
																 null,
																 FT_ExecRequest.REQTYPE_REPO,																
																 null,
																 new Array(_requestParams)) as FT_RepoExec;
			
			repoExec.addEventListener(FT_Events.FT_EVT_REPO_ACTION_END, OnRepoEvent);
			repoExec.addEventListener(FT_Events.FT_EVT_REPO_FEEDBACK,OnRepoEvent);
		}
		//-----------------------------------------------------
		protected function ReqTypeFromAction(action:int):int
		{
			// map repo manager request type to repo req type
			var ret:int = REPO_REQ_UNDEFINED;
			switch(action)
			{
				
				case FT_RepoManager.REPO_ACTION_COMMIT:
					ret =  REPO_REQ_COMMIT;
					break;
				case FT_RepoManager.REPO_ACTION_DIFF:
					ret =  REPO_REQ_DIFF;
					break;
				case FT_RepoManager.REPO_ACTION_LOG:
					ret =  REPO_REQ_LOG;
					break;
				case FT_RepoManager.REPO_ACTION_ADD:
					ret = REPO_REQ_ADD;
					break;
				case FT_RepoManager.REPO_ACTION_STATUS:
					ret = REPO_REQ_STATUS;
					break;
				case FT_RepoManager.REPO_ACTION_REMOVE:
					ret = REPO_REQ_DELETE;
					break;
				case FT_RepoManager.REPO_ACTION_REVERT:
					ret = REPO_REQ_REVERT;
					break;
				
			}
			return ret;
		}
		//-----------------------------------------------------
		private function Init():void
		{
			
			_requestParams = null;	// clear old values from previous run
			_execRequest  = null;
						
			_requestParams = new FT_RepoRequestParams();
			_execRequest = 	new FT_ExecRequest();
			_execRequest.useLocalConnection = true; // tell exec request to use local proxy 	
			// set common values of the request params object
			_requestParams.rootDirPath = _rootDir.nativePath;
			_requestParams.username = _prefsXml.@username;
			_requestParams.password = _prefsXml.@password;
			_requestParams.url = _prefsXml.@url;	
			// TODO: get checkin message from user, for now just send username
			//_requestParams.checkinMessage = 
		}
		//-----------------------------------------------
		private function OnRepoEvent(evt:ZG_Event):void
		{
			
			switch(evt.type)
			{
				case FT_Events.FT_EVT_REPO_FEEDBACK:
					//pass on to the repo manager
					
					DispatchEvent(FT_Events.FT_EVT_REPO_FEEDBACK,evt.data);					
					break;
				case FT_Events.FT_EVT_REPO_ACTION_END:
					ProcessRepoAction(evt.data as FT_RepoExec);
					break;						
			}
		}
		
		
		//----------------------------------------------
		private function ProcessRepoAction(repoExec:FT_RepoExec):void
		{
			
			if(repoExec!=null)
			{
				
				switch(repoExec.state)
				{
					case FT_PluginExec.STATE_CONNECTING:
					case FT_PluginExec.STATE_EXECUTING:
					case FT_PluginExec.STATE_RECEIVING_DATA:
						//TODO
						break;
					case FT_PluginExec.STATE_DONE:	
					case FT_PluginExec.STATE_USER_CANCELED:					
						ProcessRepoResult(repoExec);					
						break;
						//TODO: maybe send feedback to UI on that - may be n
				}
			}
		}		
		//------------------------------------------
		// process the results of repo operation
		private function ProcessRepoResult(repoExec:FT_RepoExec):void
		{
			var feedbackMsg:String = "";
			var sendRepoLoadedMsg:Boolean = false;
			var containers:Array = null;
			
			try
			{
				var repoXml:XML = new XML(repoExec.returnData);
				var repoData:String = ZG_StringUtils.Base64Decode(repoXml.RepoData);
				var repoResult:Number = new Number(repoXml.@result);
				
					// operation succeeded
					switch(_requestParams.reqType)
					{
						case REPO_REQ_CHECKOUT:
						case REPO_REQ_UPDATE:
						{	
							// if repo result is an error - don't bother to look for containers
							if(repoResult == 0)
							{
								feedbackMsg = repoData;
								DispatchEvent( FT_Events.FT_EVT_REPO_FEEDBACK,feedbackMsg);
							}
							else
							{
								containers = HandleCheckoutOrUpdate(ParseItemsList(repoData));	
							}
							// Always dispatch repo loaded event 
							// It is sent to the UI as repo_op_end event to stop the spinner
							
							DispatchEvent(FT_Events.FT_EVT_REPO_LOADED,containers);
							break;
						}
					    default:
							// in all other cases we just display the repo console output
							// Also pass the exec result that may be needed by the repo manager
							DispatchEvent(FT_Events.FT_EVT_REPO_ACTION_END,repoData,new Array(repoExec.execResult));
							break;
					}
			}
		
			catch(e:Error)
			{
				trace("exception in ProcessRepoResult: "+e.message);
				feedbackMsg = ("Error: Failed to parse Repository response");
			}
			if(feedbackMsg.length > 0)
			{
				DispatchEvent( FT_Events.FT_EVT_REPO_FEEDBACK,feedbackMsg);
			}
			
			
			
		}
		
		//----------------------------------------------
		// repo items come from the backend as a newline separated list of full local paths
		private function ParseItemsList(repoData:String):Array
		{
			var ret:Array = new Array();			
			if(repoData!=null && repoData.length > 0)
			{
				ret = repoData.split('\n');
			}						
			return ret;
		}
			
		/*	
			// save the root url of the repository.
			SaveRootUrl();
			var loader:URLLoader = new URLLoader();
			configureLoadListeners(loader);
			
			var request:URLRequest = new URLRequest(url);
		
			try 
			{
				loader.load(request);
			} 
			catch (error:Error) 
			{
				trace("Unable to load requested document.");
			}		
		}
		//-------------------------------
		private function configureLoadListeners(dispatcher:IEventDispatcher):void 
		{
			dispatcher.addEventListener(Event.COMPLETE, completeLoadHandler);
			dispatcher.addEventListener(Event.OPEN, openLoadHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressLoadHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityLoadErrorHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusLoadHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorLoadHandler);
		}
		//-------------------------------
		private function completeLoadHandler(event:Event):void 
		{
			var loader:URLLoader = URLLoader(event.target);
			//trace("completeHandler: " + loader.data);	
			ParseRepositoryXml(loader.data);
		}
		//-------------------------------
		private function openLoadHandler(event:Event):void 
		{
			//trace("openHandler: " + event);
		}
		//-------------------------------
		private function progressLoadHandler(event:ProgressEvent):void 
		{
			trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
		}
		//-------------------------------
		private function securityLoadErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
		}
		
		private function httpStatusLoadHandler(event:HTTPStatusEvent):void 
		{
			//trace("httpStatusHandler: " + event);
		}
		//-------------------------------
		private function ioErrorLoadHandler(event:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + event);
		}
		
		//------------------------------------------
		private function ParseRepositoryXml(data:String):void
		{
			trace("FTPPluginRepository:ParseRepositoryXml");
			_xmlData = null;
			_xmlData = new XML(data);
			if( VerifyXml())		
			{
			 	//this.DispatchEvent(EVT_REPO_LOADED,this);
				ProcessRepoItems(GetRepositoryItems());
			}
			else
			{
				_xmlData = null;
				trace("FTPPluginRepository:Failed to parse repo xml");
			}
		}
		//--------------------------------------------------
		// TODO: more extensive checks
		private function VerifyXml():Boolean
		{
			return((_xmlData !=null) && (_xmlData.name() == TAG_REPO_TOP));
		}
		//--------------------------------------------------
		private function ParsePlugins(xml:XML):void
		{
			var pluginsList:XMLList = xml.item ;
			if( pluginsList!=null)
			{
				for(var i:int =0; i < pluginsList.length();++i)
				{								
					var plugin:FT_Plugin = new FT_Plugin();
					var xml:XML = pluginsList[i];
					if(xml.@type == TAG_REPO_CONTAINER)
					{					
						if(plugin.InitFromXMLObj(xml))
						{
							
							// plugin url is built as follows
							// repository url/<plugin category>/plugin guid.xml
							plugin.url = _rootUrl+"/"+plugin.category+"/"+plugin.guid+".xml"; 
								
							// In the future    allow local changes, 
							// TODO: UI to indicate a remote plugin was changed locall
							// UI to push changes back to the remote location
							
							// TODO: save in a list and later load in window when necessary
							//FT_PluginManager.GetInstance().InsertInUI(plugin, FT_Events.FT_EVT_INSERT_PLUGIN);
						}
						else
						{
							plugin = null;
							//TODO: record failure
						}
					}
				}
			}					
		}
		//--------------------------------------------------
		// see flattrepo.xml for description of format
		public function GetRepositoryItems():Array
		{
			var containers:XMLList = _xmlData.item.item;
			var containersArray:Array = new Array();
			
			if( containers!=null)
			{
				for(var i:int =0; i < containers.length();++i)
				{								
					// assumes 1 level deep tree
					if(containers[i].@type == TAG_REPO_CONTAINER)
					{
						containersArray.push(containers[i]);
					}										
				}
			}
			return RepoItemsFromContainers(containersArray);
		}
		//--------------------------------------------------
		// iterate each container in list and 
		public function RepoItemsFromContainers(containers:Array):Array
		{
			var ret:Array = new Array();
			for(var i:int =0; i < containers.length;++i)
			{
				var itemsList:XMLList = containers[i].item;
				var containerCat :String = containers[i].@text;
				// now add all items 
				for(var k:int = 0; k < itemsList.length();++k)
				{
					var repoItem:FT_RepositoryItem  = new FT_RepositoryItem(itemsList[k]);
					
					repoItem.rootUrl = _rootUrl;
					repoItem.category = containerCat;
					ret.push(repoItem);
				}
			}
			return ret;
		}
		
	*/	
		//-------------------------------------------
		//  this is where we create plugins from repo items and possibly save them to cache
		//------------------------------------------
		private function HandleCheckoutOrUpdate(items:Array):Array
		{
			var allPlugins:Array = new Array();
			var containers:Array = null;
			// check license directly and send an event if it exceeds the limit
			var allowedCount:int = FT_LicenseManager.GetInstance().LicenseCheck(FT_LicenseManager.LIC_CHECK_NUM_REMOTE_PLUGINS);
			
			// if license is unlimited or we have less items than allowed
			if(allowedCount == FT_License.LIC_NUM_UNLIMITED || items.length < allowedCount)
			{
				allowedCount = items.length;
			}
			else 
			{
				// send an event to tell the user that count of remote plugins is trimmed
				DispatchEvent(FT_LicenseManager.FT_EVT_LICENCE_MGR,allowedCount);				
			}
			// create plugins from repo items
			for ( var i:int = 0; i < allowedCount;++i)
			{			
				try 
				{
					var plugin:FT_Plugin = new FT_Plugin();
					plugin.url = this._prefsXml.@url;
					var path:String = items[i];
					// make sure the string is not empty
					if(path.length > 0)
					{
						var pluginFile:File = new File (items[i]);
						plugin.Read(pluginFile,true);
						if(plugin.IsValid())
						{
							
							allPlugins.push(plugin);
						}
						else
						{
							DispatchEvent( FT_Events.FT_EVT_REPO_FEEDBACK,
								"Omitting Action " + pluginFile.name + " : Malformed XML");
						}
					}
				}
				catch(e:Error)
				{
					trace ("HandleCheckoutOrUpdate: Invalid file path: " + items[i]);
				}				
			}
			
			// organize thems. Even if we don't have any containers , i.e the repo is empty,
			// still need to go through the process so the repo container object is 
			// created by the Repo manager
			var pluginOrganizer:FT_PluginOrganizer = new FT_PluginOrganizer();	
			containers = pluginOrganizer.OrganizePlugins(allPlugins,this.filePath);
			containers.sortOn("name");
			
			return containers;
		}
		
		public function UploadPlugin(plugin:FT_Plugin):void
		{
			//TODO: check in or update existing 
		}
		//------------------------------------------
		/*private function ProcessRepoItem(item:FT_RepositoryItem):void
		{
			//TODO: Determine if the item is in the cache. If so, check its version
			// if the version in repo is newer - update the cache, otherwise
			if(item!=null)
			{
				// for now just create a new plugin and insert it in UI
				if(!LoadPluginFromCache(item))
				{
					//DownloadPlugin(item);
					var plugin:FT_Plugin = new FT_Plugin();
					plugin.InitFromRepoItem(item);
				}			
			}
		}*/
		//---------------------------------------
		/* TODO:
		* Read the plugin from cache 
		* If it is there, handle synchronization ( rev num , local changes, etc )
		* Otherwise return false, so the plugin can be loaded from server
		* 
		private function LoadPluginFromCache(item:FT_RepositoryItem):Boolean
		{
			// for now always return false
			return false;
		}
		//---------------------------------------
		private function DownloadPlugin(plugin:FT_Plugin):void
		{
			
			var loader:FT_UrlLoader = new FT_UrlLoader();			
			loader.recipient = plugin;
			configuredownloadPluginListeners(loader);
			
			var request:URLRequest = new URLRequest(plugin.url);
			
			try 
			{
				loader.load(request);
			} 
			catch (error:Error) 
			{
				trace("Unable to load requested document.");
			}		
		}
		//-------------------------------
		private function configuredownloadPluginListeners(dispatcher:IEventDispatcher):void 
		{
			dispatcher.addEventListener(Event.COMPLETE, completeDownloadPluginHandler);
			dispatcher.addEventListener(Event.OPEN, openDownloadPluginHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressDownloadPluginHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorDownloadPluginHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusDownloadPluginHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorDownloadPluginHandler);
		}
		//-------------------------------
		private function completeDownloadPluginHandler(event:Event):void 
		{
			var loader:FT_UrlLoader = FT_UrlLoader(event.target);
			//trace("completeHandler: " + loader.data);	
			var plugin:FT_Plugin = loader.recipient as FT_Plugin;
			if(plugin!=null)
			{
				plugin.InitFromString(loader.data);
				if(plugin.IsValid())
				{
					//FT_PluginManager.GetInstance().InsertInUI(plugin, FT_Events.FT_EVT_INSERT_PLUGIN);
				}			
				else
				{
					ZG_AppLog.GetInstance().LogIt("Failed to load plugin from server",ZG_AppLog.LOG_ERR);
				}
			}
			else
			{
				trace("plugin is null in FT_RepoManager.completeHandler!");
			}
		}
		//-------------------------------
		private function openDownloadPluginHandler(event:Event):void 
		{
			trace("openHandler: " + event);
		}
		//-------------------------------
		private function progressDownloadPluginHandler(event:ProgressEvent):void 
		{
			trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
		}
		//-------------------------------
		private function securityErrorDownloadPluginHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
		}
		
		private function httpStatusDownloadPluginHandler(event:HTTPStatusEvent):void 
		{
			trace("httpStatusHandler: " + event);
		}
		//-------------------------------
		private function ioErrorDownloadPluginHandler(event:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + event);
		}
		//--------------------------------------------------
		public function get pluginRoot():String
		{
			return (_xmlData == null ? "": _xmlData.@_pluginRoot);
		}
		
		//--------------------------------------------------
		public function get taskRoot():String
		{
			return (_xmlData == null ? "": _xmlData.@taskRoot);
		}
		
		//--------------------------------------------------
		public function get url():String
		{
			return _url;
		}
		//--------------------------------------------------
		public function set url(value:String):void
		{
			_url = value;
		}*/
		//--------------------------------------------------
		// save the root url of the repository.This assumes that the top level of repostory contains its xml and category folders
		// are at the same level. Strip the last url component
		/*private function SaveRootUrl():void
		{
			rootUrl = _url.substring(0,_url.lastIndexOf("/"));
		}
		//-------------------------------------------------
		public function UploadPlugin(plugin:FT_Plugin):void
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.data = plugin.ToXMLString();
			urlLoader.addEventListener(Event.COMPLETE,OnPluginUpload);			
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrUploadHandler);			
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorUploadHandler);
			
			// this routine removes http://, so add back
			var servletUrl:String = "http://"+ ZG_URLValidator.HostAddressFromUrl(rootUrl)+UPLOAD_SERVLET_URL;
			
			var request:URLRequest = new URLRequest(servletUrl);
			request.method = URLRequestMethod.POST
			request.contentType = "multipart/form-data";
			request.data = urlLoader.data;
			//request.requestHeaders = new Array(new URLRequestHeader("toto", "toto"));
			
			urlLoader.load(request);
		}
		//---------------------------------------------------
		protected function OnPluginUpload(evt:Event):void
		{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			if(loader!= null)
			{
				trace("On Plugin upload");
				DispatchEvent(FT_Events.FT_EVT_PLUGIN_UPLOADED,loader.data,new Array(ZG_Strings.STR_SUCCESS));
			}
			
		}
		private function securityErrUploadHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
			DispatchEvent(FT_Events.FT_EVT_PLUGIN_UPLOADED,PLUGIN_UPLOAD_FAIL + event.text,new Array(ZG_Strings.STR_ERROR));
			
		}				
		//-------------------------------
		private function ioErrorUploadHandler(event:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + event);
			DispatchEvent(FT_Events.FT_EVT_PLUGIN_UPLOADED,PLUGIN_UPLOAD_FAIL + event.text,new Array(ZG_Strings.STR_ERROR));
		}
		//--------------------------------------------------
		{
			return _rootUrl;
		}
		//--------------------------------------------------
		public function set rootUrl(value:String):void
		{
			_rootUrl = value;
		}*/

		public function get name():String
		{
			return (_rootDir == null  ? "" : _rootDir.name);
			//return (_prefsXml == null ? "" : _prefsXml.);
		}
		//--------------------------------------------------
		public function get execRequest():FT_ExecRequest
		{
			return _execRequest;
		}
		//--------------------------------------------------
		public function set execRequest(value:FT_ExecRequest):void
		{
			_execRequest = value;
		}
		//--------------------------------------------------
		public function HandleUserCanceled():void
		{
			if(_execRequest !=null)
			{
				_execRequest.HandleUserCanceled();
			}
		}
		//--------------------------------------------------
		// return repo url
		public function get url():String
		{
			return (_prefsXml == null? "" : _prefsXml.@url);
		}
		//--------------------------------------------------
		public function get prefsXml():XML
		{
			return _prefsXml;
		}
		//--------------------------------------------------
		public function set prefsXml(value:XML):void
		{
			_prefsXml = value;
		}
		//-----------------------------------------------
		public function get filePath():String
		{
			return (_rootDir == null ? "" : _rootDir.nativePath);
		}
		//-----------------------------------------------
		// on startup read the repo from file system
		public function LoadFromFS():void
		{
			if(_rootDir!=null && _rootDir.exists)
			{
				var fileList:Array = new ZG_FileUtils().IterateDirectory(_rootDir,1);// traverse directory , nesting level
				if(fileList != null )
				{			
					DispatchEvent(FT_Events.FT_EVT_REPO_LOADED,HandleCheckoutOrUpdate(fileList));
				}
			}
		}
	}// class end
}	//pkg end
