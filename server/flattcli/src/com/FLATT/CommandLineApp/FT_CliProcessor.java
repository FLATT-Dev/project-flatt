/*******************************************************************************
 * FT_CliProcessor.java
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

import java.io.*;
import com.FT_JSSH.*;


public class FT_CliProcessor extends JSSHConnection 
{
	private String _xmlRequest = "";
	
	public FT_CliProcessor(String xmlRequest, JSSHProxyParams cmdLineParams)
	{
		super();
		_xmlRequest = xmlRequest;
		_xmlParams = cmdLineParams;
		// copy the command line values from cmdLine params object
		// come of them are relevant to execution i.e whether we're in simulation mode
		//_xmlParams.CopyCmdLineParams(cmdLineParams);
		_responseObj = new FT_CliResponse(m_Socket);	
	}
	//-------------------------------------
	@Override
	protected String ReadInput(BufferedReader br)
	{
		return _xmlRequest;
	}
	//----------------------------------------
	@Override
	protected void SetResponseObjForExec(SSHExec exec)
	{
		exec.setResponseObj(new FT_CliResponse(m_Socket));
	}
}
