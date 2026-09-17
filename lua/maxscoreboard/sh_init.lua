local Addon = MaxScoreboard or {

    version = '1.0.0',
    versionNr = 100,

    name = "MAX Scoreboard",
    alias = "MaxScoreboard",
    identifier = 'maxscoreboard',

    config = {}

}
MaxScoreboard = Addon

--------------------------------------------------
-- Utilities

--[[
- Includes a file.
- @arg string file
- @arg string type
]]
function Addon.include(file, type)
    if type == 'server' or type == 'shared' then
        if SERVER then
            include(file)
        end
    end
    if type == 'client' or type == 'shared' then
        if SERVER then
            AddCSLuaFile(file)
        else
            include(file)
        end
    end
end

--------------------------------------------------------------------------------

-- Include files
Addon.include('src/lib/sh_class.lua', 'shared')
Addon.include('src/lib/cl_component.lua', 'client')

Addon.include('config/sh_config.lua', 'shared')
Addon.include('config/cl_config.lua', 'client')

Addon.include('src/cl_misc.lua', 'client')
Addon.include('src/sv_misc.lua', 'server')

Addon.include('src/cl_fonts.lua', 'client')
Addon.include('src/cl_view.lua', 'client')

Addon.include('src/view/cl_scoreboard.lua', 'client')
Addon.include('src/view/cl_player_list.lua', 'client')
Addon.include('src/view/cl_player_row.lua', 'client')
