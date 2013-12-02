/*******************************************************************************
 * SSHShellExec.java
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

import java.io.BufferedReader;
import java.io.InputStreamReader;
import net.schmizz.sshj.connection.channel.direct.Session.Shell;
import com.FLATT.Utils.*;

//-========================================
public class SSHShellExec extends SSHExec 
{

	private Shell m_Shell;
	private static int SLEEP_MS				= 1000; // 1 second sleep between waits for stream
	private String m_Prompt = "";
	private String m_CmdResponse = "";	
	private Boolean m_BreakOnNL = false; // used to break out of the loop waiting for input stream
	private Boolean m_CmdFileDeleted = false;
	private BufferedReader m_StreamReader = null;
	
	
	public SSHShellExec(JSSHProxyParams params,JSSHConnection parent) 
	{
		super(params,parent);	
		
	}
	//-----------------------------
	// Set up jssh objects
	@Override
	public Boolean PrepareForExec()
	{
		Boolean ret = true;
		try
		{ 
			// does not do server authentication! potentially dangerous 
			// when executing a task and this is not the first command in a batch
			// the session and shell objects are already set up
			
			m_Session.allocateDefaultPTY();			
		    m_Shell = m_Session.startShell();		           
		    m_StreamReader = new BufferedReader(new InputStreamReader(m_Shell.getInputStream()));
		}
		catch(Exception e)
		{
			
			ret = false;
		}
		return ret;
	}
	//-----------------------------------------------
	// if this is a part of the task - don't disconnect the ssh connection.
	// On error or abort the JSSHConnection object will clean up. 
	// Also, if it's a task and its not the first command we're executing - don't read the login prompt again
	// 
	@Override
	public Boolean Execute(Boolean disconnectOnCompletion, Boolean readLoginPrompt)
	{		
 		Boolean ret = true;
		try
		{	   	   
		   
			m_CmdFileDeleted = false; // reset because task can have more than one command
			// read shell input stream that remote system sends on  login
		   // and determine the shell prompt .Done inside ReadInputStream
		   // Do this only on initial login. When executing tasks  this step is skipped on the second and
		   // subsequent tasks
		  if(readLoginPrompt)
		  {
		   	ReadInputStream();
		  }
		   
		   /* We always take the following distinct steps:
		    * 1. Chmod the command file, wait for prompt. On error -
		    * 	 bail, cannot execute without chmod.
		    * 2. Execute and get result. If an error was returned, record it in output string
		    * 3. Delete command file, wwait for output. If error, log it. Cant do much about it..
		    * There is a possibility of filling up /tmp .. TODO: revisit this
		    */
		   
		   // Step 1. Chmod the command file. Cannot proceed without  this step
		  if(!ExecSuccess(ExecuteRemoteCommand(SET_EXEC_MODE_CMD + m_CurAction.getCommand(),getClientCanceled() )))
		  {
			  m_ResultString = "Failed to prepare remote command for execution";
			  throw (new Exception("Chmod failed")); 
		  }
		   //Step 2
		  /* Execute commmand and store result
		   * St
		   */
		  
		  // if plugin wants to send data back right away - break on new line in ReadInputStream and
		  // send the data
		  if(m_Params.getIsRealTime())
		  {
			m_BreakOnNL = true; // start sending data back
		  }
		  ExecuteRemoteCommand( m_CurAction.getCommand(),getClientCanceled());
		  
		  // on some systems password is not cached - enter it and attempt to resend the command
		  if(ContainsPasswordPrompt(m_CmdResponse))
		  {
			  AppLog.LogIt("SSHShellExec: On sudo got a password prompt:" + "'"+ m_CmdResponse.trim() + "'"+
					  	   "\nentering password... " , 
					  	   AppLog.LOG_LEVEL_WARNING, 
					  	   AppLog.LOGFLAGS_ALL);			     
			  ExecuteRemoteCommand(m_Params.getPassword(m_HostIndex),getClientCanceled());
		  }
		  if(ContainsPasswordPrompt(m_CmdResponse))
		  {
			  AppLog.LogIt("SSHShellExec: Output possibly contains password prompt : " + m_CmdResponse , 
					  		AppLog.LOG_LEVEL_WARNING, 
					  		AppLog.LOGFLAGS_ALL);
		  }
		  // remove command and prompt from response string
		  CleanupExecResponse();
	  	 
		  // Step 3. Delete commmand file		
		  //DeleteCommandFile();
		  		   
		}
		catch(Exception err)
		{
			ret = false;
			// TODO: error handling
		}
		finally
		{
        	if(disconnectOnCompletion)
        	{
        		Cleanup(false);// is it a final cleanup
        	}
        	else
        	{
        		// this is a part of the task and we only need to clean up the file
        		DeleteCommandFile();       		
        	}
        	//DeleteCommandFile();
        	// if it's a task - we dont want to disconnect on completion of execution
        	/*if(disconnectOnCompletion)
        	{
        		Cleanup();
        	}*/
        	
    	}
    	
		return ret;
	}
	//-----------------------------------------------
	// for now
	@Override
	synchronized public  void Cleanup(boolean isFinal)
	{
		// if we're in sim mode - there is no command file
		if(!m_Params.getSimulationMode())
		{
			DeleteCommandFile();	
		}		
		super.Cleanup(isFinal);	
	}
	//------------------------------------
	@Override
	public Boolean IsSSHConnected()
	{
		return(m_Shell == null? false : super.IsSSHConnected());
	}
	
	//-------------------------------------
	// TODO: clean up response
	// Remove shell prompt string and the command 
	void CleanupExecResponse()
	{
		
		// The last line is always a prompt.
		//Find last carriage return and trim it till  end
		//The assumption is that there is always a carriage return in front of the prompt..
		
		
		String temp = StringUtils.Replace(m_CmdResponse,m_CurAction.getCommand(),"");		
			
		if(!m_Prompt.isEmpty())
		{
			m_ResultString = StringUtils.Replace(temp,m_Prompt,"");	
		}
		//String temp = StringUtils.Replace(m_CmdResponse,m_Prompt, "");	
		//m_ResultString = StringUtils.Replace(temp,m_Params.getCmd(),"");			
		
	}
	//-------------------------------------------
	private String ReadInputStream()
	{
	  int ch;
	  //Boolean streamReady;
	  StringBuffer input = new StringBuffer();	 
	  String curString = "";	  
	  try
	  {
		 /* This code relies on shell prompt to determine that a command completed.
		  * Potential pitfalls of this approach are:
		  * 1.Somehow we never get a shell prompt. It is unlikely - check out if it is even a possibility
		  * 2.One of the commands in the command file screws up and never returns 
		  * In that case a disconnect should kill the flatt-server connection 
		  * which would in turn kill ssh connectionthat this thread had.
		  *  This would leave a bunch of zombie processes on the host but who cares  
		 * */ 
		  while (IsSSHConnected())
		  {			
			 if(getClientCanceled())
			 {
				break;
			 }
			  while(m_StreamReader.ready())
			  {
				  if((ch = m_StreamReader.read())!=-1)
				  {
				  	input.append((char) ch);		     
				  }
				  else
				  {
					  DEBUG("ReadInputStream: read -1 from stream, breaking");
					  break;
				  }
			  }			 			  
			  //Stream not ready - see what we got so far
			  curString = input.toString();		
			  if(!curString.isEmpty())
			  {
				 //see if we got prompt. If not - get it
				  if(m_Prompt.isEmpty())
				  {
					  GetShellPrompt(curString);						
				  }			    
				  /* If we have the prompt in the input - we're done ,
				   * whatever shell was doing, is done and it is waiting
				   * for input
				   */	
				  if(ContainsPrompt(curString) 			|| 
					 ContainsPasswordPrompt(curString)	||
					 (this.m_BreakOnNL && curString.endsWith("\n")))
				  {
					  DEBUG("Found prompt, password prompt or new line, breaking");
					  break; 
				  }
			  }			  
			  /* input string does not contain prompt and stream is not ready..
			   * sleep and try again 
			   * */
			 DEBUG("Waiting for stream to be ready");
			 Thread.sleep(SLEEP_MS);
		 }			 		  
	  }
		 
	  catch(Exception ex)
	  {
		  AppLog.LogIt("SSHShellExec: Exception in ReadInputStream, cur string = "+ curString + ", Message:"+ex.getMessage(),  
				  		AppLog.LOG_LEVEL_ERROR, 
				  		AppLog.LOGFLAGS_ALL);
	  }	  
	  return curString;
	}
	//------------------------------------------------
	// when shell connection is established, the remote system
	// prints a welcome string and shell prompt which is the last thing
	// that it should print. We grab that  prompt and save it so it can be removed from the
	// output 
	private void GetShellPrompt(String loginStr)
	{
		m_Prompt = "";
		int len = loginStr.length();
		// if there is a shell prompt char - find last cr
		// the prompt should be between cr and prompt char
		if(ContainsPrompt(loginStr))
		{
			int pos = loginStr.lastIndexOf("\n");
			if(pos >=0)
			{
				m_Prompt = loginStr.substring(pos+1,(len));
			}		
		}
	}

	//-------------------------------
	@Override
	/* This subclass just needs to save the new file path of the command file. 
	 * Newline is important! without it it won't execute
	 */
	protected void UpdateRemoteCommand(String execPath)
	{
		m_CurAction.setCommand(execPath);
	}
	//----------------
	// A generic routine to execute a command with no output.
	// TODO: add the following logic:
	// If response contains a newline character - send it back
	// If it contains a password prompt - send pasword
	// if it contains shell prompt - return - we're done
	protected String ExecuteRemoteCommand(String cmd, Boolean clientCanceled)throws Exception
	{
		String strCmd = cmd + "\n";
		m_CmdResponse = "";
		byte[] cmdBytes = strCmd.getBytes();
		
		// don't bother if not connected
		if(IsSSHConnected() && !clientCanceled)
		{			
			try
			{
				m_Shell.getOutputStream().write(cmdBytes, 0, cmdBytes.length);		
				m_Shell.getOutputStream().flush();
				// now read output
				// avoid getting stuck on bad input and on client disconnect
				while(IsSSHConnected() && !clientCanceled)
				{				
					
					/* ReadInputStream will return if
					 * prompt or password were encountered.
					 * If plugin is continuous  it will also return if the last character of
					 * input contains a new line
					 */
					m_CmdResponse = ReadInputStream();
					// not a real time plugin - break and return. We got all the output.
					if(!m_Params.getIsRealTime())
					{					
						break;
					}
					// This is a countinuous plugin that wants to send data in real time
					// Check if response contains prompt or password prompt.
					// If found - break out - either need to handle the password or
					// no more data is available ( response contains prompt)
					// If none of that is true - ReadInputStream returned because a newline
					// char was encountered. Clean the response and send to client
					if(m_CmdResponse.isEmpty() || ContainsPrompt(m_CmdResponse) || ContainsPasswordPrompt(m_CmdResponse))
					{
						break;
					}
					/* one last check if we're connected */
					if(IsSSHConnected() && !clientCanceled)
					{
						CleanupExecResponse();		
												
						//m_ResponseObj.SetData(getResultString());
						if(!m_ResponseObj.SendResponse(m_CmdSeqNum,
												   getHostAddr(),
												   getResultString(),
												   SSHJResponse.STATUS_OK,
												   SSHJResponse.RESP_TYPE_NORMAL,
												   m_HostIndex))
						{
							DEBUG("SSHShellExec #" +Integer.toString(m_HostIndex)+ ":SendResponse returned false, breaking");
							break; // sendresponse failed - break
						}
						AppLog.LogIt("sending data chunk "/*+ getResultString()*/,
								  AppLog.LOG_LEVEL_INFO,
								  AppLog.LOGFLAGS_CONSOLE);			

					}
				}				
			}
			catch(Exception e)
			{
				m_CmdResponse = "";
				AppLog.LogIt("SSHShellExec: Exception  in PrepareForExec: " + e.getMessage(), 
						AppLog.LOG_LEVEL_ERROR,  
						AppLog.LOGFLAGS_ALL);				
				e.printStackTrace();
			}
		}		
		return m_CmdResponse;		
	}
	
	//----------------
	// this object always needs to scp the file 
	public Boolean NeedsScp()
	{
		return true;
	}
	
	//------------------------------------------
	// check if command executed successfully
	// TODO: check error stream ??
	private Boolean ExecSuccess(String str)
	{
		return true; 
	}
	//-------------------------
	// hmmm if the word password is legitimately in the output??
	private Boolean ContainsPasswordPrompt(String  str)
	{
		String strLowercase = str.toLowerCase();
		// assume that the colon  and the word "password" in the same string mean a  password prompt
		// also assume that when there is a password prompt there is no shell prompt
		return (strLowercase.contains("sudo") && (strLowercase.contains("password") && strLowercase.contains(":")) && !ContainsPrompt(str));
	}
	//-----------------------------------------
	private Boolean ContainsPrompt(String str)
	{	
		
		int len = str.length();	
		if(m_Prompt.isEmpty())
		{
			return((FindPromptChar('$',str,len)) ||
					((FindPromptChar('#',str,len))||
					((FindPromptChar('>',str,len)))));
		}
		return(str.contains(m_Prompt));
		
		
	}
	
	//-------------------------------------------
	//the assumption is that the last 2 chars are the prompt char followed by a space
	// Is it good enough???
	private Boolean FindPromptChar(char promptChar,String str, int len)
	{				
		Boolean ret =  ((str.charAt(len-1)== 0x20)&& (str.charAt(len-2)== promptChar));	
		//DEBUG("FindPromptChar:Last 2 chars are "+ str.charAt(len-1) + ","+ str.charAt(len-2)+ ", returning " + ret.toString());
		return ret;
	}
	//----------------------------------
	// delete command file. also called from cleanup 
	// If user aborted operation - cmd file will be deleted from cleanup code
	// When calling ExecuteRemoteCommand
	// explicitly set client canceled flag to false - we always want to
	//delete remote command regardless of client connection status
	synchronized private void DeleteCommandFile() 
	{
	 	// never break on  new line during this op
		m_BreakOnNL = false;
		// no reason to try deleting the command if ssh is not connected
		if(!m_CmdFileDeleted && IsSSHConnected())
		{
			try
			{
				
				AppLog.LogIt("***Deleting Command file on host "+ this.m_Params.getHostAddr(m_HostIndex),
							  AppLog.LOG_LEVEL_INFO,
							  AppLog.LOGFLAGS_CONSOLE);			
				
				// If plugin is executing in real time need to send  
				//  a ctrl c (break character ETX ASCII 003) 
				// (interrupt) signal to shell to stop execution
				//if(m_Params.getIsRealTime())
				{					
					ExecuteRemoteCommand("\003",false);
				}				
				if(!ExecSuccess(ExecuteRemoteCommand(REMOVE_SELF_CMD + m_CurAction.getCommand() ,false)))
				{
					// Don't set deleted flag to give it another shot - 
					//this code is called from exec obj cleanup and from connection obj cleanup
					// on abort - it is  called one extra time
					AppLog.LogIt("SSHShellExec: Cannot delete command: " + m_CurAction.getCommand(),
					      AppLog.LOG_LEVEL_WARNING, 
					      AppLog.LOGFLAGS_ALL);					
				}
				else
				{						
					m_CmdFileDeleted = true;
					// if we don't do  this - the shell disconnects too quickly and the file is not deleted
					MiscUtils.Sleep(500);
				}
			}
			catch(Exception e)
			{
				AppLog.LogIt("DeleteCommandFile: exception ," + e.getMessage(),
						AppLog.LOG_LEVEL_WARNING, 
						AppLog.LOGFLAGS_ALL);
			}
		}		
	}
	//-----------------------------
	// m_IgnoreClientCancel is set to true when deleting remote command file
	/*@Override
	public Boolean getClientCanceled()
	{
		return (super.getClientCanceled());
	}*/
	
	
	
	
	
	
}
