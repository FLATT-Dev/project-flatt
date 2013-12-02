/*******************************************************************************
 * FT_DbCreds.java
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

import org.w3c.dom.*;

public class FT_DbCreds 
{
	private String _url ="";
	private String _username = "";
	private String _password = "";
	//---------------------------------
	//---------------------------------
	public FT_DbCreds() 
	{
		// TODO Auto-generated constructor stub
		/*_url = "localhost";
		_username="root";
		_password="r1galatvia";*/
	}
	//------------------------------
	public FT_DbCreds(String url, String username, String password)
	{
		_url = url;
		_username = username;
		_password = password;
	}
	//-------------------------------
	public String getUrl() 
	{	
		return _url;
	}
	//---------------------------------
	public String getUsername() 
	{
		return _username;
	}
	//---------------------------------
	public String getPassword() 
	{
		return _password;
	}
	//---------------------------------
	public void FromXML(Node theNode)
	{
		NodeList children = theNode.getChildNodes();
		
		 for( int i = 0; i < children.getLength(); ++ i)
		 {
			 Node curChild = children.item(i);
			 String nodeName = curChild.getNodeName();
			 
			 if(nodeName != null && curChild.getFirstChild()!=null )
			 {
				// range to scan for hosts
				 if (nodeName.equalsIgnoreCase("url"))
				 {
					 _url = curChild.getFirstChild().getNodeValue().trim();
				 }
				 else if(nodeName.equalsIgnoreCase("username"))
				 {
					 _username = curChild.getFirstChild().getNodeValue().trim();
				 }
				 else if(nodeName.equalsIgnoreCase("password"))
				 {
					 _password = curChild.getFirstChild().getNodeValue().trim();
				 }
			 }
		 }
	}
	//-----------------------------------------
	public boolean ValidCreds()
	{
		return (!_url.isEmpty() && !_username.isEmpty());				
	}
	//-----------------------------------------
	public String ToXml()
	{
		String ret = "";
		if(ValidCreds())
		{			
			ret += "<DbCreds>";
			ret += "<url>"+_url + "</url>" +  "<username>" + _username + "</username>" + "<password>" + _password + "</password>";
			ret += "</DbCreds>";					
		}
		return ret;
	}
	//-----------------------------------------
	public void setUrl(String val)
	{
		_url = val;
	}
	//-----------------------------------------
	public void setUsername(String val)
	{
		_username = val;
	}
	//-----------------------------------------
	public void setPassword(String val)
	{
		_password = val;
	}
	

}
