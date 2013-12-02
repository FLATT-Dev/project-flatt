/*******************************************************************************
 * JSSHServer.java
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

import java.net.*;
import java.io.*;

import javax.net.ssl.SSLServerSocket;
import javax.net.ssl.SSLServerSocketFactory;
import com.FLATT.Utils.*;


/* SSH proxy server class. Listen for incoming connections
 * Extract ssh parameters (host, username, etc )
 * Connect to host and execute a command
 * Return result of command to the client and disconnect
 * Realtime is not supported yet
 */
public class JSSHServer 
{
	private ServerSocket m_Listener = null;
	private JSSHProxyParams m_CmdLineParams = null;
	
	public JSSHServer() 
	{
		
	}
	// server main entry point
	public void Run()
	{
		try
		{
			StartServer();
			Socket sock = null;		
			int seqNum = 1;
			// if listener is null this will throw
			AppLog.LogIt("Simulation mode " +
						 (this.m_CmdLineParams.getSimulationMode() ? "on" : "off"), 
						 AppLog.LOG_LEVEL_ALWAYS,
						 AppLog.LOGFLAGS_ALL);
			while(true)
			{
				sock = m_Listener.accept();
				JSSHConnection connection = new JSSHConnection(sock,m_CmdLineParams);
				AppLog.LogIt("********Connection # "+ Integer.toString(seqNum) + " **********",
						 	AppLog.LOG_LEVEL_INFO,
						 	 AppLog.LOGFLAGS_CONSOLE);	
				
				seqNum+=1;
				//Thread connThread = new Thread(connection);
				//connThread.start();	
				connection.start();
			}
		}
		catch(Exception ex)
		{
			AppLog.LogIt("JSSHServer:Exception caught in JSSHServer: " + ex.getMessage(),
							AppLog.LOG_LEVEL_ERROR,
							AppLog.LOGFLAGS_ALL);
		}
	}
	//------------------------------
	void StartServer() throws Exception
	{
		
		// If port provided - use it otherwise look for the first available
		int initialPort = m_CmdLineParams.getPort();
		
		m_Listener = CreateServerSocket(m_CmdLineParams.getPort());
		
		if(m_Listener!=null)
		{
			int listenerPort = m_Listener.getLocalPort();
			
			AppLog.LogIt("ssh proxy server is listening for connections on  port " + 
					Integer.toString(listenerPort),			
					 AppLog.LOG_LEVEL_INFO,
					 AppLog.LOGFLAGS_ALL);
			
			/* if the assigned listener port is not the same as the port we got on the command line this means
			 * app was started without --port parameter, we got assigned a port by the OS and 
			 * need to save it to a file
			 */
			if(listenerPort!= initialPort )
			{
				SavePort(listenerPort);
			}
		}
		else
		{
			 AppLog.LogIt("JSSHServer: Cannot start server on port  " + 
						 	Integer.toString(m_CmdLineParams.getPort()), 
						 	AppLog.LOG_LEVEL_ERROR,
						 	AppLog.LOGFLAGS_ALL);					
		}
		
		
		/* TODO:Delete
		else
		{						
			//for(i = JSSHProxyParams.PORT_MIN; i< JSSHProxyParams.PORT_MAX; ++ i)
			while (true)
			{
				// try to bind to a port				
				m_Listener = CreateServerSocket(0);
				if(m_Listener!=null)
				{					
					break;
				}			
				else
				{
					AppLog.LogIt("Failed to bind to port "+ Integer.toString(i)+ " ,continuing bind attempts",
								AppLog.LOG_LEVEL_WARNING,
								AppLog.LOGFLAGS_ALL);
				}
			}
		}
		*/
		// Only save port when running standalone 
		
		
	}
	
	//------------------------------
	void SavePort(int portNum)
	{
		try
		{
			
			String tempDir = MiscUtils.GetSystemTempDirPath(true);// print on what os we're running
			// assumes that there is a file separator at the end of directory path
			// add if  not there . Looks like on linux it's not added
			AppLog.LogIt("Temp dir path = " + tempDir,
						  AppLog.LOG_LEVEL_INFO,
						  AppLog.LOGFLAGS_ALL);			
			
			File temp =  new File(tempDir+"jsshproxyport.txt");
			temp.deleteOnExit();
			BufferedWriter out = new BufferedWriter(new FileWriter(temp));
		    out.write(Integer.toString(portNum));
		    out.close();
		    AppLog.LogIt("JSSHServer: Saved port number "+  Integer.toString(portNum) + "  to  " + temp.getAbsolutePath(), 
			    		AppLog.LOG_LEVEL_INFO,
			    		AppLog.LOGFLAGS_ALL);	
			
		}
		catch(Exception e)
		{
			AppLog.LogIt("JSSHServer: Failed to save port number to temp file : " + e.getMessage(),
						AppLog.LOG_LEVEL_ERROR,
						AppLog.LOGFLAGS_ALL);					
			try
			{
				m_Listener.close();
			}
			catch(Exception ex)
			{
				AppLog.LogIt("JSSHServer: Failed to close listener : " + ex.getMessage(),
							AppLog.LOG_LEVEL_ERROR,
							AppLog.LOGFLAGS_ALL);	
			}			
		}
		
	}
	
	//---------------------------
	
	
	
	//-----------------------------------------
	// create a ssl or non ssl server socket
	private ServerSocket CreateServerSocket(int port)
	{
		ServerSocket ret = null;
		
		if(m_CmdLineParams.getUseSSL())
		{
			 try
			 {
				 ret  = (SSLServerSocket)SSLServerSocketFactory.getDefault().createServerSocket(port); 
				
				 /*  http://rgrzywinski.wordpress.com/2004/08/03/dont-forget-to-set-the-cipher-suite/
				 * Use an anonymous cipher suite so that a KeyManager or TrustManager
				 * is not needed
				 * NOTE:  this assumes that the cipher suite is known.  A check -should-
				 *	be done first.	 
				 * The long and short of it is that if you use a default SSLServerSocketFactory and 
				 * create a socket then you must have an anonymous cipher suite installed. 
				 * A unless you do the same on the client side, you will receive the following:
				 * javax.net.ssl.SSLHandshakeException: no cipher suites in common
				 * javax.net.ssl.SSLHandshakeException:Received fatal alert: handshake_failure 
				 */
				
				/* final String[] enabledCipherSuites = { "SSL_DH_anon_WITH_RC4_128_MD5" };
				 ((SSLServerSocket)ret).setEnabledCipherSuites(enabledCipherSuites);*/
			 }
			 catch(Exception e)
			 {
				 AppLog.LogIt("JSSHServer: Exception creating SSLServerSocket: " + e.getMessage(), 
							 AppLog.LOG_LEVEL_ERROR,
							 AppLog.LOGFLAGS_ALL); 
			 }
		}
		else
		{
			 try
			 {
				ret = new ServerSocket(port);
			 }
			 catch(Exception e)
			 {
				 AppLog.LogIt("JSSHServer: Exception creating ServerSocket: " + e.getMessage(), 
							 AppLog.LOG_LEVEL_ERROR,
							 AppLog.LOGFLAGS_ALL); 
			 }
		}
        return ret;
	}
	//-----------------------------------------
	public JSSHProxyParams getCmdLineParams()
	{
		return m_CmdLineParams;
	}
	//-----------------------------------------
	public void setLineParams(JSSHProxyParams mCmdLineParams) 
	{
		m_CmdLineParams = mCmdLineParams;
	}
	//---------------------------------------------------
}
