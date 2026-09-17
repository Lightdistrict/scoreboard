local Addon = MaxScoreboard

local identifier = Addon.identifier

----------------------------------------------------------------
-- Country relay (see src/sv_misc.lua for the server side)

Addon.playerCountries = {} -- [steamid64] = "US" / "NL" / etc

net.Receive('maxscoreboard.country', function()
    local steamid64 = net.ReadString()
    local country = net.ReadString()
    Addon.playerCountries[steamid64] = country
end)

hook.Add('InitPostEntity', identifier .. '.sendCountry', function()
    net.Start('maxscoreboard.country')
        net.WriteString(system.GetCountry())
    net.SendToServer()
end)

----------------------------------------------------------------
-- OS relay (see src/sv_misc.lua for the server side)

Addon.playerOS = {} -- [steamid64] = "windows" / "linux" / "osx"

net.Receive('maxscoreboard.os', function()
    local steamid64 = net.ReadString()
    local os = net.ReadString()
    Addon.playerOS[steamid64] = os
end)

hook.Add('InitPostEntity', identifier .. '.sendOS', function()
    local os = system.IsWindows() and 'windows' or system.IsLinux() and 'linux' or system.IsOSX() and 'osx' or 'unknown'

    net.Start('maxscoreboard.os')
        net.WriteString(os)
    net.SendToServer()
end)

----------------------------------------------------------------
