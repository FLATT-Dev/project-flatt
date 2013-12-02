/*******************************************************************************
 * FT_SvnRequest.java
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

import java.util.ArrayList;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

//import com.FLATT.Utils.*;

public class FT_SvnRequest
{

	/* SVN Request types sent by client */
	public static final int SVNREQ_UNDEFINED = 0;
	public static final int SVNREQ_CHECKOUT = 1;
	public static final int SVNREQ_UPDATE = 2;
	public static final int SVNREQ_STATUS = 3;
	public static final int SVNREQ_DIFF = 4;
	public static final int SVNREQ_LOG = 5;
	public static final int SVNREQ_COMMIT = 6;
	public static final int SVNREQ_ADD = 7;
	public static final int SVNREQ_DELETE = 8;
	public static final int SVNREQ_REVERT = 9;

	public static final int SVNREQ_NUM = 10;// increment as new types are added
	
	private int 	_requestType; // request types
	//private String  _moduleName = "";
	//private String  _localPaths = "";
	private String  _url = "";
	private String  _username = "";
	private String  _password  = "";
	private ArrayList<String> _localPaths = new ArrayList<String>(); // list of files on which to operate
	private String _topLevelDir = "";
	private String _checkinMsg = "";
	
	public FT_SvnRequest()
	{
		// TODO Auto-generated constructor stub
	
	}
	
	//-------------------------------
	public void FromXml(Node topNode,Document doc)
	{
	
		String strType = JSSHProxyParams.GetNodeAttribute(topNode,"type");
		// if type is empty - something is amiss,
		if(!strType.isEmpty())
		{
			_requestType = Integer.parseInt(strType);
			
			NodeList children = topNode.getChildNodes();
			
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
					/* else if (nodeName.equalsIgnoreCase("module"))
					 {
						 _moduleName = curChild.getFirstChild().getNodeValue().trim();
					 }
					 else if (nodeName.equalsIgnoreCase("localdir"))
					 {
						 _localDir = curChild.getFirstChild().getNodeValue().trim();
					 }*/
					 // the  timeout to use when scanning for hosts
					 else if (nodeName.equalsIgnoreCase("username"))
					 {
						 _username = curChild.getFirstChild().getNodeValue().trim();
					 } 
					 else if (nodeName.equalsIgnoreCase("password"))
					 {
						 _password = curChild.getFirstChild().getNodeValue().trim();
					 } 
					 else if (nodeName.equalsIgnoreCase("LocalPaths"))
					 {
						 ProcessPathList(doc.getElementsByTagName("Path"));
					 } 
					 else if (nodeName.equalsIgnoreCase("RootDir"))
					 {
						_topLevelDir = curChild.getFirstChild().getNodeValue().trim();
					 } 
					 else if (nodeName.equalsIgnoreCase("CheckinMessage"))
					 {
						 // checkin message - for now the client is sending unencoded msg
			
						 _checkinMsg = curChild.getFirstChild().getNodeValue().trim();//StringUtils.Base64Decode(curChild.getFirstChild().getNodeValue().trim());
					 } 
					 
				 }
			 }		 
		}
	}
	//-----------------------------
	/* Process a list of local paths.
	 * For checkout and update there is only one top level directory path
	 * For other commands there may be a list of files to perform an operation on
	 */
	private void ProcessPathList(NodeList files)
	{
		for(int i = 0; i < files.getLength();++i)
		{
			Node item = files.item(i);
			
			if(item!=null)
			{														
				String path = JSSHProxyParams.GetNodeAttribute(item,"name");
				if(!path.isEmpty())
				{					
					/*if(JSSHProxyParams.GetNodeAttribute(item,"isroot").equalsIgnoreCase("true"))
					{
						_topLevelDir = path;
					}
					else*/
					{
						_localPaths.add(path);
					}
				}
			}			
		}
	}
	//--------------------------------
	public Boolean get_isValid()
	{
		return (_requestType > SVNREQ_UNDEFINED && _requestType < SVNREQ_NUM);
	}
	//-----------------------------
	public int get_requestType()
	{
		return _requestType;
	}
	//-----------------------------
	/*public String get_moduleName()
	{
		return _moduleName;
	}*/
	//-----------------------------
	public String get_url()
	{
		return _url;
	}
	//-----------------------------
	public String get_username()
	{
		return _username;
	}
	//-----------------------------
	public String get_password()
	{
		return _password;
	}
	//-----------------------------
	public ArrayList<String>get_localPaths()
	{
		return _localPaths;
	}
	//----------------------------------------
	public String get_topLevellDir()
	{
		return _topLevelDir;
	}
	//----------------------------------------
	public String get_checkinMsg()
	{
		return _checkinMsg;
	}
	//----------------------------------------
	public void set_checkinMsg(String val)
	{
		_checkinMsg = val;
		
	}
	

}
