package CustomControls.Renderers
{
	import CustomControls.FT_HostsTree;
	
	import DesktopApp.*;
	
	import TargetHostManagement.FT_TargetHost;
	
	import Utility.*;
	
	import com.ZG.Utility.*;
	
	import flash.events.*;
	import flash.text.*;
	
	import mx.controls.*;
	import mx.controls.treeClasses.*;
	
	public class FT_HostsTreeItemRenderer extends FT_BaseNumItemsRenderer
	{
		private var _removeConfigBtn :Image;
		private var _treeParent:FT_HostsTree;
		
		
		public function FT_HostsTreeItemRenderer()
		{
			super();
		}
		//---------------------------------------------------------
		// for now nothing - maybe something else in future
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			var treeListData:TreeListData=TreeListData(listData);
			if(treeListData!=null)
			{
				var curItem:FT_TargetHost = treeListData.item as FT_TargetHost;
									
				if(curItem != null)
				{
					if(curItem.HasHostConfig())
					{
						
						MakeBtnVisible();					
					}
					else
					{
						if(_removeConfigBtn!=null)
						{
							_removeConfigBtn.visible = false;
						}
					}
				}
				AdjustTextWidth(curItem.name);
			}
		}
		//---------------------------------------------------------
		override protected function createChildren():void
		{
			super.createChildren();			
		}
		//--------------------------------------------------------
		private function OnClick(evt:Event):void
		{
			var treeListData:TreeListData=TreeListData(listData);
			var curItem:FT_TargetHost = treeListData.item as FT_TargetHost;
			if(curItem !=null)
			{							
				_treeParent.RemoveHostConfig(curItem);
			}
			
		}
		//-----------------------------------
		private function MakeBtnVisible():void
		{
			if(_removeConfigBtn == null)
			{
				CreateRemoveConfigBtn();
			}
				
			PositionRemoveBtn();
			_removeConfigBtn.visible=true;
			
		}
		
		//------------------------------
		private function CreateRemoveConfigBtn():void
		{
			/*_removeConfigBtn = new Button();
			_removeConfigBtn.setStyle("icon", FT_DesktopApplication.ICON_REMOVE_16);
			_removeConfigBtn.addEventListener(MouseEvent.CLICK,OnClick,true);
			addChild(_removeConfigBtn);*/
			
			_removeConfigBtn = new Image();
			_removeConfigBtn.source = "assets/remove-16.png";
			_removeConfigBtn.toolTip = "Remove Host Configuration";
			_removeConfigBtn.addEventListener(MouseEvent.CLICK,OnClick,true);			
			_removeConfigBtn.width=16;
			_removeConfigBtn.height=16;	
			_removeConfigBtn.visible = false;
			addChild(_removeConfigBtn);
		}
		//-------------------------------------------------
		private function PositionRemoveBtn():void
		{
			_removeConfigBtn.x = this.width - _removeConfigBtn.width - 10;	
		}
		//-------------------------------------------------
		public function get treeParent():FT_HostsTree
		{
			return _treeParent;
		}
		//-------------------------------------------------
		public function set treeParent(value:FT_HostsTree):void
		{
			_treeParent = value;
		}
		//-------------------------------------------
		protected function AdjustTextWidth(nameString:String):void
		{
			
			if(this.width > 0)
			{
				// measure the widerst letter in this font
				var maxCharWidth:int = this.measureText("W").width;
				var lineMetrics:TextLineMetrics = this.measureText(nameString);				
				
				var rowWidth:int = (_removeConfigBtn!=null && _removeConfigBtn.visible) ?(_removeConfigBtn.x  - this.x -5) :this.width;
					
					//(_removeConfigBtn!=null && _removeConfigBtn.visible) ?(this.width - _removeConfigBtn.width) :this.width;
				// how manhy chars can fit in this width
				if (lineMetrics.width > rowWidth )
				{
					var numChars:int = rowWidth /maxCharWidth;
					this.label.text = nameString.slice(0, numChars).concat((nameString.length > (numChars)) ? "..." : "");
					
				}
			}
		}
		//-------------------------------------
				
	}
}