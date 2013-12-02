/*******************************************************************************
 * ZG_XMLUtils.as
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
package com.ZG.Utility
{
	public class ZG_XMLUtils
	{	
		
		public static var TAG_SSH_REQUEST_OPEN:String = "<SSHRequest>";
		public static var TAG_SSH_REQUEST_CLOSE:String = "</SSHRequest>";
		
		public static var TAG_SSH_REPONSE_OPEN:String = "<SSHResponse";
		public static var TAG_SSH_REPONSE_CLOSE:String = "</SSHResponse>";
		
		// various xml related utility funcions
		public function ZG_XMLUtils()
		{
			//			
		}
		//---------------------------------------
		// returns true if this is a valid response and return the xml object or null
		public static function ValidateResponseXML(inData:String):XML
		{
			//  validate if this is a valid XML
			var ret:Boolean = false;
			
			if(inData.indexOf(TAG_SSH_REPONSE_OPEN)!=-1 && inData.indexOf(TAG_SSH_REPONSE_CLOSE ) !=-1)
			{
				var xml:XML = null;
				try
				{
					xml = new XML(inData);	
					
				}
				catch( e:Error)
				{
					xml = null;
				}
			}
			return xml;
		}
	}
}
