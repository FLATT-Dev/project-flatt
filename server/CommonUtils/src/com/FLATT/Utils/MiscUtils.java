/*******************************************************************************
 * MiscUtils.java
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


import java.io.*;
import java.net.InetAddress;


public class MiscUtils 
{
	
	public  static String GetSystemTempDirPath(Boolean printOS)
	{
		String os = System.getProperty("os.name");
		String ret;
		os = os.toLowerCase();
		
		if(printOS)
		{
			AppLog.LogIt("JSSHServer: Running on  " + os,
						AppLog.LOG_LEVEL_INFO,
						AppLog.LOGFLAGS_ALL);
		}
		ret =  System.getProperty("java.io.tmpdir");
		// add a separator at the end - callers of this code assume it is there, on
		// some OS's this is true, on some it is not
		if (!ret.endsWith(File.separator))
		{
			ret+=File.separator;
		}
		return ret;	
				
		/*
		 * This code was necessary due to mac weirdness where temp directory returned by the OS
		 * was not just /tmo but some convoluted Mac temp dir
		 * if(os.contains("windows"))
		{
			return System.getProperty("java.io.tmpdir");
		}
		// return temp directory on all other platforms
		return "/var/tmp/";	*/	
		
	}
	//----------------
	// just a wrapper around thread sleep
	public static void Sleep(int sleeptime)
	{
		try
		{
			Thread.sleep(sleeptime);
		}
		catch(Exception e)
		{			
		}
	}
	// OS accessors
	//Return true if runnigng on windows
	public static Boolean RunningOnWindows()
	{
		return System.getProperty("os.name").contains("indows");
	}
	//----------------------------------------
	public static Boolean RunnningOnMac()
	{
		return System.getProperty("os.name").contains("OS X");
	}
	//------------------------------------
	public static String GetLocalHostName()
	{
		String ret = "uknown host";
		try
		{
			ret = InetAddress.getLocalHost().getHostName();
		}
		catch(Exception e)
		{
		}
		return ret;
	}
	//-----------------------------------------
	/* Get username on the system */
	public static String GetLocalUserName()
	{
		return System.getProperty("user.name");
	}
	
	//--------------------------------
	// Write chunked output - UNUSED
	public static void ChunkedWrite(OutputStream ostream, String output, int bufSz)	throws Exception
	{
		
		int pos = 0;
		byte[] data = output.getBytes();
		int len = output.length();
		int numBytes;
		
		while(pos < len)
		{
			numBytes = Math.min(bufSz, len-pos);
			ostream.write(data,pos,numBytes);
			ostream.flush();
			pos += numBytes;
		}
	}
	

}
