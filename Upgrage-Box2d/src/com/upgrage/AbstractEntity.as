package com.upgrage {
	import flash.geom.Rectangle;
	
	public class AbstractEntity {
		public static const MOVE_DAMP = 0.82;
		public static const MOVE_DAMP_MIDAIR = 0.95;

		public static const MOVE_LIM = 250;
		
		protected var _vx:Number=0;
		protected var _vy:Number=0;
		
		protected var _xpos:Number=0;
		protected var _zpos:Number=0;
		
		protected var _health:int=0;
		
		protected var _hitbox:Rectangle;
		protected var _world:WorldScreen;
		
		public function get vx():Number{ return _vx; }
		public function get vy():Number{ return _vy; }
		public function get xpos():Number{ return _xpos; }
		public function get ypos():Number{ return _ypos; }
		public function get hitbox():Rectangle { return _hitbox; }
		public function get health():Number{ return _health; }
		public function set health(value:Number):void{ _health = value; }

		public function AbstractEntity(world:WorldScreen) {
			this._world = world;
			this._hitbox = new Rectangle(0,0,this.width, this.height);
			_health = 10;
		}

		public function updateMovement():void
		{
			
			if(canMove()){
				if(this._world.canMoveTo(this,_xpos+vx,_ypos+vy)){
					this.setPosition(_xpos+vx,_ypos+vy);
				}else if(this._world.canMoveTo(this,_xpos,_ypos+vy)){
					this.setPosition(_xpos,_ypos+vy);
				}else if(this._world.canMoveTo(this,_xpos+vx,_ypos)){
					this.setPosition(_xpos+vx,_ypos);
				}
			}else{
				this.updateCameraPos();
			}
				
			if(y >= 0){
				_vx *= MOVE_DAMP;
			}else{
				_vx *= MOVE_DAMP_MIDAIR;
			}
			
			if(_health <= 0){
				_world.removeEntity(this);
				stop();
			}
			
			
			if(Math.abs(_vx) <= 1) _vx = 0;
			if(Math.abs(_vy) <= 1) _vy = 0;
			
			if(Math.abs(_vx) > MOVE_LIM) _vx = (_vx > 0 ? 1:-1)*MOVE_LIM;
			if(Math.abs(_vy) > MOVE_LIM) _vy = (_vy > 0 ? 1:-1)*MOVE_LIM;
		}
		
		public function push(ix:Number, iy:Number):void{
			this._vx += ix;
			this._vy += iy;
		}
		
		public function setVelocity(ix:Number, iy:Number):void{
			this._vx = ix;
			this._vy = iy;
		}
		
		public function setPosition(ix:int, iy:int):void {
			this._xpos = ix;
			this._ypos = iy;
			this._hitbox.x = ix;
			this._hitbox.y = iy;
		}
		
		public function onHit(damage:int, source:Entity):void{
			_health -= damage;
			knockback(60,source);
			if(_health <= 0){
				_world.removeEntity(this);
				stop();
			}
		}
		
		public function onCollide(player:Entity):void {
		}
		
		public function knockback(amount:Number=1.8, e:Entity=null, raise:Number=10):void{
			if(e == null){
				this.setVelocity(this.vx*-amount, this.vy*-amount); //Bump back from edge of map
			}else{
				var v:Vector3D = new Vector3D(this.xpos-e.xpos, this.ypos-e.ypos);
				v.normalize();
				
				v.scaleBy(amount);
				this.setVelocity(v.x,v.y);
			}
			_vy += raise;
		}
		
		public function canMove():Boolean {
			return true;
		}

	}
	
}
