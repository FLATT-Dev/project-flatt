/*******************************************************************************
 * ZG_PriceLabel.as
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
    
    import mx.controls.Label;
    import mx.controls.listClasses.*;

    public class ZG_PriceLabel extends Label {

        private const POSITIVE_COLOR:uint = 0x000000; // Black
        private const NEGATIVE_COLOR:uint = 0xFF0000; // Red 
        private var _propName:String = "";
        
		
		public function set propName(val:String):void
		{
			_propName = val;
		}
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            /* if the property is a number and it is negative-set the color. */
          if( (this.listData.label !=null) && this.listData.label.length >0 )
          {
          		var num:Number = ZG_StringUtils.StringToNumEx(this.listData.label);
          		// see if the label is not already formatted - if so, remove formatting         		
          		setStyle("color", (num  < 0) ? NEGATIVE_COLOR : POSITIVE_COLOR);
          }
            
        }
       
    }
}
