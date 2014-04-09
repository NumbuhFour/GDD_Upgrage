package code {
	
	import flash.display.MovieClip;
	
	
	public class Enemy extends Entity {
		
		var _wasOnGround:Boolean = false;
		var _dir:Number = 1;
		var _speed:Number = 5;
		
		public function Enemy() {
			// constructor code
		}
		
		public override function update():void{
			super.update();
			
			if((!onGround() && _wasOnGround) || ((_adj&Level.WEST) == Level.WEST && _dir == -1) || ((_adj&Level.EAST) == Level.EAST && _dir == 1)){
				_dir *= -1;
				this.x += _speed * _dir;
				this.y -= 3;
			}
			_wasOnGround = onGround();
			this.sub_clip.scaleX = _dir;
			
			this._vx = _speed * _dir;
		}
	}
	
}
