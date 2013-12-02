/*******************************************************************************
 * FT_Events.as
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
package Utility
{
	// FT app specific event  types
	public class FT_Events
	{
		public static  var FT_EVT_SHOW_LOGIN_PROMPT:String 	= "evt_ShowLoginPrompt";
		
		// execution related events
		public static  var FT_EVT_PLUGIN_EVENT:String 		= "evt_PluginEvent";
		// plugin execution starts with start event, progress is displayed
		// in feedback events, and result is displayed in exec end event
		public static var FT_EVT_PLUGIN_EXEC_START:String		= "evt_PluginExec_Start";
		public static var FT_EVT_PLUGIN_EXEC_FEEDBACK:String	= "evt_PluginExec_Feedback";
		public static var FT_EVT_PLUGIN_EXEC_END:String			= "evt_DisplayEnd";	
		public static var FT_EVT_PLUGIN_EXEC_NEW_HOST:String	= "evt_NewHost";	
		public static var FT_EVT_EXECUTE_PLUGIN:String			= "evt_ExecutePlugin";
		public static var FT_EVT_ADD_HOST:String 				= "evt_AddHost";
		public static var FT_EVT_HOST_IMPORT_COMPLETE:String	= "evt_HostImportComplete"; // from csv file or other sources
		public static var FT_EVT_UPDATE_UI:String 				= "evt_UpdateUI"; // something in ui needs to be updated - ui specific
		// insert events
		public static var FT_EVT_INSERT_PLUGIN:String			= "evt_InsertPlugin"; //to insert into plugin manager list and ui		
		public static var FT_EVT_INSERT_TASK:String				= "evt_InsertTask"; //to insert into plugin manager list and ui	
		public static var FT_EVT_PLUGIN_INSERTED:String				= "evt_PluginInserted"; // when insertion is complete
		public static var FT_EVT_TASK_INSERTED:String				= "evt_TaskInserted"; // ditto.
		
		public static var FT_EVT_REPO_OP_START:String			= "evt_ReposLoadStart"; // sent when a repos operation be
		public static var FT_EVT_REPO_OP_END:String				= "evt_ReposLoadEnd"; // sent when a repos operation be
		public static var FT_EVT_REPO_LOADED:String				= "evt_RepoLoaded"; // repo action-load
		public static var FT_EVT_REPO_ACTION_END:String			= "evt_RepoActionEnd"; //some repo action completed - commit, log, etc
		public static var FT_EVT_REPO_FEEDBACK:String			= "evt_RepoFeedback" ; // feedback for repo operation
		public static var FT_EVT_REPO_PUGIN_DROP:String			= "evt_RepoPluginDrop"; // user dropped an local action on repo tree
		public static var FT_EVT_REPO_PUGIN_ADDED:String		= "evt_RepoPluginAdded"; // action was added to repo and to container tree
		
		//misc
		public static var FT_EVT_VERT_RESIZE:String 			= "evt_VertResize";
		// sent when user adds a UI param. The param placeholder is inserted into command string
		public static var FT_EVT_UI_PARAM_ADDED:String			= "evt_UIParamAdded";
		// when user removes ui parameter. Removes it from command line
		public static var FT_EVT_UI_PARAM_REMOVED:String		 = "evt_UIParamRemoved";
		// proxy  log message arrived
		public static var FT_EVT_PROXY_LOG:String 				 = "evt_ProxyLog"; 
		// registration related
		public static var FT_EVT_LICENSE_EXPIRED:String				 = "evt_LicenseExpired";
		public static var FT_EVT_LICENSE_INVALID:String				 = "evt_LicenseInvalid";
		public static var FT_EVT_LICENSE_EXCEEDED:String			 = "evt_LicenseExceeded";
		// is this needed?		
		public static var FT_EVT_EXEC_ERROR:String					 = "evt_Error"; // serious error that a ui object 
		public static var FT_EVT_PLUGIN_UPLOADED:String				= "evt_PluginUploaded";		
		public static var FT_EVT_HOST_SCAN:String					= "evt_HostScan";
		// sent to UI by host scan manager
		public static var FT_EVT_HOST_SCAN_START:String				= "evt_HostScanStart";
		public static var FT_EVT_HOST_SCAN_DATA:String				= "evtHostScanData"; //got data from host scan
		public static var FT_EVT_HOST_SCAN_DONE:String				= "evtHostScanDone";// done scanning
		public static var FT_EVT_IP_ADDR_VALIDATE:String			 = "evtIPAddrtValidate"; // a validation event.
																						// used to enable OK button
																						// in options if IP addresses for host scan are valid
		public static var FT_EVT_UPDATE_TARGET_HOST:String			= "evtUpdateTargetHost";
		public static var FT_EVT_CONFIG_FILES_READY:String			= "evtConfigFilesReady"; // got a list of config files
		public static var FT_EVT_REMOVE_HOST_CONFIG:String			= "evtRemoveHostConfig"; // config file is removed
		public static var FT_EVT_EXPAND_CONTAINERS:String			=  "evtExpandContainers";// sent when a table wants to expand some items
		public static var FT_EVT_NAME_VALIDATE:String				 = "evtNameValidate"; // a validation event.Used to enable OK button in host config editor
		public static var FT_EVT_CONTEXT_MENU_HOST_ADD:String		 = "evtContextMenuHostAdd"; // Adding host via context menu 
		
		
		//scheduler events
		public static var FT_EVT_SCHEDULE_EXEC_EVT:String		 = "evtScheduleExec";// schedule timer event fired. handled by schedule manager
		public static var FT_EVT_ABORT_SCHEDULE:String		 =	   "evtScheduleAbort";// schedule timer event fired. handled by schedule manager
		public static var FT_EVT_SCHEDULES_READY:String 	= "evtSchedulesReady"; // sent when all schedules are read in
		public static var FT_EVT_REMOVE_SCHEDULE:String 	= "evtSchedulesRemove"; 
		public static var FT_EVT_SCHEDULE_RESTART:String	= "evtScheduleRestart"; // sent when action or task completes and schedule timer to be restarted
		public static var FT_EVT_ADJUST_TAB:String			= "evtAdjustTab"; // sent when tab is added. processed by the display vie and adjusts the tab for schedule
	
		// choses to display	
		//TODO: need modified as well?
		
		
		
		
		
		
		
		
		
		
		public function FT_Events()
		{
		}
	}
}
