/*******************************************************************************
 * ZG_SqlStatement.as
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
package com.ZG.Database
{
	import flash.data.SQLStatement;
	
	public class ZG_SqlStatement extends SQLStatement
	{
		private var _currentObj:SQLStatement;
		
		public function Prepare():void
		{
			
		}		
		public  function Init(colValues:Array):void
		{
			for(var i:int =0; i< colValues.length;++i)
			{
				this.parameters[i] = colValues[i];
			}
		}
		
		
	}
}
