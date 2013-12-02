/*******************************************************************************
 * FT_WizardPage.as
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
package FLATTPlugin
{
	public class FT_WizardPage extends FT_WizardBase
	{
		/* This class represents a wizard page with all its UI parameters */
		//==================================
		private var _title:String = "";
		private var _uiParams:Array = new Array();
		
		public function FT_WizardPage(xmlData:XML)
		{
			_title = xmlData.@title;
			var pageParams:XMLList = xmlData.UIParam;			
			for( var i: int = 0; i< pageParams.length(); ++i)
			{
				// ui param only has attributes
				var uiParam:FT_UIParam = new FT_UIParam();
				uiParam.type=pageParams[i].@type;
				uiParam.id = pageParams[i].@id;
				uiParam.label =pageParams[i].@label;
				_uiParams.push(uiParam);
			}
		}
		//==================================
		public function get title():String
		{
			return _title;
		}
		//----------------------------------------------
		public function set title(value:String):void
		{
			_title = value;
		}
		//---------------------------------------------
		override public function Dump():String
		{
			var ret:String = "**Wizard Page**"+"\ntitle="+_title+"\n";
			for(var i:int =0;i < _uiParams.length;++i)
			{
				ret+=_uiParams[i].Dump();
			}
			return ret;
		}

	}
}
