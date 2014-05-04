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