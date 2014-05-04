package  com.upgrage.components {
	import com.upgrage.components.physics.*;
	import flash.events.Event;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.upgrage.events.ShotEvent;

	public class Enemy extends PEntity{

		protected var _collisionFilter:b2FilterData;
		
		protected var _leftFootSensorShape:b2PolygonShape; //Lower sensor to detect a cliff
		protected var _rightFootSensorShape:b2PolygonShape;
		protected var _leftWallSensorShape:b2PolygonShape; //Upper sensor to detect a wall
		protected var _rightWallSensorShape:b2PolygonShape;
		protected var _groundSensorShape:b2PolygonShape
		
		protected var _leftFootSensorDef:b2FixtureDef;
		protected var _rightFootSensorDef:b2FixtureDef;
		protected var _leftWallSensorDef:b2FixtureDef;
		protected var _rightWallSensorDef:b2FixtureDef;
		protected var _groundSensorDef:b2FixtureDef;
		
		protected var _leftFootSensor:b2Fixture;
		protected var _rightFootSensor:b2Fixture;
		protected var _leftWallSensor:b2Fixture;
		protected var _rightWallSensor:b2Fixture;
		protected var _groundSensor:b2Fixture;
		
		
		protected var _wallLeft:Boolean = false;
		protected var _numWallLeft:Number = 0;
		protected var _wallRight:Boolean = false;
		protected var _numWallRight:Number = 0;
		protected var _footLeft:Boolean = false;
		protected var _numFootLeft:Number = 0;
		protected var _footRight:Boolean = false;
		protected var _numFootRight:Number = 0;
		protected var _hitBelow:Boolean = false;
		protected var _numHitBelow:Number = 0;
		
		protected var _dir:String = "right";
		
		public function Enemy() {
			// constructor code
		}
		public override function onTick(e:Event):void {
			super.onTick(e);
			if(_hitBelow){
				if(Math.abs(_body.GetLinearVelocity().x) < 2){
					var spd = (_dir == "right" ? 1:-1) * 1;
					this._body.ApplyImpulse(new b2Vec2(spd,0),_body.GetWorldCenter());
				}
				
				if((_wallLeft || !_footLeft) && _dir=="left") {
					_dir = "right";
					this.followingObject.scaleX = Math.abs(this.followingObject.scaleX);
					this._body.SetLinearVelocity(new b2Vec2(0,this._body.GetLinearVelocity().y));
				}
				if((_wallRight || !_footRight) && _dir=="right") {
					_dir = "left";
					this.followingObject.scaleX = -Math.abs(this.followingObject.scaleX);
					this._body.SetLinearVelocity(new b2Vec2(0,this._body.GetLinearVelocity().y));
				}
			}
		}
		public function onShot(e:ShotEvent):void{
			if(e.hit.GetBody() == this._body){
				this.kill();
			}
		}
		
		protected override function setup(e:Event):void{
			super.setup(e);

			_world.addEventListener(ShotEvent.SHOT,onShot);
			
			_shape = new b2PolygonShape();
			var wid:Number = this.width/2/_world.pscale;
			var hei:Number = this.height/2/_world.pscale;
			(_shape as b2PolygonShape).SetAsBox(wid,hei)
			_fixtureDef.shape = _shape;
			_fixture = _body.CreateFixture(_fixtureDef);
			
			var senWidth:Number = 0.1;
			
			_leftFootSensorShape = new b2PolygonShape();
			_rightFootSensorShape = new b2PolygonShape();
			_leftFootSensorShape.SetAsOrientedBox(senWidth, senWidth,new b2Vec2(-wid-senWidth,hei+senWidth),0);
			_rightFootSensorShape.SetAsOrientedBox(senWidth, senWidth,new b2Vec2(wid+senWidth,hei+senWidth),0);
			
			_leftWallSensorShape = new b2PolygonShape();
			_rightWallSensorShape = new b2PolygonShape();
			_leftWallSensorShape.SetAsOrientedBox(senWidth, hei*0.8,new b2Vec2(-wid-senWidth,0),0);
			_rightWallSensorShape.SetAsOrientedBox(senWidth, hei*0.8,new b2Vec2(wid+senWidth,0),0);
			
			_groundSensorShape = new b2PolygonShape();
			_groundSensorShape.SetAsOrientedBox(wid*0.8,senWidth,new b2Vec2(0,hei+senWidth),0);
			
			
			_leftFootSensorDef = new b2FixtureDef();
			_rightFootSensorDef = new b2FixtureDef();
			_leftFootSensorDef.shape = _leftFootSensorShape;
			_leftFootSensorDef.isSensor = true;
			_rightFootSensorDef.shape = _rightFootSensorShape;
			_rightFootSensorDef.isSensor = true;
			
			_leftWallSensorDef = new b2FixtureDef();
			_rightWallSensorDef = new b2FixtureDef();
			_leftWallSensorDef.shape = _leftWallSensorShape;
			_leftWallSensorDef.isSensor = true;
			_rightWallSensorDef.shape = _rightWallSensorShape;
			_rightWallSensorDef.isSensor = true;
			
			_groundSensorDef = new b2FixtureDef();
			_groundSensorDef.isSensor = true;
			_groundSensorDef.shape = _groundSensorShape;

			_leftFootSensor = _body.CreateFixture(_leftFootSensorDef);
			_rightFootSensor = _body.CreateFixture(_rightFootSensorDef);
			_leftWallSensor = _body.CreateFixture(_leftWallSensorDef);
			_rightWallSensor = _body.CreateFixture(_rightWallSensorDef);
			_groundSensor = _body.CreateFixture(_groundSensorDef);

			_leftFootSensor.SetUserData(this);
			_rightFootSensor.SetUserData(this);
			_leftWallSensor.SetUserData(this);
			_rightWallSensor.SetUserData(this);
			_groundSensor.SetUserData(this);

			_collisionFilter = new b2FilterData();
			_collisionFilter.groupIndex = -2; //-2 for enemies, kinda arbitrary
			
			_fixture.SetFilterData(_collisionFilter);
			_leftFootSensor.SetFilterData(_collisionFilter);
			_rightFootSensor.SetFilterData(_collisionFilter);
			_leftWallSensor.SetFilterData(_collisionFilter);
			_rightWallSensor.SetFilterData(_collisionFilter);
			_groundSensor.SetFilterData(_collisionFilter);
			
			_body.SetFixedRotation(true);
		}
		
		public override function onHit(fixture:b2Fixture, trigger:b2Fixture, contact:b2Contact, colliding:Boolean):void{
			if(fixture.IsSensor()) return;
			if(trigger == _leftFootSensor) {
				_numFootLeft += (colliding ? 1:-1);
				_footLeft = (_numFootLeft > 0)
			}
			if(trigger == _rightFootSensor){
				_numFootRight += (colliding ? 1:-1);
				_footRight = (_numFootRight > 0)
			}
			if(trigger == _leftWallSensor) {
				_numWallLeft += (colliding ? 1:-1);
				_wallLeft = (_numWallLeft > 0)
			}
			if(trigger == _rightWallSensor) {
				_numWallRight += (colliding ? 1:-1);
				_wallRight = (_numWallRight > 0)
			}
			if(trigger == _groundSensor) {
				_numHitBelow += (colliding ? 1:-1);
				_hitBelow = (_numHitBelow > 0)
			}
		}

	}
	
}
