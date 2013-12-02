/*******************************************************************************
 * ZG_LogImageZoomWnd.as
 * 
 * Copyright 2010-2013 Andrew Marder
 * heelcurve5@gmail.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
******************************************************************************/
package com.ZG.UI
{
	import com.ZG.Utility.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	import mx.containers.*;
	import mx.controls.Image;
	import mx.core.Window;
	import mx.managers.*;
	

	public class ZG_LogImageZoomWnd extends Window
	{
		private var _image:Image;
		public function ZG_LogImageZoomWnd()
		{
			super();
			//this.systemChrome = NativeWindowSystemChrome.NONE;
			//this.transparent = true;
			this.type = "utility";
			this.showStatusBar = false;
			//this.showTitleBar = false;
			//this.visible = false;
			this.resizable = false;
			this.showGripper  = false;	
			this.addEventListener(FocusEvent.FOCUS_OUT,OnFocusOut);
			this.addEventListener(Event.CLOSING,OnWindowClosing);
			//this.creationPolicy="queued";
				
		}
		//------------------------------------------------------
		private static	var	s_Instance:ZG_LogImageZoomWnd
		 	//------------------------------------------------
	 		public static function GetInstance():ZG_LogImageZoomWnd
	 		{
	 			if(s_Instance == null)
		 		{
		 			s_Instance = new ZG_LogImageZoomWnd();
		 			s_Instance.open();
		 		}
	 			
		 		return s_Instance;
	 		}
		 protected function OnFocusOut(event:FocusEvent):void
		{
			Cleanup(event);
		}
		//---------------------------------------------
		override protected function focusOutHandler(event:FocusEvent):void
		{
			trace("focusOutHandler");
			Cleanup(event);
			
		}
		/*override protected function mouseDownHandler(ev:MouseEvent):void
		{
			Cleanup(ev);
		}*/
		private function OnMouseClick(ev:MouseEvent):void
		{
			Cleanup(ev);
		}
		//----------------------------------------------------
		private function Cleanup(event:Event):void
		{
					
			CleanupImage();
			this.removeAllChildren();	
			if( event!=null )
			{
				event.preventDefault();		
			}	 	
			s_Instance.visible = false;		
			
		}
		//----------------------------------------------------
		public function SetImage(inImage:Image):void
		{
			
			NewImage(inImage);
			// center the window on the screen
            var screenBounds:Rectangle = Screen.mainScreen.bounds;
            //the image may be scaled so use
            // measured width and height which are true image w/h. 
          	var x:int = (screenBounds.width - inImage.measuredWidth) / 2;
          	var y:int = (screenBounds.height - inImage.measuredHeight) / 2;
          	
          	this.width =  Math.min(inImage.measuredWidth,screenBounds.width);
          	this.height = Math.min( inImage.measuredHeight,screenBounds.height);
          	var positionAtTopLeft:Boolean = (inImage.measuredWidth > screenBounds.width || inImage.measuredHeight > screenBounds.height)
			
             this.move((positionAtTopLeft ? screenBounds.x :x) ,(positionAtTopLeft ? screenBounds.y :y));
             Activate();
			
		}
		
		//------------------------------------------------
		private function OnInit():void
		{
			
		}		
		//---------------------------------------
		public function Activate():void
		{
			this.visible = true;
			this.activate();
			this.nativeWindow.orderToFront();
			
		}
		//---------------------------------------------
		private function CleanupImage():void
		{
			if(_image!=null)
			{
				_image.removeEventListener(MouseEvent.CLICK,OnMouseClick);
				 this.removeChild(_image);
				_image = null;
			}
		}
		//------------------------------------------------
		private function NewImage(srcImage:Image):void
		{
			
			CleanupImage();
			_image = new Image();
			_image.useHandCursor = true;
          	 _image.addEventListener(MouseEvent.CLICK,OnMouseClick);
          	_image.toolTip = ZG_Utils.TranslateString("Click to close");
			 this.addChild(_image);
			_image.load(srcImage.source);
		}
		//----------------------------------------------
		private function OnWindowClosing(event:Event):void
		{
			Cleanup(event);
		}

		
		
		
	}
}
