/*******************************************************************************
 * FT_PluginRef.as
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
	import com.ZG.UserObjects.*;
	import com.ZG.Utility.*;
	
	// This class contains a reference to a plugin object
	// used in tasks handling
	public class FT_PluginRef extends ZG_PersistentObject
	{
		private var _plugin:FT_Plugin;
		//----------------------------------
		public function FT_PluginRef()
		{
			super();
			_isContainer = false;
		}
		//-----------------------------------
		public function get plugin():FT_Plugin
		{
			return _plugin;
		}
		//-------------------------------------
		public function set plugin(value:FT_Plugin):void
		{
			_plugin = value;
		}
		//----------------------------------
		// plugin name is saved in the xml. If plugin is missing indicate so
		// preserve plugin name so it's easier for user to identify missing plugin
		override public function get name():String
		{
			return (_plugin == null? (_name+"-"+ZG_Strings.STR_UNDEFINED) :_plugin.name);
		}
		//----------------------------------------
		override public function get guid():String
		{
			return (_plugin == null? ZG_Strings.STR_UNDEFINED:_plugin.guid);
		}
		//--------------------------------------
		public static function Create(src:FT_Plugin):FT_PluginRef
		{
			var pr:FT_PluginRef = new FT_PluginRef();
			pr.name = src.name // preserve the name just in case
			if(src.isRemote)
			{
				// make a local copy
				src = new FT_Plugin(src.ToXMLString());
				FT_PluginManager.GetInstance().Save(src);
				
			}
			pr.plugin = src;			
			return pr;
		}
		//------------------------------------------
		//TODO: Use plugin ref specific icon or a speccial icon to indicat that plugin is missing
		//for now use plugin icon
		public function get icon():Class
		{
			return (_plugin == null ? null : _plugin.icon);
		}
		//------------------------------------------
		// copy a plugin ref object
		public static function Copy(src:FT_PluginRef):FT_PluginRef
		{
			var pr:FT_PluginRef = new FT_PluginRef();
			pr.name = src.name // preserve the name just in case
			pr.plugin = src.plugin;
			return pr;
		}
		//------------------------------------------
		// TODO: this is way too UI specific and should not be here
		// Think of a way to move this in UI layer
		override public function get label():String
		{
			var ret:String = name;
			// if a plugin's parent is a task - display a number next to  the name
			if( parentObj!=null)
			{
				return  (parentObj.GetChildIndex(this) + 1) + ". "+ ret;
			}
			return name;
		}
	}
}
