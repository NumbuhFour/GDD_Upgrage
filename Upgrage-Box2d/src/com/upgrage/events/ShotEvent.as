package com.upgrage.events {
	import flash.events.Event;
	import Box2D.Dynamics.b2Fixture;
	
	//Called when something is hit by bullet
	public class ShotEvent extends Event{

		public static const SHOT:String = "shotByBullet";
		
		public var hit:b2Fixture;
		
		public function ShotEvent(hit:b2Fixture) {
			super(SHOT);
			this.hit = hit;
		}
		
		public override function clone():Event
		{
			return new ShotEvent(this.hit);
		}

	}
	
}
