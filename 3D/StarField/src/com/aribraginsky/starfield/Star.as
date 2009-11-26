/**
 * Star class
 * 
 * A sprite that represents a star to be part of the star field.
 *
 * @author Ari Braginsky (contact@aribraginsky.com)
 * @version 1.0
 * 
 * Created 2009/11/20
 */

package com.aribraginsky.starfield  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Star extends Sprite
	{
		private const W:uint = 20;
		private const H:uint = 20;
		
		private var _color:uint = 0xFFFFFF;		// color of star
		private var _vx:Number = 0;				// initial distance along X axis from current vanishing point
		private var _vy:Number = 0;				// initial distance along Y axis from current vanishing point
		private var _z:Number = 0;				// initial distance from near plane along Z axis
		private var _hasMoved:Boolean = false;	// If true, star has been displaced for the first times
		private var _isDead:Boolean = false;	// If true, will be removed when next updated
		private var _hasTrails:Boolean = false;	// If true, star can "streak" across the screen depending on speed
		private var _prevPoint:Point = null;	// Beginning point for trail segment
		private var _prevTrail:Sprite = null;	// Previous trail segment
		
		
		public function Star(vx:Number, vy:Number, z:Number, color:uint) 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, this.init);
			
			this._color = color;
			this._vx = vx;
			this._vy = vy;
			this._z = z;
			
			var pt:Sprite = new Sprite();
			pt.graphics.beginFill(this._color);
			pt.graphics.drawRect(-W/2, -H/2, W, H);
			pt.graphics.endFill();
			
			this.addChild(pt);
		}
		
		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.init, false);
			
			// Nothing to do when added to stage for now
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.unload);
 		}
		
		private function unload(e:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.unload, false);
			
			this.clearTrails();
		}
		
		private function clearTrails():void
		{
			if (this._prevTrail != null)
			{
				this.parent.removeChild(this._prevTrail);
				this._prevTrail = null;
			}
		}
		
		public function move(x:Number, y:Number):void
		{
			if(this._hasTrails)
				this.clearTrails();

			this._prevPoint = new Point(this.x, this.y);
			
			this.x = x;
			this.y = y;
		}
		
		//{ Gettors/settors
		
		public function get color():uint
		{
			return this._color;
		}
		
		public function get vx():Number
		{
			return this._vx;
		}
		
		public function set vx(val:Number):void
		{
			this._vx = val;
		}

		public function get vy():Number
		{
			return this._vy;
		}
		
		public function set vy(val:Number):void
		{
			this.vy = val;
		}

		public function get z():Number
		{
			return this._z;
		}
		
		public function set z(val:Number):void
		{
			this._z = val;
		}
		
		public function get isDead():Boolean
		{
			return this._isDead;
		}
		
		public function set isDead(val:Boolean):void
		{
			this._isDead = val;
		}
		
		public function get hasTrails():Boolean
		{
			return this._hasTrails;
		}
		
		public function set hasTrails(val:Boolean):void
		{
			this._hasTrails = val;
		}
		
		public function get prevPoint():Point
		{
			return this._prevPoint;
		}
		
		public function set prevTrail(val:Sprite):void
		{
			this._prevTrail = val;
		}
		
		//}
	}
}