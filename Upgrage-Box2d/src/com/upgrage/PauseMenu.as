package com.upgrage {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.upgrage.components.physics.PhysicsWorld;
	
	public class PauseMenu extends MovieClip{

		private var _world:PhysicsWorld;
		
		public function PauseMenu() {
			_world = (((parent as MovieClip).getChildByName("level") as MovieClip).getChildByName("world") as PhysicsWorld);
			stop();
		}
		
		public function show(){
			menu_btn.addEventListener(MouseEvent.MOUSE_UP, onMenu);
			continue_btn.addEventListener(MouseEvent.MOUSE_UP, onContinue)
			_world.pause();
			gotoAndPlay("rollout");
		}

		public function close(){
			menu_btn.removeEventListener(MouseEvent.MOUSE_UP, onMenu);
			continue_btn.removeEventListener(MouseEvent.MOUSE_UP, onContinue)
			_world.unpause();
			gotoAndPlay("rollin");
		}
		
		private function onContinue(e:MouseEvent):void{
			close();
		}
		
		private function onMenu(e:MouseEvent):void{
			close();
			_world.cleanup()
			MovieClip(root).gotoAndStop("menu");
		}
		
		
		
	}
	
}
