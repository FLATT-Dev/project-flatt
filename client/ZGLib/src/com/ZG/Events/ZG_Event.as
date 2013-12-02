/*******************************************************************************
 * ZG_Event.as
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
package com.ZG.Events
{
	import flash.events.Event;
	//import flash.utils.*;

	public class ZG_Event extends Event
	{
		// Database related
		public static const SYNC_START: String 				= "syncStart";
		public static const SYNC_COMPLETE: String			= "syncComplete";
		public static const DB_OPENED:String 				= "dbOpened";
		public static const DB_OPEN_ERR:String 				= "dbOpenErr";
		public static const DB_READ_COMPLETE:String 		= "dbReadComplete";
		public static const DB_READ_ERROR:String			= "dbReadError";
				
		// update
		public static const EVT_OBJECT_UPDATE:String		= "dbObjectUpdate";
		// insert
		public static const EVT_OBJECT_INSERT:String		= "dbObjectInsert";
		
		// insert
		public static const EVT_OBJECT_DELETE:String		= "dbObjectDelete";
		
		public static const EVT_OBJECT_INSERT_ERR:String	= "dbObjectInsertError";
		
		// Initialization related
		public static const EVT_INIT_COMPLETE:String	  	= "InitComplete";
		public static const EVT_INIT_ERROR:String			= "InitError";
		public static const EVT_DB_READING_USER_DATA:String	= "dbReadingUserData";
		public static const EVT_DB_READING_APP_DATA:String	= "dbReadingAppData";
		public static const EVT_DB_READING_DATA:String		= "dbReadingData";		
		public static const EVT_UPDATE_TRADE_FILTERS:String = "dbReadTradeFilters";
		public static const EVT_UPDATE_TIME_FILTERS:String  = "dbReadTimeFilters";
		public static const EVT_UPDATE_INSTRUMENTS:String	 = "dbReadInstruments";
		public static const EVT_UPDATE_SHORTCUTS:String		 = "dbReadShortcuts";
		public static const EVT_UPDATE_BROKER:String		 = "dbReadBrokers";
		public static const EVT_DB_READ_LOG_ENTRIES:String	 = "dbReadLogEntries";
		public static const EVT_UPDATE_TRADE_STRATEGIES:String	 = "dbReadTradeStrategies";
		// sent when an object with temp id is removed from the map of UI objects
		public static const EVT_REMOVE_TEMP_INSTRUMENT:String    = "dbRemoveTempInstrument";
		public static const EVT_REMOVE_TEMP_FILTER:String    = "dbRemoveTempFilter";
		public static const EVT_REMOVE_TEMP_STRATEGY:String   = "dbRemoveTempStrategy";
		public static const EVT_REMOVE_TEMP_BROKER:String   = "dbRemoveTempBroker";
		
		
		// children
		public static const CHILDREN_LOADED:String='childrenLoaded';
		public static const CHILDREN_NOT_LOADED:String='childrenNotLoaded';
		
		// various UI messages
		public static const EVT_TRADE_CONTAINER_SELECTED:String = "evt_TradeContainerSelected";
		public static const EVT_MARKET_SELECTED:String 			= "evt_MarketSelected";
		public static const EVT_ACCOUNT_SELECTED:String			= "evt_AccountSelected";
		public static const EVT_BROKER_SELECTED:String			= "evt_BrokerSelected";
		
		public static const EVT_TRADE_FILTER_CHANGED:String	    = "evt_TradeFilterChanged";
		public static const EVT_TRADE_STATUS_CHANGED:String	    = "evt_TradeStatusChanged";
		public static const EVT_ACCOUNT_TAB_CHANGED:String	    = "evt_AcctTabChanged";
		
		// sent by the ok or cancel button to the window in a dialog
		public static const EVT_CLOSE_DLG:String	    		= "evt_CloseDialog";
		// sent when all stock info objects are read from db and also after a lookup
		public static const EVT_STOCK_INFO_BATCH_COMPLETE:String    = "evt_StockInfoBatchComplete";
		//for single lookup complete ( inet or db)
		public static const EVT_STOCK_INFO_COMPLETE:String   		= "evt_StockInfoComplete";
		
		public static const EVT_CONNECTION_ERR:String				="evt_ConnectionError";
		
		
		// generic message sent between components to trigger ui updates (enable disable buttons, etc)
		public static const EVT_UPDATE_UI:String	    = "evt_UpdateUI";
		
		public static const EVT_READ_FILE_COMPLETE:String	= "evt_ReadFileComplete";
		public static const EVT_READ_FILE_CANCEL:String	    = "evt_ReadFileCancel";
		
		public static const EVT_SAVE_FILE_CANCEL:String	    = "evt_SaveFileCancel";
		public static const EVT_SAVE_FILE_COMPLETE:String	= "evt_SaveFileComplete";
		
		// user clicked on a trade row in the datagrid - display trade journal
		public static const EVT_TRADE_ROW_SELECTED:String		= "evt_TradeSelected";
		// user made a selection in the screen shot window
		public static const EVT_IMAGE_SELECTED:String			= "evt_ImageSelected";
		// user selected a row in the log entries datagrid
		public static const EVT_LOG_ENTRY_SELECTED:String		= "evt_LogEntrySelected";
		// fired on every file in a journal directory
		public static const EVT_LOADING_JOURNAL_ENTRIES:String   = "evt_Loading_JE";
		// called when the above is done
		public static const EVT_LOADED_JOURNAL_ENTRIES:String   = "evt_Loaded_JE";
		// called by any code that loaded an image from disc
		public static const EVT_IMAGE_LOADED:String = 			"evt_ImageLoaded";
		// trades datagrid responds to this event to delete all rows
		public static const EVT_DELETE_ALL_TRADES:String = 		"evt_DeleteAllTrades";
		
		public static const EVT_DELETE_ONE_TRADE:String = 		"evt_DeleteOneTrade";
		
		public static const EVT_MT_IMPORT_COMPLETE:String = 	"evt_MtImportComplete";
		public static const EVT_MT_IMPORT_ERROR:String 	  = 	"evt_MtImportError";
		public static const EVT_PARSE_COMPLETE:String 	  = 	"evt_ParseComplete";
		//public static const EVT_MT_IMPORT_START:String	  = 	"evt_MtImportStart";
		
		public static const EVT_SHORTCUT_SELECTED:String  =		"evt_ShortcutSelected";
		public static const EVT_PORTFOLIO_SELECTED:String  =		"evt_PortfolioSelected";
		
		// sent when there are changes that affect tree display 
		//( e.g number of trades in a trade container changes)		 
		public static const EVT_TREE_UPDATE:String =				"evt_TreeUpdate";
		public static const EVT_UPDATE_TRADEGRID_COLUMNS:String = 	"evt_UpdateTDGColumns";
		public static const EVT_TRADEGRID_DATA_CHANGED:String = 	"evt_TradeGridDataChanged";
		public static const EVT_UPDATE_ACCOUNT:String		  = 	"evt_UpdateAccount";
		// sent by main tree when parsing is done and we start to insert trades into the db
		// the event data contains the number or trades
		public static const EVT_POST_IMPORT_INSERT_START:String	   = 	"evt_PostImportInsertStart";
		public static const EVT_POST_IMPORT_INSERT_STOP:String	   = 	"evt_PostImportInsertStop";
		public static const EVT_POST_IMPORT_INSERT_PREPARE:String = 	"evt_PostImportInsertPrepare"
		
		public static const EVT_TRADE_LOG_EVENT:String =		"evt_LogEvent";
		public static const EVT_BACKUP_DONE:String =			"evt_BackupDone";
		public static const EVT_DB_CHECK_DONE:String =			"evt_TypeDbCheckDone";
		public static const EVT_APP_LOG_LOADED:String =			"evt_AppLogLoaded";
		public static const EVT_APP_LOG:String =				"evt_AppLog";//when new entry added
		
		public static const EVT_SAVE_DATA:String = "evt_SaveData";
		
		
				
		private var _xtraData:Array; // extra data one object may want send to another
		private var _errorMessage:String
		private var _data:Object; // private data
		
		//private var _success:Boolean = true;
		
		
		public function ZG_Event(type:String)
		{
			super(type);
	
		}		
		public function get errorMessage ():String
		{
			return _errorMessage;
		}
		public function set errorMessage(mess:String):void
		{
			_errorMessage = mess;
		}
		
		public function get data():Object
		{
			return _data;
		}
		public function set data(data:Object):void
		{
			_data = data;
		}
		//---------------------
		public function get xtraData():Array
		{
			return _xtraData;
		}
		//---------------------
		public function set xtraData(value:Array):void
		{
			_xtraData = value;
		}
	
		
	}
}
	
