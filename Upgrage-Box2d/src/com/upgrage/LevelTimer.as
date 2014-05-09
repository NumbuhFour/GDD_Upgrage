package com.upgrage {
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import com.upgrage.components.physics.PhysicsWorld;
	import flash.events.TimerEvent;
	
	public class LevelTimer extends MovieClip{
		
		private var _paused:Boolean;
		private var _timer:Timer;
		private var _totalTime:Number;
		private var _currentTime:Number;
		
		public function set StartTime(time:int) { _totalTime = time; }
		public function get SecondsLeft():Number { return _currentTime*1000; }
		public function get isRunning(): { return !_paused; }
		
		public function LevelTimer() {
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, tick);
			_timer.start();
			_paused = true;
		}
		
		private function tick(){
			if (!_paused)
				_currentTime -= 100;
		}		
		
		public function start(){
			_paused = false;
		}

		public function reset(){
			_currentTime = _totalTime;
		}
		
		public function pause(){
			_paused = true;
		}
		
		public function addTime(time:int){
			_currentTime += time;
		}
		
		public function cleanup(){
			if (_timer)
				_timer.removeEventListener(TimerEvent.TIMER, tick);
		}

		
	}
	
}
