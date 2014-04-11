package com.upgrage.components.physics {
	
	import flash.display.MovieClip;
	import Box2D.Collision.Shapes.b2CircleShape;
	import flash.events.Event;
	import flash.display.Sprite;
	import com.as3toolkit.ui.Keyboarder;
	import flash.ui.Keyboard;
	import Box2D.Common.Math.b2Vec2;
	
	
	public class PPlayer extends PEntity {
		
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
			
			if(Keyboarder.keyIsDown(Keyboard.D)){
				//_body.ApplyForce(new b2Vec2(20,0),_body.GetLocalCenter());
				_body.ApplyImpulse(new b2Vec2(2*_body.GetMass(),0),new b2Vec2());
			}if(Keyboarder.keyIsDown(Keyboard.A)){
				//_body.ApplyForce(new b2Vec2(-20,0),_body.GetLocalCenter());
				_body.ApplyImpulse(new b2Vec2(-2*_body.GetMass(),0),new b2Vec2());
			}if(Keyboarder.keyIsDown(Keyboard.W)){
				//_body.ApplyForce(new b2Vec2(0,50),_body.GetLocalCenter());
				_body.ApplyImpulse(new b2Vec2(0,-10*_body.GetMass()),new b2Vec2());
			}
		}
		
		protected override function setup(e:Event):void {
			super.setup(e);
			
			/*_shape = new b2CircleShape(this.width/2/_world.pscale);
			_fixtureDef.shape = _shape;
			_fixture = _body.CreateFixture(_fixtureDef);
			_body.SetFixedRotation(true);*/
		}
	}
	
}
