/*******************************************************************************
 * FT_Action.java
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

import java.util.*;
import com.FLATT.DataObjects.*;
import com.FLATT.Utils.StringUtils;

public class FT_Action extends DB_Action

{
	private String _cmd = "";
	private int    _seqNum = -1;
	private String _origCmd;
	private String _result = SSHJResponse.STATUS_DIDNT_RUN;
	
	// command has actual command and a sequense number.
	// seq num is only used for tasks that execute multiple commands.
	// copy constructor
	//-------------------------------------
	public FT_Action(FT_Action src)
	{
		super("",src.getName(),src.getGuid(),src.getVersion());
		_cmd = src.getCommand();
		_origCmd = _cmd; // sae original just in case
		_seqNum = src.getSeqNum();
	}
	public FT_Action(String cmd,int seqNum,String name, String guid, String version)
	{		
		super("",name,guid,version);
		_cmd = cmd;
		_origCmd = _cmd; // sae original just in case
		_seqNum = seqNum;
	}
	//------------------------------
	public String getCommand()
	{
		return  _cmd;
	}
	//---------------------------------
	public void setCommand(String val)
	{
		_cmd = val;
	}
	//------------------------------
	public String getOrigCmd()
	{
		return _origCmd;
	}
	//------------------------------
	public int getSeqNum()
	{
		return _seqNum;
	}
	//------------------------------
	public void setResult(String val)
	{
		_result = val;
	}
	//------------------------------
	public String getResult()
	{
		return _result;
	}
	
	//---------------------------
	// Sort the commands by sequence number
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public static void Sort(ArrayList<FT_Action> cmds)
	{
		// don't bother sorting if there is just one item
		if(cmds.size() > 1 )
		{
			Collections.sort(cmds, new Comparator()
	        {
	       	 public int compare( Object a, Object b )
	           {
	           	return( ((FT_Action)a).getSeqNum() - ((FT_Action)b).getSeqNum());
	           }
	        } );
		}
	}
	//-------------------------------------------
	public String ToXml()
	{
		
		return ( 
				"<action version=" + StringUtils.QuoteString(getVersion())+				
				" name=" + StringUtils.QuoteString(getName()) +
				" guid=" + StringUtils.QuoteString(getGuid()) +
				" seqnum=" + StringUtils.QuoteString(Integer.toString(_seqNum)) + ">" +
				StringUtils.Base64Encode(_cmd) + "</action>" );		
	}
	
}
