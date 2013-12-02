/*******************************************************************************
 * FT_CliResponse.java
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

import java.io.IOException;
import java.net.*;

import com.FLATT.Utils.AppLog;
import com.FT_JSSH.SSHJResponse;

public class FT_CliResponse extends SSHJResponse 
{
	private String _res = "";
	public FT_CliResponse(Socket sock) 
	{
		super(sock);
	}
	//--------------------------------------
	@Override
	public   Boolean  SendResponse(int cmdSeqNum,
									String hostAddr, 
									String data,
									String status,
									int respType, // normal response or wait for ack
									int execObjIndex) throws IOException
	{
		
		if(_res.isEmpty() && !hostAddr.isEmpty())
		{
			_res = "Host " + hostAddr + ":" + AppLog.g_LineSepartator;
			System.out.println("Executing on host " + hostAddr + "...");
		}
		_res += data + AppLog.g_LineSepartator;
		return true;
	}
	//-----------------------------
	@Override
	public void Cleanup()
	{
		if(!_res.isEmpty())
		{
			super.Cleanup();
			System.out.println(AppLog.g_LineSepartator+ _res);
			_res = "";
		}
		/*else
		{
			System.out.println("");
		}*/
	}
	//----------------------------------------

}
