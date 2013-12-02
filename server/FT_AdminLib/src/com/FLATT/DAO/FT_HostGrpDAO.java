/*******************************************************************************
 * FT_HostGrpDAO.java
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

import java.util.Collection;
import com.FLATT.DataObjects.*;

public interface FT_HostGrpDAO
{

	public DB_HostGrp FindById(String id);
	public Collection<DB_HostGrp> FindBy(String searchStr);
	public DB_HostGrp FindByGuid(String guid) ;
	public  DB_HostGrp CreateGroup(String name, 
								   String username, 
								   String password,
								   String sshKey,
								   String permId,
								   String guid);
	public boolean UpdateGroup(DB_HostGrp grp);// updates database 
	public boolean DeleteGroup (String id);	
	public Collection<DB_HostGrp> FindByPermId(String permId);
	
}
