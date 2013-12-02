/*******************************************************************************
 * FT_Host.java
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

import java.io.File;
import java.util.ArrayList;

import org.w3c.dom.*;

import com.FLATT.DataObjects.*;
import com.FLATT.Utils.*;

public class FT_Host extends DB_Host
{
	//private String m_HostAddr ="";
	//private String m_Username="";
	//private String m_Passwd="";
	private String _configParams = "";
	private File   _sshKeyFile;
	
	
	//===========================
	/*
	 * This object represents a host that is being administered.
	 */
	public FT_Host()
	{
		//super("","","","","","",""); // group ids are not known at this time
		super();
	}
	//------------------------------------
	public void Cleanup()
	{
		if(_sshKeyFile!=null)
		{
			_sshKeyFile.delete();
		}
	}
	//-------------------------------------
	public Boolean FromXML(Node hostNode)
	{
		_address = JSSHProxyParams.GetNodeAttribute(hostNode,"addr");
		
		NodeList children = hostNode.getChildNodes();
		
		 for( int i = 0; i < children.getLength(); ++ i)
		 {
			 Node curChild = children.item(i);
			 String nodeName = curChild.getNodeName();
			 
			 if(nodeName != null && curChild.getFirstChild()!=null )
			 {
				// range to scan for hosts
				 if (nodeName.equalsIgnoreCase("address"))
				 {
					 _address = curChild.getFirstChild().getNodeValue().trim();
				 }
				 else if (nodeName.equalsIgnoreCase("sshkey"))
				 {					
					 _sshKeyData = StringUtils.Base64Decode(curChild.getFirstChild().getNodeValue().trim());
					 _sshKeyFile = FT_FileUtils.SaveTempFile(_sshKeyData);
				 }
				 // the  timeout to use when scanning for hosts
				 else if (nodeName.equalsIgnoreCase("username"))
				 {
					 _username = curChild.getFirstChild().getNodeValue().trim();
				 } 
				 else if (nodeName.equalsIgnoreCase("password"))
				 {
					 _password = curChild.getFirstChild().getNodeValue().trim();
				 } 
				 else if (nodeName.equalsIgnoreCase("configParams"))
				 {
					 _configParams = curChild.getFirstChild().getNodeValue().trim();
				 } 
			 }
		 }		 
		// the only requirement for host is that its address is not empty
		return (!_address.isEmpty());
	}
	//------------------------------
	public String ToXml()
	{
		String ret = "<host><address>";
		
		ret+= _address + "</address>"; 
		if(StringUtils.IsValidString(_username))
		{
			ret+="<username>" + _username + "</username>";
		}
		if( StringUtils.IsValidString(_password))
		{
			ret+="<password>" + _password + "</password>";
		}
				
		String sshKeyData = GetSshKeyData();
		if(StringUtils.IsValidString(sshKeyData))
		{
			ret+="<sshkey>" +StringUtils.Base64Encode(sshKeyData) + "</sshkey>";
		}
		// see if there are host params
		if(!_configParams.isEmpty())
		{
			ret+="<configParams>" +StringUtils.Base64Encode(_configParams) + "</configParams>";
		}
		ret +="</host>";
		return ret;
	}
	//-------------------------------
	public String GetSshKeyData()
	{
		String ret = "";
		try
		{
			if (_sshKeyFile!=null)
			{
				ret = FT_FileUtils.ReadFile(_sshKeyFile);
			}
		}
		catch(Exception e)
		{
		}
		return ret;
	}
	//--------------------------------
	// Getters/setters
	/*public String getHostAddr() 
	{
		return getAddress();
	}*/
	//--------------------------------
	public void setHostAddr(String val) 
	{
		_address = val;
	}
	//--------------------------------
	// return a full path to ssh key file
	public File getSshKeyFile() 
	{
		return _sshKeyFile;
	}
	public void setSshKeyFile(String path)
	{
		if(!path.isEmpty())
		{
			try
			{
				_sshKeyFile = new File (StringUtils.StripQuotes(path));
				if(!_sshKeyFile.exists())
				{
					_sshKeyFile = null;
				}
			}
			catch(Exception e)
			{
				// something wrong with the path
				AppLog.LogIt("Exception creating ssh key file from " + path + "\n" + e.getMessage(), 
							AppLog.LOG_LEVEL_ERROR, 
							AppLog.LOGFLAGS_LOGFILE);
				_sshKeyFile = null;
			}
		}
	}
	//--------------------------------
	/*public String getUsername() 
	{
		return getUsername();
	}*/
	//--------------------------------
	public void set_Username(String val)
	{
		_username = val;
	}
	//--------------------------------
	/*public String getPasswd()
	{
		return getPassword();
	}*/
	//--------------------------------
	public void setPassword(String val)
	{
		_password = val;
	}
	//--------------------------------
	public String getConfigParams()
	{
		return _configParams;
	}
	//--------------------------------
	public void setConfigParams(String val)
	{
		_configParams = val;
	}
	//--------------------------------	
	public void ReadConfigParams(String path)
	{		
		if(!path.isEmpty())
		{
			try
			{
				setConfigParams(FT_FileUtils.ReadFile(new File(StringUtils.StripQuotes(path))));
			}
			catch(Exception e)
			{
			}
		}		
	}
	//--------------------------------
	public static ArrayList<FT_Host> ParseHostsFile(File inFile)
	{
		ArrayList<FT_Host> ret = new ArrayList<FT_Host>();
		try
		{
			String data = FT_FileUtils.ReadFile(inFile);
			if(StringUtils.IsValidString(data))
			{
				String[] arr =  StringUtils.Dos2Unix(data).split("\n");
				if( arr !=null )
				{
					for( int i = 0 ; i < arr.length;++i)
					{
						FT_Host newHost = ParseOneHost(arr[i].trim());
						if(newHost!=null)
						{
							ret.add(newHost);	
						}
					}
				}
			}			
		}
		catch(Exception e)
		{
			AppLog.LogIt("An error occurred while parsing hosts file: "+e.getMessage(),
						  AppLog.LOG_LEVEL_ERROR, 
						  AppLog.LOGFLAGS_ALL);
		}
		return ret;
	}
	
	//-------------------------------------------------
	private static FT_Host ParseOneHost(String src)
	{		
		FT_Host ret = new FT_Host();	
		int startPos=0;
		int endPos;
		int i;	
		String strTest = "";
		// the format has 5 entries separated by commas:
		// host,username,password,ssh key,config file\n
		// the order is important!
		// the last entry is config params file and it's not separated by the comma on the end
		// that's why there is one extra entry in the positions array
		int[] commaPositions = new int[]{-1,-1,-1,-1,-1};
		boolean[] setFields = new boolean[]{false,false,false,false,false};
		int k = 0;
		// first check if it's not a comment or an empty line
		// a comment is a # at the beginning of the line
		if(src.isEmpty() || src.indexOf("#") == 0 )
		{
			// at this point the string is trimmed so if the first char is a string this must be a comment
			return null;
		}
		
		while(startPos >=0)
		{
			startPos = src.indexOf(',', startPos);
			
			if(startPos>=0 )
			{				
				//rewind back one char to see if it' not an escaped comma
				strTest = src.substring(startPos-1, startPos).trim();				
				// skip escaped commas - they are part of the string,
				// and not field separators				
				if(!strTest.equals("\\"))
				{									
					// make sure not to overrun the commaPositions array 
					// we only handle 4 commas
					if(k >=commaPositions.length)
					{
						break;
					}											
					//increment pos so we can continue looking for the 
					//other commas in the string
				 	commaPositions[k++] = startPos++;
				}
				else
				{					
					// This is an escaped comma inside a string.
					// remove  escape char from and increment startPos
					// so we can proceed traversing the string
					String start = src.substring(0,startPos-1);
					String end = src.substring(startPos,src.length());
					src = start+end;
					startPos++;
				}			
			}		
		}
		// now that we know all comma positions, process the entries
		for( i =0 ; i < commaPositions.length; ++i)
		{
			// now that we have positions of all entries, process them.			
			// start position is either 0 ( for the first entry ) or the i index in the positions array
			startPos = (i==0?  0 : commaPositions[i-1]);
			// for the last entry use the length of the string
			endPos = (i+1 >= commaPositions.length? src.length() : commaPositions[i]);
			if(startPos >=0 && endPos>=0)
			{
				// mark this field as set
				setFields[i] = true;
				// startPos points to the field delimiter, so skip past it unless we;re processing the first entry
				if(i> 0)
				{
					startPos++;
				}
				SetHostField(ret,src.substring(startPos,endPos).trim(),i);				
			}
		}
		// now check how many fields were set.
		// We allow omitting field delimiters,
		// make sure that the last field before last comma is set and bail - there is nothing after that
		for( i=0; i < setFields.length;++i)
		{
			if(!setFields[i])
			{
				// if this field is not set - find the previous good position
				// and use it as a startPos and string length as end pos
				startPos = (i == 0 ? 0 : commaPositions[i-1]+1);
				endPos = src.length();
				SetHostField(ret,src.substring(startPos,endPos).trim(),i);
				break;
			}			
		}
		
		if(!ret.IsValid())
		{
			ret = null;
		}
		return ret;
			
	}
	//---------------------------------------
	private static void SetHostField(FT_Host host, String field, int fieldNum)
	{		
		switch( fieldNum)
		{
			case 0:
				// host name 
				host.setHostAddr(field);
				break;
			case 1:
				//username
				host.set_Username(field);
				break;
			case 2:
				// password:
				host.setPassword(field);
				break;
			case 3:
				// ssh key
				host.setSshKeyFile(field);
				break;
			case 4: 
				host.ReadConfigParams(field);
				break;
		}
	}
	//--------------------------------------
	@Override
	public boolean IsValid()
	{
		return StringUtils.IsValidString(_address);
	}
	
	
}
