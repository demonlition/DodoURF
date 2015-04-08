--[[
Dota PvP game mode
]]

print( "HAM game mode loaded." )

if HAM == nil then
	HAM = {}
	HAM.__index = HAM
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

function Activate()
    GameRules.HAM = HAM()
    GameRules.HAM:InitGameMode()
end

function HAM:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	-- Enable custom buyback cooldown
	GameMode:SetCustomBuybackCooldownEnabled(true)
	ListenToGameEvent('player_connect_full', SetBuyback, self)

	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )

	-- Register Think
	GameMode:SetContextThink( "HAM:GameThink", function() return self:GameThink() end, 0.25 )

	-- Set custom levels/experience
	GameMode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	GameMode:SetCustomHeroMaxLevel(35)
	GameMode:SetUseCustomHeroLevels(true)

	-- Set custom gold income
	GameRules:SetGoldTickTime(0.12)

	-- Enable same hero
	GameRules:SetSameHeroSelectionEnabled(true)
end

function SetBuyback(keys)
	local GameMode = GameRules:GetGameModeEntity()
	local entIndex = keys.index+1
	local player = EntIndexToHScript(entIndex)
	PlayerResource:SetCustomBuybackCooldown(player, 252)
end

function HAM:GameThink()
	return 0.25
end

-- bool HaveAllPlayersJoined()
-- bool IsValidPlayerID(int playerID) 
-- int GetPlayerOwnerID() 
-- int GetPlayerID() 
-- void SetHeroSelectionTime(float time)