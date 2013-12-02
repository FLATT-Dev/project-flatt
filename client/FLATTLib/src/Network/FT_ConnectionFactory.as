/*******************************************************************************
 * FT_ConnectionFactory.as
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
package Network
{
	public class FT_ConnectionFactory
	{
		import Application.*;
		
		public function FT_ConnectionFactory()
		{
		}
		// determine type of connection and return appropriate object
		public static function GetConnection():FT_Connection
		{
								
			switch(FT_Prefs.GetInstance().GetProxyType())
			{
				case FT_Prefs.PROXY_TYPE_INTERNAL:
					return new FT_SocketConnection();
					break;
				/*case FT_Prefs.PROXY_TYPE_TOMCAT:
					return new FT_POSTConnection();
					break;		*/		
				case FT_Prefs.PROXY_TYPE_STANDALONE_SSL:
					return new FT_SSLConnection();
					break;
				default:
					break;
			}
			//return new FT_SocketConnection();
			return null;
		}
	}
}
