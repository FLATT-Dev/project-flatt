/*******************************************************************************
 * DB_Constants.java
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
package com.FLATT.Database;

public class DB_Constants {

	public static final String DBT_ACTION 		= "action";
	public static final String DBT_HISTORY 		= "history";
	public static final String DBT_HOST 		= "host";
	public static final String DBT_HOSTGRP 		= "hostgroup";
	public static final String DBT_PERMISSIONS	= "permissions";
	public static final String DBT_RESULT 		= "result";
	public static final String DBT_STATE 		= "state";
	public static final String DBT_VER 			= "version";
	public static final String DBT_TASK 		= "task";
	public static final String DBT_USERS 		= "user";
	public static final String DB_ASC			= " ASC";
	public static final String DB_DESC			= " DESC";
	public static final String ID_STATE_IN_PROGRESS = "1";
	public static final String ID_STATE_COMPLETED 	= "2";
	public static final String ID_STATE_PAUSED	 	= "3";
	public static final String ID_STATE_CANCELED 	= "4";
	public static final String ID_RESULT_OK		 	= "1";
	public static final String ID_RESULT_ERR		= "2";
	public static final String ID_RESULT_NA			= "3"; // canceled, no result
	public static final String ID_RESULT_CONN_ERR	= "4"; // connection error
	
	public static final String ID_PERM_LEVEL_0		= "1";
	public static final String ID_PERM_LEVEL_1		= "2";
	public static final String ID_PERM_LEVEL_2		= "3";
	
	public static final String ID_NO_TASK			= "1";
	public static final String ID_NO_GROUP			= "1";
	public static final String ID_DEF_USER			= "1";
	
	
	/* Some default values */
	
	public static final String  STR_DEF_GUID ="123";
	public static final String  STR_DEF_VERS = "1.0";
	
	public static final String	STR_DEF_TASK_NAME ="%TASK%";
	public static final String  STR_DEF_GRP_NAME = 	"%GRP%";
	public static final String  STR_DEF_USER = 		"%USR%";
	
	/* Some sleep time values used by the db manager code */
	public static final int WAIT_DB_INIT_SECS	= 45000; /*wait time for the database initialization */
	public static final int SLEEP_SECS_1		= 1000; /* just a couple of sleep  values */
	public static final int SLEEP_SECS_5		= 1000 * 5;
	public static final int SLEEP_SECS_10		= 1000 * 10;
	public static final String STR_QUOTE		= "'";
	public static final String STR_PAREN_OPEN   = "(";
	public static final String STR_PAREN_CLOSE  = ")";
	
	// JDBCPool constants
	
	public static final int JDBC_NUM_CONNECTIONS = 2;
	public static final int JDBC_MAX_CONNECTIONS = 5;
	
	public static final String DB_NAME = "ft_admin_db";
	public static final String MYSQL_URI = "jdbc:mysql://";
	
	
	
	
	private DB_Constants() 
	{
		// TODO Auto-generated constructor stub
	}
	

}
