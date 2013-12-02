/*******************************************************************************
 * ZG_TableRow.as
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
package com.ZG.Parsers
{
	
	// A generic class that represents a table row and its columns
	public class ZG_TableRow
	{
		public var _columns:Array; // TODO: for debugging,change to protected
		
		public function ZG_TableRow()
		{
			_columns = new Array();
		}
		
		/*private  function get columns():Array
		{
			return _columns;
		}*/
		
		public function AddColumns(rowData:String):Boolean
		{
			return false;
		}
		//-------------------------------------------------
		public function GetColumnValue(colOffset:int):String
		{
			if ( colOffset < _columns.length )
			{
				return ( _columns[colOffset]);
			}
			//bad
			trace("ZG_TableRow::GetColumnValue: bad offset");
			return null;
		}
		//-------------------------------------------------
		public function AddColumn(val:Object):void
		{
			_columns.push(val);
		}

	}
}
