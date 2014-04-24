package com.upgrage {
	
	import flash.net.*;
	import flash.events.*
	import flash.errors.IOError;
	
	public class ScriptParser {

		private static var _parser:ScriptParser = new ScriptParser();
		private var _scripts:Vector.<Vector.<ScriptEvent>>;
		private var _levels:Array = new Array();
		private var _PATH:String = "src/com/upgrage/scripting/";
		private var _loader:URLLoader;
		private var loadCounter:int;
		private var _currLevel:uint;
		
		public function ScriptParser() {
			if (_parser) throw new Error("Instance of ScriptParser already exists.");
		}
		
		public function loadScripts(path:String){
			_currLevel = 0;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,onLoadScripts,false,0,true);
			
			var request:URLRequest = new URLRequest(_PATH + path);
			loader.load(request);
			trace("loading");
		}

		//parses data from file
		private function onLoadScripts(e:Event){
			_scripts = new Vector.<Vector.<ScriptEvent>>();
			//trace("data: \n" + e.target.data);
			var str:String = e.target.data;
			trace("Dont be a bitch compy " + str);
			//str = str.replace("\n", "");
			_levels = str.split("\n")
			trace("start" + _levels + "end");
			loadCounter = 0;
			loadScript(_levels[loadCounter++]);			
		}
		
		private function loadScript(path:String){
			trace("PEINS");
			_loader = new URLLoader();
			trace("CANS");
			_loader.addEventListener(Event.COMPLETE,onLoadScript);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			path = path.substring(0, path.lastIndexOf("t")+1);			
			var request:URLRequest = new URLRequest(_PATH + path);
			
			_loader.load(request);
		}
		
		private function onLoadScript(e:Event){
			//var arr:Array = e.target.data.split("\n");
			var allScripts:Array = e.target.data.split("\n");
			var vector:Vector.<ScriptEvent>
			for each(var script:String in allScripts){
				vector.push(new ScriptEvent(script.substr(0, script.length-3)))
			}
			_scripts.push(script);
			trace(e.target.data);
			if (_loader != null)
			{
				try
				{
					_loader.close();
				}
				catch (e:Error)
				{
				}
				_loader.removeEventListener(Event.COMPLETE, onLoadScript);
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_loader = null;
			}
			if (loadCounter < _levels.length)
				loadScript(_levels[loadCounter++]);
		}
		
		private function onIOError(e:IOErrorEvent){
			trace(e.text);
		}
		
		public function loadNewLevel(){
			return _scripts[_currLevel++];
		}
		
		public static function get parser():ScriptParser { return _parser; }
		public function get scripts():Vector.<Vector.<ScriptEvent>> { return _scripts; }
		public function get CurrLevel():uint { return _currLevel; }
		public function set CurrLevel(val:uint) { _currLevel = val; }

	}
	
}
