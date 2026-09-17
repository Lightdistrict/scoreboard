local config = StudioNetworkScoreboard.config

--------------------------------------------------
-- Usergroup icon
 
local ICON_GROUP_USER = Material('studionet/scoreboard/icons/group_user.png', 'noclamp smooth')
local ICON_GROUP_ADMIN = Material('studionet/scoreboard/icons/group_admin.png', 'noclamp smooth')
local ICON_GROUP_MANAGER = Material('studionet/scoreboard/icons/group_manager.png', 'noclamp smooth')
local ICON_GROUP_VIP = Material('studionet/scoreboard/icons/group_vip.png', 'noclamp smooth')
local ICON_GROUP_DEVELOPER = Material('studionet/scoreboard/icons/group_developer.png', 'noclamp smooth')
local ICON_GROUP_CEO = Material('studionet/scoreboard/icons/group_ceo.png', 'noclamp smooth')

local userGroupIcons = {
    ['Network President'] = ICON_GROUP_CEO,
    ['Developer'] = ICON_GROUP_DEVELOPER,
    ['VIP'] = ICON_GROUP_VIP,
    ['VIP+'] = ICON_GROUP_VIP,
    ['Studioist'] = ICON_GROUP_VIP,
    ['CManager'] = ICON_GROUP_MANAGER,
    ['Director'] = ICON_GROUP_MANAGER,
    ['LeadAdmin'] = ICON_GROUP_ADMIN,
    ['SeniorAdmin'] = ICON_GROUP_ADMIN,
    ['SeniorAdmin'] = ICON_GROUP_ADMIN,
    ['Admin'] = ICON_GROUP_ADMIN,
    ['Moderator'] = ICON_GROUP_ADMIN,
    ['SeniorMod'] = ICON_GROUP_ADMIN,
    ['TrialModerator'] = ICON_GROUP_MANAGER
}

--[[
- Returns a usergroup icon for the player.
-
- @param player player
-
- @return material
]]
config.getUserGroupIconMaterial = function(player)
    local userGroup = player:GetUserGroup()

    if player:IsAdmin() then
        return ICON_GROUP_ADMIN
    end

    if userGroupIcons[userGroup] then
        return userGroupIcons[userGroup]
    end

    return ICON_GROUP_USER
end
