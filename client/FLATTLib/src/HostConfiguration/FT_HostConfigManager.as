/*******************************************************************************
 * FT_HostConfigManager.as
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
package HostConfiguration
{
	import Utility.*;
	
	import com.ZG.Events.*;
	import com.ZG.Utility.*;
	
	import flash.data.*;
	import flash.events.*;
	import flash.events.IEventDispatcher;
	import flash.filesystem.*;
	import flash.utils.*;
	
	public class FT_HostConfigManager extends ZG_EventDispatcher
	{
		
		private static var s_Instance:FT_HostConfigManager;
		public static const CONFIG_FILES_DIR:String = "HostConfig";
		private var _configFilesDir:File;
		private var _configFiles:Array; // array of FT_HostConfig objects
		private static const DEF_CONFIG_NAME:String  = "defaultconfig.txt";
		
		[Embed(source="/Defaults/defaultconfig.txt",mimeType="application/octet-stream")]
		protected const DEF_CONFIG:Class;
		
		//====================================================
		public function FT_HostConfigManager(target:IEventDispatcher=null)
		{
			super(target);
			_configFiles = new Array();
		}

		//-----------------------------------------------
		public static function GetInstance():FT_HostConfigManager
		{
			if(s_Instance == null )
			{
				s_Instance = new FT_HostConfigManager();
			}
			return s_Instance;
		}
		//-----------------------------------------------------
		public function Initialize():void
		{
			FS_ReadHostConfigFiles();
		}
		//-------------------------------------------
		private function FS_ReadHostConfigFiles():void
		{
			if(EnsureHostConfigDirectory())			
			{
				_configFilesDir.addEventListener(FileListEvent.DIRECTORY_LISTING, HostConfigDirListFunc);
				// start reading plugins from FS
				_configFilesDir.getDirectoryListingAsync();
			}
		}
		//--------------------------------------
		private function HostConfigDirListFunc(event:FileListEvent):void		
		{
			var contents:Array = event.files;		 
			FS_CreateHostConfigList(event.files);
			DispatchEvent(FT_Events.FT_EVT_CONFIG_FILES_READY,_configFiles);
		}
		//------------------------------------------------
		//
		private function FS_CreateHostConfigList(configFiles:Array):void
		{
			for(var i:int =0; i < configFiles.length;++i)
			{
				var foo:File;
				
				if(!configFiles[i].isDirectory)
				{
					InternalAdd(configFiles[i],false);
				}
			}
			// TODO: sort
		}
		//---------------------------------------------
		private function EnsureHostConfigDirectory():Boolean
		{
			
			var dir:File = File.applicationStorageDirectory.resolvePath(CONFIG_FILES_DIR);
			
			var createDefaultConfig:Boolean = (dir!=null ? (dir.exists == false): false);
			_configFilesDir = ZG_FileUtils.EnsureDirectory(_configFilesDir,CONFIG_FILES_DIR);
			
			if(_configFilesDir && createDefaultConfig)
			{
				var f:File = new File(_configFilesDir.nativePath+File.separator+DEF_CONFIG_NAME);
				ZG_FileUtils.WriteFile(f,(new String(new DEF_CONFIG())),true,FileMode.WRITE);
			}
			
			return (_configFilesDir!=null && _configFilesDir.exists );
		}	
		//-----------------------------------------------
		public function get configFiles():Array
		{
			return _configFiles;
		}
		//-----------------------------------------------	
		public function Remove(item:FT_HostConfig):void
		{
			//remove from array and delete file
			if(item.file)
			{
				item.file.deleteFile();
			}
			DispatchEvent(FT_Events.FT_EVT_REMOVE_HOST_CONFIG,item);
			//_configFiles.splice(_configFiles.indexOf(item),1);
		}
		protected function InternalAdd(file:File,checkDups:Boolean):Boolean
		{
			
			if(checkDups)
			{
				/* find out if the file with the same name exists in the list */
				for( var i:int; i < _configFiles.length;++i)
				{
					if(_configFiles[i].name == file.name)
					{
						return false;
					}
				}
			}
			// now create a FT_HostConfig object and add it to 
			_configFiles.push(FT_HostConfig.NewObj(file));
			return true;
		}
		
		//-----------------------------------------
		public function NewHostConfig(text:String,name:String):void
		{			
			if(EnsureHostConfigDirectory())
			{
				var path:String = this._configFilesDir.nativePath + File.separator + name;
				
				var file:File = new File(path);
				ZG_FileUtils.WriteFile(file,text,true,FileMode.WRITE);				
				
				if(file.exists)
				{
					AddHostConfig(file,false);
				}
			}
			
		}
		
		//-----------------------------------------
		private function OnSaveFileComplete(evt:ZG_Event):void
		{								
			if(evt.type == ZG_Event.EVT_SAVE_FILE_COMPLETE)
			{			
				if(evt.data!=null)
				{
					
				}
			}
		}
		//---------------------------------------
		public function AddHostConfig(file:File,copyToConfigDir:Boolean):void
		{
			var newFile:File = null;
			if(copyToConfigDir)
			{
				/* copy the file to the configuration directory */
				try
				{				
					newFile = new File(_configFilesDir.nativePath + File.separator+file.name);	
					if(newFile.exists)
					{
						newFile = null; 
						// already exists, don't bother copying again
						// it will fail anyway
					}
					else
					{
						file.copyTo(newFile);	
					}
					
				}
				catch(e:Error)
				{
					trace("Error copying file " + file.nativePath + " to " + newFile.nativePath + ": " +e.message);
					newFile = null;
				}
			}
			else
			{
				newFile = file;
			}
			if(newFile!=null)
			{
				if(InternalAdd(newFile,true))//check duplicates
				{
					// TODO:sort
					DispatchEvent(FT_Events.FT_EVT_CONFIG_FILES_READY,_configFiles);
				}
			}
		}
		//-----------------------
		public function FindByName( name:String):FT_HostConfig
		{
			for(var i:int = 0; i < _configFiles.length;++i)
			{
				if(_configFiles[i].name == name )
				{
					return  _configFiles[i];
				}
			}
			return null;
		}
	}
	
}
