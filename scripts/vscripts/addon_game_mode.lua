print("Going ham.")

if HAM == nil then
	HAM = class({})
end

XP_PER_LEVEL_TABLE = {
	0, -- 1
	180, -- 2
	360, -- 3
	810, -- 4
	1260, -- 5
	1800, -- 6
	2340, -- 7
	2880, -- 8
	3960, -- 9
	4860, -- 10
	5400, -- 11
	7380, -- 12
	8100, -- 13
	9360, -- 14
	10710, -- 15
	12150, -- 16
	13680, -- 17
	15300, -- 18
	17010, -- 19
	18810, -- 20
	20700, -- 21
	22680, -- 22
	24750, -- 23
	26910, -- 24
	29160, -- 25
	31500, -- 26
	33930, -- 27
	36450, -- 28
	39060, -- 29
	41760, -- 30
	44550, -- 31
	47430, -- 32
	50400, -- 33
	53460, -- 34
	56610 -- 35
}

function Activate()
    GameRules.AddonTemplate = HAM()
    GameRules.AddonTemplate:InitGameMode()
    require('timers')
end

function HAM:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	-- Set thinker
	GameMode:SetThink("OnThink", self, "GlobalThink", 1)

	-- Set listeners
	ListenToGameEvent("entity_killed", Dynamic_Wrap(HAM, "OnEntityKilled"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(HAM, "OnNPCSpawned"), self)

	-- Enable backdoor protection
	GameMode:SetTowerBackdoorProtectionEnabled(true)

	-- Enable custom buyback cooldown
	-- GameMode:SetCustomBuybackCooldownEnabled(true)

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

function HAM:OnNPCSpawned(keys)
    local spawnedNPC = EntIndexToHScript(keys.entindex)
    if spawnedNPC:IsRealHero() then
        Timers:CreateTimer(0.6, spawnedNPC:AddNewModifier(spawnedNPC, nil, "modifier_lycan_shapeshift_speed", {duration = -1}))
    end
end

function HAM:OnEntityKilled(keys)
    local killedEntity = EntIndexToHScript(keys.entindex_killed)
    if killedEntity:IsRealHero() then
		killedEntity:SetTimeUntilRespawn(killedEntity:GetRespawnTime() / 2)
    end
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