/*******************************************************************************
 * AppLog.java
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
package com.FLATT.Utils;

import java.text.DateFormat;
import java.util.Date;
import java.io.*;
/*import java.net.URL;
import java.security.CodeSource;*/

//=========================================================================


public class AppLog
{
	public static String LOG_INFO = " [INFO] ";
	public static String LOG_WARN = " [WARN] ";
	public static String LOG_ERR = " [ERROR] ";
	public static String LOG_ALWAYS = " [INFO] "; // something that must be logged overriding log level

	public  static int LOG_LEVEL_ALWAYS =0;
	public  static int LOG_LEVEL_ERROR = 1;
	public  static int LOG_LEVEL_WARNING = 2;
	public  static int LOG_LEVEL_INFO = 3;
	
	private static String[] _logLevels = {LOG_ALWAYS,LOG_ERR,LOG_WARN,LOG_INFO};
	
	private static Boolean g_Inited = false;
	public static String g_LineSepartator = System.getProperty("line.separator");			
	public static int LOGFLAGS_CONSOLE  = 0x00000001;
	public static int LOGFLAGS_LOGFILE  = 0x00000002;
	public static int LOGFLAGS_ALL = (LOGFLAGS_CONSOLE |LOGFLAGS_LOGFILE);
	
	/*UNUSED - delete
	 * public  class LOG_LEVEL 
	{
				
	    public int _value;
	    //------------------------
	    // set the value of the log level. Why does it have to be that complicated??
	    public void SetValue(int val)
	    {
	    	if(val < LOG_LEVEL_INFO || val > LOG_LEVEL_ERROR)
	    	{
	    		_value = val;
	    	}
	    	else
	    	{
	    		_value = val;
	    	}
	    }
	}; */

	// the last element is the "always" flag

	public static int _logLevel;
	// by default set to jssh proxy.
	// others may override
	public static String STR_APP_NAME = "jsshproxy";
	public static String STR_APP_VERSION = "1.2.1";
	public static String g_LogDirectory;

	private static File g_LogFile;

	AppLog()
	{
		_logLevel = LOG_LEVEL_ERROR;
	}

	// ----------------------------------------
	public static void InitLog() 
	{
		g_Inited = true;
		try 
		{
			
			EnsureLogFile();
			AppLog.WriteLog(STR_APP_NAME + " v " + STR_APP_VERSION
							+ " started" + AppLog.g_LineSepartator + 
							"Log file location:" + g_LogFile.getCanonicalPath() 
							/* in " + GetCurrentDir()*/, 
							LOG_LEVEL_ALWAYS, 
							LOGFLAGS_ALL);
		} 
		catch (Exception error) 
		{			
			// cannot get canonical path - get absolute
			AppLog.WriteLog("AppLog:Cannot get canonical path, using absolute .Server log file location: "
							+ g_LogFile.getAbsolutePath(), 
							LOG_LEVEL_ALWAYS, 
							LOGFLAGS_ALL);
		}
	}

	// -------------------------------------------
	public static void LogIt(String message, int level, int logFlags ) 
	{
		if (!g_Inited)
		{
			InitLog();
		}
		WriteLog(message, level, logFlags);

	}

	// --------------------------------------------
	public static String GetCurrentDir() 
	{
		
		if (g_LogDirectory != null) 
		{
			return g_LogDirectory;
		}
		
		/* this means we are running as internal proxy and we want to log in the temp directory 
		 * 
		 *  
		*/
		// is located
		return MiscUtils.GetSystemTempDirPath(false);

	}

	// ----------------------------------------
	public static String GetCurrentDate() 
	{
		/*
		 * Formatter fmt = new Formatter(); Calendar cal =
		 * Calendar.getInstance();
		 * 
		 * fmt = new Formatter(); fmt.format("%tc", cal); return fmt.toString();
		 */
		return (DateFormat
				.getDateTimeInstance(DateFormat.FULL, DateFormat.FULL)
				.format(new Date()));

	}
	public static void SetLogLevel(int level)
	{
		_logLevel = level;
	}
	// -------------------------------------------------------
	private static void WriteLog(String message, int level,long logFlags) 
	{
		
		if(ShouldLog(level))
		{
			String fullMessage = GetCurrentDate() + _logLevels[level] + message + g_LineSepartator;					
			
			if ((logFlags & LOGFLAGS_CONSOLE)!=0)
			{
				System.out.println(fullMessage);
			}
			if((logFlags & LOGFLAGS_LOGFILE)!=0)
			{
				try 
				{
					/* create a UUID for this file
					if (g_LogFile == null) 
					{
						g_LogFile = new File(GetCurrentDir() + File.separator + STR_APP_NAME +".log");								
						
					}*/
					// first write happens in InitLog - in this case we overwrite the file
					BufferedWriter out = new BufferedWriter(new FileWriter(g_LogFile,g_Inited));
							
					out.write(fullMessage);
					out.close();
				} 
				catch (Exception e) 
				{
					System.out.println("AppLog - Failed to log to a file:"+ e.getMessage());							
				}
			}
		}
	}
	//-----------------------------
	//Make sure log file exists
	public static void EnsureLogFile()
	{
		if (g_LogFile == null) 
		{
			g_LogFile = new File(GetCurrentDir() + File.separator + STR_APP_NAME +".log");								
		}
	}
	//-------------------------------------------------
	// see if logging is needed. Always overrides
	private static Boolean ShouldLog(int level)
	{
		return ((level<=_logLevel) || (_logLevel == LOG_LEVEL_ALWAYS));
	}

}
