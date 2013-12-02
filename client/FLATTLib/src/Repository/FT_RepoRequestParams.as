/*******************************************************************************
 * FT_RepoRequestParams.as
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
	import com.ZG.Utility.*;
	// this object creates  xml related to a repository request to the server, that is added to the overall server request.
	public class FT_RepoRequestParams
	{
		
		private var _rootDirPath:String = "";
		private var _reqType:int;
		private var _url:String = "";
		private var _fileList:Array = new Array(); // files to perform a repo operation on
		private var _username:String = ""
		private var _password:String = "";
		private var _checkinMessage:String = "";
		private var _userName:String ="";
		
		public function FT_RepoRequestParams()
		{
			
		}
		//---------------------------------------------
		public function ToXML():XML
		{
			
			var ret:XML = new XML(<RepoRequest></RepoRequest>);
			var url:String = 
			ret.@type=_reqType;
			
			
			if(_url.length > 0)
			{
				ret.appendChild(<URL>{_url}</URL>);
			}
			// Add root path if it exists
			var pathsXml:XML= new XML(<LocalPaths></LocalPaths>);
			if(_rootDirPath.length > 0)
			{
				//pathsXml.appendChild(AppendPath(_rootDirPath,true));	
				ret.appendChild(<RootDir>{_rootDirPath}</RootDir>);
			}
			// now add other paths
			if(_fileList !=null)
			{
				for(var i:int = 0; i < _fileList.length;++i)
				{
					pathsXml.appendChild(AppendPath(fileList[i],false));
				}
			}
			/* append credentials */
			if(_username!=null && _username.length > 0)
			{
				ret.appendChild(<username>{username}</username>);				
			}
			
			if(_password!=null && _password.length > 0)
			{
				ret.appendChild(<password>{_password}</password>);				
			}
			if(_reqType == FT_PluginRepository.REPO_REQ_ADD || _reqType == FT_PluginRepository.REPO_REQ_COMMIT)
			{
				// add checkin message
				ret.appendChild(<CheckinMessage>{checkinMessage}</CheckinMessage>);						
			}
			
			// append checkin message
			// and append to xml result
			ret.appendChild(pathsXml);
			
			return ret;
			
				
				
		}
		//----------------------------------------------
		protected function AppendPath(path:String, isRoot:Boolean):XML
		{
			var ret:XML = new XML(<Path></Path>);
			ret.@name = path;
			if(isRoot)
			{
				ret.@isroot = true;
			}
			return ret;
		}
		
		//---------------------------------------------
		public function set rootDirPath(value:String):void
		{
			_rootDirPath = value;
		}
		//---------------------------------------------
		public function set reqType(value:int):void
		{
			_reqType = value;
		}
		//---------------------------------------------
		public function get reqType():int
		{
			return _reqType;
		}
		//---------------------------------------------
		// a list of file on which the repository operation is performed
		public function get fileList():Array
		{
			return _fileList;
		}
		//---------------------------------------------
		public function set fileList(value:Array):void
		{
			_fileList = value;
		}
		//---------------------------------------------
		public function get url():String
		{
			return _url;
		}
		//---------------------------------------------
		public function set url(value:String):void
		{
			_url = value;
		}

		public function get username():String
		{
			return _username;
		}
		//---------------------------------------------
		public function set username(value:String):void
		{
			_username = value;
		}
		//---------------------------------------------
		public function get password():String
		{
			return _password;
		}
		//---------------------------------------------
		public function set password(value:String):void
		{
			_password = value;
		}
		//---------------------------------------------
		public function get checkinMessage():String
		{
			
			var ret :String = "";
			if(ZG_StringUtils.IsValidString(_checkinMessage))
			{
				ret = _checkinMessage;
			}
			return ret;
			/*
			ret =  ("Committed by " + (ZG_StringUtils.IsValidString(_username) ? _username : "Anonymous"));
			// not needed for now  in the future when we allow user to enter messages - probably
			return (ret));*/
		}
		//---------------------------------------------
		public function set checkinMessage(value:String):void
		{
			_checkinMessage = value;
		}
		//---------------------------------------------
		public function get userName():String
		{
			return _userName;
		}
		//---------------------------------------------
		public function set userName(value:String):void
		{
			_userName = value;
		}


		//---------------------------------------------

	}
}
