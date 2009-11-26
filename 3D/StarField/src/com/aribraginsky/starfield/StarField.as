/**
 * StarField
 * 
 * Simulates a moving starfield of sprites
 * in 3D given a focal length, min/max Z depth, 
 * and a vanishing point 2D coordinate.
 * 
 * See http://www.youtube.com/watch?v=6heJBmgektA
 *
 * This is accomplished primarily by the use of the
 * scaling formula:
 * 
 * 	scale = fl / (fl + z)
 * 
 * where fl is the distance from the viewer to the
 * near plane and z is the distance from the
 * near plane to the object being rendered.  
 * 
 * The scale value affects both the scale of the object
 * and the distance from the vanishing point along
 * the XY axis.
 * 
 * @author Ari Braginsky (contact@aribraginsky.com)
 * @version 1.0
 * 
 * Created: 2009/11/20
 */

 package com.aribraginsky.starfield
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import flash.display.LoaderInfo;
	
	
	public class StarField extends Sprite 	
	{
		private const FOCALLENGTH:uint = 500;	// Distance from viewer to near plane
		private const VMIN:uint = 1;			// Min initial star displacement from vanishing point (for both X and Y)
		private const VMAX:uint = 25;			// Max initial star displacement from vanishing point (for both X and Y)
		private const ZSTARTMIN:uint = 2000;	// Min initial star Z coord (lower values are closer to viewer)
		private const ZSTARTMAX:uint = 25000;	// Max initial star Z coord 
		private const MINSPEED:uint = 10;		// Min speed of starfield
		private const MAXSPEED:uint = 700;// 1500;		// Max speed of starfield
		private const SPEEDSTEP:uint = 10;		// Amount starfield speed changed on up/down arrow
		private const MINTRAILSPEED:uint = 2;	// Minimum speed of star before trail can be shown
		private const MAXTRAILSPEED:uint = 200;	// Maximum speed of star at which a trail can be shown
		private const INITSTARS:uint = 200;		// Initial number of stars in the starfield
		private const MAXSTARS:uint = 350;// 10000;		// Maximum number of stars that can be added to the starfield
		private const STARSTEP:uint = 100;		// Number of stars to add/subtract with +/- keys
		
		private var _randColors:Boolean = true;	// If true, color of stars will be random.  Otherwise they'll be white.
		private var _speed:uint = 700;			// Initial speed of starfield
		private var _vpX:Number = 0;			// X coord of vanishing point
		private var _vpY:Number = 0;			// Y coord of vanishing point
		private var _stars:Array = [];			// Array of Star objects
		private var _showTrails:Boolean = true;	// If true, once higher speeds are reached, stars show trails.
		private var _debug:Boolean = true;		// If true, displays debug view that can be toggled
		private var _debugView:DebugView = null;
		
		internal var _isPaused:Boolean = false;

		
		public function StarField():void 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, this.init);
		}

		private function init(e:Event = null):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.unload);

			if(this._debug)
			{
				this._debugView = new DebugView();
				this.addChild(this._debugView);
			}
			
			// Initialize vanishing point coordinates to be
			// at the center of the stage
			this._vpX = stage.stageWidth / 2;
			this._vpY = stage.stageHeight / 2;
			
			// Initialize collection of star objects
			this.createStars(INITSTARS, true);
	
			// Update position of all visible star objects every frame
			this.addEventListener(Event.ENTER_FRAME, this.updatePosition);

			// Adjust speed of starfield when up/down arrows are pressed
			stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDown);
		}

		// Create n number of new star objects
		private function createStars(numStars:int, startup:Boolean):void
		{
			// On startup, spread stars out randomly along the Z axis.  
			// Otherwise, if starfield already populated, restrict 
			// each new star to be at the maximum Z distance from 
			// the viewer.

			for (var i:uint = 0; i < numStars; i++)
			{
				// Randomize initial displacement from vanishing point
				// in all 4 quadrants of the XY coordinate axes within
				// the min/max values
				var xSign:int = 1;
				var ySign:int = 1;
			
				if (Math.round(Math.random()) == 0)
					xSign *= -1;
				if (Math.round(Math.random()) == 0)
					ySign *= -1;

				var vx:Number = xSign * (0 + (VMAX - 0) * Math.random());
				var vy:Number;
				
				// We want to avoid having stars fly directly at the viewer
				if (vx < VMIN && vx > -VMIN)
				{
					vy = ySign * (VMIN + (VMAX - VMIN) * Math.random());
				}
				else
				{
					vy = ySign * (0 + (VMAX - 0) * Math.random());
				}

				var z:Number;
				
				// If starting up, limit Z coordinate between min/max values,
				// otherwise new stars created as others are deleted will always
				// start back at the max Z value
				if (startup)
				{
					// Randomize Z coordinate within min/max values
					z = ZSTARTMIN + (ZSTARTMAX - ZSTARTMIN) * Math.random();
				}
				else
					z = ZSTARTMAX;

				// Instantiate Star class
				var curStar:Star = new Star(vx, vy, z, (this._randColors ? Math.random() : 1) * 0xFFFFFF);

				// Apply initial scale/vanishing point displacement
				this.applyPerspective(curStar);

				// Add new star to the screen
				this.addChild(curStar);

				// Add new star to current collection of stars
				this._stars.push(curStar);
			}
		}
		
		// Adjust star scale and displacement from vanishing point
		private function applyPerspective(star:Star):void	
		{
			var scale:Number = FOCALLENGTH / (FOCALLENGTH + star.z);

			star.scaleX = star.scaleY = scale;
			
			// Apply new scale to initial displacement of 
			// star on both X and Y axes
			//star.x = this.vpX + (star.vx * this.vpX) * scale;
			//star.y = this.vpY + (star.vy * this.vpY) * scale;
			star.move((this._vpX + (star.vx * this._vpX) * scale), (this._vpY + (star.vy * this._vpY) * scale));

			var drawTrails:Boolean = false;
			
			if (star.hasTrails && star.prevPoint.x != 0 && star.prevPoint.y != 0 && star.x != 0 && star.y != 0)
			{
				var dx:Number = (star.x - star.prevPoint.x);
				var dy:Number = (star.y - star.prevPoint.y);
				var starSpeed:Number = Math.sqrt(dx * dx + dy * dy);
	
				// Only draw trails if speed is within a certain threshold
				// or else the display of the trails at certain speeds
				// tends to break down.
				if(starSpeed > MINTRAILSPEED && starSpeed < MAXTRAILSPEED)
					drawTrails = true;
			}
			
			if(drawTrails)
			{
				var addTrail:Sprite = new Sprite();
				addTrail.graphics.lineStyle(2, star.color);
				
				addTrail.graphics.moveTo(star.prevPoint.x, star.prevPoint.y);
				addTrail.graphics.lineTo(star.x, star.y);
				
				this.addChild(addTrail);
				star.prevTrail = addTrail; 
			}
		}
		
		// Remove each star that goes outside field of view or
		// move each star along Z axis and adjust scale and
		// displacement from vanishing point
		private function updatePosition(e:Event):void
		{
			if (this._isPaused)
			{
				this._debugView.setStarCount("-- PAUSED --");
				return;
			}
			
			if (this._debug)
			{
				this._debugView.setStarCount("stars: " + this._stars.length);
				this._debugView.setSpeed("speed: " + this._speed);
			}

			for (var i:uint = 0; i < this._stars.length; i++)
			{
				var curStar:Star = this._stars[i];
			
				// Marked for deletion (del key)
				if (curStar.isDead)
				{
					this.removeStar(curStar, i, false);
				}
				else
				{
					// Behind or at near view
					if (curStar.z <= -FOCALLENGTH || (curStar.z + FOCALLENGTH == 0))
					{
						this.removeStar(curStar, i, true);
					}
					else
					{
						// In order to have a better sense of speed, those
						// stars that are closer to the viewer should appear
						// to be moving faster than those farther away
						var distFromVP:Number = Math.sqrt((curStar.x - this._vpX) * (curStar.x - this._vpX) + (curStar.y - this._vpY) * (curStar.y - this._vpY));
						
						if (curStar.z < ZSTARTMIN + 2000 || distFromVP > 50)
						{
							if(this._showTrails)
								curStar.hasTrails = true;

							var maxStarSpeed:uint =  2 * this._speed;
							curStar.z -= maxStarSpeed;
						}
						else
						{
							curStar.z -= this._speed;
						}

						this.applyPerspective(curStar);
					}
				}
			}
		}
		
		// Removes given star object from screen and
		// star arraylist and then generates a new
		// random star object to replace it
		private function removeStar(star:Star, i:uint, createNew:Boolean):void
		{
			if (this._debug)
			{
				this._debugView.setDeletedStarIndex("deleting star index: " + i);
			}

			try
			{
				this.removeChild(star);

				if (this._stars.length > 0 && i < this._stars.length)
				{
					this._stars.splice(i, 1);
				}
				
				if(createNew)
					this.createStars(1, false);
			}
			catch (e:Error)
			{
				trace("ERROR: " + this + ": " + e.message);
			}
		}
		
		// Handle key events
		private function keyDown(e:KeyboardEvent):void
		{
			if (this._debug)
			{
				switch(e.keyCode)
				{
					// Increase speed of starfield
					case Keyboard.UP:
					{
						if (this._speed + SPEEDSTEP < MAXSPEED)
							this._speed += SPEEDSTEP;
						else	
							this._speed = MAXSPEED;
							
						break;
					}
					
					// Decrease speed of starfield
					case Keyboard.DOWN:
					{
						if (this._speed - SPEEDSTEP > MINSPEED)
							this._speed -= SPEEDSTEP;
						else
							this._speed = MINSPEED;
							
						break;
					}
					
					/*
					case Keyboard.LEFT:
					{
						this.vpX--;
						break;
					}
					case Keyboard.RIGHT:
					{
						this.vpX++;
						break;
					}
					*/
					
					// Add a new star
					case Keyboard.NUMPAD_ADD:
					{
						if(this._stars.length + STARSTEP <= MAXSTARS)
							this.createStars(STARSTEP, true);
					
						break;
					}
					
					// Remove most recent stars
					case Keyboard.NUMPAD_SUBTRACT:
					{
						for (var i:uint = 0; i < STARSTEP; i++)
						{
							var deadStarIndex:uint = this._stars.length - 1 - i;
							
							if (deadStarIndex >= 0 && this._stars.length > 0)
							{
								var curStar:Star = this._stars[this._stars.length - 1 - i] as Star;
								
								if(curStar != null)
									curStar.isDead = true;
								else
								{
									//trace("curStar to be removed has already been removed!");
								}
							}
							else
							{
								//trace("Out of bounds when removing stars!");
							}
						}
						
						break;
					}
									
					// Clear all stars
					case Keyboard.DELETE:
					{
						this.deleteAllStars(false);
						break;
					}
					
					// Resets starfield
					case Keyboard.SPACE:
					{
						this.deleteAllStars(true);
						break;
					}
					
					// 'd' key
					// Toggle debug view
					case 68:
					{
						this._debugView.visible = !this._debugView.visible;
						break;
					}
					
					// 'p'
					// Toggle pause
					case 80:
					{
						this._isPaused = !this._isPaused;
						break;
					}
					
					// 't'
					// Toggle trails
					case 84:
					{
						this._showTrails = !this._showTrails;
						break;
					}
				}
			}
		}

		// Marks all current stars as dead so that they're 
		// removed on the next position update
		private function deleteAllStars(createAllWhenDone:Boolean):void
		{
			for (var i:uint = 0; i < this._stars.length; i++)
			{
				var curStar:Star = this._stars[i] as Star;
				
				if (curStar != null)
					curStar.isDead = true;
			}
			
			if (createAllWhenDone)
				this.createStars(INITSTARS, true);
		}

		// Cleans up event listeners
		private function unload(e:Event = null):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.unload, false);

			stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.keyDown, false);
			stage.removeEventListener(Event.ENTER_FRAME, this.updatePosition, false);
		}
	}
}