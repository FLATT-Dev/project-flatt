/*******************************************************************************
 * ZG_BaseWindow.as
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
package com.ZG.UI
{
	import mx.core.Window;
	
	// UNUSED ???

	public class ZG_BaseWindow extends Window
	{
		public function ZG_BaseWindow()
		{
			super();
		}
		// TODO: make this a base window for all window classes
		protected static	var	s_Instance:ZG_BaseWindow;
	 	//------------------------------------------------
 		public static function GetInstance():ZG_BaseWindow
 		{
 			if(s_Instance == null)
	 		{
	 			s_Instance = new ZG_BaseWindow();
	 			s_Instance.open();
	 		}
	 		return s_Instance;
 		}
 		
 		private function OnClose():void
		{
		 	s_Instance = null;
		}
	}
}
