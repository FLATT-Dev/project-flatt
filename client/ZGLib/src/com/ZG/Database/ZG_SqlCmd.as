/*******************************************************************************
 * ZG_SqlCmd.as
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
	import mx.messaging.channels.StreamingAMFChannel;
	
	// This is a collection of various sql commands, table and column names
	// and utility routines to build commands
	public class ZG_SqlCmd
	{
		
		// Table names
		public static var TBLNAME_ACCOUNT:String 	 	= "Account";
		public static var TBLNAME_BROKER:String 	 	= "Broker";		
		public static var TBLNAME_BROKERNAME:String 	= "BrokerName";
		public static var TBLNAME_CURRENCY_PAIR:String	= "Instrument";
		public static var TBLNAME_CURRENCY_TYPE:String	= "CurrencyType";
		public static var TBLNAME_MARKET:String 	 	= "Market";
		public static var TBLNAME_ORDER_TYPE:String 	= "OrderType_"+STR_LANG_PLACEHOLDER;;
		public static var TBLNAME_TRADE:String			= "Trade";
		public static var TBLNAME_TRADE_STATUS:String	= "TradeStatus_"+STR_LANG_PLACEHOLDER;
		public static var TBLNAME_TRADE_STRATEGY:String	= "TradeStrategy_"+STR_LANG_PLACEHOLDER;
		public static var TBLNAME_TRADE_FILTER:String	= "TradeFilter";
		public static var TBLNAME_TIME_FILTER:String	= "TimeFilter";
		public static var TBLNAME_TRADE_PROP:String 	= "TradeTableProperty";
		public static var TBLNAME_TRADE_DEFAULTS:String = "TradeDefaults";
		public static var TBLNAME_DBINFO:String  		= "DbInfo";
		
		
		//public static var STR_ID_PLACEHOLDER:String 			= "%";
		public static var STR_LANG_PLACEHOLDER:String 			= "<lg>";
		
		// qualifiers
		public static var QUALIFIER_BROKER_MARKET_ID:String	= "broker.brk_marketId = ";
				
		// commands
													 
		//public static var CMD_SELECT_BROKERS:String ="select * from broker where broker.brk_marketId =%d order by broker.brk_name asc";
		public static var CMD_SELECT_BROKERS:String ="select * from broker order by broker.brk_name asc";
		// XXX  There may be multiple brokers with the same name, description but different market id..
		// It's a bit wasteful but ok, cause there are never gonna be more than 3-4 brokers, max probably 10											 
		public static var CMD_SELECT_ALL_MARKETS:String = "select * from market order by mkt_id asc";		
		public static var CMD_SELECT_ALL_TRADE_STATUSES:String = "select * from tradestatus_<lg> order by tradestatus_<lg>.trs_id asc";
		
		//public static var CMD_SELECT_ALL_ACCOUNTS:String="select * from account where account.act_brokerid=%d order by account.act_accountNumber asc;"
		public static var CMD_SELECT_ALL_ACCOUNTS:String="select * from account order by account.act_accountNumber asc;"
		
		public static var CMD_SELECT_ALL_TRADES:String = "select * from trade where trade.trd_accountId=%d";		
		
		// static tables that are prepopulated
		public static var CMD_SELECT_ALL_INSTRUMENTS:String 			= "select * from instrument order by instrument.ins_name asc";
		public static var CMD_SELECT_ALL_ORDER_TYPES:String 			= "select * from ordertype_<lg> order by ordertype_<lg>.odt_name asc";
		public static var CMD_SELECT_ALL_TRADE_STRATEGIES:String 		= "select * from tradestrategy_<lg> order by tradestrategy_<lg>.strat_name asc";
		//public static var CMD_SELECT_ALL_TRADE_GRID_COL_NAMES:String 	= "select * from tradegridcolumns_<lg>";
		public static var CMD_SELECT_ALL_TRADE_TABLE_PROPS:String 		= "select * from tradetableproperty";
	
		public static var CMD_SELECT_ALL_CURRENCY_TYPES:String 			= "select * from currencytype";
		public static var CMD_SELECT_ALL_TRADE_FILTERS:String 			= "select * from TradeFilter order by flt_id asc";
		public static var CMD_SELECT_ALL_SHORTCUTS:String 				= "select * from Shortcut order by sct_id asc";
		public static var CMD_SELECT_ALL_TIME_FILTERS:String 			= "select * from TimeFilter order by tfr_id asc";
		
		
		
		public static var CMD_INSERT_TRADE:String ="insert into trade(trd_name,trd_description,trd_accountId,trd_price,trd_instrumentId," + 
													"trd_orderTypeId,trd_statusId,trd_strategyId,trd_stopLoss,trd_takeProfit,trd_volume, " +
													"trd_swap,trd_commission,trd_ticket,trd_opentime,trd_closetime,trd_profit,trd_closeprice,trd_platform,trd_expiration)"+
													" values(:trd_name,:trd_description,:trd_accountId,:trd_price,:trd_instrumentId," + 
													":trd_orderTypeId,:trd_statusId,:trd_strategyId,:trd_stopLoss,:trd_takeProfit,:trd_volume,:trd_swap,:trd_commission,"+
													":trd_ticket,:trd_opentime,:trd_closetime,:trd_profit,:trd_closeprice,:trd_platform,:trd_expiration)";	
													
													
	    public static var CMD_INSERT_TRADE_TEMPLATE:String ="insert into trade(trd_name,trd_description,trd_accountId,trd_price,trd_instrumentId," + 
													"trd_orderTypeId,trd_statusId,trd_strategyId,trd_stopLoss,trd_takeProfit,trd_volume, " +
													"trd_swap,trd_commission,trd_ticket,trd_opentime,trd_closetime,trd_profit,trd_closeprice,trd_platform,trd_expiration)"+
													" values('%s','%s',%d,%f,%d,%d,%d,%d,%f,%f,%f,%f,%f,'%s','%s','%s',%f,%f,'%s','%s');";
													
																
	
		
		public static var CMD_UPDATE_TRADE:String = "update Trade set trd_name=:trd_name, trd_description=:trd_desc,"+
													"trd_price=:trd_price, trd_instrumentId=:trd_instrumentId, "	 +
												    "trd_orderTypeId=:trd_orderTypeId, trd_statusId=:trd_statusId,"	+
												    "trd_strategyId=:trd_strategyId,trd_stopLoss=:trd_stopLoss," 	+												 
												    "trd_takeProfit=:trd_takeProfit,trd_volume=:trd_volume, " 		+
												    "trd_swap=:trd_swap,trd_commission=:trd_commission, " 	 		+
												    "trd_ticket=:trd_ticket,trd_opentime=:trd_opentime,trd_closetime=:trd_closetime,"+
												    "trd_profit=:trd_profit,trd_closeprice=:trd_closeprice,trd_platform=:trd_platform," +
												    "trd_expiration=:trd_expiration "+
												    "where trd_id=:trd_id";												  									
		   
		public static var CMD_UPDATE_BROKER:String="update broker set brk_name=:brk_name,brk_description=:brk_desc," +
													"brk_marketId=:brk_marketId where brk_id=:brk_id"; 
		   
		public static var CMD_UPDATE_ACCOUNT:String="update account set act_brokerId=:act_brokerId,act_accountNumber=:act_accountNumber," +
													"act_amount=:act_amount,act_currencyTypeId=:act_currencyTypeId," + 
													"act_description=:act_desc,act_accountName=:act_name,act_tradeFilterId=:act_tradeFilterId," +
													" act_timeFilterId=:act_timeFilterId,act_equity=:act_equity where act_id=:act_id";
		
		public static var CMD_INSERT_BROKER:String="insert into broker(brk_marketId,brk_name) values(:parentId,:brk_name)";
		
		public static var CMD_INSERT_ACCOUNT:String="insert into account(act_brokerId,act_accountNumber,"+
													 "act_amount,act_currencyTypeId,act_description,act_accountName,act_tradeFilterId,act_timeFilterId,act_equity)" +
													 " values(:act_brokerId,:act_accountNumber,:act_amount,:act_currencyTypeId,:act_description," +
													 ":act_name,:act_tradeFilterId,:act_timeFilterId,:act_equity)";	
	
												
													
		public static var CMD_INSERT_TRADE_FILTER:String = "insert into TradeFilter(flt_name,flt_description,flt_isDefault,flt_enabledItems) "+
															"values(:flt_name,:flt_description,:flt_isDefault,:flt_enabledItems)";			
													
		 public static var CMD_UPDATE_TRADE_FILTER:String ="update TradeFilter set flt_name=:flt_name,flt_description=:flt_description,flt_isDefault=:flt_isDefault," +
		 													"flt_enabledItems =:flt_enabledItems where flt_id=:flt_id";
		 													
		
													
		 public static var CMD_INSERT_INSTRUMENT:String = "insert into Instrument(ins_name,ins_description) values(:ins_name,:ins_description)";
		 
		 public static var CMD_GENERIC_DELETE:String =  "delete from %s where %s_id=%d";
		 public static var CMD_DELETE_ALL_TRADES:String = "delete from trade where trd_accountId=%d";
		
		// trade log entry
		 public static var CMD_INSERT_LOG_ENTRY:String =  "insert into TradeLogEntry(tle_label,tle_date,tle_htmlText,tle_tradeId,tle_timeFrameIndex,tle_imageData,tle_entryType)" +
		 					" values(:tle_label,:tle_date,:tle_htmlText,:tle_tradeId,:tle_timeFrameIndex,:tle_imageData,:tle_entryType)";
		
		 public static var CMD_UPDATE_LOG_ENTRY:String = "update  TradeLogEntry set tle_label=:tle_label,tle_date=:tle_date,tle_htmlText=:tle_htmlText," +
		 					"tle_tradeId =:tle_tradeId,tle_timeFrameIndex =:tle_timeFrameIndex,tle_imageData=:tle_imageData,tle_entryType=:tle_entryType where tle_id=:tle_id"; 
		
		public static var CMD_SELECT_TRADE_LOG_ENTRIES:String  = "select * from TradeLogEntry  where tradelogentry.tle_tradeId=%d";
		
		public static var CMD_DELETE_TRADE_LOG:String = "delete from tradelogentry where tle_tradeId=%d";
	
		// update trade table property
		public static var CMD_UPDATE_TABLE_PROP_VISIBILITY:String = "update TradeTableProperty set ttp_visible=:ttp_visible where ttp_id=:ttp_id";
		
		
		public static var SQL_TYPE_INSERT:int = 0;
		public static var SQL_TYPE_UPDATE:int = 1;
		public static var SQL_TYPE_DELETE:int = 1;
		
		public static var CMD_INSERT_STRATEGY:String = "insert into %s(strat_name,strat_description,strat_isDefault,strat_openRules, "+
  														"strat_closeRules,strat_mmRules,strat_attPaths) values(:strat_name,:strat_description,:strat_isDefault,:strat_openRules,"+
  														":strat_closeRules,:strat_mmRules,:strat_attPaths)";
 	
		
		public static var CMD_UPDATE_TRADE_STRATEGY:String = "update  %s set strat_name=:strat_name,strat_description=:strat_description,strat_isDefault=:strat_isDefault, " +
		 													 "strat_openRules=:strat_openRules,strat_closeRules=:strat_closeRules,strat_mmRules=:strat_mmRules,strat_attPaths=:strat_attPaths "+
		 													 "where strat_id=:strat_id"; 
		
		
		//version table -- we're always addinbg to this table, so always select last row
		public static var CMD_SELECT_DB_VERSION:String = "select max(dbinfo.dbi_id), * from DBInfo";
		public static var CMD_INSERT_DB_VERSION:String = "insert into DbInfo(dbi_version) values(%d)";
		public static var CMD_UPDATE_DB_VERSION:String = "update DBInfo set dbv_version=:dbv_version";// not used for now
		
		
		public function ZG_SqlCmd()
		{
		}

	}
}
