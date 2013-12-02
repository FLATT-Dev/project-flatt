/*******************************************************************************
 * ZG_PersistentObject.as
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
package com.ZG.UserObjects
{

	import com.ZG.Data.*;
	import com.ZG.Events.*;
	import com.ZG.UI.*;
	import com.ZG.Utility.*;
	
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.collections.*;
	/*
	This component is made available by Magnolia Multimedia
	http://www.magnoliamultimedia.com
	under a creative commons license
	http://creativecommons.org/licenses/by/3.0/
	
	You are free:
	to Share — to copy, distribute and transmit the work to Remix — to adapt the work 
	Under the following conditions:
	Attribution. You must attribute the work in the manner specified by the author or 
	licensor (but not in any way that suggests that they endorse you or your use of the work). 
	
	Attribute this work:
    Leave this comment at the top of the file
    */
	
	//[RemoteClass (alias="com.magnoliamultimedia.vo.Classification")]
	[Bindable]
	public class ZG_PersistentObject  extends ZG_EventDispatcher
		implements LazyLoading 
	{
		// search type enumeration
		public static var SRCH_TYPE_ID:int 					 = 0x00000001;
		public static var SRCH_TYPE_NAME:int 				 = 0x00000002;
		public static var SRCH_TYPE_INTERNAL_NAME:int		 = 0x00000004;
		public static var SEARCH_INTERNAL_CHILDREN:int 		 = 0x00000008;
		public static var SRCH_TYPE_OBJECT_TYPE:int			 = 0x00000010;
		public static var SRCH_TYPE_DB_TYPE:int				 = 0x00000020;
		public static var SRCH_TYPE_ACCOUNT:int				 = 0x00000040;// search acct by name and number
		public static var SRCH_TYPE_GUID:int				 = 0x00000080;
		public static var SRCH_TYPE_PTR:int					 = 0x00000100; // compare object pointers
		public static var SRCH_TYPE_PARTIAL_NAME:int		 = 0x00000200; // partial name search
		public static var SRCH_FLAG_INCLUDE_CONTAINER:int	 = 0x00000400; // include container itself in the search
		public static var SRCH_TYPE_CLASSNAME:int			 = 0x00000800; // compare class names
	
		
		private static var TEMP_ID_BASE:int			= -1;
		
		protected var _id:Number; // this is the database row id
		protected var _name:String='';
		protected var _type:String='';
		protected var _description:String='';
		protected var _isContainer:Boolean;
		protected var _parentId:Number = 0;
		protected var _isDefault:Boolean = true; // used only by some objects
		protected var _label:String='';
		// when object is read from db this value will be incremented as
		// the fields are set.The save is triggered if  _dirty is > 1
		protected var _dirty:Boolean;  
		protected var _objInitialized:Boolean;
		protected var _savedEventType:String;
		protected var _parentObj:ZG_PersistentObject = null;
		protected var _internalName:String = ''; // used in some objects where the internal name differs from UI name
		protected static var _tempId:int = TEMP_ID_BASE; // temp ids assigned to some objects while the objects are written to db
		protected var _ignoreDuplicates:Boolean= false; // unused for now but maybe in the fuure
		protected var _guid: String  = "";

		
		/*	By initing this as an ArrayCollection, we give the
			LazyLoadingDataDescriptor something to return in
			the getChildren function even if the children aren't
			yet loaded.	*/ 
		protected var _children:ArrayCollection=new ArrayCollection();;
		protected var _hasChildren:Boolean;
		protected var _childrenLoaded:Boolean;
		protected var _isLoadingChildren:Boolean;
		
		protected var _tempChildren:Array;
		protected var _visible:Boolean = true; // used by some objects
		//transient value set at runtime.
		protected var _readOnly:Boolean = false; 
		protected var _scratchStr:String = ""; // used for anything that the object needs to use it
		protected var _fileObj:File;
		
		//--------------------------------------------------------------------------
		public function ZG_PersistentObject()
		{
			super(this);
			_isContainer = true; // container by default,subclasses override
			//_dirtyFieldsMap = new Dictionary();	
			_id = GetTempId();
				
			
		}
		//--------------------------------------------------------------------------		
		public function get id():Number 
		{
			return _id;
		}
		//--------------------------------------------------------------------------
		public function set id(value:Number):void
		{
			if(_id != value)
			{
				_id = value;
				// only increment dirty flag if the object has been read from db
				//_dirty =_objInitialized;
			}			
		}		
		//--------------------------------------------------------------------------
		// some subclasses may want to display number of children in name
		public function get name():String 
		{						
			return _name;
		}
		//--------------------------------------------------------------------------
		public function set name(value:String):void 
		{
			if(_name != value)
			{
				_name = value;
				// only increment dirty flag if the object has been read from db
				//_dirty+=_objInitialized;
			}			
		}
		//--------------------------------------------------------------------------
		//just in case some UI element wants to use it
		public function get label():String 
		{
			return name;
		}
		//---------------------------------------------------------------------------
		public function set label(value:String):void
		{
			if(_label != value)
			{
				_label = value;
				// only increment dirty flag if the object has been read from db
				//_dirty+=_objInitialized;
			}		
		}		
		//--------------------------------------------------------------------------
		public function get type():String
		{
			return _type;
		}
		//--------------------------------------------------------------------------
		public function set type(value:String):void 
		{
			if(_type != value)
			{
				_type = value;
				// only increment dirty flag if the object has been read from db
				//_dirty+=_objInitialized;
			}			
		}
		//--------------------------------------------------------------------------
		public function get description():String 
		{
			return _description;
		}
		//--------------------------------------------------------------------------
		public function set description(value:String):void 
		{
			if(_description != value)
			{
				_description = value;
				// only increment dirty flag if the object has been read from db
				//_dirty+=_objInitialized;
			}
		} 
		//--------------------------------------------------------------------------
		public function get parentId():Number 
		{
			return _parentId;
		}
		//--------------------------------------------------------------------------
		public function set parentId(value:Number):void 
		{
			if(_parentId != value)
			{
				_parentId = value;
				// only increment dirty flag if the object has been read from db
				//_dirty+=_objInitialized;
			}			
		} 
		//--------------------------------------------------------------------------
		public function get isDefault():Boolean
		{
			return _isDefault;
		}
		//--------------------------------------------------------------------------
		public function set isDefault(value:Boolean):void
		{
			if(_isDefault != value)
			{
				_isDefault = value;
				// only increment dirty flag if the object has been read from db
				//_dirty+=_objInitialized;
			}
		}
		public function get dirty():Boolean
		{
			return(_dirty);
		}
		// in case it's 0 - dirty =1 does not trigger update
		public function set dirty(val:Boolean):void
		{			
			_dirty = val;			
		}
	
		// This allows to pass this object to  UI so it displays its name
		override public function toString():String
		{
			return name;
		}
				
		//[Bindable ('childrenLoaded')]
		public function get children():ArrayCollection 
		{
			return (_isContainer? _children : null);
		}
		/* the above call is made by the UI framework. 
			We want to return null for containers
			that have hidden children, like TradeCategory
			But internally we still need to be able to access the _children array
		*/			
		public function InternalGetChildren():ArrayCollection
		{
			return _children;
		}
		//--------------------------------------------------------------------------
		public function set children(value:ArrayCollection):void
		{
			if (value) _children=value;
		}		
		//--------------------------------------------------------------------------
		public function get hasChildren():Boolean
		{
			return  (_isContainer? _isContainer: false);
		}		
		//--------------------------------------------------------------------------
		public function set hasChildren(value:Boolean):void
		{
			_hasChildren=value;			
		}
		//--------------------------------------------------------------------------
		/*
		 * true if the children have been loaded
		 */
		public function get childrenLoaded():Boolean
		{
			return _childrenLoaded;
		}
		//--------------------------------------------------------------------------
		// true if this object needs to always be a container
		public function get isContainer():Boolean
		{
			return _isContainer;
		}
		//--------------------------------------------------------------------------
		public function set isContainer(value:Boolean):void
		{
			_isContainer=value; // this does not make object dirty
		}
		//--------------------------------------------------------------------------
		// Update internal variables to indicate the children are loaded
		public function HandleChildrenLoaded():void
		{
			_isLoadingChildren=false;
			_childrenLoaded = true;
			
			// add this obj as aparent for all its children.
			for(var i:int = 0; i < this._children.length;++i)
			{
				_children[i].parentObj = this;
			}
			ZG_DataReader.GetInstance().removeEventListener(ZG_Event.CHILDREN_LOADED,onChildrenLoaded);
			trace('children of ' + _name + ' loaded.', 'ID: ' + _id, (new Date).getTime());		 			
		}
		//-----------------------methods that are not properties------------------//
		/*
		 * loads the children of this object
		 */
		public function loadChildren():void 
		{
			if (!_isLoadingChildren /*&& _children.length==0 && _hasChildren*/)
			{
				_isLoadingChildren=true;
				ZG_DataReader.GetInstance().GetChildren(this);
				
			} 
			else 
			{
				DispatchEvent(ZG_Event.CHILDREN_LOADED);
			}
		}
		//--------------------------------------------------------------------------
		// not used but maybe in the future
		private function onChildrenLoaded(e:ZG_Event):void
		{			
			HandleChildrenLoaded();		 	
		}
		//--------------------------------------------------------------------------
		private function onChildrenLoadFailed(e:ZG_Event):void 
		{
			//dispatchEvent(new Event(CHILDREN_NOT_LOADED));
		}
		
		//--------------------------------------------------------------------------
		// dont' copy the children
		public function ShallowCopy(src:ZG_PersistentObject):void
		{			
			id = src.id;
			name = src.name;
			type = src.type;
			internalName = src.internalName;
			description = src.description;
			isContainer = src.isContainer;
			parentId = src.parentId;
			isDefault = src.isDefault;
		}
		
		//--------------------------------------------------------------------------
		// called by the data writer upon successful db update of the object properties
		public function OnUpdate():void
		{
			
			this.dirty = false;							
			trace("OnObjectUpdate:Object= " +  
					getQualifiedClassName(this) 	+ 
					"\nID="+this.id 				+ 
					"\nName="+this.name
				);
			
		}	
		
		//--------------------------------------------------------------------------				
		public function set objInitialized(val:Boolean):void
		{
			_objInitialized=val;
		}
		//--------------------------------------------------------------------------
		public function get objInitialized():Boolean
		{
			return _objInitialized;
		}	
		//--------------------------------------------------------------------------
		public function OnDelete():void
		{
			trace("OnDelete:Object= " +  
					getQualifiedClassName(this) 	+ 
					"\nID="+this.id 				+ 
					"\nName="+this.name
				);
		}
		//--------------------------------------------------------------------------
		
		/*Called by DataWriter responder to handle insert specific tasks
			OBSOLETE
		*/
		public function OnInsert(newId:Number):void
		{
			
			this.objInitialized = true;	
			// object may be on the list of ui objecst with a temp id ( eg. instrument, or account)
			// remove it from there and re-add with a good id. send an event notifying all objects
			// that use this guy that it's being removed
		 	
			ZG_DataReader.GetInstance().UI_UpdateObject(this,true,true);				
			this.id = newId;	
			trace("OnObjectInsert:Object= " +  
					getQualifiedClassName(this) 	+ 
					"\nID="+this.id 				+ 
					"\nName="+this.name);						 	
			
			// update the UI map. ( only for those objects that need this)
			ZG_DataReader.GetInstance().UI_UpdateObject(this,true,false);
		
		}
		
		
		//--------------------------------------------------------------------------				
		public function set parentObj(val:ZG_PersistentObject):void
		{
			_parentObj=val;
		}
		//--------------------------------------------------------------------------
		public function get parentObj():ZG_PersistentObject
		{
			return _parentObj;
		}	
		//--------------------------------------------------------------------------
		//generic routine to find a child by a given criteria
		//--------------------------------------------------------------------------
		public function FindChildBy(searchFlags:int,searchBy:Object):Object
		{
			var ret:ZG_PersistentObject = null;
			var found:Boolean = false;
			var kids:Array = (searchFlags & SEARCH_INTERNAL_CHILDREN ? _tempChildren:_children.toArray());
			
			if(kids!=null && kids.length >0)
			{								
				for( var i:int = 0; i < kids.length;++i)
				{
					if(searchFlags & SRCH_TYPE_ID)
					{
						found = (kids[i].id == searchBy);
					}
					else if(searchFlags & SRCH_TYPE_NAME)
					{
						found = (kids[i].name == searchBy);
					}
					else if(searchFlags & SRCH_TYPE_INTERNAL_NAME)
					{
						found  = (kids[i].internalName == searchBy);
					}
					else if (searchFlags & SRCH_TYPE_PARTIAL_NAME)
					{
						found = ZG_StringUtils.PartialStringMatch(kids[i].name, searchBy as String);
					}
					else if (searchFlags & SRCH_TYPE_GUID )
					{
						found  = (kids[i].guid == searchBy);
					}
					// search for unique account by name and acct number
					/* should be in sublclass * 
						else if (searchFlags & SRCH_TYPE_ACCOUNT)
					{
						found = ( kids[i].name == searchBy[0] && ZG_Account(kids[i]).acctNumber == searchBy[1]);
					}*/
					
					
					if(found)
					{
						ret = kids[i];
						break;
					}
				}
			}
			return ret;			
		}
		//--------------------------------------------------------------------------
		public function get internalName():String 
		{
			return _internalName;
		}
		//--------------------------------------------------------------------------
		public function set internalName(value:String):void 
		{
			/*if(_internalName != value)
			{
				_internalName = value;
				// only increment dirty flag if the object has been read from db
				_dirty+=_objInitialized;
			}*/
			_internalName = value;			
		}
		//-------------------------------------------------------------------------------
		/* Sometimes we need to assign a temporary id to an object that is referenced somewhere
		 but hasn't been inserted yet, so no real id exists.
		 In that case we assign a temporary negative ID.
		 */
		 public static function IsTempId(theId :Number):Boolean
		 {
		 	return theId <= TEMP_ID_BASE;
		 }
		 //-------------------------------------------------------------------------------
		 // return a temp id and decrement
		 public static function GetTempId():int
		 {
		 	var savedTempId:int = _tempId;
		 	_tempId--;
		 	return savedTempId;
		 }
		 //-------------------------------------------------------------------------------
		 // Temp children are used when importing from various sources ( e.g MT Html)
		 public function get tempChildren():Array
		 {
		 	return _tempChildren;
		 }
		 //-------------------------------------------------------------------------------
		 public function set tempChildren(val:Array):void
		 {		 	
			_tempChildren = val;
		 }
		 //------------------------------------------------------------------------------
		 // TODO Revisit if this is needed 
		
		 protected function InsertTempChildren(parent:ZG_PersistentObject,insertIntoDB:Boolean):void
		 {			  
			 /*  if(_tempChildren!=null)
			  {
			  	// temp array is array of parameters that is passed  the EVT_OBJECT_INSERT event
			  	// parameters are as follows:
			  	// [0] - parent of the object to be inserted
			  	// [1] - should the object be inserted into db or only into runtime hierarchy
			  	// [2] - the object itself
			  	
			  	var tempArray:Array = new Array();
			  	tempArray.push(parent == null ? this : parent);
			  	tempArray.push(insertIntoDB);
			  	
			  	//zero based arrays
			  	for( var i:int = (_tempChildren.length-1); i >=0; --i)
			  	{
			  		var cur:ZG_PersistentObject = _tempChildren.pop();
			  		if( cur!=null)
			  		{
			  		
			  			// Dispatch an event 
			  			// Some children may have a parent that is not this object ( e.g trades'
			  			// parent is container but they belong to an account
			  			
			  			tempArray.push(cur);			  			
			  			ZG_Application.GetInstance().DispatchEvent(ZG_Event.EVT_OBJECT_INSERT,tempArray);
			  			tempArray.pop();
			  		}			  		
			  	}
			  	
			  	_tempChildren = null;		  				  
			  }		
		 */
		 }
		 
		 //------------------------------------------------------------------------------
		 //Subclasses override
		 public function Copy(src:ZG_PersistentObject):void
		 {
		 	
		 }
		 //------------------------------------------------------------------------------
		 //Subclasses override
		 // Merge the values from src object
		 public function Merge(src:ZG_PersistentObject):void
		 {
		 	
		 }
		 //------------------------------------------------------------------------------
		 // generic set function 
		/* public function SetValue(curVal:Object ,newVal:Object):void
		 {
		 	if(curVal!=newVal)
		 	{
		 		curVal = newVal;
		 		// only increment dirty flag if the object has been read from db
				_dirty+=_objInitialized;	 		
		 	}
		 }*/
		 //------------------------------------------------------------------------------
		 public function GetParentName():String
		 {
		 	var ret:String = ( parentObj == null ? ZG_Strings.STR_UNDEFINED : parentObj.name);
		 	return ret;
		 }
		  //------------------------------------------------------------------------------
		  		
		public function get visible():Boolean 
		{
			return _visible;
		}
		//--------------------------------------------------------------------------
		public function set visible(value: Boolean):void
		{
			if(_visible != value)
			{
				_visible = value;
				// only increment dirty flag if the object has been read from db
				_dirty+=_objInitialized;
			}			
		}
		
		//--------------------------------------------------------------------------
		// recursive search the tree beginning with this node
		// search criteria: either class name or db type
		// return array of objects of given type.
		
		public function FindChildrenByType(srchType:String,flags:int,result:Array):Boolean
		{
			var kids:Array = (flags & SEARCH_INTERNAL_CHILDREN ? _tempChildren:_children.toArray());
			
			if(kids!=null && kids.length >0)
			{								
				for( var i:int = 0; i < kids.length;++i)
				{
					var curChild:ZG_PersistentObject = kids[i];
					var kidType:String = flags & SRCH_TYPE_DB_TYPE ? curChild.type : getQualifiedClassName(curChild);	
					
					if(kidType == srchType)
					{
						result.push(curChild);
					}
					else
					{
						if(curChild.FindChildrenByType(srchType,flags,result))
						{
							return true;
						}
					}	
					
				}
			}
			return false;
		}
		
		
		// recursive search the tree beginning with this node
		// recurse up until the limit
		
		public function FindChildrenBy(pattern:String,searchFlags:int,result:Array,recursionLimit:int = 10):Boolean
		{
			var kids:Array = (searchFlags & SEARCH_INTERNAL_CHILDREN ? _tempChildren:GetChildrenArray());
			var found:Boolean = false;
			var recLimit:int = 0;
			
			/* first find out if self needed to be included in results */
			if( searchFlags & SRCH_FLAG_INCLUDE_CONTAINER)
			{
				if(MatchPattern(searchFlags,pattern, this))
				{
					result.push(this);
				}
			}
			if(kids!=null && kids.length >0)
			{								
				for( var i:int = 0; i < kids.length;++i)
				{
					var curChild:ZG_PersistentObject = kids[i];
					
					// if the current object is a container - recurse
					if(curChild.isContainer)
					{
						if(recLimit++ < recursionLimit)
						{
							curChild.FindChildrenBy(pattern,searchFlags,result);
						}
						else
						{
							trace("ZG_PersistentObject::FindChildrenBy-Recursion limit of "
								  +recursionLimit + " is reached,not recursing");
						}
					}
					
					if(MatchPattern(searchFlags,pattern,curChild))	
					{
						result.push(curChild);
					}
					
					
					/*if(searchFlags & SRCH_TYPE_ID && (!found))
					{
						found = (curChild.id.toString() == pattern);
					}
					if(searchFlags & SRCH_TYPE_NAME && (!found))
					{
						found = (curChild.name == pattern);
					}
					if(searchFlags & SRCH_TYPE_INTERNAL_NAME && (!found))
					{
						found  = (curChild.internalName == pattern);
					}
					if (searchFlags & SRCH_TYPE_PARTIAL_NAME && (!found))
					{
						found = ZG_StringUtils.PartialStringMatch(curChild.name, pattern as String);
					}
					// these are mutually exclusive 
					if (searchFlags & SRCH_TYPE_DB_TYPE && (!found))
					{
						found = (curChild.type == pattern);
					}
					else if (searchFlags & SRCH_TYPE_CLASSNAME && (!found))
					{
						found  = (getQualifiedClassName(curChild) == pattern);
					}
					else if (searchFlags & SRCH_TYPE_GUID && (!found))
					{
						found = (curChild.guid == pattern);
					}
					
					if(found)
					{
						result.push(curChild);
					}*/
											
				}
			}			
			return (result.length > 0);
		}
		
		//------------------------------------------------------------------------------
		protected function MatchPattern(searchFlags:int,pattern:String,obj:ZG_PersistentObject):Boolean
		{
			var found:Boolean = false;
		
			if(searchFlags & SRCH_TYPE_ID && (!found))
			{
				found = (obj.id.toString() == pattern);
			}
			if(searchFlags & SRCH_TYPE_NAME && (!found))
			{
				found = (obj.name == pattern);
			}
			if(searchFlags & SRCH_TYPE_INTERNAL_NAME && (!found))
			{
				found  = (obj.internalName == pattern);
			}
			if (searchFlags & SRCH_TYPE_PARTIAL_NAME && (!found))
			{
				found = ZG_StringUtils.PartialStringMatch(obj.name, pattern as String);
			}
			// these are mutually exclusive 
			if (searchFlags & SRCH_TYPE_DB_TYPE && (!found))
			{
				found = (obj.type == pattern);
			}
			else if (searchFlags & SRCH_TYPE_CLASSNAME && (!found))
			{
				found  = (getQualifiedClassName(obj) == pattern);
			}
			else if (searchFlags & SRCH_TYPE_GUID && (!found))
			{
				found = (obj.guid == pattern);
			}
			
			return found;
		}
		
		//--------------------------------------------------------------------------------
		// inserts this PO into the database
		public function Insert(parent:ZG_PersistentObject):void
		{
			if( parent!=null)
			{
				_parentId = parent.id;
				_parentObj = parent;				
			}
			ZG_DataWriter.GetInstance().Insert(this);
		}
		//--------------------------------------------------------------------------------
		// since this value is not saved to db, setting it does not modify dirty state
		public function set readOnly(val:Boolean):void
		{
			_readOnly = val;
		}
		//--------------------------------------------------------------------------------
		public function get readOnly():Boolean
		{
			return _readOnly;
		}
		//---------------------------------------------------------------------
		public function SetParent(parent:ZG_PersistentObject):void
		{
			_parentObj = parent;
			_parentId = parent.id;
		}
		//---------------------------------------------------------------------
		// since this value is not saved to db, setting it does not modify dirty state
		public function set scratchStr(val:String):void
		{
			_scratchStr = val;
		}
		//--------------------------------------------------------------------------------
		public function get scratchStr():String
		{
			return _scratchStr;
		}
		//---------------------------------------------------
		public function Update():void
		{
			ZG_DataWriter.GetInstance().Update(this);
		}
		//---------------------------------------------------
		public function Delete(param:Object):void
		{
			ZG_DataWriter.GetInstance().Delete(this);
			ZG_DataReader.GetInstance().UI_UpdateObject(this,true,true);
		}
		//---------------------------------------------------
		// prepares an sql statement for this  object 
		public function ToSqlStatement(statementType:int):String
		{
			return "";
		}
		//----------------------------------------------
		// subclasses override.
		//Default behavior is either commit or update depending on ID
		public function CommitToStorage(params:Object = null):void
		{
			if( IsTempId(_id))
			{
				ZG_DataWriter.GetInstance().Insert(this);
			}
			else
			{
				ZG_DataWriter.GetInstance().Update(this);
			}	 
		}
		
		//-----------------------------------------------------------
		// subclasses override
		public function OnInsertChild(ch:ZG_PersistentObject):void
		{
			
		}
		//-----------------------------------------------------------
		// shortcut to get the array of children.
		public function GetChildrenArray():Array
		{
			return _children.toArray();
		}
		//-----------------------------------------------------
		//add child to this object
		// search if it's there by given criteria
		// ZG_PersistentObject.SRCH_TYPE_NAME = 2
		public function AddChild(newChild:ZG_PersistentObject,
								 insertIndex:int = -1,
								 searchType:int = 2):Boolean
		{
			var ret:Boolean = true;
			
			
			var searchPattern:Object;
			switch(searchType)
			{
				case SRCH_TYPE_NAME:
					searchPattern = newChild.name;
					break;
				case SRCH_TYPE_ID:
					searchPattern = newChild.id;
					break;
				case SRCH_TYPE_INTERNAL_NAME:
					searchPattern = newChild.internalName;
					break;
			}
			// if ignoring duplicates - just add the child
			if(FindChildBy(searchType ,searchPattern) == null )
			{
				if(insertIndex >=0 )
				{
					
					_children.addItemAt(newChild,Math.min(insertIndex,_children.length));
				}
				else
				{
					_children.addItem(newChild);					
				}
				newChild.SetParent(this);
				_isContainer = true;
				
				this.dirty = true;
				return true;
			}
			return false;
		}	
		
		// //-----------------------------------------------------
		// swap places of 2 children in list
		// TODO: handle errors
		public function SwapChildren(fromItem:ZG_PersistentObject,  toItem:ZG_PersistentObject):void		
		{
			var fromIndex:int = _children.getItemIndex(fromItem);
			var toIndex:int = _children.getItemIndex(toItem);
			
			if( ValidChildIndex(fromIndex) && ValidChildIndex(toIndex))
			{
				_children.setItemAt(fromItem, toIndex);
				_children.setItemAt(toItem, fromIndex);
				this.dirty = true;
			}			
		}
		//--------------------------------------------------------------------------------
		public function DeleteAllChildren():void
		{
			if(_children!=null)
			{
				_children.removeAll();
			}
		}
		// remove a given child from childrens list		
		public function DeleteChild(child:ZG_PersistentObject):void
		{
			DeleteChildByIndex(_children.getItemIndex(child));
		}
		//---------------------------------------------------
		// remove child by index
		public function DeleteChildByIndex(index:int):Boolean
		{
			if(ValidChildIndex(index))
			{
				// break association of this child with parent
				var child :ZG_PersistentObject = _children.getItemAt(index) as ZG_PersistentObject;
				if(child!=null)
				{
					child.parentObj = null;
				}
				_children.removeItemAt(index);
				this.dirty = true;
				return true;
			}
			return false;
		}
		//--------------------------------------------------------------------------------
		// make sure the index in the children array is valid
		protected function ValidChildIndex(index:int):Boolean 
		{
			return( index >=0 && index < _children.length);
		}
		// various chldren array accesors
		//---------------------------------------------------
		//return this child's index
		public function GetChildIndex(child:ZG_PersistentObject):int
		{
			return _children.getItemIndex(child);
		}
		//---------------------------------------------------
		//return  num children
		public function get numChildren():int
		{
			return _children.length;
		}
		//-------------------------------
		// subclasses override
		public function Write(param:Object = null ):Boolean
		{
			return true;
		}
		//-----------------------------------
		// subclasses override
		public function Read(file:File,param1:Object):Boolean
		{
			return true;
		}
	
		// subclasses override
		public function get guid():String
		{
			return _guid;
		}
		//-----------------------------------
		public function set guid(val:String):void
		{
			_guid = val;
		}
		//-------------------------------
		// subclasses override
		public function get isRemote():Boolean
		{
			return false;
		}
		//-------------------------------
		// generic routine to sort children of this object
		public function SortChildren(propName:String = "name",
							 isNumeric:Boolean = false,
							 descending:Boolean = false,
							 caseSensitive:Boolean = false,
							 newSort:Boolean = false):void
		{
			var i:int;
			
			// newSort means override whatever there was before
			// Sort is case sensitive by default, meaning that Z precedes A
			// In our case we make it case insensitive, 
		
			/*trace ("Before sort");
			for(i = 0; i <_children.length;++i)
			{
				trace(_children.getItemAt(i).name);
			}*/
			
			if(newSort ||_children.sort==null)
			{							
				var dataSortField:SortField = new SortField();
				dataSortField.name = propName;
				dataSortField.numeric = isNumeric;	
				dataSortField.descending = descending;
				dataSortField.caseInsensitive = !caseSensitive;
			
				// Create the Sort object and add the SortField 
				// created earlier to the array of fields to sort on
				
				var sort:Sort = new Sort();
				sort.fields = [dataSortField];		
				_children.sort = sort;
			}
			_children.refresh();
			/*trace ("After sort");
			for(i = 0; i <_children.length;++i)
			{
				trace(_children.getItemAt(i).name);
			}*/
		}
		//-------------------------------
		public function get fileObj():File
		{
			return _fileObj;
		}
		//-------------------------------
		public function set fileObj(value:File):void
		{
			_fileObj = value;
		}
		//------------------------------------
		public function get filePath():String
		{
			return (_fileObj == null ? "" : _fileObj.nativePath);
		}
		//---------------------------------------
		// Iterate list of children and update the property with a new value
		public function UpdateChildrenProperty(propName:String,propVal:Object):void
		{
			// check if children have the property and bail early if  they don't
			if(_children.length  > 0)
			{
				if(!_children.getItemAt(0).hasOwnProperty(propName))
				{
					return;
				}
			
				for (var i:int = 0; i < _children.length;++i)
				{
					var curChild:ZG_PersistentObject = _children.getItemAt(i) as ZG_PersistentObject;
					curChild[propName]=propVal;
				}
			}
		}
		// rereads all children if dirty or force is set
		public function RefreshChildren(force:Boolean,clearDirtyFlag:Boolean,parentColl:ArrayCollection):void
		{
			for (var i:int = 0; i < _children.length;++i)
			{
				var curChild:ZG_PersistentObject = _children.getItemAt(i) as ZG_PersistentObject;
				if(curChild.dirty || force)
				{
					curChild.Refresh();
					curChild.UpdateCategory(parentColl);
					if(clearDirtyFlag)
					{
						curChild.dirty = false;
					}
				}
				
			}
		}
		//-----------------------------------------
		// subclasses override
		public function UpdateCategory(collection:ArrayCollection):void
		{
			
		}
		
		//---------------------------------------
		// virtual function to update the item contents - subclases implement
		public function Refresh():void
		{
			
		}
		//--------------------------------
		// subclasses override
		public function IsValid():Boolean
		{
			return false;
		}
		//-----------------------------------
		// subclasses override
		public function Cleanup():void
		{
			
		}
		// generic function to get the data from object
		// subclasses override
		public function GetData():Object
		{
			return null;
		}
		// subclasses override
		public function FromXML( inXml:String):void
		{
			
		}
		//---------------------------------------
		public function ToXML():XML
		{
			return null
		}
		
		 		 		
	}//end class
}// end package
