
## Todo


- [x] disable debug and strict mode before release
- [x] update version number before release
- [x] add a LICENSE.txt

- [ ] implement preset-feature, where you can save the current config as a preset and load them easily.
- [ ] write readme.md

- [x] add ctrl+S hotkey to save settings (how? use accelerator-tables or something?)
- [x] clean up todo.md
- [x] add 'TranslationLoader.lua' and 'config/lang/english.lua' to squishy and makefile!
- [x] finish 'LanguageTab.lua' (look up event id for selecting an element in a listCtrl!)
- [x] run unit tests again after adding translation feature to everything else
- [x] capitalize language file names
- [x] add 'GetFilesEndingWith.lua' to squishy and makefile.
- [x] move helper function 'GetFilesEndingWith' from 'ModTab.lua' into its own file, because we will also need that function in 'LanguageTab.lua'
- [x] translate the line "Please choose the minimum amount of SP for each skill [...]" in file 'SkillsTab.lua' at line 41. (but do it in the 'ApplyTranslation' method in MainWindow.lua) (the wxStaticText is called 'widgets.TXT_SkillsDescription') (line 48)
- [x] translate the remaining tabs in MainWindow.lua
- [x] implement translation feature in the rest of the source files

- [x] implement translation (load it using the loader module, finish LanguageTab.lua, use '_T()' calls, write translation files (english and german).
- [x] write translation loader module
- [x] there seems to be a bug with an invalid choice in the skills tab when 'Config.lua' does not exist!
- [x] test OLD_HOMUN_TYPE and DEFAULT_BEHA saving and loading again
- [x] add 'OLD_HOMUN_TYPE' variable to MainWindow save and load functions
- [x] replace hidden checkBox "CB_CanDetectNoPot" with OldHomunType wxChoice
- [x] ask before quitting
- [x] remove the checkBox "CB_CanDetectNoPot" later, since it seems to be specific to "AutoAidPotion", which we don't support. (but check the mirai-mod source first, to make sure that it really is specific to AAP!!) -> yes. it really is only used with AAP! -> replace it with OldHomunType later!

- [x] set wxStaticText 'TXT_Version' to the version number
- [x] delete the "*_Mod.lua" files later! (before merging into master) they are just for testing.
- [x] finish writing "ModTab.lua" (NEXT: M.LoadMod)
- [x] fix memory leak with wxDialog::Destroy()?
- [x] write support for Tab 'Mod' (+ load and save support)

- [x] in save function: write the selected mod to file 'SelectedMod.lua'
- [x] in load function: read 'SelectedMod.lua' and return the selected mod as a string (as third return value in M.LoadConfigOptions?) -> write additional function 'LoadSelectedMod'

- [x] write function "ListCtrlHelper.SelectRow(listCtrl, pos)": selects the item at index 'pos'
- [x] finish writing 'TacticsTab.lua'
- [x] write support for tab 'Tactics' (+ read and save support)
- [x] write widths in TacticsTab.lua, line 64
- [x] update makefile and squishy with new files "TacticsTab.lua" and "ListCtrlHelper.lua"
- [x] create new file 'TacticsTab.lua' and add all functionality related to tab 'Tactics' there.
- [x] wire up the buttons in tab tactics
- [x] finish the config-writer function
- [x] finish the config-reader function
- [x] finish writing function M.LoadSkills in SkillsTab.lua
- [x] uncomment call to 'SkillsTab.SaveSkills' in function 'MainWindow:SaveConfig' (line 286)
- [x] test loading and saving of all options in tab 'General'
- [x] checkbox "cautious" / "CB_Cautious" isn't saved/loaded...
- [x] function M.SaveSkills from SkillsTab.lua
- [x] why does the wxScrolledWindow not get a scrollbar? (it is more than full, and cannot be scrolled.) (try wxScrolledWindow::EnableScrolling) (see sample: 'picker.wx.lua') -> fixed using method FitInside of the sizer contained in the wxScrolledWindow!
- [x] plan the skills table format (in MainWindow.lua: function FillSkillsTab)
- [x] skills-table stuff
- [x] move skills table stuff into its own source file...
- [x] remove ./data/Config.lua from project, as well as the GEN_FILES generation rules, ./tools/txt2lua.lua etc. since we don't need it.
- [x] Makefile: copy dir 'config/' into build directory when building.
- [x] Makefile: update 'release' rule. put the 'config/' dir into the release archives
- [x] move every external file into folder "config/", including the .xrc, images and translations.
- [x] write unit tests for M.GetTact()
- [x] write a file interface emulator module (using 30log). it should create objects that behave like file handles for text files. the constructor should take a string containing one or more lines as argument. (we need this for unit-testing function M.LoadConfigOptions)
- [x] write unit tests for M.LoadConfigOptions() (we will need the file interface emulator module described above)

- [x] add error handlers to all functions that call functions containing 'assert' or 'error'.
- [x] finish LoadConfigOptions.lua
- [x] add unit tests which test quotes to test_LoadConfigOptions.lua (and implement support for quotes in LoadConfigOptions.StripComments!)
- [x] finish unittest module for LoadConfigOptions.lua
- [x] Makefile: add 'test' rule to makefile, to run unittests
- [x] start writing config-loader function
- [x] start writing config-writer function
- [x] test filling the TAB_Skills programmatically (in new branch) (we will need to remove the contents of BSIZER_Skills, so make a branch before this, so that we can keep it as a reference later)

- [x] keep the slider and the spinCtrl for "AttackWhenHP" in sync
- [x] keep the slider and the spinCtrl for "EvadeWhenHP" in sync
- [x] link the two sliders "SL_AttackWhenHP" and "SL_EvadeWhenHP" (while keeping spinCtrls in sync!)
- [x] link the two pairs of slider and SpinCtrl "AttackWhenHP" and "EvadeWhenHP" (according to "ControlPanelConfigOptions.md" line 28!)

- [x] hide the tab Language for now. (until translation functionality is implemented)
- [x] AddTacticDialog: treat "Monster Names" starting with "--" as comment.
- [x] AddTacticDialog: forbid "-- End Tact" as monster name. (this would confuse the reader function because it is the marker that tells it that the Tact List ends there)


- [x] copy stringutil.lua into project directory when it is finished and tested. (is it?)

- [x] name the widgets from AddTacticDialog.
- [x] give names to all of the required widgets in the .fbp
- [x] in wxListCtrl: should we use style 'wxLC_NO_SORT_HEADER'? -> yes
- [x] maybe change the wxListBox in the Tactics tab to an excel-like table-thing? (what is the best widget for this?) (maybe wxListCtrl?) (see sample controls.wx.lua) -> wxListCtrl
- [x] write a test program for the table thing mentioned in the line below. (wxListCtrl?)
- [x] replace the wxBitmapButtons in TAB_SKILLS with wxStaticBitmaps?
- [x] write an image button test using wxBitmapButtons (for the skills tab)
- [x] write a simple program in main.lua that loads and displays the main window from the xrc
- [x] add a new Dialog to the Form project? for adding new entries to the tactics list.
- [x] add stuff to Tactics tab in wxFormBuilder project
- [x] add rules for archive files to the makefile
- [x] add 'build', 'release', 'gen' and '_temp' directories to .gitignore
- [x] put a .gitignore in the project directory.
- [x] finish Makefile.mingw (use ./tools/txt2lua.lua for converting the .xrc and Config.lua)
- [x] put a dummy program into main lua to test the makefile.
- [x] build a GUI with wxFormBuilder and generate an xrc file.



##Notes

- add function to get exe directory? (like AppDir in BlitzMax) (see sample: calculator.wx.lua) -> http://stackoverflow.com/questions/25819812/wxwidgets-getting-application-path

- for the Tabs "Mod" and "Language" we will need to enumerate all files in the current directory (to find *_Mod.lua files). Use wxDir for that. 
http://docs.wxwidgets.org/trunk/classwx_dir.html
file:///D:/Dateien/Programming/lua/wxLua/wxLua-2.8.12.3-Lua-5.1.5-MSW-Ansi/doc/wxLua/wxluaref.html#wxDir

- use wxWindow::SetMaxSize for the wxScrolledWindow in tab "Skills", whenever the window size changes and when the window is initialized. So that the long list inside it won't enlarge the window unnecessarily. (the MaxSize is set to a very low value for this reason) (get the size from TAB_GENERAL's main sizer via wxSizer::GetSize)
file:///D:/Dateien/Programming/lua/wxLua/docs/html/wx_wxwindow.html#wxwindowsetmaxsize

- write a new runtime exe later? (in C or C++)
