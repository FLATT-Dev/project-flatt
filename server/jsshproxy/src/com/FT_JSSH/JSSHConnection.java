/*******************************************************************************
 * JSSHConnection.java
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
import java.net.*;
import java.util.*;
import java.util.concurrent.*;
import org.slf4j.LoggerFactory;
import com.FLATT.Utils.*;


public class JSSHConnection extends Thread 
{
	
	protected JSSHProxyParams _xmlParams;
	protected Socket m_Socket;
	protected SSHExec m_ExecObj = null;
	//ArrayList<SSHExec> m_ExecObjs;
	protected ConcurrentHashMap<String,SSHExec>m_ExecObjsMap;
	protected JSSHConnectionMonitor m_ConnMon;
	public static final int EOT = 3;
	public static final String SSH_REQ_END = "</SSHRequest>";
	protected Boolean _aborted = false;
	protected String  _fatalError = "";
	protected SSHJResponse  _responseObj;
	protected int 		_numCompleted = 0;
	protected FT_Admin	_adminObj;

	//-----------------------------
	// TODO - DELETE
	/*public class JSSHConnectionExceptionHandler implements Thread.UncaughtExceptionHandler 
	{
	  public int _objectIndex = -1;
	 
	  public void uncaughtException(Thread t, Throwable e) 
	  {
		 	String msg = e.getMessage();
			AppLog.LogIt("Uncaught exception in JSSHConnection:" + msg,
							AppLog.LOG_LEVEL_INFO,
							AppLog.LOGFLAGS_CONSOLE);	
			if(msg == null || msg.isEmpty())
			{
				e.printStackTrace();
			}
	  }
	}*/
	public JSSHConnection()
	{	
		/* this supresses messages from the logger:
		 * SLF4J: The following loggers will not work because they were created during 
		 * the default configuration phase of the underlying logging system.
		 */
		LoggerFactory.getLogger("ROOT");
	}
	//----------------------------------
	JSSHConnection(Socket sock,JSSHProxyParams cmdLineParams) 
	{
		// these params com from the client
		_xmlParams = new JSSHProxyParams(cmdLineParams.GetJarDirPath());
		// copy the command line values from cmdLine params object
		// come of them are relevant to execution i.e whether we're in simulation mode
		_xmlParams.CopyCmdLineParams(cmdLineParams);
		m_Socket = sock;
		_responseObj = new SSHJResponse(m_Socket);		
	}

	// main thread entry point
	public void run()
	{
		
		try 
		{

			String input = "";
			String returnData = ""; // this is what the client will display

			// this response object is used by v 1 and to send an error response
			// in case of malformed xml request

			// set up keep alive for the socket
			ConfigureKeepAlive();
			
			AppLog.LogIt("JSSHConnection:Started " ,
						AppLog.LOG_LEVEL_INFO, 
						AppLog.LOGFLAGS_CONSOLE);
			// Get input from the client
			BufferedReader br = (m_Socket == null ? null : new BufferedReader(new InputStreamReader(m_Socket.getInputStream())));
					
			input = ReadInput(br);			
			
			AppLog.LogIt("JSSHConnection:Got request,size = " + input.length(),
							AppLog.LOG_LEVEL_INFO, 
							AppLog.LOGFLAGS_ALL);

			// Initialize response object with the output stream.
			// It is used for v 1 and for
			// reporting malformed xml request.
			// V2 makes a copy for each exec thread.
			if (_xmlParams.ParseXMLParams((input))) 
			{
				AppLog.LogIt("JSSHConnection:Parsed params, starting execution",
							AppLog.LOG_LEVEL_INFO, 
							AppLog.LOGFLAGS_CONSOLE);
				switch (_xmlParams.getRequestVersion()) 
				{
					case JSSHProxyParams.FT_REQ_VERSION_1:
						HandleVersion1Processing(br);
						break;

					case JSSHProxyParams.FT_REQ_VERSION_2:
						HandleVersion2Processing(br);
						break;
				}
			} 
			else 
			{
				// problem parsing parameters
				//responseObj.SetStatus(SSHJResponse.STATUS_ERR);
				AppLog.LogIt("JSSHConnection:Error parsing request",
						AppLog.LOG_LEVEL_INFO, 
						AppLog.LOGFLAGS_ALL);
				returnData = "Failed to execute command: malformed request";
				// dont send anything if the socket is closed or there is no
				// data to send
				// - this may be the case if user canceled
				//responseObj.SetData(returnData);
	
				_responseObj.SendResponse(-1, 						// cmdSeqNum,
										  "",						// hostAddr 
										  returnData, 				// data
										  SSHJResponse.STATUS_ERR,	// status
										  SSHJResponse.RESP_TYPE_FIN, // response type
										 -1);								// unused host addr parameter
			}

		} 
		catch (IOException ioe) 
		{
			AppLog.LogIt("IOException on socket listen: " + ioe.getMessage(),
					AppLog.LOG_LEVEL_ERROR, 
					AppLog.LOGFLAGS_ALL);
			ioe.printStackTrace();
		} 
		finally
		{
			try 
			{
				
				// since everything is driven by the connection monitor, it will
				// do the cleanup
				/*
				 * if (m_ConnMon!=null) { m_ConnMon.SetDone(); } Cleanup();
				 */
				if (m_ConnMon!=null) 
				{
					 m_ConnMon.SetDone();
			    } 
			    Cleanup();
			} 
			catch (Exception e)
			{
				AppLog.LogIt("Exception in JSSHConnection:finally\n ",
						AppLog.LOG_LEVEL_ERROR, 
						AppLog.LOGFLAGS_ALL);
			    e.printStackTrace();
			}
		}
		
		AppLog.LogIt("JSSConnection:Completed", AppLog.LOG_LEVEL_INFO, AppLog.LOGFLAGS_CONSOLE);

	}

	// --------------------------------------------------------

	public void Cleanup() throws Exception 
	{
		switch (_xmlParams.getRequestVersion()) 
		{
			case JSSHProxyParams.FT_REQ_VERSION_1:
				CleanupV1();
				break;
			case JSSHProxyParams.FT_REQ_VERSION_2:
				CleanupV2();
				break;
			default:
				CleanupV1();
				break;
		}	
		
	}

	// ---------------------------------------------------
	protected void CleanupV1() 
	{

		try 
		{
			if (m_ExecObj != null) 
			{
				m_ExecObj.Cleanup(true);
			}
			CloseConnection();

		} 
		catch (Exception e) 
		{
		}
	}

	// --------------------------------------------
	protected void CloseConnection() throws Exception 
	{
		if ((m_Socket != null) && (!m_Socket.isClosed()))
		{
			try
			{
				
				if(!_fatalError.isEmpty())
				{					
					_responseObj.SendResponse(-1, 			// cmdSeqNum,
								  "",							// hostAddr 
								  _fatalError, 					// data
								  SSHJResponse.STATUS_ERR,		// status
								  SSHJResponse.RESP_TYPE_FIN, 	// response type
								 -1);							// unused host addr parameter
										
				}
				
				m_Socket.close();
				m_Socket = null;				
				AppLog.LogIt("JSSHConnection:Closed connection to client",
								AppLog.LOG_LEVEL_INFO,
								AppLog.LOGFLAGS_CONSOLE);
			}
			catch(Exception e)
			{
				AppLog.LogIt("JSSHConnection:Exception closing connection to socket",AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_CONSOLE);
			}
		}
	}

	// ----------------------------------------------
    protected void CleanupV2() 
	{
		
		try 
		{
			CloseConnection();
		}
		catch (Exception e) 
		{
		}
	
		if(m_ExecObjsMap!=null)
		{
			Collection<SSHExec>execObjs = m_ExecObjsMap.values();
			Iterator<SSHExec> iter = execObjs.iterator();
			
			while(iter.hasNext())
			{
				/* This is a final cleanup of this object
				 * Do whatever needs to be done only once 
				 */
				iter.next().Cleanup(true);				
			}
			// before clearing the map and losing all objects, clean up the admin object
			if(_adminObj!=null)
			{
				_adminObj.Cleanup();
			}
			//now that the admin object is done - clear the map
			m_ExecObjsMap.clear();	
		}
		// also cleanup proxyparams object - it may have created some temp ssh key files
		if(_xmlParams!=null)
		{
			_xmlParams.Cleanup();
		}
		AppLog.LogIt("JSSHConnection:Cleanup done",AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_CONSOLE);		
		_responseObj.Cleanup();
	}

	// --------------------------------
	public void Abort() throws Exception 
	{
		switch (_xmlParams.getRequestVersion()) 
		{
			case JSSHProxyParams.FT_REQ_VERSION_1:
				AbortV1();
				break;
	
			case JSSHProxyParams.FT_REQ_VERSION_2:
				AbortV2();
				break;
			default:
				AbortV1();
				break;
		}
		_aborted = true;
		AppLog.LogIt("JSSHConnection:Setting abort flag",AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_CONSOLE);		
	}

	// ------------------------------------
	protected void AbortV1() 
	{
		try 
		{
			if (m_ExecObj != null) 
			{
				m_ExecObj.setClientCanceled(true);
				Cleanup();
			}
		} 
		catch (Exception e) 
		{

		}
	}

	// ------------------------------------
	protected void AbortV2() 
	{
		try 
		{
			
			if(m_ExecObjsMap!=null)
			{
				Collection<SSHExec>execObjs = m_ExecObjsMap.values();
				Iterator<SSHExec> iter = execObjs.iterator();
				
				while(iter.hasNext())
				{					
					iter.next().setClientCanceled(true);
				}
			}
			/*for (int i = 0; i < m_ExecObjs.size(); ++i) 
			{
				m_ExecObjs.get(i).setClientCanceled(true);
			}*/
			Cleanup();
		} 
		catch (Exception e) 
		{

		}
	}

	// ---------------------------

	/*
	 * For now just set it .. In the future may need to tweak the keepalive
	 * value with socket options When the keepalive option is set for a TCP
	 * socket and no data has been exchanged across the socket in either
	 * direction for 2 hours (NOTE: the actual value is implementation
	 * dependent), TCP automatically sends a keepalive probe to the peer. This
	 * probe is a TCP segment to which the peer must respond. One of three
	 * responses is expected: 1. The peer responds with the expected ACK. The
	 * application is not notified (since everything is OK). TCP will send
	 * another probe following another 2 hours of inactivity. 2. The peer
	 * responds with an RST, which tells the local TCP that the peer host has
	 * crashed and rebooted. The socket is closed. 3. There is no response from
	 * the peer. The socket is closed. The purpose of this option is to detect
	 * if the peer host crashes. Valid only for TCP socket: SocketImpl
	 */
	protected void ConfigureKeepAlive() throws IOException 
	{
	
		// AppLog.LogIt("Current keepalive setting: "+
		// m_Socket.getKeepAlive());
		if(m_Socket!=null)
		{
			m_Socket.setKeepAlive(true);
		}

	}

	// -----------------------------------
	private void HandleVersion1Processing(BufferedReader br) 			
	{
		/* TODO: fix - maybe not needed at all anymore
		String returnData = ""; // this is what the client will display
		String returnStatus = SSHJResponse.STATUS_OK;
		
		try 
		{
			Boolean canProceed = true;
			m_ExecObj = SSHExec.GetSSHExecObject(_xmlParams);

			if (m_ExecObj.Connect()) 
			{
				// start connection monitor
				m_ConnMon = new JSSHConnectionMonitor(this, br, responseObj);
				Thread connThread = new Thread(m_ConnMon);
				connThread.start();

				// is it a multiline command ?
				// if so, scp it to remote host to temp dir
				// and execute it,then delete

				if (m_ExecObj.NeedsScp()) 
				{
					AppLog.LogIt(
							"JSSHConnection:Multiline command,copying to remote host ",
							AppLog.LOG_INFO, true);
					canProceed = m_ExecObj.CopyCommandToRemoteHost();
				}
				// dump output on command line
				AppLog.LogIt("JSSHConnection:Executing command",
						AppLog.LOG_INFO, true);
				// Set the response object in case this is a continouts plugin
				m_ExecObj.setResponseObj(responseObj);
				// OK here we go
				if (canProceed && m_ExecObj.PrepareForExec()
						&& m_ExecObj.Execute(true, true)) // disconnectOnCompletion,readLoginPrompt
				{
					// response object status is OK by default
					returnData = m_ExecObj.getResultString();
				} 
				else 
				{
					// If command returns an error, result string contains error
					// description.
					responseObj.SetStatus(SSHJResponse.STATUS_ERR);
					returnData = "Failed to execute remote command. "
							+ m_ExecObj.getResultString();
				}
			} 
			else 
			{
				// cannot connect to host
				responseObj.SetStatus(SSHJResponse.STATUS_ERR);
				returnData = m_ExecObj.getResultString();
			}
			AppLog.LogIt("JSSHConnection: Printing Execution result:"
					+ AppLog.g_LineSepartator + " " + returnData,
					AppLog.LOG_INFO, true);

			m_ExecObj = null;// set to null so we don't attempt to clean it up
		} 
		catch (Exception e) 
		{
			responseObj.SetStatus(SSHJResponse.STATUS_ERR);
			returnData = "Failed to connect to host "
					+ _xmlParams.getHostAddr(-1);
			AppLog.LogIt(returnData, AppLog.LOG_ERR, true);
		}

		try 
		{
			// and send return data
			responseObj.SetData(returnData);
			responseObj.SendResponse(0, "", SSHJResponse.RESP_TYPE_NORMAL, -1);// host
																				// parameter
																				// is
																				// not
																				// used
																				// in
																				// v1,
																				// nor
																				// is
																				// object
																				// host
																				// index
		} 
		catch (Exception e) 
		{
		}
		*/
	}

	// ---------------------------------
	private void HandleVersion2Processing(BufferedReader br) 			
	{

		long startTime = new Date().getTime();
		//int numCompleted = 0;
		//int numObjs = 0;
		
		int i = 0;
		try 
		{
						
			m_ExecObjsMap = new ConcurrentHashMap<String,SSHExec>();
			// start connection monitor
			if(br !=null )
			{
				m_ConnMon = new JSSHConnectionMonitor(this, br);
				Thread connThread = new Thread(m_ConnMon);
				connThread.start();
				AppLog.LogIt("Started Connection Monitor",AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_CONSOLE);
			}

			// if this is a host scan - there is no host addr to connect to,
			// just
			// start executing. Otherwise create execution objects for every
			// host in the list
			if (_xmlParams.IsHostScanRequest() || _xmlParams.IsSvnRequest()) 
			{
				ExecStart(-1);
			} 
			else 
			{
				AppLog.LogIt("Starting execution on "+ 
							Integer.toString(_xmlParams.NumHosts()) + " hosts",
							AppLog.LOG_LEVEL_INFO,
							AppLog.LOGFLAGS_ALL);
				// start exec threads\
				try
				{
					for (i = 0; i < _xmlParams.NumHosts(); ++i) 
					{
						ExecStart(i);						
					}
					if( _xmlParams.getDbCreds().ValidCreds())
					{
						_adminObj = new FT_Admin(this);
						Thread adminObjThread = new Thread(_adminObj);
						adminObjThread.start();
					}
				}				
				catch(OutOfMemoryError e)
				{
					/* Try to reclaim memory.
					 * Steps taken
					 * 1. Call garbage collector 
					 * 2. Sleep for 30 seconds - by that time maybe some threads would be done 
					 * 3. Call gc again
					 * Document that we could not process all hosts and continue 
					 */
					System.gc();
					MiscUtils.Sleep(30000);					
					System.gc();
					_fatalError = "Server:Cannot process all hosts - out of memory.";
					
					AppLog.LogIt("Could not start "+ 
							Integer.toString(_xmlParams.NumHosts()) +
							" exec objects due to out of memory error. Num started = " +
							Integer.toString(i),
							AppLog.LOG_LEVEL_ERROR,
							AppLog.LOGFLAGS_ALL);						
				}
			}
			int numObjs = m_ExecObjsMap.values().size();
			int numHosts = _xmlParams.NumHosts();
			AppLog.LogIt("Started  " + Integer.toString(numObjs) + " exec objects" +  (numHosts> 0 ? (" for "+Integer.toString(numHosts)) : ""),
					AppLog.LOG_LEVEL_INFO,
					AppLog.LOGFLAGS_CONSOLE);							
					
			// cannot proceed if fatal error is set
			if(_fatalError.isEmpty())
			{
				AppLog.LogIt("JSSHConnection: Entering main processing loop,num hosts =  " +
						Integer.toString(numObjs),
						AppLog.LOG_LEVEL_INFO,
						AppLog.LOGFLAGS_CONSOLE);
				
				while (!_aborted) 
				{												
					if( _numCompleted >= numObjs)
					{										
						break;
					}				
					MiscUtils.Sleep(100);
				}
			}
			else
			{
				AppLog.LogIt("JSSHConnection: Skipping main processing loop due to fatal error",				
						AppLog.LOG_LEVEL_INFO,
						AppLog.LOGFLAGS_CONSOLE);				
			}
		}
		catch (Exception e)
		{
			String message = e.getMessage();
			if(message == null || message.isEmpty())
			{
				message = "Exception in main processing loop";
			}
			AppLog.LogIt("HandleVersion2Processing:Exception in main loop:" +
					 e.getMessage(),
					  AppLog.LOG_LEVEL_ERROR,
					  AppLog.LOGFLAGS_ALL);
			
			if(e.getMessage() == null)
			{
				e.printStackTrace();
			}
			// try to notify client
			try
			{
				_responseObj.SendResponse(-1, // cmdSeqNum,
						  "",						// hostAddr 
						  message, 				// data
						  SSHJResponse.STATUS_ERR,	// status
						  SSHJResponse.RESP_TYPE_FIN, // response type
						 -1);// unused object index
			}
			catch(Exception ex)
			{
				AppLog.LogIt("Exception sending error message in main loop" +
						  ex.getMessage(),
						  AppLog.LOG_LEVEL_ERROR,
						  AppLog.LOGFLAGS_ALL);
			}			
		}
		finally
		{
			
			if(_numCompleted == _xmlParams.NumHosts())
			{
				AppLog.LogIt("HandleVersion2Processing completed due to all threads completed ",
								  AppLog.LOG_LEVEL_INFO,
								  AppLog.LOGFLAGS_ALL);
			}
			else if (_aborted)
			{
				AppLog.LogIt("HandleVersion2Processing completed due abort",
						  AppLog.LOG_LEVEL_INFO,
						  AppLog.LOGFLAGS_ALL);
			}
			else
			{
				
				AppLog.LogIt("HandleVersion2Processing completed due to " +
						  DetermineCompletionReason() +
						 ",num completed = "+ 			
						  Integer.toString(_numCompleted) + " out of " + 
						  ((_xmlParams.IsHostScanRequest() || _xmlParams.IsSvnRequest()) ? "1" : Integer.toString(_xmlParams.NumHosts())),
						  AppLog.LOG_LEVEL_INFO,
						  AppLog.LOGFLAGS_ALL);
			}
			AppLog.LogIt("Took " + Integer.toString((int)((new Date().getTime() - startTime)/1000)) 
						  + " seconds",
						 AppLog.LOG_LEVEL_INFO,
						 AppLog.LOGFLAGS_ALL);
		}
	}
	//--------------------------------------------------
	public void HandleClientResponse(String addr)
	{
		SSHExec exec = m_ExecObjsMap.get(addr);
		if(exec!=null)
		{
			exec.HandleClientResponse(addr); // addr is unused for now
		}
		else
		{
			
			AppLog.LogIt("HandleClientResponse: cannot find object in map for " + addr, 
						  AppLog.LOG_LEVEL_ERROR,
						  AppLog.LOGFLAGS_ALL);
		}
	}
	// -----------------------------------
	private void ExecStart(int hostIndex) 
	{
		SSHExec exec = null;
		
		AppLog.LogIt("ExecStart: index: " + 
				Integer.toString(hostIndex), 
				AppLog.LOG_LEVEL_INFO,
				AppLog.LOGFLAGS_CONSOLE);
		try
		{
			exec = SSHExec.GetSSHExecObject(_xmlParams,this);	
			// set the index to the host object maintained by sshparams object
			exec.setHostIndex(hostIndex);					
			// create a new response object from the socket
			SetResponseObjForExec(exec);
			
			m_ExecObjsMap.put(exec.getHostAddr(), exec);
			
			AppLog.LogIt("ExecStart: Starting thread ",						
							AppLog.LOG_LEVEL_INFO,
							AppLog.LOGFLAGS_CONSOLE);	
			exec.start();					
		}
		catch(Exception e)
		{
			AppLog.LogIt("Exception caught creating exec object, index" +
					Integer.toString(hostIndex) +" : "+ e.getMessage(), 
					AppLog.LOG_LEVEL_ERROR,
					AppLog.LOGFLAGS_ALL);
		}
		finally
		{			
			if(exec!=null)
			{
				if(exec.isAlive())
				{				
					AppLog.LogIt("ExecStart: done",	
							AppLog.LOG_LEVEL_INFO,
							AppLog.LOGFLAGS_CONSOLE);		
				}
				else
				{
					m_ExecObjsMap.remove(exec);
					AppLog.LogIt("ExecStart: exec thread is dead, removing from map",
							AppLog.LOG_LEVEL_INFO,
							AppLog.LOGFLAGS_CONSOLE);	
					
				}
			}
			else
			{
				AppLog.LogIt("ExecStart: Failed to create exec object",	
						AppLog.LOG_LEVEL_ERROR,
						AppLog.LOGFLAGS_ALL);	
			}
		}		
	}
	//----------------------------------
	public void IncrementNumCompleted()
	{
		_numCompleted++;
		AppLog.LogIt("Incrementing num completed: " + 
					 Integer.toString(_numCompleted), 
					 AppLog.LOG_LEVEL_INFO, 
					 AppLog.LOGFLAGS_CONSOLE);
	}
	// ------------------------------------
	// determines reason for operation completion. used for loggging
	private String DetermineCompletionReason()
	{
		String reason;
		if(_xmlParams.IsHostScanRequest())
		{
			reason = "Host scan request done";
		}
		
		else if(_xmlParams.IsSvnRequest())
		{
			reason = "SVN request done";
		}
		else
		{
			reason = "unhandled exception";
		}
		return reason;
	}
	//--------------------------------------
		public JSSHProxyParams getXmlParams()
		{
			return _xmlParams;
		}
		//---------------------------
		public ConcurrentHashMap<String, SSHExec> getExecObjsMap()
		{
			return m_ExecObjsMap;
		}
		//---------------------------
		public Boolean getAborted()
		{
			return _aborted;
		}

		public int getNumCompleted()
		{
			return _numCompleted;
		}
		//----------------------------
		// read data from the socket. Subclasses override
		protected String ReadInput(BufferedReader br)
		{
			String input = "";
			String inLine = null;
			try
			{
				while (((inLine = br.readLine()) != null))
				{
					input += inLine;
					// Look for the closing tag of the XML
					if (input.lastIndexOf(SSH_REQ_END) > 0) 
					{
						break;
					}
				}
			}
			catch(Exception e)
			{
				
			}
			
			return input;
		}
		
		//-----------------------------
		protected void SetResponseObjForExec(SSHExec exec)
		{
			exec.setResponseObj(new SSHJResponse(this.m_Socket));
		}
		
}// end class

