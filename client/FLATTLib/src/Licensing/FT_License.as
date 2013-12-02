/*******************************************************************************
 * FT_License.as
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
	import flash.utils.Dictionary;

	public class FT_License extends Object
	{
		import com.ZG.Utility.*;
		
		public static const LIC_TYPE_GARNET:int 	= 0;
		public static const LIC_TYPE_EMERALD:int 	= 1;
		public static const LIC_TYPE_OPAL:int 		= 2;
		public static const LIC_TYPE_SAPPHIRE:int 	= 3;
		public static const LIC_TYPE_RUBY:int 		= 4;
		public static const LIC_TYPE_UNLIMITED:int	= 5;
		public static const LIC_TYPE_CUSTOM:int 	= 6;
		public static const LIC_TYPE_DEMO:int		= 7; //this is for info	
		public static const LIC_TYPE_NUM:int		= 8;// number of license types
		
		public static const LIC_DURATION_UNDEFINED:int = 0;
		public static const LIC_DURATION_MAX:int = 255; // in months, that's a lot of years - how much fits in a byte
		
		public static const LIC_DEF_NUM_PLUGINS:int = 10;
		public static const LIC_DEF_NUM_HOSTS:int = 5;
		public static const LIC_DEF_NUM_TASKS:int = 5;
		public static const LIC_DEF_NUM_REMOTE_PLUGINS:int = 10;
		public static const LIC_NUM_UNLIMITED:int = -1;
		
		
		
		private var _licType:uint = LIC_TYPE_DEMO;
		private var _numPlugins:uint = LIC_DEF_NUM_PLUGINS;
		private var _numHosts:uint =   LIC_DEF_NUM_HOSTS;
		private var _numTasks:uint =   LIC_DEF_NUM_TASKS;
		private var _numRemotePlugins:uint = LIC_DEF_NUM_REMOTE_PLUGINS;
		private var _duration:uint = LIC_DURATION_UNDEFINED; // duration of license. can be 1, 2, or 3 years, 0 if undefined
		
		private var _licTypes:Array;
		public static const CUR_LIC_VER:int = 2;
		private var _licVersion:int = CUR_LIC_VER;
	
		
		public function FT_License()
		{
			super();
			
			// Order is important!
			_licTypes = new Array("Garnet","Emerald","Opal","Sapphire","Ruby","Unlimited","Custom","Demo");
								  
		}
		//--------------------------------------------------
		// TODO: decode the key and extract license type and capabilities
		public function InitFromKey(licKey:String,setToDemo:Boolean = true):Boolean
		{
			// if existing license could not be verified
			var ret:Boolean = false;
			var intVal:Number;
			var typeDur:int;
			if(licKey!="")
			{
				var groups:Array = licKey.split("-");
				if(groups !=null && groups.length >=4)
				{
					// first decipher version type and duration
					//must prepend with 0x to indicate it's a hex string
					intVal = new Number("0x"+groups[4]);// ZG_StringUtils.StringToNumEx("0x"+groups[4]);
					// extract version  in the 2 upper bytes
					_licVersion = intVal >> 16;
					// type and duration is in the lower 2 bytes short, 1 bytes each 
					typeDur  = intVal &0xffff;
				}
				
				switch(_licVersion)
				{
					case 2:
						ret = ParseV2(groups,typeDur);
						break;
				
				}
			}
			if(!ret)
			{
				if(setToDemo)
				{
					_licType = LIC_TYPE_DEMO;
					
				}
			}
			// if license is unlimited or demo -sets the values correctly
			UpdateDemoOrUnlimited();
			return ret;
				
			
		}
		//--------------------------------------------------
		public function get numHosts():int
		{
			return _numHosts;
		}
		//--------------------------------------------------
		public function set numHosts(value:int):void
		{
			_numHosts = value;
		}
		//--------------------------------------------------
		public function get numPlugins():int
		{
			return _numPlugins;
		}
		//--------------------------------------------------
		public function set numPlugins(value:int):void
		{
			_numPlugins = value;
		}
		//--------------------------------------------------
		public function get licType():int
		{
			return _licType;
		}
		//--------------------------------------------------
		public function set licType(value:int):void
		{
			_licType = value;
		}
		//--------------------------------------------------
		public function get numTasks():int
		{
			return _numTasks;
		}
		//--------------------------------------------------
		public function set numTasks(value:int):void
		{
			_numTasks = value;
		}
		//--------------------------------------------------
		public function get numRemotePlugins():int
		{
			return _numRemotePlugins;
		}
		//--------------------------------------------------
		public function set numRemotePlugins(value:int):void
		{
			_numRemotePlugins = value;
		}
		//--------------------------------------------------
		// set the licensee functionality according to type.
		// make sure duration is set to undefined when in demo mode.
		private function UpdateDemoOrUnlimited():void
		{
			switch (_licType)
			{				
				case LIC_TYPE_UNLIMITED:
					SetLicValues(LIC_NUM_UNLIMITED,LIC_NUM_UNLIMITED,LIC_NUM_UNLIMITED,LIC_NUM_UNLIMITED);
					break;
				case LIC_TYPE_DEMO:
					SetLicValues(LIC_DEF_NUM_PLUGINS,LIC_DEF_NUM_HOSTS,LIC_DEF_NUM_TASKS,LIC_DEF_NUM_REMOTE_PLUGINS);
					_duration = LIC_DURATION_UNDEFINED;
					break;
			}
		}
		//-------------------------------------------
		// set license values
		protected function SetLicValues(val_NumPlugins:int, 
										val_NumHosts:int,  
										val_NumTasks:int, 
										val_NumRemotes:int):void
		{
			numPlugins = val_NumPlugins;
			numTasks = val_NumTasks;
			numHosts = val_NumHosts;
			numRemotePlugins = val_NumRemotes;
		}	
		//-------------------------------------------------------
		public function get duration():int
		{
			return _duration;
		}
		//-------------------------------------------------------
		public function set duration(value:int):void
		{
			_duration = value;
		}
		//------------------------------------
		/*
			Version 2 license format is as follows:
			[long]-[short]-[long]-[short]-[long]-[10 bytes]
			
			long 1 
			{		
				Actions:2 upper bytes
				Remote actions:2 lower bytes
			}
			random 2 bytes
			long 2 
			{
				Hosts: 2 upper bytes
				tasks: 2 lower bytes
			}
			random 2 bytes
			long 3 
			{
				Version : 2 upper bytes
				Type : 1 lower byte
				Duration in years: 1 lower byte
			}		
			A "-" character is used as a separator.
			Example:
			cb210a4-dbe7-18881496-413a-20606-726ddd51629e
		*/
		private function ParseV2(groups:Array,typeDur:uint):Boolean
		{
			//actions and remote actions
			// XX tell the number object that the string contains hex digits, otherwise it creates a decimal number object
			var intVal:Number = new Number("0x"+groups[0]);
			_numPlugins = (intVal >> 16) & 0xFFFF;
			_numRemotePlugins  = intVal &0xFFFF;
			
			//hosts and tasks
			intVal = new Number("0x"+groups[2]);
			_numHosts = (intVal >> 16) & 0xFFFF;
			_numTasks  = intVal &0xFFFF;
			
			 _licType = typeDur >>8;
			_duration = typeDur & 0xFF;
			
			return ((_licType >=LIC_TYPE_GARNET && _licType <LIC_TYPE_NUM) &&
					(_duration > LIC_DURATION_UNDEFINED && _duration <= LIC_DURATION_MAX));
			
			
		}
		//------------------------
		public function GetTypeString():String
		{
			return _licTypes[_licType];
		}
		
		//----------------------------

	}// end class	
}// end package
