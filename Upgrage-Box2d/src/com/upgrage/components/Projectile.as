package com.upgrage.components {
	import com.upgrage.components.physics.PEntity;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import flash.events.Event;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import com.upgrage.components.physics.PhysicsObj;
	import com.upgrage.components.physics.PPlayer;
	import com.upgrage.events.ShotEvent;
	
	public class Projectile extends PEntity{

		private var lifetime:int = 20000;
		private var age:int = 0;
		public function Projectile() {
			
		}
		protected override function updateSelfToGraphics():void {
			super.updateSelfToGraphics();
		}
		
		protected override function setup(e:Event):void {
			super.setup(e);
			
			var bullet:Bullet = new Bullet();
			bullet.x = this.x;
			bullet.y = this.y;
			parent.addChild(bullet);
			this.setFollowingObject(bullet);
			
			this.width = bullet.width;
			this.height = bullet.height;
			
			_shape = new b2PolygonShape();
			(_shape as b2PolygonShape).SetAsBox(this.width/2/_world.pscale, this.height/2/_world.pscale);
			_fixtureDef.shape = _shape;
			_fixtureDef.isSensor = true;
			_fixture = _body.CreateFixture(_fixtureDef);
			_fixture.SetUserData(this);
			this.isStatic = false;
			this.gravity = new b2Vec2();
		}
		
		public override function onHit(fixture:b2Fixture, trigger:b2Fixture, contact:b2Contact, colliding:Boolean):void{
			
			if(fixture.IsSensor()) return;
			var hit:PhysicsObj = fixture.GetBody().GetUserData();
			if(hit is PPlayer || this._isDead) return;
			if(hit.followingObjectName){
				trace("Hit a " + hit.followingObjectName);
			}
			this._world.dispatchEvent(new ShotEvent(fixture));
			
			var explosion:Explosion = new Explosion();
			explosion.x = this.x;
			explosion.y = this.y;
			parent.addChild(explosion);
			this.kill();
		}
		
		public override function onTick(e:Event):void{
			super.onTick(e);
			age ++;
			if(age > lifetime) {
				trace("Dying");
				this.kill();
			}
		}

	}
	
}
