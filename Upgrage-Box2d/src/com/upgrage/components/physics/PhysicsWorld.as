package com.upgrage.components.physics {
	import Box2D.Dynamics.b2World;
	import Box2D.Common.Math.b2Vec2;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class PhysicsWorld extends MovieClip{
		
		public static const DONE_LOADING:String = "DoneLoadingWorld";
		public static const TICK_WORLD:String = "TickWorld";
		public static const TRIGGER_CONTACT:String = "TriggerContact";
		public static const debug:Boolean = true;
		
		private var _world:b2World;
		private var _stepTimer:Timer;
		private var _stepTime:Number = 0.025;
		
		private var _collisionHandler;
		
		public function PhysicsWorld() {
			_world = new b2World(new b2Vec2(0,10), true);
			_collisionHandler = new CollisionHandler(this);
			_world.SetContactListener(_collisionHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			this.dispatchEvent(new Event(DONE_LOADING));
			_stepTimer = new Timer(stepTime);
			_stepTimer.addEventListener(TimerEvent.TIMER,onTick);
			_stepTimer.start();
		}
		
		private function onTick(e:TimerEvent):void {
			_world.ClearForces();
			_world.Step(stepTime,10,10);
			this.dispatchEvent(new Event(TICK_WORLD));
			/*for (var i:int = 0; i < this.numChildren; i++){
				var s:DisplayObject = this.getChildAt(i);
				if(s is PhysObj) {
					(s as PhysObj).onTick();
				}
			}*/
			
			//Delete bodies marked for deletion
			//for (var worldbody:b2Body = world.GetBodyList(); worldbody; worldbody = worldbody.GetNext()) {
                // if a body is marked as "remove"...
                //if (worldbody.GetUserData()=="remove") {
                    // ... just remove it!!
                    //world.DestroyBody(worldbody);
                //}
            //}
		}


		public function get pscale():Number { return 40; } // Pixels per meter ratio for the physics engine
		public function get w():b2World { return _world; }
		public function get stepTime():Number { return _stepTime; }
	}
	
}
