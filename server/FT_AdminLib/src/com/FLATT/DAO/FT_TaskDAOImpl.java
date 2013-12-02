/*******************************************************************************
 * FT_TaskDAOImpl.java
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
import java.util.Collection;

import com.FLATT.DataObjects.*;
import com.FLATT.Database.*;

public class FT_TaskDAOImpl implements FT_TaskDAO 
{

	public FT_TaskDAOImpl() 
	{
		// TODO Auto-generated constructor stub
	}

	@Override
	public Collection<DB_Task> FindBy(String searchString) 
	{
		Collection<DB_Task>res = null;
		ResultSet rs = null;

		try
		{
			rs = DB_Utils.FindBy(DB_Constants.DBT_TASK, searchString);
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
	public DB_Task FindById(String id) 
	{
		DB_Task res = null;
		ResultSet rs = null;
		try
		{
			Collection<DB_Task>coll = FindBy("id=" + id);
			
			if(coll!=null)
			{
				res = (DB_Task)coll.toArray()[0];
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
	public Collection<DB_Task> FindByGuid(String guid) 
	{
		return FindBy("guid='"+guid+"'");
	}

	@Override
	public DB_Task CreateTask(String guid, String name, String version) 
	{
		DB_Task result = null;

		try
		{
			String strSql = "INSERT INTO `ft_admin_db`.`task` (`guid`,`name`, `version`) VALUES (";
			strSql +="'"+guid+"',";
			strSql +="'"+name+"',";
			strSql +="'"+version+"')";
			
			String id = DB_Utils.InsertRow(strSql, DB_Constants.DBT_TASK);
			result = new DB_Task(id, name,  guid,  version);
		}
		catch (Exception ex)
		{
			
		}
		finally
		{
		
		}
		return result;
	}

	@Override
	public boolean UpdateTask(DB_Task task) 
	{
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean DeleteTask(String id) 
	{
		// TODO Auto-generated method stub
		return false;
	}
	//----------------------------------
	protected Collection<DB_Task> ObjectsFromRS(final ResultSet rs)throws java.sql.SQLException			
	{
		Collection<DB_Task> result = new java.util.ArrayList<DB_Task>();
	
		while (rs.next())
		{
			String id = rs.getString("id"); 	
			String guid = rs.getString("guid"); 	
			String name = rs.getString("name"); 	
			String version = rs.getString("version");
			
			DB_Task cur = new DB_Task(id,name,version,guid);
			result.add(cur); 	
		}
		
		return result;
	}


}
