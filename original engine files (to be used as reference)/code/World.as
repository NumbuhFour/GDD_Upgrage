package code {
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import com.as3toolkit.ui.Keyboarder;
	import flash.ui.Keyboard;
	import flash.display.DisplayObject;
	
	
	public class World extends MovieClip {

		private var _level:code.Level;
		
		public function World() {
			this.bounds_clip.visible = false;
			var test:BitmapData = new LevelTest();
				
			_level = LevelLoader.load(this, test);
			_level.addEntity(this.player_clip);
			
			var i:int = 0;
			for (i = 0; i<this.numChildren; i++)
			{
				var child:DisplayObject = this.getChildAt(i);
				if(child is Entity){
					_level.addEntity(child as Entity);
				}
			}
			
			this.addEventListener(Event.ENTER_FRAME, onUpdateCall);
		}
		
		public function onUpdateCall(e:Event){
			this.bounds_clip.visible = Keyboarder.keyIsDown(Keyboard.M);
			_level.update();
			var player:Entity = (player_clip as Entity);
			var levelW:Number = _level.Width*_level.Scale;
			var levelH:Number = _level.Height*_level.Scale;
			this.x = Math.max(Math.min(-player.x + stage.stageWidth/2 - player.Width/2, 0),-levelW+stage.stageWidth);
			this.y = Math.max(Math.min(-player.y + stage.stageHeight/2 - player.Height/2, 0),-levelH+stage.stageHeight);
			
			//var xRatio:Number = _level.x/player.x;
			//var xRatio:Number = bg_clip.height/_level.Height;
			
			var wTest:Number = levelW*0.75;
			this.bg_clip.x = -(levelW/2 - player.x)*0.25 + levelW/2;
			//this.bg_clip.x = _level.Width*_level.Scale/player.x;
			//this.bg_clip.y = -(levelH/2 - player.y)*0.25 + levelH/2;
		}
	}
	
}
