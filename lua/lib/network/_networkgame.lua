-- Modified to alter the display of player count in lobbies
local orig__NetworkGame = {
	on_peer_added = NetworkGame.on_peer_added,
	check_peer_preferred_character = NetworkGame.check_peer_preferred_character
}

function NetworkGame:on_peer_added(peer, peer_id)
	orig__NetworkGame.on_peer_added(self, peer, peer_id)

	if Network:is_server() then
		-- Change the crime.net display to show the % of players relative to the lobby size set by host.
		local ratio = table.size(managers.network:session():all_peers()) / BigLobbyGlobals:num_player_slots()
		local ratio_to_icon = math.clamp( math.ceil(4 * ratio), 1, 4 )

		managers.network.matchmake:set_num_players( ratio_to_icon )
	end
end

-- Modified to support additional peers.
function NetworkGame:on_network_stopped()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	for k = 1, num_player_slots do
		self:on_drop_in_pause_request_received(k, nil, false)
		if self._members[k] then
			self._members[k]:delete()
		end
	end
	if managers.network:session():local_peer() then
		self:on_drop_in_pause_request_received(managers.network:session():local_peer():id(), nil, false)
	end

	-- Resets host lobby size preference when leaving their lobby
	Global.BigLobbyPersist.num_players = nil
	-- Update this variable in case the player left from lobby screen (doesn't reload the mod)
	BigLobbyGlobals.num_players = BigLobbyGlobals.num_players_settings--Global.BigLobbyPersist.num_players
end

-- Modified to provide all peers with a character, regardless of free characters.
function NetworkGame:check_peer_preferred_character(preferred_character)
	local free_characters = clone(CriminalsManager.character_names())
	for pid, member in pairs(self._members) do
		local character = member:peer():character()
		table.delete(free_characters, character)
	end
	if table.contains(free_characters, preferred_character) then
		return preferred_character
	end
	local character = #free_characters > 0 and free_characters[math.random(#free_characters)] or CriminalsManager.character_names()[math.random(#CriminalsManager.character_names())]
	print("Player will be", character, "instead of", preferred_character)
	return character
end