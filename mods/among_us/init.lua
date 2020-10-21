local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

math.randomseed(os.time())

among_us = {impostors = 1, impostors_list = {}, skins = {}, game_spawn = {x = 8, y = 21.5, z = 4}, game_time = false, guess_time = true, players_list = {}}

local players = 0
minetest.register_on_joinplayer(function(player)
	players = players + 1
	
	player:set_nametag_attributes({text = " "})
	
	among_us.skins[player] = players
	default.player_set_textures(player, {"skin_"..players..".png"})
	local meta = player:get_meta()
	meta:set_string("among_us:", skins.skins[playername])
end)

minetest.register_on_leaveplayer(function(player)
	players = players - 1
end)


local start_timer = false
local until_start = 5

local timer = 0

function among_us.start_game()
	local impostors_numbers = {}
	for i=1,among_us.impostors do
		while true do
			local rand = math.random(1, players)
			if impostors_numbers[rand] == nil then
				impostors_numbers[rand] = true
				break
			end
		end
	end
	for i, player in ipairs(minetest.get_connected_players()) do
		table.insert(among_us.players_list, player)
		local deg = math.pi * 2 / players * i
		player:set_pos({x = among_us.game_spawn.x + math.cos(deg) * 2, y = among_us.game_spawn.y, z = among_us.game_spawn.z + math.sin(deg) * 2})
		player:set_look_vertical(0)
		player:set_look_horizontal(deg + math.pi / 2)
		if impostors_numbers[i] ~= nil then
			minetest.chat_send_all(player:get_player_name().." is an impostor!")
			among_us.impostors_list[player] = true
		end
	end		
	start_timer = false
	until_start = 5
end


minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		if (start_timer) then
			minetest.chat_send_all("Start in "..until_start.."...")
			until_start = until_start - 1
			if (until_start == 0) then
				among_us.start_game()
			end
		end
		timer = 0
	end
end)


function among_us.guess_formspec(name)

	local formspec = ""

	--if skins.invplus then
	--	formspec = "size[8,8.6]"
	--		.. "bgcolor[#08080822;true]"
	--end

	formspec = formspec .. "label[.5,2;" .. "Select Player Skin:" .. "]"
		.. "textlist[.5,2.5;6.8,6;skins_set;"

	local meta
	local selected = 1

	for i = 1, players do

		formspec = formspec .. among_us.meta[i].name

		if skins.skins[name] == among_us.skins[i] then
			selected = i
			meta = skins.meta[ skins.skins[name] ]
		end

		if i < #skins.list then
			formspec = formspec ..","
		end
	end

	--if skins.invplus then
	--	formspec = formspec .. ";" .. selected .. ";true]"
	--else
	--	formspec = formspec .. ";" .. selected .. ";false]"
	--end

	if meta then
		if meta.name then
			formspec = formspec .. "label[2,.5;" .. "Name: " .. meta.name .. "]"
		end
		if meta.author then
			formspec = formspec .. "label[2,1;" .. "Author: " .. meta.author .. "]"
		end
	end

	return formspec
end

function among_us.get_formspec(name)
    -- TODO: display whether the last guess was higher or lower

    local formspec = {
        "formspec_version[3]",
        "size[6,3.476]",
        "image[1,0.6;1,2;character_25.png]",
        "label[0.375,0.5;Who is the impostor?]",
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

function among_us.show_to(name)
    minetest.show_formspec(name, "among_us:settings", among_us.guess_formspec(name))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "among_us:settings" then
        return
    end

    if fields.plusimpostor then
        among_us.impostors = among_us.impostors + 1
    end
    if fields.minusimpostor then
        among_us.impostors = among_us.impostors - 1
    end
end)

minetest.register_chatcommand("game", {
    func = function(name)
        among_us.show_to(name)
    end,
})

minetest.register_chatcommand("impostors", {
    params = "<number>",
    description = "Set impostors number",
    func = function(name, number)
    	number = tonumber(number)
    	if number < 1 then
    		minetest.chat_send_player(name, "Must be at least 1 impostor!")
    	elseif number >= players then
    		minetest.chat_send_player(name, "Can't be more than "..(players - 1).." impostors!")
    	else
        	among_us.impostors = number
        	minetest.chat_send_all("Impostors number changed to " .. among_us.impostors)
        end
    end,
})

minetest.register_chatcommand("start", {
    func = function(_)
        start_timer = true
    end,
})

function among_us.show_guess(name)
	minetest.show_formspec(name, "among_us:guess", among_us.get_formspec(name))
end

function among_us.show_guess_all()
	for _, player in ipairs(minetest.get_connected_players()) do
		
	end
end

minetest.register_chatcommand("guess", {
    func = function(name)
        if among_us.guess_time then
        	among_us.show_guess(name)
        end
    end,
})

function player_to_spectator(player)
	local privs = {}
	privs.fly, privs.fast = true, true
	privs.interact, privs.shout = nil, nil
	vs, fs ,cb = { x = 0, y = 0 }, false, { 0, 0, 0, 0, 0, 0 }
	minetest.set_player_privs(player:get_player_name(), privs)
	player:set_nametag_attributes({ color = { a = 0, r = 0, g = 0, b = 0 } })
	player:set_armor_groups({ immortal = 1 })
	player:hud_set_flags({
		hotbar = false,
		healthbar = false,
		crosshair = false,
		wielditem = false,
		breathbar = false,
	})
	player:set_properties({
		visual_size = vs,
		makes_footstep_sound = fs,
		collisionbox = cb,
	})
end

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	minetest.chat_send_player(player:get_player_name(), "You were killed by "..hitter:get_player_name().."!")
	player_to_spectator(player)
	--if among_us.impostors_list[hitter] ~= nil and among_us.impostors_list[player] == nil then
	--end
end)

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
dofile(modpath.."/nodes.lua")

