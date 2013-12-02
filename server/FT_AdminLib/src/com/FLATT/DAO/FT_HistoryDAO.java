/*******************************************************************************
 * FT_HistoryDAO.java
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

import java.sql.Timestamp;
import java.util.Collection;

import com.FLATT.DataObjects.*;

public interface FT_HistoryDAO 
{
	public Collection<DB_History>FindBy(String searchString);
	public DB_History FindById(String id);
	public Collection<DB_History> LoadHistory(Timestamp start,int limit);
	public  DB_History CreateHistory(DB_Action action, DB_Host host,String desc, String groupId, String taskId, String userId); 
	public  boolean UpdateHistoryItems(Collection<DB_History> historyList);// updates the database
	public boolean DeleteHistory (String id);
}
