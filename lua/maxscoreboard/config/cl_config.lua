local config = MaxScoreboard.config

--------------------------------------------------
-- Usergroup icon
--
-- Maps a usergroup name (whatever ply:GetUserGroup() returns -- kept in
-- sync by both SAM and ULX/ULib via CAMI) to an icon filename inside
-- materials/scoreboard/icons/. Match the KEYS to your actual usergroup
-- names, and the FILENAMES to whatever's actually in your max_assets
-- icon pack (materials/scoreboard/icons/).
--------------------------------------------------

config.rankIcons = {
    ['superadmin'] = 'group_superadmin.png',
    ['admin']      = 'group_admin.png',
    ['moderator']  = 'group_moderator.png',
    ['developer']  = 'group_developer.png',
    ['vip']        = 'group_vip.png',
    ['supporter']  = 'group_supporter.png',
}

local iconCache = {}
local function rankIconMaterial(file)
    if iconCache[file] == nil then
        iconCache[file] = Material('scoreboard/icons/' .. file, 'noclamp smooth')
    end
    return iconCache[file]
end

local ICON_GROUP_USER = rankIconMaterial('group_user.png')

--[[
- Returns a usergroup icon for the player. Always returns a material --
- falls back to the default "user" icon for the "user" group and for
- any group not listed in config.rankIcons.
-
- @param player player
-
- @return material
]]
config.getUserGroupIconMaterial = function(player)
    local userGroup = string.lower(player:GetUserGroup() or 'user')

    if config.debugFakeBotData and player:IsBot() then
        userGroup = config.getDebugData(player).rank
    end

    local iconFile = config.rankIcons[userGroup]
    if iconFile then
        return rankIconMaterial(iconFile)
    end

    return ICON_GROUP_USER
end

--------------------------------------------------
-- Debug: fake bot data
--
-- Real players self-report their own country/OS over the network (see
-- src/sv_misc.lua + src/cl_misc.lua), so a single test player will only
-- ever show their own real flag/OS/rank. Bots can't self-report at all.
-- Set debugFakeBotData = true and spawn a few with the "bot" console
-- command to preview varied flags/OS/ranks on the scoreboard without
-- needing real testers from other countries.
--
-- ALWAYS set this back to false before going live -- it only affects
-- bot rows, but there's no reason to ship it enabled.
--------------------------------------------------

config.debugFakeBotData = false

local DEBUG_COUNTRIES = { 'us', 'gb', 'de', 'nl', 'ca', 'au', 'br', 'jp' }
local DEBUG_OS = { 'windows', 'linux', 'osx' }
local DEBUG_RANKS = { 'user', 'vip', 'supporter', 'moderator', 'admin', 'superadmin', 'developer' }

local debugAssignments = {}

--[[
- Deterministic fake country/OS/rank for a bot, based on its entity index
- so it stays consistent for that bot across refreshes (until it respawns).
-
- @param player player
-
- @return table {country, os, rank}
]]
config.getDebugData = function(player)
    local key = player:EntIndex()

    if not debugAssignments[key] then
        debugAssignments[key] = {
            country = DEBUG_COUNTRIES[(key % #DEBUG_COUNTRIES) + 1],
            os = DEBUG_OS[(key % #DEBUG_OS) + 1],
            rank = DEBUG_RANKS[(key % #DEBUG_RANKS) + 1],
        }
    end

    return debugAssignments[key]
end
