/*******************************************************************************
 * ZG_FileUtils.as
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
package com.ZG.Utility
{
	
	import com.ZG.Events.*;
	
	import flash.errors.IOError;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.*;

	public class ZG_FileUtils extends ZG_EventDispatcher
	{
		private var _filePathOnly:Boolean = false;
		private var _maxNestingLevel:int;
		private var _curNestingLevel:int;
		private var _filePaths:Array;
		
		public function ZG_FileUtils(target:IEventDispatcher=null)
		{
		}
		// prompts user for file, reads it and returns the data
		public function BrowseReadFile(fileDescription:String,fileExtension:String, filePathOnly:Boolean = false):void
		{
			_filePathOnly = filePathOnly;// reading file or just getting file path
						
			var fileToOpen:File = new File();
			var txtFilter:FileFilter = new FileFilter(ZG_Utils.TranslateString("Supported formats"),"");
			
			if(fileExtension!= null && fileExtension.length > 0)
			{
				txtFilter.description = fileDescription;
				txtFilter.extension  = fileExtension;				
			}
			else
			{				
				txtFilter.description = ZG_Utils.TranslateString("All Files");
				txtFilter.extension = "*.*";
			}
						
			try 
			{
			    fileToOpen.browseForOpen("Open", [txtFilter]);
			    fileToOpen.addEventListener(Event.SELECT, OnTextFileSelected);
			    fileToOpen.addEventListener(Event.CANCEL,OnReadCancel);
			}
			catch (error:IOError)
			{
			    trace("BrowseReadFile Failed:", error.message);
				OnReadCancel(null);
			}
		}
	  //--------------------------------------------------------------------------	
		public function OnTextFileSelected(event:Event):void 
		{
		   if(_filePathOnly)
		   {		   		
		   		ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_READ_FILE_COMPLETE,event.target);
		   }
		   else
		   {
		    	/*var fileData:ZG_FileData = new ZG_FileData();
		    	fileData.data = ReadFile(File(event.target),true);// text file
				// Save some basic file info ata may be usful to the caller
		    	fileData.extension = File(event.target).extension;
				fileData.fileName = ZG_StringUtils.StripFileExtension(File(event.target).name);*/
			   
		    	ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_READ_FILE_COMPLETE,GetFileData(File(event.target)));
		   }
		}
		//--------------------------------------------------------------------------	
		public function OnReadCancel(event:Event):void
		{
			ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_READ_FILE_CANCEL);
		}
		//--------------------------------------------------------------------------	
		// a generic routine to read in a file and returns its data
		public static function ReadFile(theFile:File, isText:Boolean ):Object
		{
			
			var fileData:Object = null;
			var stream:FileStream = new FileStream();
			try
			{
				if( theFile!=null && theFile.exists )
				{
					
			   	 	stream.open(theFile, FileMode.READ);
			   	 	if( isText)
			   	 	{
			    		fileData =  stream.readUTFBytes(stream.bytesAvailable);
			   	 	}
			   	 	else
			   	 	{
			   	 		fileData = new ByteArray();
			   	 		stream.readBytes(ByteArray(fileData), 0, stream.bytesAvailable);
			   	 	}
			    	
			 	}
		 	}
		 	catch(err:IOError)
		 	{
		 		trace("Error reading file" + theFile.nativePath );
		 	}
		 	stream.close();
		 	
		    return fileData;
		}
		//--------------------------------------------------------------------------	
		public static function WriteFile(theFile:File, 
										 data:Object, 
										 isText:Boolean,
										 openMode:String/* = FileMode.WRITE*/):Boolean
		{
			// default to open mode write
			var stream:FileStream = new FileStream();
			var ret:Boolean = true;
			try
			{
			   	stream.open(theFile, openMode);
		   		if(isText)
		   		{
		   			stream.writeUTFBytes(data as String);
		   		}
		   		else
		   		{
		   			stream.writeBytes(ByteArray(data),0,data.length);
		   		}		   		
		 	}
		   	catch(error:IOError)
		   	{
		   		ret = false;
		   		trace ("Error writing file "+ theFile.nativePath);
		   	}
		   	
		   	stream.close();		   	
		   	return ret;
		}
		
		//-------------------------------------------------------------------
		/* copyTo give a security error copying from appDir to appStorageDir
		Per docs this should work. However creating files works
		TODO: Figure out
		*/
		public static function CopyFile(src:File,dest:File):void
		{
			//src.copyTo(src,false);
			try	
			{
				var bytes:ByteArray = new ByteArray();
				
				var fileStream:FileStream = new FileStream();
				fileStream.open(src, FileMode.READ);
				fileStream.readBytes(bytes,0,fileStream.bytesAvailable);
				fileStream.close();
				
				fileStream.open(dest, FileMode.WRITE);
				fileStream.writeBytes(bytes, 0, bytes.length);
				fileStream.close();
			}
				catch(e:Error)
			{
				trace("Copy Failed: src ="+ src.nativePath+",dest="+dest.nativePath);
			}
		}
		//---------------------------------------------------------------------
		// wrapper around FileReference.save that does not require return of the saved file
		// handle
		public static function SaveAs(data:Object,name:String = null):void
		{
			new FileReference().save(data,name);
		}
		//--------------------------------------------------
		// read a file into  ZG_FileData object
		public static function GetFileData(inputFile:File, isText:Boolean = true):ZG_FileData
		{
			var fileData:ZG_FileData = new ZG_FileData();
			fileData.data = ReadFile(inputFile,isText);// text file
			// Save some basic file info ata may be usful to the caller
			fileData.extension = inputFile.extension;
			fileData.fileName = ZG_StringUtils.StripFileExtension(inputFile.name);
			return fileData;
		}
		
		//--------------------------------------------------
		// Generic routine that creates a directory if it does not exist
		// and return file object
		public static function EnsureDirectory(dir:File,path:String):File
		{
			if(dir == null)
			{
				dir = File.applicationStorageDirectory.resolvePath(path);
				if (!dir.exists)
				{
					dir.createDirectory();
				}
			}
			return dir;
		}
		
		//-----------------------------------------------------------------
		public function BrowseWriteFile(data:String,name:String):void
		{
					
			try 
			{
				var fileRef:FileReference =  new FileReference();
				
				fileRef.addEventListener(Event.COMPLETE, OnSaveComplete);
				fileRef.addEventListener(Event.CANCEL,OnSaveCancel);
				fileRef.save(data,name);
			}
			catch (error:IOError)
			{
				trace("BrowseWriteFile Failed:", error.message);
				OnSaveCancel(null);
			}
		}
		//--------------------------------------------------------------------------	
		public function OnSaveCancel(event:Event):void
		{
			ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_SAVE_FILE_CANCEL);
		}
		//--------------------------------------------------------------------------	
		public function OnSaveComplete(event:Event):void
		{
			var file:File 
			ZG_Utils.ZG_DispatchEvent(this,ZG_Event.EVT_SAVE_FILE_COMPLETE, event.currentTarget as FileReference);
		}
		//-----------------------------------------------
		// iterate a directory and collect an array of paths 
		public function IterateDirectory(dir:File, nestingLevel:int):Array
		{
			_maxNestingLevel = nestingLevel;
			_filePaths = new Array();
			// may make nested calls 
			DoIterateDirectory(dir.getDirectoryListing());
			return _filePaths;
			
		}
		//----------------------------
		private function DoIterateDirectory(contents:Array):void		
		{		
			var savedNestingLevel:int = _curNestingLevel; // save current nesting level			
			for(var i: int = 0; i < contents.length; ++i)
			{
				var cur:File = contents[i] as File;
				if (cur!=null && !cur.isHidden)
				{						
					if(cur.isDirectory && savedNestingLevel < _maxNestingLevel )
					{
						// increment current level once for all directories at thks level
						if(savedNestingLevel == _curNestingLevel)
						{
							_curNestingLevel++;
						}
						DoIterateDirectory(cur.getDirectoryListing());
					}
					else
					{
						// it's a file - add path to list
						_filePaths.push(cur.nativePath);
					}
					
				}
			}
		}
		//----------------------------------------
		public static function GetEncodedSshKeyData(keyPath:String):String
		{
			var ret:String = "";
			// the key is really the path
			if(ZG_StringUtils.IsValidString(keyPath))
			{
				try
				{
					var f:File = new File(keyPath);
					if(f.exists)
					{
						ret = ZG_FileUtils.ReadFile(f,true) as String;
					}
				}
				catch(e:Error)
				{
					//maybe report this
				}
			}
			if(ret!="")
			{
				ret = ZG_StringUtils.Base64Encode(ret);
			}
			return ret;
		}
	
	}			
}
