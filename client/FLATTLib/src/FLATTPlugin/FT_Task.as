/*******************************************************************************
 * FT_Task.as
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
	public class FT_Task extends FT_Plugin
	{
		//This class handles plugin tasks
		import com.ascrypt3.*;
		import TargetHostManagement.*;
		import Utility.*;
		
		
		
		public function FT_Task(xmlString:String = null)
		{
			super(xmlString);
			// task is a container
			this.isContainer = true;
			type = FT_Strings.OTYPE_TASK;
		}
		
		//------------------------------------------
		override protected function CreateDefaultXML():void
		{
			//create a skeleton xml
			_xml = null; //
			_xml = new XML("<FLATTTask>" +
				"<GUID>"+GUID.create()+"</GUID>"+
				"<Version/><Creator/><Name/>"+								
				"<Description/>"+
				"<PluginList></PluginList>"+				
				"</FLATTTask>");
			
		}
		//------------------------------------------
		override protected function  InitFromXMLString(xmlString:String):Boolean
		{
			var ret:Boolean = false;	
			
			if(xmlString!=null)
			{
				try
				{				
					_xml = new XML(xmlString);
					// will throw if XML is malformed
					VerifyXML();
					ChildrenFromXML();
										
					ret = true;
					
				}
				catch( e:Error)
				{
					trace("FT_Task: ctor: " + e.message);
					// TODO : Log thsi
					//Alert.show("Error parsing plugin XML : " + e.message);
					//create a new empty one 
					_xml = null;	
					initFromXmlFailed = true;
					
				}
			}
			return ret;
		}
		//---------------------------------------------------------
		override public  function VerifyXML():void
		{
			// For plugins that are read in from external sources,verify structure
			var e:Error = new Error();
			var s:String = _xml.name();
			var ret:Boolean = true;
			
			if(_xml.name() != "FLATTTask")
			{
				// not a FLATT task
				e.message = "This is not a flatt task: " + _xml.name();
				throw(e);
			}
			
			//TODO: maybe do things differently depending on version
			if(guid == "")
			{
				guid=GUID.create();
			}
		}
		
		//---------------------------------------------------------
		// Create a list of children from xml
		private function ChildrenFromXML():void
		{
			var hostList:Array = new Array();
			
			var pluginsList:XMLList = _xml.PluginList.PluginRef;
			if( pluginsList!=null)
			{
				for(var i:int =0; i < pluginsList.length();++i)
				{								
					var pluginRef:FT_PluginRef = new FT_PluginRef();
					pluginRef.plugin = FT_PluginManager.GetInstance().FindPlugin(pluginsList[i].@guid) as FT_Plugin;	
					// preserve the name for user
					pluginRef.name = pluginsList[i].@name;
					AddChild(pluginRef);
				}				
			}
		}
		//------------------------------------
		override public function ToXMLString():String
		{
			//remove existing list
			delete(_xml.PluginList);
			var newPluginList:XML = new XML(<PluginList></PluginList>);
			// now that we have a saved hosts block, let's fill it
			
			for(var i:int =0; i <_children.length; ++i )
			{			
				var pluginXml:XML  = CreatePluginXml(_children.getItemAt(i) as FT_PluginRef);
				newPluginList.appendChild(pluginXml);				
			}
			// and save the new list
			_xml.appendChild(newPluginList);
			
			// TODO: update list of plugins
			return _xml.toXMLString();
		}
		//-------------------------------------
		private function CreatePluginXml(curChild:FT_PluginRef):XML
		{
			var pluginXml:XML = new XML(<PluginRef></PluginRef>);			
			// add common tags
			pluginXml.@name = curChild.name;
			pluginXml.@guid = curChild.guid;			
			return pluginXml;
		}
		//-------------------------------------
		// return a list of plugins 
		public function GetPluginList():Array
		{
			var ret:Array = new Array();
			for(var i:int = 0; i < _children.length;++i)
			{
				ret.push(_children[i].plugin);
			}
			return ret;
		}
		//------------------------------------
		// display number of tasks plugins in task
		
		/* done in renderer now 
		override public function get label():String
		{
			return name + ( " ("+_children.length+")");
		}*/
		
		//------------------------------------
		/*public function get execHost():FT_TargetHost
		{
			return _execHost;
		}
		//------------------------------------
		public function set execHost(value:FT_TargetHost):void
		{
			_execHost = value;
		}*/
		//------------------------------------
		/*public function get curHostIndex():int
		{
			return _curHostIndex;
		}
		//------------------------------------
		public function set curHostIndex(value:int):void
		{
			_curHostIndex = value;
		}*/
		//----------------------------------------
		

		
	}
}
