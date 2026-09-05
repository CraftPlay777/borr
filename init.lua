-- Cargamos la función de traducción
local S = minetest.get_translator("borr")

local borr_positions = {}

local function clear_area(player_name, p1, p2)
    local minp = {
        x = math.min(p1.x, p2.x),
        y = math.min(p1.y, p2.y),
        z = math.min(p1.z, p2.z)
    }
    local maxp = {
        x = math.max(p1.x, p2.x),
        y = math.max(p1.y, p2.y),
        z = math.max(p1.z, p2.z)
    }

    -- 1. Eliminar bloques
    for x = minp.x, maxp.x do
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                minetest.set_node({x=x, y=y, z=z}, {name="air"})
            end
        end
    end

    -- 2. Eliminar entidades
    local objects = minetest.get_objects_in_area(minp, maxp)
    for _, obj in ipairs(objects) do
        if not obj:is_player() then
            obj:remove()
        end
    end

    minetest.chat_send_player(player_name, S("[Borr] Area completely cleared!"))
    borr_positions[player_name] = nil
end

minetest.register_chatcommand("borr", {
    description = S("Clears blocks and entities from an area. Use /borr pos1 and /borr pos2"),
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false end

        if not borr_positions[name] then
            borr_positions[name] = {}
        end

        if param == "" then
            return true, S("[Borr] Run '/borr pos1' where you are standing. Then go to the opposite corner and use '/borr pos2'.")
            
        elseif param == "pos1" then
            borr_positions[name].pos1 = vector.round(player:get_pos())
            return true, S("[Borr] Position 1 saved.")
            
        elseif param == "pos2" then
            borr_positions[name].pos2 = vector.round(player:get_pos())
            
            if borr_positions[name].pos1 then
                minetest.chat_send_player(name, S("[Borr] Position 2 saved. Clearing area..."))
                clear_area(name, borr_positions[name].pos1, borr_positions[name].pos2)
                return true
            else
                return true, S("[Borr] Error: You need to define Position 1 first. Use '/borr pos1'.")
            end
            
        else
            return false, S("[Borr] Invalid parameter. Use only /borr, /borr pos1 or /borr pos2")
        end
    end
})
