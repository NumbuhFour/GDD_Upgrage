SYNTAX
triggerID:triggerType:triggerCommand

upon hitting the jetpack trigger, dialog is called
jetpackTrigger:DIALOG:Here, you can have this jetpack. It was my daughter's when she was in Nam."I'll want that back.
Quotation mark is the delimiter for dialogue

on the same trigger, after the dialogue, the jetpack is obtained
jetpackTrigger:UPGRADE:jetpack true

for unlocks, the command specifies the trigger to be unlocked, and the code will lock that trigger when the level is loaded

TRIGGER TYPES
DIALOG
LEVEL_COMPLETE
UPGRADE

when making new levels, label the level symbol in Game "level". also, label the physicsworld symbol "world"

levels.txt specifies which levels to load, and they will be loaded in that order.

_upgrades["max speed"] = 7;
_upgrades["accel speed onground"] = 1.2;
_upgrades["accel speed inair"] = 0.7;
_upgrades["dash speed"] = 20;
_upgrades["jump force"] = 9.2;
_upgrades["mid air jumps"] = 1;
_upgrades["horizontal dampening onground"] = 0.8; //Friction on ground
_upgrades["horizontal dampening inair"] = 0.03; //Friction in air
_upgrades["wall slide duration"] = 20;
_upgrades["dash length"] = 20;
_upgrades["wall jump up percentage"] = 0.7;//When jumping off a wall, jump upwards with a force of x*_upgrades["jump force"]
_upgrades["wall jump out percentage"] = 2; //When jumping off a wall, jump off from the wall with a force of x*_upgrades["accel speed onground"]

_upgrades["jetpack"] = true;
_upgrades["jetpack accel"] = 2.5;
_upgrades["max jetpack speed"] = 7.3;

_upgrades["rockets"] = true;
_upgrades["manhole cover"] = false;
_upgrades["rocket speed"] = 5;

_upgrades["wall jump"] = true;
_upgrades["wall slide"] = true;
_upgrades["jump"] = true;
