/*******************************************************************************
 * FT_PluginOrganizer.as
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
	import com.ZG.UserObjects.ZG_PersistentObject;

	public class FT_PluginOrganizer
	{
		public function FT_PluginOrganizer()
		{
		}
		//----------------------------------
		//This class organizes default plugins by category and returns
		// an array of containers that contains plugins as children
		// TODO: This does not check if the plugins with the same name exist
		// rootDirPath is only used for remote plugins
		// 
		public function OrganizePlugins(pluginList:Array, rootDirPath:String = null):Array
		{
			var i:int;
			
			var containerList:Array = new Array();
			for(i=0; i < pluginList.length; ++i)
			{
				var curPlugin:FT_Plugin =pluginList[i];
				var container:ZG_PersistentObject = FindContainer(containerList,curPlugin.category);
				if(container == null)
				{
					container = new FT_PluginContainer();	
					container.name = curPlugin.category;
					//save the path of this container by removing the plugin name.
					// for local plugins this path is not used and does not exist but
					// it may exist for remote plugins
					FT_PluginContainer(container).SetPath(curPlugin.filePath,rootDirPath);
					containerList.push(container);
				}
				container.AddChild(curPlugin);			
			}
			// now sort
			/*for ( i = 0; i < containerList.length;++i)
			{
				containerList[i].SortChildren();// by name is default
			}*/
			return containerList;
		}
		//-----------------------------------------
		private function FindContainer(containerList:Array,containerName:String):ZG_PersistentObject
		{
			for( var i:int =0; i < containerList.length;++i)
			{
				var curContainer:ZG_PersistentObject = containerList[i];
				if(curContainer.name == containerName)
				{
					return curContainer;
				}
			}
			return null;
		}
	}
}
