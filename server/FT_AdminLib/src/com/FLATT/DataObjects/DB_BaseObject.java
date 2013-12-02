/*******************************************************************************
 * DB_BaseObject.java
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
package com.FLATT.DataObjects;

public abstract class DB_BaseObject
{
	protected String _id = "";
	protected String _name = "";
	protected String _desc = "";
	
	//-------------------------------------------------------
	public DB_BaseObject()
	{
		// default ctor
		
	}
	public DB_BaseObject(String id, String name, String desc)
	{
		_id = id;
		_name = name;
		_desc = desc;
	}
	
	public String getId()
	{
		return _id;
	}
	//--------------------------
	public String getName()
	{
		return _name;
	}
	//----------------------
	public void setName(String val)
	{
		_name = val;
	}
	//----------------------
	public String getDesc()
	{
		return _desc;
	}
	//-----------------------------------------
	public void Copy(DB_BaseObject src)
	{
		_id = src.getId();
		_name = src.getName();
		_desc = src.getDesc();
	}
	//-------------------------------------
	// subclasses override
	public boolean IsValid()
	{
		return true;
	}
	//--------------------------------------
	protected void SetDefaults()
	{
		// set class specfic defaults of the object
	}
	
}
