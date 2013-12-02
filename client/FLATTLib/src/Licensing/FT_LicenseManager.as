/*******************************************************************************
 * FT_LicenseManager.as
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
package Licensing
{
	import Application.FT_Prefs;
	
	import Utility.*;
	
	import com.ZG.Events.ZG_EventDispatcher;
	
	import flash.events.*;
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	import mx.core.FlexTextField;
	
	
	// This class handles registration of the app and trial expiration
	public class FT_LicenseManager extends ZG_EventDispatcher
	{
		
		public static const LIC_CHECK_NUM_HOSTS:int 	= 0;
		public static const LIC_CHECK_NUM_TASKS:int 	= 1;
		public static const LIC_CHECK_NUM_PLUGINS:int	= 2;
		public static const LIC_CHECK_NUM_REMOTE_PLUGINS:int  	= 3;
				
		public static var FT_EVT_LICENCE_MGR:String				= "evtLicenseMgr"; // any License Mgr event 
		private static const REG_CHECK_INTERVAL:int  = 86400000; // 24 hrs in milliseconds 
		
		
		private static var s_Instance:FT_LicenseManager;
		private var _license:FT_License = new FT_License();
		private var _savedDuration:int = 0;
		private var _savedType:int;
		
		// This  is the beginning of registration implementation
		// Not finished, or tested
		public function FT_LicenseManager(target:IEventDispatcher=null)
		{
			super(target);
			InitLicense();
			var timer:Timer = new Timer(REG_CHECK_INTERVAL);			
			timer.addEventListener(TimerEvent.TIMER, OnLicenseTimer,false,0, true);			
			timer.start();
		}
		//-----------------------------------------------------
		public static function GetInstance():FT_LicenseManager
		{						
			if( s_Instance == null )
			{
				s_Instance = new FT_LicenseManager();
			}							
			return s_Instance;
		}
		
		// Check if the operation is allowed. Called by various parts of the UI
		// Returns either a number of allowed items or whether the operation is allowed in general
		// For now only num items is returned
		public function LicenseCheck(type:int):int
		{
			switch(type)
			{
				case LIC_CHECK_NUM_HOSTS:
					return _license.numHosts;
				
				/*case LIC_CHECK_NUM_PLUGINS:
					return _license.numPlugins;
					
				case LIC_CHECK_NUM_TASKS:
					return  _license.numTasks;
					
				case LIC_CHECK_NUM_REMOTE_PLUGINS:
					return _license.numRemotePlugins;*/
				default:
					break;
					
			}
			// allow everything else
			return FT_License.LIC_NUM_UNLIMITED;
		}
		//-----------------------------------------------------
		// human readable form
		public function LicenseCheck_Str(type:int):String
		{
			var val:Number = LicenseCheck(type);			
			return (val == FT_License.LIC_NUM_UNLIMITED ? "Unlimited": val.toString());
		}
		//-----------------------------------------------------
		// get the string representation of the license type
		public function get licenseTypeString():String
		{
			return _license.GetTypeString();
		}
		//--------------------------------------
		// get numeric type
		public function get licenseType():int
		{
			return _license.licType;
		}
		//-------------------------------------------------------		
		protected function get license():FT_License
		{
			return _license;
		}
		//------------------------------------
		// called from UI when user inputs the license.
		// checks if the license is OK and sets it to demo if it is not.
		//If license is ok it sets expiration time of the license to duration + current year
		public function SaveLicense(licKey:String,setToDemo:Boolean = true):Boolean
		{			
			var ret:Boolean ;
			var curLic:String = FT_Prefs.GetInstance().GetLicenseKey();
			// if same license is entered - do nothing
			if(curLic == licKey)
			{
				return true;
			}
			// otherwise parse the key and init license object from it
			var newLicense:FT_License = new FT_License();
			ret = newLicense.InitFromKey(licKey,setToDemo);
			// license was inited successfully - create a time stamp that is <duration> years after now, save it
			// and update the license object
			if(ret)
			{
				// create timestamp only if either duration or type are different or there is no timestamp
				if((newLicense.duration != _savedDuration) || 
				   (newLicense.licType!= _savedType) ||
				   (FT_Prefs.GetInstance().GetLicenseExpirationDate() == 0))					
				{
					_license = newLicense;
					var date:Date = new Date();
					// duration is in months
					// convert months to seconds and add to current time
					date.month+= license.duration;
					//date.fullYear+=license.duration;
					FT_Prefs.GetInstance().SaveLicenseExpirationDate(date.time.toString());	
					// now save new values
					_savedDuration = _license.duration;
					_savedType = _license.licType;
				}
				// and save the license key
				FT_Prefs.GetInstance().SetLicenseKey(licKey);
				// resave duration and type now that they changed
				return true;
			}
			return false;
		}
		//------------------------------------------------------------------------
		// Validate the license
		// this routine may change the duration of the license.
		// save old duration so you can compare it to the new one when savinh
		public function ValidateLicense(licKey:String):Boolean
		{
			_savedDuration = license.duration;
			_savedType = license.licType;
			
			return license.InitFromKey(licKey,false); // don't set to demo
		}
		//--------------------------------------------
		public function get licenseDuration():int
		{
			return _license.duration;
		}
		
		//-----------------------------------------------------
		// called on startup and then once in 24 hrs
		public function CheckLicenseExpiration():void
		{			
						
			// is this a non demo license?			
			if(_license.licType!= FT_License.LIC_TYPE_DEMO)
			{
				var evtType:String = "";
				var expDateSecs:Number = FT_Prefs.GetInstance().GetLicenseExpirationDate();				
				
				if(expDateSecs > 0 )
				{
					// got a valid expiration date - check if license expired
					var now:Number = new Date().time;
					if( now > expDateSecs)
					{
						//if license expired - force it back to demo
						
						evtType = FT_Events.FT_EVT_LICENSE_EXPIRED;
					}
				}
				else
				{
					//  expiration date not found on a non demo license - this is invalid condition, bail					
					evtType = FT_Events.FT_EVT_LICENSE_INVALID;
				}
				// do we need to set to demo and dispatch an event?
				if(evtType.length > 0)
				{					
					SetToDemo();
					DispatchEvent(evtType);
				}
			}
			// otherwise its a demo license and we don't care about expiration date
			// if we have a valid expiration date	
		}
		
		//----------------------------------------------------------
		private function OnLicenseTimer(e:TimerEvent):void
		{
			trace("OnLicenseTimer: CallingCheckLicenseExpiration");
			CheckLicenseExpiration();
		}
		//------------------------------------------------------
		// Forces a licence to demo
		public function SetToDemo():void
		{
			// zero everythin out
			FT_Prefs.GetInstance().SetLicenseKey("");
			FT_Prefs.GetInstance().SaveLicenseExpirationDate("");
			// will set license to demo
			InitLicense();
			
		}
		
		//--------------------------------------
		public function InitLicense():void
		{
			//reread whatever we have stored in prefs
			_savedDuration = license.duration;
			_savedType = license.licType;
			license.InitFromKey(FT_Prefs.GetInstance().GetLicenseKey());			
		}
	}
}
