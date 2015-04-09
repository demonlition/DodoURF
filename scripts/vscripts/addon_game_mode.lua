print("Going ham.")

if HAM == nil then
	HAM = class({})
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
	32400, -- 25
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
    GameRules.AddonTemplate = HAM()
    GameRules.AddonTemplate:InitGameMode()
end

function HAM:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	-- Set thinker
	GameMode:SetThink("OnThink", self, "GlobalThink", 1)

	-- Set listener
	-- ListenToGameEvent("entity_killed", Dynamic_Wrap(HAM, "OnEntityKilled"), self)

	-- Enable backdoor protection
	GameMode:SetTowerBackdoorProtectionEnabled(true)

	-- Enable custom buyback cooldown
	GameMode:SetCustomBuybackCooldownEnabled(true)

	-- Set custom levels/experience
	GameMode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	GameMode:SetCustomHeroMaxLevel(35)
	GameMode:SetUseCustomHeroLevels(true)

	-- Set gold income
	GameRules:SetGoldTickTime(0.12)

	-- Enable same hero selection
	GameRules:SetSameHeroSelectionEnabled(true)
	
	-- Set hero selection time
	GameRules:SetHeroSelectionTime(90)
end

function HAM:OnThink()
	return 1
end

-- function HAM:OnEntityKilled(keys)
-- 	local killedUnit = EntIndexToHScript(keys.entindex_killed)
-- 	if killedUnit:IsRealHero() then
-- 		PlayerResource:SetCustomBuybackCooldown(killedUnit:GetPlayerID(), 252)
--     end
-- end