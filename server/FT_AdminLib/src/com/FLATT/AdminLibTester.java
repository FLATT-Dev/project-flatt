/*******************************************************************************
 * AdminLibTester.java
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
package com.FLATT;

import com.FLATT.Utils.*;

import com.FLATT.DataObjects.*; 
import com.FLATT.Database.*;

public class AdminLibTester
{

	/**
	 * @param args
	 */
	public static void main(String[] args)
	{
		// TODO Auto-generated method stub
		AppLog.STR_APP_NAME = "AdminLibTester";
		AppLog.STR_APP_VERSION = "1.0";
		try
		{
			DB_Manager.GetInstance().InitDatabase("localhost","root","r1galatvia");			
			Test();
			
			
		}
		catch(Exception e)
		{
			System.out.println(e.getMessage());
		}

	}
	
	private static void InsertHistoryItem()
	{
		/*DB_Action act = new DB_Action("", "Test DB_Action_OLD", "1234", "1","");
		DB_Host host = new DB_Host("", "11.22.33.44",DB_Constants.ID_PERM_LEVEL_0,"user","password","","");
		
		DB_History hist = DB_ObjectsMgr.GetInstance().Hist_Create(act, host, "Description");
		if(hist!=null)
		{
			hist.setStateId(DB_Constants.ID_STATE_COMPLETED);
			DB_ObjectsMgr.GetInstance().Hist_Update(hist);
		}*/
	
	}
	//------------------------------
	private static void Test()
	{
		try
		{
			DB_StaticObjectsMgr.GetInstance().Initialize();
			InsertHistoryItem();
			
			/*FT_ActionDAO theDao = (FT_ActionDAO) FT_DAOFactory.GetDAOForClass(FT_ActionDAO.class);
			DB_Action_OLD act = theDao.CreateAction("1234", "my action", "1.0", false);
			theDao.DeleteAction(act.getId());
			DB_Action_OLD act1 = theDao.FindById("3");
			DB_Action_OLD act2 = (DB_Action_OLD)theDao.FindByGuid("2222").toArray()[0];
			if(act1!=null && act2!=null)
			{
				System.out.println("Got objects guid= " + act1.getGuid() + " and " + act2.getGuid());
			}*/
			DB_Manager.GetInstance().getDbConnection().close();
			
		}
		catch(Exception err)
		{
			
		}
		
		//----------------------------
		
	}

}
