package DesktopApp
{
	import Application.*;
	
	import CustomControls.*;
	
	import FLATTPlugin.*;
	
	import HostConfiguration.*;
	import Scheduling.*;
	
	import Network.*;
	
	import Repository.*;
	
	import TargetHostManagement.FT_TargetHost;
	
	import Utility.*;
	
	import com.ZG.Logging.*;
	import com.ZG.Utility.*;
	
	import flash.desktop.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.controls.SWFLoader;
	import mx.events.*;
	import mx.managers.*;
	
	import spark.components.Application;
	
	public class FT_DesktopApplication extends FT_Application
	{
		//cvs from work
		private static const  PROXY_PORT_NUM_FILE:String = "jsshproxyport.txt";
		//private static const TRIAL_EXPIRATION_TIME:Number = 1335945600000; //05-02-2012 8:00:00 AM in milliseconds.
		private var _jarHandler:FT_JarHandler = new FT_JarHandler();
		private var _invalidProxyPortMsgDisplayed:Boolean;
		private var _svnStartupTimer:Timer;
		
		// all embedded things
		[Bindable]
		[Embed(source="assets/host-22.png")] 
		public static var ICON_HOST:Class; 
		[Bindable]
		[Embed(source="assets/hostgrp-22.png")] 
		public static var ICON_GRP:Class; 
		
		[Bindable]
		[Embed(source="assets/action-22.png")] 
		public static var ICON_PLUGIN:Class; 
		
		[Bindable]
		[Embed(source="assets/task-22.png")] 
		public static var ICON_TASK:Class; 
		
		[Bindable]
		[Embed(source="assets/config-file-22.png")] 
		public static var ICON_HOSTCONFIG:Class; 
		
		[Bindable]
		[Embed(source="assets/host-with-config-22.png")] 
		public static var ICON_SINGLE_HOST_CONFIG:Class; 
		
		[Bindable]
		[Embed(source="assets/grp-with-config-22.png")] 
		public static var ICON_GRP_HOST_CONFIG:Class; 
		
		[Bindable]
		[Embed(source="assets/remove-16.png")] 
		public static var ICON_REMOVE_16:Class; 
		
		[Bindable]
		[Embed(source="assets/repo-22.png")] 
		public static var ICON_REPO:Class; 
		
		[Bindable]
		[Embed(source="assets/action_cat-22.png")] 
		public static var ICON_ACTION_CATEGORY:Class; 
		
		[Bindable]
		[Embed(source="assets/scripts-22.png")] 
		public static var ICON_SCRIPTS_FLDR:Class; 
	
		
		/*[Bindable]
		[Embed(source="assets/plus-circle-green-24.png")] 
		public static var ICON_PLUS_GREEN:Class; 
		
		[Bindable]
		[Embed(source="assets/minus-circle-green-24.png")] 
		public static var ICON_MINUS_GREEN:Class; */
		
		
		//============================================
		public function FT_DesktopApplication(target:IEventDispatcher=null)
		{
			super(target);
			
			
			/*_swfLoader= new SWFLoader();			
			_swfLoader.source="Assets/NativeAppLauncher.swf";			
			_swfLoader.addEventListener(Event.INIT, OnSwfLoaded);
			_swfLoader.addEventListener(IOErrorEvent.IO_ERROR,OnLoadError);
			_swfLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSecurityError);
			*/	
		}
		
		//-----------------------------------
		// Do specific initialization
		override public function Initialize():void
		{
			super.Initialize();
			//_proxyLauncher.StartSshProxy();		
			ConfigureProxy();
			ConfigureSvn();
			StartSvnUpdateTimer();
			
			// Registration manager is functional but disabled for now. 
			// Hard coded value of 5-2-2012 will end quit the app on launch
			//FT_RegistrationManager.GetInstance().addEventListener(FT_Events.FT_TRIAL_EXPIRED, OnTrialExpired);
		}
		
		//-------------------------------------
		// look in the temp directory for the port number in temp file
		// so silly.. you can create a file in temp dir but cannot get temp dir path
		override protected function DiscoverSSHProxyPort():int
		{
						
			var ret:int = FT_Application.INVALID_PORT;
			
			var nativePath:String = GetTempDirPath()+ PROXY_PORT_NUM_FILE;
			
			var strPort:String  = ZG_FileUtils.ReadFile(new File(nativePath),true ) as String;
			if(strPort !=null && strPort !="")
			{
				ret =  ZG_StringUtils.StringToNumEx(strPort);
			}
			/* TODO: Move where the plugin executes, or write to log */
			if(ret == FT_Application.INVALID_PORT)
			{
				
				if(!_invalidProxyPortMsgDisplayed)
				{
					//Alert.show("Cannot determine SSH proxy server port. You will not be able to execute Actions.\n","Error");
					_invalidProxyPortMsgDisplayed = true;
				}
				ZG_AppLog.GetInstance().LogIt("Cannot determine SSH proxy port, looked in " + nativePath,ZG_AppLog.LOG_ERR);
						  
			}
			return ret;
		}
		//------------------------------------
		// generic routine to get an icon for an object
		override public  function GetIconForObject(obj:Object):Class
		{
			if( obj is FT_TargetHost)
			{
				if(!ZG_StringUtils.IsValidString(obj.hostConfigID))
				{
					return ( FT_TargetHost(obj).isContainer ? ICON_GRP : ICON_HOST);
				}
				else
				{
					return (FT_TargetHost(obj).isContainer ? ICON_GRP_HOST_CONFIG :ICON_SINGLE_HOST_CONFIG);
				}
			}
			if( obj is FT_Plugin )
			{
				return ICON_PLUGIN
			}
			if (obj is FT_HostConfig)
			{
				return ICON_HOSTCONFIG;
			}
			if( obj is FT_RepoContainer)
			{
				return  ICON_REPO;
			}
			if( obj is FT_PluginContainer)
			{
				return ICON_ACTION_CATEGORY;
			}
				
			return null;
		}
		//------------------------------------------
		override public function Cleanup():void
		{
			// if the proxy never started for some reason -quit right away
			// proxy port is only set when a connection is made but the proxy may be running
			// so make sure to check the proxy
			// make sure the invalid message is not displayed
			//if(sshProxyPort == INVALID_PORT )
			if(!_jarHandler.localProxyRunning)			
			{
				QuitApp();
			}
			else
			{
				var proxyQuitter:FT_ProxyQuitter = new FT_ProxyQuitter();
				proxyQuitter.quitApp = true;
				// if the server does not respond in 5 seconds - shut down 			
				proxyQuitter.QuitProxy();
			}
					
		}
		//-----------------------------------
		override public function QuitApp():void
		{
			NativeApplication.nativeApplication.exit(0);
		}
		//-----------------------------------
		/*override public function TrialExpired():Boolean
		{
			var curDate:Date = new Date();
			if( curDate.time >= TRIAL_EXPIRATION_TIME )
			{				
				return true;
			}
			return false;
			
		}*/
		public function GetProxyLogPath():String
		{
			//return ((_proxyLauncher!=null)? _proxyLauncher.logPath: "");
			return GetTempDirPath()+FT_JarHandler.PROXY_LOG_NAME;
		
		}
		//----------------------------------------------------------
		// Determine where the temp path is depending on the OS
		// On windows both java (server) and flex air ( app) use the same temp path
		// On mac it's different, so the app cannot find the proxy port
		// return system specific temp dir path
		// for mac ( and linux ? )  just return /tmp
		
		private function GetTempDirPath():String
		{						
			
			if((Capabilities.os.indexOf("Windows") >= 0))
			{
				return GetTempDirPath_Win();
			}
			else if((Capabilities.os.indexOf("Mac") >= 0))
			{
				return GetTempDirPath_Mac();
			} 
			else if((Capabilities.os.indexOf("Linux") >= 0))
			{
				return GetTempDirPath_Linux();
			}
			return "";
		}
		// on windows temp directory is the same for java environment and flex,
		private function GetTempDirPath_Win():String
		{
			return GetTempDirPath_Common();
		}
		// 
		private function GetTempDirPath_Common():String
		{
			var nativePath:String = "";
			var f:File = File.createTempFile();
			nativePath = f.parent.nativePath + File.separator;// + PROXY_PORT_NUM_FILE;
			// only needed to discover system  temp directory
			f.deleteFile();
			return nativePath;
		}
		//-------------------------
		// on the Mac it's in the common temp directory/TemporaryItems folder for whatever reason
		// GRR
		
		private function GetTempDirPath_Mac():String
		{
			var path :String = GetTempDirPath_Common();
			var pos:int = path.indexOf("/TemporaryItems");
			if(pos > 0)
			{
				path = path.substr(0,pos+1);//copy the slash
			}
			return path;
			
		}
		//-------------------------
		private function GetTempDirPath_Linux():String
		{
			return GetTempDirPath_Common(); //TODO: handle whatever idosyncrasies exist
		}
		//----------------------------------------
		// if this is universal - move to parent class
		// use the same versioning scheme for both client and server.
		// Make sure to update on every build.
		override public function GetVersionString():String
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			var appVersion:String = appXml.ns::versionNumber[0];
			return appVersion;
		}
		
		//----------------------------------------
		private function OnTrialExpired(e:Event):void
		{
			trace("trial expired!");
			Cleanup();
			QuitApp();
		}
		//---------------------------------------------
		// Configure which proxy to use.
		// Handle various errors
		override public function ConfigureProxy():void
		{
			var proxyType:int = FT_Prefs.GetInstance().GetProxyType();
			// always launch local proxy so remote repo can work
			if(!_jarHandler.localProxyRunning)
			{
				_jarHandler.StartSshProxy();	
			}
			switch(proxyType)
			{
				/*case FT_Prefs.PROXY_TYPE_INTERNAL:
					if(!_proxyLauncher.localProxyRunning)
					{
						_proxyLauncher.StartSshProxy();	
						//DiscoverSSHProxyPort();
					}
					break;*/
				
				//case FT_Prefs.PROXY_TYPE_TOMCAT:
				case FT_Prefs.PROXY_TYPE_STANDALONE_SSL:
					
					// Internal proxy always runs once started 
					// first quit local proxy if it is running
					/*if(_sshProxyPort !=INVALID_PORT)
					{
						var proxyQuitter:FT_ProxyQuitter = new FT_ProxyQuitter();
						// if the server does not respond in 5 seconds - shut down 			
						proxyQuitter.QuitProxy();
						_sshProxyPort = INVALID_PORT;
					}*/
					
					if(!ValidateProxy())
					{
						var preamble:String = (proxyType == FT_Prefs.PROXY_TYPE_TOMCAT? "Proxy URL ":
												"Proxy address or port");
						
						Alert.show(ZG_Utils.TranslateString(preamble + " is invalid. You will not be able" +
														    " to execute Actions or Tasks in environments that require a bastion or a jump box server.\n"),
															"Error");
					}
					
					break;
					
			}
		}
		
		//------------------------------------------------
		override public function ValidateProxy():Boolean
		{
			 var ret:Boolean = false;
			
			switch(FT_Prefs.GetInstance().GetProxyType())
			{
				case FT_Prefs.PROXY_TYPE_INTERNAL:
					//ret = _sshProxyPort!=INVALID_PORT;
					ret = GetlocalProxyPort()!=INVALID_PORT;
					break;
				
				/*case FT_Prefs.PROXY_TYPE_TOMCAT:									
					ret = (ZG_URLValidator.ValidUrl(FT_Prefs.GetInstance().GetProxyUrl()));					
					break;
				*/
				case FT_Prefs.PROXY_TYPE_STANDALONE_SSL:
					ret = (ZG_URLValidator.ValidAddress(FT_Prefs.GetInstance().GetProxyAddress()) &&
						  	FT_Prefs.GetInstance().GetProxyPort() > 0)
					break;
				
			}
			return ret;
		}
		//-------------------------------------------
		private function ConfigureSvn():void
		{
			if(!_jarHandler.EnsureSvnClient())
			{
				ZG_AppLog.GetInstance().LogIt("Error preparing svn client application. Remote repository will not be available",ZG_AppLog.LOG_ERR);	
			}
		}
		//---------------------------------
		private function StartSvnUpdateTimer():void			
		{
			if(_svnStartupTimer == null )
			{
				_svnStartupTimer = new Timer(10000,1);// 10 sec , repeat once
				_svnStartupTimer.addEventListener(TimerEvent.TIMER, OnSvnUpdateTimer);
			}
			_svnStartupTimer.reset();
			_svnStartupTimer.start();
		}
		//-----------------------------------------------------
		// if repo action in progress - defer
		private function OnSvnUpdateTimer(event:TimerEvent):void
		{
			
			// first check if user clicked update manually and we need to cancel all this
			if(FT_RepoManager.GetInstance().cancelStartupUpdate)
			{
				CleanupSvnTimer();
			}
			else
			{
			
				if(FT_RepoManager.GetInstance().RepoActionInProgress() || 
				  !FT_RepoManager.GetInstance().startupUpdateCompleted)
				{
					StartSvnUpdateTimer();
				}
				else
				{
					FT_RepoManager.GetInstance().UpdateReposOnStartup();
					CleanupSvnTimer();
					
				}
			}
		}
		//-------------------------------------------
		private function CleanupSvnTimer():void
		{
			if(_svnStartupTimer!=null)
			{
				_svnStartupTimer.stop();
				_svnStartupTimer.removeEventListener(TimerEvent.TIMER, OnSvnUpdateTimer);
				_svnStartupTimer = null;
			}
			
		}
		
		/*
		private function LoadNativeAppLauncher():void
		{
			_swfLoader.load();
		}
		//-----------------------------------
		private function OnSwfLoaded(event:Event):void 
		{
			//var content:DisplayObject = _swfLoader.content;
			// Or if you don't have the loader:
			// content = event.target.content;
			// add loaded SWF to a UIComponent to show it on the screen
			//uicomponent.addChild(content);
			var sysmgr:SystemManager = (event.target.content as SystemManager);
			// must wait for the swf application to finish loading
			// otherwise the application is null
			sysmgr.addEventListener(FlexEvent.APPLICATION_COMPLETE, OnSwfLoadComplete); 
		}
		//-----------------------------------
		private function OnSwfLoadComplete(event:FlexEvent):void 
		{
			var sysmgr:SystemManager = (event.currentTarget as SystemManager);
			var swfApp:Application = (sysmgr.application as Application);
			// call your function here, maybe add error checking
			if (swfApp.hasOwnProperty("LaunchProxy")) 
			{
				var LaunchProxy:Function = (swfApp["LaunchProxy"] as Function);
				LaunchProxy();
			}
		}
		//----------------------------------
		private function OnLoadError(event:IOErrorEvent):void
		{
			trace("Failed to load swf: "+event.text);
		}
		//----------------------------------
		private function OnSecurityError(event:SecurityErrorEvent):void
		{
			trace("Failed to load swf: "+event.text);
		}*/
		
		
		
	}
}