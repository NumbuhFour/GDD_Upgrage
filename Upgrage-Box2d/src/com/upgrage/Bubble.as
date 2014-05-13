package com.upgrage {
	import flash.display.MovieClip;
	
	public class Bubble extends MovieClip{
		
		public function Bubble() {
		}
		
		public function tick(waterline:int){
			if (this.y < waterline)
				gotoAndPlay("pop");
			else
				this.y -= 10;
		}

	}
	
}
