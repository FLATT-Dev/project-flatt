/*******************************************************************************
 * FT_ActionDAOImpl.java
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
import java.util.*;

import com.FLATT.Database.*;
import com.FLATT.DataObjects.*;

import com.FLATT.DataObjects.DB_Action;

public class FT_ActionDAOImpl implements FT_ActionDAO 
{

	public FT_ActionDAOImpl() 
	{
		// 	TODO Auto-generated constructor stub
	}
	//-----------------------------------
	@Override
	public DB_Action FindById(String id) 
	{
		DB_Action res = null;
		ResultSet rs = null;
		try
		{
			Collection<DB_Action>coll = FindBy("id=" + id);
			
			if(coll!=null)
			{
				res = (DB_Action)coll.toArray()[0];
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
	//------------------------------------
	@Override
	public Collection<DB_Action> FindByGuid(String guid) 
	{
		
		return FindBy("guid='"+guid+"'");
	}
	
	//-----------------------------------
	@Override	
	public Collection<DB_Action> FindByTaskId(String taskId)
	{
		//TODO - need to select from the history and do a join of some sort
		return null;
	}

	//------------------------------------
	@Override
	public Collection<DB_Action> FindBy(String searchString) 
	{

		Collection<DB_Action>res = null;
		ResultSet rs = null;

		try
		{
			rs = DB_Utils.FindBy(DB_Constants.DBT_ACTION, searchString);
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

	
	@Override
	public DB_Action CreateAction(String guid, String name, String version) 			
	{
		DB_Action result = null;

		try
		{
			String strSql = "INSERT INTO `ft_admin_db`.`action` (`guid`,`name`, `version`) VALUES (";
			strSql +="'"+guid+"',";
			strSql +="'"+name+"',";
			strSql +="'"+version+"')";
			
			String id = DB_Utils.InsertRow(strSql, DB_Constants.DBT_ACTION);
			result = new DB_Action(id, name,  guid,  version);
		}
		catch (Exception ex)
		{
			
		}
		finally
		{
		
		}
		return result;
	
	
	}
	//-------------------------------------
	/* 
	 * ID must be set
	 * Only updating task ids
	 * Unused for the moment
	 * 
	 */
	@Override
	public boolean UpdateAction(DB_Action action) 
	{
		boolean ret = false;
		/*String sql = "Update action set task_ids =" +
					  action.getTaskIds() +
					  " where id = " + action.getId();
		if(DB_Utils.GenericUpdate(sql))
		{
			ret = true;
		}*/
		return ret;
	}

	@Override
	public boolean DeleteAction(String id) 
	{
		return DB_Utils.DeleteRow(id, DB_Constants.DBT_ACTION);
	}
	
	//--------------------------------------
	protected Collection<DB_Action> ObjectsFromRS(final ResultSet rs)throws java.sql.SQLException			
	{
		Collection<DB_Action> result = new java.util.ArrayList<DB_Action>();
	
		while (rs.next())
		{
			String id = Integer.toString(rs.getInt("id")); 	
			String guid = rs.getString("guid"); 	
			String name = rs.getString("name"); 	
			String version = rs.getString("version");
			//String taskIds = rs.getString("task_ids");
			
			DB_Action cur = new DB_Action(id,name, guid, version);
			result.add(cur); 	
		}
		
		return result;
	}

}
