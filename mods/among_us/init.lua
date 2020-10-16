among_us = {impostors = 1, }

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
	}
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
