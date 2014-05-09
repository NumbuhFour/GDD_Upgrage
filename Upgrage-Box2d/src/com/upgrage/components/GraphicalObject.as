package com.upgrage.components {
	import flash.display.MovieClip;
	
	public class GraphicalObject extends MovieClip{
		
		public function duplicate():MovieClip {
			var clazz:Class = Object(this).constructor;
			var instance:MovieClip = new clazz() as MovieClip;
			instance.width = this.width;
			instance.height = this.height;
			instance.rotation = this.rotation;
			instance.x = this.x;
			instance.y = this.y;
			instance.scaleX = this.scaleX;
			instance.scaleY = this.scaleY;
			if(this.isPlaying){
				instance.gotoAndPlay(this.currentFrame);
			}else{
				instance.gotoAndStop(this.currentFrame);
			}
			parent.addChild(instance);
			return instance;
			//return new GraphicalObject();
		}

	}
	
}
