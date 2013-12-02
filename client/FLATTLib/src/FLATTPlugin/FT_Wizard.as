/*******************************************************************************
 * FT_Wizard.as
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
	public class FT_Wizard extends FT_WizardBase
	{
		
		private var _wizPages:Array = new Array();
		//=================================
		
		public function FT_Wizard(wizBlock:XMLList)
		{
			var pageList:XMLList = wizBlock.WizardPage;
			
			for( var i:int ;i < pageList.length();++i)
			{
				//create and parse wizard page xml
				_wizPages.push(new FT_WizardPage(pageList[i]));
			}
		}
		//--------------------------------------
		private function ParsePage(page:XMLList):void
		{
		
		}
	
		//----------------------------------
		//Dump contents
		override public function Dump():String
		{
			var retStr:String="**Wizard**\n";
			for( var i: int = 0 ; i < _wizPages.length;++i)
			{
				retStr+=_wizPages[i].Dump();
			}
			return retStr;
		}
	}
}
