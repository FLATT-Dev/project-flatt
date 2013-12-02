/*******************************************************************************
 * FT_HostGrpDAOImpl.java
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

public class FT_HostGrpDAOImpl implements FT_HostGrpDAO
{
	//-----------------------------------------
	@Override
	public DB_HostGrp FindById(String id)
	{
		DB_HostGrp res = null;
		ResultSet rs = null;
		try
		{
			Collection<DB_HostGrp>coll = FindBy("id=" + id);
			
			if(coll!=null)
			{
				res = (DB_HostGrp)coll.toArray()[0];
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
	//-----------------------------------------
	@Override
	public DB_HostGrp FindByGuid(String guid) 
	{
		
		DB_HostGrp res = null;
		ResultSet rs = null;
		try
		{
			Collection<DB_HostGrp>coll = FindBy("guid=" + guid);
			
			if(coll!=null)
			{
				res = (DB_HostGrp)coll.toArray()[0];
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

	//-----------------------------------------
	@Override
	public DB_HostGrp CreateGroup(String name, 
								  String username, 
								  String password, 
								  String sshKey, 
								  String permId, 
								  String guid)								 
	{
		DB_HostGrp result = null;

		try
		{
			String strSql = "INSERT INTO `ft_admin_db`.`hostgroup` (`name`,`username`, `password`, " +
							"`ssh_key`,`permissions_id`,`guid`) VALUES (";
							
			strSql +="'"+name+"',";
			strSql +="'"+username+"',";
			strSql +="'"+password+"',";
			strSql +="'"+sshKey+"',";
			strSql +="'"+permId+"',";			
			strSql +="'"+guid+"')";
			
			String id = DB_Utils.InsertRow(strSql, DB_Constants.DBT_HOSTGRP);
			result = new DB_HostGrp(id,
										name,  
										username,  
										password,
										sshKey,
										permId,
										guid);
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
	public boolean UpdateGroup(DB_HostGrp grp)
	{
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean DeleteGroup(String id)
	{
		return DB_Utils.DeleteRow(id, DB_Constants.DBT_HOSTGRP);
	}
	
	//-------------------------------------
	@Override
	public Collection<DB_HostGrp> FindBy(String searchStr)
	{
		Collection<DB_HostGrp>res = null;
		ResultSet rs = null;

		try
		{
			rs = DB_Utils.FindBy(DB_Constants.DBT_HOSTGRP, searchStr);
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
	//----------------------
	protected Collection<DB_HostGrp> ObjectsFromRS(final ResultSet rs)throws java.sql.SQLException			
	{
		Collection<DB_HostGrp> result = new java.util.ArrayList<DB_HostGrp>();

		while (rs.next())
		{
			String id 		= rs.getString("id"); 	
			String name		= rs.getString("name"); 	
			String username = rs.getString("username"); 
			String passwd 	= rs.getString("password");
			String sshKey	= rs.getString("ssh_key");
			String permId 	= rs.getString("permissions_id");
			String guid 	= rs.getString("guid");
			
			DB_HostGrp cur = new DB_HostGrp( id, name,username,passwd,sshKey,permId,guid);
			result.add(cur); 	
		}
		
		return result;
	}
	@Override
	public Collection<DB_HostGrp> FindByPermId(String permId)
	{		
		return FindBy("permissions_id="+permId);
	}	
	//-----------

}
