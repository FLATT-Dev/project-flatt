/*******************************************************************************
 * FT_ActionDAO.java
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

import com.FLATT.DataObjects.*;

import java.util.*;

public interface FT_ActionDAO
{
	public Collection<DB_Action> FindBy(String searchString) ;
	public DB_Action FindById(String id);
	public Collection<DB_Action> FindByGuid(String guid);
	public  DB_Action CreateAction(String guid, String name, String version);
	public  boolean UpdateAction(DB_Action DB_Action);// updates database 
	public boolean DeleteAction (String id);	
	public Collection<DB_Action> FindByTaskId(String taskId);
	
}
