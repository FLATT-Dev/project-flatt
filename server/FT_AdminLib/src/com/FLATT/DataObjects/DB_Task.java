/*******************************************************************************
 * DB_Task.java
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

public class DB_Task extends DB_BaseObject 
{

	protected String _guid = "";
	protected String _version = "";
	
	public DB_Task()
	{
		super();
		SetDefaults();
	}
	
	//---------------------------------------------
	public DB_Task(String id, String name, String version, String guid) 
	{
		super(id, name, "");		
		_version = version;
		_guid = guid;		
	}
	//-----------------------
	@Override
	protected void SetDefaults()
	{
		_id = DB_Constants.ID_NO_TASK;		
		_guid = DB_Constants.STR_DEF_GUID;
		_name = DB_Constants.STR_DEF_TASK_NAME;	
		_version = DB_Constants.STR_DEF_VERS;
	}
	
	public String getGuid() 
	{
		// TODO Auto-generated method stub
		return _guid;
	}

	public String getVersion() 
	{
		// TODO Auto-generated method stub
		return _version;
	}

}
