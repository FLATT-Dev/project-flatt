/*******************************************************************************
 * JSSHProxy.java
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
import com.FT_JSSH.*;
import com.FLATT.Utils.*;

import java.io.File;
import java.io.IOException;



/* SSH proxy class. 
 * Can be started as a server or just execute a command and exit
*/

public class JSSHProxy 
{
	
	private String _jarDirPath = "";
	//-------------------------------------
	public static void main(String... args) throws IOException           
	{				
		/* Set up app name and version
		 * 
		 */
		AppLog.STR_APP_NAME = "jsshproxy";
		AppLog.STR_APP_VERSION = "2.1.4";
		new JSSHProxy().Execute(args);				
	} //main	
	
	//-----------------------------------------------
	public void Execute(String... args)
	{
		_jarDirPath = GetJarFolderPath();
		AppLog.LogIt("Started JSSHProxy in " + _jarDirPath, AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL);
		
		JSSHProxyParams params = new JSSHProxyParams(_jarDirPath);
		
		if(!params.ParseArgs(args))
		{
			System.out.println("Bad parameters,exiting");
			System.exit(1);
		}	
		// we can only initialize the log when we have figured out from parameters how we're running
		
		AppLog.g_LogDirectory = params.getLogPath();
		
		if(AppLog.g_LogDirectory == null)
		{
			// try to figure out if this is an internal proxy or external proxy. I
			//If it's external - it will have a port number and log directory defaults to "."
			//Otherwise it's internal. Then dir path stays null and logging will happen in the temp directory
			//
			if(params.getPort() > JSSHProxyParams.DEFAULT_PORT)
			{
				AppLog.g_LogDirectory = ".";
			}
		}
		
		// make assumption
		// no server
		if(params.getNoServer())		
		{
			if(params.getIsRealTime())
			{
				//TODO implement continuous response
			}
			else
			{
				SSHExec exec = new SSHExec(params,null);
				if(exec.Connect() && exec.Execute(true,true))//disconnectOnCompletion,readLoginPrompt,cmd index
				{
					// dump output on command line
					AppLog.LogIt("JSSHProxy: exec returned " + exec.getResultString(),
								 AppLog.LOG_LEVEL_INFO,
								 AppLog.LOGFLAGS_ALL);
				}
				else
				{
					AppLog.LogIt("JSSHProxy: exec error "+ exec.getResultString(),
							AppLog.LOG_LEVEL_ERROR,
							AppLog.LOGFLAGS_ALL);
				}
			}			
		}
		else
		{
			JSSHServer server = new JSSHServer();
			server.setLineParams(params);
			server.Run();
		}	
		AppLog.LogIt("JSSHProxy exiting",AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_ALL);
	    System.exit(0);
	}
	//----------------------------------------------
	private String GetJarFolderPath()
	{	
	   /* String name = this.getClass().getName().replace('.', '/');
	    String s = this.getClass().getResource("/" + name + ".class").toString();
	    s = s.replace('/', File.separatorChar);
	    s = s.substring(0, s.indexOf(".jar")+4);
	    s = s.substring(s.lastIndexOf(':')-1);
	    return s.substring(0, s.lastIndexOf(File.separatorChar)+1);*/
	    /* Relies on the following format
	     *  Windows- "jar:file:/C:/Users/andy/AppData/Local/Temp/FLATT/jsshproxy.jar!/JSSHProxy.class";
	     *  Mac - "jar:file:/private/var/folder/+Sdddfkjdlfjdkljdlfjldfkdf++++++TI/-Tmp-/FLATT/jsshproxy.jar!/JSSHProxy.class";
	     * 
	     */
		int add = 0;
		int pos;
		int seconColonPos;
		String name = this.getClass().getName().replace('.', '/');  
		String classPath = this.getClass().getResource("/" + name + ".class").toString();
		// on mac decoding the path is not necessary and should not be done as the path becomes mangled
		// decoder interprets certain sequences as Unicode and messes up the path
		// decoding really only needed for older version of Windows, i.e XP
		String s = (MiscUtils.RunningOnWindows())? StringUtils.URLDecodeString(classPath): classPath;	
	    s = s.replace('/', File.separatorChar);	    
	   // AppLog.LogIt("GetJarFolderPath:getResource returns: "+s, AppLog.LOG_LEVEL_ALWAYS, AppLog.LOGFLAGS_ALL);	    
	    //when run standalone the path will contain appname.jar with a ! in front of it
	    // when run from eclipse - it will not be there, so just return the current directory path
	    pos = s.indexOf(AppLog.STR_APP_NAME+".jar");
			
	    if(pos >=0 )
	    {
	    	s = s.substring(0, pos );
	    
		    pos = s.indexOf("file:");
		    // check if there is another colon in the string. if there is it must be a windows path.
		    // in that case skip past the beginnig path separator. On  the mac this would be the only colon - leave the 
		    // separator
		    if(pos >=0)
		    {				    
		    	pos+=5;
		    	seconColonPos = s.indexOf(":", pos);	
		    	if(seconColonPos>=0)
		    	{
		    		add = 1;
		    	}			    
		    }
		    s = s.substring(pos +add);
		    return s; 
	    }
	    
	    // if not found just return
	    return "."+File.separator;		   
	}
	//------------------------------------------
	
	
	
} //class

