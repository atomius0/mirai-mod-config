
## Todo

- [ ] add rules for archive files to the makefile
- [ ] should the config.xrc file really be included inside the config.exe file? it makes updates more difficult (what if a user has an older version of the config.xrc after updating the config.exe?)
- [ ] add 'build', 'release', 'gen' and '_temp' directories to .gitignore
- [ ] copy stringutil.lua into project directory when it is finished and tested. (is it?)
- [x] put a .gitignore in the project directory.
- [ ] finish Makefile.mingw (use ./tools/txt2lua.lua for converting the .xrc and Config.lua)
- [ ] put a dummy program into main lua to test the makefile.
- [ ] write a library for reading/writing Config.lua (original Config.lua is in ./data/Config.lua)
- [ ] build a GUI with wxFormBuilder and generate an xrc file. (place the xrc file inside ./data/)
- [ ] write readme.md
- [ ] add a LICENSE.txt

##Notes

- the original Config.lua is in ./data/Config.lua. it will be placed as a string inside the config program
so that it can restore the original settings.

- the Config.lua will be converted to Config_lua.lua (via txt2lua.lua) and 'require'd by the config program.
- the .xrc file will also be converted to 

- for the Extras Tab we will need to enumerate all files in the current directory (to find *_Mod.lua files). Use wxDir for that. 
http://docs.wxwidgets.org/trunk/classwx_dir.html
file:///D:/Dateien/Programming/lua/wxLua/wxLua-2.8.12.3-Lua-5.1.5-MSW-Ansi/doc/wxLua/wxluaref.html#wxDir

- Should the "Mod" and "Translation" selectors really both be in the "Extra" tab? It might be better to split them into separate tabs.

