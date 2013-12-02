/*******************************************************************************
 * FT_PluginContainer.as
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
	import Utility.*;
	
	import com.ZG.UserObjects.ZG_PersistentObject;
	
	import mx.collections.*;
	
	public class FT_PluginContainer extends ZG_PersistentObject
	{
		private var _containerPath:String = "";
		public function FT_PluginContainer()
		{
			super();
			type = FT_Strings.OTYPE_CATEGORY_CONTAINER;// not used			
		}
		//-----------------------------------------------------
		override public function AddChild(newChild:ZG_PersistentObject,
								 insertIndex:int = -1,
								 searchType:int = 2):Boolean
		{
			var ret:Boolean = super.AddChild(newChild,insertIndex,searchType);
			// TODO: get sort params from prefs.
			if(_children.length > 1 )
			{
				SortChildren();
			}
			return ret;
		}
		//------------------------------------------
		
		override public function get filePath():String
		{
			return _containerPath;
		}
		//------------------------------------		
		// since local plugin contrainers are virtual they don't have a directory on the file system
		// remote containers may have a directory - so figure out its path from children
		//Sometimes the plugin container is not virtual for remote plugin, so the container name may not be
		// present in the plugin path. In that case set the container path to root repo path.
		public function SetPath(pluginPath:String,rootDirPath:String):void
		{
			// find the category directory
			var pos:int = pluginPath.indexOf(this.name);
			if(pos >=0)
			{
				//pos points to the first character of the found name. add 1 for file separator characte.
				_containerPath = pluginPath.substr(0,pos+this.name.length); 
			}
			else
			{
				if(rootDirPath!=null)
				{
					_containerPath =  rootDirPath;
				}
			}			
		}
		//----------------------------------------------
	}
}
