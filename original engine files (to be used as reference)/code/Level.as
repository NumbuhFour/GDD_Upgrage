package code {
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.MovieClip;
	
	public class Level {

		
		public static const NO_HIT:uint = 0;
		public static const EAST:uint = 1;
		public static const NORTH:uint = 2;
		public static const WEST:uint = 4;
		public static const SOUTH:uint = 8;
		
		public static const AIR_TILE:uint = 0;
		public static const GROUND_TILE:uint = 1;
		public static const FALLTHROUGH_TILE:uint = 2;
		
		private var _width:int;
		private var _height:int;
		private var _scale:Number = 10;//oops not const
		
		private var _map:Array;
		
		private var _ents:Dictionary;
		
		private var _world:MovieClip
		
		public function Level(world:MovieClip, width:int, height:int) {
			this._world = world;
			this._width = width;
			this._height = height;
			_map = new Array();
			for(var x:int = 0; x < _width; x++){
				_map[x] = new Array();
				for(var y:int = 0; y < _height; y++){
					_map[x][y] = 0;
				}
			}
			
			_ents = new Dictionary();
		}
		
		public function setTile(x:int, y:int, value:uint){
			_map[x][y] = value;
		}
		
		public function addEntity(e:Entity){
			e.setLevel(this);
			_ents[e] = e;
		}
		
		public function destroy(e:Entity){
			_world.removeChild(e);
			delete _ents[e];
		}
		
		public function canMoveTo(e:Entity, x:Number, y:Number):uint{
			var ex:Number = e.x;
			var ey:Number = e.y;
			var nx:Number = x;
			var ny:Number = y;

			var rtn:uint = 0;
			
			var wIter:Number = e.Width/2;
			var hIter:Number = e.Height/2;
			
			/*var vec:Point = new Point(nx-ex, ny-ey);
			var mag:Number = vec.length;
			var tol:Number = Scale;
			var perc:Number = 1;
			var percIter:Number = 1;
			
			if(mag > tol){
				trace("INTERPOLATINGlevel");
				percIter = (Scale/2)/mag;
			}
			for(perc = percIter; perc <= 1; perc += percIter){
				vec.normalize(perc*mag);
				nx = ex + vec.x;
				ny = ey + vec.y;*/
				if(e is Player){
					for(var ix:Number = 0; ix < e.Width; ix ++){
						for(var iy:Number = 0; iy < e.Height; iy ++){
							var n:uint;
							if(x > ex && (rtn&EAST) != EAST && (n=checkPoint(nx + e.Width, ey + iy))!=AIR_TILE && n != FALLTHROUGH_TILE) rtn |= EAST;
							if(y < ey && (rtn&NORTH) != NORTH && (n=checkPoint(ex + ix, ny))!=AIR_TILE && n != FALLTHROUGH_TILE) rtn |= NORTH;
							if(x < ex && (rtn&WEST) != WEST && (n=checkPoint(nx, ey + iy))!=AIR_TILE && n != FALLTHROUGH_TILE) rtn |= WEST;
							if(y > ey && (rtn&SOUTH) != SOUTH && (n=checkPoint(ex + ix, ny + e.Height))!=AIR_TILE) {
								/*if(n == FALLTHROUGH_TILE && e.VY > 0){
									var ycheck:Number = ny + e.Height;
									ycheck = this.toPixelRaster(ycheck)*this.Scale;
									var diff:Number = ycheck - (ny + e.Height);
									//if(diff != 0) trace("RAWR CHECK " + diff);
	//								if(diff >= -5) 
										rtn |= SOUTH;
								}else{*/
									rtn |= SOUTH;
								//}
							}
						}
					}
				}else{
					var ix:Number = e.Width/2;
					var iy:Number = e.Height/2;
					var n:uint;
					if(x > ex && (rtn&EAST) != EAST && (n=checkPoint(nx + e.Width, ey + iy))!=AIR_TILE && n != FALLTHROUGH_TILE) rtn |= EAST;
					if(y < ey && (rtn&NORTH) != NORTH && (n=checkPoint(ex + ix, ny))!=AIR_TILE && n != FALLTHROUGH_TILE) rtn |= NORTH;
					if(x < ex && (rtn&WEST) != WEST && (n=checkPoint(nx, ey + iy))!=AIR_TILE && n != FALLTHROUGH_TILE) rtn |= WEST;
					if(y > ey && (rtn&SOUTH) != SOUTH && (n=checkPoint(ex + ix, ny + e.Height))!=AIR_TILE) {
							rtn |= SOUTH;
						/*if(n == FALLTHROUGH_TILE && e.VY > 0){
							var ycheck:Number = ny + e.Height;
							ycheck = this.toPixelRaster(ycheck)*this.Scale;
							var diff:Number = ycheck - (ny + e.Height);
							//if(diff != 0) trace("RAWR CHECK " + diff);
//								if(diff >= -5) 
								rtn |= SOUTH;
						}else{
							rtn |= SOUTH;
						}*/
					}
				}
			//}
			
			
			return rtn;
		}
		
		public function getAdjacentWalls(e:Entity, dist:int=1):uint {
			var ex:Number = e.x;
			var ey:Number = e.y;

			var rtn:uint = 0;
			
			if(e is Player){
				var wIter:Number = e.Width/2;
				var hIter:Number = e.Height/2;
				for(var ix:Number = 0; ix < e.Width; ix ++){
					for(var iy:Number = 0; iy < e.Height; iy ++){
						var n:uint;
						if((n=checkPoint(ex + ix, ey - dist)) != AIR_TILE && n!=FALLTHROUGH_TILE) rtn |= NORTH;
						if((n=checkPoint(ex + e.Width + dist, ey + iy)) != AIR_TILE && n!=FALLTHROUGH_TILE) rtn |= EAST;
						if((n=checkPoint(ex - dist, ey + iy)) != AIR_TILE && n!=FALLTHROUGH_TILE) rtn |= WEST;
						if((n=checkPoint(ex + ix, ey + e.Height + dist)) != AIR_TILE /*&& ((n==FALLTHROUGH_TILE && checkPoint(ex + ix, ey + e.Height + dist-5) == AIR_TILE) || n==GROUND_TILE)*/){
							rtn |= SOUTH;
							/*if(n == FALLTHROUGH_TILE && e.VY > 0){
								var ycheck:Number = ey+e.Height+dist;
								ycheck = this.toPixelRaster(ycheck)*this.Scale;
								var diff:Number = ycheck - (ey+e.Height);
								//if(diff != 0) trace("RAWR " + diff);
	//							if(diff >= -5)
									rtn |= SOUTH;
							}else{
								rtn |= SOUTH;
							}*/
						}
					}
				}
			}else{
				var ix:Number = e.Width/2;
				var iy:Number = e.Height/2;
				var n:uint;
				if((n=checkPoint(ex + ix, ey - dist)) != AIR_TILE && n!=FALLTHROUGH_TILE) rtn |= NORTH;
				if((n=checkPoint(ex + e.Width + dist, ey + iy)) != AIR_TILE && n!=FALLTHROUGH_TILE) rtn |= EAST;
				if((n=checkPoint(ex - dist, ey + iy)) != AIR_TILE && n!=FALLTHROUGH_TILE) rtn |= WEST;
				if((n=checkPoint(ex + ix, ey + e.Height + dist)) != AIR_TILE /*&& ((n==FALLTHROUGH_TILE && checkPoint(ex + ix, ey + e.Height + dist-5) == AIR_TILE) || n==GROUND_TILE)*/){
					rtn |= SOUTH;
					/*if(n == FALLTHROUGH_TILE && e.VY > 0){
						var ycheck:Number = ey+e.Height+dist;
						ycheck = this.toPixelRaster(ycheck)*this.Scale;
						var diff:Number = ycheck - (ey+e.Height);
						//if(diff != 0) trace("RAWR " + diff);
	//							if(diff >= -5)
							rtn |= SOUTH;
					}else{
						rtn |= SOUTH;
					}*/
				}
			}
			
			return rtn;
		}
		
		public function checkPoint(x:Number, y:Number):uint {
			var px:int = toPixelRaster(x);
			var py:int = toPixelRaster(y);

			if(px < 0 || px >= _width || py < 0 || py >= _height) return 0;
			
			//trace("CHECK [" + px + "," + py + "] [" + x + "," + y + "]");
			
			return _map[px][py];
		}
		
		public function toPixelRaster(coord:Number):Number{
			return Math.floor(coord / _scale);
		}
		
		public function findCollidingEntities(rect:Rectangle, ignore:Entity = null):Dictionary{
			var rtn:Dictionary = new Dictionary();
			for each(var e:Entity in _ents){
				if(e != ignore){
					var check:Rectangle = new Rectangle(e.x, e.y, e.Width, e.Height);
					var overlap = check.union(rect);
					if(overlap.width < rect.width+check.width && overlap.height < rect.height+check.height){
						rtn[e] = e;
					}
				}
			}
			return rtn;
		}

		public function get Width():Number { return _width; }
		public function get Height():Number { return _height; }
		public function get Scale():Number { return _scale; }
		
		public function update(){
			for each(var e:Entity in _ents){
				e.update();
			}
		}

	}
	
}
