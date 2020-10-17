math.randomseed(os.time())

among_us = {impostors = 1, impostors_list = {}, game_spawn = {x = 8, y = 21.5, z = 4}}

local players = 0
minetest.register_on_joinplayer(function(player)
	players = players + 1
end)
minetest.register_on_leaveplayer(function(player)
	players = players - 1
end)


local start_timer = false
local until_start = 5

local timer = 0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		if (start_timer) then
			minetest.chat_send_all("Start in "..until_start.."...")
			until_start = until_start - 1
			if (until_start == 0) then
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
		end
		timer = 0
	end
end)

function among_us.get_formspec(name)
    -- TODO: display whether the last guess was higher or lower

    local formspec = {
        "formspec_version[3]",
        "size[6,3.476]",
        "label[0.375,0.5;Impostors: ", minetest.formspec_escape(among_us.impostors), "]",
        "button[0.375,0.8;0.4,0.4;minusimpostor;<]",
        "button[1,0.8;0.4,0.4;plusimpostor;>]",
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

function among_us.show_to(name)
    minetest.show_formspec(name, "among_us:settings", among_us.get_formspec(name))
end

minetest.register_chatcommand("game", {
    func = function(name)
        among_us.show_to(name)
    end,
})

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

minetest.register_chatcommand("impostors", {
    params = "<number>",
    description = "Set impostors number",
    func = function(name, number)
    	number = tonumber(number)
    	if number < 1 then
    		minetest.chat_send_player(name, "Must be at least 1 impostor!")
    	elseif number > players then
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


minetest.register_node("among_us:admin", {
	description = "Admin computer",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 4,
	tiles = {
		"among_us_admin_top.png",
		"among_us_admin_sc_bottom.png^among_us_admin_bottom.png",
		"among_us_admin_right.png",
		"among_us_admin_left.png",
		"among_us_admin_sc_back.png^among_us_admin_back.png",
		"among_us_admin_front.png^among_us_admin_sc_front.png",
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, -0.4375, 0.375}, -- base
			{-0.4375, -0.4375, 0.375, 0.4375, 0.3125, 0.4375}, -- screen
		}
	},
	groups = {snappy = 1}
})

steel = {"White", "Grey", "Darkgrey", "Black"}

for i, color in ipairs(steel) do
	minetest.register_node("among_us:"..color:lower().."_steelblock", {
		description = color.." Steel Block",
		tiles = {"among_us_"..color:lower().."_steel_block.png"},
		groups = {cracky = 1, level = 2},
		--sounds =
	})
end


metal = {"Red", "Orange", "Green", "Blue"}

for i, color in ipairs(metal) do
	minetest.register_node("among_us:"..color:lower().."_metallist", {
		description = color.." Metal List",
		tiles = {"among_us_"..color:lower().."_metal_list.png"},
		groups = {cracky = 1, level = 2},
		--sounds =
	})
end

tile = {"White", "Blackwhite", "Grey", "Black"}

for i, color in ipairs(tile) do
	minetest.register_node("among_us:"..color:lower().."_tile", {
		description = color.." Tile",
		tiles = {"among_us_"..color:lower().."_tile.png"},
		groups = {cracky = 1, level = 2},
		--sounds =
	})
end

danger = {"Red", "Yellow"}

for i, color in ipairs(danger) do
	minetest.register_node("among_us:"..color:lower().."_danger", {
		description = color.." Hazard Strip",
		tiles = {"among_us_"..color:lower().."_danger.png"},
		groups = {cracky = 1, level = 2},
		--sounds =
	})
end

local tasks = 2

minetest.register_node("among_us:hologram", {
		description = "Hologram",
		drawtype = "plantlike",
		tiles = {"among_us_hologram.png"},
		groups = {cracky = 1, level = 2},
		--sounds =
	})

minetest.after(5, function()
	minetest.set_node({x=0,y=0,z=0}, {name="among_us:admin"})
end)
