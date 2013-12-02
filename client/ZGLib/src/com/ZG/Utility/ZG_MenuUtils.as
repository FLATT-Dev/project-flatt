/*******************************************************************************
 * ZG_MenuUtils.as
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
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import mx.collections.*;
	import mx.events.*;
			
	// Various menu related utilities
	public class ZG_MenuUtils
	{
			
		public function ZG_MenuUtils()
		{
		}
		//---------------------------------------------------------
		public static function InsertContextItem(contextMenu:NativeMenu,
												itemName:String,
												onSelectProc:Function,
												setLabel:Boolean,
												index:Number=-1):ContextMenuItem
		{
			var contextMenuItem:ContextMenuItem = new ContextMenuItem("");
			contextMenuItem.name = ZG_Utils.TranslateString(itemName);    
			/* some callers may not want to set the label right away */
			if( setLabel )
			{
				contextMenuItem.label = contextMenuItem.name;
			}           
            contextMenuItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT,onSelectProc);  
           
            if(index>=0 && index < contextMenu.items.length)
            {
            	contextMenu.addItemAt(contextMenuItem,index);
            }
            else
            {
            	contextMenu.addItem(contextMenuItem);
            }
            return contextMenuItem;
		}
		
	//-------------------------------------------------------------
	
	public static function DeleteContextItem(contextMenu:NativeMenu,itemName:String):void
	{
		var ci:ContextMenuItem = FindContextItem(contextMenu,itemName);
		if( ci )
		{
			contextMenu.removeItem(ci);
		}			
	}
	//-------------------------------------------------------------
	public static function FindContextItem(contextMenu:NativeMenu,strName:String):ContextMenuItem
	{
		for(var i:int = 0; i < contextMenu.items.length;++i)
		{
			var ci:ContextMenuItem = contextMenu.getItemAt(i) as ContextMenuItem;
			if(ZG_Utils.TranslateString(ci.name)== ZG_Utils.TranslateString(strName))
			{
				return ci;
			}					
		}
		return null;	
	}

	}
}
