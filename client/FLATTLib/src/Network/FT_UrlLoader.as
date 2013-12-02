/*******************************************************************************
 * FT_UrlLoader.as
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
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	// this class saves the object that needs to be initialized from data that URLLoader loads
	// so the calling code does not have to keep track of them
	public class FT_UrlLoader extends URLLoader
	{
		private var _recipient:Object; // item that will be updated with the data that this loader is loading
		//--------------------------------------
		public function FT_UrlLoader(request:URLRequest=null)
		{
			super(request);
		}
		//--------------------------------------
		public function get recipient():Object
		{
			return _recipient;
		}
		//--------------------------------------
		public function set recipient(value:Object):void
		{
			_recipient = value;
		}

	}
}
