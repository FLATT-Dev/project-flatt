/*******************************************************************************
 * FT_FileUtils.java
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
import java.util.UUID;

public class FT_FileUtils 
{

	// ----------------------------------------------------
	public static String ReadFile(File file) throws Exception 
	{
		
		StringBuilder result = new StringBuilder();
		BufferedReader reader = null;

	    try 
	    {
	        reader = new BufferedReader(new FileReader(file));
	        char[] buf = new char[1024];
	        int r = 0;

	        while ((r = reader.read(buf)) != -1) 
	        {
	            result.append(buf, 0, r);
	        }
	    }
	    finally 
	    {
	        if(reader!=null)
	       	{
	       		reader.close();
	       	}
	    }

		return result.toString();
		
		
		/*String ret = "";

		FileInputStream fstream = new FileInputStream(file);
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		
		String strLine;
		// Read File Line By Line
		while ((strLine = br.readLine()) != null) {
			ret += strLine;
		}
		// Close the input stream
		in.close();
		return ret;*/

	}
	//----------------
	public static File CreateDirectory(String dirPath) throws Exception
	{
		File f = new File(dirPath);
		if(!f.mkdir())
		{
			throw ( new Exception("Cannot create directory for category"));
		}
		return f;
	}
	
	// save command to local temp file	
	public static File SaveTempFile(String data)
	{
		
		File temp = null;
		String tempDir = "";
		try
		{
			// create a UUID for this file
			// NOTE!!
			/* Looks like there is a 35 character limit on the length of the command in the Shell
			 * If exceeded the return stream contains a bunch of backspaces and other weirdness
			 * Make sure we don't exceed this limit
			 * NOTE2!!
			 * Now the code that calls this routine adds 4 characters to the name and now the total num chars is 39.
			 * So far I have not seen any ill effects of this but watch out
			 */
			UUID uuid = UUID.randomUUID();
			tempDir = MiscUtils.GetSystemTempDirPath(false);
			// dashes confuse the shell client..
			String strUID =  uuid.toString();
			
			if(strUID.length() > 35)
			{
				strUID = strUID.substring(0,35);
			}
			temp = SaveFile(tempDir+ strUID,data,true);
			
			
			/*temp =  new File(tempDir+ strUID);
			temp.deleteOnExit();
			BufferedWriter out = new BufferedWriter(new FileWriter(temp));
		    out.write(data);
		    out.close();*/	
		}
		catch( Exception e)
		{
			AppLog.LogIt("Exception saving temp file :" + e.getMessage(),
			  		AppLog.LOG_LEVEL_ERROR,
			  		AppLog.LOG_LEVEL_ALWAYS);
			if(temp!=null)
			{
				temp.delete();
				temp = null;
			}			
		}
		return temp;		
	}
	//------------------------------------------------------------
	public static File SaveFile(String path,String data,boolean deleteOnExit) throws Exception
	{		
		File f = new File(path);	
		if(deleteOnExit)
		{
			f.deleteOnExit();
		}
		BufferedWriter out = new BufferedWriter(new FileWriter(f));
	    out.write(data);
	    out.close();
	    
	    return f;
	}
	
}// end class
