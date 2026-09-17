local Addon = MaxScoreboard
 
local identifier = Addon.identifier
local class = Addon.class

local Components = Addon.Components

----------------------------------------------------------------

--[[
- Scoreboard singleton.
]]
function Addon.scoreboard()
    if Addon._scoreboard == nil then
        Addon._scoreboard = Addon.Scoreboard:new()
    end
    return Addon._scoreboard
end

----------------------------------------------------------------
-- Hooks

timer.Simple(0, function()

    hook.Add('ScoreboardShow', identifier, function()
        Addon.scoreboard():show()

        return true
    end)

    hook.Add('ScoreboardHide', identifier, function()
        Addon.scoreboard():hide()

        return true
    end)

end)

hook.Add('OnEntityCreated', identifier, function(entity)
    if entity:IsPlayer() then

        -- Adds the player
        Addon.scoreboard():addPlayer(entity)

    end
end)

hook.Add('EntityRemoved', identifier, function(entity)
    if entity:IsPlayer() then

        -- Remove the player
        Addon.scoreboard():removePlayer(entity)

    end
end)


--[[
- Refresh every now and then..
- Whenever a player changes team etc it should resort the list.
]]
timer.Create(identifier .. '.refresh', 3, 0, function()
    local scoreboard = Addon.scoreboard()
    if scoreboard:isVisible() then
        local view = scoreboard:getView():getPlayerList()

        view:sortPlayers()
        view:refreshView()

    end
end)

----------------------------------------------------------------

--[[
- The scoreboard.
-
- @class Scoreboard
]]
Addon.Scoreboard = class(nil, Addon.Scoreboard, function(Class, Prototype)

    --[[
    - @var Components.Scoreboard
    ]]
    Prototype._view = nil

    --[[
    - @protected
    -
    - @return Component
    ]]
    function Prototype:_createView()
        local view = Components.Scoreboard:create()

        view:getPlayerList():addPlayers(player.GetAll(), true)

        return view
    end

    --[[
    - Shows the scoreboard.
    ]]
    function Prototype:show()

        if self._view ~= nil and self._view:isPinned() then
            return
        end

        -- Always destroy the view on debug mode
        if Addon.config.debug == true then
            self:destroy()
        end

        -- Create a new view if it is nil
        if self._view == nil then
            self._view = self:_createView()
        end

        self._view:setVisible(true)
        self:refreshPlayerList()

    end

    --[[
    - Hides the scoreboard.
    ]]
    function Prototype:hide()

        if self._view == nil then
            return
        end

        -- Do not hide when pinned
        if self._view:isPinned() then
            return
        end

        self._view:setVisible(false)

    end

    --[[
    - Destroys the scoreboard.
    ]]
    function Prototype:destroy()

        if self._view == nil then
            return
        end

        self._view:destroy()
        self._view = nil

    end

    --[[
    - Whether the scoreboard is visible.
    -
    - @return bool
    ]]
    function Prototype:isVisible()
        if self._view == nil then
            return false
        end
        return self._view:isVisible()
    end

    --[[
    -
    ]]
    function Prototype:refreshPlayerList()

        if self._view == nil then
            return
        end

        self._view:getPlayerList():refresh()

    end

    --[[
    - @param player player
    ]]
    function Prototype:addPlayer(player)

        if self._view == nil then
            return
        end

        self._view:getPlayerList():addPlayer(player, true)

    end

    --[[
    - @param player player
    ]]
    function Prototype:removePlayer(player)

        if self._view == nil then
            return
        end

        self._view:getPlayerList():removePlayer(player)

    end

    --[[
    - @return Component
    ]]
    function Prototype:getView()
        return self._view
    end

end)
