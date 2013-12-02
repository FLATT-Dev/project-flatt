/*******************************************************************************
 * FT_HostGroup.java
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
package com.FT_JSSH;

import java.io.*;

import com.FLATT.DataObjects.*;
import com.FLATT.Utils.*;

public class FT_HostGroup extends DB_HostGrp 
{
	private File _sshKeyFile;
	private String _configParams;
	
	
	public FT_HostGroup()
	{
		super();
	}
	public FT_HostGroup( String name, 
						 String username,
						 String password, 
						 String sshKeyData,
						 String guid
						 ) 
	{	
		/* no id, permission id or host ids */
		super("", name, username, password, sshKeyData, "", guid);
		
		if(StringUtils.IsValidString(sshKeyData))
		{
			_sshKeyFile = FT_FileUtils.SaveTempFile(StringUtils.Base64Decode(sshKeyData));
		}
	}
	//--------------------------------------
	public File getSshKeyFile()
	{
		return _sshKeyFile;
	}
	//
	public String getConfigParams() 
	{
		return _configParams;
	}
	//--------------------------------------
	public void setConfigParams(String val)
	{
		_configParams = val;
	}
	//-----------------------------------
	public void Cleanup()
	{
		if(_sshKeyFile!=null)
		{
			_sshKeyFile.delete();
		}
	}
	//------------------------------
	@Override
	public boolean IsValid()
	{
		return (StringUtils.IsValidString(_name));
	}
	//------------------------------
}
