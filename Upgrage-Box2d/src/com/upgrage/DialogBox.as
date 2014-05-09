package com.upgrage {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.as3toolkit.ui.Keyboarder;
	import flash.ui.Keyboard;
	import com.upgrage.components.physics.PhysicsWorld;
	import com.upgrage.util.Queue;
	import flash.events.KeyboardEvent;
	
	
	public class DialogBox extends MovieClip {
		
		private var _queue:Queue;
		private var _text:String = "";
		private var _open:Boolean = false;
		private var _world:PhysicsWorld;
		
		public function DialogBox() {

			_queue = new Queue();

			_world = PhysicsWorld(parent);
		}
		
		private var _spaceDown:Boolean = false;
		private function onEnter_Frame(e:KeyboardEvent):void{
			//var down:Boolean = Keyboarder.keyIsDown(Keyboard.SPACE);
			if(e.keyCode == Keyboard.SPACE){//down && !_spaceDown){
				if(_open){
					if (!_queue.empty){
						_text = _queue.read();
						this.innerMC.textMC.text = _text;
					}
					else{
						this.gotoAndStop(0);
						_world.unpause();
						stage.removeEventListener(KeyboardEvent.KEY_UP, onEnter_Frame);
						_text = "";
					}
				}
			}
			//_spaceDown = down;
		}
		
		public function pushText(text:String):void{
			stage.addEventListener(KeyboardEvent.KEY_UP, onEnter_Frame);
			var arr:Array = text.split("\"");
			for each(var i:String in arr)
				_queue.write(i);
			if (_text == "")
				_text = _queue.read();
			this.gotoAndStop("show");
			this.innerMC.textMC.text = _text;
			_open = true;
			_world.pause();
		}
	}
	
}
