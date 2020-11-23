local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Farmex = E:NewModule('ElvUI Farmex', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

Farmex.version = GetAddOnMetadata("ElvUI_Farmex", "Version")
Farmex.title = format('|cff00c0fa%s|r',"Farmex")

function Farmex:FOption(name)
	local color = '|cff00c0fa%s|r'
	return (color):format(name)
end

function Farmex:unpackColor(color)
	return color.r, color.g, color.b, color.a
end

--Default options
P["Farmex"] = {
	['minimapSize'] = 300,
	['minimapX'] = 0,
	['minimapY'] = 400,
	['minimapPositionPoint'] = "CENTER",
	['minimapPositionAttachTo'] = "UIParent",
}

-- misc
local farm = false
local minimapSize, miniMoverSize = 0, 0
local minimapPosition

-- keybinds
BINDING_HEADER_FARMEX				= "ElvUI Farmex"
BINDING_NAME_FARMEX_TOGGLE		= "Toggle Farm Mode"

-------------------------------------------------------------------------------
-- Keybind/Slash command goodness
-------------------------------------------------------------------------------
function Farmex_Toggle()
	if not farm then
		minimapSize = Minimap:GetWidth()
		minimapPosition = Minimap:GetPoint()
		
		-- resize minimapmover too, if it exists
		if MinimapMover then
			miniMoverSize = MinimapMover:GetWidth()
			MinimapMover:SetSize(E.db.Farmex.minimapSize, E.db.Farmex.minimapSize)
		end
		
		Minimap:SetSize(E.db.Farmex.minimapSize, E.db.Farmex.minimapSize)
		Minimap:ClearAllPoints()
		Minimap:SetPoint(E.db.Farmex.minimapPositionPoint, E.db.Farmex.minimapPositionAttachTo, E.db.Farmex.minimapX, E.db.Farmex.minimapY)
		farm = true
	else
		if MinimapMover then
			MinimapMover:SetSize(miniMoverSize, miniMoverSize)
		end
		Minimap:SetSize(minimapSize, minimapSize)
		Minimap:SetPoint(minimapPosition)
		farm = false
	end
	
	if AurasMover and (E.Movers and not E.Movers["AurasMover"] or not E.Movers) then
		AurasMover:ClearAllPoints()
		AurasMover:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", E.Scale(-8), E.Scale(2))
	end
end


--This function inserts our GUI table into the ElvUI Config. You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function Farmex:InsertOptions()
	E.Options.args.Farmex = {
		order = 400,
		type = "group",
		name = Farmex.title,
		childGroups = "tab",
		args = {
			FarmexHeader = {
				order = 1,
				type = "header",
				name = format("%s version %s by Valixx", Farmex.title, Farmex:FOption(Farmex.version)),
			},
			FarmexHeader2 = {
				order = 2,
				type = "header",
				name = format("%s is an addon to enlarge and reposition the minimap for farming.", Farmex.title),
			},
			FarmexSpacer1 = {
				order = 3,
				type = "description",
				name = "\n",
			},
			info = {
				order = 200,
				type = "group",
				name = "Minimap Settings",
				args = {
					keybind	= {
						type	= "keybinding",
						order	= 1,
						name	= BINDING_NAME_FARMEX_TOGGLE,
						desc	= "You may also use |cff69ccf0/farm|r command for this action.",
						get		= function() return GetBindingKey("FARMEX_TOGGLE") end,
						set		= function(_, value) SetBinding(value, "FARMEX_TOGGLE"); SaveBindings(GetCurrentBindingSet()) end,
					},
					minimapSize	= {
						type	= "range",
						order	= 2,
						name	= "Minimap Size",
						desc	= "Size of the minimap while in farm mode.",
						get		= function() return E.db.Farmex.minimapSize end,
						set		= function(_, value) E.db.Farmex.minimapSize = value end,
						min = 100, max = 1000, step = 10
					},
					FarmexSpacer1 = {
						order = 3,
						type = "description",
						name = "\n",
					},
					-- minimapPositionPointSettings	= {
					-- 	type	= "select",
					-- 	order	= 4,
					-- 	name	= "Minimap Anchor Position",
					-- 	desc	= "Select the anchor point for the minimap while in farm mode.",
					-- 	get		= function() return E.db.Farmex.minimapPositionPoint end,
					-- 	set		= function(_, value) E.db.Farmex.minimapPositionPoint = value end,
					-- 	values = {
					-- 		TOPL		= "TOPLEFT",
					-- 		TOP			= "TOP",
					-- 		TOPR 		= "TOPRIGHT",
					-- 		RIGHT 	= "RIGHT",
					-- 		CENTER 	= "CENTER",
					-- 		LEFT		= "LEFT",
					-- 		BOTR		= "BOTTOMRIGHT",
					-- 		BOT			= "BOTTOM",
					-- 		BOTL		= "BOTTOMLEFT"
					-- 	}
					-- },
					minimapPositionXSettings	= {
						type	= "range",
						order	= 5,
						name	= "Minimap X Position",
						desc	= "Change the position of the minimap while in farm mode.",
						get		= function() return E.db.Farmex.minimapX end,
						set		= function(_, value) E.db.Farmex.minimapX = value end,
						min = 0, max = 500, step = 1
					},
					minimapPositionYSettings	= {
						type	= "range",
						order	= 6,
						name	= "Minimap Y Position",
						desc	= "Change the position of the minimap while in farm mode.",
						get		= function() return E.db.Farmex.minimapY end,
						set		= function(_, value) E.db.Farmex.minimapY = value end,
						min = 0, max = 500, step = 1
					},
				},
			},
		},
	}
end

function Farmex:Initialize()
	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, Farmex.InsertOptions)
	-- chat command
	E:RegisterChatCommand("farm", Farmex_Toggle)
end

E:RegisterModule(Farmex:GetName()) --Register the module with ElvUI. ElvUI will now call Farmex:Initialize() when ElvUI is ready to load our plugin.