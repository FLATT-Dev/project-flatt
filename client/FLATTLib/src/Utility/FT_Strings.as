/*******************************************************************************
 * FT_Strings.as
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
package Utility
{
	import mx.skins.halo.ScrollTrackSkin;

	public class FT_Strings
	{
		// basically, defines
		public static var STR_UNDEFINED:String 	= "????";
		public static var STR_TEXT_EXT:String 	= "txt";
		public static var STR_SYM_EXT:String 	= "sym";
		public static var STR_MT_EXT:String 	= "mt_html";
		public static var ST_NL:String = "\n";
	
		
	
		
		public static var STR_DEFAULT_DATE_FORMAT:String = "MM/DD/YYYY J:NN:SS";
		public static var STR_DEFAULT_FILEDATE_FORMAT:String = "MM//DD//YYYY J:NN:SS";
		public static var STR_APP_NAME:String 	 	= "<b>FL</b>exible <b>A</b>utomation and <b>T</b>roubleshooting <b>T</b>ool"; //TODO real name!!
		public static var STR_COMPANY_URL:String  = "http://www.flattsolutions.com";		
		public static var STR_MANUAL_URL:String = "http://flattsolutions.com/client-manual.htm";

		
		
		//plugin return types
		public static var RTYPE_TEXT:String="Text";
		public static var RTYPE_LIST:String="List";
		public static var RTYPE_LINECHART:String="Line Chart";
		public static var RTYPE_COLUMNCHART:String = "Column Chart";
		public static var RTYPE_TABLE:String="Table"; // data grid
		public static var RTYPE_UNDEFINED:String = STR_UNDEFINED;
		
		//repo stuff
		public static var STR_DEF_REPO_LIST_XML:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><Repos></Repos>";
		
		// object types
		public static var OTYPE_CATEGORY_CONTAINER:String = "CategoryContainer";
		public static var OTYPE_REPO_CONTAINER:String = "RepoContainer";
		public static var OTYPE_PLUGIN:String =	 	    "Plugin";
		public static var OTYPE_TASK:String = 			"Task";
		public static var STR_HOST_SCAN_STOPPED:String = "Host scan stopped due to license restrictions";
	
		public function FT_Strings()
		{
		}
	}
}
