/*******************************************************************************
 * FT_StaticObjDAOImpl.java
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
import com.FLATT.DataObjects.DB_StaticObject;
import com.FLATT.Database.DB_Utils;

public class FT_StaticObjDAOImpl implements FT_StaticObjDAO 
{

	// This DAO handles generic static tables that only contain id, name and description
	// i.e Result, Permissions anb State
	
	public FT_StaticObjDAOImpl() 
	{
		// TODO Auto-generated constructor stub
	}

	@Override
	public Collection<DB_StaticObject> Load(String tableName) 
	{
	
			Collection<DB_StaticObject>res = null;
			ResultSet rs = null;
	
			try
			{
				rs = DB_Utils.GenericQuery("Select * from " + tableName + " order by id");
				if(rs!=null)
				{
					res = StaticObjectsFromRS(rs);
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
//----
/* this is for a generic table with id, name and descrtiption fields
*/
protected Collection<DB_StaticObject> StaticObjectsFromRS(final ResultSet rs)throws java.sql.SQLException
	
{
	Collection<DB_StaticObject> result = new java.util.ArrayList<DB_StaticObject>();

	while (rs.next())
	{
		String id = Integer.toString(rs.getInt("id")); 	
		String name = rs.getString("name"); 	
		String desc = rs.getString("desc"); 	
		
		DB_StaticObject cur = new DB_StaticObject(id,name, desc);
		result.add(cur); 	
	}
	
	return result;
}

}
