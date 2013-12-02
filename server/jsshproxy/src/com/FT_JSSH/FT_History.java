/*******************************************************************************
 * FT_History.java
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

import com.FLATT.DataObjects.*;


public class FT_History  extends DB_History
{
	private FT_Host _host;
	private FT_Action _action;
	private DB_History _dbHistory;
	
	public FT_History() 
	{
		super("", "","","","", "", null,null,"","","");
				 
		// TODO Auto-generated constructor stub
	}
	//--------------------------------------
	// ctor from db history
	public FT_History(DB_History hist)
	{
		super(hist.getId(),
			  hist.getActionId(),
			  hist.getResultId(),
			  hist.getStateId(),
			  hist.getHostId(),
			  hist.getDesc(),
			  hist.getStart(),
			  hist.getEnd(),
			  hist.getHostGroupId(),
			  hist.getTaskId(),
			  hist.getUserId());
		
	}
	//--------------------------------------
	public FT_Host getHost()
	{
		return _host;
	}
	//--------------------------------------
	public void setHost(FT_Host val)
	{
		_host = val;
	}
	public FT_Action getAction()
	{
		return _action;
	}
	//--------------------------------------
	public void setAction(FT_Action val)
	{
		this._action = val;
	}
	public DB_History getDbHistory() 
	{
		return _dbHistory;
	}
	public void setDbHistory(DB_History val) 
	{
		this._dbHistory = val;
	}

}
