package com.upgrage.components.physics {
	
	import flash.display.MovieClip;
	import Box2D.Collision.Shapes.b2CircleShape;
	import flash.events.Event;
	import flash.display.Sprite;
	
	
	public class PCircle extends PhysicsObj {
		
		public function PCircle() {
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
		
		protected override function setup(e:Event):void {
			super.setup(e);
			
			_shape = new b2CircleShape(this.width/2/_world.pscale);
			_fixtureDef.shape = _shape;
			_fixture = _body.CreateFixture(_fixtureDef);
		}
	}
	
}
