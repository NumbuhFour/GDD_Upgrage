package code {
	
	import flash.display.MovieClip;
	
	import com.as3toolkit.ui.Keyboarder;
	import flash.ui.Keyboard;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	public class Player extends Entity {
		
		private var _jumpWasPressed:Boolean = false;
		private var _jumpCounter:uint = 0; //Hold length
		private var _jumps:uint = 0; //Number of double jumps
		private var _maxJumps:uint = 2;
		private var _onWall:int = 0;
		private var _wallSlideCounter:int = 0;
		
		private var _sprintCounter:uint = 0; //Dash animation counter for how long to display dash sprite
		private var _sprintYHold:Number = 0;
		
		private var _sprintWasPressed:Boolean = false;
		private var _dropWasPressed:Boolean = false;
		private var _attackWasPressed:Boolean = false;
		private var _attackCooldown:uint = 0;
		
		private var _status:String = "idle";
		
		private var _tongue:Tongue;
		private var _tonguex:Number;
		private var _tonguey:Number;
		private var _tonguer:Number;
		
		
		private var _scaler:Number;
		public function Player() {
			_boundWidth = this.bounds_clip.width;
			_boundHeight = this.bounds_clip.height;
			_scaler = this.sub_clip.scaleX;
		}

		public override function update():void {
			
			super.update();
			if(Keyboarder.keyIsDown(Keyboard.D) && this._vx < 10 && _status != "dash" && _status != "attack"){
				if(!animationOccupied()) this.sub_clip.scaleX = _scaler;
				if((_adj&Level.SOUTH) == Level.SOUTH) {
					this.push(3,0);
				}
				else {
					if((_adj&Level.EAST) == Level.EAST) { //Attempting to slide on wall
						//trace("SLIDE " + this._wallSlideCounter);
						if(_onWall == 0 && _wallSlideCounter == 0){
							sub_clip.gotoAndStop("wallSlide");
							_jumps = 1;
							_wallSlideCounter = 45;
							_onWall = 1;
							_status = "wallSlide";
							this.sub_clip.scaleX = -_scaler;
						}
					}else{
						_onWall = 0;
					}
					this.push(0.65,0);	
				}
			}if(Keyboarder.keyIsDown(Keyboard.A) && this._vx > -10 && _status != "dash" && _status != "attack"){
				if(!animationOccupied()) this.sub_clip.scaleX = -_scaler;
				if((_adj&Level.SOUTH) == Level.SOUTH) {
					this.push(-3,0);
				}
				else {
					if((_adj&Level.WEST) == Level.WEST) { //Attempting to slide on wall
						if(_onWall == 0 && _wallSlideCounter == 0){
							sub_clip.gotoAndStop("wallSlide");
							_jumps = 1;
							_wallSlideCounter = 45;
							_onWall = -1;
							_status = "wallSlide";
							this.sub_clip.scaleX = _scaler;
						}
					}else{
						_onWall = 0;
					}
					this.push(-0.65,0);	
				}
			}			
			if(_onWall == 0 && _status == "wallSlide") { //Cleanup wall sliding animation
				_status = "idle";
					sub_clip.gotoAndPlay("idle");
			}
			
			if(_onWall != 0){
				_sprintWasPressed = false;
				if(onGround()){
					_status = "idle";
					sub_clip.gotoAndPlay("idle");
					_onWall = 0;
				}else {
					this._vy *= this._airDamp/2;
					if(_wallSlideCounter > 0){
						_wallSlideCounter --;
					}
					
					if(_wallSlideCounter <= 0){
						_wallSlideCounter = -1;
						_status = "idle";
						sub_clip.gotoAndPlay("idle");
						_onWall = 0;
					}
				}
			}else if(_wallSlideCounter != 0 && onGround()){
				_wallSlideCounter = 0;
			}
			//trace("RAWR onWall:" + _onWall + " _wallCounter:" + _wallSlideCounter + " _status:" + _status);
			
			if(!onGround() && _jumps == 0){ //prevents falling then getting 2 air jumps
				_jumps = 1;
			}
						
			if(Keyboarder.keyIsDown(Keyboard.W)){
				if(!_jumpWasPressed || (_jumpCounter > 0 && _jumpCounter < 15)){
					_jumpCounter ++;
					_jumpWasPressed = true;
					
					if(onGround() && _jumpCounter <= 1){ // Jump off ground
						this.push(0,-11);
						_jumps++;
						this._status = "jump";
						sub_clip.gotoAndPlay("jump");
					}else if(_onWall == 1 && _jumpCounter <= 1){
						this.setVel(-12,-6);
						this._status = "jump";
						sub_clip.gotoAndPlay("jump");
					}else if(_onWall == -1 && _jumpCounter <= 1){
						this.setVel(12,-6);
						this._status = "jump";
						sub_clip.gotoAndPlay("jump");
					}else if(!onGround() && _jumpCounter <= 1 && _jumps < _maxJumps){ //Double jump
						_jumps ++;
						this.setVel(VX,-10);
						this._status = "jump";
						sub_clip.gotoAndPlay("jump");
					}else if(_vy < 0) {//Push by holding down jump
						this.push(0,-0.85);
					}
					_wallSlideCounter = 0;
					_onWall = 0;
				}
			}else{
				_jumpWasPressed = false;
				_jumpCounter = 0;
				if(onGround()) _jumps = 0;
			}
			
			if(Keyboarder.keyIsDown(Keyboard.Q) || Keyboarder.keyIsDown(Keyboard.E)){
				if(!this._sprintWasPressed && _sprintCounter <= 0 && _status != "attack"){
					_sprintWasPressed = true;
					_onWall = 0;
					_wallSlideCounter = 0;
					var eDown:Boolean = Keyboarder.keyIsDown(Keyboard.Q);
					var qDown:Boolean = Keyboarder.keyIsDown(Keyboard.E);
					_status = "dash";
					this._ignoreDamp = true;
					this._sprintCounter = 20;
					this._sprintYHold = this.y;
					if(qDown){
						this.setVel(15,0);		
						if(sub_clip.scaleX > 0){
							sub_clip.gotoAndStop("dash");
						}else{
							sub_clip.gotoAndStop("dashBack");
						}
					}else if(eDown){
						this.setVel(-15,0);
						if(sub_clip.scaleX < 0){
							sub_clip.gotoAndStop("dash");
						}else{
							sub_clip.gotoAndStop("dashBack");
						}						
					}
				}
			}else if(_sprintWasPressed && onGround()){
				_sprintWasPressed = false;
			}
			
			if(_sprintCounter > 0){
				_sprintCounter --;
				_vy = 0;
				this.y = this._sprintYHold;
				//this._vx = (_vx > 0 ? 20:-20);
				if(_sprintCounter == 0){
					this._ignoreDamp = false;
					_status = "idle";
					sub_clip.gotoAndPlay("idle");
					this._vx *= 0.4;
				}
			}
			
			
			
			if(Keyboarder.keyIsDown(Keyboard.S) && onGround() && !_dropWasPressed){
				var feet:uint = 0;
				_dropWasPressed = true;
				for(var ix:Number = 0; ix < Width && feet == 0; ix += Width/2){
					feet = _level.checkPoint(x + ix, y + Height + 1);
				}
				
				if(feet == Level.FALLTHROUGH_TILE){
					this.y += 20;
					if(_vy == 0) this.push(0, 5);
				}
			}else if(!Keyboarder.keyIsDown(Keyboard.S)){
				this._dropWasPressed = false;
			}
			
			if(/*Keyboarder.keyIsDown(Keyboard.SPACE)*/ MouseLog.isMouseDown){
				if(!this._attackWasPressed && this._attackCooldown == 0){
					this._attackWasPressed = true;
					this._status = "attack";
					this.sub_clip.gotoAndPlay("attack");
					this._attackCooldown = 30;
					var mx:Number = MouseLog.x - parent.x;
					if(mx > this.x){
						this.sub_clip.scaleX = _scaler;
					}else if(mx < this.x) {
						this.sub_clip.scaleX = -_scaler;
					}
					
					_tonguex = sub_clip.attackMarker_clip.x*sub_clip.scaleX + sub_clip.x;
					_tonguey = sub_clip.attackMarker_clip.y*sub_clip.scaleY + sub_clip.y;
					_tonguer = Math.atan2(MouseLog.y - (this.y+parent.y + _tonguey), MouseLog.x - (this.x+parent.x + _tonguex))*180/Math.PI;//(sub_clip.scaleX < 0) ? -135:-45;
				}
			}else{
				this._attackWasPressed = false;
			}
			if(this._attackCooldown > 0) {
				if(_tongue == null) this._attackCooldown --;
				if(this._status == "attack"){
					var attackRect:Rectangle = this.getAttackRect();
					var hitEnts:Dictionary = _level.findCollidingEntities(attackRect, this);
					for each(var e:Entity in hitEnts){
						_level.destroy(e);
					}
				}
			}
			
			
				

			if(!onGround() && !animationOccupied()){
				if(VY < 0) {
					_status = "rise";
					sub_clip.gotoAndStop("rise");
				}else if(VY > 0){
					_status = "fall";
					sub_clip.gotoAndStop("fall");
				}
			}
			if((!animationOccupied() && _status != "walk") && Math.abs(VX) > 1 && onGround()){
				_status = "walk";
				sub_clip.gotoAndPlay("walk");
			}else if(!animationOccupied() && Math.abs(VX) <= 1 && onGround() && _status != "idle"){
				_status = "idle";
				sub_clip.gotoAndPlay("idle");
			}
			
			if(_tongue != null) {
				_tongue.update();
				/*this.graphics.clear();
				if(_tongue != null && sub_clip.attackMarker_clip != null){ //Can be deleted while in update
					this.graphics.lineStyle(4,0xFF3333);
					this.graphics.moveTo(_tongue._sx, _tongue._sy);
					this.graphics.lineTo(_tongue.x, _tongue.y);
				}*/
			}
			
			this.north_clip.visible = ((this._adj&Level.NORTH) == Level.NORTH);
			this.east_clip.visible = ((this._adj&Level.EAST) == Level.EAST);
			this.west_clip.visible = ((this._adj&Level.WEST) == Level.WEST);
			this.south_clip.visible = ((this._adj&Level.SOUTH) == Level.SOUTH);
		}
		
		public function animationOccupied():Boolean {
			return _status == "attack" || _status == "jump" || _status == "wallSlide" || _status == "dash";
		}
		
		public function getAttackRect(local:Boolean = false):Rectangle{
			var rtn:Rectangle = new Rectangle();
			if(_tongue == null) return rtn;
			
			rtn.width = _tongue.width;
			rtn.height = _tongue.height;
			rtn.x = _tongue.x;
			rtn.y = _tongue.y;
			
			//if(sub_clip.scaleX < 0) rtn.x -= rtn.width;
			
			//rtn.x += sub_clip.x;
			//rtn.y += sub_clip.y;
			
			if(!local){
				rtn.x += this.x;
				rtn.y += this.y;
			}
			
			return rtn;
		}
		
		public function frame_LaunchAttack(){
			var tongue:Tongue = new Tongue(this);
			tongue.x = tongue._sx = _tonguex;//sub_clip.attackMarker_clip.x*sub_clip.scaleX + sub_clip.x;
			tongue.y = tongue._sy = _tonguey;//sub_clip.attackMarker_clip.y*sub_clip.scaleY + sub_clip.y;
			tongue.sub_clip.rotation = _tonguer;//Math.atan2(MouseLog.y - (this.y+parent.y + tongue.x), MouseLog.x - (this.x+parent.x + tongue.y))*180/Math.PI;//(sub_clip.scaleX < 0) ? -135:-45;
			this._tongue = tongue;
			this.addChild(tongue);
		}
		
		public function killTongue():void {
			this.sub_clip.play();
			this.removeChild(_tongue);
			_tongue = null;
		}
		
		public function frame_EndAttack(){
			this._status = "idle";
			//Account for falling and rising
			if(!onGround()){
				if(VY > 0) {
					this._status = "fall";
					sub_clip.gotoAndStop("fall");
				}else if(VY < 0){
					this._status = "rise";
					sub_clip.gotoAndStop("rise");
				}
			}
			else if(Math.abs(VX) > 1 && onGround()){
				_status = "walk";
				sub_clip.gotoAndPlay("walk");
			}else{
				sub_clip.gotoAndPlay("idle");
			}
		}
		
		public function frame_OnRise(){
			this._status = "rise";
		}
		public function frame_OnFall(){
			this._status = "fall";
		}
		
	}
	
}
