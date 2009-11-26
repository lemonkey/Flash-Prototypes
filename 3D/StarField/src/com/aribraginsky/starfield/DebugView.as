package com.aribraginsky.starfield 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.*;
	import flash.geom.Point;
	import flash.events.TimerEvent;
	
	/**
	 * ...
	 * @author Ari Braginsky
	 */
	public class DebugView extends Sprite
	{
		private var _txtStarCount:TextField = null;
		private var _txtDelStarIndex:TextField = null;
		private var _txtSpeed:TextField = null;
		private var _txtFPS:TextField = null;
		
		private var _lastTime:int = getTimer();
		private var _fpsFrameCount:uint = 0;
		private var _fpsFrames:Array = [];
		private var _fpsTimer:Timer = null;
		private var _fpsInterval:uint = 5;
		private var _fpsLastPoint:Point = new Point(70, 70);
		private var _fpsLines:Array = [];

		private var _parent:StarField = null;
		

		public function DebugView() 
		{			
			this._txtStarCount = new TextField();
			this._txtStarCount.width = 200;
			this._txtStarCount.x = this._txtStarCount.y = 5;
			this._txtStarCount.textColor = 0xFFFFFF;
			this._txtStarCount.mouseEnabled = false;
			this.addChild(this._txtStarCount);

			this._txtDelStarIndex = new TextField();
			this._txtDelStarIndex.width = 200;
			this._txtDelStarIndex.x = 5;
			this._txtDelStarIndex.y = 20;
			this._txtDelStarIndex.textColor = 0xFFFFFF;
			this._txtDelStarIndex.mouseEnabled = false;
			this.addChild(this._txtDelStarIndex);
			
			this._txtSpeed = new TextField();
			this._txtSpeed.width = 200;
			this._txtSpeed.x = 5;
			this._txtSpeed.y = 35;
			this._txtSpeed.textColor = 0xFFFFFF;
			this._txtSpeed.mouseEnabled = false;
			this.addChild(this._txtSpeed);

			this._txtFPS = new TextField();
			this._txtFPS.width = 200;
			this._txtFPS.x = 5;
			this._txtFPS.y = 50;
			this._txtFPS.textColor = 0xFFFFFF;
			this._txtFPS.mouseEnabled = false;
			this.addChild(this._txtFPS);

			this.addEventListener(Event.ADDED_TO_STAGE, this.init);
		}

		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init, false);
		
			this._parent = this.parent as StarField;
	
			this._fpsTimer = new Timer(1000);
			this._fpsTimer.addEventListener(TimerEvent.TIMER, this.tick);
			this._fpsTimer.start();
			
			this.addEventListener(Event.ENTER_FRAME, updateFrameCount);
		}
		
		private function updateFrameCount(e:Event):void
		{
			if (this._parent._isPaused)
				return;
				
			this._fpsFrameCount++;
		}

		private function tick(e:TimerEvent):void
		{
			if (this._parent._isPaused)
				return;
				
			this._fpsFrames.push(this._fpsFrameCount);
			
			if (this._fpsFrames.length > 0)
			{
				var avg:Number = 0;
				
				for (var i:uint = 0; i < this._fpsFrames.length; i++)
				{
					avg += this._fpsFrames[i];
				}
				
				avg /= this._fpsFrames.length;
				
				if (this._fpsFrames.length > this._fpsInterval)
					this._fpsFrames = [];
					
				this._txtFPS.text = "avg FPS: " + Math.round(avg);
				
				if (this._fpsLastPoint.x > this.stage.stageWidth)
				{
					for (var j:uint = 0; j < this._fpsLines.length; j++)
					{
						this.removeChild(this._fpsLines[j]);
					}
					
					this._fpsLines = [];
					this._fpsLastPoint.x = 70;
				}
				
				var newFPSPoint:Point = new Point(this._fpsLastPoint.x + 3, 70 - (Math.round(avg)));
				
				// Draw a line from last point to new point
				var fpsLine:Sprite = new Sprite();
				fpsLine.graphics.lineStyle(1, 0xFF0000);
				fpsLine.graphics.moveTo(this._fpsLastPoint.x, this._fpsLastPoint.y);
				fpsLine.graphics.lineTo(newFPSPoint.x, newFPSPoint.y);
				this.addChild(fpsLine);
				this._fpsLines.push(fpsLine);
				
				this._fpsLastPoint = newFPSPoint;
			}
			
			this._fpsFrameCount = 0;
		}
		
		private function unload(e:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.unload, false);
			this.removeEventListener(Event.ENTER_FRAME, this.updateFrameCount, false);
			
			this._fpsTimer.stop();
		}
		
		//{ Gettors/settors
		
		public function setStarCount(txt:String):void
		{
			this._txtStarCount.text = txt;
		}
		
		public function setSpeed(txt:String):void
		{
			this._txtSpeed.text = txt;
		}
		
		public function setDeletedStarIndex(txt:String):void
		{
			this._txtDelStarIndex.text = txt;
		}
		
		//}
	}

}