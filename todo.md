
## Todo

- [ ] write a simple program in main.lua that loads and displays the main window from the xrc
- [ ] maybe change the wxListBox in the Tactics tab to an excel-like table-thing? (what is the best widget for this?)
- [ ] write an image button test using wxBitmapButtons (for the skills tab)
- [x] add a new Dialog to the Form project? for adding new entries to the tactics list.
- [x] add stuff to Tactics tab in wxFormBuilder project
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

- [ ] add preset-feature, where you can save the current config as a preset and load them easily.

##Notes

- the original Config.lua is in ./data/Config.lua. it will be placed as a string inside the config program
so that it can restore the original settings.

- the Config.lua will be converted to Config_lua.lua (via txt2lua.lua) and 'require'd by the config program.
- the .xrc file will also be converted to 

- for the Extras Tab we will need to enumerate all files in the current directory (to find *_Mod.lua files). Use wxDir for that. 
http://docs.wxwidgets.org/trunk/classwx_dir.html
file:///D:/Dateien/Programming/lua/wxLua/wxLua-2.8.12.3-Lua-5.1.5-MSW-Ansi/doc/wxLua/wxluaref.html#wxDir

- use wxWindow::SetMaxSize for the wxScrolledWindow in tab "Skills", whenever the window size changes and when the window is initialized. So that the long list inside it won't enlarge the window unnecessarily. (the MaxSize is set to a very low value for this reason) (get the size from TAB_GENERAL's main sizer via wxSizer::GetSize)
file:///D:/Dateien/Programming/lua/wxLua/docs/html/wx_wxwindow.html#wxwindowsetmaxsize

- translation files should be lua scripts, maybe? (put them in a subdirectory "lang" or "translation"?)
