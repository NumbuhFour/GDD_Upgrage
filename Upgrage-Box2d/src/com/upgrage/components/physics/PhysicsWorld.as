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
	import com.upgrage.components.*;
	import flash.utils.Dictionary;
	import Box2D.Dynamics.b2Body;
	import com.upgrage.events.ContactEvent;
	import flash.text.TextField;
	
	public class PhysicsWorld extends MovieClip{
		
		public static const DONE_LOADING:String = "DoneLoadingWorld";
		public static const TICK_WORLD:String = "TickWorld";
		public static const TRIGGER_CONTACT:String = "TriggerContact";

		public static const DEFAULT_GRAVITY:b2Vec2 = new b2Vec2(0,10);
		
		public static var DEBUG:Boolean = true;
		private var _wasQDown:Boolean = false;
		private var _wasPDown:Boolean = false;
		private var _wasMDown:Boolean = false;
		private var dbg:b2DebugDraw;
		private var _breathing:Boolean = true;
		private var _bodyChecked:Boolean; // player body triggers multiple contacts, checks for that
		private var level:uint;
		private var _numEnemies:int;
		private var _motionBombState:String = "";
		
		private var _scripts:Vector.<ScriptEvent>;
		private var _events:Vector.<CustomEvent>;
		private var _bodiesToRemove:Vector.<b2Body>;
		private var _timer:LevelTimer;
		private var _bubbles:Vector.<Bubble>;
		private var _player:PPlayer;
		
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

			_bodiesToRemove = new Vector.<b2Body>();
			_world = new b2World(new b2Vec2(), true);
			_collisionHandler = new CollisionHandler(this);
			_world.SetContactListener(_collisionHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function loadScripts(){
			_scripts = ScriptParser.parser.loadNextLevel();
			for each (var script:ScriptEvent in _scripts)
				if (script.ScriptType == "UNLOCK"){
					if (script.Command == "enemyLock"){
						(parent.getChildByName(script.TriggerID) as PTrigger).disabled = true;
						(parent.getChildByName(script.TriggerID) as PTrigger).enemyLocked = true;
					}
					else
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
			_numEnemies = 0;
			var i:int =0;
			for(i=0; i < parent.numChildren; i++){
				var c:DisplayObject = parent.getChildAt(i);
				if(c is PhysicsObj){
					var po:PhysicsObj = c as PhysicsObj;
					po.setInitialWorld(this);
				}
				else if (c is CustomEvent)
					_events.push(c);
				if (c is Enemy)
					_numEnemies ++;
			}
			
			loadScripts();
			_player = (parent.getChildByName("phys_player") as PPlayer);
			_timer = new LevelTimer();
			
			this.dispatchEvent(new Event(DONE_LOADING));
			_stepTimer = new Timer(stepTime);
			_stepTimer.addEventListener(TimerEvent.TIMER,onTick);
			_stepTimer.start();
			this.addEventListener(TRIGGER_CONTACT, onContact);
			//this.addEventListener(
		}
		
		private function onTick(e:TimerEvent):void {
			
			if(!_paused){
				_bodyChecked = false;
				if(_hitExit){
					this._stepTimer.stop();
					cleanup();
					MovieClip(parent).removeChild(dbg.GetSprite());
					start();
					MovieClip(parent.parent).nextFrame();
				}
				//_world.ClearForces();
				_world.Step(stepTime,10,10);
				this.dispatchEvent(new Event(TICK_WORLD));
				
				for each (var b:b2Body in _bodiesToRemove){
					_world.DestroyBody(b);
				}
				_bodiesToRemove = new Vector.<b2Body>()
				//if (_timer.isRunning && _timer.ClockMode)
				//	((parent.getChildByName("timer") as MovieClip).getChildByName("textField") as TextField).text = _timer.SecondsLeft.toString();
				if (!_timer.isRunning){
					if (_player.Upgrades["motion bomb"]){
						_motionBombState = "green"
						_timer.StartTime = Math.random() * 5000 + 5000;
						_timer.reset();
						_timer.start();
					}
				}
				if (_timer.isRunning && !_timer.isPaused){
					trace(_timer.TimeLeft);					
					if (_timer.TimeLeft <= 0){
						if (!_breathing) die();
						if (_player.Upgrades["motion bomb"]){
							if (_motionBombState == "green"){
								_motionBombState = "orange";
								_timer.StartTime = 2000;
							}
							else if (_motionBombState == "orange"){
								_motionBombState = "red";
								_timer.StartTime = 2000;
							}
							else if (_motionBombState == "red"){
								_motionBombState = "green";
								_timer.StartTime = Math.random() * 5000 + 5000;
							}
							_timer.reset();
							_timer.start();
							trace(_motionBombState);
						}
						if (_player.Upgrades["time bomb"]){
							die();
						}
					}
				}
				if (_motionBombState == "red"){
					if (_player.checkMovement())
						die();
				}
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
			//menu controls
			//might want to let P close menu as well
			if (Keyboarder.keyIsDown(Keyboard.P) && !_wasPDown && !_paused){
					((parent.parent as MovieClip).getChildByName("menu") as PauseMenu).show();
			}
			_wasQDown = Keyboarder.keyIsDown(Keyboard.Q);
			_wasMDown = Keyboarder.keyIsDown(Keyboard.M);
			_wasPDown = Keyboarder.keyIsDown(Keyboard.P);

			if(DEBUG) _world.DrawDebugData();
			else dbg.GetSprite().graphics.clear();
		}

		//For handling collisions with the exit door
		private var _hitExit:Boolean = false;
		
		private function onContact(e:ContactEvent):void{
			if(e.colliding) { //Starting contact
				trace("Trigger hit: " + e.triggerID);
				//checks for entering and leaving breathing spaces, deals with timers
				if (!_player.Upgrades["fishbowl"] && e.collider.GetBody().GetUserData() is PDampSpace && !_bodyChecked){
					_bodyChecked = true;				
					if (_player.Upgrades["toaster"])
						die();
					if (!_player.Upgrades["gills"] ){
						_breathing = false;
						_timer.StartTime = 5000; // timer for drowning
						_timer.start();
					}
					else {
						_breathing = true;
					}
				}
				
				if(checkScript(e.triggerID)){
					(parent.getChildByName(e.triggerID) as PTrigger).disabled = true;
				}
			}
			else if (!e.colliding){
				//checks for entering and leaving breathing spaces, deals with timers
				if (!_player.Upgrades["fishbowl"] && e.collider.GetBody().GetUserData() is PDampSpace && !_bodyChecked){
					_bodyChecked = true;					
					if (_player.Upgrades["gills"] ){
						_breathing = false;
						_timer.StartTime = 5000; // timer for "fish out of water"
						_timer.start();
					}
					else {
						_breathing = true;
					}
				}
			}
			if(e.triggerID == "exit" && !_hitExit && !(parent.getChildByName("exit") as PTrigger).enemyLocked){
				_hitExit = true;
			}
		}
		
		private function checkScript(trigger:String):Boolean{
			var lockTrigger:Boolean = false;
			for each (var script:ScriptEvent in _scripts){
				if (script.TriggerID == trigger && (script.Command) == "enemyLock"){
					if (_numEnemies <= 0){
						(parent.getChildByName(script.TriggerID) as PTrigger).disabled = false;
						(parent.getChildByName(script.TriggerID) as PTrigger).enemyLocked = false;
						lockTrigger = false;
					}
				}
				else if (script.TriggerID == trigger && !(parent.getChildByName(trigger) as PTrigger).disabled && !(parent.getChildByName(trigger) as PTrigger).enemyLocked){
					lockTrigger = true;
					switch(script.ScriptType){
						case "DIALOG": 
							{DialogBox(getChildByName("dialog")).pushText(script.Command); trace("yagr");
							break;}
						case "LEVEL_COMPLETE": cleanup(); _hitExit = true;
							break;
						case "UPGRADE": {	
							var arr:Array = new Array(script.Command.substring(0, script.Command.lastIndexOf(" ")), script.Command.substring(script.Command.lastIndexOf(" ")+1, script.Command.length));			
							trace(arr);
							_player.setUpgrade(arr[0], arr[1]); 
							trace(_player.Upgrades[arr[0]]); }
							break;
						case "UNLOCK": {
								(parent.getChildByName(script.Command) as PTrigger).disabled = false;
								var trig:PTrigger = (parent.getChildByName(script.Command) as PTrigger);
								trace(script.Command + " unlocked");}
							break;
						case "TIMER": processTimer(script.Command);
							break;
						case "SPRITESWAP": {
							var split:Array = script.Command.split(" ");
							var sprite:DisplayObject = parent.getChildByName(split[0]);
							if(sprite && sprite is PhysicsObj){
								var phys:PhysicsObj = sprite as PhysicsObj;
								phys.followingObjectName = split[1];
							}else{
								trace("Script tries to change the sprite of \"" + split[0] + "\" which is not a Physics object or does not exist");
							}
						}
					}
				}
			}
			return lockTrigger;
		}
		
		public function registerDeath(){
				_numEnemies --;
		}
		
		private function processTimer(cmd:String){
			var arr:Array = cmd.split(" ");
			if (arr.length == 1){
				_timer.StartTime = arr[0];
				_timer.reset();
				_timer.start();
				_timer.pause();
			}
			else if (arr[0] == "setTime")
				_timer.StartTime == arr[1];
			else if (arr[0] == "start")
				_timer.start();
			else if (arr[0] == "reset")
				_timer.reset();
			else if (arr[0] == "stop")
				_timer.pause();
			
		}
		
		//wont be called yet, don't worry about it
		private function bubbles(){
			//update bubbles
			var placeholder:int = 100;
			for each (var bubble:Bubble in _bubbles)
				bubble.tick(placeholder);
			//update time
			//check for number of bubbles compared to time
			//if bubbles * time < 5, spawn bubble, add to list
		}
		
		private function die(){
			trace("ded");
			var explosion:Explosion = new Explosion();
			explosion.x = _player.x;
			explosion.y = _player.y;
			parent.addChild(explosion);
		}

		public function cleanup(){
			if (parent.getChildByName("phys_player"))
					(parent.getChildByName("phys_player") as PPlayer).clearListeners();
			_timer.cleanup();
		}
		
		public function addObjectToLevel(obj:PhysicsObj):void{
			if(obj.parent == null){
				parent.addChild(obj);
			}
			obj.setInitialWorld(this);
			this.dispatchEvent(new Event(DONE_LOADING));
		}
		
		public function removeBody(body:b2Body):void{
			this._bodiesToRemove.push(body);
		}
		
		public function pause():void { _paused = true; _timer.pause();}
		public function unpause():void { _paused = false; _timer.unpause(); }


		public function get pscale():Number { return 40; } // Pixels per meter ratio for the physics engine
		public function get w():b2World { return _world; }
		public function get stepTime():Number { return _stepTime; }
	}
	
}
