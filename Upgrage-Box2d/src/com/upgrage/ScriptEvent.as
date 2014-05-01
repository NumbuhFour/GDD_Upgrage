package com.upgrage {

	public class ScriptEvent {

		private var _triggerID:String;
		private var _scriptType:String;
		private var _command:String;

		public function ScriptEvent(data:String) {
			_triggerID = data.substring(0, data.indexOf(":"));
			_scriptType = data.substring(data.indexOf(":") + 1, data.lastIndexOf(":")); 
			_command = data.substring(data.lastIndexOf(":") + 1, data.length);
			trace("TriggerID: " + _triggerID + "\tType: " + _scriptType + "\tCommand: " + _command);
		}
		
		public function get TriggerID():String { return _triggerID; }
		public function get ScriptType():String { return _scriptType; }
		public function get Command():String { return _command; }

	}
	
}
