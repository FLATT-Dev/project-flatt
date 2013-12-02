package DesktopApp
{
	import FLATTPlugin.*;
	
	import Licensing.*;
	
	import TargetHostManagement.*;
	
	import com.ZG.Utility.*;
	
	import flash.display.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.*;
	

	public class FT_LicenseChecker
	{
		public function FT_LicenseChecker()
		{
		}
		//------------------------------------------------------------------
		// common routine to perform a license check on various UI items
		public static function AdjustForLicense(checkType:int,
												newObject:Object=null,
												existingObject:Object=null,
												parentWindow:Object =null,
												displayAlert:Boolean = true):Boolean
		{		
				
			switch(checkType)
			{
				case FT_LicenseManager.LIC_CHECK_NUM_HOSTS:
				{
					return AdjustForLicense_TargetHost(newObject as FT_TargetHost,existingObject as ArrayCollection,parentWindow,displayAlert);
				}
				case FT_LicenseManager.LIC_CHECK_NUM_PLUGINS:
				{
					return true;//CanAddPlugins(parentWindow,displayAlert);
				}
				case FT_LicenseManager.LIC_CHECK_NUM_TASKS:
				{
					return true;//CanAddTasks(existingObject as ArrayCollection,parentWindow,displayAlert);
				}
				case FT_LicenseManager.LIC_CHECK_NUM_REMOTE_PLUGINS:
				{
					return true;//CanAddRemotePlugins(newObject as int, parentWindow,displayAlert);
				}
			}
			
			return true;							
		}		
		//-------------------------------------------------------------
		// checks if licence num is not exceeded and optionally trims a host group to fit into the allowable limit
		public static function AdjustForLicense_TargetHost(host:FT_TargetHost,
														   existingColl:ArrayCollection,
														   parentWindow:Object,
														   displayAlert:Boolean):Boolean
		{
			
			var maxAllowed :int = FT_LicenseManager.GetInstance().LicenseCheck(FT_LicenseManager.LIC_CHECK_NUM_HOSTS);
			//Before going any further check if unlimited is allowed
			if(maxAllowed == FT_License.LIC_NUM_UNLIMITED)
			{
				return true;
			}
			// count containers in this case, cause a task is a container regardless empty or ot
			var numExisting:int = ZG_Utils.CountAll_ZGP_Objects(existingColl);
			// easy case - total num hosts is  already greater than number allowed.
			if( numExisting >= maxAllowed)
			{
				if(displayAlert)
				{
					
					// alert : your license only allows %d hosts
					Alert.show(
							ZG_Utils.TranslateString(
							ZG_StringUtils.Sprintf("Your license does not allow more than %d unique hosts.",maxAllowed )),
							ZG_Utils.TranslateString("License exceeded"),4,null);
				}
				
				return false;
			}
			if( host!=null && host.isContainer)
			{
				var numAllowed:int = maxAllowed-numExisting;
				// handle a case where adding n hosts from  the group would exceed the license.
				// trim the number of hosts to adjust
				if( host.numChildren > numAllowed )
				{
					// remove extra children from end
					
					for(var i:int = host.numChildren-1; i >=numAllowed; --i)
					{
						host.DeleteChildByIndex(i);
					}
					if(displayAlert)
					{
						Alert.show(
								ZG_Utils.TranslateString(
								ZG_StringUtils.Sprintf("Only adding %d hosts, not to exceed the license limit.",host.numChildren)),
								ZG_Utils.TranslateString("License exceeded"),4,parentWindow as Sprite);	
					}
				}
				
			}
			
			
			return true;
		}
		//----------------------------------------
		// see if num allowed plugins is not exceeded
		public static function CanAddPlugins(parentWindow:Object,displayAlert:Boolean):Boolean
		{
			var maxAllowed :int = FT_LicenseManager.GetInstance().LicenseCheck(FT_LicenseManager.LIC_CHECK_NUM_PLUGINS);
			//Before going any further check if unlimited is allowed
			if(maxAllowed == FT_License.LIC_NUM_UNLIMITED)
			{
				return true;
			}
			// count all plugins
			var numExisting:int = ZG_Utils.CountAll_ZGP_Objects(FT_PluginManager.GetInstance().containerColl);
			if( numExisting >= maxAllowed)
			{
				if(displayAlert)
				{
					Alert.show(
							ZG_Utils.TranslateString(
							ZG_StringUtils.Sprintf("Your license does not allow more than %d Actions.",maxAllowed )),
							ZG_Utils.TranslateString("License exceeded"),4,parentWindow as Sprite);
				}
				
				return false;
			}
			return true;
		}
		//-------------------------------------------------
		public static function CanAddTasks(taskList:ArrayCollection,parentWindow:Object,displayAlert:Boolean):Boolean
		{
			var maxAllowed :int = FT_LicenseManager.GetInstance().LicenseCheck(FT_LicenseManager.LIC_CHECK_NUM_TASKS);
			//Before going any further check if unlimited is allowed
			if(maxAllowed == FT_License.LIC_NUM_UNLIMITED)
			{
				return true;
			}
			// count all plugins
			var numExisting:int = taskList.length;
			if( numExisting >= maxAllowed)
			{
				if(displayAlert)
				{
					Alert.show(
							ZG_Utils.TranslateString(
							ZG_StringUtils.Sprintf("Your license does not allow more than %d tasks.",maxAllowed )),
							ZG_Utils.TranslateString("License exceeded"),4,parentWindow as Sprite);
				}
				
				return false;
			}
			return true;
		}
		//------------------------------------------------------------
		public static function CanAddRemotePlugins( numRemotePlugins:int,parentWindow:Object,displayAlert:Boolean):Boolean
		{
			var maxAllowed :int = FT_LicenseManager.GetInstance().LicenseCheck(FT_LicenseManager.LIC_CHECK_NUM_REMOTE_PLUGINS);
			//Before going any further check if unlimited is allowed
			if(maxAllowed == FT_License.LIC_NUM_UNLIMITED)
			{
				return true;
			}
			if( numRemotePlugins >= maxAllowed)
			{
				if(displayAlert)
				{
					Alert.show(
							ZG_Utils.TranslateString(
							ZG_StringUtils.Sprintf("Your license does not allow more than %d remote Actions.",maxAllowed )),
							ZG_Utils.TranslateString("License exceeded"),4,parentWindow as Sprite);
				}
				
				return false;
			}
			
			return true;
			
		}
	}
}