package com.upgrage.components.physics {
	
	import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Dynamics.Joints.*;
    import Box2D.Dynamics.Contacts.*;
    import Box2D.Common.*;
    import Box2D.Common.Math.*;
	
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
            if (fixtureB.IsSensor()) {
				userData = fixtureB.GetBody().GetUserData();
				if(userData is PTrigger){
					trigger = userData as PTrigger;
					_world.dispatchEvent(new ContactEvent(PhysicsWorld.TRIGGER_CONTACT,trigger.triggerID,true));
				}else if(userData is PPlayer){ //If the trigger belongs to the player
					(userData as PPlayer).onHit(fixtureA,fixtureB,contact,true);
				}
            }
            if (fixtureA.IsSensor()) {
				userData = fixtureA.GetBody().GetUserData();
				if(userData is PTrigger){
					trigger = userData as PTrigger;
					_world.dispatchEvent(new ContactEvent(PhysicsWorld.TRIGGER_CONTACT,trigger.triggerID,true));
				}else if(userData is PPlayer){ //If the trigger belongs to the player
					(userData as PPlayer).onHit(fixtureB,fixtureA,contact,true);
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
            if (fixtureB.IsSensor()) {
				userData = fixtureB.GetBody().GetUserData();
				if(userData is PTrigger){
					trigger = userData as PTrigger;
					_world.dispatchEvent(new ContactEvent(PhysicsWorld.TRIGGER_CONTACT,trigger.triggerID,false));
				}else if(userData is PPlayer){ //If the trigger belongs to the player
					(userData as PPlayer).onHit(fixtureA, fixtureB,contact,false);
				}
            }
            if (fixtureA.IsSensor()) {
				userData = fixtureA.GetBody().GetUserData();
				if(userData is PTrigger){
					trigger = userData as PTrigger;
					_world.dispatchEvent(new ContactEvent(PhysicsWorld.TRIGGER_CONTACT,trigger.triggerID,false));
				}else if(userData is PPlayer){ //If the trigger belongs to the player
					(userData as PPlayer).onHit(fixtureB, fixtureA,contact,false);
				}
            }
		}
	}
	
}
