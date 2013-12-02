/*******************************************************************************
 * FT_JSVNExec.java
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

import com.FLATT.Utils.*;

public class FT_JSVNExec extends SSHExec
{

	protected static final String CMD_CHECKOUT = "checkout";
	protected static final String CMD_UPDATE = "update";
	protected static final String CMD_LIST = "list";
	protected static final String CMD_FLAG_RECURSIVE= "-R";
	protected static final String CMD_CLEANUP = "cleanup";
	protected static final String CMD_DIFF = "diff";
	protected static final String CMD_STATUS = "status";
	protected static final String CMD_COMMIT = "commit";
	protected static final String CMD_LOG = "log";
	protected static final String CMD_FLAG_MSG= "-m"; // message for the checkin
	protected static final String CMD_FLAG_VERBOSE= "-v";
	protected static final String CMD_ADD = "add";
	protected static final String CMD_DELETE="delete";
	protected static final String CMD_REVERT="revert";
	

	// used only for update and checkout operations
	//protected  ArrayList<String> _localPaths = new ArrayList<String>();
	
	//String username = "";//"heelcurve5@gmail.com"
	//String password = "";//Qc3zA3DB7WA7"; 
	//String module = "flatt-actions";//"facebook-actionscript-api-read-only";
	//String _checkoutCmd = //CMD_CHECKOUT;
	//String url =  "https://flatt-actions.googlecode.com/svn/";
	//"http://facebook-actionscript-api.googlecode.com/svn/trunk/";
	// if no module was provided- use this directory as a starting point

	private FT_SVNClient _svncli;
	
	public FT_JSVNExec(JSSHProxyParams params,JSSHConnection parent) 
	{
		super(params,parent);
		// TODO Auto-generated constructor stub
	}
	//---------------------------
	//Return true to satisfy parent requirements - 
	@Override
	public Boolean Connect()
	{		
		return true;
	}
	//---------------------------
	@Override
	public Boolean Execute(Boolean disconnectOnCompletion,Boolean readLoginPrompt)
	{
		boolean ret = true;
		try
		{
			_svncli = new FT_SVNClient(m_Params.GetJarDirPath());
			
			int reqType = m_Params.get_SvnRequest().get_requestType();	
			
				
			switch(reqType)
			{
				case FT_SvnRequest.SVNREQ_CHECKOUT:
				case FT_SvnRequest.SVNREQ_UPDATE:
					HandleUpdate();
					break;		
				case FT_SvnRequest.SVNREQ_ADD:
					HandleAdd();
					break;
				case FT_SvnRequest.SVNREQ_COMMIT:
					SvnExec_Cleanup();
					HandleGenericReq(CommandFromReqType(reqType));
					break;
				case FT_SvnRequest.SVNREQ_DELETE:
					HandleDelete();
					break;
				default:
					HandleGenericReq(CommandFromReqType(reqType));
					break;
			}
		}
		catch(Exception e)
		{
			ret = false;
		}
		
		finally
		{
			try
			{
				// always create svn response, the other side expects something
				CreateSvnResponse();
				AppLog.LogIt("Sending "+m_ResultString,AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_CONSOLE);	    		
				m_ResponseObj.SendResponse(-1,
										"",
										m_ResultString,
										SSHJResponse.STATUS_OK,
										SSHJResponse.RESP_TYPE_SVNREQ,
										-1);
			}
			catch(Exception e)
			{
				AppLog.LogIt("FT_JSVNExec:Execute - Exception sending response : "+e.getMessage() ,
													AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);	
			}
		}
			
		return ret;
	}
	// this object never needs scp
	@Override
	public Boolean NeedsScp()
	{
		return false;
	}	
	
	//---------------------------------------------
	private void HandleUpdate()
	{
		// on checkout we need to build the top level directory from URL
		// 
		int reqType = m_Params.get_SvnRequest().get_requestType();
				
		// on update the top level dir path should be sent by the client. 
		// A list of files and directories may also be sent on update
		// If  top level dir path is prsent, paths to individual files and directories are ignored
		String localRepoPath = m_Params.get_SvnRequest().get_topLevellDir();			
						
		ArrayList<String> localPaths;
		
		// If there is a top level directory - use it , otherwise use 
		// a list of provided files.
		if(localRepoPath.isEmpty())
		{
			localPaths = m_Params.get_SvnRequest().get_localPaths();
		}
		else
		{
			localPaths = new ArrayList<String>();
			localPaths.add(localRepoPath);
		}	
		
		boolean updateRes =  SvnExec_Update(localPaths);			
		if(!updateRes)
		{			
			SvnExec_Cleanup();
			updateRes = SvnExec_Update(localPaths);// does both update and checkout
		}
		/* Will be handled in the client. TODO: Delete
		// return a list of files only on checkout.
		// Otherwise return whatever svn returned*/
		if(updateRes && (reqType == FT_SvnRequest.SVNREQ_CHECKOUT || reqType == FT_SvnRequest.SVNREQ_UPDATE))
		{
			// success - create a list of files
			SvnExec_List(localPaths);							
		}
				
	}
	//---------------------------------------------	
	public boolean SvnExec_Update(ArrayList<String> localPaths)
	{
		int reqType = m_Params.get_SvnRequest().get_requestType();
		String url = m_Params.get_SvnRequest().get_url();
		// URL is not needed on update, only on checkout
		if(reqType == FT_SvnRequest.SVNREQ_UPDATE)
		{
			url = "";
		}
		// save the full module path on local file system
		//_svncli.set_modulePath(moduleDirFileObj.getAbsolutePath());
		return _svncli.Execute(CommandFromReqType(reqType),
								url,
								localPaths,
								m_Params.get_SvnRequest().get_username()
								,m_Params.get_SvnRequest().get_password());
			
	}
	//-------------------------------------------------
	protected boolean SvnExec_List(ArrayList<String> localPaths)
	{		
		return (_svncli.Execute(new String[] {CMD_LIST,CMD_FLAG_RECURSIVE} ,"",localPaths, "",""));						
	}
	//-------------------------------------------------
	protected boolean SvnExec_Cleanup()
	{		
		// always do cleanup on root directory
		// assumes that the client always sends it
		String localRepoPath = m_Params.get_SvnRequest().get_topLevellDir();
		if(!localRepoPath.isEmpty())
		{
			ArrayList<String> paths = new ArrayList<String>();	
			paths.add(localRepoPath);
			// excec wants an array of paths
			return (_svncli.Execute(new String[] {CMD_CLEANUP} ,"",paths, "",""));	
		}
		return false;	
		
											    
	}
	//----------------------------------
	protected String ParseFileList()
	{
						
		String[] arr = _svncli.get_resultString().split("\n");
		String repoPath = m_Params.get_SvnRequest().get_topLevellDir();
		
		if(!repoPath.isEmpty())
		{
			if(!repoPath.endsWith(File.separator))
			{
				repoPath+=File.separator;
			}
		}		
		String res = "";
		if(arr.length > 0)
		{
			// if we got at  least 1 file (which we should) 
			// parse and return the list
			// otherwise resultString of the svn client contains an error
			// and we'just passing it to the client.
			for(int i = 0; i < arr.length;++i)
			{
							
				File f = new File(repoPath +arr[i]);
				if(f.exists() && f.isFile())
				{
					res+=f.getAbsolutePath()+"\n";
				}
			}
		}
		else
		{
			res = _svncli.get_resultString();
		}
		return res;
	}
	
	//-------------------------------------
	/* SvnResponse echoes the request type and has either data
	 *  from the svn client - i.e what svn client returned on command line
	 * or already parsed list
	 */
	protected void CreateSvnResponse()
	{
		String svnData = "";
		int reqType = m_Params.get_SvnRequest().get_requestType();
		
		String preamble = "<RepoResponse type=\""				+ 
							Integer.toString(reqType) 			+
							"\" result=\"" 					  	+ 
							(_svncli.SvnSuccess()?  "1": "0") 	+ 
							"\">";
		
		if(_svncli.SvnSuccess())
		{
				
			switch(reqType)
			{
				case FT_SvnRequest.SVNREQ_CHECKOUT:
				case FT_SvnRequest.SVNREQ_UPDATE:
					svnData=ParseFileList();
					break;
				default:
					/* For now for everything else - just get the output of the svn client */
					svnData = _svncli.get_resultString();
					break;
			}	
		}
		else
		{
			svnData = _svncli.FormatErrorString();
		}
			  
	 	m_ResultString = preamble +  "<RepoData>"+ StringUtils.Base64Encode(svnData) + "</RepoData>";
	 	// add more tags here as needed.
	  	m_ResultString+="</RepoResponse>";
	}
	//-------------------------------------------------------
	/* build the root path for the repository on the local computer from URL
	*/
	protected String RootDirFromURL()
	{
		String ret = m_Params.get_SvnRequest().get_topLevellDir();
		if(!ret.endsWith(File.separator))
		{
			ret+=File.separator;
		}
		String url =  m_Params.get_SvnRequest().get_url();
		
		if(!url.isEmpty())
		{
			// Strip everything but the domain name or ip addrss. this becomes our directory name
			// for the local directory
			ret+=StringUtils.CleanupUrl(url);
		}
		return ret;
	}
	/*--------------------------------------------*/
	//common code that handles requests that do not reqire any special processing of the response
	
	protected void HandleGenericReq(String[] cmds)
	{
		/* For all commands handled here  url is not needed. 
		 * but the file list is needed
		 */		
		_svncli.Execute(cmds, // commands
						"",   // url
						m_Params.get_SvnRequest().get_localPaths(),
						 m_Params.get_SvnRequest().get_username()
						,m_Params.get_SvnRequest().get_password());
	}
	
	//---------------------------------------
	private String[] CommandFromReqType(int reqType)
	{		
		switch(reqType)
		{
			case FT_SvnRequest.SVNREQ_CHECKOUT:
				return  (new String[]{CMD_CHECKOUT});
			case FT_SvnRequest.SVNREQ_UPDATE:
				return  (new String[]{CMD_UPDATE});
			case FT_SvnRequest.SVNREQ_DIFF:
				return  (new String[]{CMD_DIFF});
			case FT_SvnRequest.SVNREQ_COMMIT:	
			 // commit requires a -m flag with a message amd a list 			 
				return  PrepareCommitCmd();		
			case FT_SvnRequest.SVNREQ_LOG:
				return (new String[]{CMD_LOG});	//PrepareLogCmd();	-- maybe  in the future use with -v flag
			case FT_SvnRequest.SVNREQ_STATUS:
				return (new String[]{CMD_STATUS});	
			case FT_SvnRequest.SVNREQ_ADD:
				return (new String[]{CMD_ADD});	
			case FT_SvnRequest.SVNREQ_DELETE:
				return (new String[]{CMD_DELETE});
			case FT_SvnRequest.SVNREQ_REVERT:
				return (new String[]{CMD_REVERT});				
		}
		
		return new String[]{""};
	}
	//--------------------------------------------------
	// add the list of files to commit and the message
	private String[] PrepareCommitCmd()
	{
		ArrayList<String> cmds = new ArrayList<String>();
		// quote checkin message
		String msg = m_Params.get_SvnRequest().get_checkinMsg();
		if(msg.isEmpty())
		{
			String userName = m_Params.get_SvnRequest().get_username();
			if(userName.isEmpty())
			{
				userName = MiscUtils.GetLocalUserName();
			}
			// add machine name 
			msg = "Committed by " + userName +" on " + MiscUtils.GetLocalHostName();			
		}
		
		String strCheckinMsg = "\"" + msg +"\"";
		
		cmds.add(CMD_COMMIT);
		cmds.add(CMD_FLAG_MSG);
		cmds.add(strCheckinMsg);
		
		// so clunky.. why cant i just return an array of strings 
		String[] ret = new String[cmds.size()];
		cmds.toArray(ret);
		return ret;				
	}
	//---------------------------------------------
	private String[] PrepareLogCmd()
	{
		ArrayList<String> cmds = new ArrayList<String>();
		cmds.add(CMD_LOG);
		cmds.add(CMD_FLAG_VERBOSE);
		// so clunky.. why cant i just return an array of strings 
		String[] ret = new String[cmds.size()];
		cmds.toArray(ret);
		return ret;		
	}
	//-----------------------------------
	// Handle Add request. First Add then commit
	// always do a cleanup first just in case
	private void HandleAdd()
	{
		// always clean up before add and commit just in case
		SvnExec_Cleanup();
		if(_svncli.Execute(CommandFromReqType(FT_SvnRequest.SVNREQ_ADD), 
						"",   // url
						m_Params.get_SvnRequest().get_localPaths(),
						 m_Params.get_SvnRequest().get_username()
						,m_Params.get_SvnRequest().get_password()))
		{
			HandleGenericReq(CommandFromReqType(FT_SvnRequest.SVNREQ_COMMIT));
		}
	}
	//------------------------------------------------------
	// Delete request. First Delete then commit
	// Always do cleanup just in case
	private void HandleDelete()
	{
		// always clean up before add and commit just in case
		SvnExec_Cleanup();
		if(_svncli.Execute(CommandFromReqType(FT_SvnRequest.SVNREQ_DELETE), 
						"",   // url
						m_Params.get_SvnRequest().get_localPaths(),
						 m_Params.get_SvnRequest().get_username()
						,m_Params.get_SvnRequest().get_password()))
		{
			// TODO: this will change when we allow user  to enter messages for commit
			// for now just set the message to something generic , indicating a delete commit
			String userName = m_Params.get_SvnRequest().get_username();
			if(userName.isEmpty())
			{
				userName = MiscUtils.GetLocalUserName();
			}
			// add machine name 
			userName += " on " + MiscUtils.GetLocalHostName();
			String checkinMsg = userName + " deleted ";
			for(int i=0; i < m_Params.get_SvnRequest().get_localPaths().size(); ++i)
			{
				checkinMsg+=(m_Params.get_SvnRequest().get_localPaths().get(i)+"\n");
			}
			m_Params.get_SvnRequest().set_checkinMsg(checkinMsg);
												 
			HandleGenericReq(CommandFromReqType(FT_SvnRequest.SVNREQ_COMMIT));
		}
	}
	//-----------------------------------------------
	@Override
	public void Cleanup(boolean isFinal)
	{
		if(_svncli!=null)
		{
			_svncli.Cleanup();
		}
	}
	

}//end class
