-- mirai-mod-conf
-- class AddTacticDialog

local class = require "30log"

local AddTacticDialog = class("AddTacticDialog")

AddTacticDialog.IDs = {}


function AddTacticDialog:init(xmlResource)
	self.dialog = nil
	-- TODO: this
end


-- we won't return the class here!
--return AddTacticDialog

-- instead, we return a function 'ShowAddTacticDialog',
-- which opens a modal dialog and returns the new (or modified) tactic as a table
return function ShowAddTacticDialog(xmlResource, tactic)
	-- TODO: this
end
