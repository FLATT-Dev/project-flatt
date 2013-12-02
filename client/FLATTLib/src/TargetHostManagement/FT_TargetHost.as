/*******************************************************************************
 * FT_TargetHost.as
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
package TargetHostManagement
{
	import Application.*;
	
	import HostConfiguration.*;
	
	import com.ZG.UserObjects.ZG_PersistentObject;
	import com.ZG.Utility.*;
	import mx.utils.*;
	import flash.filesystem.*;

	public class FT_TargetHost extends ZG_PersistentObject
	{
		
		public static  var AUTH_METHOD_PASSWD:int = 0;
		public static  var AUTH_METHOD_KEYFILE:int = 1;
		
		private var _username:String="";
		private var _password:String=""; 
		private var _host:String = ""; // ip or name of host
		private var _sshKey:String = ""; 
		private var _authMethod:int = AUTH_METHOD_PASSWD;
		
		private var _hostConfigID:String = ""; // for now it's just the name, maybe later it will be a unique id
		
		public function FT_TargetHost()
		{
			super();
			_isContainer = false;			
		}
		//-------------------------------------------
		// Create request xml for remote proxy
		public function ToRequestXML():XML
		{
			var hostXml:XML = new XML(<Host></Host>);
					
			// only add creds if we have them - otherwise will use the creds from container of master
			if(username!="")
			{
				hostXml.appendChild(<username>{username}</username>);
			}
			
			if(password != "")
			{
				hostXml.appendChild(<password>{password}</password>);
			}
			if(_sshKey!="" )
			{	
				hostXml.appendChild(<sshkey>{sshKeyData}</sshkey>);
			}
						
			hostXml.appendChild(<address>{host}</address>);	
			
			var configData:String = GetEncodedConfig();
			if(ZG_StringUtils.IsValidString(configData))
			{
				//host specific configuration parameters.
				hostXml.appendChild(<configParams>{configData}</configParams>);
			}
		
						
			return hostXml;
		}
		
		//---------------------------------------------------
		// assign container creds to children.
		// only assign if empty
		/*public function PropagateCredentials():void
		{
			for(var i:int =0; i < _children.length;++i)
			{
				var child:FT_TargetHost = _children.getItemAt(i) as FT_TargetHost;
				if(child.username == "")
				{
					child.username = username;
				}
				if(child.password == "")
				{
					child.password = password;
				}				
			}
		}*/
		//-----------------------------
		// override standard name property of ZG_PO
		// if this object is a container it's name is given by user
		// otherwise it's just a host and name is its address
		override public function get name():String
		{
			return (_isContainer ? super.name: _host);
		}
		//-----------------------------
		// used by ComboBox UI to display the hosts
		override public function get label():String
		{
			return name;
		}
		//-------------------------------------
		public function Validate():Boolean
		{
			return(_host!="");
			/* Is  this all really needed?? just check if the host is not blank
			var numCreds:int = 0;
			var val:String="";
			
			if(_username=="")
			{				
				val = (parentObj !=null ? FT_TargetHost(parentObj).username : "");
				numCreds+=(val == "" ? 0: 1);
			}	
			// if no passwd - check ssh key
			if(_password=="")
			{	
				val = _sshKey!="";
				numCreds+=(val == "" ? 0: 1);
				
				if(!val)
				{
					// dont have a key check if parent has password.
					val = (parentObj !=null ? FT_TargetHost(parentObj).password: "");
					numCreds+=(val == "" ? 0: 1);
				}
				// parent does not have a password.check if parent has a key
				if(!val)
				{
					val = (parentObj !=null ? FT_TargetHost(parentObj).GetSshKeyPath(): "");
					numCreds+=(val == "" ? 0: 1);
				}
			}
			
						
			if(numCreds < 2)
			{
				// no user name and password and container does not have one either.
				// See if there is a master username and password 
				//if they exist -  don't set the username/ password values of this host but report that validation succeeded.
				// This is done to prevent the creds to be written to prefs so on the next run they 
				//are sent to the host and they are the same as master
				
				if(_username=="" )
				{
					numCreds += (FT_Prefs.GetInstance().GetMasterUserName()=="" ? 0 :1);
				}
				
				if(_password=="")
				{
					numCreds+= (FT_Prefs.GetInstance().GetMasterPassword()=="" ? 0:1);
				}
				
				if(_sshKey=="")
				{
					numCreds +=(FT_Prefs.GetInstance().GetMasterSshKeyPath()=="" ? 0:1);
				}
			}			
			return (numCreds >= 2);
			//TODO add code to validate IP address	
			*/
		}
		//--------------------------------------
		public function get username():String
		{
			return _username;
		}
		//--------------------------------------
		public function set username(value:String):void
		{
			_username = value;
		}
		//--------------------------------------
		public function get password():String
		{
				
			return _password;
		}
		//--------------------------------------
		public function set password(value:String):void
		{
			_password = value;
		}
		//--------------------------------------
		public function get host():String
		{
			return _host;
		}
		//--------------------------------------
		public function set host(value:String):void
		{
			_host = value;
		}
		//------------------------------------------
		override public function Copy(src:ZG_PersistentObject):void
		{
			super.Copy(src);
			// copy source
			username= (src as FT_TargetHost).username;
			password = (src as FT_TargetHost).password;
			host = 	(src as FT_TargetHost).host;	
			hostConfigID = (src as FT_TargetHost).hostConfigID;
			sshKey = (src as FT_TargetHost).GetSshKeyPath();
			//authMethod = (src as FT_TargetHost).authMethod;
		}
		public function GetSshKeyPath():String
		{
			return _sshKey;
		}
		//------------------------------------------
		public function get sshKeyData():String
		{			
			return ZG_FileUtils.GetEncodedSshKeyData(_sshKey);
		}
		//------------------------------------------
		public function set sshKey(value:String):void
		{
			_sshKey = value;
		}
		//------------------------------------------
		public function set hostConfigID(value:String):void
		{
			_hostConfigID = value;
		}

		//------------------------------------------
		public function get hostConfigID():String
		{
			return _hostConfigID;
		}
		//-----------------------------------
		public function GetEncodedConfig():String
		{
			var ret:String  = null;
			if(HasHostConfig())
			{
				var configObj:FT_HostConfig =  FT_HostConfigManager.GetInstance().FindByName(_hostConfigID);
				if(configObj !=null)
				{
					ret = configObj.GetEncodedConfig();
				}
			}
			return ret;			
		}
		//------------------------------------------
		public function GetConfigFileName():String
		{
			var ret:String  = null;
			if(HasHostConfig())
			{
				var configObj:FT_HostConfig =  FT_HostConfigManager.GetInstance().FindByName(_hostConfigID);
				if(configObj !=null)
				{
					ret = configObj.name;
				}
			}
			return ret;			
		}
		
		//---------------------------
		public function HasHostConfig():Boolean
		{
			return ZG_StringUtils.IsValidString(this.hostConfigID);
		}
		//-----------------------------------------------------------------------
		// shallow search for items that use a given config file
		public function ClearHostConfig(configID:String):int
		{
			var ret:int = 0;
			if(_hostConfigID == configID)
			{
				_hostConfigID = "";
				ret++;
			}
			if(isContainer && _children!=null)
			{
				for(var i:int = 0; i < _children.length;++i)
				{
					var curChild:FT_TargetHost = _children[i] as FT_TargetHost;
					if(curChild.hostConfigID == configID)
					{
						curChild.hostConfigID = "";
						ret++;
					}
				}
			}
			return ret;
		 }
		//-----------------------------------------------------------------------
		public function get authMethod():int
		{
			
			//return _authMethod;			
			//if key file is not empty - then use it , otherwise use password.
			// default is password
			return (_sshKey != "" ? AUTH_METHOD_KEYFILE : AUTH_METHOD_PASSWD);
		}
		//-----------------------------------------------------------
		// read the file, add
		public function HostConfigFromFile(path:String, copyToConfigDir:Boolean = true):String
		{
			var f:File = null;
			try
			{
				f = new File(path);
				if(f.exists)
				{
					FT_HostConfigManager.GetInstance().AddHostConfig(f,copyToConfigDir);
				}
			}
			catch(e:Error)
			{
				
			}
			return(f!=null ? f.name : "");
			
		}
		//--------------------------------------
		override public function IsValid():Boolean
		{
			return ZG_URLValidator.ValidAddress(host)
		}
		
		// STATIC
		//-------------------------------------------------
		public static function ParseHost(src:String):FT_TargetHost
		{		
			var ret:FT_TargetHost = new FT_TargetHost();	
			var startPos: int =0;
			var  endPos:int;
			var  i:int;	
			var strTest: String  = "";
			// the format has 5 entries separated by commas:
			// host,username,password,ssh key,config file\n
			// the order is important!
			// the last entry is config params file and it's not separated by the comma on the end
			// that's why there is one extra entry in the positions array
			var commaPositions: Array  = new Array(-1,-1,-1,-1,-1);
			var setFields : Array  = new Array(false,false,false,false,false);
			var  k : int= 0;
			// first check if it's not a comment or an empty line
			// a comment is a # at the beginning of the line
			if(src == "" || src.indexOf("#") == 0 )
			{
				// at this point the string is trimmed so if the first char is a string this must be a comment
				return null;
			}
			
			while(startPos >=0)
			{
				startPos = src.indexOf(',', startPos);
				
				if(startPos>=0 )
				{				
					//rewind back one char to see if it' not an escaped comma
					strTest = ZG_StringUtils.CleanupSpaces(src.substring(startPos-1, startPos));			
					// skip escaped commas - they are part of the string,
					// and not field separators				
					if(strTest == ("\\"))
					{									
						
						// This is an escaped comma inside a string.
						// remove  escape char from and increment startPos
						// so we can proceed traversing the string
						var start:String = src.substring(0,startPos-1);
						var  end:String = src.substring(startPos,src.length);
						src = start+end;
						startPos++;						
					}
					else
					{	
						// make sure not to overrun the commaPositions array 
						// we only handle 4 commas
						if(k >=commaPositions.length)
						{
							break;
						}											
						//increment pos so we can continue looking for the 
						//other commas in the string
						commaPositions[k++] = startPos++;					
					}			
				}		
			}
			// now that we know all comma positions, process the entries
			for( i =0 ; i < commaPositions.length; ++i)
			{
				// now that we have positions of all entries, process them.			
				// start position is either 0 ( for the first entry ) or the i index in the positions array
				startPos = (i==0?  0 : commaPositions[i-1]);
				// for the last entry use the length of the string
				endPos = (i+1 >= commaPositions.length? src.length : commaPositions[i]);
				if(startPos >=0 && endPos>=0)
				{
					// mark this field as set
					setFields[i] = true;
					// startPos points to the field delimiter, so skip past it unless we;re processing the first entry
					if(i> 0)
					{
						startPos++;
					}
					SetHostField(ret,src.substring(startPos,endPos),i);				
				}
			}
			// now check how many fields were set.
			// We allow omitting field delimiters,
			// make sure that the last field before last comma is set and bail - there is nothing after that
			for( i=0; i < setFields.length;++i)
			{
				if(!setFields[i])
				{
					// if this field is not set - find the previous good position
					// and use it as a startPos and string length as end pos
					startPos = (i == 0 ? 0 : commaPositions[i-1]+1);
					endPos = src.length;
					SetHostField(ret,src.substring(startPos,endPos),i);
					break;
				}			
			}
			
			if(!ret.IsValid())
			{
				ret = null;
			}
			return ret;
			
		}
		//---------------------------------------
		private static function SetHostField(host:FT_TargetHost, field:String , fieldNum:int ):void
		{		
			field = ZG_StringUtils.StripQuotes(StringUtil.trim(field));
			switch( fieldNum)
			{
				case 0:
					// host name 
					host.host = field;
					break;
				case 1:
					//username
					host.username = field;
					break;
				case 2:
					// password:
					host.password = field;
					break;
				case 3:
					// ssh key
					host.sshKey = field;
					break;
				case 4: 
					host.hostConfigID = host.HostConfigFromFile(field);
					break;
			}
		}
		/*public function set authMethod(value:int):void
		{
			_authMethod = value;
		}*/
	//-------------------------------------------
		

	}
}
