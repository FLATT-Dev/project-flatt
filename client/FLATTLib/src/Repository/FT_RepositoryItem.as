/*******************************************************************************
 * FT_RepositoryItem.as
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
	// This class represents a repository item
	public class FT_RepositoryItem
	{
		private var _xml :XML;
		private var _rootUrl:String;
		private var _category:String;
		//---------------------------
		public function FT_RepositoryItem(inXML:XML)
		{
			_xml = inXML
		}
		//---------------------------
		public function get guid():String
		{
			return ((_xml == null) ? "" : (_xml.@id));
		}
		//---------------------------
		public function get revision():String
		{
			return ((_xml == null) ? "" : (_xml.Revision));
		}
		//---------------------------
		public function get name():String
		{
			return ((_xml == null) ? "" : (_xml.@text));
		}
		//---------------------------
		public function get category():String
		{
			//return ((_xml == null) ? "" : (_xml.@category));
			return _category;
		}
		//--------------------------
		// category is not in xml, so set manually
		public function set category(val:String):void
		{
			_category = val;
		}
		//---------------------------
		public function get type():String
		{
			return ((_xml == null) ? "" : (_xml.@type));
		}
		//---------------------------
		public function get rootUrl():String
		{
			return _rootUrl;
		}
		//---------------------------
		public function set rootUrl(value:String):void
		{
			_rootUrl = value;
		}
		//---------------------------
		// the url of the plugin that this item represents is made from the repository url/category/guid.xml
		public function get pluginUrl():String
		{
			return ((_xml == null) ? "" : (_rootUrl + "/"+ category + "/"+guid+ ".xml"));
		}

	}
}
