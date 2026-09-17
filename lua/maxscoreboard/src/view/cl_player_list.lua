local Addon = MaxScoreboard

local Component = Addon.Component
local Components = Addon.Components

----------------------------------------------------------------

--[[
- PlayerList component
]]
Components.PlayerList = Component:extend(Components.PlayerList, function(Class, Prototype)

    --[[
    - @var string
    ]]
    Class._panelClass = 'DScrollPanel'

    --[[
    - @var player[]
    ]]
    Prototype._playerSorted = nil

    --[[
    - @var string
    ]]
    Prototype._filter = ""

    --[[
    - @var Component[]
    ]]
    Prototype.rows = nil

    --[[
    - @var Component
    ]]
    Prototype.canvas = nil

    --[[
    - @var Component
    ]]
    Prototype.scrollbar = nil

    --[[
    - @param panel panel
    - @param player player
    ]]
    function Prototype:__construct(panel)

        self._playerSorted = {}
        self.rows = {}

        self.__parent.__construct(self, panel)
    end

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)
        self.__parent:init(panel)

        self.canvas = Component:apply(panel:GetCanvas())
        self.scrollbar = Component:apply(panel:GetVBar())

        self:override('Paint', self.p_paint)

        self:initScrollbar(self.scrollbar:getPanel())

    end

    --[[
    - Refreshes the whole players list.
    ]]
    function Prototype:refresh()
        self:sortPlayers()
        self:filterPlayers()
        self:refreshView()
    end

    --[[
    - Refereshes the rendered list.
    ]]
    function Prototype:refreshView()

        -- Readd all players in order
        for index, player in ipairs(self._playerSorted) do
            self.rows[player]:setParent(nil)
            self._panel:AddItem(self.rows[player]:getPanel())
        end

        -- Rebuild the list..
        self._panel:Rebuild()

    end

    --[[
    - Sorts the players.
    ]]
    function Prototype:sortPlayers()
        local client = LocalPlayer()

        table.sort(self._playerSorted, function(a, b)

            -- client row at the top
            if a == client or b == client then
                return a == client
            end

            if a:Team() == b:Team() then
                return a:Nick() < b:Nick()
            end

            return team.GetName(a:Team()) < team.GetName(b:Team())
        end)

    end

    --[[
    - Filters the player rows.
    - This sets each row visible/invisible based on the filter.
    ]]
    function Prototype:filterPlayers()

        if self._filter == "" then

            -- Simply set all rows visible
            for player, row in pairs(self.rows) do
                row:setVisible(true)
            end

        else
            local filter = string.lower(self._filter)
            local filterType = string.sub(filter, 1, (string.find(filter, ':') or 1) - 1)
            local text = string.sub(filter, #filterType == 0 and 1 or #filterType + 2)

            for player, row in pairs(self.rows) do
                local filterValue

                -- Role
                if filterType == 'role' or filterType == 'job' then
                    filterValue = string.lower(team.GetName(player:Team()))

                -- Usergroup
                elseif filterType == 'group' then
                    filterValue = string.lower(player:GetUserGroup())

                -- SteamID
                elseif filterType == 'steamid' then
                    filterValue = string.lower(player:SteamID())

                -- SteamID64
                elseif filterType == 'steamid64' then
                    filterValue = string.lower(player:SteamID64())

                -- Steamname
                elseif filterType == 'steamname' then
                    filterValue = string.lower(player:SteamName())

                -- Nick
                else
                    filterValue = string.lower(player:Nick())
                end

                -- Set the row visible when it matches
                row:setVisible(string.find(filterValue, text) ~= nil)

            end

        end

    end

    --[[
    - Adds a player to the scoreboard.
    -
    - @param player player
    - @param bool refresh - Whether to refresh the list.
    ]]
    function Prototype:addPlayer(player, refresh)

        if self.rows[player] ~= nil then
            return
        end

        self.rows[player] = Components.PlayerRow:create(self.canvas, player)
        table.insert(self._playerSorted, player)

        if refresh == true then
            self:refresh()
        end

    end

    --[[
    - Adds multiple players to the scoreboard.
    -
    - @param player[] players
    - @param bool refresh - Whether to refresh the list.
    ]]
    function Prototype:addPlayers(players, refresh)

        for _, player in ipairs(players) do
            self:addPlayer(player, false)
        end

        if refresh == true then
            self:refresh()
        end

    end

    --[[
    - Removes a player from the scoreboard.
    -
    - @param player player
    ]]
    function Prototype:removePlayer(player)

        if self.rows[player] == nil then
            return
        end

        self.rows[player]:destroy()
        self.rows[player] = nil

        table.RemoveByValue(self._playerSorted, player)

    end

    --[[
    - @param string filter
    ]]
    function Prototype:setFilter(filter)
        self._filter = filter
    end

    --------------------------------------------------
    -- Scrollbar

    --[[
    - @param panel panel
    ]]
    function Prototype:initScrollbar(panel)

        panel.btnUp:SetVisible(false)
        panel.btnDown:SetVisible(false)

        self:override(panel, 'PerformLayout', self.p_scroll_performLayout)
        self:override(panel, 'Paint', self.p_scroll_paint)
        self:override(panel, 'PaintOver', self.p_scroll_paintOver)
        self:override(panel.btnGrip, 'Paint', self.p_scroll_grip_paint)

    end

    --[[ ]]
    function Prototype:p_scroll_performLayout(panel, w, h)

        panel:SetWide(8)

    	local scroll = panel:GetScroll() / panel.CanvasSize
    	local barSize = math.max(panel:BarScale() * panel:GetTall(), panel:GetWide())
    	local track = panel:GetTall() - barSize + 1

    	panel.btnGrip:SetPos(0, scroll * track)
    	panel.btnGrip:SetSize(w, barSize)

    end

    --[[ ]]
    function Prototype:p_scroll_paint(panel, w, h)

    end

    --[[ ]]
    function Prototype:p_scroll_paintOver(panel, w, h)

        -- Border
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, 1, h)

    end

    --[[ ]]
    function Prototype:p_scroll_grip_paint(panel, w, h)
        surface.SetDrawColor(0, 0, 0, 140)
        surface.DrawRect(0, 0, w, h)
    end

end)
