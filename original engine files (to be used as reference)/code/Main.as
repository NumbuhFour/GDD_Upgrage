package code {
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import com.as3toolkit.ui.Keyboarder;
	
	public class Main extends MovieClip{
		
		public function Main() {
			new Keyboarder(this);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		public function onMouseMove(e:MouseEvent):void{
			MouseLog.x = e.stageX;
			MouseLog.y = e.stageY;
		}
		public function onMouseDown(e:MouseEvent):void{
			MouseLog.x = e.stageX;
			MouseLog.y = e.stageY;
			MouseLog.isMouseDown = true;
		}
		public function onMouseUp(e:MouseEvent):void{
			MouseLog.x = e.stageX;
			MouseLog.y = e.stageY;
			MouseLog.isMouseDown = false;
		}

	}
	
}
