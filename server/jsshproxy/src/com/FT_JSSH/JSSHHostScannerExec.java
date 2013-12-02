/*******************************************************************************
 * JSSHHostScannerExec.java
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

import java.net.*;
import java.nio.*;

import com.FLATT.Utils.*;

//import com.FLATT.Utils.*;

import net.schmizz.sshj.SSHClient;
import net.schmizz.sshj.transport.verification.PromiscuousVerifier;

public class JSSHHostScannerExec extends SSHExec 
{

	public JSSHHostScannerExec(JSSHProxyParams params,JSSHConnection parent) 
	{
		super(params,parent);
		// TODO Auto-generated constructor stub
	}
	
	/*  Parameters are only used by shell exec override
	 * 
	 */
	@Override
	public Boolean Execute(Boolean disconnectOnCompletion,Boolean readLoginPrompt)
	{	
		Boolean ret = true;
		int myNetAddr = 0;
		String curIP = "";
		SSHClient client;
		
		try 
    	{
    	   // Go through the range and try to connect on port 22. If successful-send the IP of the host.
    		InetAddress startIAddr = InetAddress.getByName(m_Params.getStartIP());
    		InetAddress endIAddr =  InetAddress.getByName(m_Params.getEndIP());
    		
    		int startAddr = ByteBuffer.wrap(startIAddr.getAddress()).getInt();
    		int endAddr = ByteBuffer.wrap(endIAddr.getAddress()).getInt();
    		// If start or end addr is zero - scan the subnet of the proxy server.
    		
    		if(startAddr == 0 || endAddr == 0)
    		{
    			
    			myNetAddr = ByteBuffer.wrap(InetAddress.getLocalHost().getAddress()).getInt();
    			startAddr  =  (myNetAddr & 0xFF000000)  |
    						  (myNetAddr & 0xFF0000)    |
    						  (myNetAddr & 0xFF00);
    						     			
    			
    			endAddr = startAddr | 0xFE;   			
    			// don't use the broadcast address 255
    		}
    		
    		//startAddr = 0xAC160100;
    		//endAddr = 0xAC16010A;
    		
    		//m_SSHClient.setConnectTimeout(m_Params.getScanConnectTimeout());
    		AppLog.LogIt("Start addr = " + InetRange.intToIp(startAddr),AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_CONSOLE);
    		AppLog.LogIt("End addr = " + InetRange.intToIp(endAddr),AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_CONSOLE);
    		do
    	    {    	    	   	    	
    			
    			try
    	    	{  			   	    		   	    		
    	    		// skip own addr
    	    		if(startAddr != myNetAddr)
    	    		{
	    	    		
    	    			if(getClientCanceled())
    	    			{
    	    				break;
    	    			}
    	    			// Try to connect to a host on port 22 (ssh). If succeeded
	    	    		//- send host IP back to the client
	    	    		curIP = InetRange.intToIp(startAddr);
	    	    
	    	    		client = CreateSSHClientObj();
	    	    		client.connect(curIP);
	    	    		client.disconnect();	    	    		    	    		
	    	    		
    	    		}
    	    	}
    			catch (Exception x)
    	    	{
    	    		// nobody home on port 22
    				// still send the empty IP to the client 
    				// so that the connection does not die.
    				// Seen cases where a long idle period kills 
    				// the connection even though keepalive is set
    				curIP = "";
    	    		String msg = x.getMessage();
    	    		if(msg == null)
    	    		{
    	    			msg = x.getLocalizedMessage();
    	    		}
    	    		
    	    		if(msg==null)
    	    		{
    	    			Throwable cause = x.getCause();
    	    			if(cause!=null)
    	    			{
    	    				msg = cause.getMessage();   	    				
    	    				
    	    			}
    	    			if(msg==null)
    	    			{
    	    				x.printStackTrace();
    	    			}
    	    			else
    	    			{
    	    				AppLog.LogIt("Exception in ssh client connect,printing cause message :"+msg,
    	    							  AppLog.LOG_LEVEL_ERROR,
    	    							  AppLog.LOGFLAGS_ALL);
    	    			}
    	    		}
    	    		else
    	    		{
    	    			;
    	    		}
    	    	}
    			// always send packet back even though IP is empty
    			// to prevent disconnect
    			AppLog.LogIt("Sending "+curIP,AppLog.LOG_LEVEL_INFO,AppLog.LOGFLAGS_CONSOLE);	    		
	    		m_ResponseObj.SendResponse(-1,
	    									"",
	    									curIP,
	    									SSHJResponse.STATUS_OK,
	    									SSHJResponse.RESP_TYPE_HOST_SCAN,
	    									-1);
    	    	client = null;
    	    	curIP = "";
    	    }
    	    while(startAddr++ <endAddr && !getClientCanceled());
   		
    	}
		catch (Exception e) 
    	{
			ret = false;
    	}  		
		return ret;
	}	
	//------------------------
	@Override
	public Boolean Connect()
	{		
		return true;
	}
	//----------------------------
	protected SSHClient CreateSSHClientObj()
	{		
		SSHClient client = new SSHClient();		
		try
		{ 
			// does not do server authentication! potentially dangerous 
			client.addHostKeyVerifier(new PromiscuousVerifier()); 
			client.setConnectTimeout(m_Params.getScanConnectTimeout());
		}
		catch(Exception e)
		{
			client = null;
		}
		return client;
	}
	
	// this object never needs scp
	@Override
	public Boolean NeedsScp()
	{
		return false;
	}	
	
	//==========================================================
	 static class InetRange 
	 {
	        public static int ipToInt(String ipAddress) 
	        {
	            try {
	                byte[] bytes = InetAddress.getByName(ipAddress).getAddress();
	                int octet1 = (bytes[0] & 0xFF) << 24;
	                int octet2 = (bytes[1] & 0xFF) << 16;
	                int octet3 = (bytes[2] & 0xFF) << 8;
	                int octet4 = bytes[3] & 0xFF;
	                int address = octet1 | octet2 | octet3 | octet4;

	                return address;
	            } catch (Exception e) 
	            {
	                e.printStackTrace();

	                return 0;
	            }
	        }

	        public static String intToIp(int ipAddress) 
	        {
	            int octet1 = (ipAddress & 0xFF000000) >>> 24; //unsigned right shift >>>>
	            int octet2 = (ipAddress & 0xFF0000) >>> 16;
	            int octet3 = (ipAddress & 0xFF00) >>> 8;
	            int octet4 = ipAddress & 0xFF;

	            return new StringBuffer().append(octet1).append('.').append(octet2)
	                                     .append('.').append(octet3).append('.')
	                                     .append(octet4).toString();
	        }
	    }

}
