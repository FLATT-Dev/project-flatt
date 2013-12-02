/*******************************************************************************
 * DB_ObjectsMgr.java
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
package com.FLATT.Database;

import java.sql.Timestamp;
import java.util.Collection;

import com.FLATT.DAO.*;
import com.FLATT.DataObjects.*;
import com.FLATT.Utils.StringUtils;

public class DB_ObjectsMgr 
{
	//This class encapsulates creation  and deletion of various objects, so other code does not haveto 
	// use DAOs directly.
	//Is called from external code that may need a given
	// row created
	private FT_ActionDAO _actionDao;
	private FT_HistoryDAO _historyDao;
	private FT_HostDAO 	  _hostDao;
	private FT_HostGrpDAO _hostGrpDao;
	private FT_TaskDAO	  _taskDao;
	private FT_UsersDAO	  _usersDao;
	
	
	private static DB_ObjectsMgr _instance;
	
	public DB_ObjectsMgr() 
	{
		InitDaos();
	}
	//-------------------------------
	public static DB_ObjectsMgr GetInstance()
	{
		if( _instance == null )
		{
			_instance = new DB_ObjectsMgr();
		}
		return _instance;
	}	
	//--------------------------------
	protected void InitDaos()
	{
		_actionDao  = (FT_ActionDAO) FT_DAOFactory.GetDAOForClass(FT_ActionDAO.class);
		_historyDao = (FT_HistoryDAO) FT_DAOFactory.GetDAOForClass(FT_HistoryDAO.class);
		_hostDao = (FT_HostDAO) FT_DAOFactory.GetDAOForClass(FT_HostDAO.class);
		_hostGrpDao = (FT_HostGrpDAO) FT_DAOFactory.GetDAOForClass(FT_HostGrpDAO.class);
		_taskDao = (FT_TaskDAO) FT_DAOFactory.GetDAOForClass(FT_TaskDAO.class);
		_usersDao = (FT_UsersDAO) FT_DAOFactory.GetDAOForClass(FT_UsersDAO.class);
		
		
	}
	//======================DB_Action==========================\\
	// return the object from db - if needed insert
	// Returns true if the object exists in the database
	public  boolean Act_Ensure (DB_Action act)
	{
		DB_Action ret = null;
		// Make sure that the row with given parameters exists - if not create it and return the object, otherwise read from  database
		String sql = "guid="+
					  DB_Constants.STR_QUOTE + 
					  act.getGuid() +
					  DB_Constants.STR_QUOTE +
					  " and version="+ 
					  DB_Constants.STR_QUOTE +
					  act.getVersion() +
					  DB_Constants.STR_QUOTE;
		
		// there can be only one item in the collection 
		Collection<DB_Action> coll = _actionDao.FindBy(sql);
		
		if(coll != null && coll.iterator().hasNext())
		{
			ret = coll.iterator().next();
		}
		else
		{
			ret = _actionDao.CreateAction(act.getGuid(),act.getName(),act.getVersion());
		}
		
		if(ret!=null)
		{
			act.Copy(ret);
		}
		return (ret!=null && StringUtils.IsValidString(act.getId()));
	}
	//-----------------------------------------------------	
	// return the object from db - if needed insert
	//----------------------------------------
	public DB_Action Act_FindById(String id)
	{
		return _actionDao.FindById(id);
	}
	//----------------------------------------
	public Collection<DB_Action> Act_FindByGuid(String guid)
	{
		return _actionDao.FindByGuid(guid);
	}
	//----------------------------------------
	public  DB_Action Act_Create(String guid, String name, String version)
	{
		return _actionDao.CreateAction(guid, name, version);
	}
	//----------------------------------------
	public  boolean Act_Update(DB_Action DB_Action)
	{
		return _actionDao.UpdateAction(DB_Action);
	}
	//-----------------------------------------
	public boolean Act_Delete (String id)
	{
		return _actionDao.DeleteAction(id);
	}
	//======================DB_Host==========================\\	
	/*
	 */
	public boolean Host_Ensure(DB_Host host)
	{
		// Make sure that the row with given parameters exists - if not create it and return the object, otherwise read from  database
		DB_Host ret = null;
		
		// Make sure that the row with given parameters exists - if not create it and return the object, otherwise read from  database
		String sql = "address="+
					DB_Constants.STR_QUOTE + 
					host.getAddress()+
					DB_Constants.STR_QUOTE; 		
					
		
		// there can be only one item in the collection 
		Collection<DB_Host> coll = _hostDao.FindBy(sql);
		
		if(coll != null && coll.iterator().hasNext())
		{
			ret = coll.iterator().next();
		}
		else
		{
			ret = _hostDao.CreateHost(host.getAddress(),
									  host.getUsername(),
									  host.getPassword(),
									  host.getSshKeyData(),
									  host.getPermId());
									  
		}
		if(ret!=null)
		{
			host.Copy(ret);
		}
		return (ret !=null && StringUtils.IsValidString(host.getId()));
	}
	//-----------------------------------------
	public DB_Host Host_FindById(String id)
	{
		return _hostDao.FindById(id);
	}
	//-----------------------------------------
	public DB_Host Host_FindByAddress(String addr)
	{
		return _hostDao.FindByAddress(addr);
	}
	//-----------------------------------------
	public Collection<DB_Host> Host_FindByPermId(String permId)
	{
		return _hostDao.FindByPermId(permId);
	}
	//----------------------------------------
	public DB_Host  Host_Create( String address, String permId,String username, String passwd, String sshKey)
	{
		return _hostDao.CreateHost(address,  username,  passwd,  sshKey, permId);
	}
	//----------------------------------------
	public  boolean  Host_Update(DB_Host DB_Host)
	{
		return _hostDao.UpdateHost(DB_Host);
	}
	//----------------------------------------
	public boolean  Host_Delete (String id)
	{
		return _hostDao.DeleteHost(id);
	}
	//======================DB_Host Group==========================\\	
	public boolean HostGrp_Ensure(DB_HostGrp hostGroup)
	{
		DB_HostGrp ret = null;
		// Make sure that the row with given parameters exists - 
		//if not create it and return the object, otherwise read from  database
		String guidClause = hostGroup.getGuid().isEmpty() ? "": ( "guid="+"'"+ hostGroup.getGuid() +"' and ");
		String sql = guidClause + "name='" + hostGroup.getName() +"'";		
		// there can be only one item in the collection 		
		Collection<DB_HostGrp> coll = _hostGrpDao.FindBy(sql);
		
		if(coll != null && coll.iterator().hasNext())
		{
			ret = coll.iterator().next();
		}
		else
		{
			ret = _hostGrpDao.CreateGroup(hostGroup.getName(), 
										  hostGroup.getUsername(), 
										  hostGroup.getPassword(),
										  hostGroup.getSshKeyData(),
										  hostGroup.getPermId(),
										  hostGroup.getGuid());										 
		}
		if(ret!=null)
		{
			// update the id of the group object passed in
			hostGroup.Copy((DB_BaseObject)ret);
		}
		return (ret!=null && StringUtils.IsValidString(hostGroup.getId()));
	}
	public Collection<DB_HostGrp>HostGrp_FindBy(String searchString)
	{
		return _hostGrpDao.FindBy(searchString);
	}
	//----------------------------------------------
	public DB_HostGrp HostGrp_FindById(String id)
	{
		return _hostGrpDao.FindById(id);
	}
	//-------------------------------------------------
	public DB_HostGrp HostGrp_FinFindByGuid(String guid)
	{
		return _hostGrpDao.FindByGuid(guid);
	}
	//-------------------------------------------------
	public DB_HostGrp HostGrp_Create(String name, 
								   String username, 
								   String password,
								   String sshKey,
								   String permId,
								   String hostIds)
	{
		return _hostGrpDao.CreateGroup(name, username, password, sshKey, permId, hostIds);
	}						
	//-------------------------------------------------	
	public  boolean HostGrp_Update(DB_HostGrp grp)
	{
		return _hostGrpDao.UpdateGroup(grp);
	}
	//----------------------------------------------------
	public boolean HostGrp_Delete (String id)
	{
		return _hostGrpDao.DeleteGroup(id);
	}
	//======================DB_History==========================\\	
	public DB_History Hist_Create(DB_Action action, DB_Host host,String desc,String hostGrpId, String taskId,String userId )
	{
		return _historyDao.CreateHistory(action, host,desc,hostGrpId,taskId,userId);
	}
	//--------------------------------------------------
	public DB_History Hist_FindById(String id) 
	{
		return _historyDao.FindById(id);
	}
	public Collection<DB_History> Hist_Load(Timestamp start, int limit) 
	{
		// TODO Auto-generated method stub
		return _historyDao.LoadHistory(start, limit);
	}
	//-----------------------------------------------
	public boolean Hist_Update(Collection<DB_History> historyList) 
	{
		// TODO Auto-generated method stub
		return _historyDao.UpdateHistoryItems(historyList);
	}

	//---------------------------------
	public boolean Hist_Delete(String id) 
	{
		// TODO Auto-generated method stub
		return _historyDao.DeleteHistory(id);
	}
	
	//======================DB_Task==========================\\	
	public  boolean Task_Ensure (DB_Task task)
	{
		DB_Task ret = null;
		// Make sure that the row with given parameters exists - 
		//if not create it and return the object, otherwise read from  database
		String sql = "guid="+"'"+ task.getGuid() +"' and version='"+ task.getVersion() +"'";		
		// there can be only one item in the collection 		
		Collection<DB_Task> coll = _taskDao.FindBy(sql);
		
		if(coll != null && coll.iterator().hasNext())
		{
			ret = coll.iterator().next();
		}
		else
		{
			ret = _taskDao.CreateTask(task.getGuid(),task.getName(),task.getVersion());
		}
		if(ret!=null)
		{
			task.Copy(ret);
		}
		return (ret!=null);
	}
	//-----------------------------------------------------	
	// return the object from db - if needed insert
	//----------------------------------------
	public DB_Task Task_FindById(String id)
	{
		return _taskDao.FindById(id);
	}
	//----------------------------------------
	public Collection<DB_Task> Task_FindByGuid(String guid)
	{
		return _taskDao.FindByGuid(guid);
	}
	//----------------------------------------
	public  DB_Task Task_Create(String guid, String name, String version)
	{
		return _taskDao.CreateTask(guid, name, version);
	}
	//----------------------------------------
	public  boolean Task_Update(DB_Task task)
	{
		return _taskDao.UpdateTask(task);
	}
	//-----------------------------------------
	public boolean Task_Delete (String id)
	{
		return _taskDao.DeleteTask(id);
	}	
	//======================User==========================\\	
	public DB_User User_FindByName(String name)
	{
		return _usersDao.FindByName(name);
	}
	//--------------------------------
	public DB_User User_FindById(String id)
	{
		return _usersDao.FindById(id);
	}
	//--------------------------------
	public Collection<DB_User> User_FindByPermId(String permId)
	{
		return _usersDao.FindByPermId(permId);
	}
	
	

}
