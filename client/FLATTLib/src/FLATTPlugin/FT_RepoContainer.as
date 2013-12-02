/*******************************************************************************
 * FT_RepoContainer.as
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
	import Repository.*;
	
	import Utility.*;
	
	import com.ZG.UserObjects.ZG_PersistentObject;
	// ui container for repository object
	public class FT_RepoContainer extends ZG_PersistentObject
	{
		private var _repo:FT_PluginRepository;
		//-------------------------------------
		public function FT_RepoContainer()
		{
			super();
			type = FT_Strings.OTYPE_REPO_CONTAINER;// not used
		}
		//-------------------------------------
		public function get repo():FT_PluginRepository
		{
			return _repo;
		}
		//-------------------------------------
		public function set repo(value:FT_PluginRepository):void
		{
			_repo = value;
		}
		override public function get name():String
		{
			return (_repo !=null ? _repo.name: "");
		}
		//----------------------------------------------------------
		//RepoContainer has one or more plugin containers. 
		// Look in all containers for a given item
		public function DeepFindChild(searchFlags:int,searchBy:Object):Object
		{
			var childrenArr:Array = _children.toArray();
			var curObj:Object = null;
			
			for (var i:int = 0; i < childrenArr.length;++i)
			{
				//each child is a plugin container
				// match also plugin container names
				if(childrenArr[i].name == searchBy)
				{
					return childrenArr[i];
				}
				curObj = childrenArr[i].FindChildBy(searchFlags,searchBy);
				if(curObj!=null)
				{
					return curObj;
				}				
			}
			return null;
		}
		//------------------------------------------------------
		override public function get filePath():String
		{
			return (_repo !=null ? _repo.filePath: "");
		}
	}
}
