/*******************************************************************************
 * FT_PluginResult.as
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
	import TargetHostManagement.FT_TargetHost;
	import Exec.FT_PluginExec;
	
	// This class handles runtime return data for the plugin	                          						*/
	
	public class FT_PluginResult ///TODO: extends ZG_PersistentObject
	{
		
		
		// TODO: may be  these can be obtained from plugin itself 
		// or keep the plugin object ptr??
		/*private var _type:String = RTYPE_TEXT;
		private var  _description:String = "";	
		private var _name:String = "";
		private var _pluginId:Number =-1;*/
		//protected var _pluginObj:FT_Plugin;		
		//protected var _data:String ="" ; // actual data that plugin exec returns		
		protected var _timestamp:Date = null;
		//protected var _execResult:String = "";		
		//protected var _host:String ="" ; // host from which this result came	
		//private var _appendData:Boolean; // this value is given to UI so it knows that data needs to be appended
										 // Also used to determine if e.g tablle columns need to be generated
		private var _execObj:FT_PluginExec;
		public function FT_PluginResult()
		{	

		}	
		//---------------------------------
		// subclasses override
		public function GetData(params:Object = null):Object
		{
			return _execObj.returnData;
		}
		//---------------------------------
		protected function Validate(data :Object):Boolean
		{
			return true;
		}
		//--------------------------------------
		public function get type():String
		{
			return _execObj.plugin.returnDataInfo.type;
		}
		//--------------------------------------
		/*public function get pluginName():String
		{
			return _execObj.plugin.name;
		}*/
		//--------------------------------------
		public function get description():String
		{
			return _execObj.plugin.returnDataInfo.description;
		}
		//--------------------------------------
		// Generic labels. For plugin type table - this is column names
		
		public function get labelNames():Array
		{
			//TODO: for type table extract first data row
			return new Array();
		}
		
		//--------------------------------------
		public function get execResult():String
		{
			return _execObj.execResult;
		}
		//--------------------------------------
		public function get timestamp():Date
		{
			return _timestamp;
		}
		//--------------------------------------
		public function set timestamp(value:Date):void
		{
			_timestamp = value;
		}
		//--------------------------------------
		public function get hostName():String
		{
			return _execObj.targetHostObj.host;
		}
		//--------------------------------------
		public function get targetHostObj():FT_TargetHost
		{
			return _execObj.targetHostObj;
		}
		//--------------------------------------
		public function get pluginObj():FT_Plugin
		{
			return _execObj.plugin;
		}
		//--------------------------------------
		//-------------------------
		public function get appendData():Boolean
		{
			return _execObj.appendData;
		}
		//--------------------------------------
		public function get execObj():FT_PluginExec
		{
			return _execObj;
		}
		//--------------------------------------
		// Set by plugin manager when exec object finishes
		public function set execObj(value:FT_PluginExec):void
		{
			_execObj = value;
			_timestamp = null;
			_timestamp = new Date();
		}
		public function HasData():Boolean
		{
			return (_execObj.HasData());
		}

		
		//--------------------------------------
	
	}
}
