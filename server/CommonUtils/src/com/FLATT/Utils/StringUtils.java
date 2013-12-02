/*******************************************************************************
 * StringUtils.java
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


import java.io.File;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.nio.charset.Charset;
import java.util.Enumeration;
import java.util.concurrent.ConcurrentHashMap;

//import net.schmizz.sshj.common.Base64;

public class StringUtils {

	public StringUtils() 
	{
		// TODO Auto-generated constructor stub
	}
	
	public static Boolean IsValidString( String s)
	{
		return ((s!=null) && (!s.isEmpty()));
	}
	
	public static String InsertArgument(String dest, String pattern,String val)
	{
		if(dest.indexOf(pattern)>=0)
		{
			dest = dest.replace(pattern, val);		
		}
		return dest;		
	}
	//--------------------------------------------------------------------
	public static String Base64Decode(String str)
	{
		String ret = "";
		if(IsValidString(str))
		{
			try
			{
				ret = new String(Base64.decode(str));
				
			}
			catch(Exception e)
			{
				AppLog.LogIt("Exception decoding base64 string : "+ e.getMessage(),
							AppLog.LOG_LEVEL_ERROR,
							AppLog.LOGFLAGS_ALL);
			}
		}
		return ret;
		
	}
	//--------------------------------------------------------------------
	public static String Base64Encode(String str)
	{
		String ret;
		try
		{
			ret = Base64.encodeBytes(str.getBytes());
			
		}
		catch(Exception e)
		{
			AppLog.LogIt("Exception encoding string : "+ e.getMessage(),
						 AppLog.LOG_LEVEL_ERROR,
						 AppLog.LOGFLAGS_ALL);
			ret = str;
		}
		return ret;
		
	}
	//--------------------------------------------
	/* Replace the pattern with replace value in the string and return modified string 
	 * 
	 */
	public static String Replace(String str, String pattern, String replace) 
	{
	    int s = 0;
	    int e = 0;
	    StringBuffer result = new StringBuffer();

	    while ((e = str.indexOf(pattern, s)) >= 0)
	    {
	        result.append(str.substring(s, e));
	        result.append(replace);
	        s = e+pattern.length();
	    }
	    result.append(str.substring(s));
	    return result.toString();
	}
	//--------------------------------------------------
	//unused?
	public static String StreamToString(OutputStream stream)
	{
		String ret =  stream.toString();
		return ret;
	}
	//------------------------------------------------------------------------
	/* Parse  the keys and values in keyValStr, 
	 * find keys in dest string and replace them with values found in
	 * keyVal string
	 */
	public static String Substitute(String str,String keyValStr)
	{
		String res = str;
		ConcurrentHashMap<String,String> keyValMap=ParseKeyValues(keyValStr);
		if(keyValMap !=null)
		{
			Enumeration<String>keys = keyValMap.keys();
			String curKey;
			String curVal;
			
			while(keys.hasMoreElements())
			{
				curKey = keys.nextElement();
				curVal = keyValMap.get(curKey);
				res = Replace(res,"$"+curKey,curVal);
			}			
		}
		return res;
	}
	//----------------------------------------
	/* Parse key value pairs found in src into the hash map */
	public static ConcurrentHashMap<String,String> ParseKeyValues(String src)
	{
		ConcurrentHashMap<String,String> ret = null;
		String arr[] = src.split("\n");
		if(arr!=null && arr.length > 0 )
		{
			ret = new ConcurrentHashMap<String,String>();
			for(int i=0; i < arr.length;++i)
			{
				ParseKeyValString(arr[i].trim(),ret);
			}
		}
		return ret;
	}
	//----------------------------------------
	/* Parse one line and add a key value pair to the hash map
	 * Supported key value separators are:
	 * spaces,tabs,equal sign.
	 * Should recognize  the # and // comments
	 */
	public static void ParseKeyValString(String keyValString,ConcurrentHashMap<String,String> map)
	{
		// If i's not a comment
		if(!keyValString.startsWith("#") && !keyValString.startsWith("//") && !keyValString.startsWith("/*"))
		{
			StringBuffer sb = new StringBuffer();
			int i;
			String key = "";
			String val = "";
			/* read the key until a separator character is encountered */
			for( i =0; i <keyValString.length();++i)
			{
				char cur = keyValString.charAt(i);
				if(cur==' ' || cur == '\t' || cur == '=')
				{
					i++;
					break;
				}
				sb.append(cur);
			}
			/* Do we have a key? */
			if(sb.length() > 0  && i !=0 && i < keyValString.length())
			{
				/*parse the value*/
				val = keyValString.substring(i).trim();
				 key = sb.toString();
				if(!val.isEmpty() & !key.isEmpty())
				{
					map.put(key,val);
				}
				
			}
		}
			
	}
	//--------------------------------------------
	public static String CleanupUrl(String url)
	{
		String temp = StringUtils.Replace(url,"https://","");
		temp = StringUtils.Replace(temp,"http://","");	
		
		// First strip http and https from source.
		StringBuffer src = new StringBuffer( temp );
		String dest = "";
		
		for(int i = 0; i < src.length(); ++i)
		{
			if(temp.charAt(i) == '/')
			{
				break;
			}
			dest+=temp.charAt(i);			
		}		  
		return dest;
	}
	//----------------------------
	//return default charset of the system
	public static String URLDecodeString(String s)
	{
		String ret = s;
		// default to UTF-8
		String charset = "UTF-8";
		try
		{
			charset = Charset.defaultCharset().name();
			ret = URLDecoder.decode(s,charset);
		}
		catch(Exception e)
		{
		}
		return ret;
	}
	//-----------------------------------------
	// Case sensitive search of a token in an array.
	public static boolean FindToken(String searchString,String fieldSeparator,String token)
	{
		
		if(IsValidString(searchString))
		{
			String arr[] = searchString.split(fieldSeparator);
			if(arr!=null && arr.length > 0)
			{
				for(int i = 0;i < arr.length;++i)
				{
					if(arr[i].equals(token))
					{
						return true;
					}
				}
			}
		}
		return false;		
	}
	
	//------------------------------------------------------------
	// a generic routine that returns a path of class inside a jar
	public static String GetJarFolderPath(Class<?> theClass, String jarName)
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
		String name = theClass.getName().replace('.', '/');  
		String classPath = theClass.getResource("/" + name + ".class").toString();
		
		// on mac decoding the path is not necessary and should not be done as the path becomes mangled
		// decoder interprets certain sequences as Unicode and messes up the path
		// decoding really only needed for older version of Windows, i.e XP
		String s = (MiscUtils.RunningOnWindows())? StringUtils.URLDecodeString(classPath): classPath;	
	    s = s.replace('/', File.separatorChar);	    
	   // AppLog.LogIt("GetJarFolderPath:getResource returns: "+s, AppLog.LOG_LEVEL_ALWAYS, AppLog.LOGFLAGS_ALL);	    
	    //when run standalone the path will contain appname.jar with a ! in front of it
	    // when run from eclipse - it will not be there, so just return the current directory path
	    pos = s.indexOf(jarName + ".jar");
			
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
	//----------------------------------
	// put quotes around a string
	public static String QuoteString(String src)
	{
		return "\""+ src+"\"";
	}
	//------------------------------------
	public static String Dos2Unix(String src)
	{
		return src.replaceAll("\r\n", "\n"); 		
	}
	//------------------------------------
	public static String CleanupSpaces(String insStr)
	{
		
		String newString= "";
		
		for( int i = 0; i < insStr.length();++i)
		{
		 	char curChar = insStr.charAt(i);
			if(!isWhitespace(curChar))
			{
				newString+=curChar;
			}
		}
		return newString;
	}
	//------------------------------
	public static boolean isWhitespace(char character)
    {
        switch (character)
        {
            case 0x20:
            case '\t':
            case '\r':
            case '\n':
            case '\f':
                return true;

            default:
                return false;
        }
    }
    
    //-------------------------------
    // clean up quotes from beginning and end of string
    public static String StripQuotes(String src)	
    {
    	String ret = src;
    	if( ret.startsWith("\"") || ret.startsWith("'"))
		{
    		ret = ret.substring(1,ret.length());
		}
		if( ret.endsWith("\"") || ret.endsWith("'"))
		{
			ret = ret.substring(0,ret.length()-1);
		}
		return ret;
    }
} // class
