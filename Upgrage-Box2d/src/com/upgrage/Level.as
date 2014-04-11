package com.upgrage {
	
	public class Level {

		private var _width:int;
		private var _height:int;
		private var _scale:Number = 10;
		
		private var _map:Array;
		
		private var _world:WorldScreen;

		public function Level(world:WorldScreen, width:int = 32, height:int = 32) {
			this._world = world;
			this._width = width;
			this._height = height;
			initMap();
		}
		
		private function initMap():void
		{
			_map = new Array();
			for(var x:int = 0; x < _width; x++){
				_map[x] = new Array();
				for(var y:int = 0; y < _height; y++){
					_map[x][y] = 0;
				}
			}
		}

		public function setTile(x:int, y:int, val:uint):void
		{
			_map[x][y] = val;
		}
		
		public function canMoveTo(e:Entity, x:Number, y:Number):Boolean
		{
			return false;
		}
		
		
	}
	
}
