/*******************************************************************************
 * FT_Plugin.as
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
	import Application.*;
	
	import Repository.*;
	
	import Utility.*;
	
	import com.ZG.Logging.*;
	import com.ZG.UserObjects.ZG_PersistentObject;
	import com.ZG.Utility.*;
	import com.ascrypt3.*;
	
	import flash.filesystem.*;
	import flash.filesystem.File;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	
	// TODO: Optimize so that t he xml is not kept in memory all the time
	public class FT_Plugin extends ZG_PersistentObject
	{		
		/* Wizard page UI elements  
		*/		
		//Private vars		
		protected var _xml:XML = new XML();
		private var _wizard:FT_Wizard = null;
		private var _formattedCmd:String = "";
		private var _returnDataInfo:FT_ReturnDataInfo ;
		private var _uiParams:Array = new Array();
		private var _initFromXmlFailed:Boolean = false;
		private var _url:String = ""; // for remote plugins
		private var _serverAddr:String = "";
		private var _repoRevision:String;
		
		
		//================================
		
		public function FT_Plugin(xmlString:String = null)
		{
			super();
			type = FT_Strings.OTYPE_PLUGIN; // not needed
			// plugin is not a container
			isContainer = false;
			InitFromString(xmlString);	
			
			
		}
				
		//-------------------------------------
		public function InitFromString(xmlString:String):void
		{
			if(!InitFromXMLString(xmlString))
			{			
				CreateDefaultXML();
			}	
		}
		//----------------------------------------------
		public function InitFromXMLObj(xml:XML):Boolean
		{
			_xml = null;
			_xml = xml;
			return IsValid();
		}
		
		//------------------------------------------------
		// initializes the plugin with data from repo item.
		// OBSOLETE
		/*public function InitFromRepoItem(repoItem:FT_RepositoryItem):void
		{
			
			this.name = repoItem.name;
			this.guid = repoItem.guid;
			this.url = repoItem.pluginUrl;
			this.type = repoItem.type;
			this.category = repoItem.category;
			this.readOnly = this.isRemote;
			//save repo revision to be displayed next to item name
			this.repoRevision = repoItem.revision;
		}*/		
		//----------------------------------------------
		protected function CreateDefaultXML():void
		{
			//create a skeleton xml
			_xml = null; //
			_xml = new XML("<FLATTPlugin category =\"validation\">" +
				"<GUID>"+GUID.create()+"</GUID>"+
				"<Version/><Creator/><Name/>"+				
				"<Image/><Action/>"+
				"<Description/>"+
				"<ReturnData type=\"Text\">" +
				"<DataSeparator>space</DataSeparator>"+
				"<Description/></ReturnData>"+
				"<Transport>ssh</Transport>"+
				"</FLATTPlugin>");
			
			ReadReturnDataInfo();
		}
		//-----------------------------
		public function ToXMLString():String
		{
			// update return data portion and return full xml
			_xml.ReturnData.@type =_returnDataInfo.type;
			_xml.ReturnData.NumColumns = _returnDataInfo.numColumns.toString();
			_xml.ReturnData.DataSeparator = _returnDataInfo.dataSeparatorType;
			_xml.ReturnData.Description = _returnDataInfo.description;
			UpdateUIParams();
				
			return _xml.toXMLString();
			
		}
		//-----------------------------
		private function ReadReturnDataInfo():void
		{
			if(_xml.hasOwnProperty("ReturnData"))
			{				
				_returnDataInfo = new FT_ReturnDataInfo(_xml.ReturnData);
			}
		}
		
		// GETTERS/SETTERS
		public function get transport():String
		{
			return _xml.Transport;
		}
		//-------------------------------
		public function set transport(val:String):void
		{
			_xml.Transport = val;
		}	
		override public function get description():String
		{
			return _xml.Description;
		}
		//-------------------------------
		override public function set description(val:String):void
		{
			_xml.Description = val;
		}	
		public function get category():String
		{
			return _xml.@category;
		}
		//-------------------------------
		public function set category(val:String):void
		{
			 _xml.@category = val;
		}	
		//-------------------------------
		override public function get name():String
		{			
			return _xml.Name;
		}
		//-------------------------------
		override public function set name(val:String):void
		{
			_xml.Name = val;
		}	
		//--------------------------------------
		/*override public function get label():String
		{
			var ret:String = name;
			// if a plugin's parent is a task - display a number next to  the name
			if( parentObj!=null && parentObj is FT_Task)
			{
				return  (parentObj.GetChildIndex(this) + 1) + ". "+ ret;
			}
			return name;
		}*/
		//-----------------------------
		public function get commandString():String
		{
			return _xml.Action;
		}
		//-----------------------------
		public function set commandString(val:String):void
		{
			_xml.Action = val;
		}
		//-----------------------------
		public function get version():String
		{
			return _xml.Version;
		}
		//----------------------------------
		public function set version(val:String):void
		{
			_xml.Version = val;
		}		
		//-----------------------------
		//TODO: base64 decode image
		public function get image():String
		{
			return _xml.Image;
		}
		//----------------------------------
		public function set image(val:String):void
		{
			 _xml.Image = val;
		}
		//----------------------------------
		public function get creator():String
		{
			return _xml.Creator;
		}
		
		//----------------------------------
		public function set creator(val:String):void
		{
			_xml.Creator = val;
		}
		// not used for now but maybe later
		//----------------------------------
		 override public function set guid(val:String):void
		{
			_xml.GUID = val;
		}
		//----------------------------------
		 override public function get guid():String
		{
			return _xml.GUID;
		}
		 
		//----------------------------------
		
		//----------------------------------
		/*public function get xml():XML
		{
			return _xml;
		}
		//----------------------------------
		public function set xml(value:XML):void
		{
			_xml = value;
		}*/
		//----------------------------------
		public function GetWizard():FT_Wizard
		{
			/* create a wizard object if there is one */
			if(_xml.hasOwnProperty("FLATTWizard"))
			{				
				_wizard = new FT_Wizard(_xml.FLATTWizard);
			}
			return _wizard;
		}
		
		//-----------------------------
		public function Dump():String
		{
			var ret :String = "********Plugin XML dump******\n"+
				"category=" + category +"\nversion=" + version +
				"\ncreator=" + creator + "\nname=" + name +
				"\nimage=" +image+"\naction="+commandString +
				"\ndescription="+description +
				"\nreturn type=" + returnDataInfo.type + "\n"+
				(GetWizard()!=null? _wizard.Dump():"");	
			
			trace(ret);			
			return ret;			
		}
		//-----------------------------
		// if formatted command is empty - return the command,
		// this is the case for plugins that don't require UI to add parameters
		// to the command.
		public function get formattedCmd():String
		{
			return (_formattedCmd == "" ? commandString : _formattedCmd);
		}
		//-----------------------------
		public function set formattedCmd(value:String):void
		{
			_formattedCmd = value;
		}
		//-----------------------------
		public function get returnDataInfo():FT_ReturnDataInfo
		{
			return _returnDataInfo;
		}
		//-----------------------------
		// Saves plugin into the plugin directory if the plugin does not have a file obbject
		override public function Write(pluginDir:Object = null):Boolean
		{
			if(_fileObj == null )
			{
				_fileObj = new File( File(pluginDir).nativePath + File.separator + guid + ".xml");
			}
			if(ZG_FileUtils.WriteFile(_fileObj,ToXMLString(),true,FileMode.WRITE))
			{
				// remote plugins become dirty when they are written, i.e locally modified.
				// it's the opposite for local plugins
				dirty = isRemote;
				return true;
			}
			ZG_AppLog.GetInstance().LogIt(("Failed to save  '" + name) ,ZG_AppLog.LOG_ERR);
			return false;
			
			
		}
		//-----------------------------
		override public function Read(inFile:File, useFile:Object):Boolean
		{			
			_xml = null; // clear old xml
			var xmlData:String = ZG_FileUtils.ReadFile(inFile,true) as String;
			// indicate that  this is the file .There may be case where
			// we're reading plugin from another file and saving it in plugin directory
			if(useFile)
			{
				_fileObj = inFile;
			}
			return InitFromXMLString(xmlData);
		}
		//-----------------------------
		protected function InitFromXMLString(xmlString:String):Boolean
		{			
			var ret:Boolean = false;	
			
			if(xmlString!=null)
			{
				try
				{				
					_xml = null;
					_xml = new XML(xmlString);
					// will throw if XML is malformed
					VerifyXML();
					ReadReturnDataInfo();
					ReadUIParams();
					ret = true;
					
				}
				catch( e:Error)
				{
					trace("FT_Plugin: ctor: " + e.message);
					// TODO : Log thsi
					//Alert.show("Error parsing plugin XML : " + e.message);
					//create a new empty one 
					_xml = null;	
					initFromXmlFailed = true;
											
				}
			}
			return ret;
		}
		//-----------------------------
		public function get uiParams():Array
		{
			return _uiParams;
		}

		public function set uiParams(value:Array):void
		{
		
			_uiParams = value;
		}
		//-----------------------------
		private function UpdateUIParams():void
		{
			//TODO: update current ui params list in xml
			// remove existing. create new one from existsing list.
			delete(_xml.UIParams);
			
			var newParamsList:XML = new XML(<UIParamsList></UIParamsList>);
			// now that we have a saved hosts block, let's fill it
			
			for(var i:int =0; i <_uiParams.length; ++i )
			{				
				newParamsList.appendChild((_uiParams[i].ToXML()));				
			}
			// and save the new list
			_xml.appendChild(newParamsList);		
			
		}

		//-----------------------------
		private function ReadUIParams():void
		{
			//TODO: read UI params list from XML
			var paramsList:XMLList = _xml.UIParamsList.UIParam;
			if( paramsList!=null)
			{
				for(var i:int=0; i <paramsList.length();++i)
				{
					var param:FT_UIParam = new FT_UIParam();
					param.FromXML(paramsList[i]);
					_uiParams.push(param);
				}
			}			
		}
		
		//--------------------------------------------
		// TODO: more rigorous verification
		public  function VerifyXML():void
		{
			// For plugins that are read in from external sources,verify structure
			var e:Error = new Error();
			var s:String = _xml.name();
			
			if(_xml.name() != "FLATTPlugin")
			{
				// not a FLATT plugin
				e.message = ("This is not a FLATT plugin:" + _xml.name());
				throw(e);
			}
			if(category == "")
			{
				e.message = ("Malformed XML: Category is missing");
				throw(e);
			}
			//TODO: maybe do things differently depending on version
			if(guid == "")
			{
				guid=GUID.create();
			}
			  
		}
		
		//----------------------------------------------------
		override public function Delete(pluginDir:Object):void
		{
			if(_fileObj == null )
			{
				_fileObj = new File( File(pluginDir).nativePath + File.separator + guid + ".xml");
			}
			if(_fileObj.exists)
			{
				_fileObj.deleteFile();
			}
		}
		
		//---------------------------------------------------------
		public function get icon():Class
		{			
			return FT_Application.GetInstance().GetIconForObject(this);
		}
		//----------------------------------------------------\
		override public function Copy(src:ZG_PersistentObject):void
		{
			// just init the xml 
			// file will be created because  guid is known
			InitFromString(FT_Plugin(src).ToXMLString());
			
		}
		//-----------------------------------------
		// If there is an error loading xml, a default xml is created
		// neeed to check the saved variable
		
		public function LoadedOK():Boolean
		{
			return (initFromXmlFailed == false);
		}
		//-----------------------------
		public function get initFromXmlFailed():Boolean
		{
			return _initFromXmlFailed;
		}
		//-----------------------------
		public function set initFromXmlFailed(value:Boolean):void
		{
			_initFromXmlFailed = value;
		}
		//---------------------------------------
		// A valid plugin has a name,guid,command string and category
		// command string is checked right before plugin executes
		override public function IsValid():Boolean
		{
			return ((_xml!=null)					&&
					(_xml.name() == "FLATTPlugin") 	&&
					(this.guid.length > 0 )			&&
					//(this.commandString.length > 0) && 
					(this.category.length > 0) 		&& 
					(this.name.length > 0));
										
		}
		//---------------------------------------
		public function get url():String
		{
			return _url;
		}
		//---------------------------------------
		public function set url(value:String):void
		{
			_url = value;
			
			
		}
		//-----------------------------
		/*public function get serverAddr():String
		{
			if(_serverAddr == "")
			{
				_serverAddr = ZG_URLValidator.HostAddressFromUrl(_url);			
				
			}
			return _serverAddr;
		}
		//-----------------------------
		public function set serverAddr(value:String):void
		{
			_serverAddr = value;
		}*/
		// brain dead check, no url validation
		override public function get isRemote():Boolean
		{
			return (_url!=null && _url.length > 0);
		}
		//-----------------------------
		// those are used to extract the version of the pli
		public function get repoRevision():String
		{
			return _repoRevision;
		}
		//-----------------------------
		public function set repoRevision(value:String):void
		{
			_repoRevision = value;
		}
		//-----------------------------
		// plugin supports continuous return data.
		public function get supportsContinuousData():Boolean
		{
			return (returnDataInfo.type ==FT_Strings.RTYPE_TEXT ||
					returnDataInfo.type ==FT_Strings.RTYPE_LINECHART ||
					returnDataInfo.type ==FT_Strings.RTYPE_TABLE);
			
		}
		//-------------------------------
		//For plugin its id is its GUID
		override public function  get internalName():String
		{
			return guid;
		}
		//---------------------------------------------
		override public function Refresh():void
		{
			Read(_fileObj,true);				
		}
		//-----------------------------------------
		override public function UpdateCategory(collection:ArrayCollection):void
		{
			// this relies on the following structure:
			/* repo container->plugin container->plugin*/			
			var oldCategoryContainer:ZG_PersistentObject = this.parentObj;
			var repoContainer:ZG_PersistentObject = oldCategoryContainer.parentObj ;
			var newCategoryContainer:ZG_PersistentObject = null;
			
			// easy case - container did not change
			if(oldCategoryContainer.name == this.category)
			{
				return;			
			}
			// not the same category.Find out if category exists in repo
			newCategoryContainer = repoContainer.FindChildBy(ZG_PersistentObject.SRCH_TYPE_NAME,this.category) as ZG_PersistentObject;
			if(newCategoryContainer == null)
			{
				// doesnt exist - create
				newCategoryContainer=new FT_PluginContainer();
				newCategoryContainer.name = this.category;
				// containers are virtual but their path needs to be set
				// so the repo commands have a path to work with
				newCategoryContainer.fileObj=repoContainer.fileObj;
				repoContainer.AddChild(newCategoryContainer);
			}
			oldCategoryContainer.DeleteChild(this);
			newCategoryContainer.AddChild(this);
			
			// no more children in  category - delete category
			if(oldCategoryContainer.children.length == 0)
			{
				repoContainer.DeleteChild(oldCategoryContainer);
			}
			collection.refresh();
		}
	}// pkg
} // class
