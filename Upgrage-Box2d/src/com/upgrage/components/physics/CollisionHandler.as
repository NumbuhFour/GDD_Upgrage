package com.upgrage.components.physics {
	
	import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Dynamics.Joints.*;
    import Box2D.Dynamics.Contacts.*;
    import Box2D.Common.*;
    import Box2D.Common.Math.*;
	
	import com.upgrage.events.ContactEvent;
	
	public class CollisionHandler extends b2ContactListener{
		private var _world:PhysicsWorld;
		
		public function CollisionHandler(world:PhysicsWorld):void{
			this._world = world;
		}
		
		override public function BeginContact(contact:b2Contact):void {
            // getting the fixtures that collided
            var fixtureA:b2Fixture=contact.GetFixtureA();
            var fixtureB:b2Fixture=contact.GetFixtureB();
            // if the fixture is a sensor, mark the parent body to be removed
			var trigger:PTrigger;
			var userData:Object;
			var secUserData:Object;
            if (fixtureB.IsSensor()) {
				userData = fixtureB.GetBody().GetUserData();
				secUserData = fixtureA.GetBody().GetUserData();
				if(userData is PTrigger && secUserData is PPlayer){
					trigger = userData as PTrigger;
					if(!trigger.disabled) _world.dispatchEvent(new ContactEvent(PhysicsWorld.TRIGGER_CONTACT,trigger.name,true,fixtureB,fixtureA));
				}else if(userData is PEntity){ //If the trigger belongs to the player
					(userData as PEntity).onHit(fixtureA,fixtureB,contact,true);
				}
            }
            if (fixtureA.IsSensor()) {
				userData = fixtureA.GetBody().GetUserData();
				secUserData = fixtureB.GetBody().GetUserData();
				if(userData is PTrigger && secUserData is PPlayer){
					trigger = userData as PTrigger;
					if(!trigger.disabled) _world.dispatchEvent(new ContactEvent(PhysicsWorld.TRIGGER_CONTACT,trigger.name,true,fixtureA,fixtureB));
				}else if(userData is PEntity){ //If the trigger belongs to the player
					(userData as PEntity).onHit(fixtureB,fixtureA,contact,true);
				}
            }
        }
		
		override public function EndContact(contact:b2Contact):void {
            // getting the fixtures that collided
            var fixtureA:b2Fixture=contact.GetFixtureA();
            var fixtureB:b2Fixture=contact.GetFixtureB();
            // if the fixture is a sensor, mark the parent body to be removed
			var trigger:PTrigger;
			var userData:Object;
			var secUserData:Object;
            if (fixtureB.IsSensor()) {
				userData = fixtureB.GetBody().GetUserData();
				secUserData = fixtureA.GetBody().GetUserData();
				if(userData is PTrigger && secUserData is PPlayer){
					trigger = userData as PTrigger;
					if(!trigger.disabled) _world.dispatchEvent(new ContactEvent(PhysicsWorld.TRIGGER_CONTACT,trigger.name,false,fixtureB,fixtureA));
				}else if(userData is PEntity){ //If the trigger belongs to the player
					(userData as PEntity).onHit(fixtureA, fixtureB,contact,false);
				}
            }
            if (fixtureA.IsSensor()) {
				userData = fixtureA.GetBody().GetUserData();
				secUserData = fixtureB.GetBody().GetUserData();
				if(userData is PTrigger && secUserData is PPlayer){
					trigger = userData as PTrigger;
					if(!trigger.disabled) _world.dispatchEvent(new ContactEvent(PhysicsWorld.TRIGGER_CONTACT,trigger.name,false,fixtureA,fixtureB));
				}else if(userData is PEntity){ //If the trigger belongs to the player
					(userData as PEntity).onHit(fixtureB, fixtureA,contact,false);
				}
            }
		}
	}
	
}
