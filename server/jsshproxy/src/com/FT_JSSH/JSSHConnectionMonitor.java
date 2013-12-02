/*******************************************************************************
 * JSSHConnectionMonitor.java
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

import com.FLATT.Utils.*;



// This class monitors the connection with the client  to make sure that when client
// disconnects the connection to host is closed as well
public class JSSHConnectionMonitor implements Runnable 
{	
	
	private JSSHConnection _conn;
	public static final String FT_ACK = "6";// ack char we get from client
	BufferedReader _br;
	private Boolean	_done = false;
	
	
	JSSHConnectionMonitor(JSSHConnection inConn, BufferedReader inBr )
	{
		_conn  = inConn;
		_br = inBr;
		
	}	
	
	@Override
	public void run() 
	{
		// TODO Auto-generated method stub
		try
		{
			String inLine = null;
			
			while(!_done)
			{
				inLine = _br.readLine(); // this would block
				if(inLine == null)
				{
					break;
				}
				else
				{
					// the only thing that the client can send is an IP address or an empty string
					_conn.HandleClientResponse(inLine);
			
				}				
			}
		}
		catch(IOException e)
		{
			// 			
		}
		if( _conn!=null )
		{
			_done = true;
			AppLog.LogIt("ConnMon: Disconnect.Sending Abort!",
						 AppLog.LOG_LEVEL_INFO,
						 AppLog.LOGFLAGS_CONSOLE);
			try
			{
				
				//_responseObj.Abort(); // if any object is waiting for ack - make sure to abort
				_conn.Abort();
			}
			catch(Exception e2)
			{
				// this is bad
			}
		}
		
	}
	//------------------------------
	public void SetDone()
	{
		_done =  true;
		_conn = null; // prevent this code from running cleanup. The connection thread will do this
	}

}
