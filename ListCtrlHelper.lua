-- ListCtrlHelper
-- helper functions for wxListCtrl

--require "wx"

local M = {}

-- InitColumns(listCtrl, t_cols)
-- listCtrl is a reference to the wxListCtrl
-- t_cols is either: a table containing column names as strings
--               or: a table containing tables in the form of:
--                   {"name", width}
--                   where width is optional.
function M.InitColumns(listCtrl, t_cols)
	assert(listCtrl)
	assert(type(t_cols) == "table")
	
	local col = wx.wxListItem()
	
	for i, v in ipairs(t_cols) do
		col:SetId(i-1) -- -1 because lua indices are 1 based, and wx indices are 0 based.
		
		if type(v) == "table" then
			assert(type(v[1]) == "string")
			col:SetText(v[1])
			if v[2] then col:SetWidth(v[2]) end
			
		elseif type(v) == "string" then
			col:SetText(v)
			
		else -- column is neither table nor string:
			error("column must be either a table or a string!")
		end
		
		listCtrl:InsertColumn(i-1, col)
	end
end

-- InsertRow(listCtrl, [pos,] t_row)
-- inserts a single row 't_row' at 'pos' (pos is zero based!)
-- returns: the index of the newly inserted item
-- 'pos' can be omitted, eg: InsertRow(listCtrl, t_row)
-- if 'pos' is omitted, the row will be added to the end of the listCtrl.
function M.InsertRow(listCtrl, pos, t_row)
	assert(listCtrl)
	
	-- if the third parameter (t_row) is omitted,
	-- we assume that the user actually omitted the second parameter (pos).
	if not t_row then
		-- so we set t_row to the value of the second parameter
		t_row = pos
		-- and we set pos to point to the end of the listCtrl.
		pos = listCtrl:GetItemCount()
	end
	assert(type(t_row) == "table")
	
	
	local item = wx.wxListItem()
	item:SetId(pos)
	local r = listCtrl:InsertItem(item)
	
	-- set the contents of the row
	for col, v in ipairs(t_row) do
		listCtrl:SetItem(pos, col-1, v)
	end
	
	return r
end


-- InsertRows(listCtrl, [start_pos,] t_rows)
-- inserts multiple rows from table 't_rows' starting at position 'start_pos'
-- returns two numbers: the index of the first newly inserted item
--                      and the index of the last newly inserted item.
-- t_rows is a table containing a table for each row.
-- eg: { {"row0_col0", "row0_col1"}, {"row1_col0", "row1_col1"}, ... }
-- 'start_pos' can be omitted, eg: InsertRows(listCtrl, t_rows)
-- if 'start_pos' is omitted, the rows will be added to the end of the listCtrl.
function M.InsertRows(listCtrl, start_pos, t_rows)
	assert(listCtrl)
	
	-- if the third parameter (t_rows) is omitted,
	-- we assume that the user actually omitted the second parameter (start_pos).
	if not t_rows then
		-- so we set t_rows to the value of the second parameter
		t_rows = start_pos
		-- and we set start_pos to point to the end of the listCtrl.
		start_pos = listCtrl:GetItemCount()
	end
	assert(type(t_rows) == "table")
	
	
	local item = wx.wxListItem()
	local r_first, r_last = nil, nil
	
	for i, t_row in ipairs(t_rows) do
		item:SetId(start_pos + i-1)
		r_last = listCtrl:InsertItem(item)
		if r_first == nil then r_first = r_last end
		
		-- set the contents of the row
		for col, v in ipairs(t_row) do
			listCtrl:SetItem(start_pos + i-1, col-1, v)
		end
	end
	
	return r_first, r_last
end

-- DeleteRow(listCtrl, pos)
-- deletes the row at position 'pos'
function M.DeleteRow(listCtrl, pos)
	assert(listCtrl)
	-- just a simple wrapper for wxListCtrl:DeleteItem()
	return listCtrl:DeleteItem(pos)
end


-- DeleteAllRows(listCtrl)
-- deletes all rows in the listCtrl (but not the columns!)
function M.DeleteAllRows(listCtrl)
	assert(listCtrl)
	-- just a simple wrapper for wxListCtrl:DeleteAllItems()
	return listCtrl:DeleteAllItems()
end


-- ReadRow(listCtrl, pos)
-- returns a table containing the row at position 'pos'
function M.ReadRow(listCtrl, pos)
	assert(listCtrl)
	
	local item = wx.wxListItem()
	item:SetId(pos)
	item:SetMask(wx.wxLIST_MASK_TEXT)
	
	local row = {}
	for i = 1, listCtrl:GetColumnCount() do
		item:SetColumn(i-1) -- -1 because the loop index is 1 based, but SetColumn is 0 based.
		listCtrl:GetItem(item)
		row[i] = item:GetText()
	end
	
	return row
end


-- ReplaceRow(listCtrl, pos, t_row)
-- sets the content of the row at 'pos' to 't_row'
function M.ReplaceRow(listCtrl, pos, t_row)
	assert(listCtrl)
	assert(type(t_row) == "table")
	
	-- set the contents of the row
	for col, v in ipairs(t_row) do
		listCtrl:SetItem(pos, col-1, v)
	end
end


-- GetSelected(listCtrl)
-- returns a table containing the indices of the currently selected rows
-- (or an empty table, if no row is selected)
function M.GetSelected(listCtrl)
	assert(listCtrl)
	
	local item = -1
	local selected = {}
	
	repeat
		item = listCtrl:GetNextItem(item, wx.wxLIST_NEXT_ALL, wx.wxLIST_STATE_SELECTED)
		if item ~= -1 then table.insert(selected, item) end
	until item == -1
	
	return selected
end


-- GetFirstSelected(listCtrl)
-- returns the index of the first row (or nil, if no row is selected)
function M.GetFirstSelected(listCtrl)
	assert(listCtrl)
	
	local r = listCtrl:GetNextItem(-1, wx.wxLIST_NEXT_ALL, wx.wxLIST_STATE_SELECTED)
	if r == -1 then return nil end
	return r
end


-- SwapRows(listCtrl, pos1, pos2)
-- swaps the rows at 'pos1' and 'pos2'
function M.SwapRows(listCtrl, pos1, pos2)
	assert(listCtrl)
	
	-- get rows 1 and 2
	local row1 = M.ReadRow(listCtrl, pos1)
	local row2 = M.ReadRow(listCtrl, pos2)
	
	M.ReplaceRow(listCtrl, pos1, row2)
	M.ReplaceRow(listCtrl, pos2, row1)
end


return M
