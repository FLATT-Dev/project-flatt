/*******************************************************************************
 * DB_Action.java
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

public class DB_Action extends DB_BaseObject
{
	private String _guid = "";
	private String _version = "";
	//private String _taskIds = "";
	
	
	public DB_Action(String id, 
					String name, 
				    String guid, 
				     String version)
						
	{
		// TODO Auto-generated constructor stub
		super(id,name,"");
		_guid 	= guid;
		_version = version;
		

	}
	/* Interface implemetation */
	//--------------------------
	public String getGuid()
	{
		// TODO Auto-generated method stub
		return _guid;
	}
	//--------------------------
	public String getVersion()
	{
		// TODO Auto-generated method stub
		return _version;
	}
	/*
	//--------------------------
	public boolean BelongsToTask(String taskId)
	{
		return StringUtils.FindToken(_taskIds,",",taskId);
	}
	//-----------------------------

	public String getTaskIds()
	{
		return _taskIds;
	}
	//--------------------------------
	public void AddTaskId(String id)
	{		
		if(!_taskIds.contains(id+","))
		{
			_taskIds += id+",";
		}
	}*/
	@Override
	public void Copy(DB_BaseObject src)
	{
		super.Copy(src);
		_guid 	= ((DB_Action)src).getGuid();
		_version = ((DB_Action)src).getVersion();
		//_taskIds = ((DB_Action)src).getTaskIds();
	}
		
}
