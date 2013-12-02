/*******************************************************************************
 * FT_UsersDAOImpl.java
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
import com.FLATT.Utils.StringUtils;

public class FT_UsersDAOImpl implements FT_UsersDAO 
{

	// This DAO handles generic static tables that only contain id, name and description
	// i.e Result, Permissions anb State
	
	public FT_UsersDAOImpl() 
	{
		// TODO Auto-generated constructor stub
	}

	@Override
	public Collection<DB_User> Load(String tableName) 
	{
	
			Collection<DB_User>res = null;
			ResultSet rs = null;
	
			try
			{
				rs = DB_Utils.GenericQuery("Select * from " + tableName + " order by id");
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
//-----------------------------------
	protected Collection<DB_User> ObjectsFromRS(final ResultSet rs)throws java.sql.SQLException
		
	{
		Collection<DB_User> result = new java.util.ArrayList<DB_User>();
	
		while (rs.next())
		{
			String id = Integer.toString(rs.getInt("id")); 	
			String name = rs.getString("name"); 	
			String permId = rs.getString("permissions_id"); 	
			
			DB_User cur = new DB_User(id,name, permId);
			result.add(cur); 	
		}
		
		return result;
	}
	@Override
	//-----------------------------------------------------------
	public Collection<DB_User> FindBy(String searchString)
	{
		Collection<DB_User>res = null;
		ResultSet rs = null;

		try
		{
			rs = DB_Utils.FindBy(DB_Constants.DBT_USERS, searchString);
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
	//--------------------------------------
	public DB_User FindByName(String name)
	{
		
		DB_User res = null;
		ResultSet rs = null;
		if(StringUtils.IsValidString(name))
		{
			try
			{
				Collection<DB_User>coll = FindBy("name=" + DB_Constants.STR_QUOTE + name + DB_Constants.STR_QUOTE);	
				if(coll!=null)
				{
					res = (DB_User)coll.toArray()[0];
				}			
			}
			catch(Exception e)
			{
				
			}
			finally
			{
				DB_Utils.CloseResultSet(rs);
			}
		}
		return res;
	}
	@Override
	//---------------------------------------
	public DB_User FindById(String id)
	{
		
		DB_User res = null;
		ResultSet rs = null;
		try
		{
			Collection<DB_User>coll = FindBy("id=" + id);	
			if(coll!=null)
			{
				res = (DB_User)coll.toArray()[0];
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
	//---------------------------------------
	@Override
	public Collection<DB_User> FindByPermId(String permId)
	{		
		return FindBy("permissions_id=" + permId);	
	}	
		

}
