-- Modified to support displaying additional peers loadouts.
-- TODO: This becomes undesirable the larger the player count and requires a reworked UI.

local max_slots_in_column = 8
local num_player_slots = BigLobbyGlobals:num_player_slots()
local column = math.ceil(num_player_slots / max_slots_in_column)
function TeamLoadoutItem:init(panel, text, i)
	-- Only code changed was replacing two hardcoded values of 4 with the variable num_player_slots
	TeamLoadoutItem.super.init(self, panel, text, i)
	self._player_slots = {}
	local quarter_width = self._panel:w() / math.min(max_slots_in_column, num_player_slots)
	
	local x = 0
	local y = 0
	local slot_panel
	for i = 1, num_player_slots do
		local slot_height = self._panel:h() / column
		slot_panel = self._panel:panel({
			x = x,
			y = y,
			w = quarter_width,
			h = slot_height,
			valign = "grow"
		})
		
		if x + slot_panel:w() < self._panel:w() then
			x = x + slot_panel:w()
		else
			y = y + slot_height
			x = 0
		end

		self._player_slots[i] = {}
		self._player_slots[i].panel = slot_panel
		self._player_slots[i].outfit = {}
		local kit_menu = managers.menu:get_menu("kit_menu")
		if kit_menu then
			local kit_slot = kit_menu.renderer:get_player_slot_by_peer_id(i)
			if kit_slot then
				local outfit = kit_slot.outfit
				local character = kit_slot.params and kit_slot.params.character
				if outfit and character then
					self:set_slot_outfit(i, character, outfit)
					local heister_name = self._player_slots[i].panel:child(0)
					local padding_scaled = math.min(8, num_player_slots)
					heister_name:set_font_size(heister_name:font_size() - (padding_scaled))
					heister_name:set_lefttop(heister_name:left() - padding_scaled, heister_name:top() - padding_scaled)
				end
			end
		end
	end
end

-- Modified to support additional players. Seems to just reduce font size when needed?
function TeamLoadoutItem:reduce_to_small_font(iteration)
	TeamLoadoutItem.super.reduce_to_small_font(self, iteration)

	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	TeamLoadoutItem.super.reduce_to_small_font(self)
	for i = 1, num_player_slots do
		if self._player_slots and self._player_slots[i].box then
			self._player_slots[i].box:create_sides(self._player_slots[i].panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end
	end
end
