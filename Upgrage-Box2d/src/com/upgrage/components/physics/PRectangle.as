package com.upgrage.components.physics {
	
	import flash.display.MovieClip;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import flash.events.Event;
	import flash.display.Sprite;
	
	
	public class PRectangle extends PhysicsObj {
		
		public function PRectangle() {
		}
		
		protected override function updateSelfToGraphics():void {
			super.updateSelfToGraphics();
			if(_world != null) {
				_shape = new b2PolygonShape();
				(_shape as b2PolygonShape).SetAsBox(this.width/2/_world.pscale, this.height/2/_world.pscale)
				_fixtureDef.shape = _shape;
				_fixture = _body.CreateFixture(_fixtureDef);
			}
		}
		
		protected override function drawBounds():void {
			super.drawBounds();
			graphics.clear();
			graphics.endFill();
			graphics.lineStyle(3,isStatic ? 0xff0000 : (this._body != null && this._body.IsAwake() ? 0x00ff00:0xBBDDBB)); //Red:Static, Green:Moving, Gray:Sleeping
			graphics.drawRect(-width/2,-height/2, width,height);
			graphics.moveTo(0,0);
			graphics.lineTo(width/2,0);
		}
		
		protected override function setup(e:Event):void {
			super.setup(e);
			
			_shape = new b2PolygonShape();
			(_shape as b2PolygonShape).SetAsBox(this.width/2/_world.pscale, this.height/2/_world.pscale)
			_fixtureDef.shape = _shape;
			_fixture = _body.CreateFixture(_fixtureDef);
		}
	}
	
}
