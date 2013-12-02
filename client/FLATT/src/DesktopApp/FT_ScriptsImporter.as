package DesktopApp
{
	import FLATTPlugin.*;
	
	import com.ZG.Events.ZG_EventDispatcher;
	import com.ZG.Utility.*;
	
	import flash.events.*;
	import flash.events.IEventDispatcher;
	import flash.filesystem.*;
	
	//Handles creating plugins from files in a directory and adding them to PlugnManager list
	// Directory name becomes category
	public class FT_ScriptsImporter extends ZG_EventDispatcher
	{
		public function FT_ScriptsImporter(target:IEventDispatcher=null)
		{
			super(target);
		}
		//-------------------------------------
		public function ImportScripts():void
		{
			var file:File = new File();
			file.addEventListener(Event.SELECT, OnDirSelected); 
			file.browseForDirectory("Import Actions from a directory"); 			
		}
		//
		protected function OnDirSelected(e:Event):void 
		{ 
			var f:File = e.currentTarget as File;
			if(f!=null)
			{
				trace(f.nativePath);
				f.addEventListener(FileListEvent.DIRECTORY_LISTING, DirListHandler);
				// start reading plugins from FS
				f.getDirectoryListingAsync();
			}
		}
		//------------------------------
		private function DirListHandler(event:FileListEvent):void		
		{
			var contents:Array = event.files;
			var dir:File = event.currentTarget as File;
			for(var i:int = 0; i < contents.length;++i)
			{
				var cur:File=contents[i];
				if(AllowedFileExtension(cur.extension))
				{
					var plugin:FT_Plugin = new FT_Plugin();
					plugin.category = dir.name;
					
					plugin.name=cur.name;
					
					trace("plugin name="+plugin.name);
					plugin.commandString= ZG_FileUtils.ReadFile(cur,true) as String;
					FT_PluginManager.GetInstance().Save(plugin);
				}
			}
		}
		// no extension is allowed
		public static function AllowedFileExtension(ext :String):Boolean
		{
			return( !ZG_StringUtils.IsValidString(ext) ||
					ext == "pl" 	||
					ext == "sh" 	||
					ext == "txt" 	||
					ext == "py"		||
					ext == "js"		||
					ext == "php" 	||
					ext == "scpt");	//AppleScript
		}
	}//class
		
}// pkg