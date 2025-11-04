-- Instead of overriding methods, I am now hooking them and continuiing the loop
-- to handle >4 peers.

local max_slots_in_column = 8
local num_player_slots = BigLobbyGlobals:num_player_slots()
local column = math.ceil(num_player_slots / max_slots_in_column)
local scale = math.min(max_slots_in_column, num_player_slots) / (tweak_data.menu.pd2_small_font_size - 3) * 4
local text_font = tweak_data.menu.pd2_small_font
local text_font_size = tweak_data.menu.pd2_small_font_size / scale
local orig__HUDMissionBriefing = {
	init = HUDMissionBriefing.init,
	set_player_slot = HUDMissionBriefing.set_player_slot,
	set_slot_joining = HUDMissionBriefing.set_slot_joining,
	set_slot_ready = HUDMissionBriefing.set_slot_ready,
	set_slot_not_ready = HUDMissionBriefing.set_slot_not_ready,
	set_dropin_progress = HUDMissionBriefing.set_dropin_progress,
	remove_player_slot_by_peer_id = HUDMissionBriefing.remove_player_slot_by_peer_id
}

function HUDMissionBriefing:init(...)
	orig__HUDMissionBriefing.init(self, ...)

	-- Adjust height of panel to accomodate for the amount of player slots
	self._ready_slot_panel:clear()

	-- Adds player slot panels for peers >4
	if not self._singleplayer then
		local row = 0
		local current_column = 1
		local voice_icon, voice_texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_talk")
		local infamy_icon, infamy_rect = tweak_data.hud_icons:get_icon_data("infamy_icon")
		for i = 1, num_player_slots do
			if max_slots_in_column > row then
				row = row + 1
			else
				row = 1
				current_column = current_column + 1
			end
	
	-- Original Code --
			local color_id = i
			local color = tweak_data.chat_colors[color_id]
			local slot_width = (self._ready_slot_panel:w() - 20) / column
			local slot_panel = self._ready_slot_panel:panel({
				name = "slot_" .. tostring(i),
				h = text_font_size,
				y = (row - 1) * text_font_size + 10,
				x = (slot_width * (current_column - 1)) + 10,
				w = slot_width
			})
			local criminal = slot_panel:text({
				name = "criminal",
				font_size = text_font_size,
				font = text_font,
				color = color,
				text = "HOXTON",
				blend_mode = "add",
				align = "left",
				vertical = "center"
			})
			local voice = slot_panel:bitmap({
				name = "voice",
				texture = voice_icon,
				visible = false,
				layer = 2,
				texture_rect = voice_texture_rect,
				w = voice_texture_rect[3],
				h = voice_texture_rect[4],
				color = color,
				x = 10
			})
			local name = slot_panel:text({
				name = "name",
				text = managers.localization:text("menu_lobby_player_slot_available") .. "  ",
				font = text_font,
				font_size = text_font_size,
				color = color:with_alpha(0.5),
				align = "left",
				vertical = "center",
				w = 256,
				h = text_font_size,
				layer = 1,
				blend_mode = "add"
			})
			local status = slot_panel:text({
				name = "status",
				visible = false,
				text = "  ",
				font = text_font,
				font_size = text_font_size,
				align = "right",
				vertical = "center",
				w = 256,
				h = text_font_size,
				layer = 1,
				blend_mode = "add",
				color = tweak_data.screen_colors.text:with_alpha(0.5)
			})
			local infamy = slot_panel:bitmap({
				name = "infamy",
				texture = infamy_icon,
				texture_rect = infamy_rect,
				visible = false,
				layer = 2,
				color = color,
				y = 1,
			})
			infamy:set_size(infamy:h() / scale, infamy:w() / scale)
			local detection = slot_panel:panel({
				name = "detection",
				layer = 2,
				visible = false,
				w = slot_panel:h(),
				h = slot_panel:h()
			})
			local detection_ring_left_bg = detection:bitmap({
				name = "detection_left_bg",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				alpha = 0.2,
				blend_mode = "add",
				w = detection:w(),
				h = detection:h()
			})
			local detection_ring_right_bg = detection:bitmap({
				name = "detection_right_bg",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				alpha = 0.2,
				blend_mode = "add",
				w = detection:w(),
				h = detection:h()
			})
			detection_ring_right_bg:set_texture_rect(detection_ring_right_bg:texture_width(), 0, -detection_ring_right_bg:texture_width(), detection_ring_right_bg:texture_height())
			local detection_ring_left = detection:bitmap({
				name = "detection_left",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				render_template = "VertexColorTexturedRadial",
				blend_mode = "add",
				layer = 1,
				w = detection:w(),
				h = detection:h()
			})
			local detection_ring_right = detection:bitmap({
				name = "detection_right",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				render_template = "VertexColorTexturedRadial",
				blend_mode = "add",
				layer = 1,
				w = detection:w(),
				h = detection:h()
			})
			detection_ring_right:set_texture_rect(detection_ring_right:texture_width(), 0, -detection_ring_right:texture_width(), detection_ring_right:texture_height())
			local detection_value = slot_panel:text({
				name = "detection_value",
				font_size = text_font_size,
				font = text_font,
				color = color,
				text = " ",
				blend_mode = "add",
				align = "left",
				vertical = "center"
			})
			detection:set_left(slot_panel:w() * 0.65)
			detection_value:set_left(detection:right() + 2)
			detection_value:set_visible(detection:visible())
			local _, _, w, _ = criminal:text_rect()
			voice:set_left(w + 2)
			criminal:set_w(w)
			criminal:set_align("right")
			criminal:set_text("")
			name:set_left(voice:right() + 2)
			status:set_right(slot_panel:w())
			infamy:set_left(name:x())
		end
		BoxGuiObject:new(self._ready_slot_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end
	-- End Original Code --
end

local function change_status_size(panel, peer_id)
	local slot = panel:child("slot_" .. tostring(peer_id))
	if slot and alive(slot) then
		slot:child("status"):set_font_size(text_font_size)
	end
end

function HUDMissionBriefing:set_player_slot(nr, params)
	orig__HUDMissionBriefing.set_player_slot(self, nr, params)
	change_status_size(self._ready_slot_panel, nr)
end

function HUDMissionBriefing:set_slot_joining(peer, peer_id)
	orig__HUDMissionBriefing.set_slot_joining(self, peer, peer_id)
	change_status_size(self._ready_slot_panel, peer_id)
end

function HUDMissionBriefing:set_slot_ready(peer, peer_id)
	orig__HUDMissionBriefing.set_slot_ready(self, peer, peer_id)
	change_status_size(self._ready_slot_panel, peer_id)
end

function HUDMissionBriefing:set_slot_not_ready(peer, peer_id)
	orig__HUDMissionBriefing.set_slot_not_ready(self, peer, peer_id)
	change_status_size(self._ready_slot_panel, peer_id)
end

function HUDMissionBriefing:set_dropin_progress(peer_id, progress_percentage, mode)
	orig__HUDMissionBriefing.set_dropin_progress(self, peer_id, progress_percentage, mode)
	change_status_size(self._ready_slot_panel, peer_id)
end

function HUDMissionBriefing:remove_player_slot_by_peer_id(peer, reason)
	orig__HUDMissionBriefing.remove_player_slot_by_peer_id(self, peer, reason)
	change_status_size(self._ready_slot_panel, peer:id())
end