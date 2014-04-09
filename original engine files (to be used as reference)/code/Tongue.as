package code {
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	
	public class Tongue extends Entity {
		
		private var _player:Player;
		
		private var _lifetime:Number = 0;
		private var _speed:Number = 10;
		
		private var _maxLifetime:Number = 75;
		private var _maxSpeed = _speed;
		
		public var _sx:Number;
		public var _sy:Number;
		
		public function Tongue(player:Player) {
			_player = player;
			this._gravity = 0;
			this._airDamp = 1;
			this._frictionDamp = 1;
			this._ignoreDamp = true;
			this._intangible = true;
			this._level = player.MyLevel;
		}
		
		public override function update():void {
			super.update();
			
			var rot:Number = this.sub_clip.rotation*Math.PI/180;
			
			this._vx = Math.cos(rot)*_speed;
			this._vy = Math.sin(rot)*_speed;
			
			_lifetime++;
			if(_lifetime/_maxLifetime > 0.4 && _speed > -_maxSpeed){
				_speed -= 1;
			}
			
			var vec:Point = new Point(this.x-_sx, this.y-_sy);
			//trace(vec.length);
			if(vec.length < 30 && _speed < 0){
				_player.killTongue();
			}
			
			this.graphics.clear();
			this.graphics.lineStyle(4,0xFF3333);
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(-x+_sx, -y+_sy);
		}
	}
	
}
