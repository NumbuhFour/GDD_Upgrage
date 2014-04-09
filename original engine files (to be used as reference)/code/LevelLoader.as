package code {
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	
	public class LevelLoader {

		public static const AIR:uint = 0xFFFFFF;
		public static const GROUND:uint = 0;
		public static const FALLTHROUGH:uint = 0x0000FF;

		public static function load(world:MovieClip, img:BitmapData):Level {
			var w:int = img.width;
			var h:int = img.height;
			var rtn:Level = new Level(world, w,h);
			
			for(var x:int = 0; x < w; x++){
				for(var y:int = 0; y < h; y++){
					var pixel:uint = img.getPixel(x,y);
					if(pixel == GROUND){					
						rtn.setTile(x,y,Level.GROUND_TILE);
					}else if(pixel == FALLTHROUGH){
						rtn.setTile(x,y,Level.FALLTHROUGH_TILE);
					}
				}
			}
			
			return rtn;
		}

	}
	
}
