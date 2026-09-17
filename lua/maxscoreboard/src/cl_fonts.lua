local Addon = MaxScoreboard

local identifier = Addon.identifier

----------------------------------------------------------------

--[[
- @param string name
- @param table|nil options
-
- @return string - Returns the full (prefixed) name of the font
]]
function Addon.font(name, options)
    name = identifier .. '.' .. name

    if options ~= nil then
        surface.CreateFont(name, options)
    end

    return name
end
local font = Addon.font

----------------------------------------------------------------

font('small', {
    font = 'Roboto',
    size = 14,
    weight = 300,
    antialias = true
})

font('small.underline', {
    font = 'Roboto',
    size = 14,
    weight = 300,
    antialias = true
	-- underline = true
})

font('footer', {
    font = 'Roboto',
    size = 14,
    weight = 300,
    antialias = true
})

-- "Montserrat" is the bundled font's internal family name (resource/fonts/montserrat-regular.ttf,
-- force-downloaded to clients via resource.AddFile in src/sv_misc.lua) -- not a stock GMod font.
font('title', {
    font = 'Montserrat',
    size = 44,
    antialias = true
})
