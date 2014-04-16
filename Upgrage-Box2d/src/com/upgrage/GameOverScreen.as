package com.upgrage {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class GameOverScreen extends MovieClip {
		
		
		public function GameOverScreen() {
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded(e:Event):void{
			//this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addListeners();
		}
		
		private function addListeners(){
			yes_btn.addEventListener(MouseEvent.MOUSE_UP,onYes);
			no_btn.addEventListener(MouseEvent.MOUSE_UP,onNo);
		}
		
		private function removeListeners(){
			yes_btn.removeEventListener(MouseEvent.MOUSE_UP,onYes);
			no_btn.removeEventListener(MouseEvent.MOUSE_UP,onNo);
		}
		
		private function onYes(e:Event):void{
			removeListeners();
			MovieClip(root).gotoAndStop("game");
		}
		
		private function onNo(e:Event):void{
			removeListeners();
			MovieClip(root).gotoAndStop("menu");
		}
		
	}
	
}
