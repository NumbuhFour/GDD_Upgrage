package com.upgrage.events {
	
	import flash.events.Event;
	import Box2D.Dynamics.b2Fixture;

	public class ContactEvent extends Event{
		
		public var triggerID:String;
		public var colliding:Boolean; //Determines whether exiting or entering collision
		public var collider:b2Fixture;
		public var fixture:b2Fixture;
		
		public function ContactEvent(type:String, triggerID:String, colliding:Boolean, collider:b2Fixture, fixture:b2Fixture):void {
			super(type);
			this.triggerID = triggerID;
			this.colliding = colliding;
			this.collider = collider;
			this.fixture = fixture;
		}
		
		public override function clone():Event
		{
			return new ContactEvent(this.type,this.triggerID,colliding,collider,fixture);
		}
	}
	
}
