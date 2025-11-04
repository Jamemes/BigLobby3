-- Updates colours to support UI elements for additional peers while avoiding those
-- that affect gameplay such as orange and yellow

local num_player_slots = BigLobbyGlobals:num_player_slots()


-- Make sure we have enough colours to support the number of player slots

tweak_data.peer_vector_colors[5] = nil
tweak_data.peer_colors[5] = nil

local steps = 360 / num_player_slots
for i = 4, num_player_slots - 1 do
	-- RGB channels
	local hue = i * steps
	local col = Vector3(_G.HUSL.huslp_to_rgb(hue, 100, 60))

	table.insert(tweak_data.peer_vector_colors, col)
	table.insert(tweak_data.peer_colors, tostring("team_colour_") .. i)
end

-- AI labels will use the last value so we add it at the end
table.insert(tweak_data.peer_vector_colors, Vector3(0.2, 0.8, 1))
table.insert(tweak_data.peer_colors, "mrai")

-- Dynamically added now based on peer_vector_colors table
tweak_data.chat_colors = {}
for i = 1, #tweak_data.peer_vector_colors do
	tweak_data.chat_colors[i] = Color(tweak_data.peer_vector_colors[i]:unpack())
end

-- Use the same colours created for chat for preplanning
tweak_data.preplanning_peer_colors = {}
for i = 1, #tweak_data.peer_vector_colors do
	tweak_data.preplanning_peer_colors[i] = Color(tweak_data.peer_vector_colors[i]:unpack())
end