package com.upgrage {
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import com.upgrage.components.physics.PhysicsWorld;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	public class LevelTimer extends MovieClip{
		
		private var _paused:Boolean;
		private var _timer:Timer;
		private var _totalTime:Number;
		private var _currentTime:Number;
		private var _running:Boolean;
		private var _timing:Boolean;
		private var _clockMode:Boolean;
		
		public function get StartTime():int { return _totalTime; }
		public function set StartTime(time:int) { _totalTime = time; }
		public function get TimeLeft():Number { return _currentTime; }
		public function get ClockMode():Boolean { return _clockMode; }
		public function get isRunning():Boolean { return _timing; }
		public function get isPaused():Boolean { return _paused; }
		
		public function LevelTimer() {
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, tick);
			_timer.start();
			_paused = true;
			_timing = false;
			_clockMode = false;
		}
		
		private function tick(e:Event){
			if (!_paused)
				_currentTime -= 100;
		}		
		
		public function start(){
			_paused = false;
			_timing = true;
		}

		public function reset(){
			_currentTime = _totalTime;
		}
		
		public function unpause(){
			_paused = false;
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
