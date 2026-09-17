local Addon = MaxScoreboard

local class = Addon.class

----------------------------------------------------------------

Addon.Components = Addon.Components or {}

--[[
- @class Component
]]
Addon.Component = class(nil, Addon.Component, function(Class, Prototype)

    --[[
    - @var string
    ]]
    Class._panelClass = 'Panel'

    --[[
    - @var panel
    ]]
    Prototype._panel = nil

    --[[
    - @var table
    ]]
    Prototype._handlers = nil

    --[[
    - @private
    - @param panel panel
    ]]
    function Prototype:__construct(panel)

        self._panel = panel
        self._panel._view = self

        self._handlers = {}

        self:init(panel)

    end

    --[[
    - @protected
    - @param panel panel
    ]]
    function Prototype:init(panel)

    end

    --------------------------------------------------
    -- Panel functions

    --[[ ]]
    function Prototype:p_paint(panel, w, h)

    end

    --------------------------------------------------
    -- Handy functions

    --[[
    - Overrides a panel property.
    -
    - @param panel|string property
    - @param string|any property
    - @param any|nil value
    ]]
    function Prototype:override(panel, name, value)

        if type(panel) == 'string' then
            panel, name, value = self._panel, panel, name
        end

        if not ispanel(panel) then
            panel = panel:getPanel()
        end

        if type(value) == 'function' then

            panel[name] = function(...)
                value(self, ...)
            end

        else
            panel[name] = value
        end

    end

    --[[
    - @return table
    ]]
    function Prototype:getPanelControlTable()
        return vgui.GetControlTable(self._panel:GetName())
    end

    --[[
    - Calls an function of the panel control.
    -
    - @param string name
    - @param ...
    -
    - @return any
    ]]
    function Prototype:panelControlCall(name, ...)
        return self:getPanelControlTable()[name](self._panel, ...)
    end

    --------------------------------------------------
    -- Listener

    --[[
    - Triggers all 'event' handlers.
    -
    - @param string name
    - @param ...
    ]]
    function Prototype:trigger(name, ...)
        for _, handler in ipairs(self._handlers[name] or {}) do
            handler(self, ...)
        end
    end

    --[[
    - Listens for an 'event' to be triggered.
    -
    - @param Component|string component
    - @param string|function name
    - @param function|nil handler
    ]]
    function Prototype:listen(component, name, handler)

        if type(component) == 'string' then
            component, name, handler = self, component, name
        end

        if component ~= self then

            -- the current self as self in the handler
            local _handler = handler
            handler = function(_, ...)
                _handler(self, ...)
            end

        end

        component._handlers[name] = component._handlers[name] or {}
        table.insert(component._handlers[name], handler)

    end

    --------------------------------------------------
    -- Shortcuts

    --[[
    -
    ]]
    function Prototype:destroy()
        self:trigger('onDestroyed')
        self._panel:Remove()
    end

    --[[
    -
    ]]
    function Prototype:onDestroyed()

    end

    --[[
    - Sets the panel visible or invisible.
    -
    - @param bool visible
    ]]
    function Prototype:setVisible(visible)
        self._panel:SetVisible(visible)

        if visible == true then
            self:trigger('onShown')
        else
            self:trigger('onHidden')
        end

    end

    --[[
    - Whether the panel is visible.
    -
    - @return bool
    ]]
    function Prototype:isVisible()
        return self._panel:IsVisible()
    end

    --[[
    - Get the parent's view.
    -
    - @return Component|nil
    ]]
    function Prototype:getParent()
        local parentPanel = self._panel:GetParent()

        if parentPanel == nil then
            return nil
        end

        return parentPanel._view
    end

    --[[
    - Set the view's parent.
    -
    - @param Component parent
    ]]
    function Prototype:setParent(parent)
        self._panel:SetParent(parent and parent:getPanel() or nil)
        -- Don't have to add as a child to the parent's panel, since the panel:SetParent already does that..
    end
    
    --[[
    - Get the children's view.
    -
    - @return Component[]
    ]]
    function Prototype:getChildren()
        local children = {}

        for _, childPanel in ipairs(self._panel:GetChildren()) do
            children[#children + 1] = childPanel._view
        end

        return children
    end

    --------------------------------------------------

    --[[
    - @return panel
    ]]
    function Prototype:getPanel()
        return self._panel
    end

    --------------------------------------------------

    --[[
    - @return string
    ]]
    function Class:getPanelClass()
        return self._panelClass
    end

    --[[
    - @final
    - @param Component|nil parent
    - @param ...
    -
    - @return Component
    ]]
    function Class:create(parent, ...)
        return self:createNamed(self:getPanelClass(), parent, ...)
    end

    --[[
    - @final
    - @param string name
    - @param Component|nil parent
    - @param ...
    -
    - @return Component
    ]]
    function Class:createNamed(name, parent, ...)

        if parent ~= nil then
            parent = parent:getPanel()
        end

        local panel = vgui.Create(name, parent)
        return self:apply(panel, ...)
    end

    --[[
    - @final
    - @param panel panel
    - @param ...
    -
    - @return Component
    ]]
    function Class:apply(panel, ...)
        return self:new(panel, ...)
    end

    --[[
    - @final
    - @param table|function table
    - @param function|nil callback
    ]]
    function Class:extend(table, callback)
        return class(self, table, callback)
    end

end)
