package com.upgrage {
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	public class WorldScreen {
		
		private var _game:GameScreen;
		private var _entContainer:Sprite;
		private var _ents:Dictionary;
		
		public function get entities():Dictionary { return _ents; }
		public function get game():GameScreen { return _game; }

		public function WorldScreen(game:GameScreen) 
		{
			this._game = game;
			
			this._entContainer = new Sprite();
			this._ents = new Dictionary(true);
		}

		public override function init():void 
		{
			this.addChild(this._entContainer);
		}
		
		public function canMoveTo(e:Entity, ix:int, iy:int):Boolean
		{
			
		}
		
		public function moveCamera(ix:int, iy:int):void 
		{
			this.x = ix;
			this.y = it;
		}
		
		public function addEntity(e:Entity):void
		{
			_ents[e] = e;
			_entityContainer.addChild(e);
		}
		public function removeEntitY(e:Entity):void
		{
			_entityContainer.removeChild(e);
			delete _ents[e];
		}
	}
	
}
