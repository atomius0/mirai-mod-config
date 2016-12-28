
## Todo

- [ ] copy stringutil.lua into project directory when it is finished and tested. (is it?)
- [ ] put a .gitignore in the project directory.
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

