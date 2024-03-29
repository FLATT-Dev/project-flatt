////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

// Copied from mx.skins.halo.SliderThumbSkin and hacked by Joel May, connectedpixel.com, 
// as part of the scrolling charts feature.

// All hacking is related to making the scrollbar thinner so that it fits on the
// Chart axis line.  This code has not been tested with the vertical axis, nor has 
// it been tested with an altered axis line.   

package CustomControls.ChartScrolling.skins
{
	import mx.skins.halo.ScrollArrowSkin;
	import flash.display.GradientType;
	import mx.styles.StyleManager;
	import flash.display.Graphics;
	import mx.skins.halo.HaloColors;
	import mx.utils.ColorUtil;
	import mx.core.FlexGlobals;
	
	public class AxisScrollArrowSkin extends ScrollArrowSkin
	{
		public function AxisScrollArrowSkin()
		{
			super();
		}
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 */
		private static var cache:Object = {};
	
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 *  Several colors used for drawing are calculated from the base colors
		 *  of the component (themeColor, borderColor and fillColors).
		 *  Since these calculations can be a bit expensive,
		 *  we calculate once per color set and cache the results.
		 */
		private static function calcDerivedStyles(themeColor:uint,
												  borderColor:uint,
												  fillColor0:uint,
												  fillColor1:uint):Object
		{
			var key:String = HaloColors.getCacheKey(themeColor, borderColor,
													fillColor0, fillColor1);
			
			if (!cache[key])
			{
				var o:Object = cache[key] = {};
				
				// Cross-component styles.
				HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
				
				// ScrollArrow-specific styles
				o.borderColorDrk1 = ColorUtil.adjustBrightness2(borderColor, -25);
				o.borderColorDrk2 = ColorUtil.adjustBrightness2(borderColor, -50);
			}
			
			return cache[key];
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
	
			// User-defined styles.
			var backgroundColor:Number = getStyle("backgroundColor");
			var borderColor:uint = getStyle("borderColor");
			var fillAlphas:Array = getStyle("fillAlphas");
			var fillColors:Array = getStyle("fillColors");
			FlexGlobals.topLevelApplication.styleManager.getColorNames(fillColors);
			//StyleManager.getColorNames(fillColors);
			var highlightAlphas:Array = getStyle("highlightAlphas");				
			var themeColor:uint = getStyle("themeColor");
			
			var upArrow:Boolean = (name.charAt(0) == 'u');
			
			// Placeholder styles stub.
			var arrowColor:uint = 0x111111;
			
			// Derived styles.
			var derStyles:Object = calcDerivedStyles(themeColor, borderColor,
													 fillColors[0], fillColors[1]);
	
			var horizontal:Boolean = parent &&
									 parent.parent &&
									 parent.parent.rotation != 0;
			
			var borderColors:Array;
			if (upArrow && !horizontal)
				borderColors = [ borderColor, derStyles.borderColorDrk1 ];
			else
				borderColors = [ derStyles.borderColorDrk1,
								 derStyles.borderColorDrk2 ];
	
			//------------------------------
			//  background
			//------------------------------
			
			var g:Graphics = graphics;
			g.clear();
			
			if (isNaN(backgroundColor))
				backgroundColor = 0xFFFFFF;
				
			drawRoundRect(
					0, 0, w, h, 0,
					0xffffff, 0);
			
			// Opaque backing to force the scroll elements
			// to match other components by default.
			// Do not draw it for disabled arrows.
			w *= 0.6;
			
			if (name.indexOf("Disabled") == -1)
			{
				drawRoundRect(
					0, 0, w, h, 0,
					backgroundColor, 1);
			}                         
			
	
			switch (name)
			{
				case "upArrowUpSkin":
				{			
					// shadow
					if (!horizontal)
					{
						drawRoundRect(
							1, h - 4, w - 2, 8, 0,
							[ derStyles.borderColorDrk1,
							  derStyles.borderColorDrk1 ], [ 1, 0 ],
							verticalGradientMatrix(1, h - 4, w - 2, 8),
							GradientType.LINEAR, null, 
							{ x: 1, y: h-4, w: w - 2, h: 4, r: 0 });
					}
	
					// intentionally fall through to the next case statement
				}
	
				case "downArrowUpSkin":
				{
	   				var upFillColors:Array = [ fillColors[0], fillColors[1] ];
	   				var upFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];
	
					// border
					drawRoundRect(
						0, 0, w, h, 0,
						borderColors, 1,
						horizontal ?
						horizontalGradientMatrix(0, 0, w, h) :
						verticalGradientMatrix(0, 0, w, h),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0 });  
	
					// fill
					drawRoundRect(
						1, 1, w - 2, h - 2, 0,
						upFillColors, upFillAlphas,
						horizontal ?
						horizontalGradientMatrix(0, 0, w - 2, h - 2) :
						verticalGradientMatrix(0, 0, w - 2, h - 2 / 2));
					
					// top bighlight
					drawRoundRect(
						1, 1, w - 2, h - 2 / 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						horizontal ?
						horizontalGradientMatrix(0, 0, w - 2, h - 2) :
						verticalGradientMatrix(0, 0, w - 2, h - 2 / 2));
					
					break;
				}
				
				case "upArrowOverSkin":
				{                           
					// shadow
					if (!horizontal)
					{
						drawRoundRect(
							1, h - 4, w - 2, 8, 0,
							[ derStyles.borderColorDrk1,
							  derStyles.borderColorDrk1 ], [ 1, 0 ],
							verticalGradientMatrix(1, h - 4, w - 2, 8),
							GradientType.LINEAR, null, 
							{ x: 1, y: h-4, w: w - 2, h: 4, r: 0}); 
					}
	
					// intentionally fall through to the next case statement
				}
				
				case "downArrowOverSkin":
				{
					var overFillColors:Array;
					if (fillColors.length > 2)
						overFillColors = [ fillColors[2], fillColors[3] ];
					else
						overFillColors = [ fillColors[0], fillColors[1] ];
	
					var overFillAlphas:Array;
					if (fillAlphas.length > 2)
						overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
	  				else
						overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	
					// white backing to force the scroll elements
					// to match other components by default
					drawRoundRect(
						0, 0, w, h, 0,
						0xFFFFFF, 1);  
	
					// border
					drawRoundRect(
						0, 0, w, h, 0,
						[ themeColor, derStyles.themeColDrk1 ], 1,
						horizontal ?
						horizontalGradientMatrix(0, 0, w, h) :
						verticalGradientMatrix(0, 0, w, h),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0}); 
	
					// fill
					drawRoundRect(
						1, 1, w - 2, h - 2, 0,
						overFillColors, overFillAlphas,
						horizontal ?
						horizontalGradientMatrix(0, 0, w - 2, h - 2) :
						verticalGradientMatrix(0, 0, w - 2, h - 2)); 
					
					// top highlight
					drawRoundRect(
						1, 1, w - 2, h -2 / 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						horizontal ?
						horizontalGradientMatrix(0, 0, w - 2, h - 2) :
						verticalGradientMatrix(0, 0, w - 2, h - 2 / 2)); 
					break;
				}
				
				case "upArrowDownSkin":
				{	
					// shadow
					if (!horizontal)
					{
						drawRoundRect(
							1, h - 4, w - 2, 8, 0,
							[ derStyles.borderColorDrk1,
							  derStyles.borderColorDrk1 ], [ 1, 0 ],
							horizontal ?
							horizontalGradientMatrix(1, h - 4, w - 2, 8) :
							verticalGradientMatrix(1, h - 4, w - 2, 8),
							GradientType.LINEAR, null, 
							{ x: 1, y: h - 4, w: w - 2, h: 4, r: 0 }); 
					}
						
					// intentionally fall through to the next case statement
				}
	
				case "downArrowDownSkin":
				{
					// border
					drawRoundRect(
						0, 0, w, h, 0,
						[ themeColor, derStyles.themeColDrk1 ], 1,
						horizontal ?
						horizontalGradientMatrix(0, 0, w, h) :
						verticalGradientMatrix(0, 0, w, h),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }); 
	
					// fill
					drawRoundRect(
						1, 1, w - 2, h - 2, 0,
						[ derStyles.fillColorPress1,
						  derStyles.fillColorPress2 ], 1,
						horizontal ?
						horizontalGradientMatrix(0, 0, w - 2, h - 2) :
						verticalGradientMatrix(0, 0, w - 2, h - 2)); 
					
					// top highlight
					drawRoundRect(
						1, 1, w - 2, h -2 / 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						horizontal ?
						horizontalGradientMatrix(0, 0, w - 2, h - 2) :
						verticalGradientMatrix(0, 0, w - 2, h - 2 / 2)); 
					break;
				}
				
				default:
				{
					drawRoundRect(
						0, 0, w, h, 0,
						0xFFFFFF, 0);
					
					return;
					break;
				}
			}
	
			// Draw up or down arrow
			g.beginFill(arrowColor);
			if (upArrow)
			{
				g.moveTo(w / 2, 6);
				g.lineTo(2, h - 6);
				//g.lineTo(w - 5, h - 6);
				//g.lineTo(5, h - 6);
				g.lineTo(w-2, h - 6);
				g.lineTo(w / 2, 6);
			}
			else
			{
				g.moveTo(w / 2, h - 6);
				//g.lineTo(w - 5, 6);
				g.lineTo(2, 6);
				//g.lineTo(5, 6);
				g.lineTo(w-2, 6);
				g.lineTo(w / 2, h - 6);
			}
			g.endFill();
		}
	}
}