/*******************************************************************************
 * SSHJResponse.java
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
import com.FLATT.Utils.*;


/* This class formats proxy response and sends it to client 
*/

public class SSHJResponse 
{
	protected PrintStream _outStream;
	public static final String RESPONSE_TEMPLATE = "<SSHResponse type=\"$5\">"+
													"<Status>$1</Status>"+
													"<Host>$2</Host>" +
													"<CmdSeqNum>$3</CmdSeqNum>" +
													"<Data>$4</Data>" +
													"</SSHResponse>\n";
	public static final String STATUS_OK="OK";
	public static final String STATUS_ERR="Error";
	public static final String STATUS_DIDNT_RUN ="Did not run";
	public static final String STATUS_CONN_ERR="Connection error";
	public static final String STATUS_CONN_CANCELED	="Canceled";
	
	public static final int RESP_TYPE_NORMAL = 0;
	public static final int RESP_TYPE_FIN	 = 1;
	public static final int RESP_TYPE_HOST_SCAN = 2;
	public static final int RESP_TYPE_SVNREQ	= 3;
	
	
	
	//private String _status = STATUS_OK;
	//private String _data = "";
	protected Socket _streamSocket;
	protected Boolean _gotAck = false;
	protected int _objIndex; // used for debugging only 
	
	
	public SSHJResponse(Socket sock)
	{
		try
		{
			_streamSocket = sock;	
			
			//SetStatus(STATUS_OK);// ok by default
		}
		catch(Exception e)
		{
			//SetStatus(STATUS_ERR);
		}		
	}	
	//-------------------------------------------
	// data is base64 encoded!
	public   Boolean  SendResponse(int cmdSeqNum,
									String hostAddr, 
									String data,
									String status,
									int respType, // normal response or wait for ack
									int execObjIndex) throws IOException
	{
		String output;	
		Boolean ret = false;
		_objIndex = execObjIndex;
		
		if(_streamSocket!=null &&  _streamSocket.isConnected() &&  !_streamSocket.isClosed())
		{
			try
			{
				if(data == null || data.isEmpty())
				{
					AppLog.LogIt("Sending empty data!",
								  AppLog.LOG_LEVEL_INFO,
								  AppLog.LOGFLAGS_CONSOLE);			

					data = "";
				}			
				// Set status, data and send the response to client
				output = StringUtils.InsertArgument(RESPONSE_TEMPLATE,"$1",status);
				output = StringUtils.InsertArgument(output, "$2", hostAddr);
				output = StringUtils.InsertArgument(output, "$3", Integer.toString(cmdSeqNum));
				output = StringUtils.InsertArgument(output,"$4",StringUtils.Base64Encode(data));
				output = StringUtils.InsertArgument(output,"$5",Integer.toString(respType));
				
				ret = SendData(output,respType);
				
			}
			catch(Exception e)
			{
				
			}
		}
		return ret;
	}
	// send data to client and block all other threads so the client does not get confused.
	// wait for the client app to ack the receipt of the data
	private Boolean SendData(String output, int respType)
	{
		AppLog.LogIt("SendData for #: "+Integer.toString(_objIndex) + ", Size="+output.length(),					  
					  AppLog.LOG_LEVEL_INFO,
					  AppLog.LOGFLAGS_CONSOLE);			

		Boolean ret = true;
		
		try
		{
			OutputStream ostream = _streamSocket.getOutputStream();
			ostream.write(output.getBytes());			
			ostream.flush();
			// TYPE_FIN is sent only in case of a fatal error - for now only out of memory error
			// is handled - 
			// This could be just a boolean but type gives more flexibility 
			// to do something other than deciding if waiting is needed.
			// Program in the future tense!
			if(respType != RESP_TYPE_FIN && respType !=RESP_TYPE_HOST_SCAN && respType !=RESP_TYPE_SVNREQ)
			{
				WaitForResponse();
			}			
		}
		catch(Exception e)
		{
			AppLog.LogIt("Exception in JSSHResponse:SyncSendData: " + e.getMessage(),
					AppLog.LOG_LEVEL_ERROR,
					AppLog.LOGFLAGS_ALL);
			_gotAck = true;
			ret = false;
		}
		return ret;
	}
	//------------------------------------------
	// wait for the other side to ack the data
	private  void WaitForResponse()
	{
		try
		{
			
			while(!_gotAck )
			{
				if(	_streamSocket == null ||
					_streamSocket.isClosed() || 
					(!_streamSocket.isConnected()) ||
					( _streamSocket.isInputShutdown()) ||
					(_streamSocket.isOutputShutdown()))
				{
					AppLog.LogIt("JSSHResponse:Connection closed, breaking",
								  AppLog.LOG_LEVEL_INFO,
								  AppLog.LOGFLAGS_CONSOLE);			

					break;
				}
				Thread.sleep(100);
			}
		}
		catch(Exception e)
		{
			
		}
		AppLog.LogIt("JSSHResponse: got ack , exec index " + 
					  Integer.toString(_objIndex),
					  AppLog.LOG_LEVEL_INFO,
					  AppLog.LOGFLAGS_CONSOLE);			
		  		 
	}
	
	//-------------------------------------
	// Reset response string
	public void Reset()
	{
		/*_status = STATUS_OK;
		_data = "";*/
		_gotAck = false;
		
	}
	//-------------------------
	/*public String getStatus()
	{
		return _status;
	}*/
	//-------------------------
	public void setGotAck()
	{
		_gotAck = true;
		AppLog.LogIt("JSSHResponse: setGotAck, exec index " + 
				  Integer.toString(_objIndex),
				  AppLog.LOG_LEVEL_INFO,
				  AppLog.LOGFLAGS_CONSOLE);			
	}
	//---------------------
	// if a thread is 
	// 
	public void Abort()
	{
		_gotAck = true;
		_streamSocket = null;
	}
	//--------------------------
	public void Cleanup()
	{
		// subclasses override
	}
}
