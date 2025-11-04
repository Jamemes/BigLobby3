-- This function contains a variable `names` which is a table of dummy name strings.
-- Unfortunately the function is massive and that data is hardcoded at the start of
-- the function. Thankfully we might still be able to work around it without breaking
-- other mods such as hud mods which may heavily modify this code.
local function resize(panel, scale)
	for _, item in pairs(panel:children()) do
		local item_type = getmetatable(item).type_name
		if item_type == "Panel" then
			resize(item, scale)
		end

		if item_type == "Text" then
			item:set_font_size(item:font_size() * scale)
		end
	
		item:set_w(item:w() * scale)
		item:set_h(item:h() * scale)
		item:set_y(item:y() * scale)
		item:set_x(item:x() * scale)
	end
end

local max_slots_in_column = 8
local num_player_slots = BigLobbyGlobals:num_player_slots()
-- local scale = 1 - (math.min(max_slots_in_column, num_player_slots - 4) * 0.1)
local orig__HUDTeammate = {
	init = HUDTeammate.init,
	add_special_equipment = HUDTeammate.add_special_equipment,
	set_state = HUDTeammate.set_state
}

if BL2Options then return end
function HUDTeammate:init(i, teammates_panel, is_player, width)
	-- Main difference in this function is based on the `main_player` variable
	-- This refers to the local/client player, so as long as we can make that
	-- true when appropriate and false when not, we should be good. Just need to
	-- fix some settings after the original function finishes and hopefully
	-- everything works as it should.
	local fake_i = 1
	local real_player_panel = HUDManager.PLAYER_PANEL
	if (i == HUDManager.PLAYER_PANEL) then
		fake_i = 4
		HUDManager.PLAYER_PANEL = 4
	end

	orig__HUDTeammate.init(self, fake_i, teammates_panel, is_player, width)
	if not self._scale then
		self._scale = (teammates_panel:w() - 204) / (self._panel:w() * math.min(max_slots_in_column + 1, num_player_slots))
		self._gap = 20 * self._scale
	end
	
	-- Fix some properties to align with the real i value.
	self._id = i
	self._panel:set_name("" .. i)
	self._panel:child("callsign"):set_color(tweak_data.chat_colors[i]:with_alpha(1))
	HUDManager.PLAYER_PANEL = real_player_panel

	if i ~= HUDManager.PLAYER_PANEL then
		resize(self._panel, self._scale)
		self._panel:set_w(self._panel:w() * self._scale)
		self._panel:set_h(self._panel:h() * self._scale)
	end
end

function HUDTeammate:add_special_equipment(data)
	orig__HUDTeammate.add_special_equipment(self, data)
	
	if not self._main_player then
		resize(self._panel:child(data.id), self._scale)

		local item = self._panel:child(data.id)
		item:set_w(item:w() * self._scale)
		item:set_h(item:h() * self._scale)
		self._special_equipment[#self._special_equipment] = item

		self:layout_special_equipments()
	end
end

function HUDTeammate:set_state(state)
	if state == "player" then
		return
	end
	
	orig__HUDTeammate.set_state(self, state)
end