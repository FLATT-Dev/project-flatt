/*
Copyright (c) 2008 Joel May.  See:
	http://www.connectedpixel.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Note: this will likely be moved to FlexLib soon, after I clean up the code.
*/

package CustomControls.ChartScrolling
{
	import  CustomControls.ChartScrolling.skins.*;
	
	import mx.controls.HScrollBar;
	import mx.controls.VScrollBar;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.controls.scrollClasses.ScrollBarDirection;
	import mx.core.UIComponent;
	import mx.events.ScrollEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.core.FlexGlobals;
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollArrowSkin
 */
	[Style(name="downArrowDownSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollArrowSkin
 */
	[Style(name="downArrowOverSkin", type="Class", inherit="no")]
	[Style(name="thumbIcon", type="Class", inherit="no")]
	
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollThumbSkin
 */
 
	[Style(name="thumbDownSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollThumbSkin
 */	
 	[Style(name="thumbDownSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollThumbSkin
 */	
	[Style(name="thumbOverSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollThumbSkin
 */	
	[Style(name="thumbUpSkin", type="Class", inherit="no")]
	
	[Style(name="trackColors", type="Array", arrayType="uint", format="Color", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollTrackSkin
 */	
	[Style(name="trackSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollArrowSkin
 */	
	[Style(name="upArrowDisabledSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @defaultcom.adobe.charts.skins.AxisScrollArrowSkin 
 */	
	[Style(name="upArrowDownSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollArrowSkin
 */	
	[Style(name="upArrowOverSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.adobe.charts.skins.AxisScrollArrowSkin
 */	
	[Style(name="upArrowUpSkin", type="Class", inherit="no")]
	
	// It would have been easier to extend ScrollBar instead of wrapping ScrollBar.  This would have
	// simplified all this skin style forwarding.  However, ScrollBar has some mx_internal data members
	// which need to be set (see HScrollBar for exampl).  This mucks it up, so wrapping wins over inheriting.
	
	[Event(name="scroll", type="mx.events.ScrollEvent")]
	
	public class ChartDataScrollBar extends UIComponent
	{
		// These skins are derived from the Halo scrollbar skins.  They have a nasty hack.  Because the flex
		// ScrollBar class hard-codes the minimum width and we desire a narrow width here, these appear to be
		// narrower, but have an alpha=0 background rectangle that is the same width as the normal ScrollBar.
		private static var defaultStyles : Array = [
			{ name: "thumbDownSkin",		styleValue: AxisScrollThumbSkin },
			{ name: "thumbOverSkin", 		styleValue: AxisScrollThumbSkin },
			{ name: "thumbUpSkin", 			styleValue: AxisScrollThumbSkin },
			{ name: "thumbDownSkin", 		styleValue: AxisScrollThumbSkin },
			
			{ name: "downArrowDisabledSkin",styleValue: AxisScrollArrowSkin },
			{ name: "downArrowDownSkin", 	styleValue: AxisScrollArrowSkin },
			{ name: "downArrowOverSkin", 	styleValue: AxisScrollArrowSkin },
			{ name: "downArrowUpSkin", 		styleValue: AxisScrollArrowSkin },
			
			{ name: "upArrowDisabledSkin", 	styleValue: AxisScrollArrowSkin },
			{ name: "upArrowDownSkin", 		styleValue: AxisScrollArrowSkin },
			{ name: "upArrowOverSkin", 		styleValue: AxisScrollArrowSkin },
			{ name: "upArrowUpSkin", 		styleValue: AxisScrollArrowSkin },
			
			{ name: "trackSkin", 			styleValue: AxisScrollTrackSkin }
		];
		
		private static var classConstructed : Boolean = classConstruct();

		private var _alteredStyles : Object = new Object();
		private var _scrollDirection : String;

		public var scrollBar : ScrollBar;
	
		public function ChartDataScrollBar(scrollBarDirection : String)
		{
			super();

			if (scrollBarDirection != ScrollBarDirection.HORIZONTAL && scrollBarDirection != ScrollBarDirection.VERTICAL)
			{
				throw new Error("scrollBarDirection must be ScrollBarDirection.HORIZONTAL or ScrollBarDirection.VERTICAL");
			}
			_scrollDirection = scrollBarDirection;
			
			initializeAlteredStyles();
		}
		
		public function get direction() : String
		{
			return _scrollDirection;
		}
		
		override public function setActualSize(actualWidth : Number, actualHeight : Number):void
		{
			super.setActualSize(actualWidth, actualHeight);
			
			if (scrollBar != null)
			{
				scrollBar.setActualSize(actualWidth, actualHeight);
			}
		}
		
		override protected function createChildren() : void
		{
			scrollBar = (_scrollDirection == ScrollBarDirection.HORIZONTAL) ? new HScrollBar() : new VScrollBar();
            scrollBar.styleName = this;
			scrollBar.addEventListener(ScrollEvent.SCROLL, onScroll);

			addChild(scrollBar);			
		}
		
		private function onScroll(event : ScrollEvent) : void
		{
			dispatchEvent(event);
		}
		
		override protected function measure() : void
		{
			super.measure();
			
			// Reuse the values from the wrapped ScrollBar
			measuredWidth  = scrollBar.measuredWidth;
			measuredHeight = scrollBar.measuredHeight;
			measuredMinWidth  = scrollBar.measuredMinWidth;
			measuredMinHeight = scrollBar.measuredMinHeight;
			this.top =UIComponent(this.parent).bottom+10;
		}
		
		override protected function updateDisplayList(unscaledWidth : Number, unscaledHeight : Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);	
			scrollBar.setActualSize(unscaledWidth, unscaledHeight);
			
			updateScrollBarStyles();
		}
		
		private static function classConstruct() : Boolean
		{
			var style : CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("ChartDataScrollBar");
			
				//Deprecated StyleManager.getStyleDeclaration("ChartDataScrollBar");
    
        	if (!style)
        	{
            	style = new CSSStyleDeclaration();
           		//Deprecated StyleManager.setStyleDeclaration("ChartDataScrollBar", style, true);
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("ChartDataScrollBar", style, true);
        	}
        	
  			for (var i : int = 0 ; i < defaultStyles.length ; i++)
  			{
				var styleItem : Object = defaultStyles[i];
				var styleName : String = styleItem.name;
				var styleValue : * = styleItem.styleValue;
				if (style.getStyle(styleName) == undefined)
				{
					style.setStyle(styleName, styleValue);
				}
			}
       	
			return true;		
		}
		
		private function updateScrollBarStyles() : void
		{
			for (var styleProp : String in _alteredStyles)
			{
				scrollBar.setStyle(styleProp, getStyle(styleProp));
			}
			_alteredStyles = new Object();
		}
		
		private function initializeAlteredStyles():void
		{
			for (var i : int = 0 ; i < defaultStyles.length ; i++)
			{
				var styleName : String = defaultStyles[i].name;
				_alteredStyles[styleName] = true;
			}
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			_alteredStyles[styleProp] = true;
			invalidateDisplayList();
		}
	}
}