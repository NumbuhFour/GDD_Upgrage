package com.upgrage.components.physics {
	
	import flash.events.Event;
	public class ContactEvent extends Event{
		
		public var triggerID:String;
		
		public function ContactEvent(type:String, triggerID:String):void {
			super(type);
			this.triggerID = triggerID;
		}
		
		public override function clone():Event
		{
			return new ContactEvent(this.type,this.triggerID);
		}
	}
	
}
