/*******************************************************************************
 * DB_StaticObjectsMgr.java
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

import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.FLATT.DAO.FT_DAOFactory;
import com.FLATT.DAO.*;
import com.FLATT.Database.DB_Constants;
import com.FLATT.Utils.*;

public class DB_StaticObjectsMgr
{
	// This object manages all static tables that are loaded once and never modified
	ConcurrentHashMap<String,DB_StaticObject> _states;
	ConcurrentHashMap<String,DB_StaticObject> _results;
	ConcurrentHashMap<String,DB_StaticObject> _permissions;
	ConcurrentHashMap<String,DB_User> _users;
	
	private static DB_StaticObjectsMgr 		_instance;
	
	public DB_StaticObjectsMgr()
	{
		// TODO Auto-generated constructor stub
		_states = new ConcurrentHashMap<String,DB_StaticObject>();
		_results = new ConcurrentHashMap<String,DB_StaticObject>();
		_permissions = new ConcurrentHashMap<String,DB_StaticObject>();
		_users = new ConcurrentHashMap<String,DB_User>();
	}
	//-----------------------------------
	public static DB_StaticObjectsMgr GetInstance()
	{
		if(_instance == null )
		{
			_instance = new DB_StaticObjectsMgr();
		}
		return _instance;
	}
	//---------------------------------------
	public boolean Initialize()
	{
		boolean ret = true;
		try
		{
			FT_StaticObjDAO theDao = (FT_StaticObjDAO)FT_DAOFactory.GetDAOForClass(FT_StaticObjDAO.class);
			LoadObjects(theDao,DB_Constants.DBT_STATE,_states);
			LoadObjects(theDao,DB_Constants.DBT_RESULT,_results);
			LoadObjects(theDao,DB_Constants.DBT_PERMISSIONS,_results);			
			LoadUsers();
			
		}
		catch(Exception e)
		{
			ret = false;
			AppLog.LogIt("Exception caught loading static tables : "+ e.getMessage(),
							AppLog.LOG_LEVEL_ERROR,
							AppLog.LOGFLAGS_ALL);
		}
		return ret;
	}
	//-----------------------------------------
	private void LoadObjects(FT_StaticObjDAO theDao,String tblName,Map<String,DB_StaticObject> theMap) throws Exception
	{
		Collection<DB_StaticObject> coll = theDao.Load(tblName);
		Iterator<DB_StaticObject> iter = coll.iterator();
		while(iter.hasNext())
		{
			DB_StaticObject cur = iter.next();
			theMap.put(cur.getId(),cur);
		}
	}
	//-----------------------------------------
	private void LoadUsers() throws Exception
	{
		
		FT_UsersDAO theDao = (FT_UsersDAO)FT_DAOFactory.GetDAOForClass(FT_UsersDAO.class);
				 
		
		Collection<DB_User> coll = theDao.Load(DB_Constants.DBT_USERS);
		Iterator<DB_User> iter = coll.iterator();
		while(iter.hasNext())
		{
			DB_User cur = iter.next();
			_users.put(cur.getId(),cur);
		}
	}
	//----------------------------------------
	public String GetPermission(String id)
	{
		DB_StaticObject so = FindStaticObject(_permissions, id);
		if(so!=null)
		{
			return so.getName();
		}
		return "";
	}
	//----------------------------------------
	public String GetState(String id)
	{
		DB_StaticObject so = FindStaticObject(_states, id);
		if(so!=null)
		{
			return so.getName();
		}
		return "";
	}
	//----------------------------------------
	public String GetResult(String id)
	{
		DB_StaticObject so = FindStaticObject(_results, id);
		if(so!=null)
		{
			return so.getName();
		}
		return "";
	}
	//------------------------------
	public DB_User GetUserById(String id)
	{
		return _users.get(id);		
	}
	//------------------------------
	public DB_User GetUserByName(String name)
	{
		Collection<DB_User>userList = _users.values();
		Iterator<DB_User> iter = userList.iterator();
		
		while(iter.hasNext())
		{					
			DB_User cur = iter.next();
			
			if(cur.equals(name))
			{
				return cur;
			}			
		}
		return null;
	}
	//-----------------------------
	//Search the given map for an object with an id 
	private DB_StaticObject FindStaticObject(Map<String,DB_StaticObject> theMap,String id)
	{
		return theMap.get(id);
	}
}
