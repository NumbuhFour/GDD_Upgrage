package com.upgrage.components.physics {
	
	import flash.display.MovieClip;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import flash.events.Event;
	import flash.display.Sprite;
	
	
	public class PEntity extends PhysicsObj {
		
		public function PEntity() {
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
			/*graphics.clear();
			graphics.endFill();
			graphics.lineStyle(3,isStatic ? 0xff0000 : (this._body != null && this._body.IsAwake() ? 0x00ff00:0xBBDDBB)); //Red:Static, Green:Moving, Gray:Sleeping
			graphics.drawCircle(0,0,width/2);
			graphics.moveTo(0,0);
			graphics.lineTo(width/2,0);*/
		}
		
		protected override function setup(e:Event):void {
			super.setup(e);
			
			/*_shape = new b2CircleShape(this.width/2/_world.pscale);
			_fixtureDef.shape = _shape;
			_fixture = _body.CreateFixture(_fixtureDef);
			_body.SetFixedRotation(true);*/
		}
		
		public function onHit(fixture:b2Fixture, trigger:b2Fixture, contact:b2Contact, colliding:Boolean):void{
		}
		
		/*[Inspectable(name="Is Static", type=Boolean, defaultValue=false)]
		public override function set isStatic(val:Boolean):void{
			super.isStatic = val;
		}
		public override function get isStatic():Boolean { return super.isStatic; }
		
		[Inspectable(name="Fixed Rotation", type=Boolean, defaultValue=true)]
		public override function set isRotationFixed(val:Boolean):void{
			super.isRotationFixed = val;
		}
		public override function get isRotationFixed():Boolean { return super.isRotationFixed; }
		
		[Inspectable(name="Friction", type=Number, defaultValue=0.6)]
		public override function set friction(val:Number):void{
			super.friction = val;
		}
		public override function get friction():Number { return super.friction; }*/
	}
	
}
