package com.upgrage.components {
	import flash.display.MovieClip;
	
	public class GraphicalObject extends MovieClip{
		
		public function duplicate():MovieClip {
			var clazz:Class = Object(this).constructor;
			var instance:MovieClip = new clazz() as MovieClip;
			parent.addChild(instance);
			return instance;
			//return new GraphicalObject();
		}

	}
	
}
