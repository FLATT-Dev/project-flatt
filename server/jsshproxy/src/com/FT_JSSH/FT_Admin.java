/*******************************************************************************
 * FT_Admin.java
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
package com.FT_JSSH;

import java.util.*;

/*
 * <FT_History version="1">
<Items>

<Item start="13" end="222" >

<Actions name="" guid="" result="OK">
<Action name="foo" guid="12344"
</Action>

</Actions>
<Hosts name="">
<Host address="122">
</Host>
</Hosts>
</Item>

</Items>
</FT_History>

select user.name,action.name,
host.address,result.name,state.name,task.name,hostgroup.name,
history.start,history.end from user,task,hostgroup,state,action,
history,result,host where user.id=history.user_id and task.id=history.task_id 
and hostgroup.id=history.group_id and host.id=history.host_id and action.id=history.action_id 
and result.id=history.result_id and state.id=history.state_id and history.id between 2 and 100 order by history.end desc;
*/

import com.FLATT.DataObjects.*;
import com.FLATT.Database.*;
import com.FLATT.Utils.*;

public class FT_Admin  implements Runnable
{
	
	private int STATE_INITIALIZING = 1;
	private int STATE_INIT_COMPLETE = 2;
	private int STATE_ERROR = 3;
	private int STATE_DONE = 4;
	
	private JSSHConnection _connection;
	
	
	private ArrayList<DB_History> _historyItems = new ArrayList<DB_History>();
	private int _state = STATE_INITIALIZING;
	
	

	
	/* This class handles database access and eventually the permissions and other things related to database */
	public FT_Admin(JSSHConnection coonection) 
	{
		_connection = coonection;
		
	}
	
	@Override
	public void run()
	{
		// if database creds are invalid - don't attempt to run
		if(_connection.getXmlParams().getDbCreds().ValidCreds())
		{
			try
			{
				if(Init())
				{
					while(_state!=STATE_DONE)
					{
						MiscUtils.Sleep(DB_Constants.SLEEP_SECS_1);// sleep for one second
					}	
				}
				else
				{
					_state = STATE_ERROR;
				}
			}
			catch(Exception err)
			{
				_state = STATE_ERROR;
			}
			finally
			{
				DB_Manager.GetInstance().DisconnectDatabase();
			}
		}
		else
		{
			// no database credentials provided - nothing to do			
			_state = STATE_DONE;
		}
		AppLog.LogIt("****FT_Admin:Database done, state = " + Integer.toString(_state) + "****",
												AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_ALL);	
	}
	//---------------------------------------------
	public boolean Init()
	{		
		try
		{
			DB_Manager.GetInstance().InitDatabase(_connection.getXmlParams().getDbCreds().getUrl(),
												  _connection.getXmlParams().getDbCreds().getUsername(),
												  _connection.getXmlParams().getDbCreds().getPassword());				
			InsertHistoryItems();
			_state = STATE_INIT_COMPLETE;
			AppLog.LogIt("FT_Admin:Database init completed ",AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_ALL);					
			//TODO: deal with user authorization and level of access			
		}
		catch(Exception err)
		{
			AppLog.LogIt("Failed to initialize database: " + err.getMessage(),
						AppLog.LOG_LEVEL_ERROR,
						AppLog.LOGFLAGS_ALL);
			
			_state = STATE_ERROR;
		}		
		return (_state == STATE_INIT_COMPLETE );
	}
	//--------------------------------
	/*
	 * Insert new history item.
	 * Ensure all 
	 */
	
	private void InsertHistoryItems() 
	{
		
		/* The logic is as follows, applies to both actions and host groups
		 * -First determine if there is a group ( or task)
		 * If there is - insert in the db if needed or get the id
		 * for every host ( or action):
		 * Find out if it exists in the db. If it does not - insert.
		 * -Get its id.
		 * Check if the id of the group ( or task is in the ids field
		 * - 
		*/
		
		EnsureHostGroup();
		EnsureTask();	
		DB_User dbUser = DB_ObjectsMgr.GetInstance().User_FindByName(_connection.getXmlParams().getDbCreds().getUsername());
		
		// If client provided no name - use special %USR% row in the database.
		// This is temporary, until users are fully implemented. The presence of a value helps selecting row for display
		if(dbUser == null)
		{
			dbUser = new DB_User();
		}		
		
		for(int i = 0; i < _connection.getXmlParams().getActions().size(); ++ i)
		{
			FT_Action curAct = _connection.getXmlParams().getActions().get(i);
			
			for(int k = 0; k < _connection.getXmlParams().getHosts().size(); ++k)
			{
				FT_Host  curHost = _connection.getXmlParams().getHosts().get(k);	
				InsertHistoryItem(curAct,curHost,"",(dbUser == null ? "" : dbUser.getId()));//description is unused for now
				MiscUtils.Sleep(500); // sleep half a second between insertions to 
			}
		}
		
	}
	//-----------------------------------
	private void InsertHistoryItem(FT_Action curAct,FT_Host curHost ,String desc,String userId)
	{
		// now that the groups and tasks are in the db, make sure the actions and hosts are updated
		/*if(_connection.getXmlParams().HasGroup())
		{
			curHost.AddGroupId(_connection.getXmlParams().GetHostGroup().getId());
		}
		
		if(_connection.getXmlParams().HasTask())
		{
			curAct.AddTaskId(_connection.getXmlParams().GetTask().getId());
		}*/
		FT_History hist =  new FT_History(DB_ObjectsMgr.GetInstance().Hist_Create(curAct, 
																				 curHost, 
																				 desc,
																				 _connection.getXmlParams().GetHostGroup().getId(),
																				 _connection.getXmlParams().GetTask().getId(),
																				 userId) );																				
		if(hist!=null)
		{
			// now that the action and host are in the db,this will help us identify the history row for update
			hist.setAction(curAct);
			hist.setHost(curHost);		
			_historyItems.add(hist);
		}
		/*else
		{
			//TODO: report
		}*/
	}
	//-----------------------------------
	// Make sure that if we have a host group it is stored in the db our reference has the host group id
	void EnsureHostGroup()
	{
		/* We always create group objects even when there is no group, using row id 1 hard coded in the db
		 * This is done so that the group ID in the database is not null so that we can select rows for display 
		 * 
		 */		
	DB_ObjectsMgr.GetInstance().HostGrp_Ensure(_connection.getXmlParams().GetHostGroup());			
						 
	}
	//-----------------------------------
	void EnsureTask()
	{
		/* We always create task objects even when there is no task, using row id 1 hard coded in the db
		 * This is done so that the task ID in the database is not null so that we can select all rows for display 
		 * 
		 */
		DB_ObjectsMgr.GetInstance().Task_Ensure(_connection.getXmlParams().GetTask());					
	}
	
	//--------------------------------
	public void UpdateHistoryItems()
	{
			
		Collection<SSHExec>execObjs = _connection.getExecObjsMap().values();
		Iterator<SSHExec> iter = execObjs.iterator();
		// this relies on thge fact that the number of history items in the list is the same as 
		while(iter.hasNext())
		{			
			SSHExec exec = iter.next();
			ArrayList<DB_History> historyItems = FindHistoryItemsForExec(exec);			
			UpdateHistoryItemsForExec(historyItems,exec);			
		}
		// And now blast to database.
		if(!DB_ObjectsMgr.GetInstance().Hist_Update(_historyItems))
		{
			AppLog.LogIt("Failed to update history items: ",
						AppLog.LOG_LEVEL_ERROR,
						AppLog.LOGFLAGS_ALL);
		}
		
	}
	//--------------------------------
	/* Find all history items associated with this exec object.
	 * If we have a task the exec object may have multiple commands.
	 * 
	 */
	private ArrayList<DB_History> FindHistoryItemsForExec(SSHExec host)
	{
		ArrayList<DB_History> ret = new ArrayList<DB_History>();
		
		Iterator<DB_History> iter = _historyItems.iterator();
		while(iter.hasNext())
		{			
			FT_History histObj = (FT_History)iter.next();
			if(histObj.getHost().getAddress().equals(host.getHostAddr()))
			{
				ret.add(histObj);
			}
		}
		return ret;							
	}
	//--------------------------------
	/* multiple history items for exec means a task */
	private void UpdateHistoryItemsForExec(ArrayList<DB_History> historyItems,SSHExec exec)
	{		
		for(int i=0; i < historyItems.size();++i)
		{
			FT_History histObj = (FT_History) historyItems.get(i);	
			// find updated action from the exec's list.
			FT_Action updatedAction = exec.FindAction(histObj.getAction());
			// if action in the exec could not be found - which is unlikely
			// - use the one from the history object ( which is the reference of the one in xml params
			if(updatedAction == null)
			{
				updatedAction = histObj.getAction();
			}
			histObj.setResultId(MapResultString(updatedAction.getResult()));
			histObj.setStateId(exec.getClientCanceled() ? DB_Constants.ID_STATE_CANCELED :DB_Constants.ID_STATE_COMPLETED );				
		}				
	}
	//--------------------------------
	protected void Cleanup()
	{
		int numSecs = 0;
		while(_state == STATE_INITIALIZING && (numSecs < DB_Constants.WAIT_DB_INIT_SECS))
		{
			/* Give it a some time to complete initialization, 
			 * in case there are problems connecting to the database
			 * and we're not done initializing when the connection is done 
			 */
				MiscUtils.Sleep(DB_Constants.SLEEP_SECS_1);
				numSecs+=DB_Constants.SLEEP_SECS_10;
		}
		if(_state == STATE_INIT_COMPLETE)
		{
			// Only update history items if the initialization completed successfully
			UpdateHistoryItems();
		}
		CleanupExecActions();
		_state = STATE_DONE; // this will terminate the thread.
		
	}
	
	//-----------------------------
	private String MapResultString(String res)
	{
		if(res.equals(SSHJResponse.STATUS_OK))
		{
			return DB_Constants.ID_RESULT_OK;		
		}
		else if(res.equals(SSHJResponse.STATUS_ERR))
		{
			return DB_Constants.ID_RESULT_ERR;				
		}
		else if(res.equals(SSHJResponse.STATUS_CONN_ERR))
		{
			return DB_Constants.ID_RESULT_CONN_ERR;				
		}
		else if(res.equals(SSHJResponse.STATUS_CONN_CANCELED))
		{
			return DB_Constants.ID_STATE_CANCELED;				
		}
			
		return DB_Constants.ID_RESULT_NA;
	}
	//0----------------------------------
	private void CleanupExecActions()
	{
		/* As a last step clean up the action maps in all exec objects */
		Collection<SSHExec>execObjs = _connection.getExecObjsMap().values();
		Iterator<SSHExec> iter = execObjs.iterator();
		// this relies on thge fact that the number of history items in the list is the same as 
		while(iter.hasNext())
		{			
			SSHExec exec = iter.next();			
			exec.CleanupActions();
		}
	}
}
