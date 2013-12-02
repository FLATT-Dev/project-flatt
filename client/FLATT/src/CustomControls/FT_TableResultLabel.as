package CustomControls
{
	import mx.controls.Label;
	
	public class FT_TableResultLabel extends Label
	{
		public function FT_TableResultLabel()
		{
			super();
		}
		//-------------------------------------------------------
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			/* if the property is a number and it is negative-set the color. */
			if( (this.listData.label !=null) && this.listData.label.length >0 )
			{
				var labelString:String = this.listData.label;
				// make the special "HOST column bold 
				if(labelString.indexOf("Data from ") >=0)
				{
					setStyle("fontWeight","bold");
				}
				else
				{
					setStyle("fontWeight","normal");
				}
				
			}
			
		}
	}
}