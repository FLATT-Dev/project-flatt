/*******************************************************************************
 * FT_HostDAOImpl.java
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
import java.util.Iterator;

import com.FLATT.DataObjects.*;
import com.FLATT.Database.DB_Constants;
import com.FLATT.Database.DB_Utils;
import com.FLATT.Utils.AppLog;


public class FT_HostDAOImpl implements FT_HostDAO
{
	//---------------------------------
	@Override
	public DB_Host FindById(String id)
	{
		DB_Host res = null;
		ResultSet rs = null;
		try
		{
			Collection<DB_Host>coll = FindBy("id=" + id);
			
			if(coll!=null)
			{
				res = (DB_Host)coll.toArray()[0];
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
	//--------------------------
	@Override
	public DB_Host FindByAddress(String addr)
	{
		DB_Host res = null;
		ResultSet rs = null;
		try
		{
			Collection<DB_Host>coll = FindBy("address=" + addr);	
			if(coll!=null)
			{
				res = (DB_Host)coll.toArray()[0];
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
	//--------------------------
	@Override
	public Collection<DB_Host> FindByPermId(String permId)
	{		
		return FindBy("permissions_id="+permId);
	}
	//--------------------------------------------------------------
	@Override
	public Collection<DB_Host>FindBy(String searchString)
	{
		Collection<DB_Host>res = null;
		ResultSet rs = null;

		try
		{
			rs = DB_Utils.FindBy(DB_Constants.DBT_HOST, searchString);
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
	//----------------------------------------
	@Override
	public DB_Host CreateHost(String address,  
							  String username, 
							  String password,
							  String sshKey,
							  String permId)
							 
	{
		DB_Host result = null;
		try
		{
			String strSql = "INSERT INTO `ft_admin_db`.`host` (`address`,`permissions_id`,`username`,`password`,`ssh_key`)" +
											" VALUES (";
			strSql +="'"+address+"',";			
			strSql +="'"+permId+"',";
			strSql +="'"+username+"',";
			strSql +="'"+password+"',";
			strSql +="'"+sshKey+"')";
			
			
			
			String id = DB_Utils.InsertRow(strSql, DB_Constants.DBT_HOST);
			result = new DB_Host(id, address,  permId,  username,  password, sshKey);
		}
		catch (Exception ex)
		{
			AppLog.LogIt("Exception creating host, "+ ex.getMessage(),
						 	AppLog.LOG_LEVEL_ERROR,
						 	AppLog.LOGFLAGS_ALL);
		}
		finally
		{
		
		}
		return result;
	
	}

	@Override
	public boolean UpdateHost(DB_Host DB_Host)
	{
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean DeleteHost(String id)
	{
		// TODO Auto-generated method stub
		return false;
	}
	@Override
	public Collection<DB_Host> FindByGroupId(String groupId)
	{
		//TODO: groups will have to be constructed on the fly by a join
		return null;	
	}
	/* 
	*/
	protected Collection<DB_Host> ObjectsFromRS(final ResultSet rs)throws java.sql.SQLException			
	{
		Collection<DB_Host> result = new java.util.ArrayList<DB_Host>();
	
		while (rs.next())
		{
			String id 		= rs.getString("id"); 	
			String address	= rs.getString("address"); 	
			String permId 	= rs.getString("permissions_id"); 
			String username = rs.getString("username");
			String passwd 	= rs.getString("password");
			String sshKey	= rs.getString("ssh_key");
					
			DB_Host cur = new DB_Host(id, address,permId,username,passwd,sshKey);
			result.add(cur); 	
		}
		
		return result;
	}

}
