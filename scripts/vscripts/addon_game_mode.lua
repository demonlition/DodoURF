--[[
Dota PvP game mode
]]

print( "HAM game mode loaded." )

if DotaPvP == nil then
	DotaPvP = class({})
end

XP_PER_LEVEL_TABLE = {
     0, -- 1
  200, -- 2
  400, -- 3
  900, -- 4
  1400, -- 5
 2000, -- 6
 2600, -- 7
 3200, -- 8
 4400, -- 9
 5400, -- 10
 6000, -- 11
 8200, -- 12
 9000, -- 13
 10400, -- 14
 11900, -- 15
 13500, -- 16
 15200, -- 17
 17000, -- 18
 18900, -- 19
20900, -- 20
23000, -- 21
25200, -- 22
27500, -- 23
29900, -- 24
32400,  -- 25
35000, -- 26
37700, -- 27
40500, -- 28
43400, -- 29
46400, -- 30
49500, -- 31
52700, -- 32
56000, -- 33
59400, -- 34
62900 -- 35
}

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.DotaPvP = DotaPvP()
    GameRules.DotaPvP:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function DotaPvP:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )

	-- Register Think
	GameMode:SetContextThink( "DotaPvP:GameThink", function() return self:GameThink() end, 0.25 )

	-- Set custom levels/experience
	GameMode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	GameMode:SetCustomHeroMaxLevel(35)
	GameMode:SetUseCustomHeroLevels(true)

	-- Set custom gold income
	GameRules:SetGoldTickTime(0.12)
end

--------------------------------------------------------------------------------
function DotaPvP:GameThink()
	return 0.25
end
