package CustomControls.Quickstart
{
	public class FT_QuickStart
	{
		protected static var SPAN_NORMAL:String = "<span class='FontNormal9'>";
		protected static var SPAN_HEADING1:String = "<span class='Heading1'>";
		protected static var SPAN_HEADING2:String = "<span class='Heading2'>";
		protected static var LI_START:String =" {ul li {margin-top: 10px;}}"

		protected static var ROW_START:String="<tr>";
		protected static var ROW_END:String = "</tr>";
		protected static var COL_START:String="<td>"
		protected static var COL_END:String="</td>";
		protected static var SINGLE_ROW_START:String=ROW_START+COL_START;
		protected static var SINGLE_ROW_END:String =COL_END+ROW_END;
		
		
		protected static var SPAN_CLOSE:String = "</span>";
		
		protected static var STYLE_DEF:String ="<style type='text/css'>"+
			"span.Heading1 {color:black;font-weight:bold;font-size:10pt}"+
			"span.Heading2 {color:black;font-weight:bold;font-size:9pt}" +
			"span.FontNormal9 {font-weight:normal;font-size:9pt}" + 
			" </style>";
		
		private static var _htmlString:String = "<body>"
			+STYLE_DEF + 
			"<Table align=\"center\" cellspacing=\"3px\">" + 
			SINGLE_ROW_START + SPAN_HEADING1 +
			"Getting Started with FLexible Automation and Troubleshooting Tool ( FLATT )"+
			SPAN_CLOSE + SINGLE_ROW_END +
			
			SINGLE_ROW_START+
			"<hr>" + 
			SINGLE_ROW_END +
				
			SINGLE_ROW_START + SPAN_NORMAL+			
			"Before you begin, you need to add hosts that you will administer and add scripts, called <b>Actions</b> in FLATT, " +
			"that you will run on those hosts." + 
			SPAN_CLOSE + SINGLE_ROW_END+			
			
			SINGLE_ROW_START+SPAN_HEADING2+			
			"Adding Hosts" 
			+ SPAN_CLOSE +SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_NORMAL +			
			"You can add hosts to FLATT in multiple ways:" + 
			SPAN_CLOSE + SINGLE_ROW_END +
		
			SINGLE_ROW_START+SPAN_NORMAL+
			"<ul>" +
			"<li >" +
			"Click <b>Scan</b> button in the <b>Hosts and Groups</b> View to scan local network "+
			"for hosts that support ssh. You can define the address range to scan in the <b>Tools->Options</b> dialog. " +
			"</li></ul>" +
			
			"<ul><li>"+
			"Import from a file: either drag a hosts file on the <b>Hosts and Groups</b>  pane or click <b>Import</b> "+
			"button and select <b>Host Group</b> from the menu. " +
			"Please refer to <b>FLATT Client Manual</b> for hosts file format description." +		
			"</li></ul>" +
			
			"<ul><li>"+
			"Define manually: Right-click in the <b>Hosts and Groups</b> pane and select <b>New Host</b> "+
			" or <b>New Group</b> or select from the <b>New</b> button menu."+
			"</li>" +
			"</ul>"+				
			SPAN_CLOSE + SINGLE_ROW_END +
			
			
			SINGLE_ROW_START+SPAN_HEADING2+			
			"Adding Scripts" 
			+ SPAN_CLOSE +SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_NORMAL +			
			"There are several ways to add scripts:" + 
			SPAN_CLOSE + SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_NORMAL +	
			"<ul>" +
			"<li >" +
			"Import Scripts folder using <b>Import</b> button. The folder name becomes Action category" +
			"</li>" +
			"</ul>"+			
			SPAN_CLOSE +SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_NORMAL +	
			"<ul>" +
			"<li >" +
			"Manually create using <b>Tools->Action Editor</b> dialog." +
			"</li>" +
			"</ul>"+			
			SPAN_CLOSE +SINGLE_ROW_END +
			
			
			SINGLE_ROW_START+SPAN_HEADING2+			
			"Tasks" 
			+ SPAN_CLOSE +SINGLE_ROW_END +
			SINGLE_ROW_START + SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_NORMAL +				
			"A Task is a collection of Actions that executes sequentially and stops on error." +					
			SPAN_CLOSE +SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_NORMAL +				
			"To create a Task drag an action onto the Task pane. Add as many Actions as needed. Drag to rearrange the order of execution." +	
			
			SPAN_CLOSE +SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_HEADING2+			
			"Executing Actions and Tasks on Hosts" 
			+ SPAN_CLOSE +SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_NORMAL +	
			"<ul>" +
			"<li >" +
			"Drag an Action or a Task on a host or host group icon." + 
			"<b> NOTE. This is the only method to execute tasks</b>" + 
			"</li>" +
			"</ul>"+
			
			"<ul>" +
			"<li>" +
			"Double click on an Action to select the host to execute on. " +
			"</li>" +
			"</ul>"+
			SPAN_CLOSE +SINGLE_ROW_END +
			
			SINGLE_ROW_START+SPAN_NORMAL +	
			"<b>Please contact support@flattsolutions.com if you have any questions</b>" + 
			SPAN_CLOSE +SINGLE_ROW_END +
			
			"</TABLE>"+
			"</body>";
		
		
		public function FT_QuickStart()
		{
		}
		
		public static function GetHtml():String
		{
			return _htmlString;
		}
		
	}
}