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
	
	
	public class PPlayer extends PEntity {
		
		public static var MAX_SPEED:Number = 7;
		public static var ACCEL_SPEED_ONGROUND:Number = 1.2; 
		public static var ACCEL_SPEED_INAIR:Number = 0.7;
		public static var DASH_SPEED:Number = 20;
		public static var JUMP_FORCE:Number = 9.2;
		public static var MID_AIR_JUMPS:Number = 1;
		public static var HORIZONTAL_DAMPENING_ONGROUND = 0.8; //Friction on ground
		public static var HORIZONTAL_DAMPENING_INAIR = 0.03; //Friction in air
		public static var WALL_SLIDE_DURATION = 20;
		public static var DASH_LENGTH = 20;
		public static var WALL_JUMP_UP_PERCENTAGE = 0.7; //When jumping off a wall, jump upwards with a force of x*JUMP_FORCE
		public static var WALL_JUMP_OUT_PERCENTAGE = 2; //When jumping off a wall, jump off from the wall with a force of x*ACCEL_SPEED_ONGROUND
		
		//Dictionary of Upgrades
		private var _upgrades:Dictionary;
		public function get Upgrades():Dictionary { return _upgrades; }
		
		//Body
		private var _torsoShape:b2Shape;
		private var _torsoFix:b2Fixture;
		private var _abdominShape:b2Shape;
		private var _abdominFix:b2Fixture;
		
		//Sensors, they are just triggers to detect when player is hitting walls/floors
		private var _headSenShape:b2PolygonShape;
		private var _headSenFix:b2Fixture;
		private var _feetSenShape:b2PolygonShape;
		private var _feetSenFix:b2Fixture;
		private var _leftSenShape:b2PolygonShape;
		private var _leftSenFix:b2Fixture;
		private var _rightSenShape:b2PolygonShape;
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
		
		//Keys
		private var _kLeft:Boolean = false;
		private var _kRight:Boolean = false;
		private var _kUp:Boolean = false;
		private var _kDown:Boolean = false;
		private var _kDashLeft:Boolean = false;
		private var _kDashRight:Boolean = false;
		
		
		//Tracking stuff
		private var _midAirJumpsLeft:Number = 0;
		private var _canJumpAgain:Boolean = true; //Tracks if the player can press the jump key again (it needs to be released first)
		private var _isOnWall:Boolean = false;
		private var _onWallTime:Number = 0;
		private var _canWallSlide:Boolean = true;
		
		private var _kDLReleased:Boolean = true; //DashKey Left released
		private var _kDRReleased:Boolean = true; //DashKey Left released
		private var _dashCountdown:Number = 0;
		private var _dashLockY:Number = 0; //Y position to set player while locked
		
		public function PPlayer() {
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
			_kDashLeft = Keyboarder.keyIsDown(Keyboard.Q);
			_kDashRight = Keyboarder.keyIsDown(Keyboard.E);
			
			if((!_kLeft && !_kRight ) || (_kLeft == _kRight) || !_hitBelow) applyHorizontalDrag();
			
			wallSlide();
			
			takeInput();
		}
		
		private function takeInput():void{
			var currentSpeedSq:Number = _body.GetLinearVelocity().LengthSquared();
			
			if(_kRight && !_hitRight && currentSpeedSq < MAX_SPEED*MAX_SPEED){
				_body.ApplyImpulse(new b2Vec2((_hitBelow ? ACCEL_SPEED_ONGROUND:ACCEL_SPEED_INAIR)*_body.GetMass(),0),new b2Vec2());
				
			}if(_kLeft && !_hitLeft && currentSpeedSq < MAX_SPEED*MAX_SPEED){
				_body.ApplyImpulse(new b2Vec2(-(_hitBelow ? ACCEL_SPEED_ONGROUND:ACCEL_SPEED_INAIR)*_body.GetMass(),0),new b2Vec2());
				
			}if(_kUp){
				if(this._isOnWall/*TODO && _canJumpAgain*/){ //Wall jump
					var jumpOff:Number = JUMP_FORCE*WALL_JUMP_UP_PERCENTAGE;
					var pushOff:Number = 0;
					if(_hitLeft){
						pushOff = ACCEL_SPEED_ONGROUND*WALL_JUMP_OUT_PERCENTAGE;
					}else if(_hitRight){
						pushOff = -ACCEL_SPEED_ONGROUND*WALL_JUMP_OUT_PERCENTAGE;
					}
					_body.ApplyImpulse(new b2Vec2(pushOff*_body.GetMass(),-jumpOff*_body.GetMass()),_body.GetWorldCenter());
					this._midAirJumpsLeft = 0;
					this._isOnWall = false;	
				}else if(_hitBelow || _midAirJumpsLeft > 0){ //jump & double jump
					var doJump:Boolean = false;
					if(_hitBelow && this._canJumpAgain) {
						this._midAirJumpsLeft = PPlayer.MID_AIR_JUMPS;
						doJump = true;
					}
					else if(this._canJumpAgain) {
						this._midAirJumpsLeft --;
						doJump = true;
					}
					
					if(doJump) {
						var currentVel:b2Vec2 = this._body.GetLinearVelocity();
						_body.SetLinearVelocity(new b2Vec2(currentVel.x,0)); //Reset speed for jumping (dont want to jump while going down)
						var jumpForce:Number = JUMP_FORCE;
						if(!_hitBelow) jumpForce*=0.8; //Cant jump as high second time
						_body.ApplyImpulse(new b2Vec2(0,-jumpForce*_body.GetMass()),new b2Vec2());
					}
				}
				this._canJumpAgain = false;
			}
			/*if(_kDashLeft){TODO
				if(_kDLReleased) {
					_body.SetLinearVelocity(new b2Vec2()); //Reset speed
					_body.ApplyImpulse(new b2Vec2(-DASH_SPEED*_body.GetMass(),-2*_body.GetMass()),new b2Vec2());
				}
				_kDLReleased = false;
			}else if(_hitBelow) _kDLReleased = true;
			if(_kDashRight){
				if(_kDRReleased) {
					_body.SetLinearVelocity(new b2Vec2()); //Reset speed
					_body.ApplyImpulse(new b2Vec2(DASH_SPEED*_body.GetMass(),-2*_body.GetMass()),new b2Vec2());
				}
				_kDRReleased = false;
			}else if(_hitBelow) _kDRReleased = true;*/
			
			if(!_kUp) this._canJumpAgain = true;
		}
		
		private function applyHorizontalDrag():void {
			var horizSpeed = _body.GetLinearVelocity().x;
			var dragVec:b2Vec2 = new b2Vec2(horizSpeed,0);
			var dragForceMagnitude = -(_hitBelow ? HORIZONTAL_DAMPENING_ONGROUND:HORIZONTAL_DAMPENING_INAIR) * Math.abs(horizSpeed);
			dragVec.Multiply(dragForceMagnitude);
			_body.ApplyImpulse(dragVec, _body.GetWorldCenter());
		}

		//Manages input for wallsliding
		private function wallSlide():void{
			if((_hitLeft || _hitRight) && !_hitBelow && _canWallSlide){
				var vertSpeed = _body.GetLinearVelocity().y;
				var dragVec:b2Vec2 = new b2Vec2(0,vertSpeed);
				var dragForceMagnitude = -0.87 * Math.abs(vertSpeed);
				dragVec.Multiply(dragForceMagnitude);
				_body.ApplyImpulse(dragVec, _body.GetWorldCenter());

				//Push onto wall
				if(!((_hitLeft && _kRight) || (_hitRight && _kLeft))){
					var push:Number = 0.4*_body.GetMass();
					if(_hitLeft) push *= -1;
					_body.ApplyImpulse(new b2Vec2(push,0),_body.GetWorldCenter());
				}
				this._isOnWall = true;
				this._onWallTime --;
			}else{
				this._isOnWall = false;
			}
			if(_hitBelow) _canWallSlide = true;
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
			_leftSenShape.SetAsOrientedBox(senWid,hei/2*senShrink/4,new b2Vec2(-wid/2-senWid,0));
			var leftSenFixDef:b2FixtureDef = new b2FixtureDef();
			leftSenFixDef.shape = _leftSenShape;
			leftSenFixDef.isSensor = true;
			this._leftSenFix = _body.CreateFixture(leftSenFixDef);
			
			_rightSenShape = new b2PolygonShape();
			_rightSenShape.SetAsOrientedBox(senWid,hei/2*senShrink/4,new b2Vec2(wid/2+senWid,0));
			var rightSenFixDef:b2FixtureDef = new b2FixtureDef();
			rightSenFixDef.shape = _rightSenShape;
			rightSenFixDef.isSensor = true;
			this._rightSenFix = _body.CreateFixture(rightSenFixDef);
		}
		
		public function onHit(fixture:b2Fixture, trigger:b2Fixture, contact:b2Contact, colliding:Boolean):void{
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
