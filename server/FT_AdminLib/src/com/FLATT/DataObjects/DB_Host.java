/*******************************************************************************
 * DB_Host.java
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

import com.FLATT.Database.DB_Constants;
import com.FLATT.Utils.StringUtils;

public class DB_Host extends DB_BaseObject
{
	//---------------------------------
	protected String _address = "";
	protected String _permId = DB_Constants.ID_PERM_LEVEL_0;
	protected String _username = "";
	protected String _password = "";
	protected String _sshKeyData = "";
	//protected String _groupIds = "";

	public DB_Host()
	{
		super("","","");
	}
	//---------------------------------
	public DB_Host(String id, 
					   String address,
					   String permId,
					   String username, 
					   String password,
					   String sshKeyData)
					  
					   
	{
		 super(id,"","");
		_address = address;
		_permId = permId;
		_username = username;
		_password = password;
		_sshKeyData = sshKeyData;
		
	}
	public String getAddress()
	{
		// TODO Auto-generated method stub
		return _address;
	}

	public String getPermissions()
	{
		// TODO Auto-generated method stub
		return DB_StaticObjectsMgr.GetInstance().GetPermission(_permId);
	
	}
	//---------------------------------
	public String getPermId()
	{
		return (StringUtils.IsValidString(_permId) ? _permId : DB_Constants.ID_PERM_LEVEL_0);
	}
	//---------------------------------
	public String getUsername()
	{
		return _username;
	}
	//---------------------------------
	public String getPassword()
	{
		return _password;
	}
	//---------------------------------
	public String getSshKeyData()
	{
		return _sshKeyData;
	}	
	
	/*
	//---------------------------------
	public boolean BelongsToGroup(String groupId)
	{
		return StringUtils.FindToken(_groupIds,",",groupId);
	}
	//---------------------------------
	public String getGroupIds()
	{
		return _groupIds;
	}
	//---------------------Add group Id to the list of group Ids this object has
	public void AddGroupId(String groupId)
	{
		if(!_groupIds.contains(groupId+","))
		{
			_groupIds += groupId+",";
		}
	}*/
	//---------------------
	public void Copy(DB_BaseObject src)
	{
		super.Copy(src);
		_address = 		((DB_Host)src).getAddress();
		_username = 	((DB_Host)src).getUsername();
		_password = 	((DB_Host)src).getPassword();
		_sshKeyData = 	((DB_Host)src).getSshKeyData();
		_permId = 	 	((DB_Host)src).getPermId();	
		//_groupIds =	 	((DB_Host)src).getGroupIds();	 
	}

}
