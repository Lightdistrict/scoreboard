local Addon = MaxScoreboard

local Component = Addon.Component
local Components = Addon.Components

----------------------------------------------------------------

local font = Addon.font

----------------------------------------------------------------

local ICON_PIN = Material('scoreboard/icons/pin.png', 'noclamp smooth')

local COLOR_WHITE = Color(255, 255, 255)
local COLOR_LIGHT_GREY = Color(200, 200, 200)

local FONT_SMALL = font('small')
local FONT_FOOTER = font('footer')
local FONT_TITLE = font('title')

----------------------------------------------------------------

local enableScreenClicker = function()
    gui.EnableScreenClicker(true)
end

local disableScreenClicker = function()
    gui.EnableScreenClicker(false)
end

----------------------------------------------------------------

local Frame

----------------------------------------------------------------

--[[
- Scoreboard component
]]
Components.Scoreboard = Component:extend(Components.Scoreboard, function(Class, Prototype)

    --[[
    - @var string
    ]]
    Class._panelClass = 'EditablePanel'

    --[[
    - @var bool
    ]]
    Prototype._pinned = false

    --[[
    - @var Component
    ]]
    Prototype.frame = nil

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)
        self.__parent:init(panel)

        panel:SetSize(ScrW(), ScrH())

        panel:MakePopup()
        panel:SetMouseInputEnabled(true)
        panel:SetKeyboardInputEnabled(false)

        self:override('Think', self.p_think)
        self:override('PerformLayout', self.p_performLayout)
        self:override('Paint', self.p_paint)
        self:override('PaintOver', self.p_paintOver)

        --------------------------------------------------
        -- Children

        self.frame = Frame:create(self)

        --------------------------------------------------
        -- Events

        -- Enable the mouse..
        gui.EnableScreenClicker(true)
        self:listen('onShown', enableScreenClicker)

        -- Disable the mouse..
        self:listen('onHidden', disableScreenClicker)
        self:listen('onDestroyed', disableScreenClicker)

    end

    --[[ ]]
    function Prototype:pin()
        self._pinned = true

        self:getPanel():SetKeyboardInputEnabled(true)

        self:trigger('onPin')
    end

    --[[ ]]
    function Prototype:unpin()
        self._pinned = false

        self:getPanel():SetKeyboardInputEnabled(false)

        self:trigger('onUnpin')
    end

    --[[ ]]
    function Prototype:togglePin()
        if self._pinned then
            self:unpin()
        else
            self:pin()
        end
    end

    --[[
    - @return bool
    ]]
    function Prototype:isPinned()
        return self._pinned
    end

    --[[
    - @return Component
    ]]
    function Prototype:getPlayerList()
        return self.frame.content.playerList
    end

    --[[ ]]
    function Prototype:p_think(panel)

        -- Fix for when pinnen and tab is pressed (which will not register if released)
        if self._pinned == false and input.IsKeyDown(KEY_TAB) == false then
            Addon.scoreboard():hide()
        end

    end

    --[[ ]]
    function Prototype:p_performLayout(panel, w, h)

        local p_frame = self.frame:getPanel()

        local scrW, scrH = ScrW(), ScrH()

        p_frame:SetSize(scrW * .8, scrH - 200)
        p_frame:SetPos(scrW * .5 - scrW * (.8 * .5), 100)

    end

    --[[ ]]
    function Prototype:p_paint(panel, w, h)

    end

    --[[ ]]
    function Prototype:p_paintOver(panel, w, h)

    end

end)

----------------------------------------------------------------

local Header, Content, Footer

----------------------------------------------------------------

--[[
- Frame component
]]
Frame = Component:extend(function(Class, Prototype)

    --[[
    - @var Component
    ]]
    Prototype.header = nil

    --[[
    - @var Component
    ]]
    Prototype.content = nil

    --[[
    - @var Component
    ]]
    Prototype.footer = nil

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)
        self.__parent:init(panel)

        self:override('Think', self.p_think)
        self:override('PerformLayout', self.p_performLayout)
        self:override('Paint', self.p_paint)
        self:override('PaintOver', self.p_paintOver)

        --------------------------------------------------
        -- Children

        self.header = Header:create(self)
        self.content = Content:create(self)
        self.footer = Footer:create(self)

    end

    --[[
    - @return bool
    ]]
    function Prototype:isPinned()
        return self._pinned
    end

    --[[ ]]
    function Prototype:p_think(panel)

        -- Fix for when pinnen and tab is pressed (which will not register if released)
        if self._pinned == false and input.IsKeyDown(KEY_TAB) == false then
            Addon.scoreboard():hide()
        end

    end

    --[[ ]]
    function Prototype:p_performLayout(panel, w, h)

        local p_header = self.header:getPanel()
        local p_content = self.content:getPanel()
        local p_footer = self.footer:getPanel()

        p_header:SetWide(w)
        p_header:SetPos(0, 0)

        p_footer:SetWide(w)
        p_footer:SetPos(0, h - p_footer:GetTall())

        p_content:SetSize(w, h - p_header:GetTall() - p_footer:GetTall())
        p_content:SetPos(0, p_header:GetTall())

    end

    --[[ ]]
    function Prototype:p_paint(panel, w, h)

        surface.SetDrawColor(255, 255, 255)

        -- Background
        draw.DrawBlurPanel( panel )
        surface.SetDrawColor(36, 34, 53, 200)
        surface.DrawRect(0, 0, w, h)
        draw.OutlinedBox( 0, 0, w, h, 1, Color( 0, 0, 0 ) )

    end

    --[[ ]]
    function Prototype:p_paintOver(panel, w, h)

        -- Border
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawOutlinedRect(0, -1, w, h + 1)

    end

end)

--[[
- Header component
]]
Header = Component:extend(function(Class, Prototype)

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)
        self.__parent:init(panel)

        panel:SetTall(134)                                              

        self:override('Paint', self.p_paint)

    end

    --[[ ]]
    function Prototype:p_paint(panel, w, h)

        surface.SetDrawColor(0, 0, 0, 160)
        surface.DrawRect(0, 0, w, h)

        draw.SimpleText(Addon.config.communityName or "MY COMMUNITY", FONT_TITLE,
            w * .5, h * .5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end

end)

--[[
- Content component
]]
Content = Component:extend(function(Class, Prototype)

    --[[
    - @var Component
    ]]
    Prototype.playerList = nil

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)
        self.__parent:init(panel)

        panel:SetTall(30)

        self:override('PerformLayout', self.p_performLayout)
        self:override('Paint', self.p_paint)
        self:override('PaintOver', self.p_paintOver)

        --------------------------------------------------
        -- Children

        self.playerList = Components.PlayerList:create(self)

    end

    --[[ ]]
    function Prototype:p_performLayout(panel, w, h)

        local p_playerList = self.playerList:getPanel()

        p_playerList:SetPos(9, 1)
        p_playerList:SetSize(w - 18, h - 2)

    end

    --[[ ]]
    function Prototype:p_paint(panel, w, h)

        surface.SetDrawColor(0, 0, 0, 160)

        surface.DrawRect(0, 0, 8, h)
        surface.DrawRect(w - 8, 0, 8, h)

    end

    --[[ ]]
    function Prototype:p_paintOver(panel, w, h)

        -- Border
        surface.SetDrawColor(0, 0, 0, 240)
        surface.DrawOutlinedRect(8, 0, w - 16, h)

    end

end)

--[[
- Footer component
]]
Footer = Component:extend(function(Class, Prototype)

    --[[
    - Component
    ]]
    Prototype.pinButton = nil

    --[[
    - Component
    ]]
    Prototype.searchInput = nil

    --[[
    - @inheritdoc
    ]]
    function Prototype:init(panel)
        self.__parent:init(panel)

        self.pinButton = Component:createNamed('DButton', self)
        self.searchInput = Component:createNamed('DTextEntry', self)

        self.pinButton:getPanel():SetText("")
        self.pinButton:getPanel():SetSize(20, 20)

        self.searchInput:setVisible(false)
        self.searchInput:getPanel():SetUpdateOnType(true)
        self.searchInput:getPanel():SetSize(0, 0)

        self:override('PerformLayout', self.p_performLayout)
        self:override('Paint', self.p_paint)
        self:override('Think', self.p_think)

        self:override(self.pinButton, 'DoClick', self.p_pinButton_doClick)
        self:override(self.pinButton, 'Paint', self.p_pinButton_paint)

        self:override(self.searchInput, 'OnValueChange', self.p_searchInput_onValueChange)
        self:override(self.searchInput, 'OnKeyCodeTyped', self.p_searchInput_onKeyCodeTyped)
        self:override(self.searchInput, 'Think', self.p_searchInput_think)

        self:listen(self:getParent():getParent(), 'onPin', self.event_parent_onPin)
        self:listen(self:getParent():getParent(), 'onUnpin', self.event_parent_onUnpin)

    end

    --[[ ]]
    function Prototype:event_parent_onPin()
        self.searchInput:setVisible(true)
    end

    --[[ ]]
    function Prototype:event_parent_onUnpin()
        self.searchInput:setVisible(false)

        local panel = self.searchInput:getPanel()
        panel:SetText("")
        panel:OnValueChange(panel:GetText()) -- SetValue does not call OnValueChange..

    end

    --[[ ]]
    function Prototype:p_performLayout(panel, w, h)
        local p_pinButton = self.pinButton:getPanel()

        p_pinButton:SetPos(w - p_pinButton:GetWide() - 2, h - p_pinButton:GetTall() - 2)

    end

    --[[ ]]
    function Prototype:p_paint(panel, w, h)

        surface.SetDrawColor(0, 0, 0, 160)
        surface.DrawRect(0, 0, w, h)

        local playerCount = #player.GetAll()

        draw.SimpleText("There's currently " .. playerCount .. " players online", FONT_FOOTER,
            10, h * .5, Color(140, 140, 140, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if self.searchInput:getPanel():GetText() ~= "" then
            draw.SimpleText("search: " .. self.searchInput:getPanel():GetText(), FONT_FOOTER,
                w * .75, h * .5, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif self:getParent():isPinned() then
            draw.SimpleText("type to search..", FONT_FOOTER,
                w * .75, h * .5, Color(140, 140, 140, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

    end

    --------------------------------------------------
    -- Pin button

    --[[ ]]
    function Prototype:p_pinButton_doClick(panel)
        self:getParent():getParent():togglePin()
    end

    --[[ ]]
    function Prototype:p_pinButton_paint(panel, w, h)

        if self:getParent():getParent():isPinned() then
            surface.SetDrawColor(Color(255, 255, 255, 100))
        else
            surface.SetDrawColor(Color(140, 140, 140, 100))
        end

        surface.SetMaterial(ICON_PIN)
        surface.DrawTexturedRect(w * .5 - 6, h * .5 - 6, 12, 12)

    end

    --------------------------------------------------
    -- Search input

    --[[ ]]
    function Prototype:p_searchInput_onValueChange(panel, value)
        value = string.Trim(value)

        if #value > 40 then
            value = string.sub(value, 1, 40)
        end

        local caretPos = panel:GetCaretPos()
        panel:SetText(value)
        panel:SetCaretPos(math.Clamp(caretPos, 0, #value))

        local playerList = self:getParent():getParent():getPlayerList()

        playerList:setFilter(value)
        playerList:filterPlayers()
        playerList:refreshView()

    end


    --[[ ]]
    function Prototype:p_searchInput_onKeyCodeTyped(panel, keyCode)

        if keyCode == KEY_ENTER then
            panel:SetText("")
            panel:OnValueChange(panel:GetText()) -- SetValue does not call OnValueChange..
        end

    end

    --[[ ]]
    function Prototype:p_searchInput_think(panel)
        self.searchInput:getPanel():RequestFocus()
    end

end)
