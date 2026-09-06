# Native sample mod



This serves as a basis for modders coming from modsys, to have some working example code that you can play with.

Copy these files into Mount\&Blade Warband\\Modules\\Native\\lua. Make sure you have updated WSE and start with it.



Lua scripts are loosely grouped into "libraries" at the root level and "modules" in the modules folder. The libraries can be utilized by modules, but do nothing on their own.



Some options in the lua menu (press J) get saved to disk automatically, it will generate a .json in the settings folder.



* The easiest to understand modules are center\_dot, clock and battle\_toys lifesteal. 
* The physics code in battle\_toys is interesting but also math heavy.
* scene\_tools has the fly and fast cam mode, it's the most code but there is nothing crazy complicated. 
* height\_map might be a bit convoluted.

