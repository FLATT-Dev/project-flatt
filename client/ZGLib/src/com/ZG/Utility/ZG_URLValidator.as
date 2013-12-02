/*******************************************************************************
 * ZG_URLValidator.as
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
	import mx.validators.*;
	
	public class ZG_URLValidator extends Validator 
	{
		public function ZG_URLValidator() {
			super();
		}
		
		private var _invalidUrlError:String = "This is an invalid URL.";
		
		[Inspectable(category="Errors", defaultValue="null")]
		
		/**
		 *  Error message when a string is not a valid url. 
		 *  @default "This is an invalid url."
		 */
		public function get invalidUrlError():String {
			return _invalidUrlError;
		}
		public function set invalidUrlError(value:String):void {
			_invalidUrlError = value;
		}
		
		override protected function doValidation(value:Object):Array {
			var results:Array = super.doValidation(value);
			if (!ValidUrl(value.toString())) {
				results.push(new ValidationResult(true, "", "invalidUrl", invalidUrlError));   
			}
			return results;
		}
		public static function ValidUrl(s:String):Boolean {
			var regexp:RegExp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
			return regexp.test(s);
		}
		// either numeric or not url formatted
		public static function ValidIP(ip:String):Boolean 
		{
			if(ip == "0")
			{
				return true;
			}
			var RegPattern:RegExp = /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/;
			
			var a:Array = RegPattern.exec(ip);
			return  (a!=null);
			
		}
		// make a best effort to determine if the address is valid
		public static function ValidAddress(addr:String):Boolean
		{
			if(ValidUrl(addr))
			{
				return true;
			}
			if(ValidIP(addr))
			{
				return true;
			}
			if(addr.toLocaleLowerCase() == "localhost")
			{
				//special case - local host should be recognized everywhere
				return true;
			}
			// does not look good
			// see if a string has at least 2 periods
			var arr:Array = addr.split(".");
			if (arr!=null && arr.length > 1 )
			{
				return true;
			}
			return false;	
		}
		
		//------------------------------------------
		// Extract host address from url. basically everything between // and first /
		public static function HostAddressFromUrl(url:String):String
		{
			
			if(url.length > 0 )
			{
				var pos:int= url.indexOf("://");
				var pos2:int;
				// maybe a numeric addr
				if( pos <0)
				{
					pos = 0;
				}
				//url better contain forward slashes otherwise it is invalid
				var temp:String = url.substring(pos+3);
				pos = temp.indexOf("/");
				if(pos > 0)
				{
					return( temp.substring(0,pos));
				}				
			}
			return url;
		}
		
	}
}
