package com.upgrage.util {
	
	public class Direction {
		public static const NORTH:Direction = new Direction(0);
		public static const EAST:Direction = new Direction(1);
		public static const SOUTH:Direction = new Direction(2);
		public static const WEST:Direction = new Direction(3);
		
		private var _val:int = 0;
		private function Direction(int val){
			this._val = val;
		}
		
		//Find the direction that is this + 90*n degrees
		public function rotateClockwise(n:int):Direction
		{
			var additive:int = _val + n;
			additive %= 4;
			
			switch(additive)
			{
				case 0: return NORTH;
				case 1: return EAST;
				case 2: return SOUTH;
				case 3: return WEST;
			}
			return null;
		}
	}
	
}
