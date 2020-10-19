local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

math.randomseed(os.time())

among_us = {impostors = 1, impostors_list = {}, game_spawn = {x = 8, y = 21.5, z = 4}, game_time = false, guess_time = true, players_list = {}}

local players = 0
minetest.register_on_joinplayer(function(player)
	players = players + 1
	
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
			minetest.chat_send_all("try "..rand)
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
		if impostors_numbers[rand] ~= nil then
			minetest.chat_send_all(player:get_name().." is an impostor!")
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
    minetest.show_formspec(name, "among_us:settings", among_us.get_formspec(name))
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

--minetest.register_chatcommand("game", {
--    func = function(name)
--        among_us.show_to(name)
--    end,
--})

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

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
dofile(modpath.."/nodes.lua")

