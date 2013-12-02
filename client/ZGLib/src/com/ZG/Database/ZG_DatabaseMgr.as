/*******************************************************************************
 * ZG_DatabaseMgr.as
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
package com.ZG.Database
{
	import com.ZG.Events.*;
	
	import flash.filesystem.*;

	public class ZG_DatabaseMgr extends ZG_EventDispatcher
	{
		
		private static var s_Instance : ZG_DatabaseMgr;	
		private static var s_IsLocal:Boolean = true; /* default to local */
			 	
	 	public function ZG_DatabaseMgr()
		{			
		}
		public static function SetLocal(local:Boolean ):void
		{
			ZG_DatabaseMgr.s_IsLocal = local;
		}
		
	 	public static function GetInstance():ZG_DatabaseMgr
		{			
			if(s_IsLocal)
			{
				if( s_Instance == null )
				{
					s_Instance = new ZG_DatabaseMgr();
				}				
			}
			else
			{
				//TODO: remote database mgr
			}
			return s_Instance;
		}		
				
		public function Init():Boolean
		{
			return false;
		}
		public function LoadDatabase(dbName:String):void
		{
		
		}
		protected function CreateDatabase(dbName:String):File
		{
			return  null;
		}
		//-----------------------------------------------------
		public function BeginTransaction(isUserConnecton:Boolean):void
		{
			
		}
		//-----------------------------------------------------
		public function EndTransaction(isUserConnecton:Boolean):void
		{
			
		}
		
		
	}
}
