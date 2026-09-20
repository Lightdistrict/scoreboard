local Addon = MaxScoreboard

local identifier = Addon.identifier
local config = Addon.config

local Component = Addon.Component
local Components = Addon.Components

local font = Addon.font

--------------------------------------------------------------------------------
-- Constants

local BAR_HEIGHT = 26

-- Ping rating
local PING_POOR = 300 -- Any ping from this number is poor
local PING_AVERAGE = 150 -- Any ping from this number is average
local PING_GOOD = 75 -- Any ping from number is good; Everything below is excelent

--------------------------------------------------
-- Color constants

local COLOR_SHADOW = Color(0, 0, 0, 160)

-- Generic colors
local COLOR_WHITE = Color(255, 255, 255)
local COLOR_BLACK = Color(0, 0, 0)

-- Ping rating colors
local COLOR_PING_POOR = Color(255, 0, 0, 200)
local COLOR_PING_AVERAGE = Color(255, 100, 0, 200)
local COLOR_PING_GOOD = Color(255, 200, 0, 200)
local COLOR_PING_EXCELLENT = Color(0, 200, 0, 200)

--------------------------------------------------
-- Materials

local ICON_VOICE_ON = Material('scoreboard/icons/voice_on.png', 'noclamp smooth')
local ICON_VOICE_OFF = Material('scoreboard/icons/voice_off.png', 'noclamp smooth')

--------------------------------------------------
-- Fonts

local FONT_SMALL = font('small')
local FONT_SMALL_UNDERLINE = font('small.underline')

-- Constants
--------------------------------------------------------------------------------

local Row, Info

--------------------------------------------------

local osMaterials, countryMaterials = {}, {}

--[[
- @param string name
-
- @return material
]]
local function osMaterial(name)
    if osMaterials[name] == nil then
        osMaterials[name] = Material('scoreboard/icons/os/' .. string.lower(name) .. '.png', 'noclamp smooth')
    end
    return osMaterials[name]
end

--[[
- @param string name
-
- @return material
]]
local function countryMaterial(name)
    -- system.GetCountry() returns an UPPERCASE code (e.g. "US"), but the
    -- icon files are lowercase (country/us.png) -- normalize here.
    name = string.lower(name)

    if countryMaterials[name] == nil then
        countryMaterials[name] = Material('scoreboard/icons/country/' .. name .. '.png', 'noclamp alphatest')
    end
    return countryMaterials[name]
end

--------------------------------------------------

--[[
- PlayerRow component
]]
Components.PlayerRow = Component:extend(Components.PlayerRow, function(Class, Prototype)

    local COLLAPSE_COLLAPSED = 1
    local COLLAPSE_EXPANDED = 2
    local COLLAPSE_EXPANDING = 3
    local COLLAPSE_COLLAPSING = 4

    --[[
    - @var player
    ]]
    Prototype._player = nil

    --[[
    - @var bool
    ]]
    Prototype._collapse = COLLAPSE_COLLAPSED

    --[[
    - @var Component
    ]]
    Prototype.row = nil

    --[[
    - @var Component
    ]]
    Prototype.info = nil

    --[[
    - @param panel panel
    - @param player player
    ]]
    function Prototype:__construct(panel, player)
        self._player = player
        self.__parent.__construct(self, panel)
    end

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)

        panel:Dock(TOP)
        panel:SetTall(BAR_HEIGHT + 1)

        self.row = Row:create(self, self._player)
        self.info = Info:create(self, self._player)

        self.info:setVisible(false)

        self:override('PerformLayout', self.p_performLayout)
        self:override('Paint', self.p_paint)

        self.row:listen('onClick', self.event_row_onClick)

    end

    --[[ ]]
    function Prototype:p_performLayout(panel, w, h)

        local p_row = self.row:getPanel()
        local p_info = self.info:getPanel()

        p_row:SetWide(w)
        p_row:SetPos(0, 0)

        p_info:SetWide(w)
        p_info:SetPos(0, p_row:GetTall() + 1)

    end

    --[[ ]]
    function Prototype:p_paint(panel, w, h)

        local p_row = self.row:getPanel()

        -- Bottom border of the row
        surface.SetDrawColor(0, 0, 0, 160)
        surface.DrawRect(0, p_row:GetTall(), w, 1)

        -- Bottom border of the info panel
        if self._collapse ~= COLLAPSE_COLLAPSED then
            surface.DrawRect(0, h - 1, w, 1)
        end

    end

    --[[ ]]
    function Prototype:event_row_onClick()
        local self = self:getParent()

        local panel = self._panel

        local p_row = self.row:getPanel()
        local p_info = self.info:getPanel()

        if self._collapse == COLLAPSE_EXPANDED then
            self._collapse = COLLAPSE_COLLAPSING

            panel:SizeTo(-1, 1 + p_row:GetTall(), .25, 0, -1, function()
                self._collapse = COLLAPSE_COLLAPSED
                self.info:setVisible(false)
            end)

            surface.PlaySound('ui/freeze_cam.wav')

        elseif self._collapse == COLLAPSE_COLLAPSED then
            self._collapse = COLLAPSE_EXPANDING

            panel:SizeTo(-1, 2 + p_row:GetTall() + p_info:GetTall(), .25, 0, -1, function()
                self._collapse = COLLAPSE_EXPANDED
            end)
            self.info:setVisible(true)

            surface.PlaySound('ui/freeze_cam.wav')

        end

    end

end)

--[[
- Row component
]]
Row = Component:extend(function(Class, Prototype)

    --[[
    - @var string
    ]]
    Class._panelClass = 'DButton'

    --[[
    - @var player
    ]]
    Prototype._player = nil

    --[[
    - @var Component
    ]]
    Prototype.avatar = nil

    --[[
    - @var Component
    ]]
    Prototype.muteButton = nil

    --[[
    - @param panel panel
    - @param player player
    ]]
    function Prototype:__construct(panel, player)
        self._player = player
        self.__parent.__construct(self, panel)
    end

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)

        panel:SetTall(BAR_HEIGHT)
        panel:SetText("")

        self.avatar = Component:createNamed('AvatarImage', self)
        self.muteButton = Component:createNamed('DButton', self)

        self.avatar:getPanel():SetPlayer(self._player, 64)
        self.avatar:getPanel():SetMouseInputEnabled(false)

        self.muteButton:getPanel():SetText("")

        self:override('PerformLayout', self.p_performLayout)
        self:override('DoClick', self.p_doClick)
        self:override('Paint', self.p_paint)

        self:override(self.muteButton, 'DoClick', self.p_muteButton_doClick)
        self:override(self.muteButton, 'Paint', self.p_muteButton_paint)

    end

    --[[ ]]
    function Prototype:p_performLayout(panel, w, h)

        local p_avatar = self.avatar:getPanel()
        local p_muteButton = self.muteButton:getPanel()

        p_avatar:SetPos(0, 0)
        p_avatar:SetSize(h, h)

        p_muteButton:SetSize(h, h)
        p_muteButton:SetPos(w - h, 0)

    end

    --[[ ]]
    function Prototype:p_doClick(panel)
        self:trigger('onClick')
    end

    --[[ ]]
    function Prototype:p_paint(panel, w, h)
        local player = self._player

        local color = team.GetColor(self._player:Team())
        color.a = 180

        -- Shadowish effect
        surface.SetDrawColor(Color(255, 255, 255, 40))
        surface.DrawRect(0, 0, w, 2)

        -- The bar color itself
        surface.SetDrawColor(color)
        surface.DrawRect(0, 0, w, h)

        if panel:IsHovered() then
            surface.SetDrawColor(Color(255, 255, 255, 10))
            surface.DrawRect(0, 0, w, h)
        end

        self:drawContent(w, h)

    end

    --[[ ]]
    function Prototype:drawContent(w, h)
        local player = self._player

        local color = COLOR_WHITE
        if player == LocalPlayer() then
            color = Color(255, 255, 200)
        end

        -- Usergroup icon (always returns a material -- falls back to the
        -- default "user" icon for the "user" group or an unlisted one)
        local rankIcon = config.getUserGroupIconMaterial(player)
        if rankIcon then
            surface.SetMaterial(rankIcon)
            surface.SetDrawColor(COLOR_SHADOW)
            surface.DrawTexturedRect(32 + 1, h * .5 - 8 + 1, 16, 16)
            surface.SetDrawColor(color)
            surface.DrawTexturedRect(32, h * .5 - 8, 16, 16)
        end

        -- Country -- each client self-reports its own system.GetCountry() over
        -- the network (see src/sv_misc.lua and src/cl_misc.lua); using
        -- system.GetCountry() directly here would only ever show YOUR OWN
        -- country on every row, not each player's.
        local countryCode = Addon.playerCountries[player:SteamID64()] or '_unknown'
        surface.SetMaterial(countryMaterial(countryCode))
        surface.SetDrawColor(Color(255, 255, 255))
        surface.DrawTexturedRect(54, h * .5 - 11, 22, 22)

        -- OS -- also self-reported by the player being drawn, not the viewer
        local osName = (Addon.playerOS and Addon.playerOS[player:SteamID64()]) or 'unknown'
        surface.SetMaterial(osMaterial(osName))
        surface.SetDrawColor(Color(255, 255, 255))
        surface.DrawTexturedRect(84, h * .5 - 8, 16, 16)

        -- Nickname
        draw.SimpleText(player:Nick(), FONT_SMALL, 106 + 1, h * .5 + 1, COLOR_SHADOW, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(player:Nick(), FONT_SMALL, 106, h * .5, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Job
        draw.SimpleText(player:getDarkRPVar('job') or "--", FONT_SMALL, w * .5  + 1, h * .5 + 1, COLOR_SHADOW, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(player:getDarkRPVar('job') or "--", FONT_SMALL, w * .5, h * .5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Level/Prestige -- levelsystem addon, if installed, broadcasts
        -- this to every client (LevelSystem.PublicData, keyed by player
        -- entity -- see its cl_public_data.lua/sv_data.lua). Not using
        -- NWInt here: those only reliably reach clients for whom the
        -- entity is currently PVS-relevant, which silently breaks a
        -- scoreboard that's supposed to show everyone regardless of
        -- visibility.
        local levelData = LevelSystem and LevelSystem.PublicData and LevelSystem.PublicData[player]
        if levelData then
            local levelText = (levelData.prestige > 0 and ('P' .. levelData.prestige .. ' ') or '') .. 'Lvl ' .. levelData.level

            draw.SimpleText(levelText, FONT_SMALL, w * .625 + 1, h * .5 + 1, COLOR_SHADOW, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(levelText, FONT_SMALL, w * .625, h * .5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Money
        do
            local playerMoney = IsValid( player ) and player:getDarkRPVar("money") or 0
            local text = '$' .. string.Comma( playerMoney )


            draw.SimpleText(text, FONT_SMALL, w * .75 + 1, h * .5 + 1, COLOR_SHADOW, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(text, FONT_SMALL, w * .75, h * .5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        end

        -- Ping
        self:drawPing(w, h)

    end

    --[[ ]]
    function Prototype:drawPing(w, h)
        local x, y = w - h - 18, h * .5
        local ping = self._player:Ping()

        surface.SetDrawColor(COLOR_SHADOW)
        surface.DrawRect(x + 0 + 1, y + 4 + 1, 3, 3)
        if ping < PING_POOR then
            surface.DrawRect(x + 4 + 1, y + 0 + 1, 3, 7)
        end
        if ping < PING_AVERAGE then
            surface.DrawRect(x + 8 + 1, y - 4 + 1, 3, 11)
        end
        if ping < PING_GOOD then
            surface.DrawRect(x + 12 + 1, y - 8 + 1, 3, 15)
        end

        if ping >= PING_POOR then
            surface.SetDrawColor(COLOR_PING_POOR)
        elseif ping >= PING_AVERAGE then
            surface.SetDrawColor(COLOR_PING_AVERAGE)
        elseif ping >= PING_GOOD then
            surface.SetDrawColor(COLOR_PING_GOOD)
        else
            surface.SetDrawColor(COLOR_PING_EXCELLENT)
        end

        surface.DrawRect(x + 00, y + 4, 3, 3)
        if ping < PING_POOR then
            surface.DrawRect(x + 04, y, 3, 7)
        end
        if ping < PING_AVERAGE then
            surface.DrawRect(x + 8, y - 4, 3, 11)
        end
        if ping < PING_GOOD then
            surface.DrawRect(x + 12, y - 8, 3, 15)
        end

    end

    --------------------------------------------------
    -- Mute button

    --[[ ]]
    function Prototype:p_muteButton_doClick(panel, w, h)
        self._player:SetMuted(not self._player:IsMuted())
    end

    --[[ ]]
    function Prototype:p_muteButton_paint(panel, w, h)

        if self._player:IsMuted() then
            surface.SetDrawColor(COLOR_WHITE)
            surface.SetMaterial(ICON_VOICE_OFF)
        else
            surface.SetDrawColor(COLOR_SHADOW)
            surface.SetMaterial(ICON_VOICE_ON)
        end

        surface.DrawTexturedRect(5, h * .5 - 7, 14, 14)

    end

end)

--[[
- Info component
]]
Info = Component:extend(function(Class, Prototype)

    --[[
    - @var player
    ]]
    Prototype._player = nil

    --[[
    - @var Component
    ]]
    Prototype.profileButton = nil

    --[[
    - @var Component
    ]]
    Prototype.steamIdButton = nil

    --[[
    - @var Component
    ]]
    Prototype.steamId64Button = nil

    --[[
    - @param panel panel
    - @param player player
    ]]
    function Prototype:__construct(panel, player)
        self._player = player
        self.__parent.__construct(self, panel)
    end

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)

        panel:SetTall(72)

        self.steamIdButton = Component:createNamed('DButton', self)
        self.steamId64Button = Component:createNamed('DButton', self)
        self.profileButton = Component:createNamed('DButton', self)

        self:override('PerformLayout', self.p_performLayout)
        self:override('Paint', self.p_paint)

        self:override(self.steamIdButton, 'DoClick', self.p_steamIdButton_doClick)
        self:override(self.steamId64Button, 'DoClick', self.p_steamId64Button_doClick)
        self:override(self.profileButton, 'DoClick', self.p_profileButton_doClick)

        local p_steamIdButton = self.steamIdButton:getPanel()
        local p_steamId64Button = self.steamId64Button:getPanel()
        local p_profileButton = self.profileButton:getPanel()

        p_steamIdButton:SetText(self._player:SteamID() ~= 'NULL' and self._player:SteamID() or "--")
        p_steamIdButton:SetFont(FONT_SMALL_UNDERLINE)

        p_steamId64Button:SetText(self._player:SteamID64() or "--")
        p_steamId64Button:SetFont(FONT_SMALL_UNDERLINE)

        p_profileButton:SetText("Show Steam profile")
        p_profileButton:SetFont(FONT_SMALL_UNDERLINE)

        self:override(self.steamIdButton, 'Paint', self.p_textButton_paint)
        self:override(self.steamId64Button, 'Paint', self.p_textButton_paint)
        self:override(self.profileButton, 'Paint', self.p_textButton_paint)

    end

    --[[ ]]
    function Prototype:p_performLayout(panel, w, h)

        local x, y = 8, 8

        local p_profileButton = self.profileButton:getPanel()
        local p_steamIdButton = self.steamIdButton:getPanel()
        local p_steamId64Button = self.steamId64Button:getPanel()

        p_steamIdButton:SizeToContentsX()
        p_steamIdButton:SetTall(16)
        p_steamIdButton:SetPos(x + 320, y + 20)

        p_steamId64Button:SizeToContentsX()
        p_steamId64Button:SetTall(16)
        p_steamId64Button:SetPos(x + 320, y + 40)

        p_profileButton:SizeToContentsX()
        p_profileButton:SetTall(16)
        p_profileButton:SetPos(w - p_profileButton:GetWide() - 8, h - p_profileButton:GetTall() - 6)

    end

    --[[ ]]
    function Prototype:p_paint(panel, w, h)
        local player = self._player

        surface.SetDrawColor(Color(0, 0, 0, 60))
        surface.DrawRect(0, 0, w, h)

        local x, y = 8, 8

        local time = math.floor(CurTime() - player:GetCreationTime())
        local hours, minutes, seconds = math.floor(time / 3600), math.floor(time / 60) % 60, time % 60
        local onlineForTime = (hours > 0 and hours .. "h " or "") .. (minutes > 0 and minutes .. "m " or "") .. seconds .. "s"

        draw.SimpleText("Nickname: ", FONT_SMALL, x, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(player:Nick(), FONT_SMALL, x + 68, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText("Usergroup: ", FONT_SMALL, x, y + 20, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(player:GetUserGroup(), FONT_SMALL, x + 68, y + 20, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText("Online for: ", FONT_SMALL, x, y + 40, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(onlineForTime, FONT_SMALL, x + 68, y + 40, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText("Steamname: ", FONT_SMALL, x + 240, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(player:SteamName(), FONT_SMALL, x + 320, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText("SteamID: " , FONT_SMALL, x + 240, y + 20, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        -- draw.SimpleText((player:SteamID() == "NULL" and " --" or player:SteamID()), FONT_SMALL, x + 320, y + 20, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText("SteamID64: " , FONT_SMALL, x + 240, y + 40, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        -- draw.SimpleText((player:SteamID64() or " --"), FONT_SMALL, x + 320, y + 40, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local propsLimit = cvars.Number("sbox_maxprops", 0)

        draw.SimpleText("Props: " .. player:GetCount('props') .. "/" .. propsLimit, FONT_SMALL,
            w - 8, y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    end

    --------------------------------------------------
    -- Profile button

    --[[ ]]
    function Prototype:p_textButton_paint(panel, w, h)
        panel:SetTextColor(panel:IsHovered() and Color(220, 220, 220) or Color(150, 210, 255))
    end

    --[[ ]]
    function Prototype:p_profileButton_doClick()
        self._player:ShowProfile()
    end

    --[[ ]]
    function Prototype:p_steamIdButton_doClick()
        SetClipboardText(self._player:SteamID() or "")
        surface.PlaySound('buttons/button14.wav')
    end

    --[[ ]]
    function Prototype:p_steamId64Button_doClick()
        SetClipboardText(self._player:SteamID64() or "")
        surface.PlaySound('buttons/button14.wav')
    end

end)
