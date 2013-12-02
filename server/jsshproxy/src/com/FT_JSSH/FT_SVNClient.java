/*******************************************************************************
 * FT_SVNClient.java
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
/* This class invokes an external SVN java application			*/
/* 																*/
/****************************************************************/

package com.FT_JSSH;
import java.io.*;
import java.util.*;
import com.FLATT.Utils.*;


public class FT_SVNClient
{

	private String _resultString="";
	private String _errorString = "";
	private String _svnClientPath;
	Process 	   _svnClientProc;
	//private Boolean _svnClientPathValid = false;
	
	public static final String JSVN_CLIENT_NAME ="ft_svncli.jar";
	public static final String SVN_CMD_NON_INTERACTIVE=" --non-interactive";
	
	// ctor
	FT_SVNClient(String jarDirPath)
	{
		if(StringUtils.IsValidString(jarDirPath))
		{
			_svnClientPath = jarDirPath +JSVN_CLIENT_NAME;
		}
		else
		{
			_svnClientPath = "."+ File.separator+JSVN_CLIENT_NAME;
		}
		//ValidateSvnClientPath();
	}
	//---------------------------------
	// destroy svn client process
	public void Cleanup()
	{
		if(_svnClientProc!=null)
		{
			_svnClientProc.destroy();
		}
	}
	//------------------------------------
	public boolean Execute(String cmds[],String url, ArrayList<String> localPaths,String username, String password)
	{
		
		boolean execSuccess = false;
		int i;
		
		ArrayList<String> cmdLine = new ArrayList<String>();
		cmdLine.add("java");
		cmdLine.add("-jar");
		cmdLine.add(GetSVNClientPath());
		
		// now add all commands that came from the caller
		for(i = 0; i < cmds.length;++i)
		{
			cmdLine.add(cmds[i]);
		}
		if(!url.isEmpty())
		{
			cmdLine.add(url);
		}
		/*localPaths can contain a specific path of repository directory  
		 * or a list of files to perform the operation on or be empty - in that case the operation is 
		 * performed in the current directory
		 * Only double quote paths on windows - on the mac this leads to problems
		 * 
		 */
		String quote = MiscUtils.RunningOnWindows() ? "\"" : "";
		for(i = 0; i < localPaths.size();++i)
		{
			//cmdLine.add("\""+ localPaths.get(i) + "\"");
			cmdLine.add(quote + localPaths.get(i) + quote);
		}
		
		if(!username.isEmpty())
		{
			cmdLine.add("--username");
			cmdLine.add(username);
		}
		if(!password.isEmpty())
		{
			cmdLine.add("--password");
			cmdLine.add(password);
		}
		
		_resultString = ""; //clear from previous executions
		try
		{			
			
			String[] cmdArray =new String[cmdLine.size()];
			cmdLine.toArray(cmdArray);
			
			// TODO keep as debugging for now
			AppLog.LogIt("********SVN_Client:executing command line**********",AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL); 			  		
			AppLog.LogIt(cmdLine.toString(),AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL);
			
			_svnClientProc = Runtime.getRuntime().exec(cmdArray);
			
			_svnClientProc.waitFor();
      	  
      		InputStream errStream = _svnClientProc.getErrorStream();
        	InputStream iStream = _svnClientProc.getInputStream();
        	
        	if(errStream.available()>0)
        	{
        		_errorString = ReadInputStream(errStream);
        	}
        	else if(iStream.available() > 0)
        	{
        		_resultString = ReadInputStream(iStream);
        		execSuccess = true;
        	}
        	else
        	{
        		// no data is not an error - just means that svn has nothing to report
        		// for example on diff command when there are no differences
        		_errorString = "";
        	}         	
		}
		catch(Exception e)
		{
			_errorString = "Exception exectuting JSVN client : " + e.getMessage(); 
			AppLog.LogIt(_errorString,AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);			
		}	
		// set to null - this object only runs once
		_svnClientProc = null;
		//For debugging only
		//AppLog.LogIt("SVN Client result:\n"+(_errorString.isEmpty()? _resultString:_errorString),AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_ALL);
		return execSuccess;
		
	}
	//-------------------------------------
	private String ReadInputStream(InputStream stream)
	{
	  int ch;
	  //Boolean streamReady;
	  StringBuffer input = new StringBuffer();	 
	  	
	  BufferedReader streamReader =  new BufferedReader(new InputStreamReader(stream));  
	  try
	  {		  
		  while(streamReader.ready())
		  {
			  if((ch = streamReader.read())!=-1)
			  {
			  	input.append((char) ch);		     
			  }
			  else
			  {
				  //DEBUG("ReadInputStream: read -1 from stream, breaking");
				  break;
			  }
		  }			 			  			 		  
	  }
		 
	  catch(Exception ex)
	  {
		  /*AppLog.LogIt("SSHShellExec: Exception in ReadInputStream, cur string = "+ curString + ", Message:"+ex.getMessage(),  
				  		AppLog.LOG_LEVEL_ERROR, 
				  		AppLog.LOGFLAGS_ALL);*/
	  }	  
	  return input.toString();
	}
	//--------------------------------
	public String get_resultString()
	{
		return _resultString;
	}
	//--------------------------------
	public void set_resultString(String val)
	{
		_resultString = val;
	}
	//--------------------------------	
	/*private String get_errorString() 
	{
		return _errorString;
	}*/
	public String FormatErrorString()
	{
		String arr[] = _errorString.split("\n");
		String ret =  _errorString;
		if(arr.length > 0)
		{
			ret = arr[arr.length -1];
		}
		return ret;		
	}
	//---------------------------------
	// if the svn operation resuted in success - the error stirng is empty
	public Boolean SvnSuccess()
	{
		return (_errorString.isEmpty());
	}
	//----------------------------------------------
	String GetSVNClientPath()
	{
		String ret = this._svnClientPath;
		try
		{
			File f = new File(_svnClientPath);
			if(f.exists())
			{
				ret = f.getCanonicalPath();
			}
		}
		catch(Exception e)
		{
			AppLog.LogIt("Exception in GetSVNClientPath:" + e.getMessage(), AppLog.LOG_LEVEL_ALWAYS, AppLog.LOGFLAGS_ALL);
		}
		
		//AppLog.LogIt("GetSVNClientPath: returning " + ret, AppLog.LOG_LEVEL_ALWAYS, AppLog.LOGFLAGS_ALL);
		return ret;
	}
	/*
	//--------------------------------
	private Process GetSvnClientProcess(String[] cmdArray)
	{
		Process ret = null;
		
		try
		{			
			if(MiscUtils.RunnningOnMac())
			{
				// on mac - play with environment variables to make sure the ft_svncli app does not pop up in menu bar
				ProcessBuilder pb  = new ProcessBuilder(cmdArray);
				
				
				// TODO: set the terminal to empty,see if this works
				ret = pb.start();
			}
			else
			{				
				ret =  Runtime.getRuntime().exec(cmdArray);			
			}
			
		}
		catch(Exception e)
		{
			
		}
		return ret;
		
	}
	*/
		

}
