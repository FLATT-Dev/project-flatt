/*******************************************************************************
 * ZG_Utils.as
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
	import com.ZG.Database.*;
	import com.ZG.Events.*;
	import com.ZG.UserObjects.*;
	
	import flash.display.*;
	import flash.events.EventDispatcher;
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.collections.*;
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.UIComponent;
	import mx.graphics.codec.*;
	import mx.styles.*;
	import mx.utils.*;
	
	public class ZG_Utils
	{
		public function ZG_Utils()
		{
		}
		/* Input is a fully qualified name. All ZG classes are prepended with ZG_
		  Return the name after ...ZG_
		*/
		
		public static function TableNameFromClassName(strName:String):String
		{
			var pos:int = strName.lastIndexOf("ZG_");
			if(pos >=0)
			{
				return strName.substr(pos+3);
			}
			return null;
		}
		
		/*public static function DbNameFromUserName(usrName:String):String
		{
			return(ZG_LocalDatabaseMgr.s_UserPrefix+"_"+usrName+ZG_LocalDatabaseMgr.s_Extension);
		}*./
		
		
		/* TODO: return the currently selected language. */
		public static function GetCurrentLanguage():String
		{
			return "en";
		}
		// helper routine to dispatch ZG events
		public static function ZG_DispatchEvent(evtDispatcher:EventDispatcher,
												evtType:String,												
												data:Object=null,
												xtraData:Array = null):Boolean
		{
			var evt:ZG_Event = new ZG_Event(evtType);
		    evt.data = data;	
			evt.xtraData = xtraData;
		    return evtDispatcher.dispatchEvent( evt );
		}	
		
		// Ensure the object is not visible. Need to tell flex not to include it in layout
		public static function SetVisibility(obj:UIComponent,visible:Boolean):void
		{
			obj.visible = visible;
			obj.includeInLayout = visible;
		}
		//---------------------------------------------------
		public static function ToArray(map:Dictionary):Array
		{					
			var arr:Array = new Array();			
			for(var i:* in map) 
			{
				arr.push(map[i]);
			}       	
        	return arr;			
		}
		
		
		//--------------------------------------------------------------------------		
		//Find  object on the map and return it. Otherwise make an object and set
		// its name to undefined. This is done so we don't crash in the UI but return a set undefined 
		// name that will tell us that there was a problem finding the object in the map
		public static function SafeFindByKey(key:Object , map:Dictionary):Object
		{
			var obj:Object = map[key] as Object;
			if(obj == null)
			{
				obj = new Object();
				obj.name = ZG_Strings.STR_UNDEFINED;
				trace("cannot find object id " + key + " in map " + map);
			}
			return obj;
		}
		
		//--------------------------------------------------------------------------	
		// replace the language tag with the current selected language
		public static  function ResolveTableLanguage(tblName:String):String
		{
			var myPattern:RegExp = /<lg>/gi;  
		 	return (tblName.replace(myPattern,ZG_Utils.GetCurrentLanguage())); 
		 	
		}
		
		//--------------------------------------------------------------------------	
		// TODO: find translated version of a string based on the currently selected language
		public static function TranslateString(src:String):String
		{
		  
			var ret:String = src;
			// TODO: account for src == null
			return ret;
			
		}
		//--------------------------------------------------------------------------	
		// given an array collection of ZG_PersistentObjects,
		// get the object's index in the array by its id
		public static function GetObjectIndexById(objId:Number,arc:ArrayCollection):Number
		{			
			for( var i:Number = 0; i < arc.length;++i)
        	{      		
        		if(objId == ZG_PersistentObject(arc.getItemAt(i)).id)
        		{
        			return i;
        		}
        	}
        	return -1;       	
		}
		
		// a handy routine to change the text alignment of labels
		// parameters are "right","left" and "center"
		// doesnt work..getStyleDeclaration returns null. TODO:investigate
		public static function SetLabelAlignment( alignment:String):void
		{
			//var cssObj:CSSStyleDeclaration = StyleManager.getStyleDeclaration(".customTextAlignLabel");
            //cssObj.setStyle("textAlign", alignment);
		}
		//-------------------------------------------------------------
		/* Look up an object by name in a colllection. 
			Optionally use the internal name			
		*/
		public static function GetObjectByName(name:String,src:Object,
												caseSensitive:Boolean,
												useInternalName:Boolean):ZG_PersistentObject
		{
			var cur:ZG_PersistentObject = null;
			var objName:String;
			
			if( src is ArrayCollection  || src is Array)
			{
				var arr:Array = src is ArrayCollection ? src.toArray() : src as Array;
				
				//for( var i:Number = 0; i < ArrayCollection(src).length;++i)
				for (var i:Number = 0; i < arr.length;++i)
	        	{      		
	        		//cur = ZG_PersistentObject(ArrayCollection(src).getItemAt(i));
	        		cur = ZG_PersistentObject(arr[i]);
	        		objName = (useInternalName ? cur.internalName : cur.name);
	        		
	        		if( ZG_StringUtils.EqualString(name,objName,caseSensitive))
	        		{
	        			return cur;
		       		}       		       		
	        	}
	  		}       	
        	else if (src is Dictionary )
        	{
        		for each (var item:Object in src as Dictionary)
				{
				    cur= ZG_PersistentObject(item);
	        		objName = (useInternalName ? cur.internalName : cur.name);
	        		if( ZG_StringUtils.EqualString(name,objName,caseSensitive))
	        		{
	        			return cur;
		       		}
				}
        	}
        	else
        	{
        		trace("Unhandled src type:" + getQualifiedClassName(src));
        	}
        	return null;       	
		}
		//------------------------------------------------------------
		public static function MakeDateRange(initialDate:Date,
											 beginningDate:Date,
											 endingDate:Date):void
		{
			beginningDate = new Date(initialDate);
			beginningDate.hours=0;
			beginningDate.minutes=0;
			beginningDate.seconds = 1;
			
			endingDate =  new Date(beginningDate);
			beginningDate.hours=23;
			beginningDate.minutes=59;
			beginningDate.seconds = 59;
		}
		//---------------------------------------------------------------
		public static function GetCurrencySymbol(currency:ZG_PersistentObject):String
		{
			var res:String = ZG_Strings.STR_UNDEFINED;
			if( currency.name == "USD")
			{
				res =  ZG_Strings.STR_SYMBOL_USD;
			}
			return res;			
		}
		//----------------------------------------------------------------
		// check validity of an array
		public static function ValidArray(inArr:Array):Boolean
		{
			return(inArr!=null && inArr.length > 0);
			
		}
		
		//--------------------------------------------------------
		public static function ClearMap(map:Dictionary):void
		{
			for(var cur:Object in map) 
			{				
				delete map[cur];
				cur = null;
			}
		}
		//--------------------------------------------------------
		// copy an array. Shallow copy, objects are not copied, only
		// ptrs to them
		public static function ShallowCopyArray(src:Array):Array
		{
			var ret:Array = new Array();
			for(var i:int =0; i < src.length;++i)
			{
				ret.push(src[i]);
			}
			return ret;
		}	
		//------------------------------------------------------
		
		//Convert datagrid to csv file
		
		public static function ExportCSV(dg:DataGrid, 
										 csvSeparator:String="\t", 
										 lineSeparator:String="\n"):String
		{
			var data:String = "";
			var columns:Array = dg.columns;
			var columnCount:int = columns.length;
			var column:DataGridColumn;
			var header:String = "";
			var headerGenerated:Boolean = false;
			var dataProvider:Object = dg.dataProvider;
			var rowCount:int = dataProvider.length;
			var dp:Object = null;
			var cursor:IViewCursor = dataProvider.createCursor ();
			var j:int = 0;
			//loop through rows
			while (!cursor.afterLast)
			{
				var obj:Object = null;
				obj = cursor.current;
				//loop through all columns for the row
				for(var k:int = 0; k < columnCount; k++)
				{
					column = columns[k];
					//Exclude column data which is invisible (hidden)
					if(!column.visible)
					{
						continue;
					}
					data += "\""+ column.itemToLabel(obj)+ "\"";
					if(k < (columnCount -1))
					{
						data += csvSeparator;
					}
					//generate header of CSV, only if it's not genereted yet
					if (!headerGenerated)
					{
						header += "\"" + column.headerText + "\"";
						if (k < columnCount - 1)
						{
							header += csvSeparator;
						}
					}
				}
				headerGenerated = true;
				if (j < (rowCount - 1))
				{
					data += lineSeparator;
				}
				j++;
				cursor.moveNext ();
			}
			//set references to null:
			dataProvider = null;
			columns = null;
			column = null;
			return (header + "\r\n" + data);
		}		
		//----------------------------------------
		public static function SaveUIElement(uiEl:IBitmapDrawable,width:int, height:int,format:String = "jpg"):ByteArray
		{
			
			var encoder:IImageEncoder = null;
			var retData:ByteArray = null;
			
			if(format == ZG_Strings.STR_FORMAT_JPG)
			{
				encoder = new JPEGEncoder();
			}
			else if ( format == ZG_Strings.STR_FORMAT_PNG)
			{
				encoder =new PNGEncoder();
			}
			if(encoder!=null)
			{
								
				var bmpData:BitmapData = new BitmapData (width, height);
				bmpData.draw(uiEl);
				retData = encoder.encode(bmpData);
			}
			return retData;
		
		}
		
	 	//------------------------------------
		// returns a total count of items in an array collection of zg_persistentobjects an
		// if an object is a container - its num children is added to the total count
		public static function CountAll_ZGP_Objects(coll:ArrayCollection):int
		{
			// count all hosts in the tree
			var total:int = 0;
			if(coll!=null)
			{
				for(var i:int = 0; i < coll.length;++i)
				{
					var cur:ZG_PersistentObject = coll.getItemAt(i) as ZG_PersistentObject;	
					// null will be returned if this is not a ZGP object and cast fails
					if( cur!=null)
					{
						total+=cur.isContainer ? cur.numChildren : 1;	
					}
					else
					{
						trace("CountAll_ZGP_Objects: cast to ZGP failed");
						return 0;
					}
				}
			}
			return total;
			
		}
		//------------------------------------
		
	}//class	

}//package
