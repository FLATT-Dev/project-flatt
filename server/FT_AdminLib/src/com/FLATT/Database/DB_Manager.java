/*******************************************************************************
 * DB_Manager.java
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

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

import com.FLATT.Utils.*;


public  class DB_Manager
{
	// called early on to init the database
	// TODO: what to do if the version is different??
	
	private static final int DB_NOERR = 0;
	/* our errs are negative - if needed
	 *
	 */
	// real mysql errors
	private static final int DB_ERR_NO_DB = 1049; // this is 
	
	
	private Connection _dbConnection;
	private String 	_dbUrl = "";
	private String _lastErr = "";
	private static DB_Manager _dbManager;
	
	
	
	
	private DB_Manager()
	{
		
	}
	
	public static DB_Manager GetInstance()
	{	
		
		if(_dbManager == null )
		{
			_dbManager = new DB_Manager();			
		}		
		
		return _dbManager;
	}
	//--------------------------------------
	public  void InitDatabase(String dbAddr, String username,String password) throws Exception
	{	
		try
		{
			// first see if the class can be loaded - cannot proceed without this.
			Class.forName("com.mysql.jdbc.Driver");	
			
			// make sure the URL does not contain protocol identifiers
			_dbUrl = DB_Constants.MYSQL_URI + StringUtils.CleanupUrl(dbAddr);
			
			int connRes = ConnectToDatabase(username,password);
			
			if(!_lastErr.isEmpty())
			{
				AppLog.LogIt(_lastErr,AppLog.LOG_LEVEL_ERROR, AppLog.LOGFLAGS_ALL);
			}
			switch (connRes)
			{		
				case DB_ERR_NO_DB:
					 CreateDatabase( username, password);
					break;
			}
		}
		catch(ClassNotFoundException e)
		{
			 _lastErr = "ConnectToDatabase = Failed to load mysql driver";			  					
		}
	}
	//-----------------------------------
	public void DisconnectDatabase()
	{
		if(_dbConnection!=null)
		{
			try
			{
				getDbConnection().setAutoCommit(false);
				getDbConnection().commit();
				getDbConnection().close();
			}
			catch(Exception e)
			{
				
			}
		}
	}
	//----------------------------------
	protected int ConnectToDatabase( String username, String passwd)
	{
		 int ret = DB_NOERR;
		 try 
		 {
		    _dbConnection = DriverManager.getConnection(_dbUrl+"/"+DB_Constants.DB_NAME + "?allowMultiQueries=true",username, passwd);
		  
		 }
		 catch (SQLException sqlex)
		 {			 
			 ret  = sqlex.getErrorCode();			
			 if(ret!= DB_ERR_NO_DB)
			 {
				 _lastErr = "Exception connecting to database: "+ sqlex.getMessage();
			 }
			 else
			 {
				 _lastErr = "Database does not exist - will create";
			 }			
		 }		 
		 
		 return ret;	                
	}
	//----------------------------------------------
	
	protected Boolean CreateDatabase(String username,String password) throws Exception
	{
		
		Statement statement = null;
		Connection conn = null;
				
		try
		{
			conn = DriverManager.getConnection(_dbUrl,username, password);
			statement = conn.createStatement();
			statement.executeUpdate("Create Database " + DB_Constants.DB_NAME);
			statement.close();
			conn.close();
			if(ConnectToDatabase(username,password) == DB_NOERR)
			{				
				DbMaintenance(username, password);
			}
			else
			{
				AppLog.LogIt(_lastErr,AppLog.LOG_LEVEL_ERROR, AppLog.LOGFLAGS_ALL);
			}				
			
		}
		catch(SQLException ex)
		{
			System.out.println("Sql Exception creating database :" + ex.getMessage());		
		}
		
		return (_dbConnection !=null);
		
	}
	// performs database maintenance - either creation or update
	protected void DbMaintenance(String username, String password) throws Exception
	{
		
		String[] sqlCmds = ReadSchema();
		Statement statement = _dbConnection.createStatement();
		// executing a batch - set to false;
		_dbConnection.setAutoCommit(false);
		for( int i = 0 ; i < sqlCmds.length ; ++i)
		{
			// skip sql comments
			if(!sqlCmds[i].startsWith("-- "))
			{
				statement.addBatch(sqlCmds[i]);
			}
		}
		statement.executeBatch();
		_dbConnection.commit();
		_dbConnection.setAutoCommit(true);	
	}
	//---------------------------------------------4
	
	protected String[] ReadSchema() throws Exception
	{
		String sqlString = "";
		DataInputStream in = new DataInputStream(this.getClass().getResourceAsStream(DB_Constants.DB_NAME + ".sql"));
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		String strLine;
		// Read File Line By Line
		while ((strLine = br.readLine()) != null) {
			sqlString += strLine;
		}
		// Close the input stream
		in.close();
		
		
		/*URL url = this.getClass().getResource(DB_NAME + ".sql");
		 
		String sqlString = null;
		if(url!=null)
		{
			String strUrl = url.toString();
			if(strUrl.contains("jar:file:"))
			{
				strUrl = GetSchemaPathFromJar();
			}
			
			File schemaFile = new File(strUrl);	
			sqlString = FT_FileUtils.ReadFile(schemaFile);			
		}*/
		return sqlString.split(";");		
	} 
	//-----------------------------------------------
	public Connection getDbConnection()
	{
		return _dbConnection;
	}
	//-----------------------------------------------
	public String get_lastErr() 
	{
		return _lastErr;
	}
	//-------------------------------------
	/*protected String GetSchemaPathFromJar()
	{
		String ret = StringUtils.GetJarFolderPath(this.getClass()) + DB_NAME + ".sql";
		return ret;
	}	*/
}
