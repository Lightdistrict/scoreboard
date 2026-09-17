local Addon = StudioNetworkScoreboard
 
----------------------------------------------------------------

local render_SetScissorRect = render.SetScissorRect
local render_SetMaterial = render.SetMaterial
local render_DrawScreenQuad = render.DrawScreenQuad

----------------------------------------------------------------

local BLUR_AMOUNT = 6
local BLUR_HEAVYNESS = 3

local MATERIAL_BLUR = Material('pp/blurscreen')
local MATERIAL_PANEL_BLUR = Material('pp/blurscreen')

--[[
- Draw a blured rectangle on the screen.
- @arg number x
- @arg number y
- @arg number w
- @arg number h
]]
function Addon.drawBluredRect(x, y, w, h)

	render.SetScissorRect(x, y, x + w, y + h, true)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(MATERIAL_BLUR)

		for i=1, BLUR_HEAVYNESS do
			MATERIAL_BLUR:SetFloat('$blur', (i / 3) * BLUR_AMOUNT)
			MATERIAL_BLUR:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		end

	render.SetScissorRect(0, 0, 0, 0, false)

end
local drawBluredRect = Addon.drawBluredRect

--[[
- Draws a blured rectangle over the whole panel.
-
- @arg panel panel
]]
function Addon.drawBluredPanel(panel)
    local x, y = panel:LocalToScreen(0, 0)
    local w, h = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(MATERIAL_PANEL_BLUR)

	for i=1, BLUR_HEAVYNESS do
		MATERIAL_PANEL_BLUR:SetFloat('$blur', (i / 3) * BLUR_AMOUNT)
		MATERIAL_PANEL_BLUR:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(-x, -y, w, h)

	end

end

--[[
-
]]
function Addon.getWebMaterial(name)
	return Addon._webMaterialCache[name]
end
