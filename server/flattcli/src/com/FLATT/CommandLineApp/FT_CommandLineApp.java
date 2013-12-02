/*******************************************************************************
 * FT_CommandLineApp.java
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

import java.io.File;
import com.FLATT.Utils.*;
import com.FT_JSSH.*;


public class FT_CommandLineApp implements IShutdownParent
{

	protected FT_RequestBuilder _reqBuilder;
	private FT_ShutdownThread _shutdownThread;
	private FT_CliProcessor _cliProc;
	
	public FT_CommandLineApp() 
	{
		_shutdownThread = new FT_ShutdownThread(this);
        Runtime.getRuntime().addShutdownHook(_shutdownThread);
	}
	//----------------------------------------------
	public void Run(String[] args)
	{
		
		_reqBuilder = new FT_RequestBuilder();
		
		_reqBuilder.BuildRequest(args);
		
		
		if(_reqBuilder.isDryRun())
		{
			QuitApp();
		}
		
		if(_reqBuilder.getConnectToProxy())
		{
			ProcessRequest_Remote();
		}
		else
		{
			ProcessRequest();
		}
		QuitApp();
				
	}
	//--------------------------------
	private void QuitApp()
	{
		AppLog.LogIt("Execution completed", AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL);
		System.exit(0);
		
	}
	//------------------------------------
	private void ProcessRequest_Remote()
	{
		
	}
	//------------------------------------
	private void ProcessRequest()
	{
		try
		{
			JSSHProxyParams params = new JSSHProxyParams(".");// pass this directory as a jar dir path
			// propagate flags from command line into the proxy params object
			params.	SetSimulationMode(_reqBuilder.isSimulationMode());
			_cliProc = new FT_CliProcessor(_reqBuilder.getRequest(),params );		
			System.out.println("Connecting to hosts..." );
			_cliProc.run();
		}
		catch(Exception e)
		{
			AppLog.LogIt("Failed to run request:  " +  e.getMessage(), AppLog.LOG_LEVEL_ERROR,AppLog.LOGFLAGS_ALL);
		}
		
	}
	
	//----------------------------------
	public void Shutdown()
	{
		if(_cliProc !=null)
		{
			try
			{				
				_cliProc.Abort();
			}
			catch(Exception e)
			{
				
			}
		}
	}

	//========================================
	// To set ssl key in client: TODO:
	//System.setProperty("javax.net.ssl.keyStore", "/path/to/keystore.jks");
	//System.setProperty("javax.net.ssl.keyStorePassword", "password");
	/**
	 * @param args
	 */
	public static void main(String[] args) 
	{
		// TODO Auto-generated method stub
		AppLog.STR_APP_NAME = "FLATT-CLI";
		AppLog.STR_APP_VERSION = "1.1";
		AppLog.g_LogDirectory = "." + File.separator;
		System.out.println("");// print an empty line to separate the command line from the beginning of app output
		AppLog.InitLog(); // init explicitly before we start execution
		new FT_CommandLineApp().Run(args);

	}

}
