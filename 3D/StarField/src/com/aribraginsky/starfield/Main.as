package com.aribraginsky.starfield 
{
	import flash.display.MovieClip;
	import flash.events.*;

	public class Main extends MovieClip
	{
		
		public function Main() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init, false);
			this.addEventListener(Event.REMOVED_FROM_STAGE, unload);
			this.addEventListener(Event.ENTER_FRAME, loadProgress);
		}
		
		private function loadProgress(event:Event):void
		{
			// get bytes loaded and bytes total
			var mcBytesLoaded:int = this.root.loaderInfo.bytesLoaded;
			var mcBytesTotal:int = this.root.loaderInfo.bytesTotal;

			// convert to KB
			var mcKLoaded:int = mcBytesLoaded/1024;
			var mcKTotal:int = mcBytesTotal/1024;

			// update progress text, etc. here
			this.loader_mc.per_txt.text = (mcBytesLoaded / mcBytesTotal) * 100 + "%";

			// move on if done
			if (mcBytesLoaded >= mcBytesTotal) 
			{
				this.removeEventListener(Event.ENTER_FRAME, loadProgress);
				
				gotoAndStop("_loaded");
			}
		}

		private function unload(e:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, unload, false);
		}
	}
}