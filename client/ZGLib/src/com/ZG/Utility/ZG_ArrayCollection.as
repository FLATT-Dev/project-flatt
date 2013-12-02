/*******************************************************************************
 * ZG_ArrayCollection.as
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
	import com.ZG.UserObjects.ZG_PersistentObject;
	
	import mx.collections.ArrayCollection;

	public class ZG_ArrayCollection extends ArrayCollection
	{
		public function ZG_ArrayCollection(source:Array=null)
		{
			super(source);
		}
		
		/*public function GetChildByID(id:int):Object
		{
			for(var i:int = 0; i < this.length;++i)
			{
				var cur:Object = this[i];
				if(cur.id == id)
				{
					return cur;
				}
			}
			return null;
		}*/
		// search a given array collection for an item using a given criteria
		// put all results in result array and return first found item
		public static function FindItemBy(arrayColl:ArrayCollection, 
										  searchBy:int, 
										  pattern:Object):ZG_PersistentObject										  
		{
			var found:Boolean = false;
			for(var i:int =0; i < arrayColl.length;++i)
			{
				var cur:ZG_PersistentObject = arrayColl.getItemAt(i) as ZG_PersistentObject;
				if(cur !=null) // in case it's not a persistent object
				{
					switch(searchBy)
					{
						case ZG_PersistentObject.SRCH_TYPE_ID:
							found = (Number(pattern) == cur.id);
							break;
						case ZG_PersistentObject.SRCH_TYPE_GUID:
							found  = (String(pattern)== cur.guid);
							break;
						case ZG_PersistentObject.SRCH_TYPE_NAME:
							found  = (String(pattern) == cur.name);
							break;
						case ZG_PersistentObject.SRCH_TYPE_PTR:
							found  = (pattern== cur);
							break;
						case ZG_PersistentObject.SRCH_TYPE_PARTIAL_NAME:
							found = ZG_StringUtils.PartialStringMatch(String(pattern),cur.name);
							break;
						default:
							found = false;
							
					}
					if( found )
					{
						return cur;
					}
				}
			}
			return null;
		}
		//---------------------------------------------------------
		public static function DeepSearch(collection:ArrayCollection,
										  pattern:String,
										  searchFlags:int,
										  result:Array):Boolean
										  
		{
			for(var i:int =0; i < collection.length;++i)
			{
				var cur:ZG_PersistentObject = collection.getItemAt(i) as ZG_PersistentObject;
				if(cur !=null) // in case it's not a persistent object
				{					
					// now search children and potentially self as well
					cur.FindChildrenBy(pattern,searchFlags,result);
				}
			}
			return (result.length > 0);
		}
	}
}
