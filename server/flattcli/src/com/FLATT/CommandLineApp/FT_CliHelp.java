/*******************************************************************************
 * FT_CliHelp.java
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

public class FT_CliHelp 
{

	public FT_CliHelp() 
	{
		// TODO Auto-generated constructor stub
	}
	/* Format the help for command line */
	public static String GetHelpString()
	{
		String ret = "Copyright 2013, FLATT Solutions (http://www.flattsolutions.com)\n\n"+
		"FLATT Command Line Client executes one or more scripts on hosts and optionally saves the execution file for later reuse.\n" +
		"Usage: java -jar flattcli.jar <parameters> or ftcli <parameters>\n" + 
		"ftcli is a script provided for your convenience, that launches flattcli.jar with the specified parameters.\n"+
		"Command Line Arguments:\n"+		
		"--help,-? or parameters omitted: Print help and exit.\n"+
		"--hosts: Space separated list of hosts to execute on. Username and password must be supplied.\n" +
		"--username:\n--password: User name and password used  to connect to hosts specified in the --hosts parameter.\n"+
		"  Also used as a master username / password for all hosts without one.\n"+
		"--sshkey: SSH key file to use with the --username. In this case password is ignored. Used as a master ssh key file for all hosts that don't have a password\n"+
		"--hostconfig: A configuration file to be used for all hosts. Individual hosts may override. Used as a master host config file for all hosts that don't have one.\n"+
		"--hosts-file: Path to the file that contains a list of hosts. See format description below.\n" +
		"--scripts: Space separated list of file paths to scripts to be executed.\n"+
		"--scripts-file: Path to a file that contains one or more paths to scripts to be executed.\n" +
		"--command: A simple command or a script to be executed on hosts.\n" +
		"--exec-name: The name of the automation file. When provided the execution request is saved and can be reused.\n"+
		"--exec-file: Path to previously created automation file. If this parameter is provided all others are ignored and automation file is run.\n"+
		"--dry-run: Don't execute automation, just create the file.This partameter is ignored if --exec-file parameter is provided.\n" +
		"  If no exec-name parameter is supplied the file name is auto-generated.\n" +
		"--loglevel: By default only errors logged. Set to 3 for verbose debug level logging.\n" + 
		"--simulation: When this flag is present, the program simulates execution without actually connecting to hosts and executing scripts.\n" +
		"Instead it goes through the list of hosts and prints out a string \"Simulated data from <host>\".\n" +
		"This is handy when you are trying out the program and don't want to execute anything on your hosts.\n\n" +
		"**NOTES**\n"+
		"1. Hosts file format is comma separated hostname or address, username, password,ssh key file and host config parameters file:\n" +
		"  [host],<username>,<password>,<ssh key path>,<config file path>. There is one host entry per line. Unused commas may be omitted\n\n" +
		"Examples:\n" +
		"192.168.1.1,user,mypass,\"ssh_key.pem\",\"hostconfig.txt\"\n" +
		"192.168.1.1,user,mypass,,\n" +
		"myhost.mydomain.com,,,,\n" +
		"192.168.1.1\n\n" +
		"2. If username or password are omitted, the program uses the ones supplied in --username and --password parameters.\n"+
		"3. Global ssh key file can be suplied with --sshkey flag. If provided it is used for all hosts that do not have a password.\n"+
		"4. Global host configuration file can be supplied with --hostconfig flag. If provided it is used for all hosts that do not have one.\n" +
		"  For more info on host configurations see the \"Host Configurations\" section of the client manual : http://flattsolutions.com/client-manual.htm\n" +		
		"5. If multiple scripts are provided they become a Task.\nSee the \"Tasks\" section of the client manual at http://flattsolutions.com/client-manual.htm\n" +
		"*****\n"+
		"SYSTEM REQUIREMENTS\n"+
		"Java v 1.6 or higher\n\n" +		
		"Please contact support@flattsolutions.com if you have any questions.";
		
				
		
		/* Parameters not described - TODO:
		 * --proxyaddr localhost 
			--proxyport 1111 			
			--sshkey ./sshkey.pem 	
			--dbuser _dbuser_ 
			--dbpass _dbpass_ 
			--dbaddr _dbaddr_  
		 */
		
		
		return ret;
	}

}
