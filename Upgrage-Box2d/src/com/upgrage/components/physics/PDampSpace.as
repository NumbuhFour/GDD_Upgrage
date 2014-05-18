package com.upgrage.components.physics {
	
	import flash.display.MovieClip;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import flash.events.Event;
	import flash.display.Sprite;
	import com.upgrage.events.ContactEvent;
	import Box2D.Dynamics.b2Fixture;
	import flash.utils.Dictionary;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2FilterData;
	
	
	public class PDampSpace extends PTrigger {

		protected var _collisionFilter:b2FilterData;
		
		private var _addedXVel:Number;
		private var _addedYVel:Number;
		private var _dampSet:Number;
		private var _gravitySetX:Number;
		private var _gravitySetY:Number;
		private var _enableInfiniteJumps:Boolean = true;
		
		protected var _affectedEntities:Dictionary = new Dictionary();
		
		public function PDampSpace() {
		}
		
		protected override function updateSelfToGraphics():void {
			super.updateSelfToGraphics();
			if(_world != null) {
				_shape = new b2PolygonShape();
				(_shape as b2PolygonShape).SetAsBox(this.width/2/_world.pscale, this.height/2/_world.pscale)
				_fixtureDef.shape = _shape;
				_fixture = _body.CreateFixture(_fixtureDef);
			}
		}
		
		protected override function drawBounds():void {
			super.drawBounds();
			graphics.clear();
			graphics.endFill();
			graphics.lineStyle(3,isStatic ? 0xffDD00 : (this._body != null && this._body.IsAwake() ? 0x00ff00:0xBBDDBB)); //Red:Static, Green:Moving, Gray:Sleeping
			graphics.drawRect(-width/2,-height/2, width,height);
			graphics.moveTo(0,0);
			graphics.lineTo(width/2,0);
		}
		
		protected override function setup(e:Event):void {
			super.setup(e);
			
			_shape = new b2PolygonShape();
			(_shape as b2PolygonShape).SetAsBox(this.width/2/_world.pscale, this.height/2/_world.pscale)
			_fixtureDef.shape = _shape;
			_fixtureDef.isSensor = true;
			_fixture = _body.CreateFixture(_fixtureDef);

			_collisionFilter = new b2FilterData();
			_collisionFilter.groupIndex = -5; //-5 for water, kinda arbitrary
			
			_fixture.SetFilterData(_collisionFilter);
			
			this._world.addEventListener(PhysicsWorld.TRIGGER_CONTACT, onContact);
		}
		public override function onTick(e:Event):void{
			super.onTick(e);
			for each(var key:Object in _affectedEntities){
				if(key == null || key is DataStore) continue;
				var phys:PhysicsObj = key as PhysicsObj;
				phys.body.ApplyImpulse(new b2Vec2(this._addedXVel, this._addedYVel),phys.body.GetWorldCenter());
				var player:PPlayer = phys as PPlayer;
				if(player && this._enableInfiniteJumps) {
					player.midAirJumpsLeft = -1;
				}
			}
		}
		
		public function onContact(e:ContactEvent):void{
			if(e.collider.GetBody().GetUserData() != this) return;
			if(e.fixture.IsSensor()) return; //If colliding with a sensor, ignore
			
			var fixture:b2Fixture = e.fixture;
			var obj:PhysicsObj = (fixture.GetBody().GetUserData() as PhysicsObj);
			var player:PPlayer = obj as PPlayer;
			
			if(obj == null) return;
			if(e.colliding && !obj.inWater){
				if(_affectedEntities[obj] != null) return;
				_affectedEntities[obj] = new DataStore(obj.body.GetLinearDamping(), obj.gravity,(player ? player.Upgrades["mid air jumps"]:0));
				obj.gravity = new b2Vec2(this._gravitySetX, this._gravitySetY);
				obj.body.SetLinearDamping(this._dampSet);
				if(player && this._enableInfiniteJumps) {
					player.Upgrades["mid air jumps"] = -1;
					player.midAirJumpsLeft = -1;
				}
				obj.inWater = true;
				obj.water = this;
			}else if(!e.colliding && obj.water == this){
				var data = DataStore(_affectedEntities[obj]);
				if(data == null) return;
				obj.body.SetLinearDamping(data._damp);
				obj.gravity = data._grav;
				if(player){
					player.Upgrades["mid air jumps"] = data._jumps;
					player.midAirJumpsLeft = data._jumps;
				}
				delete _affectedEntities[obj];
				obj.inWater = false;
			}
			
		}
		
		[Inspectable(name="Added X Vel", type=Number, defaultValue="0")]
		public function set addedXVel(val:Number):void {
			this._addedXVel = val;
		}
		public function get addedXVel():Number { return this._addedXVel; }
		
		[Inspectable(name="Added Y Vel", type=Number, defaultValue="0")]
		public function set addedYVel(val:Number):void {
			this._addedYVel = val;
		}
		public function get addedYVel():Number { return this._addedYVel; }
		
		
		[Inspectable(name="Dampening", type=Number, defaultValue="0")]
		public function set dampSet(val:Number):void {
			this._dampSet = val;
		}
		public function get dampSet():Number { return this._dampSet; }
		
		
		
		[Inspectable(name="Gravity X", type=Number, defaultValue="0")]
		public function set gravitySetX(val:Number):void {
			this._gravitySetX = val;
		}
		public function get gravitySetX():Number { return this._gravitySetX; }
		
		[Inspectable(name="Gravity Y", type=Number, defaultValue="0")]
		public function set gravitySetY(val:Number):void {
			this._gravitySetY = val;
		}
		public function get gravitySetY():Number { return this._gravitySetY; }
		
		
		
		[Inspectable(name="Inifinite Jumps", type=Boolean, defaultValue="true")]
		public function set enableInfiniteJumps(val:Boolean):void {
			this._enableInfiniteJumps = val;
		}
		public function get enableInfiniteJumps():Boolean { return this._enableInfiniteJumps; }
	}
	
}
import Box2D.Common.Math.b2Vec2;


		
class DataStore{
	public var _damp:Number;
	public var _grav:b2Vec2;
	public var _jumps:Number;
	public function DataStore(damp:Number, grav:b2Vec2,jumps:Number){
		this._damp = damp;
		this._grav = grav;
		this._jumps = jumps;
	}
}