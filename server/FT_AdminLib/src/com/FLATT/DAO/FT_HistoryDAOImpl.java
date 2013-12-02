/*******************************************************************************
 * FT_HistoryDAOImpl.java
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
package com.FLATT.DAO;

import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Collection;
import java.util.Iterator;

import com.FLATT.DataObjects.*;
import com.FLATT.Database.*;
import com.FLATT.Utils.*;

public class FT_HistoryDAOImpl implements FT_HistoryDAO {

	public FT_HistoryDAOImpl() 
	{
		// TODO Auto-generated constructor stub
	}

	@Override
	public DB_History FindById(String id) 
	{
		DB_History res = null;
		ResultSet rs = null;
		try
		{
			Collection<DB_History>coll = FindBy("id=" + id);
			
			if(coll!=null)
			{
				res = (DB_History)coll.toArray()[0];
			}			
		}
		catch(Exception e)
		{
			
		}
		finally
		{
			DB_Utils.CloseResultSet(rs);
		}
		return res;
	}

	@Override
	public Collection<DB_History> LoadHistory(Timestamp start, int limit) 
	{
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public DB_History CreateHistory(DB_Action action, DB_Host host,String desc,String groupId, String taskId,String userId) 
			
	{
		DB_History result = null;
		// Make sure task and group id are not empty strings - they are integers in the db
		

		try
		{			
			// insert the action row if it's not there
			if(!StringUtils.IsValidString(action.getId()))
			{
				DB_ObjectsMgr.GetInstance().Act_Ensure(action);
			}
			
			if(!StringUtils.IsValidString(host.getId()))
			{
				DB_ObjectsMgr.GetInstance().Host_Ensure(host);
			}
			
			String strSql = "INSERT INTO `ft_admin_db`.`history` " +
							" (`action_id`,`state_id`,`result_id`,`host_id`,`desc`,`group_id`,`task_id`,`user_id`) VALUES(";
			/* Either host or group must exist */		
			strSql+= action.getId() + ",";			
			strSql+= DB_Constants.ID_STATE_IN_PROGRESS + ",";
			strSql+= DB_Constants.ID_RESULT_OK +",";
			strSql+= host.getId() + ",";
			strSql+= DB_Constants.STR_QUOTE + desc+ DB_Constants.STR_QUOTE + ",";
			strSql+= StringUtils.IsValidString(groupId) ? groupId+"," : "NULL,";
			strSql+= StringUtils.IsValidString(taskId) ? taskId+"," : "NULL,";
			strSql+= StringUtils.IsValidString(userId) ? userId+"" : "NULL";	
			strSql+=DB_Constants.STR_PAREN_CLOSE;
		
			String id = DB_Utils.InsertRow(strSql, DB_Constants.DBT_HISTORY);
			result = FindById(id);		
			
		}
		catch (Exception ex)
		{
			
		}
		finally
		{
		
		}
		return result;
	}
	//---------------------------------------------------------
	// Prepare Sql statement for a history item
	public String PrepareSqlStatement(DB_History hist) 
	{
		return  "Update history set state_id =" +
				  hist.getStateId() + 
				  ",result_id="+hist.getResultId() + 
				  " where id = " + hist.getId();		
	}
	
	@Override
	public boolean UpdateHistoryItems(Collection<DB_History> historyList) 
	{
				
		String sql = "";
		
		Iterator<DB_History> iter = historyList.iterator();
		while(iter.hasNext())
		{
			sql += PrepareSqlStatement(iter.next()) + ";";
			
		}
		return DB_Utils.GenericUpdateTx(sql);		
	}
	
	

	@Override
	public boolean DeleteHistory(String id) 
	{
		return DB_Utils.DeleteRow(id, DB_Constants.DBT_HISTORY);
	}
	//------------------------------------
	@Override
	public Collection<DB_History>FindBy(String searchString)
	{
		Collection<DB_History>res = null;
		ResultSet rs = null;

		try
		{
			rs = DB_Utils.FindBy(DB_Constants.DBT_HISTORY, searchString);
			if(rs!=null)
			{
				res = ObjectsFromRS(rs);
			}			
		}
		catch(Exception e)
		{
			
		}
		finally
		{
			DB_Utils.CloseResultSet(rs);
		}
		return res;
	}
	//-----------------------------------------------------
	// See schema for the latest definition
	protected Collection<DB_History> ObjectsFromRS(final ResultSet rs)throws java.sql.SQLException			
	{
		Collection<DB_History> result = new java.util.ArrayList<DB_History>();
		
		while (rs.next())
		{
			String id 		= rs.getString("id"); 	
			String actionId = rs.getString("action_id"); 
			String resultId = rs.getString("result_id"); 
			String stateId =  rs.getString("state_id"); 	
			String hostId 	= rs.getString("host_id"); 
			String desc		= rs.getString("desc");
			Timestamp start = rs.getTimestamp("start"); 
			Timestamp end  =  rs.getTimestamp("end");
			String	groupId	= rs.getString("group_id");
			String	taskId	= rs.getString("task_id");
			String userId   = rs.getString("user_id");
			
			DB_History cur = new DB_History( id, actionId,resultId,stateId, hostId,desc,start,end,groupId, taskId,userId);
			
			result.add(cur); 	
		}
	
	return result;
	}

}
