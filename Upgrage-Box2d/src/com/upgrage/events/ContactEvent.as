package com.upgrage.events {
	
	import flash.events.Event;
	public class ContactEvent extends Event{
		
		public var triggerID:String;
		public var colliding:Boolean; //Determines whether exiting or entering collision
		
		public function ContactEvent(type:String, triggerID:String, colliding:Boolean):void {
			super(type);
			this.triggerID = triggerID;
			this.colliding = colliding;
		}
		
		public override function clone():Event
		{
			return new ContactEvent(this.type,this.triggerID,colliding);
		}
	}
	
}
