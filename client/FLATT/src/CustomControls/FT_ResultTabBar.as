package CustomControls
{
	import Utility.*;
	
	import com.ZG.Utility.*;
	
	import flash.events.Event;
	
	import mx.collections.IList;
	import mx.events.ListEvent;
	
	import plus.TabBarPlus;
	import plus.TabPlus;
	import plus.tabskins.*;
	
	import spark.components.TabBar;
	import spark.events.RendererExistenceEvent;
	
	public class FT_ResultTabBar extends TabBarPlus
	{
		import mx.collections.IList;
		import mx.events.ListEvent;
		
		public function FT_ResultTabBar()
		{
			super();
		}
		
		
		//-------Aborts plugin execution
		
		override public function  onCloseTabClicked(event:ListEvent):void
		{
			var index:int = event.rowIndex;
			var displayContainer:FT_DataDisplayContainer = FT_DataDisplayContainer(dataProvider.getItemAt(index));
			if(displayContainer!=null)
			{
				displayContainer.HandleUserCanceled();
			}
			super.onCloseTabClicked(event);
			var tab:TabPlus = dataGroup.getElementAt(index) as TabPlus;
			if( tab!=null)
			{
				tab.removeEventListener(FT_Events.FT_EVT_ADJUST_TAB,OnAdjustTab);
			}
		}
			
		//-----------------------------------------
		
		//-------------------------------------
		public function AdjustTab( inTab:TabPlus, tabContainer:FT_DataDisplayContainer):void
		{
		
			var tab:TabPlus = inTab == null ?  FindTabByDataContainer(tabContainer) : inTab;
			if( tab !=null )
			{
				// find the current state of the tab and its width is already set
				if( tab.width > 0)
				{
					var tabSkin:TabPlusSkin = GetTabSkin(tab);
					if(tabSkin!=null)
					{
						tabSkin.AdjustForSchedule(tab,tabContainer.scheduleGuid);
					}
				}
			}
					
		}
		
		//--------------------------------------
		private function GetTabSkin(tab:TabPlus):TabPlusSkin
		{
			for (var i: int = 0; i < tab.numChildren;++i)
			{
				var child:TabPlusSkin = tab.getChildAt(i) as TabPlusSkin;
				if( child!=null)
				{
					return child;
				}					
			}	
			return null;
		}
		//----------------------------------
		private function FindTabByDataContainer(tabData:FT_DataDisplayContainer):TabPlus
		{
			for (var i: int = 0; i < dataGroup.numElements;++i)
			{
				var tab:TabPlus = dataGroup.getElementAt(i) as TabPlus;	
				if(tab !=null )
				{
					var tbd:FT_DataDisplayContainer = tab.data as FT_DataDisplayContainer;
					if( tbd == tabData)
					{
						return tab;
					}
				}
			}
			return null;
		}
		//-----------------------------------------
		// calle when the tab is added . At tthis time its width has been already adjusted
		override protected  function tabAdded(e:RendererExistenceEvent):void
		{
			super.tabAdded(e);
			var tab:TabPlus = dataGroup.getElementAt(e.index) as TabPlus;
			if(tab!=null)
			{
				tab.addEventListener(FT_Events.FT_EVT_ADJUST_TAB,OnAdjustTab);
			}			
		}
		//--------------------------------------------------------------
		private function OnAdjustTab(evt:Event):void
		{
			var tab:TabPlus = evt.target as TabPlus;
			if( tab !=null )
			{
				AdjustTab(tab, tab.data as FT_DataDisplayContainer);
			}
		}
		
	}
}