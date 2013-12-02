/*******************************************************************************
 * DB_HostGrp.java
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

public class DB_HostGrp extends DB_BaseObject
{
	private String _username = "";
	private String _password = "";
	private String _sshKeyData = "";
	private String _permId = DB_Constants.ID_PERM_LEVEL_0;
	private String _guid = "";
	
	// default ctor
	public DB_HostGrp()
	{
		super();	
		SetDefaults();
	}
	//------------------------------------
	public DB_HostGrp(String id,
						  String name, 
						  String username, 
						  String password, 
						  String sshKeyData, 
						  String permId ,
						  String guid
						 )
	{
		super(id, name, "");		
		_username = username;
		_password = password;
		_sshKeyData  = sshKeyData;
		_permId = permId;
		_guid = guid;	
	}
	//------------------------------------
	@Override
	protected void SetDefaults()
	{
		_id = DB_Constants.ID_NO_GROUP;
		_guid = DB_Constants.STR_DEF_GUID;
		_name = DB_Constants.STR_DEF_GRP_NAME;
		
	}
	
	public String getUsername()
	{
		return _username;
	}


	public String getPassword()
	{
		
		return _password;
	}

	public String getSshKeyData()
	{
		return _sshKeyData;
	}
	
	public String getGuid()
	{
		// TODO Auto-generated method stub
		return _guid;
	}
	
	public String getPermId()
	{
		//Always return a valid perm ID even when one was not provided
		return (StringUtils.IsValidString(_permId) ? _permId : DB_Constants.ID_PERM_LEVEL_0);
	}

	public void Copy(DB_BaseObject src)
	{
		super.Copy(src);
		_username = ((DB_HostGrp)src).getUsername();
		_password = ((DB_HostGrp)src).getPassword();
		_sshKeyData  = ((DB_HostGrp)src).getSshKeyData();
		_permId = ((DB_HostGrp)src).getPermId();			 
	}
	//-------------------------
	
	

}
