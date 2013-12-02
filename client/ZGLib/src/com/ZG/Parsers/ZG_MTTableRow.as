/*******************************************************************************
 * ZG_MTTableRow.as
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
	import com.ZG.Utility.*;
	
	public class ZG_MTTableRow extends ZG_TableRow
	{
		
		// row types		
		public static var ROWTYPE_UNKNOWN:int 	= -1;
		public static var ROWTYPE_ACCT:int 		= 0;
		public static var ROWTYPE_TRADE:int     = 1;
		
		//XXX These map to status rows  in the database:
		public static var ROWTYPE_OPEN_TRADES_HDR:int  		= 2;
		public static var ROWTYPE_PENDING_TRADES_HDR :int 	= 3;
		public static var ROWTYPE_CLOSED_TRADES_HDR:int 	= 4;	
		
		// this is just for clarity
		public static var TRADE_STATUS_OPEN:int 	 = ROWTYPE_OPEN_TRADES_HDR;
		public static var TRADE_STATUS_PENDING:int 	 = ROWTYPE_PENDING_TRADES_HDR;
		public static var TRADE_STATUS_CLOSED:int 	 = ROWTYPE_CLOSED_TRADES_HDR;
		public static var TRADE_STATUS_CANCELLED:int = 7;
				
		// special row in closed trade that has account balance
		public static var ROWTYPE_BALANCE:int 				= 5;
		
		
		// Trade related defines
		// offsets into the trade columns array where certain values are expected
		
		// These are common for all types of trades		
		public static var TICKET_OFFSET:int 	 = 0;
		public static var OPEN_TIME_OFFSET:int   = 1;
		public static var ORDER_TYPE_OFFSET:int  = 2;
		public static var SIZE_OFFSET:int  		 = 3; //
		public static var ITEM_OFFSET:int		 = 4;
		public static var OPEN_PRICE_OFFSET:int	 = 5;
		public static var STOP_LOSS_OFFSET:int	 = 6;
		public static var TAKE_PROFIT_OFFSET:int = 7;
		
		// closed trade specific offsets
		public static var CT_CLOSE_TIME_OFFSET:int  = 8;
		public static var CT_CLOSE_PRICE_OFFSET:int = 9;
		public static var CT_COMISSION_OFFSET:int   = 10;
		public static var CT_TAXES_OFFSET:int		= 11;
		public static var CT_SWAP_OFFSET:int		= 12;
		public static var CT_PROFIT_OFFSET:int		= 13;
		
		// open trade specifc offsets -same as above.only close time is empty column
		public static var OT_CLOSE_PRICE_OFFSET:int	 = 9;
		public static var OT_COMISSION_OFFSET:int    = 10;
		public static var OT_TAXES_OFFSET:int		 = 11;
		public static var OT_SWAP_OFFSET:int		 = 12;
		public static var OT_PROFIT_OFFSET:int		 = 13;
		
	  // canceled trade specifc offsets -
		public static var CLT_CLOSE_PRICE_OFFSET:int	= 9;
		public static var CLT_PROFIT_OFFSET:int		 	= 10;
		
		//Working order trade (pending trade)  specific offsets
		public static var WO_MARKET_PRICE_OFFSET:int = 8;
		
		// expired trades speccific offsets
		public static var EXP_PROFIT_OFFSET:int			= 10;
		
		public static var CLOSED_TRADE_NUM_COLS:int 	= 14;
		public static var OPEN_TRADE_NUM_COLS :int		= 14;// one empty column
		public static var WO_TRADE_NUM_COLS:int 		= 10; // working orders - maps to pending.Includes a nbsp column
		public static var ACCT_NUM_COLS :int			= 4;
		public static var BALANCE_NUM_COLS:int			= 5;
		public static var CANCELED_TRADE_NUM_COLS:int	= 11;
		public static var EXPIRED_TRADE_NUM_COLS:int	= 11;
		
		
		// various trade types
		public static var TYPE_SELL:String 			= "sell";
		public static var TYPE_BUY:String 			= "buy";
		public static var TYPE_BALANCE:String  		= "balance";
		public static var TYPE_BUY_LIMIT:String  	= "buy limit";
		public static var TYPE_SELL_LIMIT:String 	= "sell limit";	
		public static var TYPE_BUY_STOP:String   	= "buy stop";
		public static var TYPE_SELL_STOP:String   	= "sell stop";	
		public static var TYPE_DEPOSIT:String 		= "deposit"; 
		public static var TYPE_ACCOUNT:String 		= "account:";// col 0 of the account row has this
		public static var TYPE_CANCELLED:String		= "cancelled";
		public static var TYPE_EXPIRED:String		= "expiration";
		
		// trade statuses
		public static var TYPE_CLOSED_TRADES:String 	= "closed transactions:";
		public static var TYPE_OPEN_TRADES:String 		= "open trades:";
		public static var TYPE_PENDING_TRADES:String 	= "working orders:";
		
		
		// Account specific offsets
		public static var ACCT_NUM_OFFSET:int 	    = 0;
		public static var ACCT_NAME_OFFSET:int 	    = 1;
		public static var ACCT_CURRENCY_OFFSET:int 	= 2;
		public static var ACCT_DATE_OFFSET:int 		= 3;
		public static var ACCT_AMOUNT_OFFSET:int	= 4; // closed trade representing the balance
		
		
		//what other row types are needed??
		
		
		public function ZG_MTTableRow()
		{
			super();
		}		
		
		//----------------
		// This does not handle nested tables for now
		 public override function AddColumns(rowData:String):Boolean
		{
			// find all columns
			var rawCols:Array = rowData.match(/<(td){1}.*?>.*?<(\/td){1}[^>]*?>/gis);
			if(rawCols && rawCols.length > 0)
			{
				if(_columns == null)
				{
					_columns = new Array();
				} 
				for(var i:int = 0; i < rawCols.length;++i)
				{
					AddOneColumn(rawCols[i]);
				}
				return true;			
				
			}
			return false;			
		}
		//-------------------------------------
		// Cleans up columns from various tags- <br>,etc and adds it to the columns array
		private function AddOneColumn(colData:String):void
		{
			// find the end of the column
			var pos1:int = colData.lastIndexOf("</td>");
			var pos2:int;
			if(pos1 >0)
			{
				pos2 = pos1 -1;
				pos2 = colData.lastIndexOf("</",pos2);
				if (pos2 > 0 )
				{
					do
					{
						pos2 = colData.lastIndexOf("</",pos2);
						// Takes care of a situation where we have
						// other tags, e.g BR, i.e </b></td> 
					
					} while((pos1-pos2)<4);
				}
				else
				{
					pos2 = pos1;
				}
				
				pos1 = (colData.lastIndexOf(">",pos2))+1;
			}
			if(pos2-pos1 > 0)
			{
				_columns.push(colData.substr(pos1,(pos2-pos1)));
			}
		}
		//-------------------------------------
		public function GetRowType():int
		{
			if( _columns.length > 0 )
			{			
				if(IsTrade())
				{
					return ROWTYPE_TRADE;
				}
				else if ( IsAccount())
				{
					return ROWTYPE_ACCT;
				}
				else if (IsClosedTradesHeader())
				{
					return ROWTYPE_CLOSED_TRADES_HDR;
				}
				else if (IsOpenTradesHeader())
				{
					return ROWTYPE_OPEN_TRADES_HDR;
				}
				else if (IsPendingTradesHeader())
				{
					return ROWTYPE_PENDING_TRADES_HDR;
				}
				else if ( IsBalanceRow())
				{
					return ROWTYPE_BALANCE;
				}
				
			}
			//trace("ZG_MTTableRow:Unknown row type ");
			return ROWTYPE_UNKNOWN;
		}
		//-------------------------------------
		protected  function IsTrade():Boolean
		{
			return ( HasTradeNumColumns() && HasValidTicket() && IsTradeType());			
																				 
		}
		//-------------------------------------
		protected function IsAccount():Boolean
		{
			var strAcct:String = _columns[ACCT_NUM_OFFSET].toLowerCase().substr(0,TYPE_ACCOUNT.length);
			
			return (_columns.length == ACCT_NUM_COLS && 
					(strAcct!=null && strAcct == TYPE_ACCOUNT )
					);
		}		
		//-------------------------------------
		//check if the balance row is a deposit.. what else can there ?
		public function IsDeposit():Boolean
		{
			return (_columns.length >=ORDER_TYPE_OFFSET && _columns[SIZE_OFFSET].toLowerCase()== TYPE_DEPOSIT);
		}
		//-------------------------------------
		public function IsBalanceRow():Boolean
		{
			return (_columns.length==BALANCE_NUM_COLS && _columns[ORDER_TYPE_OFFSET].toLowerCase()== TYPE_BALANCE);
		}
		//-------------------------------------
		// returrn  true if the number of columns matches open,close trade or WO
		protected function HasTradeNumColumns():Boolean
		{
			return (_columns.length == CLOSED_TRADE_NUM_COLS   || 
			        _columns.length == OPEN_TRADE_NUM_COLS     ||
			        _columns.length == WO_TRADE_NUM_COLS	   ||
			        _columns.length == CANCELED_TRADE_NUM_COLS ||
			        _columns.length == EXPIRED_TRADE_NUM_COLS
			        );
			       
		}
		//-------------------------------------
		protected function HasValidTicket():Boolean
		{
			return (_columns[TICKET_OFFSET].length > 0);
		}
				
		//-------------------------------------
		protected function IsTradeType():Boolean
		{
			return ( _columns[ORDER_TYPE_OFFSET].toLowerCase() == TYPE_SELL		|| 
					 _columns[ORDER_TYPE_OFFSET].toLowerCase() == TYPE_BUY 		||
					 _columns[ORDER_TYPE_OFFSET].toLowerCase() == TYPE_BUY_LIMIT  ||
					 _columns[ORDER_TYPE_OFFSET].toLowerCase() == TYPE_SELL_LIMIT ||
					 _columns[ORDER_TYPE_OFFSET].toLowerCase() == TYPE_SELL_STOP  ||
					 _columns[ORDER_TYPE_OFFSET].toLowerCase() == TYPE_BUY_STOP  					
					);
			
		}
		//-------------------------------------
		protected function IsClosedTradesHeader():Boolean
		{
			return(_columns.length == 1 && _columns[0].toLowerCase()== TYPE_CLOSED_TRADES);
		}
		//-------------------------------------
		protected function IsOpenTradesHeader():Boolean
		{
			return(_columns.length == 1 && _columns[0].toLowerCase()== TYPE_OPEN_TRADES);
		}
		//-------------------------------------
		// Pending  trades are called  "Working Orders" in MT4
		protected function IsPendingTradesHeader():Boolean
		{
			return(_columns.length == 1 && _columns[0].toLowerCase()== TYPE_PENDING_TRADES);
		}
		//-------------------------------------
		// clean up the column values by removing everything to the given side of the separator
		// 
		public function CleanupTokenSeparatedValues(separator:String,getRightSide:Boolean):void
		{
			for( var i:int =0; i < _columns.length;++i)
			{
				_columns[i] = ZG_StringUtils.GetTokenSeparatedValue(_columns[i],separator,getRightSide);
				
			}
		}
		
		//-------------------------------------
		public function IsCanceledTrade():Boolean
		{
			return ( _columns.length == CANCELED_TRADE_NUM_COLS &&
					 _columns[CLT_PROFIT_OFFSET].toLowerCase() == TYPE_CANCELLED);
		}
		
		//-------------------------------------
		public function TradeHasExpiration():Boolean
		{
			var strExpiration:String = _columns[EXP_PROFIT_OFFSET].toLowerCase().substr(0,TYPE_EXPIRED.length);
			if ( (_columns.length == EXPIRED_TRADE_NUM_COLS) && (strExpiration !=null && strExpiration==TYPE_EXPIRED))
			{
				SetExpirationTime();
				return true;
			}
			return false;
			
					
		}
		//-------------------------------------
		// expiration is in the form "expiration [2010.01.18 18:00]"
		// remove brackets and return  time
		public function SetExpirationTime():void
		{	
			var str:String = _columns[EXP_PROFIT_OFFSET].toLowerCase().replace(TYPE_EXPIRED,"");
			str = str.replace(/\[/gi,"");
			str = str.replace(/\]/gi,"");
			
			_columns[EXP_PROFIT_OFFSET] = str;
		}
		
		
	
	}
}
