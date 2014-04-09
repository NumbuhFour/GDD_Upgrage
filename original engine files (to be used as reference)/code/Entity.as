package code {
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class Entity extends MovieClip{

		protected var _level:Level;
		protected var _vx:Number = 0;
		protected var _vy:Number = 0;
		protected var _frictionDamp:Number = 0.75;
		protected var _airDamp:Number = 0.92;
		protected var _gravity:Number = 1;
		
		protected var _maxVX:Number = 100;
		protected var _maxVY:Number = 35;
		
		protected var _ignoreDamp:Boolean = false;
		protected var _intangible:Boolean = false;
		
		protected var _adj:uint = 0;
		
		protected var _boundWidth:Number = 30;
		protected var _boundHeight:Number = 50;
		
		public function Entity(){
		}
		public function setLevel(level:Level){
			this._level = level;
		}
		
		public function update():void{
			this.push(0,_gravity);
			if(!_ignoreDamp) this.applyDamp();
			if(!_intangible) stopVelocities();
			moveTo(this.x+_vx, this.y+_vy);
			if(!_intangible) pushOut();
			/*if(_level.canMoveTo(this, this.x, this.y + 3) == 0){
				this.y += 3;
			}else{
				trace(_level.canMoveTo(this, this.x, this.y + 3));
			}*/
		}
		
		/**
		 * Push out of walls/floors
		 */
		public function pushOut():void{
			var hit:uint;
			do{
				hit = _level.getAdjacentWalls(this,-5);
				var n:Boolean = (hit&Level.NORTH) == Level.NORTH;
				var s:Boolean = (hit&Level.SOUTH) == Level.SOUTH;
				var e:Boolean = (hit&Level.EAST) == Level.EAST;
				var w:Boolean = (hit&Level.WEST) == Level.WEST;
				
				if(e && !w){
					this.x += 1;
				}else if(w && !e){
					this.x -= 1;
				}
				if(n && !s){
					this.y += 1;
				}else if(s && !n){
					this.y -= 1;
				}
			}while(hit != 0);
		}
		
		public function stopVelocities():void{
			var hit:uint = this._level.getAdjacentWalls(this);

			this._adj = hit;
			if(hit == 0) return;
			
			if(((hit&Level.EAST) == Level.EAST && _vx > 0) || ((hit&Level.WEST) == Level.WEST && _vx < 0)){
				_vx = 0;
			}
			
			if(((hit&Level.SOUTH) == Level.SOUTH && _vy > 0) ||((hit&Level.NORTH) == Level.NORTH && _vy < 0)){
				_vy = 0;
			}
		}
		
		public function moveTo(tx:Number, ty:Number):void{
			var px:Number = x;
			var py:Number = y;
			var nx:Number = tx;
			var ny:Number = ty;
			var dx:Number = px-nx;
			var dy:Number = py-ny;
			
			var hit:uint;
			//hit = _level.canMoveTo(this,nx,ny);
			//var timeout:uint = 4;
			//do{
				/*if((dx*dx)+(dy*dy) > (_level.Scale/4)*(_level.Scale/4)){
					trace("INTERPOLATING");
					var full:Point = new Point(dx,dy);
					var scaleLen:Number = Point.distance(new Point(),full)/_level.Scale;
					var inter:Number = 1;
					var hitInter:uint = 0;
					var vec:Point;
					while(hitInter == 0 && inter <= scaleLen){
						vec = new Point(full.x,full.y);
						vec.normalize(_level.Scale * inter);
						hitInter = _level.canMoveTo(this,px+vec.x, py+vec.y);
						inter++;
					}
					if(hitInter != 0){
						nx = px + vec.x;
						ny = py + vec.y;
					}
				}*/
				
				
				var vec:Point = new Point(dx, dy);
				var mag:Number = vec.length;
				var tol:Number = _level.Scale;
				var perc:Number = 1;
				var percIter:Number = 1;
				
				if(mag > tol && !_intangible){
					//trace("INTERPOLATING " + mag);
					percIter = (_level.Scale/2)/mag;
				}
				for(perc = percIter; perc <= 1 && hit == 0; perc += percIter){
					vec.normalize(perc*mag);
					//trace("INTER");
					nx = px - vec.x;
					ny = py - vec.y;
					//if(Math.abs(px-nx) > Math.abs(px-tx)) nx = tx;
					//if(Math.abs(py-ny) > Math.abs(py-ty)) ny = ty;
					hit = (_intangible ? 0:_level.canMoveTo(this,nx,ny));
				}
				/*if(mag > tol) {
					trace("INTER : " + hit + " [" + dx + "," + dy + "]");
				}
				vec.normalize(perc-percIter);
				var xTemp:Number = vec.x;
				var yTemp:Number = vec.y;
				if(hit&Level.EAST != Level.EAST && hit&Level.WEST != Level.WEST){
					trace("HORIZ NOT TRIGGERED");
					for(perc = percIter; perc <= 1 && hit&Level.EAST != Level.EAST && hit&Level.WEST != Level.WEST; perc += percIter){
						vec.normalize(perc*mag);
						nx = px - vec.x;
						hit = _level.canMoveTo(this,nx,yTemp);
					}
				}
				if(hit&Level.SOUTH != Level.SOUTH && hit&Level.NORTH != Level.NORTH){
					trace("VERT NOT TRIGGERED");
					for(perc = percIter; perc <= 1 && hit&Level.SOUTH != Level.SOUTH && hit&Level.NORTH != Level.NORTH; perc += percIter){
						vec.normalize(perc*mag);
						ny = py - vec.y;
						hit = _level.canMoveTo(this,xTemp,ny);
					}
				}*/
				//trace("Test t[" + tx + "," + ty + "] n[" + nx + "," + ny + "] vec[" + vec.x + "," + vec.y + "] delta[" + dx + "," + dy + "] p[" + px + "," + py + "] " + vec.length + " " + mag + " " + perc);
				
				if((hit&Level.EAST) == Level.EAST){
					px = _level.toPixelRaster(nx+Width)*_level.Scale-Width;
				}else if((hit&Level.WEST) == Level.WEST){
					px = _level.toPixelRaster(nx)*_level.Scale+_level.Scale;
				}else{
					px = nx;
					
				}
				
				if((hit&Level.SOUTH) == Level.SOUTH){
					py = _level.toPixelRaster(ny+Height)*_level.Scale-Height;
				}else if((hit&Level.NORTH) == Level.NORTH){
					py = _level.toPixelRaster(ny)*_level.Scale+_level.Scale;
				}else{
					py = ny;
				}
				/*nx += dx/8;
				ny += dy/8;
				hit = _level.canMoveTo(this,px,py);*/
				//timeout --;
			//}while(hit != 0 && timeout > 0);
			
			this.x = px;
			this.y = py;
		}
		
		public function setVel(vx:Number, vy:Number):void{
			this._vx = vx;
			this._vy = vy;

			if(_vx > this._maxVX) _vx = this._maxVX;
			if(-_vx > this._maxVX) _vx = -this._maxVX;
			if(_vy > this._maxVY) _vy = this._maxVY;
			if(-_vy > this._maxVY) _vy = -this._maxVY;
		}
		public function push(fx:Number, fy:Number):void{
			this.setVel(_vx + fx, _vy + fy);
		}

		protected function applyDamp():void{
			if(onGround()){ //On Ground
				this.setVel(_vx * _frictionDamp, _vy);
			}
			else {
				this.setVel(_vx * _airDamp, _vy);
			}
		}
		
		public function onGround():Boolean{
			return (_vy>=0) && (_adj&Level.SOUTH) == Level.SOUTH;
		}
		
		public function get VX():Number { return _vx; }
		public function get VY():Number { return _vy; }
		public function get Width():Number { return _boundWidth; }
		public function get Height():Number { return _boundHeight; }
		public function get MyLevel():Level { return _level; }
	}
	
}
