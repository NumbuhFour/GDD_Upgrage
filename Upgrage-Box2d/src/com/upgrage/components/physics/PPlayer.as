package com.upgrage.components.physics {
	
	import flash.display.MovieClip;
	import Box2D.Collision.Shapes.b2CircleShape;
	import flash.events.Event;
	import flash.display.Sprite;
	import com.as3toolkit.ui.Keyboarder;
	import flash.ui.Keyboard;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import flash.utils.Dictionary;
	import com.upgrage.components.Projectile;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	
	public class PPlayer extends PEntity {
		//Dictionary of Upgrades
		private var _upgrades:Dictionary;
		public function get Upgrades():Dictionary { return _upgrades; }
		
		//Body
		private var _torsoShape:b2Shape;
		private var _torsoShapeShrunk:b2Shape;
		private var _torsoFix:b2Fixture;
		private var _abdominShape:b2Shape;
		private var _abdominFix:b2Fixture;
		
		//Sensors, they are just triggers to detect when player is hitting walls/floors
		private var _headSenShape:b2PolygonShape;
		private var _headSenShapeShrunk:b2PolygonShape;
		private var _headSenFix:b2Fixture;
		private var _feetSenShape:b2PolygonShape;
		private var _feetSenFix:b2Fixture;
		private var _leftSenShape:b2PolygonShape;
		private var _leftSenShapeShrunk:b2PolygonShape;
		private var _leftSenFix:b2Fixture;
		private var _rightSenShape:b2PolygonShape;
		private var _rightSenShapeShrunk:b2PolygonShape;
		private var _rightSenFix:b2Fixture;
		
		//Collisions
		private var _hitBelow:Boolean = false;
		private var _numHitsBelow:Number = 0; //Tracks number of currently-touching things so that the hit flag is only false when there is nothing colliding
		private var _hitAbove:Boolean = false;
		private var _numHitsAbove:Number = 0;
		private var _hitLeft:Boolean = false;
		private var _numHitsLeft:Number = 0;
		private var _hitRight:Boolean = false;
		private var _numHitsRight:Number = 0;
		
		//Input tracking
		private var _kLeft:Boolean = false;
		private var _kRight:Boolean = false;
		private var _kUp:Boolean = false;
		private var _kDown:Boolean = false;
		private var _kSpace:Boolean = false;
		private var _kDashLeft:Boolean = false;
		private var _kDashRight:Boolean = false;
		private var _kShift:Boolean = false;
		private var _clicked:Boolean = false;
		private var _iterSinceLastClick:uint = 0;
		private var _mouseCoords:Point = new Point();
		
		
		//Tracking stuff
		private var _midAirJumpsLeft:Number = 0;
		private var _canJumpAgain:Boolean = true; //Tracks if the player can press the jump key again (it needs to be released first)
		private var _isOnWall:Boolean = false;
		private var _wasOnWall:Boolean = false;
		private var _onWallTime:Number = 0;
		private var _canWallSlide:Boolean = true;
		private var _canWallJump:Boolean = false;
		
		private var _kDLReleased:Boolean = true; //DashKey Left released
		private var _kDRReleased:Boolean = true; //DashKey Left released
		private var _dashCountdown:Number = 0;
		private var _dashLockY:Number = 0; //Y position to set player while locked
		
		private var _crouching:Boolean = false;
		
		private var _animState:String = "idle";
		
		public function PPlayer() {
			_upgrades = new Dictionary();
			initProperties();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
		}
		
		private function initProperties(){
			_upgrades["max speed"] = 7;
			_upgrades["accel speed onground"] = 1.2;
			_upgrades["accel speed inair"] = 0.7;
			_upgrades["dash speed"] = 20;
			_upgrades["jump force"] = 9.2;
			_upgrades["mid air jumps"] = 1;
			_upgrades["horizontal dampening onground"] = 0.8; //Friction on ground
			_upgrades["horizontal dampening inair"] = 0.03; //Friction in air
			_upgrades["wall slide duration"] = 20;
			_upgrades["dash length"] = 20;
			_upgrades["wall jump up percentage"] = 0.7;//When jumping off a wall, jump upwards with a force of x*_upgrades["jump force"]
			_upgrades["wall jump out percentage"] = 2; //When jumping off a wall, jump off from the wall with a force of x*_upgrades["accel speed onground"]
			
			_upgrades["jetpack"] = true;
			_upgrades["jetpack accel"] = 2.5;
			_upgrades["max jetpack speed"] = 7.3;
			
			_upgrades["rockets"] = true;
			_upgrades["manhole cover"] = false;
			_upgrades["rocket speed"] = 5;
			
			_upgrades["wall jump"] = true;
			_upgrades["wall slide"] = true;
			_upgrades["jump"] = true;
			
			_upgrades["can crouch"] = true;
			_upgrades["crouch speed percent"] = 0.8;
			_upgrades["crouch height percent"] = 0.8;
		}
		
		protected override function updateSelfToGraphics():void {
			super.updateSelfToGraphics();
			if(_world != null) {
				_shape = _fixtureDef.shape = new b2CircleShape((this.width/2)/_world.pscale);
				_fixture = _body.CreateFixture(_fixtureDef);
			}
		}
		
		protected override function drawBounds():void {
			super.drawBounds();
			graphics.clear();
			graphics.endFill();
			graphics.lineStyle(3,isStatic ? 0xff0000 : (this._body != null && this._body.IsAwake() ? 0x00ff00:0xBBDDBB)); //Red:Static, Green:Moving, Gray:Sleeping
			graphics.drawCircle(0,0,width/2);
			graphics.moveTo(0,0);
			graphics.lineTo(width/2,0);
		}
		
		public override function onTick(e:Event):void {
			super.onTick(e);
			
			_kLeft = Keyboarder.keyIsDown(Keyboard.A) || Keyboarder.keyIsDown(Keyboard.LEFT);
			_kRight = Keyboarder.keyIsDown(Keyboard.D) || Keyboarder.keyIsDown(Keyboard.RIGHT);
			_kUp = Keyboarder.keyIsDown(Keyboard.W) || Keyboarder.keyIsDown(Keyboard.UP);
			_kDown = Keyboarder.keyIsDown(Keyboard.S) || Keyboarder.keyIsDown(Keyboard.DOWN);
			_kSpace = Keyboarder.keyIsDown(Keyboard.SPACE);
			_kDashLeft = Keyboarder.keyIsDown(Keyboard.Q);
			_kDashRight = Keyboarder.keyIsDown(Keyboard.E);
			_kShift = Keyboarder.keyIsDown(Keyboard.SHIFT);
		
			
			
			if((!_kLeft && !_kRight ) || (_kLeft == _kRight) || !_hitBelow) applyHorizontalDrag();
			
			wallSlide();
			
			takeInput();
			
			cleanAnimations();
		}
		
		private function takeInput():void{
			this.followingObject.visible = false;
			var currentSpeedSq:Number = _body.GetLinearVelocity().LengthSquared();
			
			if(!this._crouching && this._kShift && this._upgrades["can crouch"] && this._hitBelow){
				this._crouching = true;
				if(this._animState == "run") this.followingObject.gotoAndPlay("crouch_walk");
				else if(this._animState == "idle") this.followingObject.gotoAndStop("crouch");
				this.shrinkHitbox();
			}else if(this._crouching && (!this._kShift || !this._hitBelow || !this._upgrades["can crouch"])){
				if(this._animState == "run") this.followingObject.gotoAndPlay("run");
				else if(this._animState == "idle") this.followingObject.gotoAndStop("idle");
				this._crouching = false;
				this.resetHitbox();
			}
			
			var maxSpeed = _upgrades["max speed"] * (_crouching ? _upgrades["crouch speed percent"]:1);
			if(_kRight && !_hitRight && currentSpeedSq < maxSpeed*maxSpeed){
				_body.ApplyImpulse(new b2Vec2((_hitBelow ? _upgrades["accel speed onground"]:_upgrades["accel speed inair"])
												*(_crouching ? _upgrades["crouch speed percent"]:1)
												*_body.GetMass(),0),new b2Vec2());
				if(this._animState != "run" && _hitBelow && !_hitLeft) {
					this.followingObject.gotoAndPlay(this._crouching ? "crouch_walk" : "run");
					this._animState = "run";
				}
				if(!_hitLeft) this.followingObject.scaleX = Math.abs(this.followingObject.scaleX);//Flip player
			}if(_kLeft && !_hitLeft && currentSpeedSq < maxSpeed*maxSpeed){
				_body.ApplyImpulse(new b2Vec2(-(_hitBelow ? _upgrades["accel speed onground"]:_upgrades["accel speed inair"])
												*(_crouching ? _upgrades["crouch speed percent"]:1)
												*_body.GetMass(),0),new b2Vec2());
				if(this._animState != "run" && _hitBelow && !_hitRight) {
					this.followingObject.gotoAndPlay(this._crouching ? "crouch_walk" : "run");
					this._animState = "run";
				}
				if(!_hitRight) this.followingObject.scaleX = -Math.abs(this.followingObject.scaleX);//Flip player
			}
			if(this._isOnWall && _upgrades["wall jump"] == true ){ //Jump Off Wall
				if((_kUp && _canWallJump) || (_hitLeft && _kRight) || (_hitRight && _kLeft)){ //Jump when up is pressed or when key pressed is opposite of wall direction
					var jumpOff:Number = _upgrades["jump force"]*_upgrades["wall jump up percentage"];
					var pushOff:Number = 0;
					if(_hitLeft){
						pushOff = _upgrades["accel speed onground"]*_upgrades["wall jump out percentage"];
						this.followingObject.scaleX = Math.abs(this.followingObject.scaleX);//Flip player
					}else if(_hitRight){
						pushOff = -_upgrades["accel speed onground"]*_upgrades["wall jump out percentage"];
						this.followingObject.scaleX = -Math.abs(this.followingObject.scaleX);//Flip player
					}
					_body.SetLinearVelocity(new b2Vec2(_body.GetLinearVelocity().x,0));
					_body.ApplyImpulse(new b2Vec2(pushOff*_body.GetMass(),-jumpOff*_body.GetMass()),_body.GetWorldCenter());
					this._midAirJumpsLeft = 0;
					this._isOnWall = false;	
					this._canWallJump = false;
					if(this._animState != "jump") this.followingObject.gotoAndPlay("jump");
					this._animState = "jump";
				}
			}else if(_kUp && _upgrades["jump"] == true){ //jump & double jump
				//var jetpack:Boolean = _upgrades["jetpack"];
				if(/* !jetpack && */(_hitBelow || _midAirJumpsLeft > 0 || _midAirJumpsLeft <= -1)){
					var doJump:Boolean = false;
					if(_hitBelow && this._canJumpAgain) {
						this._midAirJumpsLeft = _upgrades["mid air jumps"];
						doJump = true;
					}
					else if(this._canJumpAgain) {
						this._midAirJumpsLeft --;
						doJump = true;
					}
					
					if(doJump) {
						var currentVel:b2Vec2 = this._body.GetLinearVelocity();
						_body.SetLinearVelocity(new b2Vec2(currentVel.x,0)); //Reset speed for jumping (dont want to jump while going down)
						var jumpForce:Number = _upgrades["jump force"];
						if(!_hitBelow) jumpForce*=0.8; //Cant jump as high second time
						_body.ApplyImpulse(new b2Vec2(0,-jumpForce*_body.GetMass()),new b2Vec2());
						if(this._animState != "jump") this.followingObject.gotoAndPlay("jump");
						this._animState = "jump";
					}
					this._canJumpAgain = false;
				}
			}
			
			if(_upgrades["jetpack"] == true && _kSpace && _body.GetLinearVelocity().y >-_upgrades["max jetpack speed"]){ //JETPACK
				_body.ApplyImpulse(new b2Vec2(0,-_upgrades["jetpack accel"]*_body.GetMass()), _body.GetWorldCenter());
				if(this._animState != "jump") this.followingObject.gotoAndPlay("jump");
				this._animState = "jump";
			}
			
			/*if(_kDashLeft){TODO
				if(_kDLReleased) {
					_body.SetLinearVelocity(new b2Vec2()); //Reset speed
					_body.ApplyImpulse(new b2Vec2(-_upgrades["dash speed"]*_body.GetMass(),-2*_body.GetMass()),new b2Vec2());
				}
				_kDLReleased = false;
			}else if(_hitBelow) _kDLReleased = true;
			if(_kDashRight){
				if(_kDRReleased) {
					_body.SetLinearVelocity(new b2Vec2()); //Reset speed
					_body.ApplyImpulse(new b2Vec2(_upgrades["dash speed"]*_body.GetMass(),-2*_body.GetMass()),new b2Vec2());
				}
				_kDRReleased = false;
			}else if(_hitBelow) _kDRReleased = true;*/
			
			if(_upgrades["rockets"] && !_upgrades["manhole cover"] && _clicked && _iterSinceLastClick > 30){
				var bullet:Projectile = new Projectile();
				bullet.x = bullet.y = 10000; //Gett off mah screen
				this._world.addObjectToLevel(bullet);
				var fireVector:b2Vec2 = new b2Vec2(_mouseCoords.x / _world.pscale, _mouseCoords.y / _world.pscale);
				fireVector.Subtract(_body.GetPosition());
				fireVector.Normalize();
				fireVector.Multiply(_upgrades["rocket speed"]);
				bullet.setPositionAndVelocity(_body.GetPosition(), fireVector);
				var rot:Number = Math.atan2(_mouseCoords.y - this.y, _mouseCoords.x - this.x);
				bullet.setRotation(rot);
				_iterSinceLastClick = 0;
			}
			_iterSinceLastClick ++;
			
			if(!_kUp) this._canJumpAgain = true;
			this._canWallJump = this._wasOnWall && !_kUp && !_hitBelow; //You have to let go of the up key at least once before jumping off wall
			this._wasOnWall = this._isOnWall;
		}
		
		private function cleanAnimations():void{
						
			//Setting animation to idle when idle
			if(this._animState != "idle" && _hitBelow && ((!_kLeft && !_kRight) || this._animState != "run") && this._body.GetLinearVelocity().LengthSquared() < 10){
				this.followingObject.gotoAndPlay(this._crouching ? "crouch" : "idle");
				this._animState = "idle";
			}

			//Setting animatino to fall when falling
			if(this._animState != "fall" && !_hitBelow && this._body.GetLinearVelocity().y > 1){
				this.followingObject.gotoAndPlay("fall");
				this._animState = "fall";
			}
			
			//Setting animation to wallslide while on wall
			if(this._animState != "wall" && this._isOnWall){
				this.followingObject.gotoAndPlay("wall");
				this._animState = "wall";
			}
			
			if(this._animState == "run" && _kLeft == _kRight){
				this._animState = "idle";
				this.followingObject.gotoAndPlay(this._crouching ? "crouch" : "idle");
			}
			
			/*if(this._animState != "run" && _hitBelow && this._body.GetLinearVelocity().LengthSquared() >= 10){
				this._animState = "run";
				this.followingObject.gotoAndPlay("run");
			}*/
		}
		
		private function applyHorizontalDrag():void {
			var horizSpeed = _body.GetLinearVelocity().x;
			var dragVec:b2Vec2 = new b2Vec2(horizSpeed,0);
			var dragForceMagnitude = -(_hitBelow ? _upgrades["horizontal dampening onground"]:_upgrades["horizontal dampening inair"]) * Math.abs(horizSpeed);
			dragVec.Multiply(dragForceMagnitude);
			_body.ApplyImpulse(dragVec, _body.GetWorldCenter());
		}

		//Manages input for wallsliding
		private function wallSlide():void{
			if(this._upgrades["wall slide"] && (((_hitLeft/* && _kLeft*/) || (_hitRight/* && _kRight*/)) && !_hitBelow && _canWallSlide)){ //On wall, pressing key
				var vertSpeed:Number = _body.GetLinearVelocity().y;
				if(vertSpeed > 0){ //Must be going down to apply force down
					/*var dragVec:b2Vec2 = new b2Vec2(0,vertSpeed);
					var dragForceMagnitude = -0.87 * Math.abs(vertSpeed);
					dragVec.Multiply(dragForceMagnitude);
					_body.ApplyImpulse(dragVec, _body.GetWorldCenter());*/

					//Push onto wall
					/*if(!((_hitLeft && _kRight) || (_hitRight && _kLeft))){
						var push:Number = 0.4*_body.GetMass();
						if(_hitLeft) push *= -1;
						_body.ApplyImpulse(new b2Vec2(push,0),_body.GetWorldCenter());
					}*/
				}
				this._isOnWall = true;
				this._onWallTime --;
				
				
				if(_hitLeft){
					this.followingObject.scaleX = Math.abs(this.followingObject.scaleX);//Flip player
				}else if(_hitRight){
					this.followingObject.scaleX = -Math.abs(this.followingObject.scaleX);//Flip player
				}
			}else{
				this._isOnWall = false;
				if(this._animState == "wall"){
					this.followingObject.gotoAndPlay("fall");
					this._animState = "fall";
				}
			}
			if(_hitBelow) _canWallSlide = true;
		}
		
		public function setUpgrade(key:String, val:String) { 
			trace("type: " + typeof(_upgrades[key]));			
			if (_upgrades[key] is Boolean)
				_upgrades[key] = (val == "true"); 
			else 
				_upgrades[key] = val;
			trace(key + " : " + val); }
		
		private function mouseDown(e:MouseEvent){
			this._mouseCoords.x = e.stageX;
			this._mouseCoords.y = e.stageY;
			recalcMousePos();
			this._clicked = true;
		}
		
		private function mouseUp(e:MouseEvent){
			this._mouseCoords.x = e.stageX;
			this._mouseCoords.y = e.stageY;
			this._clicked = false;
			recalcMousePos();
		}
		
		private function updateMouse(e:MouseEvent){
			this._mouseCoords.x = e.stageX;
			this._mouseCoords.y = e.stageY;
			this._clicked = e.buttonDown;
			recalcMousePos();

		}
		//Adjust for parent's translations
		private function recalcMousePos(){
			this._mouseCoords.x -= parent.x;
			this._mouseCoords.y -= parent.y;
		}

		
		public function clearListeners(){
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
		}
		//Crouch
		private function shrinkHitbox():void{
			this._body.DestroyFixture(this._torsoFix);
			if(!this._torsoShapeShrunk) {
				var hei:Number = this.height/_world.pscale;
				var wid:Number = this.width/_world.pscale;
				var rad:Number = wid/2;
				var bHei:Number = (hei*_upgrades["crouch height percent"]-rad);
				var senWid:Number = 0.02;
				var senShrink:Number = 0.95; //How much smaller the sensor is than the player's dimensions
				
				this._torsoShapeShrunk = new b2PolygonShape();
				(_torsoShapeShrunk as b2PolygonShape).SetAsOrientedBox(wid/2*0.98,bHei/2,new b2Vec2(0,(hei/2-rad)-bHei/2),0);
				
				_headSenShapeShrunk = new b2PolygonShape();
				_headSenShapeShrunk.SetAsOrientedBox(wid/2*senShrink,senWid,new b2Vec2(0,(hei/2-rad)-bHei-senWid*2));
			}
			this._body.DestroyFixture(this._torsoFix);
			var torsoFixDef:b2FixtureDef = new b2FixtureDef();
			torsoFixDef.shape = this._torsoShapeShrunk;
			this._torsoFix = this._body.CreateFixture(torsoFixDef);

			this._body.DestroyFixture(this._headSenFix);
			var headFixDef:b2FixtureDef = new b2FixtureDef();
			headFixDef.shape = this._headSenShapeShrunk;
			this._headSenFix = this._body.CreateFixture(headFixDef);
			
		}
		//Release crouch
		private function resetHitbox():void {
			this._body.DestroyFixture(this._torsoFix);
			var torsoFixDef:b2FixtureDef = new b2FixtureDef();
			torsoFixDef.shape = this._torsoShape;
			this._torsoFix = this._body.CreateFixture(torsoFixDef);
			
			this._body.DestroyFixture(this._headSenFix);
			var headFixDef:b2FixtureDef = new b2FixtureDef();
			headFixDef.shape = this._headSenShape;
			this._headSenFix = this._body.CreateFixture(headFixDef);
		}
		
		protected override function setup(e:Event):void { //Box2d Physics initialization
			super.setup(e);
			
			/*_shape = new b2CircleShape(this.width/2/_world.pscale);
			_fixtureDef.shape = _shape;
			_fixture = _body.CreateFixture(_fixtureDef);
			_body.SetFixedRotation(true);*/

			_body.SetFixedRotation(true);
			//_body.SetLinearDamping(0.4);
			
			var hei:Number = this.height/_world.pscale;
			var wid:Number = this.width/_world.pscale;
			var rad:Number = wid/2;
			_shape = _abdominShape = new b2CircleShape(rad);
			(_abdominShape as b2CircleShape).SetLocalPosition(new b2Vec2(0,hei/2-rad));
			_fixtureDef.shape = _abdominShape;
			_fixture = _abdominFix = _body.CreateFixture(_fixtureDef);
			
			var bHei:Number = hei-rad;
			_torsoShape = new b2PolygonShape();
			(_torsoShape as b2PolygonShape).SetAsOrientedBox(wid/2*0.98,bHei/2,new b2Vec2(0,-hei/2+bHei/2),0);
			var torsoFixDef:b2FixtureDef = new b2FixtureDef();
			torsoFixDef.shape = _torsoShape;
			this._torsoFix = _body.CreateFixture(torsoFixDef);
			
			var senWid:Number = 0.02;
			var senShrink:Number = 0.95; //How much smaller the sensor is than the player's dimensions
			_headSenShape = new b2PolygonShape();
			_headSenShape.SetAsOrientedBox(wid/2*senShrink,senWid,new b2Vec2(0,-hei/2-senWid));
			var headSenFixDef:b2FixtureDef = new b2FixtureDef();
			headSenFixDef.shape = _headSenShape;
			headSenFixDef.isSensor = true;
			this._headSenFix = _body.CreateFixture(headSenFixDef);
			
			_feetSenShape = new b2PolygonShape();
			_feetSenShape.SetAsOrientedBox(wid/2*senShrink,senWid,new b2Vec2(0,hei/2+senWid));
			var feetSenFixDef:b2FixtureDef = new b2FixtureDef();
			feetSenFixDef.shape = _feetSenShape;
			feetSenFixDef.isSensor = true;
			this._feetSenFix = _body.CreateFixture(feetSenFixDef);
			
			_leftSenShape = new b2PolygonShape();
			_leftSenShape.SetAsOrientedBox(senWid,hei/2*senShrink/1.5,new b2Vec2(-wid/2-senWid,0));
			var leftSenFixDef:b2FixtureDef = new b2FixtureDef();
			leftSenFixDef.shape = _leftSenShape;
			leftSenFixDef.isSensor = true;
			this._leftSenFix = _body.CreateFixture(leftSenFixDef);
			
			_rightSenShape = new b2PolygonShape();
			_rightSenShape.SetAsOrientedBox(senWid,hei/2*senShrink/1.5,new b2Vec2(wid/2+senWid,0));
			var rightSenFixDef:b2FixtureDef = new b2FixtureDef();
			rightSenFixDef.shape = _rightSenShape;
			rightSenFixDef.isSensor = true;
			this._rightSenFix = _body.CreateFixture(rightSenFixDef);
		}
		
		public override function onHit(fixture:b2Fixture, trigger:b2Fixture, contact:b2Contact, colliding:Boolean):void{
			//TODO if wall act accordingly, if enemy take damage
			
			if(fixture.IsSensor()) return; //If colliding with a sensor, ignore
			
			if(trigger == this._feetSenFix){
				this._numHitsBelow += (colliding ? 1:-1);
				this._hitBelow = _numHitsBelow > 0;
			}else if(trigger == this._headSenFix){
				this._numHitsAbove += (colliding ? 1:-1);
				this._hitAbove = _numHitsAbove > 0;
			}else if(trigger == this._leftSenFix){
				this._numHitsLeft += (colliding ? 1:-1);
				this._hitLeft = _numHitsLeft > 0;
			}else if(trigger == this._rightSenFix){
				this._numHitsRight += (colliding ? 1:-1);
				this._hitRight = _numHitsRight > 0;
			}
		}
	}
	
}
