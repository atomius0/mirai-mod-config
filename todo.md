
## Todo

- [ ] name the widgets from TAB_Skills, TAB_Mod, TAB_Language and AddTacticDialog.
- [ ] give names to all of the required widgets in the .fbp (WIP, see above)
- [x] in wxListCtrl: should we use style 'wxLC_NO_SORT_HEADER'? -> yes
- [x] maybe change the wxListBox in the Tactics tab to an excel-like table-thing? (what is the best widget for this?) (maybe wxListCtrl?) (see sample controls.wx.lua) -> wxListCtrl
- [ ] write a library for reading/writing Config.lua (original Config.lua is in ./data/Config.lua)
- [ ] copy stringutil.lua into project directory when it is finished and tested. (is it?)
- [x] write a test program for the table thing mentioned in the line below. (wxListCtrl?)
- [x] replace the wxBitmapButtons in TAB_SKILLS with wxStaticBitmaps?
- [x] write an image button test using wxBitmapButtons (for the skills tab)
- [x] write a simple program in main.lua that loads and displays the main window from the xrc
- [x] add a new Dialog to the Form project? for adding new entries to the tactics list.
- [x] add stuff to Tactics tab in wxFormBuilder project
- [x] add rules for archive files to the makefile
- [ ] should the config.xrc file really be included inside the config.exe file? it makes updates more difficult (what if a user has an older version of the config.xrc after updating the config.exe?) -> no. we will put every external file into a folder 'config/'
- [x] add 'build', 'release', 'gen' and '_temp' directories to .gitignore
- [x] put a .gitignore in the project directory.
- [x] finish Makefile.mingw (use ./tools/txt2lua.lua for converting the .xrc and Config.lua)
- [x] put a dummy program into main lua to test the makefile.
- [x] build a GUI with wxFormBuilder and generate an xrc file. (place the xrc file inside ./data/)
- [ ] write readme.md
- [ ] add a LICENSE.txt

- [ ] add function to get exe directory (like AppDir in BlitzMax) (see sample: calculator.wx.lua)
- [ ] write translation loader module
- [ ] implement preset-feature, where you can save the current config as a preset and load them easily.

##Notes

- fill the skills tab in code?

- the original Config.lua is in ./data/Config.lua. it will be placed as a string inside the config program
so that it can restore the original settings. (used when no Config.lua is found)

- the Config.lua will be converted to Config_lua.lua (via txt2lua.lua) and 'require'd by the config program.

- for the Tabs "Mod" and "Language" we will need to enumerate all files in the current directory (to find *_Mod.lua files). Use wxDir for that. 
http://docs.wxwidgets.org/trunk/classwx_dir.html
file:///D:/Dateien/Programming/lua/wxLua/wxLua-2.8.12.3-Lua-5.1.5-MSW-Ansi/doc/wxLua/wxluaref.html#wxDir

- use wxWindow::SetMaxSize for the wxScrolledWindow in tab "Skills", whenever the window size changes and when the window is initialized. So that the long list inside it won't enlarge the window unnecessarily. (the MaxSize is set to a very low value for this reason) (get the size from TAB_GENERAL's main sizer via wxSizer::GetSize)
file:///D:/Dateien/Programming/lua/wxLua/docs/html/wx_wxwindow.html#wxwindowsetmaxsize

- translation files should be lua scripts, maybe? (put them in a subdirectory "lang" or "translation"?)

- maybe move the .xrc file (and all other additional files needed by config.exe) to a subdirectory: "config"

- use wxDialog:ShowModal for the AddTacticDialog

- write a new runtime exe later? (in C or C++)
