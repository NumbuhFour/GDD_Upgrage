package  com.upgrage{
	
	import flash.display.MovieClip;
	import com.as3toolkit.ui.Keyboarder;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class Document extends MovieClip {
		
		private var setup:Boolean = false;
		
		public function Document() {
			new Keyboarder(this);
			//ScriptParser.parser.loadScripts("levels.txt");
			//this.addEventListener(Event.ENTER_FRAME,onAdded);
			//this.addEventListener(Event.EXIT_FRAME,onRemove);
		}
		
		/*private function onAdded(e:Event):void{
			//this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			if(!setup){
				addMenuListeners();
			}
		}
		
		private function onRemove(e:Event):void{
			if(setup){
				trace("REMOVE");
				removeMenuListeners();
			}
		}*/
		
		
		/*private function addMenuListeners(){
			play_btn.addEventListener(MouseEvent.MOUSE_UP, onPlay);
			controls_btn.addEventListener(MouseEvent.MOUSE_UP, onControls);
			credits_btn.addEventListener(MouseEvent.MOUSE_UP, onCredits);
			setup = true;
		}
		private function removeMenuListeners():void{
			play_btn.removeEventListener(MouseEvent.MOUSE_UP, onPlay);
			controls_btn.removeEventListener(MouseEvent.MOUSE_UP, onControls);
			credits_btn.removeEventListener(MouseEvent.MOUSE_UP, onCredits);
			setup = false;
		}
		
		private function onPlay(e:Event):void{
			//removeMenuListeners();
			this.gotoAndStop("game");
		}
		private function onControls(e:Event):void{
			//removeMenuListeners();
			this.gotoAndStop("controls");
		}
		private function onCredits(e:Event):void{
			//removeMenuListeners();
			this.gotoAndStop("credits");
		}*/
	}
	
}
