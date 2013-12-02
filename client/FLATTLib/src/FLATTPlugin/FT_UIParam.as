/*******************************************************************************
 * FT_UIParam.as
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
	public class FT_UIParam extends FT_WizardBase
	{
		
		public static const  UI_TYPE_RADIO:String = "radio";
		public static const  UI_TYPE_EDIT_FIELD:String = "editfield";
		public static const  UI_TYPE_TEXT_AREA:String = "textarea";
		public static const  UI_TYPE_CHECKBOX:String = "checkbox";		
		public static const  UI_TYPE_LIST:String = "list";
		public static const  UI_TYPE_COMBOBOX:String = "combobox";
		//============================================
		private var _type:String = "";
		private var _id:String = "";
		private var _label:String = "";
		private var _value:String = "";
		
		public function FT_UIParam()
		{
		}
		//============================================
		override public function Dump():String
		{
			return ("UI_Param\n"+"type="+type+"\nid="+id+"\nlabel="+label+"\nvalue="+value);
		}
		//------------------------------------------------
		// create XML object from this obect
		public function ToXML():XML
		{
			var paramXML:XML = new XML(<UIParam></UIParam>);
			
			// add common tags
			
			paramXML.@id = id;
			paramXML.label = label;
			paramXML.type = type;
			paramXML.value = value;			
			
			return paramXML;
		}
		//------------------------------------------------
		public function FromXML(xml:XML):void
		{
			id= xml.@id;
			label = xml.label;
			type = xml.type;
			value = xml.value;
		}
		//----------------------------------------------
		public function get type():String
		{
			return _type;
		}
		//----------------------------------------------
		public function set type(value:String):void
		{
			_type = value;
		}
		//----------------------------------------------
		public function get id():String
		{
			return _id;
		}
		//----------------------------------------------
		public function set id(value:String):void
		{
			_id = value;
		}
		//----------------------------------------------
		public function get label():String
		{
			return _label;
		}
		//----------------------------------------------
		public function set label(value:String):void
		{
			_label = value;
		}
		//----------------------------------------------
		public function get value():String
		{
			return _value;
		}
		//----------------------------------------------
		public function set value(value:String):void
		{
			_value = value;
		}
		//-----------------------------------------------


	}
}
