package DesktopApp
{
	import CustomControls.*;
	
	import FLATTPlugin.*;
	
	import HostConfiguration.FT_HostConfig;
	
	import flash.filesystem.*;
	
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;

	//This class handles common tasks associated with drag and drop
	
	public class FT_DragHelper
	{
		private var _helpee:Object;
		
		private var _allowsPluginDrop:Boolean;
		private var _allowsTaskDrop:Boolean;
		private var _allowsHostConfigDrop:Boolean;
		
		
		public function FT_DragHelper()
		{
		}
		//----------------------------
		public function get helpee():Object
		{
			return _helpee;
		}
		//----------------------------
		public function set helpee(value:Object):void
		{
			_helpee = value;
		}
		//-----------------------------------------------
		// Get the object being dragged and dropped
		// Drag source contains an array of objects in formats specified by
		// array of formats. We assume that only one object can be dragged and 
		// hence there is only one element in the array
		public function GetDragSourceObject(dragSource:DragSource):Object
		{				
			var draggedObjectsArr:Array = dragSource.dataForFormat(dragSource.formats[0])as Array;
			
			if( draggedObjectsArr!= null && draggedObjectsArr.length  > 0 )
			{
				return(draggedObjectsArr[0]);
			}
			return null;				
		}
		//-----------------------------------------
		public function DragObjectAllowed(obj:Object):Boolean
		{
			// don't allow to drag tasks around
			if(obj is FT_Task)
			{
				return allowsTaskDrop;
			}
			if( obj is FT_Plugin || obj is FT_PluginRef )
			{
				return allowsPluginDrop;
			}
			else if ( obj is FT_HostConfig)
			{
				return allowsHostConfigDrop;
			}
			else if ( obj is File )
			{			
				var extension:String = File(obj).extension;
				if(extension!=null)
				{
					if(helpee is FT_HostsTree)
					{
						return (extension == "txt" || extension == "csv");	
					}
					else if (helpee is FT_PluginTree)
					{
						return (extension == "xml");
					}
				}
			}
			return false;
		}
		//-----------------------------------------------
		public function get allowsPluginDrop():Boolean
		{
			return _allowsPluginDrop;
		}
		//-----------------------------------------------
		public function set allowsPluginDrop(value:Boolean):void
		{
			_allowsPluginDrop = value;
		}
		//-----------------------------------------------
		public function get allowsTaskDrop():Boolean
		{
			return _allowsTaskDrop;
		}
		//-----------------------------------------------
		public function set allowsTaskDrop(value:Boolean):void
		{
			_allowsTaskDrop = value;
		}
		//-----------------------------------------------
		public function get allowsHostConfigDrop():Boolean
		{
			return _allowsHostConfigDrop;
		}
		//-----------------------------------------------
		public function set allowsHostConfigDrop(value:Boolean):void
		{
			_allowsHostConfigDrop = value;
		}
		//-----------------------------------------------
	}
}