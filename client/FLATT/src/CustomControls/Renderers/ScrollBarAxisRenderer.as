package CustomControls.Renderers
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.charts.AxisRenderer;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.AxisBase;
	import mx.charts.chartClasses.HLOCSeriesBase;
	import mx.charts.chartClasses.Series;
	import mx.charts.chartClasses.StackedSeries;
	import mx.charts.series.AreaSeries;
	import mx.charts.series.BarSeries;
	import mx.charts.series.BubbleSeries;
	import mx.charts.series.ColumnSeries;
	import mx.charts.series.LineSeries;
	import mx.charts.series.PieSeries;
	import mx.charts.series.PlotSeries;
	import mx.collections.IList;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.controls.scrollClasses.ScrollBarDirection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.ScrollEvent;
	import mx.graphics.IStroke;
	import CustomControls.ChartScrolling.ChartDataScrollBar;
	import CustomControls.ChartScrolling.MaskedCollection;

	public class ScrollBarAxisRenderer extends AxisRenderer
	{
		[Bindable]
		public var chartScrollBar : ChartDataScrollBar;
		
		[Bindable]
		public var maskedCollection : MaskedCollection;
		
		public var series : Series;
		public var verticalAxis : AxisBase;

		private var _dataProvider : IList;
		private var _pageSize : int;
		
		private var dataProviderDirty:Boolean = false;
		
		[Bindable]
		public var lastScrollBarPosition : int;
				
 
		public function ScrollBarAxisRenderer()
		{
			super();
			maskedCollection = new MaskedCollection();
			maskedCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onMaskedCollectionChange);
			setStyle("tickPlacement", "none");
		}
		
		private function onMaskedCollectionChange(event : CollectionEvent) : void
		{
			switch (event.kind)
			{
				case CollectionEventKind.ADD:
				case CollectionEventKind.REMOVE:
					configureMask();
					break;
			}
		}

		[Bindable]
		public function set dataProvider(newDataProvider : IList) : void
		{
			
			/* Remove old data provider changed event listener */
			if(_dataProvider != null)
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProviderChanged);
			
			_dataProvider = newDataProvider;
			
			if(_dataProvider != null)
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProviderChanged);
			
			
			
			dataProviderDirty = true;
			
			invalidateProperties();
		}
		
		
		protected function dataProviderChanged(event:Event):void {
			dataProviderDirty = true;
			invalidateProperties();
		}
		
		public function get dataProvider() : IList
		{
			return _dataProvider;
		}
		
		public function set pageSize(newPageSize : int) : void
		{
			_pageSize = newPageSize;
			configureMask();
		}
		
		public function get pageSize() : int
		{
			return _pageSize;
		}
		
		private function configureMask() : void
		{
			if (chartScrollBar && dataProvider)
			{
				maskedCollection.pageSize = pageSize;				
	
				//	Any time the dataProvider changes, these calculations need to be perfomed.
				//
				//	-	The maxScrollPosition for the scrollbar can never exceed the length of the original collection minus the
				//		masked collection's page size. So, a scrollbar controlling a collection of 200 items with a page size of 30 would 
				//		never be able to go above 170, since the scroll bar position sets the start offset of the collection. A start offset 
				//		above 170 would push the total visible size over 200, which would exceed the bounds of the original collection.
				//
				//	-	The min scroll position is always 0, which is the lowest value that the start offset can be set to (i.e.
				//		the beginning of the masked collection).
				//
				//	-	The scroll bar page size is set to the length of the original collection. pageSize has a dubious description in
				//		the ASDocs,	but setting the scroll bar page size to this seems to make the thumb the right size.  
				var scrollBar : ScrollBar = chartScrollBar.scrollBar;
				scrollBar.pageSize = dataProvider.length;
				scrollBar.maxScrollPosition = (dataProvider.length - maskedCollection.pageSize);
				scrollBar.minScrollPosition = 0;
				
				// This code attempts to maintain the previous scrollbar position when a new dataProvider is assigned. Note
				// that this doesn't work when the dataProvider is incrementally adjusted from 0 upwards, since each incremental
				// add/remove forces a call to configureMask() and changes the length of the dataProvider.
				//   
				// If the scrollBar position plus the page size would be greater than the length of the collection, pull
				// it back some, but don't let it go lower than 0
				if ((scrollBar.scrollPosition + maskedCollection.pageSize) > dataProvider.length)
				{
					scrollBar.scrollPosition = Math.max(0, (dataProvider.length - maskedCollection.pageSize));
				}
	
				// Synchronize the startOffset value with the new position of the scrollBar
				maskedCollection.startOffset = getScrollBarMaskOffset();
				
				lastScrollBarPosition = maskedCollection.startOffset;
				// Tried to debug this but couldn't figure it out... I was having issues with the chart data set refreshing
				// after the reset of the maskedCollection.startOffset above. The setter was not getting called, even when the 
				// value was different from that returned by the getter. You can see that the binding on startOffset doesn't always
				// fire, by binding a Label to the startOffset. You will see that when the startOffset is greater than the number
				// of items in the dataProvider (after a change to the dataProvider), the binding on startOffset() doesn't fire.
				//
				// Explicitly calling refresh() after resetting the startOffset above "fixed" the problem. 
				maskedCollection.refresh();
	
				// Find the maximum value of the collection and tell the verticalAxis to respect it. This ensures smooth scrolling.
				if (verticalAxis is LinearAxis)
				{
					var maximumValue : Number = 0;
					var className:Object = getDefinitionByName(getQualifiedClassName(series));
					switch (className)
					{
						case StackedSeries:
						case HLOCSeriesBase:
						case PieSeries:
							// TODO: What should we do with these guys?
							break;
							
						case AreaSeries:
						case BarSeries:
						case BubbleSeries:
						case ColumnSeries:
						case LineSeries:
						case PlotSeries:
							for (var i : int = 0; i < dataProvider.length; i++)
							{
								var value : Number = dataProvider.getItemAt(i)[series["yField"]];
								maximumValue = Math.max(maximumValue, value);
							}
							break;
					}
					
					//LinearAxis(verticalAxis).maximum = maximumValue;
				}
	
				// Finally, ScrollBar doesn't seem to be smart enough to resize itself when its values are changed, so we have to call
				// invalidateDisplayList() ourselves.
				scrollBar.invalidateDisplayList();
				invalidateDisplayList();
			}
		}
		
		
		private function getScrollBarMaskOffset():Number {
				return (horizontal) ? chartScrollBar.scrollBar.scrollPosition : chartScrollBar.scrollBar.maxScrollPosition - chartScrollBar.scrollBar.scrollPosition;
			
		}
		
		private function onScroll(event : ScrollEvent) : void
		{
		
			var scrollPosition:Number = getScrollBarMaskOffset();
			var scrollDelta : int = (scrollPosition - lastScrollBarPosition);
			
			// Only adjust the mask position if there is a scroll delta. Note that sometimes the delta is so much
			// that it would blow out the collection wrapped by the mask, but the mask is robust enough to handle that 
			if (scrollDelta != 0)
			{
				var newStartOffset : int = (maskedCollection.startOffset + scrollDelta);
				lastScrollBarPosition = newStartOffset;
				maskedCollection.startOffset = newStartOffset;
			}
		}
		
		override protected function createChildren() : void
		{
			chartScrollBar = new ChartDataScrollBar(ScrollBarDirection.HORIZONTAL);
			chartScrollBar.addEventListener(Event.SCROLL, onScroll);
			addChild(chartScrollBar);
		}
		
		override protected function commitProperties() : void
		{
			
			if(dataProviderDirty) {
				maskedCollection.wrappedCollection = _dataProvider;
			
			}
			
			configureMask();
		}
		
		override protected function updateDisplayList(unscaledHeight : Number, unscaledWidth : Number) : void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			renderScrollBar();
		}
		
		private function renderScrollBar():void
		{
			var scrollBarRectangle : Rectangle = (horizontal) ? calculateHorizontalScrollBarRectangle() : calculateVerticleScrollBarRectangle();
			
			var scrollBarXPosition : Number = scrollBarRectangle.left;
			var scrollBarYPosition : Number = scrollBarRectangle.top;
			var scrollBarWidth : Number = scrollBarRectangle.width;
			var scrollBarHeight : Number = scrollBarRectangle.height;

			// Position and size scrollbar
			chartScrollBar.move(scrollBarXPosition, scrollBarYPosition);
			chartScrollBar.setActualSize(scrollBarWidth, scrollBarHeight);
		}
		
		private function calculateHorizontalScrollBarRectangle() : Rectangle
		{
			var axisStrokeWeight : Number = determineAxisStrokeWeight();	  
			var guttersRectangle : Rectangle = gutters;
			
			var isInverted : Boolean = (this.placement == "top");
			var rectangleTop : Number = isInverted ? (guttersRectangle.top - axisStrokeWeight) : (unscaledHeight - guttersRectangle.bottom);
			rectangleTop += (axisStrokeWeight / 2);
			var rectangleWidth : Number = (unscaledWidth - guttersRectangle.right - guttersRectangle.left);
			
			return new Rectangle(guttersRectangle.left, rectangleTop, rectangleWidth, axisStrokeWeight);
		}
		
		private function calculateVerticleScrollBarRectangle() : Rectangle
		{
			var axisStrokeWeight : Number = determineAxisStrokeWeight();
			var guttersRectangle : Rectangle = gutters;
	
			var isInverted : Boolean = (this.placement == "right"); 
			var rectangleTop : Number = (isInverted) ? (guttersRectangle.right - axisStrokeWeight) : (unscaledWidth - guttersRectangle.left);
			rectangleTop += (axisStrokeWeight / 2);
			var rectangleHeight : Number = (unscaledWidth - guttersRectangle.bottom - guttersRectangle.top);
			
			return new Rectangle( 0, rectangleTop, rectangleHeight, axisStrokeWeight);
		}
		
		private function determineAxisStrokeWeight() : Number
		{
			var axisStroke : IStroke = getStyle("axisStroke");
			
			return (axisStroke.weight == 0) ? 1 : axisStroke.weight;
		}				
	}
}