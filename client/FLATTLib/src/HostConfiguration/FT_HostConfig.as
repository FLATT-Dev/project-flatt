/*******************************************************************************
 * FT_HostConfig.as
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
	import Application.*;
	
	import Repository.*;
	
	import Utility.*;
	
	import com.ZG.UserObjects.ZG_PersistentObject;
	import com.ZG.Utility.*;
	
	import flash.filesystem.*;
	import flash.filesystem.File;
	
	public class FT_HostConfig extends ZG_PersistentObject
	{
		
		protected var _file:File;
		
		public function FT_HostConfig()
		{
			super();
			_isContainer = false;
		}
		//---------------------------------------------------------
		public function get icon():Class
		{			
			return FT_Application.GetInstance().GetIconForObject(this);
		}
		//---------------------------------------------------------
		public function get file():File
		{
			return _file;
		}
		//---------------------------------------------------------
		public function set file(value:File):void
		{
			_file = value;
		}
		//---------------------------------------------------------
		override public function get name():String
		{
			return((file == null) ? "Untitled" :file.name);
		}
		
		//-----------------------------
	    override public function Write(param:Object = null ):Boolean
		{
			if(_file!=null && _file.exists)
			{	
				return ZG_FileUtils.WriteFile(_file,param,true,FileMode.WRITE);
			}
			return false;
		}
		//-------------------------------------------
		override public function GetData():Object
		{
			return ZG_FileUtils.ReadFile(_file,true);
		}
		//--------------------------------------------
		public function GetEncodedConfig():String
		{
			return ZG_StringUtils.Base64Encode(ZG_StringUtils.Dos2Unix(GetData() as String));
		}
		//--------------------------------------------
		// pulic constructor helper
		public static function NewObj(file:File):FT_HostConfig
		{
			var hc:FT_HostConfig = new FT_HostConfig();
			hc.file = file;
			return hc;
		}
		
		
		

	}
}
