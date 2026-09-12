# Native Demo Mod



This serves as a basis for modders coming from modsys, to have some working example code that you can play with.

Copy these files into Mount\&Blade Warband\\Modules\\Native\\lua. Make sure you have updated WSE and start with it.

* If everything works, you will see "\~ Lua Loaded \~" at game start.
* If you get a ton of "Warning reading file.py, line x: could not process line" then set "\[General] bLuaDisableGameConstWarnings=true" in "Documents\\Mount\&Blade Warband WSE2\\rgl\_config.ini"



Lua scripts are loosely grouped into "libraries" at the root level and "modules" in the modules folder. The libraries can be utilized by modules, but do nothing on their own. Modules add actual gameplay code.



During Battle, press "J" to open and close the mod menu. Some of its options get saved to disk automatically, it will generate a .json in the settings folder. Check out settings.lua.



Code complexity is roughly equal to file size. The physics code in battle\_toys is interesting but also math heavy.

Scene\_tools has the fly and fast cam mode, it's the most code but there is nothing crazy complicated.

height\_map might be a bit convoluted to be fair.



&#x20;

&#x09;

|Hotkeys||
|-|-|
|Ctrl+Shift+O|Hot Reload|



&#x20;



|During Battle||
|-|-|
|J|Open/Close Menu|
|Ctrl+B|Fly Mode|
|Ctrl+B|Fast Cam Mode during Scene Editing<br />(Note: Scene Editing does not work in WSE2. Use WSE1)|
|Mousewheel|Faster or Slower Fly/FastCam|
|E/C|Up or Down Fly/FastCam|
|V|Teleport|
|Ctrl+N|Teleport to next Spawn Point|
|X|Shoot Stone Ball|
|Page Up/Down|Stone Ball speed|
|G|Grappling Hook (10m range)|



&#x20;

|During World Map||
|-|-|
|R|Toggle hourly reminder|



