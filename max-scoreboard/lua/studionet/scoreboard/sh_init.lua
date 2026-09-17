local Addon = StudioNetworkScoreboard or {

    version = '1.0.0',
    versionNr = 100,

    name = "Studio Network's Scoreboard",
    alias = "StudioNetworksScoreboard",
    identifier = 'studionet.scoreboard',

    config = {}

}
StudioNetworkScoreboard = Addon

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
Addon.include('src/cl_util.lua', 'client')
Addon.include('src/cl_view.lua', 'client')

Addon.include('src/view/cl_scoreboard.lua', 'client')
Addon.include('src/view/cl_player_list.lua', 'client')
Addon.include('src/view/cl_player_row.lua', 'client')

--------------------------------------------------------------------------------

if SERVER and Addon.config.downloadTestResources then
    -- Only on localhost

    -- resource.AddFile('materials/icefuse/scoreboard/icons/group_user.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/group_admin.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/group_manager.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/group_developer.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/group_ceo.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/group_vip.png')

    -- resource.AddFile('materials/icefuse/scoreboard/icons/voice_on.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/voice_off.png')

    -- resource.AddFile('materials/icefuse/scoreboard/icons/pin.png')

    -- resource.AddFile('materials/icefuse/scoreboard/icons/country/_unknown.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/country/US.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/country/NL.png')

    -- resource.AddFile('materials/icefuse/scoreboard/icons/os/windows.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/os/linux.png')
    -- resource.AddFile('materials/icefuse/scoreboard/icons/os/osx.png')

end