package com.upgrage {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class ControlsScreen extends MovieClip {
		
		
		public function ControlsScreen() {
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded(e:Event):void{
			//this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addListeners();
		}
		
		private function addListeners(){
			play_btn.addEventListener(MouseEvent.MOUSE_UP,onPlay);
			menu_btn.addEventListener(MouseEvent.MOUSE_UP,onMenu);
		}
		
		private function removeListeners(){
			play_btn.removeEventListener(MouseEvent.MOUSE_UP,onPlay);
			menu_btn.removeEventListener(MouseEvent.MOUSE_UP,onMenu);
		}
		
		private function onPlay(e:Event):void{
			removeListeners();
			MovieClip(root).gotoAndStop("game");
		}
		
		private function onMenu(e:Event):void{
			removeListeners();
			MovieClip(root).gotoAndStop("menu");
		}
		
	}
	
}