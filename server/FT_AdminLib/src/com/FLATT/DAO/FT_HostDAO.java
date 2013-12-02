/*******************************************************************************
 * FT_HostDAO.java
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

public interface FT_HostDAO
{	
	public Collection<DB_Host>FindBy(String searchString);
	public DB_Host FindById(String id);
	public DB_Host FindByAddress(String addr);
	public Collection<DB_Host>FindByPermId(String permId);
	public DB_Host CreateHost( String address,  
							   String username, 
							   String password, 
							   String sshKey,
							   String permId);
							  
	public  boolean UpdateHost(DB_Host DB_Host);// updates database with new values
	public boolean DeleteHost (String id);
	public  Collection<DB_Host> FindByGroupId(String groupId);
}
