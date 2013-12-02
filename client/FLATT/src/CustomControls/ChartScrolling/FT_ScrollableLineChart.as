package CustomControls.ChartScrolling
{
	
	import mx.charts.*;
	import mx.charts.chartClasses.*;
	
	
	public class FT_ScrollableLineChart extends LineChart
	{
		private var _verticalRendererGapX:int = 0;
		private var _verticalRendererGapY:int = 0;
		private var _horizontalRendererGapX:int = 0;
		private var _horizontalRendererGapY:int = 0;
		
		
		public function FT_ScrollableLineChart()
		{
			super();
		}
		// only change the position of the first one
		override protected function updateAxisLayout(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateAxisLayout(unscaledWidth,unscaledHeight);
			if(horizontalAxisRenderers!=null && horizontalAxisRenderers.length > 0)
			{
				horizontalAxisRenderers[0].move(horizontalAxisRenderers[0].x+horizontalRendererGapX,
											horizontalAxisRenderers[0].y+horizontalRendererGapY);
			}
			if(verticalAxisRenderers!=null && verticalAxisRenderers.length > 0)
			{
				verticalAxisRenderers[0].move(verticalAxisRenderers[0].x+verticalRendererGapX,
					verticalAxisRenderers[0].y + verticalRendererGapY);
			}
		}
		
		//-------------------------------
		public function get horizontalRendererGapX():int
		{
			return _horizontalRendererGapX;
		}
		//-------------------------------
		public function set horizontalRendererGapX(val:int):void
		{
			_horizontalRendererGapX = val;
		}
		//-------------------------------
		public function get horizontalRendererGapY():int
		{
			return _horizontalRendererGapY;
		}
		//-------------------------------
		public function set horizontalRendererGapY(val:int):void
		{
			_horizontalRendererGapY = val;
		}
		
		//-------------------------------
		public function get verticalRendererGapX():int
		{
			return _verticalRendererGapX;
		}
		//-------------------------------
		public function set verticalRendererGapX(val:int):void
		{
			 _verticalRendererGapX = val;
		}
		//-------------------------------
		public function get verticalRendererGapY():int
		{
			return _verticalRendererGapY;
		}
		//-------------------------------
		public function set verticalRendererGapY(val:int):void
		{
			_verticalRendererGapY = val;
		}
		
	}
}