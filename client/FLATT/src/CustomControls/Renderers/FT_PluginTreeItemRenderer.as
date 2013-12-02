package CustomControls.Renderers
{
	import FLATTPlugin.FT_Plugin;
	
	import mx.controls.treeClasses.TreeItemRenderer;
	
	public class FT_PluginTreeItemRenderer extends FT_BaseNumItemsRenderer
	{
		public function FT_PluginTreeItemRenderer()
		{
			super();
		}
		//--------------------------------------------------------------
		// display the item depending on its properties
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(data!=null && data is FT_Plugin)
			{
				
				var strStyle:String = "normal";
				if(data.isRemote && data.dirty)
				{
					strStyle = "italic";
				}
				
				//setStyle("fontStyle", (data.isRemote ? "italic" : "normal"));
				setStyle("fontStyle",strStyle);
			}
				
			
		}
													  
	}
}