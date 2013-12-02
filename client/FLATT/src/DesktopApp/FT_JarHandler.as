package DesktopApp
{
	import Application.*;
	
	import Utility.*;
	
	import com.ZG.Events.*;
	import com.ZG.Logging.*;
	import com.ZG.Utility.*;
	
	import flash.desktop.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import flash.system.*;
	
	import mx.formatters.*;
	import mx.formatters.DateFormatter;
	
	public class FT_JarHandler extends ZG_EventDispatcher
	{
		private var _nativeProcess:NativeProcess;
		private  static const JARTYPE_PROXY:int = 0;
		private  static const JARTYPE_SVN_CLIENT:int = 1;
		private static const PPROXY_JAR_NAME:String = "jsshproxy.jar";
		private static const PROXY_SVN_JAR_NAME:String = "ft_svncli.jar"
		public static const PROXY_LOG_NAME:String = "jsshproxy.log";
		// XXX  proxy log path is always temp dir
		//private var _logPath:String = "";
		private var _localProxyRunning:Boolean;
				
		public function FT_JarHandler() 
		{
			
		}
		//-----------------------------------
		public function StartSshProxy():void
		{
			// on Linux this doesnt work . Proxy needs to be started manually or external proxy needs to be used.
			if(Capabilities.os.indexOf("Linux") >= 0)
			{
				_localProxyRunning = true;
				return;
			}
			// openWithDefaultApplication does not work in release installed build
			// Need to copy it to temp dir
			// First create 
			var jsshProxyFile:File = GetJarFile(PPROXY_JAR_NAME,JARTYPE_PROXY);
			
			if( jsshProxyFile!= null && jsshProxyFile.exists)
			{
				// save proxy log path
				// XXX proxy log path is always temp dir! Delete soon
				//_logPath = jsshProxyFile.parent.nativePath+ File.separator + PROXY_LOG_NAME;
				try
				{
					jsshProxyFile.openWithDefaultApplication();
					ZG_AppLog.GetInstance().LogIt("Started internal proxy,path: " + jsshProxyFile.nativePath,ZG_AppLog.LOG_INFO);
					_localProxyRunning = true;
				}
				catch (e:Error)
				{
					trace("Failed to openWithDefaultApplication: "+e.message);
					ZG_AppLog.GetInstance().LogIt("Failed to openWithDefaultApplication: "+e.message,ZG_AppLog.LOG_ERR);
				}
			}
			else
			{
				trace("Failed to start SSH proxy: proxy file cannot be found");
				ZG_AppLog.GetInstance().LogIt("Failed to start SSH proxy: proxy file cannot be found",ZG_AppLog.LOG_ERR);
			}
			/*
			if(NativeProcess.isSupported)
			{
				try
				{
					var npInfo:NativeProcessStartupInfo;	
					var arg:Vector.<String> = new Vector.<String>;
					arg.push("-jar");
					arg.push(File.applicationDirectory.resolvePath("bin/jsshproxy.jar").nativePath);
				
					npInfo = new NativeProcessStartupInfo;
					npInfo.arguments = arg;
					var execFile:File = LocateJavaExecutable();
					npInfo.executable = execFile;
					
				
					_nativeProcess = new NativeProcess;
					_nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, OnStdIOData);
					_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, OnStdIOErr);
					_nativeProcess.start(npInfo);
					ZG_AppLog.GetInstance().LogIt("Starting SSH proxy server");
				}
				catch(e:Error)
				{
					ZG_AppLog.GetInstance().LogIt("Failed to start SSH Proxy server:" + e.message,ZG_AppLog.LOG_ERR);
				}
			}
			else
			{
				ZG_AppLog.GetInstance().LogIt("Starting SSH proxy server:Native Process is not supported",ZG_AppLog.LOG_ERR);
			}	*/		
		}
		//----------------------------------------------
		public function EnsureSvnClient():Boolean
		{
			return (GetJarFile(PROXY_SVN_JAR_NAME,JARTYPE_SVN_CLIENT)!= null);			
		}
		//-----------------------------------------
		// generic function to get a jar file from the app directory and potentially copy it to temp dir
		private function GetJarFile(jarName:String, jarType:int):File
		{
			// openWithDefaultApplication does not work in release installed build
			// Docs say you cannot make this call on a file in app directory, but it does work in debug build
			// 
			// Need to copy it to temp dir
			// First create a new temp file to get the system temp dir path.. somewhat wasteful
			var tempFile:File = File.createTempFile();	
			var curAppVersion:String;
			var savedJarVersion:String;
			
			var jarPath:String = tempFile.parent.nativePath + File.separator + "FLATT"+File.separator+jarName;
			var jarFile:File = new File(jarPath);
			
			// make sure to delete the temp file
			tempFile.deleteFile();
			switch (jarType)
			{
				case JARTYPE_PROXY:
					savedJarVersion = FT_Prefs.GetInstance().GetSavedProxyVersion();
					break;
				case JARTYPE_SVN_CLIENT:
					savedJarVersion = FT_Prefs.GetInstance().GetSavedSvnClientVersion();
					break;
			}
			//XXX! Proxy version is the same as app version. They are synched on every  build
			curAppVersion = FT_Application.GetInstance().GetVersionString();
			
			// if the proxy file is not there ( got deleted or whatever or  versions don't match - copy
			if(savedJarVersion!=curAppVersion || (!jarFile.exists))
			{
				var jarFileInApp:File =  new File(File.applicationDirectory.resolvePath("bin/"+jarName).nativePath);
				try
				{
					
					ZG_AppLog.GetInstance().LogIt("Updating jar "+jarName+ " to newer version\n" +
						"Saved version: " + savedJarVersion + "\nNew version: "+curAppVersion,
						ZG_AppLog.LOG_INFO);
					
						jarFileInApp.copyTo(jarFile,true);//overwrite
						// only save new version if write succeeded
						switch (jarType)
						{
							case JARTYPE_PROXY:
								FT_Prefs.GetInstance().SaveProxyVersion(curAppVersion);
								break;
							case JARTYPE_SVN_CLIENT:
								FT_Prefs.GetInstance().SaveSvnClientVersion(curAppVersion);
								break;
						}
				}
				catch(e:Error)
				{
					ZG_AppLog.GetInstance().LogIt("Could not jar file "+ jarName + ": "+
						e.message,
						ZG_AppLog.LOG_ERR); 
				}
				
			}
			
			/*var proxyFileInApp:File =  new File(File.applicationDirectory.resolvePath("bin/"+PPROXY_JAR_NAME).nativePath);
			
			//var initialProxyFile:File = CheckProxyFileVersion(jsshProxyFile);
			if( !jsshProxyFile.exists )
			{
				// does not exist yet. copy to temp file
				//var initialProxyFile:File =  new File(File.applicationDirectory.resolvePath("bin/"+PPROXY_JAR_NAME).nativePath);
				if( initialProxyFile.exists )
				{
					initialProxyFile.copyTo(jsshProxyFile);		
					//var data:ByteArray = ZG_FileUtils.ReadFile(initialProxyFile,false) as ByteArray;
					//if( data !=null && data.length > 0 )
					//{
					//	ZG_FileUtils.WriteFile(jsshProxyFile,data,false,FileMode.WRITE);
					//}
				}
				else
				{
					ZG_AppLog.GetInstance().LogIt("Cannot find proxy server file!",ZG_AppLog.LOG_ERR);	
				}
			}*/
			return jarFile;			
			
		}

		/*public function get logPath():String
		{
			return _logPath;
		}*/
		//---------------------------------------------------
		// Compare creation date of the file in the application directory to the one stored in 
		// FLATT directory. Delete from FLATT dir if the one in app directory is newer
		// return file handle of the file stored in app directory
		private function CheckProxyFileVersion(curProxy:File):File
		{
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = ZG_Strings.STR_DEFAULT_DATE_FORMAT;
			
			var initialProxyFile:File =  new File(File.applicationDirectory.resolvePath("bin/"+PPROXY_JAR_NAME).nativePath);
			if(initialProxyFile.exists && curProxy.exists)
			{
				if(initialProxyFile.creationDate > curProxy.creationDate)
				{
					try
					{
						
						ZG_AppLog.GetInstance().LogIt("Updating proxy to newer version\n" +
													 "Initial proxy file: " + initialProxyFile.nativePath + "\nCreation date: " + 
													  dateFormatter.format(initialProxyFile.creationDate)+
													  "\nCurrent proxy file: " + curProxy.nativePath + "\nCreation date:" + 
													  dateFormatter.format(curProxy.creationDate),
													  ZG_AppLog.LOG_INFO);
						
						curProxy.deleteFile();
					}
					catch(e:Error)
					{
						ZG_AppLog.GetInstance().LogIt("Could not update proxy server: delete failed",ZG_AppLog.LOG_ERR); 
					}
				}
			}
			return initialProxyFile;
		}
		
		//-----------------------------------
		public function get localProxyRunning():Boolean
		{
			return _localProxyRunning;
		}
		//-----------------------------------
		public function set localProxyRunning(value:Boolean):void
		{
			_localProxyRunning = value;
		}
	
		/*
		//-----------------------------------
		private function StopSshProxy():void
		{
			if(NativeProcess.isSupported && _nativeProcess != null && _nativeProcess.running)
			{
				_nativeProcess.closeInput();
				_nativeProcess.exit();
			}
		}		
		//-----------------------------------
		private function OnStdIOData(e:ProgressEvent):void
		{
			if(_nativeProcess.running)
			{				
				var str :String = _nativeProcess.standardOutput.readUTFBytes(_nativeProcess.standardOutput.bytesAvailable);				
				// TODO:send the string to log
				trace("SSH Proxy:OnStdIOData\n"+str);
				DispatchEvent(FT_Events.FT_EVT_PROXY_LOG,str);
			}
			
		}
		private function OnStdIOErr(e:ProgressEvent):void
		{
			if(_nativeProcess.running)
			{				
				var str :String = _nativeProcess.standardOutput.readUTFBytes(_nativeProcess.standardOutput.bytesAvailable);				
				// TODO:send the string to log
				trace("SSH Proxy:OnStdIOErr\n"+str);
				DispatchEvent(FT_Events.FT_EVT_PROXY_LOG,str);
			}
			
		}
		private function LocateJavaExecutable():File
		{
			var jarFile:File = new File(File.applicationDirectory.resolvePath("bin/jsshproxy.jar").nativePath);
			//if(NativeProc
			return null;
		}
		
		*/
		
		
		
	}
}