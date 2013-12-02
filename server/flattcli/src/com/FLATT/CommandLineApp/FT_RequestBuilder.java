/*******************************************************************************
 * FT_RequestBuilder.java
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
package com.FLATT.CommandLineApp;
import java.io.File;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

import com.FLATT.Utils.*;
import com.FT_JSSH.*;

public class FT_RequestBuilder 
{
	
	private final String STR_DEF_TASK_NAME = "_auto_task_";
	private final String STR_DEF_GRP_NAME="_auto_grp_";
	private final String  STR_DEF_EXEC_FILENAME = "automation-";
	
	private String _ret = "";
	
	
	// this causes the script to send the execution request to a remote proxy
	private String _proxyAddr="";
	private int    _proxyPort;
	
	// username and password and ssh key file. Used as a master for all hosts that don't have one
	private String _username="";
	private String _password ="";
	private String _sshKeyPath = ""; 
	private String _configParamsPath="";
	private boolean _simulationMode;
	/*master user name and password - used if host does not have one */
	
	private ArrayList<FT_Action>_actions = new ArrayList<FT_Action>();
	private ArrayList<FT_Host> _hosts = new ArrayList<FT_Host>();
 
	
	private FT_Action _standaloneAction;

	private String _execReqName = "";
	private boolean _dryRun;
	private FT_DbCreds _dbCreds = new FT_DbCreds();
	
	private String _execFilePath="";
	// multiple actions become a task
	
	
	
	
	
	/*
	 * <SSHRequest version="2" id="1376438067503">  
	 * <realtime>true</realtime>  
	 * <reqtype>0</reqtype>  
	 * <hosts username="celtester" password="testme" sshkey="" name="Celtest hosts">   
	 *  <Host>      
	 *  <username>celtester</username>     
	 *   <password>testme</password>      
	 *   <address>172.16.4.154</address>    
	 *   </Host>    
	 *   <Host>      
	 *   <address>172.16.2.16</address>    
	 *   </Host>  
	 *   </hosts>  
	 *   <actions>    
	 *   <action seqnum="0" name="Test server config" guid="17cea36a6eead500815484b9abe14de56b3afd77" version="1.0">
	 *   ZWNobyAnIGFycCBpcyBhdCAkQVJQJwplY2hvICd0b3AgaXMgYXQgJFRPUCAnCmVjaG8gJ3N1ZG8gaXMgYXQgJFNVRE8nCiRORVRTVEFUIC1h
	 *   </action>  
	 *   </actions>
	 *   </SSHRequest>
	 */
	
	public FT_RequestBuilder() 
	{
		
	}
	//-----------------------------
	public void BuildRequest(String[] args)
	{
		
		ParseArgs(args);
		/* If the pre-made request was passed in - use it, otherwise build from what was provided */
		if(StringUtils.IsValidString(_execFilePath))
		{
			System.out.println("Reading execution request...");
			ReadExecRequest();
		}
		else
		{
			System.out.println("Building execution request...");
			BuildPreamble();
			BuildHostsBlock();
			BuildActionsBlock();			
			BuildDatabaseCreds();
			BuildEndTag();
			SaveRequest();
		}
		
	}
	//--------------------------------
	private void BuildActionsBlock()
	{
		String actionsBlock = "<actions";
		/* If there are action objetcs - create actions block from them, otherwise create action block
		 * from one standalone action
		 */
		if( _actions.size() > 0 )
		{
			// if there is more than 1 action in the list - this is a  task
			// Make sure the task name is set otherwise the server will not recognize this as a task
			
			if(_actions.size() > 1)
			{				
				actionsBlock+=" name="+ StringUtils.QuoteString(STR_DEF_TASK_NAME) +
							   " guid="+ StringUtils.QuoteString(UUID.randomUUID().toString()) + ">";
			}
			else
			{
				actionsBlock += ">";
			}
			for(int i = 0; i < _actions.size();++i)
			{			
				actionsBlock += _actions.get(i).ToXml();
			}
		}
		else
		{
			actionsBlock += ">";
			if(_standaloneAction!=null)
			{				
				actionsBlock += _standaloneAction.ToXml();
			}
			else
			{
				// no scripts were given and no exec file to run - warn user that 
				// exectution will fail
				if(_execFilePath.isEmpty() && !_dryRun)
				{
					AppLog.LogIt("No scripts to execute!", AppLog.LOG_LEVEL_ERROR, AppLog.LOGFLAGS_ALL);
				}
			}
		}
		actionsBlock+="</actions>";
		_ret += actionsBlock;		
	}
	
	
	//-------------------------------
	private void BuildHostsBlock()
	{
		
		/*<hosts username="celtester" password="testme" sshkey="" name="Celtest hosts">   
		 *  <Host>      
		 *  <username>celtester</username>     
		 *   <password>testme</password>      
		 *   <address>172.16.4.154</address>    
		 *   </Host>    
		 *   <Host>      
		 *   <address>172.16.2.16</address>    
		 *   </Host>  
		 *   </hosts> */ 
		
		String hostsBlock="<hosts";
		hostsBlock += " name=" + StringUtils.QuoteString(this.STR_DEF_GRP_NAME) +
					  " sshkey=" + StringUtils.QuoteString(StringUtils.Base64Encode(ReadFile(_sshKeyPath))) +
					  " password=" + StringUtils.QuoteString(_password) +
				      " username=" + StringUtils.QuoteString(_username) +					  
					  ">";
		// read host config params
		if(!_configParamsPath.isEmpty())
		{
			// add global config params 
			hostsBlock +="<configParams>"+ StringUtils.Base64Encode(ReadFile(_configParamsPath)) + "</configParams>";
		}
		if(_hosts!=null)
		{
			for(int i = 0; i < _hosts.size(); ++ i)
			{
				FT_Host cur = _hosts.get(i);
				hostsBlock+= cur.ToXml();
			}
		}
		_ret+= hostsBlock +="</hosts>";		
	}
	
	//--------------------------------------
	private void BuildDatabaseCreds()
	{
		_ret += _dbCreds.ToXml();
	}
	
	//---------------------------------
	private void BuildPreamble()
	{
		_ret = "<SSHRequest version=" + StringUtils.QuoteString("2") +
				" id=" +  StringUtils.QuoteString( Long.toString(new Date().getTime())) + ">" + 
				"<realtime>true</realtime> <reqtype>0</reqtype>";	
	}
	//---------------------------------
	private void BuildEndTag()
	{
		_ret += "</SSHRequest>";
	}
	//------------------------------------------
	
	/*
	 * Command line arguments
	 * 
	 * server address and port. When provided the app will send it execution requests
	  --proxyaddr localhost
	  --proxyport 1111
	 
	 * space separated list of hosts
	  --hosts 172.16.25.25 192.168.1.1   
	 * username, password and ssh key path. used as master, for hosts that dont provide one
	  --username andy
	  --password foo 
	  --sskkey ./sshkey.pem
	  
	 * single command to execute
	  --command "ls-al" 
	 * hosts file - contans a space separated list of host, username, password, ssh key file path
	  --hosts-file ./hostsfile 
	  
	 * a list of script file paths
	  --scripts ./script1.sh ./script2.sh
	 * a file that contains a list of script file paths	 
	  --scripts-file ./scripts-list.txt
	* filename of execution request that is saved. If none provided a random name is assigned
	  --exec-name foo-bar 
	 * just creates a request but does not execute it.
	  --dry-run
	 * debug level 
	 -- debug level 1
	 *database support
	  --dbuser
	  --dbpass
	  --dbaddr
	--proxyaddr localhost --proxyport 1111 --hosts 172.16.25.25 192.168.1.1 --username andy --password foo --sshkey ./sshkey.pem --command "ls-al" --hosts-file ./hostsfile.txt --scripts ./script1.txt ./script2.txt --scripts-file ./scripts-list.txt --exec-name generated-exec.xml --dry-run --loglevel 3 --dbuser _dbuser_ --dbpass _dbpass_ --dbaddr _dbaddr_  
	 */
	private void ParseArgs(String[] args)
	{
		String arg = "";
		int logLevel = AppLog.LOG_LEVEL_ERROR;
		
		//if log level is not specified on command line, only log errors
		if(args.length <=0)
		{
			PrintHelpAndExit();
		}
		
		for(int i = 0;i < args.length;++i )
		{
	        arg = args[i];
	        if(arg.equalsIgnoreCase("-?")|| arg.equalsIgnoreCase("--help"))
	        {
	        	PrintHelpAndExit();
	        }
	        else if(arg.equalsIgnoreCase("--hosts"))
	        {
	        	++i;
	        	i = HostsFromArgs(args,i);
	        }
	        else if(arg.equalsIgnoreCase("--username"))
	        {
	        	++i;
	        	_username = args[i];
	        }
	        else if(arg.equalsIgnoreCase("--password"))
	        {
	        	++i;
	        	_password = args[i];
	        }
	        
	        else if(arg.equalsIgnoreCase("--hosts-file"))
	        {
	        	++i;
	        	HostsFromFile(args[i]);
	        }
	        else if(arg.equalsIgnoreCase("--scripts"))
	        {
	        	++i;
	        	i = ActionsFromArgs(args,i);	        	
	        }
	        else if(arg.equalsIgnoreCase("--command"))
	        {
	        	++i;
	        	AddSingleAction(args[i]) ;    	
	        }
	        else if(arg.equalsIgnoreCase("--proxyaddr"))
	        {
	        	++i;
	        	_proxyAddr = args[i];
	        }
	        else if(arg.equalsIgnoreCase("--proxyport"))
	        {
	        	++i;
	        	_proxyPort = Integer.parseInt(args[i]);
	        }
	        else if(arg.equalsIgnoreCase("--scripts-file"))
	        {
	        	++i;
	        	ScriptsFromFile(args[i]);        
	        }
	        else if(arg.equalsIgnoreCase("--exec-name"))
	        {
	        	++i;
	        	_execReqName = args[i];
	        }
	        else if(arg.equalsIgnoreCase("--dry-run"))
	        {	        	
	        	// there is no value so don't increment the index
	        	_dryRun = true;
	        } 
	        else if(arg.equalsIgnoreCase("--loglevel"))
	        {
	        	++i;
	        	logLevel = Integer.parseInt(args[i]);	        	
	        } 
	        else if(arg.equalsIgnoreCase("--sshkey"))
	        {
	        	++i;
	        	_sshKeyPath = args[i];
	        } 
	        else if(arg.equalsIgnoreCase("--hostconfig"))
	        {
	        	++i;
	        	_configParamsPath = args[i];
	        } 
	        else if(arg.equalsIgnoreCase("--dbuser"))
	        {
	        	++i;
	        	_dbCreds.setUsername(args[i]);
	        } 
	        else if(arg.equalsIgnoreCase("--dbpass"))
	        {
	        	++i;
	        	_dbCreds.setPassword(args[i]);
	        } 
	        else if(arg.equalsIgnoreCase("--dbaddr"))
	        {
	        	++i;
	        	_dbCreds.setUrl(args[i]);
	        } 
	        else if(arg.equalsIgnoreCase("--exec-file"))
	        {
	        	++i;
	        	_execFilePath = args[i];
	        } 
	        else if(arg.equalsIgnoreCase("--simulation"))
	        {
	        	// dont increment index when there is no value!!
	        	_simulationMode = true;
	        }	                
		}
		 // if none provided -set to error only
        AppLog.SetLogLevel(logLevel);
		
	}
	//----------------------------------
	/* Assumes that every line of the file contains a file path to a script*/
	protected void ScriptsFromFile(String filePath)
	{
		try
		{
			String data = StringUtils.Dos2Unix((FT_FileUtils.ReadFile(new File(filePath))));
			String arr[] = data.split("\n");
			if(arr!=null && arr.length > 0 )
			{
				for(int i = 0; i < arr.length; ++i )
				ActionObjFromFile(arr[i]);
			}			
		}
		catch(Exception e)
		{
			AppLog.LogIt("Failed to read scripts list", AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
		}				
	}
	//--------------------------
	protected void AddSingleAction(String actionCommand)
	{
		AddActionObject("auto_generated","1",actionCommand,"1");
	}
	//-----------------------------------------
	protected int ActionsFromArgs (String[] args, int i)
	{
		int ret = i;				
		String arg = "";
		// add  space separated paths
		for(; ret < args.length; ++ret)
		{
			arg = args[ret];
			if(arg.contains("--"))
			{
				// let the main arg loop find this 
				ret--;
				break;
			}
			else
			{
				ActionObjFromFile(arg);
			}
		}
		return ret;		
	}
	//-----------------------------------------
	private void ActionObjFromFile(String path)
	{
		// read the script and create action object
		try
		{
			File f = new File(path);
			if(f !=null && f.exists())
			{
				String data = FT_FileUtils.ReadFile(new File(path));
				if(StringUtils.IsValidString(data))
				{
					//file name becomes action name  
					AddActionObject(f.getName(),UUID.randomUUID().toString(),StringUtils.Dos2Unix(data),"1");
				}
			}
			else
			{
				AppLog.LogIt("Script file not found" +  path, AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
			}
		}
		catch(Exception e)
		{
			AppLog.LogIt("Failed to add script file " +  path + " to actions list", AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
		}
		
	}
	//------------------------------------------
	private void PrintHelpAndExit()
	{
		
		System.out.println(AppLog.STR_APP_NAME + " v " + AppLog.STR_APP_VERSION + "\n**************************");
		System.out.println(FT_CliHelp.GetHelpString());
		System.exit(0);
	}
	//-------------------------------------------
	public int getProxyPort()
	{
		return _proxyPort;
	}
	
	public String getProxyAddr()
	{
		return _proxyAddr;
	}
	//-------------------------------
	public boolean getConnectToProxy()
	{
		return (_proxyPort > 0 && _proxyAddr.length() > 0);
	}
	//---------------------------------
	public String getRequest()
	{
		return _ret;
	}
	//---------------------------------
	private void AddActionObject(String actName,String actGuid,String actCommand,String vers)
	{			
		int seqNum=_actions.size();
		_actions.add(new FT_Action(actCommand,seqNum,actName,actGuid,vers));
	}
	//--------------------------------
	private int HostsFromArgs(String[] args,int i)
	{
		int ret = i;				
		String arg = "";
		
		// add  space separated paths
		for(; ret < args.length; ++ret)
		{
			arg = args[ret];
			if(arg.contains("--"))
			{
				// let the main arg loop find this 
				ret--;
				break;
			}
			else
			{
				FT_Host host = new FT_Host();
				host.setHostAddr(arg);
				_hosts.add(host);
				
			}
		}
		return ret;	
	}
	//---------------------------------
	private void HostsFromFile(String filePath)
	{
		//read the hosts file and create hosts objects
		try
		{
			File f = new File(filePath);
			if(f !=null && f.exists())
			{
				ArrayList<FT_Host> parsedHosts =  FT_Host.ParseHostsFile(f);
				if(parsedHosts.size() > 0)
				{
					_hosts.addAll(parsedHosts);
				}
			}
			else
			{
				AppLog.LogIt("Host file " + filePath + " not found",  AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
			}
		}
		catch(Exception e)
		{
			AppLog.LogIt("Exception adding " +  filePath + " to actions list", AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
		}
	}
	//-------------------------------
	private String ReadFile(String path)
	{
		String ret="";
		if(!path.isEmpty())
		{
			try
			{
				ret = FT_FileUtils.ReadFile(new File(path));
			}
			catch (Exception e)
			{
				AppLog.LogIt("Failed to read " + path ,  AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
			}
		}
		return ret;
	}
	//--------------------------------
	private void ReadExecRequest()
	{
		try
		{
			_ret = FT_FileUtils.ReadFile(new File(_execFilePath));
			
		}
		catch(Exception e)
		{
			AppLog.LogIt("Failed to read execution request:  " + e.getMessage(),  AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
		}
	}
	//***************************************/
	private void SaveRequest()
	{
		
		// only save the automation file when the file name is provided 
		// If dry run was requested and no name provided - auto generate name and tell user		
		if(!StringUtils.IsValidString(_execReqName))
		{
			if(_dryRun)
			{
				/* dry run was requested but no exec file name was provided */
				AppLog.LogIt("Dry run was requested but no automation file name was provided. Saving automation with auto generated name ",  AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL);
				DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH-mm-ss");	
				// save in the same directory as the app
				_execReqName =  STR_DEF_EXEC_FILENAME + df.format(new Date())+".xml";
			}			
		}		
		if(StringUtils.IsValidString(_execReqName))
		{
			try
			{
				 FT_FileUtils.SaveFile(_execReqName, _ret, false);				
			}
			catch(Exception e)
			{
				AppLog.LogIt("Failed to save execution file: " + e.getMessage(),  AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
			}
		}
		
	}
	//---------------------------------
	
	public boolean isDryRun() 
	{
		return _dryRun;
	}
	//-------------------------
	public boolean isSimulationMode()
	{
		return _simulationMode;
	}
	
	//===============================
	
}// class
