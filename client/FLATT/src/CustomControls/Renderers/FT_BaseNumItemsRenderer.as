package CustomControls.Renderers
{
	import mx.controls.treeClasses.TreeItemRenderer;
	
	// base class for all tree renderers that display item count
	public class FT_BaseNumItemsRenderer extends TreeItemRenderer
	{
		public function FT_BaseNumItemsRenderer()
		{
			super();
		}
		
		//-------------------------------------
		// Sublcasses override to add whatever formatting they need
		// add a number to item name. Assumes item is ZG_PersistentObject 
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			// if it has isContainer property and children property - add num children to the display
			if(HasRequiredProps() && data.isContainer)
			{
				this.label.text = data.name + " ( " + data.children.length + " )";			
			}			
		}
		//-----------------------------------------
		// subclasses may override
		protected function HasRequiredProps():Boolean
		{
			return (data != null &&
					data.hasOwnProperty("isContainer") && 
					data.hasOwnProperty("children") &&
					data.hasOwnProperty("name"));								
		}
	}
}