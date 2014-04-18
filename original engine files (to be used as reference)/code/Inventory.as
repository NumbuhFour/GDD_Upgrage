package code {
	
	public class Inventory {

		private var _items:Vector.<Collectible> = new Vector.<Collectible>();
		
		public function Inventory() {
			// constructor code
		}
		
		public function show(){
			gotoAndPlay("rollout");
		}
		
		public function get items() { return this._items; }

	}
	
}
