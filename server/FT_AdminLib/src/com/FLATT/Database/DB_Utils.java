/*******************************************************************************
 * DB_Utils.java
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

import java.sql.*;

import com.FLATT.Utils.*;




// Miscellaneous dababase utilities
/* --select multiple tables
	select action.name, action.guid, state.name,
	history.start from action,state, h
	istory where state.id=history.state_id 
	and action.id=history.action_id 
	and history.id =1;
*/
public class DB_Utils 
{

	public DB_Utils() 
	{
		// TODO Auto-generated constructor stub
	}
	//--------------------------------------
	public static void CloseStatement(final Statement stmt)
 	{
 		if (stmt != null)
 		{
 			 try
 			 {
 				stmt.close();
 			 }
 			 catch (SQLException ex)
 			 {
 				//log.error(stmt, ex);
 			 }
 		}
 	}
	//--------------------------------------- 
	public static void CloseResultSet(final ResultSet rs)
 	{
 		if (rs != null)
 		{
 			 try
 			 {
 				rs.close();
 			 }
 			 catch (SQLException ex)
 			 {
 				//log.error(rs, ex);
 			 }
 		}
 	}
 /*
  * Generic routine to insert a row. Does a multi query to make sure that no other process gets the id of the just created row
  */
 	//----------------------------------------
 	public static String InsertRow(String strSql, String tableName) 
 	{
 		String ret = "";
 		Statement stmt = null;
 		ResultSet rs = null;
 		Connection conn = null;	
 		try
 		{
 			boolean hasMoreResultSets = false;
 			
 			conn = DB_Manager.GetInstance().getDbConnection();
 			conn.setAutoCommit(false);
 			/* We need the new id right away. This sql statement makes sure that the row is locked for reading and no other 
 			 * process can do a select to snatch a row id from underneath us. That's why everything is done in a transaction and select locks the row causing 
 			 * other processes to block until we commit
 			 */
 		
 			String sqlCmd = "Begin;" + strSql + "; Select max(id) from " + tableName + " FOR UPDATE;commit;"; 			
 			stmt = conn.createStatement();
 			hasMoreResultSets = stmt.execute(sqlCmd); 	
 			conn.commit();
 			
 			//TODO this may need to become a function
 			while ( hasMoreResultSets || stmt.getUpdateCount() != -1 ) 
 			{  
 		        if ( hasMoreResultSets ) 
 		        {  
 		            rs = stmt.getResultSet();
 		            if(rs.next())
 		            {
 		            	ret = rs.getString("max(id)");
 		            	break;
 		            } 		           
 		        } 
 		        else 
 		        { // if ddl/dml/...
 		            int queryResult = stmt.getUpdateCount();  
 		            if ( queryResult == -1 ) 
 		            { // no more queries processed  
 		                break;//READING_QUERY_RESULTS;  
 		            } // no more queries processed  
 		            // handle success, failure, generated keys, etc here
 		        } // if ddl/dml/...
 		        // check to continue in the loop  
 		        hasMoreResultSets = stmt.getMoreResults();  
 		    } // while results 			
 			
 		}
 		catch(Exception e)
 		{
 			AppLog.LogIt(("Error inserting row in table " + tableName + ": " +e.getMessage()), 
 							AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL);
 		}
 		finally
 		{
 			CloseStatement(stmt);
 			CloseResultSet(rs); 		
 			try
 			{
	 			conn.setAutoCommit(true);	
	 					
 			}
 			catch(SQLException ex)
 			{
 				AppLog.LogIt(("InsertRow: exception closing, table: " + tableName + ": " + 
 							ex.getMessage()), 
							AppLog.LOG_LEVEL_ALWAYS,
							AppLog.LOGFLAGS_ALL); 
 			}
 		}
 		return ret;
 
 	}
 	
 	/*
 	 * TODO: delete all rows if id is null or empty
 	 */
 	public static boolean DeleteRow(String rowId,String tableName)
 	{
 		boolean ret = false;
 		
 		PreparedStatement stmt = null;
 		Connection conn = null;	
 		boolean hasId = StringUtils.IsValidString(rowId);
 		try
 		{ 				
 			conn = DB_Manager.GetInstance().getDbConnection(); 	 
 			String sql = "delete from " + tableName;
 			
 			if(hasId)
 			{
 				sql += " where id=?" ;
 			}
 			stmt = conn.prepareStatement(sql);
 			if(hasId)
 			{
 				stmt.setString(1, rowId); 	
 			}
 			stmt.execute();  
 			ret = true;
 		}
 		catch(Exception e)
 		{
 			AppLog.LogIt(("Error DeleteRow row id " + rowId + " in table " + tableName + ": " +e.getMessage()), 
 																	AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL);
 		}
 		finally
 		{
 			CloseStatement(stmt); 			 			
 		}
 		return ret;
 		
 	}
 	//----------------------------
 	/* Generic, catch-all query.
 	 * Caller is responsible for formatting  the sql string
 	 * and closing the result set 
 	 */
 	public static ResultSet GenericQuery(String strSql )
 	{
 		PreparedStatement stmt = null;
 		ResultSet rs = null;
 		Connection conn = null;	
 	 		
 		try
 		{
 			conn = DB_Manager.GetInstance().getDbConnection();
 			stmt = conn.prepareStatement(strSql);			
 			rs = stmt.executeQuery();
 		}
 		catch(Exception e)
 		{
 			AppLog.LogIt(("GenericQuery: exception caught for sql: " + strSql + ": " +e.getMessage()), 
 					AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL); 
 		}
 		return rs;
 	}
 	//--------------------------------------------------------------
 	public static ResultSet FindBy(String table, String searchString)
 	{
 		return GenericQuery("Select * from " + table + " where " + searchString);
 	}
 	//--------------------------------------------------------------
 	public static boolean GenericUpdate(String sql)
 	{
 	 		boolean ret = false;
 	 		
 	 		PreparedStatement stmt = null;
 	 		Connection conn = null;	
 	 		try
 	 		{ 				
 	 			conn = DB_Manager.GetInstance().getDbConnection(); 	
 	 			conn.setAutoCommit(false);
 	 			stmt = conn.prepareStatement(sql);			
 	 			stmt.execute();  
 	 			conn.commit();
 	 			ret = true;
 	 		}
 	 		catch(Exception e)
 	 		{
 	 			AppLog.LogIt(("Error in GenericUpdate: " +e.getMessage() + " sql = " + sql), 
 	 						   AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL);
 	 		}
 	 		finally
 	 		{
 	 			CloseStatement(stmt); 		
 	 			try
 	 			{
 	 				conn.setAutoCommit(true);
 	 			}
 	 			catch(Exception e)
 	 			{
 	 				
 	 			}	 				 			
 	 		}
 	 		return ret;
 	 		
 	 }
 	//------------------------------------------------------------------------
 	// Same as update but with transaction
 	public static boolean GenericUpdateTx(String sql)
 	{
 		boolean ret = false;
 		
 		Statement stmt = null;
 		Connection conn = null;	
 		try
 		{ 				
 			conn = DB_Manager.GetInstance().getDbConnection(); 	
 			conn.setAutoCommit(false);
 			
 			String sqlCmd = "Begin;" + sql + (sql.endsWith(";")? "" : ";") + "commit;";			
 			stmt = conn.createStatement();
 			stmt.execute(sqlCmd); 	
 			
 			ret = true;
 		}
 		catch(Exception e)
 		{
 			AppLog.LogIt(("Error in GenericUpdate: " +e.getMessage() + " sql = " + sql), 
 						   AppLog.LOG_LEVEL_ALWAYS,AppLog.LOGFLAGS_ALL);
 		}
 		finally
 		{
 			CloseStatement(stmt); 		
 			try
 			{
 				conn.setAutoCommit(true);
 			}
 			catch(Exception e)
 			{
 				
 			}	 				 			
 		}
 		return ret;
 	 		
 	 }
 	
}
