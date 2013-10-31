--[[

	Copyright (c) 2013 Bastien Clément

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local UnitGUID, SendChatMessage, GetMapInfo = UnitGUID, SendChatMessage, GetMapInfo

local frame = CreateFrame("Frame",  nil, UIParent)

local function check_mob(unit)
	local GUID = UnitGUID(unit)
	if not GUID then
		return false
	else
		return (GUID:sub(-13, -9) == "115F5")
	end
end

local tracking = false
local function update_tracking()
	local should_track = (GetMapInfo() == "OrgrimmarRaid") and (check_mob("boss1") or check_mob("boss2") or check_mob("boss3") or check_mob("boss4"))
	
	if should_track ~= tracking then
		if tracking then
			frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		tracking = should_track
	end
end

local TOXIN_BLUE   = GetSpellInfo(142532)
local TOXIN_RED    = GetSpellInfo(142533)
local TOXIN_YELLOW = GetSpellInfo(142534)

local matches = {
	[TOXIN_BLUE] = {
		[142725] = true, -- Blue
		[142729] = true, -- Purple
		[142730] = true  -- Green
	},
	
	[TOXIN_RED] = {
		[142726] = true, -- Red
		[142729] = true, -- Purple
		[142728] = true  -- Orange
	},
	
	[TOXIN_YELLOW] = {
		[142727] = true, -- Yellow
		[142730] = true, -- Green
		[142728] = true  -- Orange
	}
}

local catalysts = {
	[142725] = "{rt6} Catalyst BLUE on ME",   -- Blue
	[142726] = "{rt7} Catalyst RED on ME",    -- Red
	[142727] = "{rt1} Catalyst YELLOW on ME", -- Yellow
	[142728] = "{rt2} Catalyst ORANGE on ME", -- Orange
	[142729] = "{rt3} Catalyst PURPLE on ME", -- Purple
	[142730] = "{rt4} Catalyst GREEN on ME"   -- Green
}

function frame:OnEvent(ev, _, event, _, _, _, _, _, _, _, _, _, spellID, _, _, _, _)
--                         1    2    3  4  5  6  7  8  9 10 11    12    13 14 15 16
	if ev == "COMBAT_LOG_EVENT_UNFILTERED" and event == "SPELL_CAST_START" and catalysts[spellID] then
		local myDebuff = UnitDebuff("player", TOXIN_BLUE) or UnitDebuff("player", TOXIN_RED) or UnitDebuff("player", TOXIN_YELLOW)
		if myDebuff and matches[myDebuff][spellID] then
			SendChatMessage(catalysts[spellID], "YELL")
		end
	else
		-- ZONE_CHANGED / ZONE_CHANGED_INDOORS / ZONE_CHANGED_NEW_AREA / INSTANCE_ENCOUNTER_ENGAGE_UNIT
		update_tracking()
	end
end

frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_INDOORS")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")

update_tracking()

frame:SetScript("OnEvent", frame.OnEvent)
