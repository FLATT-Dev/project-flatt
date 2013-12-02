package CustomControls.Renderers
{
	import FLATTPlugin.*;
	
	public class FT_TaskItemRenderer extends FT_BaseNumItemsRenderer
	{
		public function FT_TaskItemRenderer()
		{
			super();
		}
		
		// display the item depending on its properties
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
		{
			// if we're displaying a plugin reference - display its number in the task 
			/*if( data is FT_PluginRef )
			{
				if( data.parentObj!=null)
				{
					this.label.text = (data.parentObj.GetChildIndex(data) + 1) + ". "+ data.name;
				}
			}
			else*/
			{
				// it's a container -display the number of pugins in it
				super.updateDisplayList(unscaledWidth,unscaledHeight);
			}
			
			//--------------------------------------
			
		}
	}
}