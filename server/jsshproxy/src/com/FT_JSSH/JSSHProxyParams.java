/*******************************************************************************
 * JSSHProxyParams.java
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
import java.util.*;

import org.w3c.dom.*;

import com.FLATT.Utils.*;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;

public class JSSHProxyParams 
{
	
	
	// command line processor
	// valid tcp ports from which we can choose
	private String STR_HELP = "Usage: jsshproxy --port <port to listen on> " +
							"-- useSSL --logpath < where log is saved,default is .";
							

	public static final int FT_REQ_VERSION_1 = 1;
	public static final int FT_REQ_VERSION_2 = 2;
	
	//public static final int PORT_MIN = 49152;
	//public static final int PORT_MAX = 65535;
	public static final int DEF_SCAN_HOST_CONNECT_TO = 15; //15 seconds default host scan connect timeout
	//public static final int INVALID_PORT = -1;
	public static final int DEFAULT_PORT = 0; // let the OS give out the first unused port
	// Version 1 parameters
	private String m_HostAddr = "";
	private String m_UserName ="";
	private String m_Password = "";
	private String m_Cmd = "";
	
	// Common parameters
	private Boolean m_IsRealTime = false;
	// whether the command needs to be copied to a temp file on  remote server
	// and executed from that file. Needed for multiline commands
	private Boolean m_NeedsScp = false; // whether the command 
	 // whether to accept connections from remote clients
	// By default it is false.
	String _jarDirPath = "";
	private Boolean m_LocalOnly = true;
	private Integer m_Port = DEFAULT_PORT;
	private Boolean m_NoServer = false;// not starting server,just send whatever on the cmd line and quit
	private Boolean m_UseSSL = false; // use ssl server
	private String m_LogPath = null;
	private String m_StartIP = "";
	private String m_EndIP = "";// used if there is a request to scan the subnet for hosts
	private Integer m_ScanConnectTimeout = 15; // hard coded or use provided
	private Boolean m_SimulationMode = false; /* use simulation mode t simulate multple hosts reponses */
	private FT_SvnRequest m_SvnRequest = null; /* SVN request object */
	
	// version 2 parameters
	private int m_RequestVersion = FT_REQ_VERSION_1; // default to v 1 for req version for backwards compatibility
	private String m_RequestID = "";	// not clear if thsi is needed
	
	
	//private String m_TaskName = "";
	//private String m_TaskGuid = "";	
	private FT_Task 	m_Task;
	private FT_HostGroup m_HostGroup;
	private ArrayList<FT_Host> m_Hosts = new ArrayList<FT_Host>(); // list of hosts
	private ArrayList<FT_Action> m_Actions = new ArrayList<FT_Action>(); // list of commands
	private FT_DbCreds _dbCreds = new FT_DbCreds();
	
	
	// work commit
	/*private String s_NewXMLStr = 
			"<SSHRequest version=\"2\" id=\"1234\">  <host/>  <username/>  <password/>  <command/>  <realtime>false</realtime>" +
			"<SvnRequest type=\"6\">" +
			"<Message></Message>" +
			"<username>heelcurve5@gmail.com</username>"+
			"<password>Qc3zA3DB7WA7</password>"+		
			"<LocalPaths>"+
			"<Path name=\"C:\\Users\\andy.SYSTECH\\AppData\\Local\\Temp\\FLATT\\flatt-actions.googlecode.com\"/>"+	
			"</LocalPaths>" +
			"</SvnRequest>" + 
			"</SSHRequest>";*/
	
	
	//work checkout req
	/*private String s_NewXMLStr = 
			"<SSHRequest version=\"2\" id=\"1234\">  <host/>  <username/>  <password/>  <command/>  <realtime>false</realtime>" +
			"<SvnRequest type=\"1\">" +	
			"<URL>https://flatt-actions.googlecode.com/svn/</URL>"+
			"<LocalPaths>"+
			"<Path name=\"C:\\Users\\andy.SYSTECH\\AppData\\Local\\Temp\\FLATT\"  isroot=\"true\"/>"+
			"<Path name=\"C:\\Users\\andy.SYSTECH\\AppData\\Local\\Temp\\FLATT\\how-many-cpus.xml\"/>"+
			"<Path name=\"C:\\Users\\andy.SYSTECH\\AppData\\Local\\Temp\\FLATT\\net-access-validation.xml\"/>"+
			"</LocalPaths>" +
			"</SvnRequest>" + 
			"</SSHRequest>";
	// work update req
	private String s_NewXMLStr = 
			"<SSHRequest version=\"2\" id=\"1234\">  <host/>  <username/>  <password/>  <command/>  <realtime>false</realtime>" +
			"<SvnRequest type=\"2\">" +	
			"<LocalPaths>"+
			"<Path name=\"C:\\Users\\andy.SYSTECH\\AppData\\Local\\Temp\\FLATT\\flatt-actions.googlecode.com\\how-many-cpus.xml\"/>"+
			"<Path name=\"C:\\Users\\andy.SYSTECH\\AppData\\Local\\Temp\\FLATT\\flatt-actions.googlecode.com\\net-access-validation.xml\"/>"+
			"</LocalPaths>" +
			"</SvnRequest>" + 
			"</SSHRequest>";*/
			
	
	
	/*home checkout req
	private String s_NewXMLStr = 
	"<SSHRequest version=\"2\" id=\"1234\">  <host/>  <username/>  <password/>  <command/>  <realtime>false</realtime>" +
	"<SvnRequest type=\"1\">" +	
	"<URL>https://flatt-actions.googlecode.com/svn/</URL>"+
	"<LocalPaths>"+
	"<Path name=\"C:\\Users\\andy\\AppData\\Local\\Temp\\FLATT\"  isroot=\"true\"/>"+
	"<Path name=\"C:\\Users\\andy\\AppData\\Local\\Temp\\FLATT\\how-many-cpus.xml\"/>"+
	"<Path name=\"C:\\Users\\andy\\AppData\\Local\\Temp\\FLATT\\net-access-validation.xml\"/>"+
	"</LocalPaths>" +
	"</SvnRequest>" + 
	"</SSHRequest>";
	*/
	/* home commit
	private String s_NewXMLStr = 
			"<SSHRequest version=\"2\" id=\"1234\">  <host/>  <username/>  <password/>  <command/>  <realtime>false</realtime>" +
			"<SvnRequest type=\"6\">" +
			"<Message></Message>" +
			"<LocalPaths>"+
			"<Path name=\"C:\\Users\\andy\\AppData\\Local\\Temp\\FLATT\\flatt-actions.googlecode.com\\format-samples\\top-cpu-user.xml\"/>"+			
			"</LocalPaths>" +
			"</SvnRequest>" + 
			"</SSHRequest>";*/
			
	//"<Path name=\"C:\\Users\\andy\\AppData\\Local\\Temp\\FLATT\\flatt-actions.googlecode.com\\format-samples\\net-access-validation.xml\"/>"+
	//"<SSHRequest version=\"2\" id=\"1234\">  <host/>  <username/>  <password/>  <command/>  <realtime>false</realtime>  <HostScanParams>    <startIP>0.0.0.0</startIP>    <endIP>0.0.0.0</endIP>    <scanConnectTimeout>5</scanConnectTimeout>  </HostScanParams></SSHRequest>";
	// temp, TODO: delete
	/*private String s_NewXMLStr =
	"<SSHRequest version=\"2\" id=\"12345\">"+
	"<hosts username=\"hostlist-username\" password=\"hostlist-password\">"+
	"<sshkey>blablabla</sshkey>"+
	"<host addr=\"host1.amazon.com\">"+
	"<sshkey>sshkey1</sshkey>" +
	"</host> " +
	"<host addr=\"host2.amazon.com\">"+
	"<sshkey>sshkey2</sshkey>" +
	"</host> " +
	"<host addr=\"host3.amazon.com\">"+
	"<username>host3-username</username>"+  
	"<password>host3-password</password> " +
	"</host> "+
	"</hosts>"+
	"<commands>"+
	"<command>dW5hbWUgLWE=</command>"+
	"</commands>"+ 
	"<realtime>true</realtime>"+
	"<needsScp>yes</needsScp>"+
	"</SSHRequest>";*/
	
	// whoami d2hvYW1p
	/*private String s_NewXMLStr =
		"<SSHRequest version=\"2\" id=\"12345\">"+
		"<hosts username=\"andy\" password=\"r1galatvia\">"+
		"<host addr=\"ec2-50-112-70-228.us-west-2.compute.amazonaws.com\">"+		
		"</host> " +
		"<host addr=\"ec2-50-112-70-228.us-west-2.compute.amazonaws.com\">"+	
		"<username>ec2-user</username>"	+
		"<password>flatt4ever</password>"+
		"</host> " +		
		"</hosts>"+
		"<commands>"+
		"<command>dW5hbWUgLWE=</command>"+
		"<command>d2hvYW1p</command>"+
		"</commands>"+ 
		"<realtime>true</realtime>"+
		"<needsScp>yes</needsScp>"+
		"</SSHRequest>";*/
		
		// multiple commads that are part of a task have a sequence number
		// need to be sorted before executing
	/*private String s_NewXMLStr =
			"<SSHRequest version=\"2\" id=\"12345\">"+
			"<hosts username=\"andy\" password=\"r1galatvia\">"+
			"<host addr=\"ec2-50-112-70-228.us-west-2.compute.amazonaws.com\">"+		
			"</host> " +	
			"</hosts>"+
			"<commands>"+
			"<command seqnum=\"2\">dW5hbWUgLWE=</command>"+
			"<command seqnum=\"3\">aG9zdG5hbWU=</command>"+
			"<command seqnum=\"1\">cHMgLWFlZg==</command>"+			
			"</commands>"+ 
			"<realtime>true</realtime>"+
			"<needsScp>yes</needsScp>"+
			"</SSHRequest>";*/
	
	public JSSHProxyParams(String jarDirPath)
	{
		_jarDirPath = jarDirPath;
	}
	//------------------------------------------
	public Boolean ParseArgs(String...  args)
	{
		String arg = "";
		//if log level is not specified on command line, only log errors
		int logLevel = AppLog.LOG_LEVEL_ERROR; 
		
		for(int i = 0;i < args.length;++i )
		{
	        arg = args[i];
	        if(arg.equalsIgnoreCase("-?")|| arg.equalsIgnoreCase("--help"))
	        {
	        	PrintHelpAndExit();
	        }
	        if(arg.equalsIgnoreCase("--host"))
	        {
	        	++i;
	        	m_HostAddr = args[i];
	        }
	        else if (arg.equalsIgnoreCase("--username"))
	        {
	        	++i;
	        	m_UserName = args[i];
	        }       
	        else if (arg.equalsIgnoreCase("--password"))
	        {
	        	++i;
	        	m_Password = args[i];
	        }
	        else if (arg.equalsIgnoreCase("--cmd"))
	        {
	        	++i;
	        	m_Cmd = args[i];
	        }
	        else if (arg.equalsIgnoreCase("--realtime"))// supports returning data as it arrives
	        {       	
	        	m_IsRealTime = true;
	        }
	        else if (arg.equalsIgnoreCase("--noserver"))
	        {       	
	        	
	        	m_NoServer = true;	        		     
	        }
	        else if (arg.equalsIgnoreCase("--needsSCP"))
	        {       	
	        	
	        	m_NeedsScp = true;	        		     
	        }
	        // listen on port user wants
	        else if (arg.equalsIgnoreCase("--port"))
	        {
	        	++i;
	        	try
	        	{
	        		m_Port = Integer.decode(args[i]);
	        	}
	        	catch(Exception e)
	        	{
	        		AppLog.LogIt("JSSHProxyParams:Bad port number provided, defaulting to default port " + Integer.toString(m_Port),
	        					  AppLog.LOG_LEVEL_WARNING,
	        					  AppLog.LOGFLAGS_ALL);
	        		
	        	}       	
	        }
	        else if (arg.equalsIgnoreCase("--useSSL"))
	        {       	
	        	// use ssl
	        	this.m_UseSSL = true;	        		     
	        }
	        else if (arg.equalsIgnoreCase("--logpath"))
	        {       	
	        	++i;
	        	this.m_LogPath = args[i];	        		     
	        }
	        else if (arg.equalsIgnoreCase("--loglevel"))
	        {       	
	        	++i;
	        	logLevel = Integer.decode(args[i]); 		     
	        } 
	        else if (arg.equalsIgnoreCase("--simulation"))
	        {
	        	m_SimulationMode = true;
	        }
		}
		AppLog.SetLogLevel(logLevel);
		return (m_NoServer == false); //Validate();
	}
	
	//---------------------------------------------
	public Boolean Validate()
	{
		Boolean valid = false;
		// todo: validate some magic number or something
		if(IsHostScanRequest())
		{
			return true;
		}
		/* If it is a SVN request it can't be anything else */
		if(IsSvnRequest())
		{
			return m_SvnRequest.get_isValid();
		}
		switch(getRequestVersion())
		{
			
			case  FT_REQ_VERSION_1:
				valid = (StringUtils.IsValidString(m_HostAddr) &&
						StringUtils.IsValidString(m_UserName) &&
						StringUtils.IsValidString(m_Password) &&
						StringUtils.IsValidString(m_Cmd));
						break;
			case FT_REQ_VERSION_2:
				valid =( m_Hosts.size() > 0 &&
						m_Actions.size() > 0 );
				break;
			default:
				
				break;
			
		}
		return (m_NoServer? true : valid);
				
	}
	
	public Boolean ParseXMLParams(String req)
	{
		
		//req = s_NewXMLStr;
			
		try
		{
			
			 DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			 DocumentBuilder db = dbf.newDocumentBuilder();
			
			 Document doc = db.parse(new ByteArrayInputStream(req.getBytes("UTF-8")));
			 String val = "";
			 
			 Node root = doc.getDocumentElement();
			 root.normalize();
			 // get request ID and version
			 // for now not used, maybe later
			 String vers = GetNodeAttribute(root,"version");
			 if(!vers.isEmpty())
			 {
				 m_RequestVersion = Integer.parseInt(vers);
				 // validate version
				 if(!ValidateVersion())
				 {				 	
				 	throw (new Exception("Error parsing XML request: Unknown version"));
				 }
			 }
			
			 m_RequestID  = GetNodeAttribute(root,"id");
			
			 NodeList children = root.getChildNodes();
			 
			 for( int i = 0; i < children.getLength(); ++ i)
			 {
				 Node curChild = children.item(i);
				 String nodeName = curChild.getNodeName();
				 
				 if(nodeName != null )
				 {
					 							 
					 // process the ones that need a first child to be not null					 
					 if(curChild.getFirstChild()!=null)
					 {
												 
						 if(nodeName.equalsIgnoreCase("username"))
						 {
							 m_UserName = curChild.getFirstChild().getNodeValue().trim();
						 }
						 else if (nodeName.equalsIgnoreCase("password"))
						 {
							 m_Password = curChild.getFirstChild().getNodeValue().trim();
						 }
						 else if (nodeName.equalsIgnoreCase("host"))
						 {
							 m_HostAddr = curChild.getFirstChild().getNodeValue().trim();
						 }
						 else if (nodeName.equalsIgnoreCase("command"))
						 {
							 m_Cmd = StringUtils.Base64Decode(curChild.getFirstChild().getNodeValue().trim());
						 }
						 else if (nodeName.equalsIgnoreCase("realtime"))
						 {
							 val = curChild.getFirstChild().getNodeValue().trim();
							 m_IsRealTime = val.equalsIgnoreCase("true");
						 }
						 // do we need to copy command to a temp file ?
						 else if (nodeName.equalsIgnoreCase("needsScp"))
						 {
							 val = curChild.getFirstChild().getNodeValue().trim();						
							 m_NeedsScp = val.equalsIgnoreCase("yes");
						 }
						 // got quit message from client - bail
						 else if (nodeName.equalsIgnoreCase("quit"))
						 {
							AppLog.LogIt("JSSHProxyParams: SSH proxy is shutting down",
									AppLog.LOG_LEVEL_ALWAYS,
									AppLog.LOGFLAGS_ALL); 						 
							System.exit(0);					 
						 }
						 //Host scan request
						 else if (nodeName.equalsIgnoreCase("HostScanParams"))
						 {
							 ProcessHostScanParams(curChild);
						 }
						 // hosts list username
						 else if(nodeName.equalsIgnoreCase("hosts"))
						 {							
							 ParseHostList(curChild);
						 }
						 // leave the xml name for backwards compatibility
						 //
						 else if(nodeName.equalsIgnoreCase("actions"))
						 {
							ParseActions(curChild);			
							//ParseActions(doc.getElementsByTagName("action"));
						 }
						//repo  request
						 else if (nodeName.equalsIgnoreCase("RepoRequest"))
						 {
							 ProcessRepoRequest(curChild,doc);
						 }	
						 // database creds
						 else if ( nodeName.equalsIgnoreCase("DbCreds"))
						 {
							 ProcessDbCreds(curChild);
						 }						 
					 }	
					 // check the cases where we just look at the node name			
					 if (nodeName.equalsIgnoreCase("quit"))
					 {
						// got quit message from client - bail
						AppLog.LogIt("JSSHProxyParams: SSH proxy is shutting down",
									 AppLog.LOG_LEVEL_INFO,
									 AppLog.LOGFLAGS_ALL); 						 
						System.exit(0);					 
					 }
					 
				 }				 
			 }			 
		}
		catch(Exception ex)
		{
			
			AppLog.LogIt("JSSHProxyParams: Exception caught :" + ex.getMessage(),
					AppLog.LOG_LEVEL_ERROR,
					AppLog.LOGFLAGS_ALL); 		
			return false;
			
		}
		 				
		return Validate();
	}
	//---------------------------------------------
	private void PrintHelpAndExit()
	{
		AppLog.LogIt(AppLog.STR_APP_NAME + " v. " + AppLog.STR_APP_VERSION + 
				", Copyright 2011-2012 FLATT Solutions, All rights reserved.\n" +  STR_HELP,
				AppLog.LOG_LEVEL_ALWAYS,
				AppLog.LOGFLAGS_CONSOLE);
				
		System.exit(1);
		
	}
	
	//-------------------------------
	public static String GetNodeAttribute(Node item,String attrName)
	{
		Node attr =  item.getAttributes().getNamedItem(attrName);
		if(attr!=null)
		{
			return attr.getNodeValue();
		}
	    return "";
	}
	//-----------------------------------------------
	protected void ParseHostList(Node hostListNode)
	{
		
		NodeList children = hostListNode.getChildNodes();
		String groupName = GetNodeAttribute(hostListNode,"name");
		
		/* If the group has a valid name ( guid is not enforced for now - create a group object 
		 * Otherwise it is created later on demand with defaults "no group" database values.
		 */
		if(StringUtils.IsValidString(groupName))
		{	
			m_HostGroup = new FT_HostGroup( groupName,
											GetNodeAttribute(hostListNode,"username"),
											GetNodeAttribute(hostListNode,"password"),
											GetNodeAttribute(hostListNode,"sshkey"),
											GetNodeAttribute(hostListNode,"guid"));	
		}
		else
		{
			// need to create default here because it is referenced below
			m_HostGroup = new FT_HostGroup();
		}
		
		
		/* process children of hosts tag */	  
		int len = children.getLength();
		for( int i = 0; i < len;i++)
		 {
			 Node curChild = children.item(i);
			 String nodeName = curChild.getNodeName();
			 
			 if(nodeName != null && curChild.getFirstChild()!=null )
			 {				 							 			 
				 if(nodeName.equalsIgnoreCase("host"))
				 {
					 ParseOneHost(curChild);
				 }
				 else if(nodeName.equalsIgnoreCase("configParams"))
				 {
					 m_HostGroup.setConfigParams(curChild.getFirstChild().getNodeValue().trim());
				 }
				 					 				 
			 }
		 }	
	}
	//------------------------------------------
	protected void ParseActions(Node actionsNode)
	{
		// if this is a valid task there will be name and guid
		String taskName = GetNodeAttribute(actionsNode,"name");
		String taskGuid = GetNodeAttribute(actionsNode,"guid");
		
		/* If the task has a valid name - create a task object 
		 * Otherwise it is created later on demand with defaults "no task" database values.
		 */
		if(StringUtils.IsValidString(taskName))
		{
			m_Task = new FT_Task("",taskName, "", taskGuid);	 			 
		}
		
		NodeList actions = actionsNode.getChildNodes();
		for(int i = 0; i < actions.getLength();++i)
		{
			Node item = actions.item(i);
			if(item!=null && item.getFirstChild()!=null)
			{
				FT_Action cmd = new FT_Action(StringUtils.Base64Decode(item.getFirstChild().getNodeValue().trim()),				
												Integer.parseInt(GetNodeAttribute(item,"seqnum")),
												GetNodeAttribute(item,"name"),
												GetNodeAttribute(item,"guid"),
												GetNodeAttribute(item,"version"));
															
				m_Actions.add(cmd);
			}
			
		}
		// now sort the list of commands. Only relevant for  tasks
		FT_Action.Sort(m_Actions);
		//StringUtils.Base64Decode(curChild.getFirstChild().getNodeValue().trim());
	}
	
	//--------------------------------------------
	protected void ParseOneHost(Node hostNode)
	{
		
		FT_Host host = new FT_Host();
		if(host.FromXML(hostNode))
		{
			/*AppLog.LogIt("Adding host, addr "+ host.getHostAddr(),
					 	AppLog.LOG_LEVEL_INFO,
					 	AppLog.LOGFLAGS_CONSOLE);*/
					  
			m_Hosts.add(host);
		}		
	}
	
	//------------------------------------------
	private void ProcessHostScanParams(Node scanParamsNode)
	{
		 NodeList children = scanParamsNode.getChildNodes();
		 for( int i = 0; i < children.getLength(); ++ i)
		 {
			 Node curChild = children.item(i);
			 String nodeName = curChild.getNodeName();
			 
			 if(nodeName != null && curChild.getFirstChild()!=null )
			 {
				// range to scan for hosts
				 if (nodeName.equalsIgnoreCase("startIP"))
				 {
					 m_StartIP = curChild.getFirstChild().getNodeValue().trim();
				 }
				 else if (nodeName.equalsIgnoreCase("endIP"))
				 {
					 m_EndIP = curChild.getFirstChild().getNodeValue().trim();
				 }
				 // the  timeout to use when scanning for hosts
				 else if (nodeName.equalsIgnoreCase("scanConnectTimeout"))
				 {
					 m_ScanConnectTimeout = Integer.parseInt(curChild.getFirstChild().getNodeValue().trim());
				 } 
			 }
		 }		 
	}
	
	//---------------------------------------------
	private Boolean ValidateVersion()
	{
		return (m_RequestVersion>= FT_REQ_VERSION_1 && m_RequestVersion <=FT_REQ_VERSION_2);
	}
	//----------------------------------------------
	public Boolean getNeedsScp() 
	{
		return m_NeedsScp;
	}
	//----------------------------------------------
	public void setNeedsScp(Boolean needsScp) 
	{
		m_NeedsScp = needsScp;
	}
	//----------------------------------------------
	public String getHostAddr(int hostIndex) 
	{
		
		// v 1 has user name, v 2 uses index		
		FT_Host host = GetHostAt(hostIndex);		
		if(host==null)
		{
			// v 1 - no host index, just return host addr
			return m_HostAddr;
		}
		// if host has a user name - return it, otherwise return host grp user name
		return (host.getAddress());		
	}

	//----------------------------------
	public void setHost(String val) 
	{
		this.m_HostAddr = val;
	}

	
	//-------------------------------------
	public String getHostConfigParams(int hostIndex)
	{
		
		FT_Host host = GetHostAt(hostIndex);		
		if(host!=null)
		{
			return (host.getConfigParams().isEmpty() ? GetHostGroup().getConfigParams(): host.getConfigParams());
		}
		return GetHostGroup().getConfigParams(); // this is unlikely
	}
	//----------------------------------
	public void setPassword(String val) 
	{
		m_Password = val;
	}

	//--------------------------------
	/*public FT_Action getAction(int index) 
	{
		// version 2 processing
		String cmd = this.GetCommandAt(index);
		if(cmd!=null && !cmd.isEmpty())
		{
			return cmd;
		}
		return m_Cmd;
	}*/
	//--------------------------------
	public int getActionIndex(FT_Action action)
	{
		return m_Actions.indexOf(action);
	}
	//--------------------------------
	public int getHostIndex(FT_Host host)
	{
		return m_Hosts.indexOf(host);
	}
	//--------------------------------
	public Boolean getIsRealTime() 
	{
		return m_IsRealTime;
	}

	//--------------------------------
	public void setIsRealTime(Boolean isContinuous) 
	{
		this.m_IsRealTime = isContinuous;
	}


	public Boolean getLocalOnly()
	{
		return m_LocalOnly;
	}


	public void setLocalOnly(Boolean localOnly) 
	{
		this.m_LocalOnly = localOnly;
	}


	public Integer getPort() {
		return m_Port;
	}


	public void setPort(Integer port) 
	{
		this.m_Port = port;
	}


	public Boolean getNoServer() 
	{
		return m_NoServer;
	}

	//-------------------------------------------
	public void setNoServer(Boolean val) 
	{
		this.m_NoServer = val;
	}
	//-------------------------------------------
	public String getUserName(int hostIndex) 
	{		
		FT_Host host = GetHostAt(hostIndex);		
		
		return (host != null ? host.getUsername() : null);
		// if host has a user name - return it, otherwise return host grp user name
		//return (host.getUsername().isEmpty()? m_HostGroupUserName : host.getUsername());		
	}
	
	//------------------------
	public String getPassword(int hostIndex) 
	{				
		FT_Host host = GetHostAt(hostIndex);			
		return (host != null ? host.getPassword() : null);
	}	
	//-------------------------------------
	// return path of ssh key temp file. if host does not have it - return group key file
	public File getSshKeyFile(int hostIndex)
	{		
		FT_Host host = GetHostAt(hostIndex);		
		return( host != null ? host.getSshKeyFile(): null);
	}
	//--------------------------------------------
	public String GetHostGroupUserName()
	{
		return GetHostGroup().getUsername();
	}
	//------------------------------------	
	public String GetHostGroupPassword()
	{
		return GetHostGroup().getPassword();
	}
	//------------------------------------	
	public File GetHostGroupSshKeyFile()
	{
		return GetHostGroup().getSshKeyFile();
	}	
	//-------------------------------------------
	public void setUserName(String userName) 
	{
		this.m_UserName = userName;
	}
	//-------------------------------------------
	public Boolean getUseSSL() 
	{
		return m_UseSSL;
	}
	//-------------------------------------------
	public void setUseSSL(Boolean val) {
		m_UseSSL = val;
	}
	//-------------------------------------------
	public String getLogPath() {
		return m_LogPath;
	}
	//-------------------------------------------
	public void setLogPath(String val) {
		m_LogPath = val;
	}
	//-------------------------------------------
	public String getStartIP() 
	{
		return m_StartIP;
	}
	//-------------------------------------------
	public void setStartIP(String val) 
	{
		m_StartIP = val;
	}
	//-------------------------------------------
	public String getEndIP() 
	{
		return m_EndIP;
	}
	//-------------------------------------------
	public void setEndIP(String mEndIP) 
	{
		m_EndIP = mEndIP;
	}
	//------------------------------------------
	// java socket connect timeout is in milliseconds
	public Integer getScanConnectTimeout()
	{
		return m_ScanConnectTimeout * 1000;
	}
	//------------------------------------------
	public void setScanConnectTimeout(Integer val) 
	{
		m_ScanConnectTimeout = val;
	}
	//------------------------------------------
	public Boolean IsHostScanRequest()
	{
		return((m_SvnRequest == null) && (!m_StartIP.isEmpty() && !m_EndIP.isEmpty()));
	}
	//------------------------------------------
	public int getRequestVersion() 
	{
		return (m_RequestVersion);
	}
	//------------------------------------------
	//------------------------------------------
	public void setRequestID(String val) 
	{
		m_RequestID = val;
	}
	
	//------------------------------------------
	public String getRequestID() 
	{
		return m_RequestID;
	}
	//------------------------------------------
	public int NumHosts()
	{
		return m_Hosts.size();
	}
	public FT_Host GetHostAt(int i)
	{
		if(ValidIndex(m_Hosts,i))
		{
			return m_Hosts.get(i);
		}
		return null;		
	}
	//------------------------------------------
	public int NumCommands()
	{
		return m_Actions.size();
	}
	//--------------------------------
	public FT_Action getAction(int i)
	{
		if(ValidIndex(m_Actions,i))
		{
			return m_Actions.get(i);
		}
		return null;		
	}
	//---------------------------------
	@SuppressWarnings("rawtypes")
	private  Boolean ValidIndex(ArrayList list, int index)
	{
		return (index >=0 && index < list.size());
	}
	//---------------------------
	public Boolean getSimulationMode()
	{
		return m_SimulationMode;
	}
	//-------------------------------
	public void SetSimulationMode(Boolean val)
	{
		m_SimulationMode = val;
	}		
	//-----------------------------
	//Copy command line parameters to this object. some of them are relevant to execution i.e simulation mode
	public void CopyCmdLineParams(JSSHProxyParams src)
	{
		this.m_SimulationMode = src.getSimulationMode();
		// maybe something else will be needed nothing so far
	}
	//-----------------------------
	public String getHostGroupConfigParams()
	{
		return GetHostGroup().getConfigParams();
	}
	//-----------------------------
	public void setHostGroupConfigParams(String val)
	{
		GetHostGroup().setConfigParams(val);	
	}
	//-----------------------------------------
	public Boolean IsSvnRequest()
	{
		return m_SvnRequest!=null;
	}
	//--------------------------------------------
	// TODO: abstract to support different types of repository- svn, git, cvs
	// the client can pass an attribute specifying which request object to use
	// for now svn only
	protected void ProcessRepoRequest(Node svnRoot,Document doc)
	{
		m_SvnRequest = new FT_SvnRequest();
		m_SvnRequest.FromXml(svnRoot, doc);
	}
	//--------------------------------------------
	public FT_SvnRequest get_SvnRequest()
	{
		return m_SvnRequest;
	}
	//----------------------------------------
	public String GetJarDirPath()
	{
		return _jarDirPath;
	}
	//-------------------------------
	// delete temkp proxy files for all hosts
	public void Cleanup()
	{		
		GetHostGroup().Cleanup();
		for(int i = 0; i < m_Hosts.size(); ++ i)
		{
			FT_Host cur = m_Hosts.get(i);
			if(cur!=null)
			{
				cur.Cleanup();
			}
		}
	} 
	//-----------------------------
	// this is to make sure that the host group object whihc is referenced throughout, is never null.
	// 
	public FT_HostGroup GetHostGroup()
	{
		if(m_HostGroup == null)
		{
			m_HostGroup = new FT_HostGroup();
		}
		return m_HostGroup;
	}
	//------------------------------
	public FT_Task GetTask()
	{
		if(m_Task == null)
		{
			m_Task = new FT_Task();
		}
		return m_Task;
	}
	//--------------------------------
	private void ProcessDbCreds(Node theNode)
	{
		_dbCreds.FromXML(theNode);		
	}
	
	//--------------------------------------
	public FT_DbCreds getDbCreds()
	{
		return _dbCreds;
	}
	//--------------------------------------
	public String getTaskName() 
	{
		return GetTask().getName();
	}
	//--------------------------------------
	public String getTaskGuid() 
	{
		return GetTask().getGuid();
	}
	//--------------------------------------
	public ArrayList<FT_Host> getHosts() 
	{
		return m_Hosts;
	}
	//--------------------------------------
	public ArrayList<FT_Action> getActions() 
	{
		return m_Actions;
	}
	//---------------------------------
	// Do we have more than one host
	public boolean HasGroup()
	{
		return (GetHostGroup().IsValid() && m_Hosts.size() >=1);
	}
	// Do we have a task
	public boolean HasTask()
	{
		return (GetTask().IsValid() && this.m_Actions.size() >=1);
	}
	//-----------------------------------------
/*	public String getDbUserName()
	{
		return  _dbUserName;
	}*/
		
}
