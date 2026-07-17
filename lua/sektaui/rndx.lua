--[[
Copyright (c) 2025 Srlion (https://github.com/Srlion)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local bit_band = bit.band
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local math_min = math.min
local math_max = math.max
local DisableClipping = DisableClipping
local type = type

local SHADERS_VERSION = "1781751902"
local SHADERS_GMA = [========[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]========]
do
	local DECODED_SHADERS_GMA = util.Base64Decode(SHADERS_GMA)
	if not DECODED_SHADERS_GMA or #DECODED_SHADERS_GMA == 0 then
		print("Failed to load shaders!") -- this shouldn't happen
		return
	end

	file.Write("rndx_shaders_" .. SHADERS_VERSION .. ".gma", DECODED_SHADERS_GMA)
	game.MountGMA("data/rndx_shaders_" .. SHADERS_VERSION .. ".gma")
end

local function GET_SHADER(name)
	return SHADERS_VERSION:gsub("%.", "_") .. "_" .. name
end

local BLUR_RT = GetRenderTargetEx("RNDX" .. SHADERS_VERSION .. SysTime(),
	1024, 1024,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(2, 256, 4, 8 --[[4, 8 is clamp_s + clamp-t]]),
	0,
	IMAGE_FORMAT_BGRA8888
)

local NEW_FLAG; do
	local flags_n = -1
	function NEW_FLAG()
		flags_n = flags_n + 1
		return 2 ^ flags_n
	end
end

local NO_TL, NO_TR, NO_BL, NO_BR           = NEW_FLAG(), NEW_FLAG(), NEW_FLAG(), NEW_FLAG()

-- Svetov/Jaffies's great idea!
local SHAPE_CIRCLE, SHAPE_FIGMA, SHAPE_IOS = NEW_FLAG(), NEW_FLAG(), NEW_FLAG()

local BLUR                                 = NEW_FLAG()

local RNDX                                 = {}

local shader_mat                           = [==[
screenspace_general
{
	$pixshader ""
	$vertexshader ""

	$basetexture ""
	$texture1    ""
	$texture2    ""
	$texture3    ""

	// Mandatory, don't touch
	$ignorez            1
	$vertexcolor        1
	$vertextransform    1
	"<dx90"
	{
		$no_draw 1
	}

	$copyalpha                 0
	$alpha_blend_color_overlay 0
	$alpha_blend               1 // for AA
	$linearwrite               1 // to disable broken gamma correction for colors
	$linearread_basetexture    1 // to disable broken gamma correction for textures
	$linearread_texture1       1 // to disable broken gamma correction for textures
	$linearread_texture2       1 // to disable broken gamma correction for textures
	$linearread_texture3       1 // to disable broken gamma correction for textures
}
]==]

local MATRIXES                             = {}

local function create_shader_mat(name, opts)
	assert(name and isstring(name), "create_shader_mat: tex must be a string")

	local key_values = util.KeyValuesToTable(shader_mat, false, true)

	if opts then
		for k, v in pairs(opts) do
			key_values[k] = v
		end
	end

	local mat = CreateMaterial(
		"rndx_shaders1" .. name .. SysTime(),
		"screenspace_general",
		key_values
	)

	MATRIXES[mat] = Matrix()

	return mat
end

local ROUNDED_MAT = create_shader_mat("rounded", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})
local ROUNDED_TEXTURE_MAT = create_shader_mat("rounded_texture", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = "loveyoumom", -- if there is no base texture, you can't change it later
})

local BLUR_VERTICAL = "$c0_x"
local ROUNDED_BLUR_MAT = create_shader_mat("blur_horizontal", {
	["$pixshader"] = GET_SHADER("rndx_rounded_blur_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = BLUR_RT:GetName(),
	["$texture1"] = "_rt_FullFrameFB",
})

local SHADOWS_MAT = create_shader_mat("rounded_shadows", {
	["$pixshader"] = GET_SHADER("rndx_shadows_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})

local SHADOWS_BLUR_MAT = create_shader_mat("shadows_blur_horizontal", {
	["$pixshader"] = GET_SHADER("rndx_shadows_blur_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = BLUR_RT:GetName(),
	["$texture1"] = "_rt_FullFrameFB",
})

local SHAPES = {
	[SHAPE_CIRCLE] = 2,
	[SHAPE_FIGMA] = 2.2,
	[SHAPE_IOS] = 4,
}
local DEFAULT_SHAPE = SHAPE_FIGMA
local DEFAULT_BLUR_INTENSITY = 1.0

local MATERIAL_SetTexture = ROUNDED_MAT.SetTexture
local MATERIAL_SetMatrix = ROUNDED_MAT.SetMatrix
local MATERIAL_SetFloat = ROUNDED_MAT.SetFloat
local MATRIX_SetUnpacked = Matrix().SetUnpacked

local MAT
local X, Y, W, H
local TL, TR, BL, BR
local TEXTURE
local USING_BLUR, BLUR_INTENSITY
local COL_R, COL_G, COL_B, COL_A
local SHAPE, OUTLINE_THICKNESS
local START_ANGLE, END_ANGLE, ROTATION
local CLIP_PANEL
local SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY
local function RESET_PARAMS()
	MAT = nil
	X, Y, W, H = 0, 0, 0, 0
	TL, TR, BL, BR = 0, 0, 0, 0
	TEXTURE = nil
	USING_BLUR, BLUR_INTENSITY = false, DEFAULT_BLUR_INTENSITY
	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
	SHAPE, OUTLINE_THICKNESS = SHAPES[DEFAULT_SHAPE], -1
	START_ANGLE, END_ANGLE, ROTATION = 0, 360, 0
	CLIP_PANEL = nil
	SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY = false, 0, 0
end

local normalize_corner_radii; do
	local HUGE = math.huge

	local function nzr(x)
		if x ~= x or x < 0 then return 0 end
		local lim = math_min(W, H)
		if x == HUGE then return lim end
		return x
	end

	local function clamp0(x) return x < 0 and 0 or x end

	function normalize_corner_radii()
		local TL, TR, BL, BR = nzr(TL), nzr(TR), nzr(BL), nzr(BR)

		local k = math_max(
			1,
			(TL + TR) / W,
			(BL + BR) / W,
			(TL + BL) / H,
			(TR + BR) / H
		)

		if k > 1 then
			local inv = 1 / k
			TL, TR, BL, BR = TL * inv, TR * inv, BL * inv, BR * inv
		end

		return clamp0(TL), clamp0(TR), clamp0(BL), clamp0(BR)
	end
end

local function SetupDraw()
	local TL, TR, BL, BR = normalize_corner_radii()

	local start_rad, sweep_rad
	local sweep = END_ANGLE - START_ANGLE
	if sweep >= 360 then
		start_rad, sweep_rad = 0, -1 -- full circle, shader skips arc math
	else
		if sweep < 0 then sweep = sweep + 360 end
		start_rad = (START_ANGLE % 360) * 0.017453292519943295
		sweep_rad = sweep * 0.017453292519943295
	end

	local matrix = MATRIXES[MAT]
	MATRIX_SetUnpacked(
		matrix,

		BL, W, OUTLINE_THICKNESS or -1, sweep_rad,
		BR, H, SHADOW_INTENSITY, ROTATION,
		TR, SHAPE, BLUR_INTENSITY or 1.0, 0,
		TL, TEXTURE and 1 or 0, start_rad, 0
	)
	MATERIAL_SetMatrix(MAT, "$viewprojmat", matrix)

	if COL_R then
		surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A)
	end

	surface_SetMaterial(MAT)
end

local MANUAL_COLOR = NEW_FLAG()
local DEFAULT_DRAW_FLAGS = DEFAULT_SHAPE

local function draw_rounded(x, y, w, h, col, flags, tl, tr, bl, br, texture, thickness)
	if col and col.a == 0 then
		return
	end

	RESET_PARAMS()

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	local using_blur = bit_band(flags, BLUR) ~= 0
	if using_blur then
		return RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	end

	MAT = ROUNDED_MAT; if texture then
		MAT = ROUNDED_TEXTURE_MAT
		MATERIAL_SetTexture(MAT, "$basetexture", texture)
		TEXTURE = texture
	end

	W, H = w, h
	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
	OUTLINE_THICKNESS = thickness

	if bit_band(flags, MANUAL_COLOR) ~= 0 then
		COL_R = nil
	elseif col then
		COL_R, COL_G, COL_B, COL_A = col.r, col.g, col.b, col.a
	else
		COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
	end

	SetupDraw()

	-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
	-- fixes setting $basetexture to ""(none) not working correctly
	return surface_DrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.Draw(r, x, y, w, h, col, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r)
end

function RNDX.DrawOutlined(r, x, y, w, h, col, thickness, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r, nil, thickness or 1)
end

function RNDX.DrawTexture(r, x, y, w, h, col, texture, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r, texture)
end

function RNDX.DrawMaterial(r, x, y, w, h, col, mat, flags)
	local tex = mat:GetTexture("$basetexture")
	if tex then
		return RNDX.DrawTexture(r, x, y, w, h, col, tex, flags)
	end
end

function RNDX.DrawCircle(x, y, r, col, flags)
	return RNDX.Draw(r / 2, x - r / 2, y - r / 2, r, r, col, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleOutlined(x, y, r, col, thickness, flags)
	return RNDX.DrawOutlined(r / 2, x - r / 2, y - r / 2, r, r, col, thickness, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleTexture(x, y, r, col, texture, flags)
	return RNDX.DrawTexture(r / 2, x - r / 2, y - r / 2, r, r, col, texture, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleMaterial(x, y, r, col, mat, flags)
	return RNDX.DrawMaterial(r / 2, x - r / 2, y - r / 2, r, r, col, mat, (flags or 0) + SHAPE_CIRCLE)
end

local USE_SHADOWS_BLUR = false

local function draw_blur()
	if USE_SHADOWS_BLUR then
		MAT = SHADOWS_BLUR_MAT
	else
		MAT = ROUNDED_BLUR_MAT
	end

	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
	SetupDraw()

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 0)
	surface_DrawTexturedRect(X, Y, W, H)

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 1)
	surface_DrawTexturedRect(X, Y, W, H)
end

function RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	RESET_PARAMS()

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	X, Y = x, y
	W, H = w, h
	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
	OUTLINE_THICKNESS = thickness

	draw_blur()
end

local function setup_shadows()
	X = X - SHADOW_SPREAD
	Y = Y - SHADOW_SPREAD
	W = W + (SHADOW_SPREAD * 2)
	H = H + (SHADOW_SPREAD * 2)

	TL = TL + (SHADOW_SPREAD * 2)
	TR = TR + (SHADOW_SPREAD * 2)
	BL = BL + (SHADOW_SPREAD * 2)
	BR = BR + (SHADOW_SPREAD * 2)
end

local function draw_shadows(r, g, b, a)
	if USING_BLUR then
		USE_SHADOWS_BLUR = true
		draw_blur()
		USE_SHADOWS_BLUR = false
	end

	MAT = SHADOWS_MAT

	if r == false then
		COL_R = nil
	else
		COL_R, COL_G, COL_B, COL_A = r, g, b, a
	end

	SetupDraw()
	-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
	-- fixes having no $basetexture causing uv to be broken
	surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.DrawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
	if col and col.a == 0 then
		return
	end

	local OLD_CLIPPING_STATE = DisableClipping(true)

	RESET_PARAMS()

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	X, Y = x, y
	W, H = w, h
	SHADOW_SPREAD = spread or 30
	SHADOW_INTENSITY = intensity or SHADOW_SPREAD * 1.2

	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0

	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]

	OUTLINE_THICKNESS = thickness

	setup_shadows()

	USING_BLUR = bit_band(flags, BLUR) ~= 0

	if bit_band(flags, MANUAL_COLOR) ~= 0 then
		draw_shadows(false, nil, nil, nil)
	elseif col then
		draw_shadows(col.r, col.g, col.b, col.a)
	else
		draw_shadows(0, 0, 0, 255)
	end

	DisableClipping(OLD_CLIPPING_STATE)
end

function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

function RNDX.DrawShadowsOutlined(r, x, y, w, h, col, thickness, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity, thickness or 1)
end

local BASE_FUNCS; BASE_FUNCS = {
	Rad = function(self, rad)
		TL, TR, BL, BR = rad, rad, rad, rad
		return self
	end,
	Radii = function(self, tl, tr, bl, br)
		TL, TR, BL, BR = tl or 0, tr or 0, bl or 0, br or 0
		return self
	end,
	Texture = function(self, texture)
		TEXTURE = texture
		return self
	end,
	Material = function(self, mat)
		local tex = mat:GetTexture("$basetexture")
		if tex then
			TEXTURE = tex
		end
		return self
	end,
	Outline = function(self, thickness)
		OUTLINE_THICKNESS = thickness
		return self
	end,
	Shape = function(self, shape)
		SHAPE = SHAPES[shape] or 2.2
		return self
	end,
	Color = function(self, col_or_r, g, b, a)
		if type(col_or_r) == "number" then
			COL_R, COL_G, COL_B, COL_A = col_or_r, g or 255, b or 255, a or 255
		else
			COL_R, COL_G, COL_B, COL_A = col_or_r.r, col_or_r.g, col_or_r.b, col_or_r.a
		end
		return self
	end,
	Blur = function(self, intensity)
		if not intensity then
			intensity = DEFAULT_BLUR_INTENSITY
		end
		intensity = math_max(intensity, 0)
		USING_BLUR, BLUR_INTENSITY = true, intensity
		return self
	end,
	Rotation = function(self, angle)
		ROTATION = math.rad(angle or 0)
		return self
	end,
	StartAngle = function(self, angle)
		START_ANGLE = angle or 0
		return self
	end,
	EndAngle = function(self, angle)
		END_ANGLE = angle or 360
		return self
	end,
	Shadow = function(self, spread, intensity)
		SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY = true, spread or 30, intensity or (spread or 30) * 1.2
		return self
	end,
	Clip = function(self, pnl)
		CLIP_PANEL = pnl
		return self
	end,
	Flags = function(self, flags)
		flags = flags or 0

		-- Corner flags
		if bit_band(flags, NO_TL) ~= 0 then
			TL = 0
		end
		if bit_band(flags, NO_TR) ~= 0 then
			TR = 0
		end
		if bit_band(flags, NO_BL) ~= 0 then
			BL = 0
		end
		if bit_band(flags, NO_BR) ~= 0 then
			BR = 0
		end

		-- Shape flags
		local shape_flag = bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)
		if shape_flag ~= 0 then
			SHAPE = SHAPES[shape_flag] or SHAPES[DEFAULT_SHAPE]
		end

		-- Blur flag
		if bit_band(flags, BLUR) ~= 0 then
			BASE_FUNCS.Blur(self)
		end

		-- Manual color flag
		if bit_band(flags, MANUAL_COLOR) ~= 0 then
			COL_R = nil
		end

		return self
	end,

}

local RECT = {
	Rad         = BASE_FUNCS.Rad,
	Radii       = BASE_FUNCS.Radii,
	Texture     = BASE_FUNCS.Texture,
	Material    = BASE_FUNCS.Material,
	Outline     = BASE_FUNCS.Outline,
	Shape       = BASE_FUNCS.Shape,
	Color       = BASE_FUNCS.Color,
	Blur        = BASE_FUNCS.Blur,
	Rotation    = BASE_FUNCS.Rotation,
	StartAngle  = BASE_FUNCS.StartAngle,
	EndAngle    = BASE_FUNCS.EndAngle,
	Clip        = BASE_FUNCS.Clip,
	Shadow      = BASE_FUNCS.Shadow,
	Flags       = BASE_FUNCS.Flags,

	Draw        = function(self)
		if END_ANGLE == START_ANGLE then
			return -- nothing to draw
		end

		local OLD_CLIPPING_STATE
		if SHADOW_ENABLED or CLIP_PANEL then
			-- if we are inside a panel, we need to draw outside of it
			OLD_CLIPPING_STATE = DisableClipping(true)
		end

		if CLIP_PANEL then
			local sx, sy = CLIP_PANEL:LocalToScreen(0, 0)
			local sw, sh = CLIP_PANEL:GetSize()
			render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
		end

		if SHADOW_ENABLED then
			setup_shadows()
			draw_shadows(COL_R, COL_G, COL_B, COL_A)
		elseif USING_BLUR then
			draw_blur()
		else
			if TEXTURE then
				MAT = ROUNDED_TEXTURE_MAT
				MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
			end

			SetupDraw()
			surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
		end

		if CLIP_PANEL then
			render.SetScissorRect(0, 0, 0, 0, false)
		end

		if SHADOW_ENABLED or CLIP_PANEL then
			DisableClipping(OLD_CLIPPING_STATE)
		end
	end,

	GetMaterial = function(self)
		if SHADOW_ENABLED or USING_BLUR then
			error("You can't get the material of a shadowed or blurred rectangle!")
		end

		if TEXTURE then
			MAT = ROUNDED_TEXTURE_MAT
			MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
		end
		SetupDraw()

		return MAT
	end,
}

local CIRCLE = {
	Texture = BASE_FUNCS.Texture,
	Material = BASE_FUNCS.Material,
	Outline = BASE_FUNCS.Outline,
	Color = BASE_FUNCS.Color,
	Blur = BASE_FUNCS.Blur,
	Rotation = BASE_FUNCS.Rotation,
	StartAngle = BASE_FUNCS.StartAngle,
	EndAngle = BASE_FUNCS.EndAngle,
	Clip = BASE_FUNCS.Clip,
	Shadow = BASE_FUNCS.Shadow,
	Flags = BASE_FUNCS.Flags,

	Draw = RECT.Draw,
	GetMaterial = RECT.GetMaterial,
}

local TYPES = {
	Rect = function(x, y, w, h)
		RESET_PARAMS()
		MAT = ROUNDED_MAT
		X, Y, W, H = x, y, w, h
		return RECT
	end,
	Circle = function(x, y, r)
		RESET_PARAMS()
		MAT = ROUNDED_MAT
		SHAPE = SHAPES[SHAPE_CIRCLE]
		X, Y, W, H = x - r / 2, y - r / 2, r, r
		r = r / 2
		TL, TR, BL, BR = r, r, r, r
		return CIRCLE
	end
}

setmetatable(RNDX, {
	__call = function()
		return TYPES
	end
})

-- Flags
RNDX.NO_TL = NO_TL
RNDX.NO_TR = NO_TR
RNDX.NO_BL = NO_BL
RNDX.NO_BR = NO_BR

RNDX.SHAPE_CIRCLE = SHAPE_CIRCLE
RNDX.SHAPE_FIGMA = SHAPE_FIGMA
RNDX.SHAPE_IOS = SHAPE_IOS

RNDX.BLUR = BLUR
RNDX.MANUAL_COLOR = MANUAL_COLOR

function RNDX.SetFlag(flags, flag, bool)
	flag = RNDX[flag] or flag
	if tobool(bool) then
		return bit.bor(flags, flag)
	else
		return bit.band(flags, bit.bnot(flag))
	end
end

function RNDX.SetDefaultShape(shape)
	DEFAULT_SHAPE = shape or SHAPE_FIGMA
	DEFAULT_DRAW_FLAGS = DEFAULT_SHAPE
end

function RNDX.SetDefaultBlurIntensity(val)
	DEFAULT_BLUR_INTENSITY = math_max(0, tonumber(val) or 1.0)
end

function RNDX.GetDefaultBlurIntensity()
	return DEFAULT_BLUR_INTENSITY
end

SektaUI.RNDX = RNDX
