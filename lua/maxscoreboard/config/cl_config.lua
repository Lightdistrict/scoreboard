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

    local iconFile = config.rankIcons[userGroup]
    if iconFile then
        return rankIconMaterial(iconFile)
    end

    return ICON_GROUP_USER
end
