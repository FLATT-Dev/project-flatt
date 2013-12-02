/*******************************************************************************
 * SSHExec.java
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
import net.schmizz.sshj.SSHClient;
import net.schmizz.sshj.connection.channel.direct.Session;
import net.schmizz.sshj.transport.verification.*;
import net.schmizz.sshj.userauth.keyprovider.*;

import java.security.Security;
import java.util.ArrayList;
import java.io.File;

import org.bouncycastle.jce.provider.BouncyCastleProvider;


import com.FLATT.Utils.*;


public class SSHExec extends   Thread
{

	protected Boolean m_DebugLogging = false;
	protected JSSHProxyParams m_Params;
	protected  SSHClient m_SSHClient 	= null;
	protected  Session   m_Session 	= null;
	protected  String	 m_ResultString ="";
	protected static String REMOVE_SELF_CMD = "rm -f ";
	protected static String SET_EXEC_MODE_CMD = "chmod 700 "; // rwx-x-x
	protected static String TARGET_DIR = "/tmp/";
	protected static String STR_SEMICOLON = ";";
	protected static String STR_CLIENT_CANCELED="Client canceled";
	protected Boolean m_ClientCanceled = false;// client disconnect due to cancel
	protected SSHJResponse m_ResponseObj;
	protected int 		   m_HostIndex = -1; // index into the array of hosts maintainsed by the params object
	//protected Boolean m_IsRunning = false;
	protected FT_Action m_CurAction; // the Action we're executing
	// the sequence number of the command we're currently executing.
	// used for tasks. For just actions it's always zero
	protected int m_CmdSeqNum = 0;	
	protected JSSHConnection _parentObj;
	protected String _returnStatus = SSHJResponse.STATUS_OK;
	// list of all commands that this object executes. > 1 for tasks
	private ArrayList<FT_Action> _actionsList = new ArrayList<FT_Action>();
	
	//-----------------------------------------
	public SSHExec(JSSHProxyParams params,JSSHConnection parent) 
	{
		// TODO Auto-generated constructor stub
		m_Params = params;
		_parentObj = parent;
		// this is for v 1. host index is -1 and so the old global command is returned
		// OBSOLETE
		m_CurAction = m_Params.getAction(m_HostIndex);	
		
	}	
	//-----------------------------------
	// v2 processing
	public void run()
	{
		Boolean canProceed = false;
		String returnData = "";
		Boolean disconnectOnCompletion;
		int i;
		
		/* First make a copy of  all actions and put them in a local list. 
		 * This is done because we modify the action command and
		 * result and there may be other exec threads that may need to use them. 
		 * For  task execution the number of actions in the list may be > 1
		 */
		
		for( i = 0; i < m_Params.NumCommands();++i)
		{				
			_actionsList.add(new FT_Action(m_Params.getAction(i)));				
		}	
		try
		{			
			if(!getClientCanceled() && Connect())			
			{					
				if(m_Params.IsHostScanRequest() || m_Params.IsSvnRequest())
				{
					Execute(false,false); // parameters don't matter here
				}
				
				else
				{				
					for(i = 0; i < _actionsList.size();++i)
					{						
						if(getClientCanceled())
						{
							break;
						}
						
						m_CurAction = _actionsList.get(i); 					
						/* substitute the variables in command
						 * with values found in host config file
						 */
						SubstituteHostConfigValues();
						m_CmdSeqNum = i;
						// reset variables for each command
						setResultString("");	
						returnData = "";		
						
						// are we running simulation?
						if(m_Params.getSimulationMode())
						{
							if (!ExecuteSimulation())
							{
								// error sending simulation data - break;								
								break; 
							}
						}
						else
						{						
							// normal execution,non simulation
							// is it a multiline command ?
							// if so, scp it to remote host to temp dir
							// and execute it,then  delete
							if(NeedsScp())
							{
								AppLog.LogIt("SSHExec #" + Integer.toString(m_HostIndex) + 
										":copying command to remote host ",
										AppLog.LOG_LEVEL_INFO,
										AppLog.LOGFLAGS_ALL);
								canProceed = CopyCommandToRemoteHost();					
							}
							else
							{	//TODO: Delete t his
								AppLog.LogIt("SSHExec #" + Integer.toString(m_HostIndex) + 
											":needsSCP is false! exiting to catch",
											AppLog.LOG_LEVEL_INFO,
											AppLog.LOGFLAGS_ALL);
								System.exit(1);
							}
						
							AppLog.LogIt("SSHExec #" + Integer.toString(m_HostIndex) + ":Executing command",
										AppLog.LOG_LEVEL_INFO,
										AppLog.LOGFLAGS_ALL);
							
							// on first iteration prepare the shell object
							if( i == 0)
							{
								canProceed = PrepareForExec();
							}
							
							if(getClientCanceled())
							{
								break;
							}
							// OK here we go
							//  if more than 1 command - it's a task and we need to keep the ssh connection
							// set disconnectOnCompletion parameter  to true if there is one command and to 
							// false if there is more than 1
							// set readLoginPrompt parameter to true on the first 
							// also pass the command sequence number
							// see if we need to disconnect from remote host
							disconnectOnCompletion = (m_Params.NumCommands() == 1 || i >=m_Params.NumCommands()-1);
							if( canProceed &&
								Execute((disconnectOnCompletion), // <-- disconnectOnompletion is true when excuting a single command/
																  // for tasks it is  true when executinh last command in task
										(i == 0)))				 // <-- readLoginPrompt
																
							{									
								returnData = getResultString();	
								m_CurAction.setResult(SSHJResponse.STATUS_OK);
							}
							else
							{
								// If command returns an error, result string contains error description.
								// if we have more than 1 command - it's a task ,stop
								//m_ResponseObj.SetStatus(SSHJResponse.STATUS_ERR);
								returnData = "Error: Failed to execute remote command: " + getResultString();					
							}
						
							// host execution completed- successfully or not  - send data
							if(!SendReturnData(returnData,SSHJResponse.STATUS_OK))
							{
								AppLog.LogIt("SSHExec # " + Integer.toString(m_HostIndex) + ":SendReturnData returned false, breaking",
											  AppLog.LOG_LEVEL_INFO,
											  AppLog.LOGFLAGS_CONSOLE);			
	
								
								break;
							}
						
							//If the return dta contains error: break out . In case of a single command it will break out 
							// anyway but for tasks it will stop early as it should
							if(returnData.contains("rror:"))
							{
								m_CurAction.setResult(SSHJResponse.STATUS_ERR);
								break;
							}											
						}// non sim mode					
					}// num commands
				} // not host scan, normal execution or simulation
			} // connect
			else
			{									
				_returnStatus = SSHJResponse.STATUS_ERR;
				returnData = getResultString();
				if(returnData.isEmpty())
				{
					returnData = "Failed to connect to host " + getHostAddr();
				}
				UpdateAllActionsReturnResult(SSHJResponse.STATUS_CONN_ERR);				
			}		
			/*AppLog.LogIt("JSSHConnection: Printing Execution result:" + AppLog.g_LineSepartator + " " +
						  returnData,AppLog.LOG_INFO,true);	*/		 			
		 } 
		 catch( Exception e)
		 {					 
			 _returnStatus = SSHJResponse.STATUS_ERR;
			 returnData = "Failed to connect to host " + getHostAddr();
			 AppLog.LogIt(returnData,AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
			UpdateAllActionsReturnResult(_returnStatus);				

		 }
		 finally
		 {
			// only error case is handled here
			if(_returnStatus == SSHJResponse.STATUS_ERR)
			{
				SendReturnData(returnData,_returnStatus);
			}				
			//Cleanup();
			AppLog.LogIt("SSHExec # "+ Integer.toString(m_HostIndex) + " :Thread is done!",
						  AppLog.LOG_LEVEL_INFO,
						  AppLog.LOGFLAGS_CONSOLE);	
			
			//_finished = true;		
			if(_parentObj!=null)	
			{
				_parentObj.IncrementNumCompleted();
			} 
		 }
		 
	}
	//---------------------------------------------------
	protected Boolean SendReturnData(String returnData,String status)
	{
		Boolean ret = false;
		if(getClientCanceled())
		{
			return ret;
		}						
		try
		{			
			//m_ResponseObj.SetData(returnData);
			ret=m_ResponseObj.SendResponse(m_CmdSeqNum,
									  getHostAddr(), 
									  returnData,
									  status,
									  SSHJResponse.RESP_TYPE_NORMAL,
									  m_HostIndex);
						
		}
		catch(Exception e)
		{
			AppLog.LogIt("Failed to send return data",AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
		}
		m_ResponseObj.Reset();
		return ret;
	}
	//----------------------------------------
	public void Cleanup(boolean isFinal)
	{		
		try
		{			
			if( m_Session !=null )		
			{
				m_Session.close();
				AppLog.LogIt("SSHExec # " + Integer.toString(m_HostIndex) + " Cleanup:Closing session",
							  AppLog.LOG_LEVEL_INFO,
							  AppLog.LOGFLAGS_CONSOLE);			

				
			}
			if(m_SSHClient!=null)
			{
				m_SSHClient.disconnect();
				AppLog.LogIt("SSHExec # " + Integer.toString(m_HostIndex) + " Cleanup:Disconnecting ssh client ",
							  AppLog.LOG_LEVEL_INFO,
							  AppLog.LOGFLAGS_CONSOLE);			

				
			}			
		}
		catch(Exception ex)
		{
			/*AppLog.LogIt("SSHExec  #" + Integer.toString(m_HostIndex) + ": Exception cleaning up ssh connection to host "+
							m_Params.getHostAddr(m_HostIndex),
							AppLog.LOG_ERR,true);*/
		}
		finally
		{
			m_Session = null;
			m_SSHClient = null;	
			if(isFinal)
			{
				FinalCleanup();
			}

		}
	}
	//-------------------------------
	public Boolean Connect()
	{
		Boolean ret = true;
		// if in sim mode - sleep and return true
		if(m_Params.getSimulationMode())
		{
			MiscUtils.Sleep(2000);
			return true;
		}
		
		m_SSHClient = new SSHClient();
		
		try
		{ 
			// if there is a global key and the host does no override - use the global key
			// otherwise see if there is a host specific key and use it if found.
			// The key supercedes username and password
			
			File sshKeyFile = m_Params.getSshKeyFile(m_HostIndex); 
			String password = m_Params.getPassword(m_HostIndex);
			String username = m_Params.getUserName(m_HostIndex);
			Boolean useGroupCreds = username.isEmpty();
			
			/* the host creds supercede the group
			 *  only use group creds if host creds are invalid.
			 *  Allow empty passwords			
			 */
			
			if(useGroupCreds)
			{
				sshKeyFile = m_Params.GetHostGroupSshKeyFile();
				password = m_Params.GetHostGroupPassword();
				username = m_Params.GetHostGroupUserName();
			}
			
			// now  that we have valid creds - 
			
			// does not do server authentication! potentially dangerous 
			 AppLog.LogIt("JSSHExec #" + Integer.toString(m_HostIndex) + ": Connecting to host "+ 
					 		m_Params.getHostAddr(m_HostIndex), 
					 		AppLog.LOG_LEVEL_INFO,
					 		AppLog.LOGFLAGS_ALL);
			 
			 m_SSHClient.addHostKeyVerifier(new PromiscuousVerifier()); 
			 m_SSHClient.connect(m_Params.getHostAddr(m_HostIndex)); 
			 
			 // if we have ssh key - use it, otherwise use password
			 if (sshKeyFile!=null)
			 {
				 //Bouncy castle provider to read PEM keys
				 Security.addProvider(new BouncyCastleProvider());
				 PKCS8KeyFile keyFile = new PKCS8KeyFile();
				 keyFile.init(sshKeyFile);
				 m_SSHClient.authPublickey(username,keyFile);				 
			 }
			 else
			 {
				 m_SSHClient.authPassword(username,password);
			 }	
		 				 
             m_Session = m_SSHClient.startSession(); 
			
		}
		catch(Exception err)
		{
			ret = false;
			m_ResultString = "Failed to connect to host " + err.getMessage();
			Cleanup(false);
		}
		return ret;
	}
	//----------------------------------------------------------
	public int getHostIndex()
	{
		return m_HostIndex;
	}
    //--------------------------------------------------------    
	public Boolean Execute(Boolean disconnectOnCompletion,Boolean readLoginPrompt)
	{
		Boolean ret = true;
        return ret;	
	}
	//-------------------------------------
	public Boolean CopyCommandToRemoteHost()
	{
		Boolean ret = true;
		try 
		{          
            File tempCmdFile = FT_FileUtils.SaveTempFile(m_CurAction.getCommand());
            if(tempCmdFile!=null)
            {
     
            	final String fileName = tempCmdFile.getName()+".t";
            	// upload the script into the temp directory on
            	// target host. Assumption is that /tmp dir exists everywhere.
            	// TODO: Need to make this code more robust: if /tmp is full, try /var/tmp or something
            	// xxx!
            	// Make sure that the local temp file name and remot  are different
            	// to account for cases where a plugin is executing on the same host where jsshporxy is running.
            	// In that case the file is saved by jsshproxy to temp directory, scp'd to the same temp directory 
            	// and deleted.leaving shell exec without a file to execute
            	
            	m_SSHClient.newSCPFileTransfer().upload(tempCmdFile.getAbsolutePath(), TARGET_DIR+fileName);
            	
            	// ok now that the file has been successfully uploaded,
            	// create a new exec command  and delete local command file
            	String execPath = TARGET_DIR +fileName; 
            	UpdateRemoteCommand(execPath);          
            	tempCmdFile.delete();
            }
            else
            {
            	ret = false;
            }
        } 
		catch( Exception e)
        {
			AppLog.LogIt("SSHExec  #" + Integer.toString(m_HostIndex) + 
					": Failed to copy temp command file to remote host",
					AppLog.LOG_LEVEL_ERROR,
					AppLog.LOGFLAGS_ALL);
			ret = false;
        }
		return ret;
	}
	//--------------------------------------------------------
	
	//------------------------------------
	// resp is unused
	public void HandleClientResponse(String resp)
	{
		AppLog.LogIt("SSHExec #" + Integer.toString(m_HostIndex) +
					": HandleClientResponse",				
					AppLog.LOG_LEVEL_INFO,
					AppLog.LOGFLAGS_CONSOLE);		
		m_ResponseObj.setGotAck();
	}
	//----------------------------------
	public String getResultString() 
	{
		return m_ResultString.trim();
	}
	//----------------------------------
	public void setResultString(String m_ResultString) 
	{
		this.m_ResultString = m_ResultString;
	}
	//------------------------------
	/* Default behavior is to 
	 * Append delete directive at the end of the command to execute
     * after script executes it is deleted
      * chmod <filename>;execute <filename>;rm -f <filename>
	 * Subclasses may need to override
	 */
	protected void UpdateRemoteCommand(String execPath)
	{
		m_CurAction.setCommand(SET_EXEC_MODE_CMD + execPath + ";" + execPath);	
	}	
	//-------------------
	// Determine if this command needs to be copied to remote server and executed.
	// Subclasses override
	public Boolean NeedsScp()
	{
		return m_Params.getNeedsScp();
	}
	//----------------------------------------------------
	// if there is  a sudo in the command - return shell exec object becasue sudo requires
	// a shell, otherwise return a simple cmd object 
	public static SSHExec GetSSHExecObject(JSSHProxyParams params,JSSHConnection parent)
	{		
		// return the right exec object depending on the params exec or host scanner exec object
		if(params.IsHostScanRequest())
		{
			return (new JSSHHostScannerExec(params,parent));
		}
		else if( params.IsSvnRequest())
		{
			return (new FT_JSVNExec(params,parent));
		}
		// by default return a shell exec object		
		return (new SSHShellExec(params,parent));
		
	}
	//---------------------------------------
	public Boolean getClientCanceled() 
	{
		return m_ClientCanceled;
	}
	//---------------------------------------
	 public void setClientCanceled(Boolean clientCanceled) 
	{
		m_ClientCanceled = clientCanceled;
	}	
	//---------------------------------------
	public void setResponseObj(SSHJResponse val) 
	{
		m_ResponseObj = val;
		//m_ResponseObj.setHostAddr(getHostAddr());
	}	
	//-------------------------------
	public Boolean IsSSHConnected()
	{
		return (m_SSHClient!= null && m_SSHClient.isConnected());
	}
	public void setHostIndex(int val)
	{
		m_HostIndex = val;
	}
	//----------------------------------------
	public String getHostAddr()
	{	
		return m_Params.getHostAddr(m_HostIndex);
	}
	//----------------------------------------------------------
	protected void DEBUG(String msg)
	{
		if(m_DebugLogging)
		{
			AppLog.LogIt(msg,
					  AppLog.LOG_LEVEL_INFO,
					  AppLog.LOGFLAGS_CONSOLE);			

		}
	}
	
	//---------------------------------
	public Boolean PrepareForExec()
	{
		return true;
	}
	//-----------------------------------------
	/* Get the host configuration parameters ( for the host or group)
	 * If not empty, scan the command and substitute variables found in command
	 * with values found in the config parameters
	 */
	void SubstituteHostConfigValues()
	{
		String hostConfig = m_Params.getHostConfigParams(m_HostIndex);
		if(hostConfig!=null && !hostConfig.isEmpty())
		{
			m_CurAction.setCommand(StringUtils.Substitute(m_CurAction.getCommand(),StringUtils.Base64Decode(hostConfig)));
		}
	}
	/*
	//------------------------------
	protected String CreateTempKeyFile(String sshKey)
	{
		String ret = "";
		try
		{
			_tempKeyFile = SaveTempFile(sshKey);
			ret = _tempKeyFile.getCanonicalPath();
		}
		catch( Exception e)
		{
			AppLog.LogIt("Exception while creating a temp file for ssh key  : "+ e.getMessage(),
							AppLog.LOG_LEVEL_ERROR, 
							AppLog.LOGFLAGS_ALL);
		}	
		return  ret;
	}*/
	public String getReturnStatus() 
	{
		return _returnStatus;
	}
	//----------------------------
	public int getCommandSeqNum()
	{
		return m_CmdSeqNum;
	}
	//----------------------------
	/*public Boolean isMarkedDead()
	{
		return _markedDead;
	}
	//------------------------------
	public void setMarkedDead()
	{
		 _markedDead  = true;
	}
	// don't rely on isAlive the  thread relies on the VM  to clean it up.
	public Boolean isFinished()
	{
		return _finished;
	}*/

	//----------------------------------------
	/*public void setIsRunning(Boolean val)
	{
		m_IsRunning = val;
	}
	//----------------------------------------
	public Boolean getIsRunning(Boolean val)
	{
		return m_IsRunning;
	}Y*/
	//-----------------------------
	private boolean ExecuteSimulation()
	{
		// simulate OK result
		m_CurAction.setResult(SSHJResponse.STATUS_OK);
		int sleepTime = 1 + (int)(Math.random() * ((10 - 1) + 1));
		MiscUtils.Sleep(sleepTime * 1000);
		
		if(!SendReturnData("Simulated data from " + getHostAddr(),SSHJResponse.STATUS_OK))							  
		{
			AppLog.LogIt("SSHExec # " + Integer.toString(m_HostIndex) + ":SendReturnData returned false, breaking",
						  AppLog.LOG_LEVEL_INFO,
						  AppLog.LOGFLAGS_CONSOLE);		
			return false;	
		}					
			
		return true;
	}
	//---------------------------------------
	/* Set correct return result of all actions. 
	 * This covers cases where we cannot connect to host or
	 */
	private void UpdateAllActionsReturnResult(String resultCode)
	{
		
		for(int i = 0; i < _actionsList.size();++i)
		{							
			if(getClientCanceled())
			{
				break;
			}
			/* only set if not already set */
			FT_Action curAction =  _actionsList.get(i);
			if(curAction.getResult().equals(SSHJResponse.STATUS_DIDNT_RUN))
			{
				curAction.setResult(resultCode);	
			}
		}
	}
	//----------------------------------------------------------
	public FT_Action FindAction(FT_Action act)
	{
		for(int i = 0; i < _actionsList.size();++i)
		{
			FT_Action cur = _actionsList.get(i);
			if(cur.getGuid().equals(act.getGuid()))
			{
				return cur;
			}
		}
		return null;
	}
	//----------------------------------------
	// called by admin object when it is done updating history
	public void CleanupActions()
	{
		
		if(_actionsList!=null)
		{			
			_actionsList.clear();
			_actionsList = null;			
		}
	}
	//-----------------------------------------
	// called by connection object at the end of operation to perform cleanup
	// that has to be done only once
	// For now the only application is to dump the output in the command line client app
	protected void FinalCleanup()
	{
		m_ResponseObj.Cleanup();
	}
	
}
