package com.upgrage {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.as3toolkit.ui.Keyboarder;
	import flash.ui.Keyboard;
	import com.upgrage.components.physics.PhysicsWorld;
	
	
	public class DialogBox extends MovieClip {
		
		private var _vector:Vector.<String>;
		private var _text:String = "Hello World";
		private var _open:Boolean = false;
		private var _world:PhysicsWorld;
		
		public function DialogBox() {

			_vector = new Vector.<String>();

			_world = PhysicsWorld(parent);
		}
		
		private var _spaceDown:Boolean = false;
		private function onEnter_Frame(e:Event):void{
			var down:Boolean = Keyboarder.keyIsDown(Keyboard.SPACE);
			if(down && !_spaceDown){
				if(_open){
					if (_vector.length > 0){
						_text = _vector.pop();
						this.innerMC.textMC.text = _text;
					}
					else{
						this.gotoAndStop(0);
						_world.unpause();
						this.removeEventListener(Event.ENTER_FRAME, onEnter_Frame);
					}
				}
			}
			_spaceDown = down;
		}
		
		public function pushText(text:String):void{
			this.addEventListener(Event.ENTER_FRAME, onEnter_Frame);
			var arr:Array = text.split("\"");
			for (var i:int = arr.length-1; i >= 0; i--)
				_vector.push(arr[i]);
			_text = _vector.pop();
			this.gotoAndStop("show");
			this.innerMC.textMC.text = _text;
			_open = true;
			_world.pause();
		}
	}
	
}
