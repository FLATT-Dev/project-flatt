/*******************************************************************************
 * FT_Prefs.as
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
package Application
{
	
	import TargetHostManagement.FT_TargetHost;
	
	import Utility.*;
	
	import com.ZG.Prefs.ZG_LocalPrefs;
	import com.ZG.Utility.*;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.XMLListCollection;
	
	
	public class FT_Prefs extends ZG_LocalPrefs
	{

		private static var KEY_FLATT_APP_PREFS:String	="FLATTPrefs";
		private static var CUR_PREFS_VERSION:String = "1";
		private static var s_Instance:FT_Prefs;
		public static var PROXY_TYPE_INTERNAL:int = 0;
		public static var PROXY_TYPE_STANDALONE_SSL:int = 1;
		public static var PROXY_TYPE_TOMCAT:int = 2;
		public static var DEF_CERT:String=	"-----BEGIN CERTIFICATE-----\n"+
											"MIIDSjCCAjKgAwIBAgIETzSe9DANBgkqhkiG9w0BAQUFADBnMQswCQYDVQQGEwJVUzELMAkGA1UE\n"+
											"CBMCQ0ExEjAQBgNVBAcTCVNhbiBEaWVnbzESMBAGA1UEChMJRkxBVFQgSW5jMRMwEQYDVQQLEwpG\n"+
											"TEFUVCBVbml0MQ4wDAYDVQQDEwVGTEFUVDAeFw0xMjAyMTAwNDM3MDhaFw0xNzAxMTQwNDM3MDha\n"+
											"MGcxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTESMBAGA1UEBxMJU2FuIERpZWdvMRIwEAYDVQQK\n"+
											"EwlGTEFUVCBJbmMxEzARBgNVBAsTCkZMQVRUIFVuaXQxDjAMBgNVBAMTBUZMQVRUMIIBIjANBgkq\n"+
											"hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAi/fvy7VCXT/RK11v328g3bcR8w6Sn1fad0TekFVg0+Jo\n"+
											"8QaJeZ/oXKn00cavoIXt+nhqfh1Hm3uVptnUyh4LwNPRotVazfVJxzpGArugJCR6fvBeuEhKg/7t\n"+
											"+gTRp1iVKD/HV0/kVx5NW8WM9uqtepgr0whTtPY/sbCFZ5RfQtxf64qPkAzB6vxkaCnwRiyuJhAq\n"+
											"EyrKG9b7BhnLrF3xtjV2vyAkNp8rEGvtCgJVXJJNizPH2TdzvVTvh/+ArOxTDNxgA4yV5Ccl9HKl\n"+
											"bV/7RVnnaX4+7Ec4nYcd1Vv0jJKdavbOMzFrnbSeVXIMy6jZ93gfBLmU4WDJeLdY3OGrlwIDAQAB\n"+
											"MA0GCSqGSIb3DQEBBQUAA4IBAQAinD028Li6SH1nX+M6s7vR7tpH4HOcXpx7UlBgxqXltI6B/DrK\n"+
											"QvmMPG5hb/cesMhnYy5/lYK70Saao8waf34CFwYV/C1Ajql2GGS+Rj18k+w4wpkmmIgc/59tfM3g\n"+
											"5fWC849iWOfaswMEf/I8pQXIBijBM1wKKl9UBAEmFPtPWoyylcJSnesma9/qcZeOoqCxN18jV8kX\n"+
											"7wiRqYr/Wsz66wg5mOA87ufJUpBb8ayIO+qQcOop+kDDSI+XR6Erelrxy+FqoMf9ATGwNNI1Nn+n\n"+
											"nXy5E7QQHojP69sjlAFTXejqFQa7mMD5xVcLwHkF2TIMAK4Oi4HO0JgxfFw9xfy+\n"+
											"-----END CERTIFICATE-----";
	
		//private var _hostList:Array; -- not yet -TODO
		// deal with this in optimization phase
		
		// skeleton prefs
		private static var DEF_PREFS:String = 
			"<FLATTPrefs>"+
			"<Version>" + CUR_PREFS_VERSION + "</Version>"+
			"<LastHostIndex>0</LastHostIndex>"+		
			"<SavedHosts></SavedHosts>" +
			"<MasterUserName></MasterUserName>"+
			"<MasterPassword></MasterPassword>" +
			"<RepoUrls></RepoUrls>"+
			"<ProxyType>0</ProxyType>"+
			"<ProxyURL></ProxyURL>"+
			"<ProxyAddress></ProxyAddress>"+  // used with standalone proxy
			"<ProxyPort>-1</ProxyPort>"+ 	// when proxy cert does not exist - use default one
			"<CertIndex>0</CertIndex>"+
			"<CheckHostIdent>false</CheckHostIdent>"+
			"</FLATTPrefs>";
		
		
		private var _prefsXml:XML;
		// in memory hosts list so that we don't have to read it from prefs all the time
		private var _hostsList:Array;
		
		public function FT_Prefs(target:IEventDispatcher=null)
		{
			super(target);
			var xmlString:String = GetPref(KEY_FLATT_APP_PREFS) as String;
			
			_prefsXml = new XML((xmlString == null)?DEF_PREFS:xmlString);		
		}
		//-----------------------------------------------
		public static function GetInstance():FT_Prefs
		{			
			
			if( s_Instance == null )
			{
				s_Instance = new FT_Prefs();
			}							
			return s_Instance;
		}
		//--------------------------------------------
		//  preload this to optimize for speed.
		public function GetSavedHostsList(forceRead:Boolean = false):Array
		{
			if(_hostsList!=null && !forceRead)
			{
				return _hostsList;
			}
			
			_hostsList = new Array();
			
			var hosts:XMLList = _prefsXml.SavedHosts.Host;
			if( hosts!=null)
			{
				for(var i:int =0; i < hosts.length();++i)
				{
					ReadHost(hosts[i],_hostsList);
				}				
			}
			
			return _hostsList;
		}	
		//------------------------------------------------
		// find a target host in the list. reload prefs if needed
		// if host is a container - search for a name, otherwise 
		public function FindTargetHost(addrOrName:String,forceReload:Boolean = false):FT_TargetHost
		{
			
			var hostsList:Array = GetSavedHostsList(forceReload);
			if( hostsList!=null )
			{
				for(var i: int =0; i < hostsList.length; ++i )
				{
					if(hostsList[i].name == addrOrName)
					{
						return hostsList[i];
					}	
				}
			}
			
			return null;
		}
		//-------------------------------------------
		private function ReadHost(hostXml:XML, ret:Array):void
		{
			var host:FT_TargetHost = new FT_TargetHost();
			host.name = hostXml.name;
			//set container status of the host.
			// an empty group is a container even though it does not have any children	
			
			host.isContainer = (hostXml.@isContainer == "true");
			
			// always read username/password.now containers may have them
			host.username = hostXml.username;
			host.password = hostXml.password;
			host.sshKey = hostXml.sshkey;
			host.hostConfigID = hostXml.configid;
						
			var hostListXml:XMLList = hostXml.Child;
			// this means it is a group
			if(hostListXml!=null && host.isContainer)
			{
				for(var i:int = 0; i < hostListXml.length();++i)
				{				
					var cur:XML = hostListXml[i];
					var child:FT_TargetHost = new FT_TargetHost();
					child.host 		= hostListXml[i].address;
					child.username  = hostListXml[i].username;
					child.password  = hostListXml[i].password;
					child.sshKey 	= hostListXml[i].sshkey;
					child.hostConfigID = hostListXml[i].configid;
					
					child.isContainer = false;
					host.AddChild(child);
				}
				// has chi				
			}
			else
			{
				host.host = 	hostXml.address;
				
			}
						
			ret.push(host);
			
		}
		//--------------------------------------------
		public function GetLastHostIndex():int
		{
			return _prefsXml.LastHostIndex;
		}
		//--------------------------------------------
		public function SaveHosts(hostList:Array, savedComboIndex:int = -1):void
		{
			
			// update in memory list	
			_hostsList = hostList;
			// remove existing saved host section			
			delete(_prefsXml.SavedHosts);
			var newSavedHostsList:XML = new XML(<SavedHosts></SavedHosts>);
			// now that we have a saved hosts block, let's fill it
			
			for(var i:int =0; i <hostList.length; ++i )
			{
				/*var cur:FT_TargetHost = hostsList[i];
				var curHostXml:XML = new XML(<Host></Host>);
				
				curHostXml.appendChild(<address>{cur.host}</address>);
				curHostXml.appendChild(<username>{cur.username}</username>);
				curHostXml.appendChild(<password>{cur.password}</password>);*/
				// amd now add to list of hosts
				newSavedHostsList.appendChild(AppendHost(hostList[i]));				
			}
			// and save the new list
			_prefsXml.appendChild(newSavedHostsList);
			// host index is used only for combo box
			if(savedComboIndex >=0)
			{
				SetSavedHostsIndex(savedComboIndex);
			}
			// now save prefs
			Commit();			
		}
	
		//--------------------------------------------
		private function AppendHost(host:FT_TargetHost):XML
		{
			var hostXml:XML = new XML(<Host isContainer="false"></Host>);
			
			// add common tags
			hostXml.name = host.name;
			hostXml.@isContainer = host.isContainer;	
			//groups can also have creds now
			hostXml.appendChild(<username>{host.username}</username>);
			hostXml.appendChild(<password>{host.password}</password>);
			hostXml.appendChild(<sshkey>{host.GetSshKeyPath()}</sshkey>);
			hostXml.appendChild(<configid>{host.hostConfigID}</configid>);
			
			var childrenArr:Array = host.InternalGetChildren().toArray();
			// a group can be empty -still need to save it a a group
			if(childrenArr.length > 0  || (host.isContainer))
			{
				for(var i: int = 0; i < childrenArr.length;++i)
				{
					var cur:FT_TargetHost = childrenArr[i];
					var curChildXml:XML = new XML(<Child></Child>);
					
					curChildXml.appendChild(<address>{cur.host}</address>);
					curChildXml.appendChild(<username>{cur.username}</username>);
					curChildXml.appendChild(<password>{cur.password}</password>);
					curChildXml.appendChild(<sshkey>{cur.GetSshKeyPath()}</sshkey>);
					curChildXml.appendChild(<configid>{cur.hostConfigID}</configid>);
					
					// amd now add to list of hosts
					hostXml.appendChild(curChildXml);			
				}
			}
			else
			{
				hostXml.appendChild(<address>{host.host}</address>);				
			}
			return hostXml;
		}
		//--------------------------------------------
		public function SetSavedHostsIndex(index:int):void
		{
			_prefsXml.LastHostIndex = index;
		}
		//----------------------------------------------
		public function GetLicenseExpirationDate():Number
		{
			return (_prefsXml.hasOwnProperty("LicenseExpDate")? new Number(_prefsXml.LicenseExpDate) : 0)
		}
		//-----------------------------------------------
		// save current date as trial expiration date
		public function SaveLicenseExpirationDate(expDateSecs:String):void
		{
			
			if(!_prefsXml.hasOwnProperty("LicenseExpDate"))
			{
				_prefsXml.appendChild(<LicenseExpDate>{expDateSecs}</LicenseExpDate>);
			}
			else
			{
				_prefsXml.LicenseExpDate = expDateSecs;
			}
			// write out
			Commit();
		}
		
		// Prefs below are in pres dialog and must be explicitly committed.
		//----------------------------------------
		public function GetMasterPassword():String
		{
			return (_prefsXml.hasOwnProperty("MasterPassword")? _prefsXml.MasterPassword : "")
		}
		//----------------------------------------
		public function GetMasterUserName():String
		{
			return (_prefsXml.hasOwnProperty("MasterUserName")?_prefsXml.MasterUserName : "");
		}
		//-----------------------
		public function SaveMasterUserNamePassword(username:String, passwd:String):void
		{
			
			if(!_prefsXml.hasOwnProperty("MasterPassword"))
			{
				_prefsXml.appendChild(<MasterPassword>{passwd}</MasterPassword>);
			}
			else
			{
				_prefsXml.MasterPassword = passwd;
			}
			
			if(!_prefsXml.hasOwnProperty("MasterUserName"))
			{
				_prefsXml.appendChild(<MasterUserName>{username}</MasterUserName>);
			}
			else
			{
				_prefsXml.MasterUserName = username;
			}									
		}
		//----------------------------------------
		public function GetMasterSshKeyPath():String
		{
			return (_prefsXml.hasOwnProperty("MasterSshKeyPath")? _prefsXml.MasterSshKeyPath : "")
		}
		//----------------------------------------
		public function SaveMasterSshKeyPath(keyPath:String):void
		{
			if(!_prefsXml.hasOwnProperty("MasterSshKeyPath"))
			{
				_prefsXml.appendChild(<MasterSshKeyPath>{keyPath}</MasterSshKeyPath>);
			}
			else
			{
				_prefsXml.MasterSshKeyPath = keyPath;
			}	
		}
		//------------------------------------------------
		public function GetRepos():XML
		{
			return (_prefsXml.hasOwnProperty("Repos")?new XML(_prefsXml.Repos) : null);				
		}
		//------------------------------------------------
		// returns a list of Repo xml structures
		public function GetReposList():XMLList
		{
			var repoXML:XML = GetRepos();
			
			if(repoXML!=null)
			{				
				return (repoXML.Repo);						
			}
			return null;
		}
		//---------------------------------------------------
		// find a given repo by url
		public function GetRepoByURL(url:String):XML
		{
			 var repoList:XMLList = GetReposList();
			 if(repoList!=null)
			 {
				 for(var i:int =0; i < repoList.length();++i)
				 {
					 if( repoList[i].@url == url )
					 {
						 return repoList[i];
					 }
				 }
			 	
			 }
			 return null;
		}
		//----------------------------------------------------
		public function SaveRepos(repos:XML):void
		{			
			if(repos!=null)
			{
				if(!_prefsXml.hasOwnProperty("Repos"))
				{
					_prefsXml.appendChild(repos);
				}
				else
				{
					_prefsXml.Repos = repos;
				}
			}
		}
		//----------------------------------------------------
		public function GetProxyType():int
		{
			var ret:int = PROXY_TYPE_INTERNAL; //default to using internal proxy
			
			if(_prefsXml.hasOwnProperty("ProxyType"))
			{
				ret = ZG_StringUtils.StringToNumEx(_prefsXml.ProxyType);				
			}
			// validate just in case
			if( ret < PROXY_TYPE_INTERNAL || ret > PROXY_TYPE_TOMCAT )
			{
				ret = PROXY_TYPE_INTERNAL;
			}
				
			return ret;
		}
		//----------------------------------------------------
		public function SetProxyType( val: int ):void
		{
			
			if(!_prefsXml.hasOwnProperty("ProxyType"))
			{
				_prefsXml.appendChild(<ProxyType>{val}</ProxyType>);			
			}
			else
			{
				_prefsXml.ProxyType = val;
			}
		}
		//---------------------------------
		public function GetProxyUrl():String
		{
			return (_prefsXml.hasOwnProperty("ProxyURL")? _prefsXml.ProxyURL : "")
		}
		//-------------------------------
		public function SetProxyUrl( val: String ):void
		{
			
			if(!_prefsXml.hasOwnProperty("ProxyURL"))
			{
				_prefsXml.appendChild(<ProxyURL>{val}</ProxyURL>);			
			}
			else
			{
				_prefsXml.ProxyURL = val;
			}
		}
		//---------------------------------
		public function GetProxyAddress():String
		{
			return (_prefsXml.hasOwnProperty("ProxyAddress")? _prefsXml.ProxyAddress : "")
		}
		//-------------------------------
		public function SetProxyAddress( val: String ):void
		{
			
			if(!_prefsXml.hasOwnProperty("ProxyAddress"))
			{
				_prefsXml.appendChild(<ProxyAddress>{val}</ProxyAddress>);			
			}
			else
			{
				_prefsXml.ProxyAddress = val;
			}
		}
		//----------------------------------------------------
		public function GetProxyPort():int
		{
			var ret:int = -1;
			
			if(_prefsXml.hasOwnProperty("ProxyPort"))
			{
				ret = ZG_StringUtils.StringToNumEx(_prefsXml.ProxyPort);				
			}			
			return ret;
		}
		//----------------------------------------------------
		public function SetProxyPort( val: int ):void
		{
			
			if(!_prefsXml.hasOwnProperty("ProxyPort"))
			{
				_prefsXml.appendChild(<ProxyPort>{val}</ProxyPort>);			
			}
			else
			{
				_prefsXml.ProxyPort = val;
			}
			
		}
		//---------------------------------
		//TODO. This is temporary.  would be more efficient to save certs in a file and save index in prefs
		// Write CertManager class that reading and writing certs to file sysem
		// Return default cetrificate when none is available
		public function GetProxyCert():String
		{
			return (_prefsXml.hasOwnProperty("ProxyCert")? ZG_StringUtils.Base64Decode(_prefsXml.ProxyCert) : DEF_CERT)
		}
		//-------------------------------
		public function SetProxyCert( val: String ):void
		{
			
			var b64Val:String = ZG_StringUtils.Base64Encode(val);
			if(!_prefsXml.hasOwnProperty("ProxyCert"))
			{
				_prefsXml.appendChild(<ProxyCert>{b64Val}</ProxyCert>);			
			}
			else
			{
				_prefsXml.ProxyCert = b64Val;
			}
		}
		
		public function GetCheckHostIdentity():Boolean
		{
			if(_prefsXml.hasOwnProperty("CheckHostIdent"))
			{
				return(_prefsXml.CheckHostIdent=="false" ? false : true);
			}
			return false;
		}
		//-------------------------------
		public function SetCheckHostIdentity( val:Boolean ):void
		{
					
			if(!_prefsXml.hasOwnProperty("CheckHostIdent"))
			{
				_prefsXml.appendChild(<CheckHostIdent>{val}</CheckHostIdent>);			
			}
			else
			{
				_prefsXml.CheckHostIdent = val;
			}
		}
		//------------------------------------------
		// TODO: This is not used now, will be when there is a cert manager class that handles certs on file system
		// and only current index is written to prefs
		//----------------------------------------------------
		public function GetCertIndex():int
		{
			var ret:int = -1;
			
			if(_prefsXml.hasOwnProperty("CertIndex"))
			{
				ret = ZG_StringUtils.StringToNumEx(_prefsXml.CertIndex);				
			}
			
			return ret;
		}
		//----------------------------------------------------
		public function SetCertIndex( val: int ):void
		{			
			if(!_prefsXml.hasOwnProperty("CertIndex"))
			{
				_prefsXml.appendChild(<CertIndex>{val}</CertIndex>);			
			}
			else
			{
				_prefsXml.CertIndex = val;
			}			
		}
		//----------------------------
		public function GetLicenseKey():String
		{
			var ret:String = "";
			
			if(_prefsXml.hasOwnProperty("LicenseKey"))
			{
				ret = _prefsXml.LicenseKey;				
			}
			return ret;
		}
		//----------------------------------------------------
		public function SetLicenseKey( val: String ):void
		{			
			if(!_prefsXml.hasOwnProperty("LicenseKey"))
			{
				_prefsXml.appendChild(<LicenseKey>{val}</LicenseKey>);			
			}
			else
			{
				_prefsXml.LicenseKey = val;
			}
			// write the prefs file
			Commit();
		}
		
		//---------------------------------------------
		public function GetHostScanStartIP():String
		{
			var ret:String="0.0.0.0";
			
			if(_prefsXml.hasOwnProperty("HostScanStartIP"))
			{
				ret = (_prefsXml.HostScanStartIP);				
			}			
			return ret;
		}
		//----------------------------------------------------
		public function SetHostScanStartIP( val: String ):void
		{
			
			if(!_prefsXml.hasOwnProperty("HostScanStartIP"))
			{
				_prefsXml.appendChild(<HostScanStartIP>{val}</HostScanStartIP>);			
			}
			else
			{
				_prefsXml.HostScanStartIP = val;
			}
			
		}
		//---------------------------------------------
		public function GetHostScanEndIP():String
		{
			var ret:String="0.0.0.0";
			
			if(_prefsXml.hasOwnProperty("HostScanEndIP"))
			{
				ret = (_prefsXml.HostScanEndIP);				
			}			
			return ret;
		}
		//----------------------------------------------------
		public function SetHostScanEndIP( val: String ):void
		{
			
			if(!_prefsXml.hasOwnProperty("HostScanEndIP"))
			{
				_prefsXml.appendChild(<HostScanEndIP>{val}</HostScanEndIP>);			
			}
			else
			{
				_prefsXml.HostScanEndIP = val;
			}
			
		}
		//-------------------------
		public function GetScanHostsOnStartup():Boolean
		{
			var ret:Boolean=false;
			
			if(_prefsXml.hasOwnProperty("ScanHostsOnStartup"))
			{
				ret = (_prefsXml.ScanHostsOnStartup == "true");				
			}			
			return ret;
		}
		//----------------------------------------------------
		public function SetScanHostsOnStartup( val: Boolean ):void
		{
			
			if(!_prefsXml.hasOwnProperty("ScanHostsOnStartup"))
			{
				_prefsXml.appendChild(<ScanHostsOnStartup>{val}</ScanHostsOnStartup>);			
			}
			else
			{
				_prefsXml.ScanHostsOnStartup = val;
			}
			
		}
		//-------------------------
		public function GetEnableTooltips():Boolean
		{
			var ret:Boolean=true;// tooltips enabled by default
			
			if(_prefsXml.hasOwnProperty("EnableTooltips"))
			{
				ret = (_prefsXml.EnableTooltips == "true");				
			}			
			return ret;
		}
		//----------------------------------------------------
		public function SetEnableTooltips( val: Boolean ):void
		{
			
			if(!_prefsXml.hasOwnProperty("EnableTooltips"))
			{
				_prefsXml.appendChild(<EnableTooltips>{val}</EnableTooltips>);			
			}
			else
			{
				_prefsXml.EnableTooltips = val;
			}
			
		}
		//----------------------------------------------
		//----------------------------------------
		public function GetSavedProxyVersion():String
		{
			return (_prefsXml.hasOwnProperty("ProxyVersion")? _prefsXml.ProxyVersion : "")
		}
		//----------------------------------------
		public function SaveProxyVersion(val:String):void
		{
			if(!_prefsXml.hasOwnProperty("ProxyVersion"))
			{
				_prefsXml.appendChild(<ProxyVersion>{val}</ProxyVersion>);
			}
			else
			{
				_prefsXml.ProxyVersion = val;
			}
			Commit();
		}
		//----------------------------------------
		public function GetSavedSvnClientVersion():String
		{
			return (_prefsXml.hasOwnProperty("SvnClientVersion")? _prefsXml.SvnClientVersion : "")
		}
		//----------------------------------------
		public function SaveSvnClientVersion(val:String):void
		{
			if(!_prefsXml.hasOwnProperty("SvnClientVersion"))
			{
				_prefsXml.appendChild(<SvnClientVersion>{val}</SvnClientVersion>);
			}
			else
			{
				_prefsXml.SvnClientVersion = val;
			}
			Commit();
		}
		//
		//-------------------------
		public function GetQuickstartShown():Boolean
		{
			var ret:Boolean=false;// tooltips enabled by default
			
			if(_prefsXml.hasOwnProperty("QuickstartShown"))
			{
				ret = (_prefsXml.QuickstartShown == "true");				
			}			
			return ret;
		}
		//----------------------------------------------------
		public function SetQuickstartShown( val: Boolean ):void
		{
			
			if(!_prefsXml.hasOwnProperty("QuickstartShown"))
			{
				_prefsXml.appendChild(<QuickstartShown>{val}</QuickstartShown>);			
			}
			else
			{
				_prefsXml.QuickstartShown = val;
			}
			Commit();
			
		}
		//-------------------------
		// Commit prefs to storage
		public function Commit():void
		{
			SetPref(KEY_FLATT_APP_PREFS,_prefsXml.toXMLString());
		}
		
			
	}//class	
}//package
