local Addon = MaxScoreboard

resource.AddFile('resource/fonts/montserrat-regular.ttf')

----------------------------------------------------------------
-- Country relay
--
-- The original code drew every row's flag from system.GetCountry(),
-- which only ever returns the LOCAL viewer's own country -- every
-- player would show the same flag (yours), not their actual one.
--
-- Fix: each client self-reports its own system.GetCountry() once on
-- spawn, the server relays it to everyone (and re-sends the full known
-- set to anyone who joins later), same pattern as OS detection.
----------------------------------------------------------------

util.AddNetworkString('maxscoreboard.country')

local knownCountries = {} -- [steamid64] = "US" / "NL" / etc

net.Receive('maxscoreboard.country', function(len, ply)
    if not IsValid(ply) then return end

    local country = net.ReadString()
    knownCountries[ply:SteamID64()] = country

    net.Start('maxscoreboard.country')
        net.WriteString(ply:SteamID64())
        net.WriteString(country)
    net.Broadcast()
end)

hook.Add('PlayerInitialSpawn', 'maxscoreboard.country.resend', function(newPly)
    timer.Simple(3, function()
        if not IsValid(newPly) then return end

        for steamid64, country in pairs(knownCountries) do
            net.Start('maxscoreboard.country')
                net.WriteString(steamid64)
                net.WriteString(country)
            net.Send(newPly)
        end
    end)
end)

----------------------------------------------------------------
-- OS relay
--
-- Same bug, same fix, as the country relay above: the original code
-- used system.IsWindows()/IsLinux()/IsOSX() directly in the per-row
-- draw call, which only ever reflects the LOCAL viewer's own OS.
----------------------------------------------------------------

util.AddNetworkString('maxscoreboard.os')

local knownOS = {} -- [steamid64] = "windows" / "linux" / "osx"

net.Receive('maxscoreboard.os', function(len, ply)
    if not IsValid(ply) then return end

    local os = net.ReadString()
    knownOS[ply:SteamID64()] = os

    net.Start('maxscoreboard.os')
        net.WriteString(ply:SteamID64())
        net.WriteString(os)
    net.Broadcast()
end)

hook.Add('PlayerInitialSpawn', 'maxscoreboard.os.resend', function(newPly)
    timer.Simple(3, function()
        if not IsValid(newPly) then return end

        for steamid64, os in pairs(knownOS) do
            net.Start('maxscoreboard.os')
                net.WriteString(steamid64)
                net.WriteString(os)
            net.Send(newPly)
        end
    end)
end)
