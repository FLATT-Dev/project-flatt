/*******************************************************************************
 * DB_History.java
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
package com.FLATT.DataObjects;

import java.sql.Timestamp;

public class DB_History extends DB_BaseObject 
{

	
	private String _actionId = "";
	private String _stateId;
	private String _resultId;
	private String _hostId= "";
	private Timestamp _start;
	private Timestamp _end;
	private DB_Action _action;
	private String _hostGroupId="0"; // must have a value because these fields are numeric and cannot be empty
	private String _taskId = "0";
	private String _userId = "0";
	
	
	public DB_History(String id, 
						  String actionId,
						  String resultId,
						  String stateId,
						  String hostId,						  
						  String desc,
						  Timestamp start,
						  Timestamp end,
						  String groupId,
						  String taskId,
						  String userId) 
	{
		// TODO Auto-generated constructor stub
		super(id,"",desc);
		_actionId = actionId;
		_resultId = resultId;
		_stateId = stateId;
		_hostId = hostId;		
		_start = start;
		_end = end;
		_hostGroupId = groupId;
		_taskId = taskId;
		_userId = userId;
	}

	//-----------------------------------------
	public String getState() 
	{
		// TODO Auto-generated method stub
		return DB_StaticObjectsMgr.GetInstance().GetState(_stateId);
	}
	//-----------------------------------------
	public String getStateId() 
	{	
		 return _stateId;
	}
	//-----------------------------------------
	public void setStateId(String val) 
	{
		// TODO Auto-generated method stub
		 _stateId = val;
	}

	//-----------------------------------------
	public String getResult() 
	{
		// return from global list of possibe results - ok or err
		return DB_StaticObjectsMgr.GetInstance().GetResult(_resultId);
	}
	//-----------------------------------------
	public String getResultId() 
	{
		// TODO Auto-generated method stub
		 return _resultId;
	}
	//-----------------------------------------
	public void setResultId(String val) 
	{
		// return from global list of possibe results - ok or err
		 _resultId = val;
	}
	//-----------------------------------------
	public Timestamp getStart() 
	{
		
		return _start;
	}

	//-----------------------------------------
	public Timestamp getEnd() 
	{		
		return _end;
	}
	//-----------------------------------------
	public void setEnd(Timestamp val)
	{
		_end = val;
	}
	
	//-----------------------------------------
	public DB_Action getAction() 
	{
		// 
		if(_action == null )
		{
			_action = null; //get action object associated with this history object by id
		}
		return _action;
	}
	//--------------------------
	// for now only the values that are change - add more if needed
	@Override
	public void Copy(DB_BaseObject obj)
	{
		super.Copy(obj);
		this.setEnd(((DB_History) obj).getEnd());
		this.setResultId(((DB_History) obj).getResultId());
		this.setStateId(((DB_History) obj).getStateId());	
		//this.setUserId(((DB_History) obj).getUserId());	
	}
	//--------------------------
	public String getActionId() 
	{
		return _actionId;
	}
	//--------------------------
	public void setActionId(String val) 
	{
		_actionId = val;
	}
	//--------------------------
	public String getHostId() 
	{
		return _hostId;
	}
	//--------------------------
	public void setHostId(String val) 
	{
		this._hostId = val;
	}
	//--------------------------
	public String getHostGroupId() 
	{
		return _hostGroupId;
	}
	//--------------------------
	public void setHostGroupId(String val) 
	{
		_hostGroupId = val;
	}
	//--------------------------
	public String getTaskId() 
	{
		return _taskId;
	}
	//--------------------------
	public void setTaskId(String val) 
	{
		_taskId = val;
	}
	//--------------------------
	public String getUserId() 
	{
		return _userId;
	}
	//--------------------------
	public void setUserId(String val) 
	{
		_userId = val;
	}
}
