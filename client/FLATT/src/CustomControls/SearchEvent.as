package CustomControls
{
	import flash.events.Event;
	
	public class SearchEvent extends Event
	{
		public var query:String;
			
		public static const SEARCH_EVENT:String = "search";

		public function SearchEvent(type:String, value:String):void
		{
			super(type);
			this.query = value;
		}

	}
}