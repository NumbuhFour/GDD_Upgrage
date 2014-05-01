package com.upgrage.components.physics {
	import Box2D.Dynamics.b2World;
	import Box2D.Common.Math.b2Vec2;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.upgrage.DialogBox;
	import Box2D.Dynamics.b2DebugDraw;
	import com.as3toolkit.ui.Keyboarder;
	import flash.ui.Keyboard;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import com.upgrage.*;
	import flash.utils.Dictionary;
	
	public class PhysicsWorld extends MovieClip{
		
		public static const DONE_LOADING:String = "DoneLoadingWorld";
		public static const TICK_WORLD:String = "TickWorld";
		public static const APPLY_GRAVITY:String = "DoGravity";
		public static const TRIGGER_CONTACT:String = "TriggerContact";

		public static const DEFAULT_GRAVITY:b2Vec2 = new b2Vec2(0,10);
		
		public static var DEBUG:Boolean = true;
		private var _wasQDown:Boolean = false;
		private var dbg:b2DebugDraw;
		private var level:uint;
		
		private var _scripts:Vector.<ScriptEvent>;
		
		private var _world:b2World;
		private var _stepTimer:Timer;
		private var _stepTime:Number = 0.055;
		
		private var _collisionHandler;
		
		private var _paused:Boolean = false;
		
		private var _currentFrame:Number = 0;
		
		public function PhysicsWorld() {
			start();
		}
		
		private function start():void{

			_world = new b2World(new b2Vec2(), true);
			_collisionHandler = new CollisionHandler(this);
			_world.SetContactListener(_collisionHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function loadScripts(){
			_scripts = ScriptParser.parser.loadNextLevel();
			for each (var script:ScriptEvent in _scripts)
				if (script.ScriptType == "UNLOCK"){
					var trig:PTrigger = (parent.getChildByName(script.Command) as PTrigger);
					trace("Command: " + script.Command + "\tTrigger: " + trig);
					(parent.getChildByName(script.Command) as PTrigger).disabled = true;
				}
			
		}
		
		private function onAdded(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			
			//Debugging
			dbg = new b2DebugDraw();
			dbg.SetSprite(new Sprite());
			dbg.SetDrawScale(this.pscale);
			dbg.SetFillAlpha(0.3);
			dbg.SetLineThickness(1.0);
			dbg.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_centerOfMassBit | b2DebugDraw.e_jointBit/* | b2DebugDraw.e_aabbBit*/);
			_world.SetDebugDraw(dbg);
			parent.addChild(dbg.GetSprite());
			this.addEventListener(Event.ENTER_FRAME,onEnter_Frame);
		}
		
		private function onEnter_Frame(e:Event):void{
			this.removeEventListener(Event.ENTER_FRAME,onEnter_Frame);
			_currentFrame = MovieClip(parent).currentFrame;
			stage.focus = stage;
			var i:int =0;
			for(i=0; i < parent.numChildren; i++){
				var c:DisplayObject = parent.getChildAt(i);
				if(c is PhysicsObj){
					var po:PhysicsObj = c as PhysicsObj;
					po.setInitialWorld(this);
				}
			}
			
			loadScripts();
			
			this.dispatchEvent(new Event(DONE_LOADING));
			_stepTimer = new Timer(stepTime);
			_stepTimer.addEventListener(TimerEvent.TIMER,onTick);
			_stepTimer.start();
			this.addEventListener(TRIGGER_CONTACT, onContact);
		}
		
		private function onTick(e:TimerEvent):void {
			
			if(!_paused){
				if(_hitExit){
					this._stepTimer.stop();
					MovieClip(parent).removeChild(dbg.GetSprite());
					start();
					MovieClip(parent.parent).nextFrame();
				}
				//_world.ClearForces();
				_world.Step(stepTime,10,10);
				this.dispatchEvent(new Event(APPLY_GRAVITY));
				this.dispatchEvent(new Event(TICK_WORLD));
			}
			
			/*if(parent == null || MovieClip(parent).currentFrame != _currentFrame){
				start();
			}*/
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
			
			//Debug controls
			if(Keyboarder.keyIsDown(Keyboard.M) && !_wasQDown) {
				DEBUG = !DEBUG;
				var g:Graphics = this.graphics;
				if(DEBUG){
					var sqr:Number = 200;
					var size:Number =  50;
					g.lineStyle(1, 0);
					for(var ix:Number = -size; ix < size; ix++){
						g.moveTo(ix*sqr,-size*sqr);
						g.lineTo(ix*sqr,size*sqr);
					}
					
					for(var iy:Number = -size; iy < size; iy++){
						g.moveTo(-size*sqr,iy*sqr);
						g.lineTo(size*sqr,iy*sqr);
					}
							
				}else{
					g.clear();
				}
			}
			_wasQDown = Keyboarder.keyIsDown(Keyboard.Q);
			if(DEBUG) _world.DrawDebugData();
			else dbg.GetSprite().graphics.clear();
		}

		//For handling collisions with the exit door
		private var _hitExit:Boolean = false;
		
		private function onContact(e:ContactEvent):void{
			if(e.colliding) { //Starting contact
				var scriptFound:Boolean = false;
				for each (var script:ScriptEvent in _scripts){
					if (script.TriggerID == e.triggerID && !(parent.getChildByName(e.triggerID) as PTrigger).disabled){
						scriptFound = true;
						switch(script.ScriptType){
							case "DIALOG": 
								{DialogBox(getChildByName("dialog")).pushText(script.Command); trace("yagr");
								break;}
							case "LEVEL_COMPLETE": _hitExit = true;
								break;
							case "UPGRADE": {	
								var arr:Array = e.target.Command.split(" ");			
								(parent.getChildByName("phys_player") as PPlayer).Upgrades[arr[0]] = arr[1]; }
								break;
							case "UNLOCK": {(parent.getChildByName(script.Command) as PTrigger).disabled = false; trace(script.Command + " unlocked");}
						}
					}
				}
				
				if(scriptFound){
					(parent.getChildByName(e.triggerID) as PTrigger).disabled = true;
				}
			}
			if(e.triggerID == "exit" && !_hitExit){
				//com.upgrage.DialogBox(getChildByName("dialog")).pushText("You did it!");
				_hitExit = true;
			}
		}
		
		public function pause():void { _paused = true; }
		public function unpause():void { _paused = false; }


		public function get pscale():Number { return 40; } // Pixels per meter ratio for the physics engine
		public function get w():b2World { return _world; }
		public function get stepTime():Number { return _stepTime; }
	}
	
}
