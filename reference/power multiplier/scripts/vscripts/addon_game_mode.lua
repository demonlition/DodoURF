--[[
Dota Power Multiplier game mode
]]

print( "Dota Power Multiplier x20 game mode loaded." )

-- Load Stat collection (statcollection should be available from any script scope)
require('lib.statcollection')

-- Load the options module (GDSOptions should now be available from the global scope)
require('lib.optionsmodule')

require ( 'util' )
require ( 'skillmanager')
require ( 'timers' )

if PowerMultiplier == nil then
	PowerMultiplier = class({})
end

statcollection.addStats({
	modID = 'a0a0aa957ab22d67b4e69d6b5b0d9f1d' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
})



USE_LOBBY=true
THINK_TIME = 0.1

STARTING_GOLD = 1000--650
MAX_LEVEL = 25


local voted = false
local waitingVote = false
local receivedRemoteCfg = false

local EASY_MODE = false
local ALL_RANDOM = false
local SAME_HERO = false
local BUFF_CREEPS = false
local BUFF_STATS = false
local BUFF_TOWERS = false
local RANDOM_OMG = false
local DM_OMG = false

local SAME_HERO_HOST_HERO = nil

local currentStage = STAGE_VOTING
--local allowed_factors = {2, 3, 5, 10}

local COLOR_BLUE2 = '#4B69FF'
local COLOR_RED2 = '#EB4B4B'
local COLOR_GREEN2 = '#ADE55C'
local COLOR_ORANGE2 = '#FFA500'

--local factor = 20
--local divValue = 10
local factor = 5
local divValue = 2
local heroKV = LoadKeyValues('scripts/npc/npc_heroes.txt')

-- Total number of skill slots to allow
local maxSlots = 4

-- Total number of normal skills to allow
local maxSkills = 3

-- Total number of ults to allow (Ults are always on the right)
local maxUlts = 1

-- Skill list for a given player
local skillList = {}

-- A list of heroes that were picking before the game started
local brokenHeroes = {}

local handled = {}
local handledPlayerIDs = {}

-- Ban List
local banList = LoadKeyValues('scripts/kv/bans.kv')


GDSOptions.setup('a0a0aa957ab22d67b4e69d6b5b0d9f1d', function(err, options)  -- Your modID goes here, GET THIS FROM http://getdotastats.com/#d2mods__my_mods
    -- Check for an error
    if err then
        Log('Something went wrong and we got no options: '..err)
        return
    end

    if GDSOptions.getOption('gamemode', nil) == nil then
    	Log('Received invalid options from getdotastats, not hosted from it?')
    	return
    end

    receivedRemoteCfg = true


	if (GDSOptions.getOption('gamemode', '') == 'ar') 	then ALL_RANDOM 	= true else ALL_RANDOM 	= false end
	if (GDSOptions.getOption('gamemode', '') == 'sh') 	then SAME_HERO 		= true else SAME_HERO 		= false end

	EASY_MODE = GDSOptions.getOption('easymode', false)
	BUFF_CREEPS = GDSOptions.getOption('buffcreeps', false)
	BUFF_TOWERS = GDSOptions.getOption('bufftowers', false)
	BUFF_STATS = GDSOptions.getOption('buffstats', true)
	RANDOM_OMG = GDSOptions.getOption('romg', false)
	
	if (RANDOM_OMG == true) then
		--DM_OMG		= GDSOptions.getOption('dmomg', false)
		maxUlts		= tonumber(GDSOptions.getOption('ultimates', 1))
		maxSlots	= tonumber(GDSOptions.getOption('totalskills', 4))		
		maxSkills	= maxSlots - maxUlts
	end

	Log('*** Config received from dota2stats! ***')
	Log('BUFF_STATS = ' .. tostring(BUFF_STATS))
	Log('BUFF_CREEPS = ' .. tostring(BUFF_CREEPS))
	Log('BUFF_TOWERS = ' .. tostring(BUFF_TOWERS))
	Log('SAME_HERO = ' .. tostring(SAME_HERO))
	Log('RANDOM_OMG = ' .. tostring(RANDOM_OMG))
	--Log('DM_OMG = ' .. tostring(DM_OMG))
	Log('maxUlts = ' .. tostring(maxUlts))
	Log('maxSlots = ' .. tostring(maxSlots))
	Log('maxSkills = ' .. tostring(maxSkills))

	if waitingVote == true then
		FireGameEvent('pwm_hide_dialog', {})
		PowerMultiplier:sayGameModeMessage()
		PowerMultiplier:performAllRandom()
		PowerMultiplier:MultiplyTowers(factor)
	end
    
end)

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.PowerMultiplier = PowerMultiplier()
    GameRules.PowerMultiplier:InitGameMode()
end


function Precache( context )

	--Log('PRECACHING CALLED!')

	--SendToServerConsole('scaleform_spew 1')

	--Precache things we know we'll use.  Possible file types include (but not limited to):
	--PrecacheResource( "model", "*.vmdl", context )
	--PrecacheResource( "soundfile", "*.vsndevts", context )
	--PrecacheResource( "particle", "*.vpcf", context )
	--PrecacheResource( "particle_folder", "particles/folder", context )

	--[[PrecacheModel('models/props_structures/tower_good.vmdl', context)
	PrecacheModel('models/props_structures/tower001.vmdl', context)
	PrecacheModel('models/buildings/building_racks_melee_reference.vmdl', context)
	PrecacheModel('models/creeps/lane_creeps/creep_good_siege/creep_good_siege.vmdl', context)
	PrecacheModel('models/creeps/lane_creeps/creep_bad_siege/creep_bad_siege.vmdl', context)
	PrecacheModel('models/props_c17/fountain_01.vmdl', context)
	

	PrecacheModel('models/heroes/juggernaut/jugg_healing_ward.vmdl', context)
	PrecacheModel('models/heroes/tiny_01/tiny_01.vmdl', context)
	PrecacheModel('models/heroes/tiny_02/tiny_02.vmdl', context)
	PrecacheModel('models/heroes/tiny_03/tiny_03.vmdl', context)
	PrecacheModel('models/heroes/tiny_04/tiny_04.vmdl', context)
	PrecacheModel('models/heroes/tiny_01/tiny_01_tree.vmdl', context)
	PrecacheModel('models/props_gameplay/frog.vmdl', context)
	PrecacheModel('models/props_gameplay/chicken.vmdl', context)
	PrecacheModel('models/heroes/shadowshaman/shadowshaman_totem.vmdl', context)
	PrecacheModel('models/heroes/witchdoctor/witchdoctor_ward.vmdl', context)
	PrecacheModel('models/heroes/enigma/eidelon.vmdl', context)
	PrecacheModel('models/heroes/enigma/eidelon.vmdl', context)
	PrecacheModel('models/heroes/beastmaster/beastmaster_bird.vmdl', context)
	PrecacheModel('models/heroes/beastmaster/beastmaster_beast.vmdl', context)
	PrecacheModel('models/heroes/venomancer/venomancer_ward.vmdl', context)
	PrecacheModel('models/heroes/death_prophet/death_prophet_ghost.vmdl', context)
	PrecacheModel('models/heroes/pugna/pugna_ward.vmdl', context)
	PrecacheModel('models/heroes/witchdoctor/witchdoctor_ward.vmdl', context)
	PrecacheModel('models/heroes/dragon_knight/dragon_knight_dragon.vmdl', context)
	PrecacheModel('models/heroes/rattletrap/rattletrap_cog.vmdl', context)
	PrecacheModel('models/heroes/furion/treant.vmdl', context)
	PrecacheModel('models/heroes/nightstalker/nightstalker_night.vmdl', context)
	PrecacheModel('models/heroes/nightstalker/nightstalker.vmdl', context)
	PrecacheModel('models/heroes/broodmother/spiderling.vmdl', context)
	PrecacheModel('models/heroes/weaver/weaver_bug.vmdl', context)
	PrecacheModel('models/heroes/gyro/gyro_missile.vmdl', context)
	PrecacheModel('models/heroes/invoker/forge_spirit.vmdl', context)
	PrecacheModel('models/heroes/lycan/lycan_wolf.vmdl', context)
	PrecacheModel('models/heroes/lone_druid/true_form.vmdl', context)
	PrecacheModel('models/heroes/undying/undying_flesh_golem.vmdl', context)
	PrecacheModel('models/development/invisiblebox.vmdl', context)
	PrecacheModel('models/heroes/terrorblade/demon.vmdl', context)]]

	--[[PrecacheResource('particle', 'particles/creature_splitter.pcf', context)
	PrecacheResource('particle', 'particles/frostivus_gameplay.pcf', context)
	PrecacheResource('particle', 'particles/frostivus_herofx.pcf', context)
	PrecacheResource('particle', 'particles/generic_aoe_persistent_circle_1.pcf', context)
	PrecacheResource('particle', 'particles/holdout_lina.pcf', context)
	PrecacheResource('particle', 'particles/test_particle.pcf', context)
	PrecacheResource('particle', 'particles/nian_gameplay.pcf', context)
	PrecacheResource('particle', 'particles/nian_gameplay_b.pcf', context)
	PrecacheResource('particle', 'particles/nian_temp.pcf', context)]]

	-- Precache models we might need
	--[[PrecacheResource('model', 'models/heroes/juggernaut/jugg_healing_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_01/tiny_01.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_02/tiny_02.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_03/tiny_03.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_04/tiny_04.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_01/tiny_01_tree.vmdl', context)
	PrecacheResource('model', 'models/props_gameplay/frog.vmdl', context)
	PrecacheResource('model', 'models/props_gameplay/chicken.vmdl', context)
	PrecacheResource('model', 'models/heroes/shadowshaman/shadowshaman_totem.vmdl', context)
	PrecacheResource('model', 'models/heroes/witchdoctor/witchdoctor_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/enigma/eidelon.vmdl', context)
	PrecacheResource('model', 'models/heroes/enigma/eidelon.vmdl', context)
	PrecacheResource('model', 'models/heroes/beastmaster/beastmaster_bird.vmdl', context)
	PrecacheResource('model', 'models/heroes/beastmaster/beastmaster_beast.vmdl', context)
	PrecacheResource('model', 'models/heroes/venomancer/venomancer_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/death_prophet/death_prophet_ghost.vmdl', context)
	PrecacheResource('model', 'models/heroes/pugna/pugna_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/witchdoctor/witchdoctor_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/dragon_knight/dragon_knight_dragon.vmdl', context)
	PrecacheResource('model', 'models/heroes/rattletrap/rattletrap_cog.vmdl', context)
	PrecacheResource('model', 'models/heroes/furion/treant.vmdl', context)
	PrecacheResource('model', 'models/heroes/nightstalker/nightstalker_night.vmdl', context)
	PrecacheResource('model', 'models/heroes/nightstalker/nightstalker.vmdl', context)
	PrecacheResource('model', 'models/heroes/broodmother/spiderling.vmdl', context)
	PrecacheResource('model', 'models/heroes/weaver/weaver_bug.vmdl', context)
	PrecacheResource('model', 'models/heroes/gyro/gyro_missile.vmdl', context)
	PrecacheResource('model', 'models/heroes/invoker/forge_spirit.vmdl', context)
	PrecacheResource('model', 'models/heroes/lycan/lycan_wolf.vmdl', context)
	PrecacheResource('model', 'models/heroes/lone_druid/true_form.vmdl', context)
	PrecacheResource('model', 'models/heroes/undying/undying_flesh_golem.vmdl', context)
	PrecacheResource('model', 'models/development/invisiblebox.vmdl', context)
	PrecacheResource('model', 'models/heroes/terrorblade/demon.vmdl', context)]]--



	--PrecacheResource('', '')

	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function PowerMultiplier:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )

	

	-- Register Think
	--GameMode:SetContextThink( "PowerMultiplier:GameThink", function() return self:GameThink() end, 0.25 )
	
	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))


  
	 -- Timers
	PowerMultiplier.timers = {}

	-- userID map
	PowerMultiplier.vUserNames = {}
	PowerMultiplier.vBots = {}
	
	-- user level map
	PowerMultiplier.vUserLevel = {}
	
	-- Register Game Events
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(PowerMultiplier, 'AutoAssignPlayer'), self)
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(PowerMultiplier, 'CleanupPlayer'), self)
	--ListenToGameEvent('player_chat', Dynamic_Wrap(PowerMultiplier, 'PlayerSay'), self)
	ListenToGameEvent('player_connect', Dynamic_Wrap(PowerMultiplier, 'PlayerConnect'), self)
	--ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(PowerMultiplier, 'OnLevelUp'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(PowerMultiplier, 'OnGameRulesStateChange'), self)

	Convars:RegisterCommand( "pm_set_game_mode", function(...) return self:_SetGameMode( ... ) end, "used by flash to set the game mode.", 0 )
	Convars:RegisterCommand( "pm_append_log", function(...) return self:_AppendLog( ... ) end, "used by flash to append to logfile.", 0 )

	
end


--[[
  This function should be used to set up Async precache calls at the beginning of the game.  The Precache() function 
  in addon_game_mode.lua used to and may still sometimes have issues with client's appropriately precaching stuff.
  If this occurs it causes the client to never precache things configured in that block.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).
]]

local alreadyCached = {}
function PowerMultiplier:PostLoadPrecache()
  	Log("Performing Post-Load precache")    
  	--[[PowerMultiplier:LoopOverAllHeroes(function(heroname)
  		PrecacheUnitByNameAsync(heroname, function(...) end)
    end)]]

	SkillManager:precacheAll()
  	    
  	--PrecacheItemByNameAsync("item_example_item", function(...) end)
  	--PrecacheItemByNameAsync("example_ability", function(...) end)

  	--PrecacheUnitByNameAsync("npc_precache_everything", function(...) end)
end

function PowerMultiplier:AlertPrecache()
	if SkillManager:isPrecacheFinished() == false then
		SkillManager:disablePick()
  		Say(nil, '<font color="#CC33FF">Precache is in progress, Hero Selection DISABLED until that, please wait!</font>', false)
  		PauseGame(true)
  	end
end

function PowerMultiplier:OnAllPlayersLoaded()	
  	Log("All Players have loaded into the game")
  	
	Say(nil, '<font color="'..COLOR_RED2..'">Waiting 30s for HOST select the Game Mode </font>', false)
	Say(nil, '<font color="'..COLOR_RED2..'">DM OMG</font> <font color="'..COLOR_ORANGE2..'">is currently disabled due crash issues.</font>', false)
	--Say(nil, '<font color="'..COLOR_GREEN2..'">It can take some time to be able to Enter in Battle, that is because of </font><font color="'..COLOR_ORANGE2..'">Precache</font><font color="'..COLOR_GREEN2..'">, please be patient!</font>', false)
	Log("Waiting 30s for host select the game mode")
	--Say(nil, '<font color="'..COLOR_RED2..'">Required Multipliers: </font> <font color="'..COLOR_BLUE2..'">(x2 or x3 or x5 or x10)</font> ', false)
	--Say(nil, '<font color="'..COLOR_RED2..'">Optional: </font> <font color="'..COLOR_BLUE2..'">(em [easy mode], ar [all random heroes])</font> ', false)
	--Say(nil, '<font color="'..COLOR_RED2..'">Example: </font> <font color="'..COLOR_BLUE2..'">-x3 or -emx3 or -arx3 or -aremx3)</font> ', false)
	--Say(nil, '<font color="'..COLOR_GREEN2..'">Few skills will stay with x2 even if other mode is selected, and for now all items will stay in x2 also</font> ', false)

	if receivedRemoteCfg == false then
		waitingVote = true
		FireGameEvent('pwm_show_dialog', {})
		Log('display_game_mode fired')
		PowerMultiplier:AlertPrecache()
		Timers:CreateTimer(30, function()
		    if not voted and receivedRemoteCfg == false then
				FireGameEvent('pwm_hide_dialog', {})
				voted = true
				EASY_MODE = false
				BUFF_CREEPS = false
				BUFF_TOWERS = false
				BUFF_STATS = true
				self:sayGameModeMessage()
				PowerMultiplier:ShowCenterMessage('Default Game Mode Selected' , 10)
				Log("Default Game Mode: Normal x" .. factor)
				--PowerMultiplier:ReplaceAllSkills()				
				PowerMultiplier:MultiplyTowers(factor)
				--PauseGame(false)
			end
		end)
	else
		PowerMultiplier:AlertPrecache()
		self:sayGameModeMessage()
		self:performAllRandom()
		PowerMultiplier:MultiplyTowers(factor)
	end
end

-- The overall game state has changed
PowerMultiplier.loadedOnce = 0 -- needed since we reset the game to picking screen after game mode was set
function PowerMultiplier:OnGameRulesStateChange(keys)
  Log("GameRules State Changed")
  PrintTable(keys)

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    local et = 6
    if self.bSeenWaitForPlayers then
      et = .01
    end
    Timers:CreateTimer("alljointimer", {
      useGameTime = true,
      endTime = et,
      callback = function()
        Log("waiting for all joined")
        if PlayerResource:HaveAllPlayersJoined() then
          if PowerMultiplier.loadedOnce == 0 then
          	  PowerMultiplier.loadedOnce = 1
	          Log("all joined")
	          --PowerMultiplier:PostLoadPrecache()
	          PowerMultiplier:OnAllPlayersLoaded()
	      end
          return 
        end
        return 1
      end
      })
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    --PowerMultiplier:OnGameInProgress()
  end
end


-- Ability stuff
local abs = LoadKeyValues('scripts/npc/npc_abilities.txt')
local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
local skillLookupList = LoadKeyValues('scripts/kv/abilities.kv').abs
local skillLookup = {}
for k,v in pairs(skillLookupList) do
    local skillSplit = vlua.split(v, '||')

    if #skillSplit == 1 then
        skillLookup[v] = tonumber(k)
    else
        -- Store the keys
        for i=1,#skillSplit do
            skillLookup[skillSplit[i]] = -(tonumber(k)+1000*(i-1))
        end
    end
end

-- Merge custom abilities into main abiltiies file
for k,v in pairs(absCustom) do
    abs[k] = v
end

-- Create list of channeled spells
local chanelledSpells = {}
for k,v in pairs(abs) do
    if k ~= 'Version' and k ~= 'ability_base' then
        -- Check if this spell is channelled
        if v.AbilityBehavior and string.match(v.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_CHANNELLED') then
            chanelledSpells[k] = true
        end
    end
end

-- Load the hero KV file
local heroKV = LoadKeyValues('scripts/npc/npc_heroes.txt')

-- Build a table of valid hero IDs to pick from, and skill owners
local validHeroIDs = {}
local validHeroNames = {}
local skillOwningHero = {}
for k,v in pairs(heroKV) do
    if k ~= 'Version' and k ~= 'npc_dota_hero_base' then
        -- If this hero has an ID
        if v.HeroID then
            -- Store the hero name as valid
            validHeroNames[k] = true

            -- Store the ID as valid
            table.insert(validHeroIDs, v.HeroID)

            -- Loop over all possible 16 slots
            for i=1,16 do
                -- Grab the ability
                local ab = v['Ability'..i]

                -- Did we actually find an ability?
                if ab then
                    -- Yep, store this hero as the owner
                    skillOwningHero[ab] = v.HeroID
                end
            end
        end
    end
end

local ownersKV = LoadKeyValues('scripts/kv/owners.kv')
for k,v in pairs(ownersKV) do
    skillOwningHero[k] = tonumber(v);
end

-- Change random seed
local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
math.randomseed(tonumber(timeTxt))

local function isUlt(skillName)
    -- Check if it is tagged as an ulty
    if abs[skillName] and abs[skillName].AbilityType and abs[skillName].AbilityType == 'DOTA_ABILITY_TYPE_ULTIMATE' then
        return true
    end

    return false
end

-- Checks to see if this is a valid skill
local function isValidSkill(skillName)
    if skillLookup[skillName] == nil then return false end

    -- For now, no validation
    return true
end

-- Tells you if a hero name is valid, or not
local function isValidHeroName(heroName)
    if validHeroNames[heroName] then
        return true
    end

    return false
end

-- Tells you if a given spell is channelled or not
local function isChannelled(skillName)
    if chanelledSpells[skillName] then
        return true
    end

    return false
end

-- Function to work out if we can multicast with a given spell or not
local function canMulticast(skillName)
    -- No channel skills
    if isChannelled(skillName) then
        return false
    end

    -- No banned multicast spells
    if banList.noMulticast[skillName] then
        return false
    end

    -- Must be a valid spell
    return true
end

-- Returns the ID for a skill, or -1
local function getSkillID(skillName)
    -- If the skill wasn't found, return -1
    if skillLookup[skillName] == nil then return -1 end

    -- Otherwise, return the correct value
    return skillLookup[skillName]
end

-- Ensures this is a valid slot
local function isValidSlot(slotNumber)
    if slotNumber == 0 or slotNumber >= maxSlots then return false end
    return true
end

-- Returns the ID (or -1) of the hero that owns this skill
local function GetSkillOwningHero(skillName)
    return skillOwningHero[skillName] or -1
end

local function buildDraftString(playerID)
    -- Ensure this player has a draft array
    draftArray[playerID] = draftArray[playerID] or {}

    -- Rebuild draft string
    local str
    for k,v in pairs(draftArray[playerID]) do
        -- Ensure it is actually enabled
        if v then
            -- Add to the combo
            if str then
                str = str..'|'..k
            else
                str = k
            end
        end
    end

    return str or ''
end

local function addHeroDraft(playerID, heroID)
    -- Ensure this player has a draft array
    draftArray[playerID] = draftArray[playerID] or {}

    -- Check if we are chaning anything
    local changed = false
    if not draftArray[playerID][heroID] then
        changed = true
    end

    -- Enable this hero in their draft
    draftArray[playerID][heroID] = true

    -- Return the changed status
    return changed
end


local function getPlayerSlot(playerID)
    -- Grab the cmd player
    local cmdPlayer = PlayerResource:GetPlayer(playerID)
    if not cmdPlayer then return -1 end

    -- Find player slot
    local team = cmdPlayer:GetTeam()
    local playerSlot = 0
    for i=0, 9 do
        if i >= playerID then break end

        if PlayerResource:GetTeam(i) == team then
            playerSlot = playerSlot + 1
        end
    end
    if team == DOTA_TEAM_BADGUYS then
        playerSlot = playerSlot + 5
    end

    return playerSlot
end

local function CheckDraft(playerID, skillName)
    -- Are we using the draft array?
    if useDraftArray then
        -- Ensure this player has a drafting array
        draftArray[playerID] = draftArray[playerID] or {}

        -- Check their drafting array
        if not draftArray[playerID][GetSkillOwningHero(skillName)] then
            return print(skillName..'is not in your drafting pool.')
        end
    end
end

local function findRandomSkill(playerID, slotNumber)
    -- Workout if we can put an ulty here, or a skill
    local canUlt = true
    local canSkill = true

    if slotNumber < maxSlots - maxUlts then
        canUlt = false
    end
    if slotNumber >= maxSkills then
        canSkill = false
    end

    -- There is a chance there is no valid skill
    if not canUlt and not canSkill then
        -- Damn scammers! No valid skills!
        return print('There are no valid skills for this slot!')
    end

    -- Build a list of possible skills
    local possibleSkills = {}

    for k,v in pairs(skillLookupList) do
        -- Check type of skill
        if (canUlt and isUlt(v)) or (canSkill and not isUlt(v)) then
            if not CheckDraft(playerID, v) then
				-- Valid skill, add to our possible skills
				table.insert(possibleSkills, v)
			end
        end
    end

    -- Did we find no possible skills?
    if #possibleSkills == 0 then
        return print('There are no valid skills for this slot!')
    end

    -- Pick a random skill
    return nil, possibleSkills[math.random(#possibleSkills)]
end

-- Ensures the person has all their slots used
local function validateBuild(playerID)
    -- Ensure it exists
    skillList[playerID] = skillList[playerID] or {}

    -- Loop over all slots
    for j=0,maxSlots-1 do
        -- Do they have a skill in this slot?
        if not skillList[playerID][j+1] then
            local msg, skillName = findRandomSkill(playerID, j)
            -- Did we find a valid skill?
            if skillName then
                -- Pick a random skill
                skillList[playerID][j+1] = skillName
            end
        end
    end
end

-- Fixes broken heroes
local function fixBuilds()
    for k,v in pairs(brokenHeroes) do
        if k then
            local playerID = k:GetPlayerID()

            -- Validate the build
            validateBuild(playerID)

            -- Grab their build
            local build = skillList[playerID] or {}

            -- Apply the build
            SkillManager:ApplyBuild(k, build)

            -- Store playerID has handled
            handledPlayerIDs[playerID] = true
        end
    end

    -- No more broken heroes
    brokenHeroes = {}
end


-- Tells you if a hero name is valid, or not
local function isValidHeroName(heroName)
    if validHeroNames[heroName] then
        return true
    end

    return false
end

-- Attempts to pick a random hero, returns 'random' if it fails
local function getRandomHeroName()
    local choices = {}

    for k,v in pairs(validHeroNames) do
        table.insert(choices, k)
    end

    if #choices > 0 then
        return choices[math.random(#choices)]
    else
        return 'random'
    end
end


function PowerMultiplier:ShowCenterMessage(msg,dur)
  local msg = {
    message = msg,
    duration = dur
  }
  FireGameEvent("show_center_message",msg)
end

--function PowerMultiplier:AbilityUsed(keys)
  --Log('AbilityUsed')
  --PrintTable(keys)
--end


--[[function PowerMultiplier:ReplaceAllSkills()
	self:LoopOverPlayers(function(player, plyID)
      local ply = self.vPlayers[plyID]
	  local hero = player.hero
	  SkillManager:ApplyMultiplier(hero, factor)
    end)
end]]--


--[[function PowerMultiplier:OnLevelUp( keys )
	print( "Somebody leveled up!" )
	for i=0, 9 do
		-- Grab player instance
		local ply = PlayerResource:GetPlayer(i)
		-- Make sure we actually found a player instance
		if ply then
			plyID = ply:GetPlayerID()
			hero = ply:GetAssignedHero()
			if self.vUserLevel[plyID] ~= PlayerResource:GetLevel( plyID ) then
				hero:SetBaseStrength(hero:GetBaseStrength() + (hero:GetStrengthGain()*factor / divValue))
				hero:SetBaseAgility(hero:GetBaseAgility() + (hero:GetAgilityGain()*factor / divValue))
				hero:CalculateStatBonus()
			end
		end
	end
end]]--


-- Multicast + Riki ulty
ListenToGameEvent('dota_player_used_ability', function(keys)
	if keys == nil or keys.player == nil then
		Log('received invalid keys in dota_player_used_ability')
		return
	end
    local ply = EntIndexToHScript(keys.player)
    if ply then
        local hero = ply:GetAssignedHero()
        if hero then
            -- Check if they have riki ult
            if hero:HasAbility('riki_permanent_invisibility') then
                local iab = hero:FindAbilityByName('riki_permanent_invisibility')
                if iab and iab:GetLevel() > 0 then
                    -- Remove modifier if they have it
                    if hero:HasModifier('modifier_riki_permanent_invisibility') then
                        hero:RemoveModifierByName('modifier_riki_permanent_invisibility')
                    end

                    -- Workout how long the cooldown will last
                    local cd = 4-iab:GetLevel()

                    -- Start the cooldown
                    iab:StartCooldown(cd)

                    -- Apply invis again
                    hero:AddNewModifier(hero, iab, 'modifier_riki_permanent_invisibility', {
                        fade_time = cd,
                        fade_delay = 0
                    })
                end
            end

            -- Check if they have multicast
            if hero:HasAbility('ogre_magi_multicast') and canMulticast(keys.abilityname) then
                local mab = hero:FindAbilityByName('ogre_magi_multicast')
                if mab then
                    -- Grab the level of the ability
                    local lvl = mab:GetLevel()

                    -- If they have no level in it, stop
                    if lvl == 0 then return end

                    -- How many times we will cast the spell
                    local mult = 0

                    -- Grab a random number
                    local r = RandomFloat(0, 1)

                    -- Calculate multiplyer
                    if lvl == 1 then
                        if r < 0.25 then
                            mult = 2
                        end
                    elseif lvl == 2 then
                        if r < 0.2 then
                            mult = 3
                        elseif r < 0.4 then
                            mult = 2
                        end
                    elseif lvl == 3 then
                        if r < 0.125 then
                            mult = 4
                        elseif r < 0.25 then
                            mult = 3
                        elseif r < 0.5 then
                            mult = 2
                        end
                    end

                    -- Are we doing any multiplying?
                    if mult > 0 then
                        local ab = hero:FindAbilityByName(keys.abilityname)

                        -- If we failed to find it, it might hav e been an item
                        if not ab and hero:HasModifier('modifier_item_ultimate_scepter') then
                            for i=0,5 do
                                -- Grab the slot item
                                local slotItem = hero:GetItemInSlot(i)

                                -- Was this the spell that was cast?
                                if slotItem and slotItem:GetClassname() == keys.abilityname then
                                    -- We found it
                                    ab = slotItem
                                    break
                                end
                            end
                        end

                        if ab then
                            -- How long to delay each cast
                            local delay = 0.1--getMulticastDelay(keys.abilityname)

                            -- Grab the position
                            local pos = hero:GetCursorPosition()

                            Timers:CreateTimer(function()
                                -- Ensure it still exists
                                if IsValidEntity(ab) then
                                    -- Position cursor
                                    hero:SetCursorPosition(pos)

                                    -- Run the spell again
                                    ab:OnSpellStart()

                                    mult = mult-1
                                    if mult > 1 then
                                        return delay
                                    end
                                end
                            end, DoUniqueString('multicast'), delay)

                            -- Create sexy particles
                            local prt = ParticleManager:CreateParticle('ogre_magi_multicast', PATTACH_OVERHEAD_FOLLOW, hero)
                            ParticleManager:SetParticleControl(prt, 1, Vector(mult, 0, 0))
                            ParticleManager:ReleaseParticleIndex(prt)

                            prt = ParticleManager:CreateParticle('ogre_magi_multicast_b', PATTACH_OVERHEAD_FOLLOW, hero:GetCursorCastTarget() or hero)
                            prt = ParticleManager:CreateParticle('ogre_magi_multicast_b', PATTACH_OVERHEAD_FOLLOW, hero)
                            ParticleManager:ReleaseParticleIndex(prt)

                            prt = ParticleManager:CreateParticle('ogre_magi_multicast_c', PATTACH_OVERHEAD_FOLLOW, hero:GetCursorCastTarget() or hero)
                            ParticleManager:SetParticleControl(prt, 1, Vector(mult, 0, 0))
                            ParticleManager:ReleaseParticleIndex(prt)

                            -- Play the sound
                            hero:EmitSound('Hero_OgreMagi.Fireblast.x'..(mult-1))
                        end
                    end
                end
            end
        end
    end
end, nil)

-- Abaddon ulty fix
ListenToGameEvent('entity_hurt', function(keys)
    -- Grab the entity that was hurt
    local ent = EntIndexToHScript(keys.entindex_killed)

    -- Ensure it is a valid hero
    if ent and ent:IsRealHero() then
        -- The min amount of hp
        local minHP = 400

        -- Ensure their health has dropped low enough
        if ent:GetHealth() <= minHP then
            -- Do they even have the ability in question?
            if ent:HasAbility('abaddon_borrowed_time') then
                -- Grab the ability
                local ab = ent:FindAbilityByName('abaddon_borrowed_time')

                -- Is the ability ready to use?
                if ab:IsCooldownReady() then
                    -- Grab the level
                    local lvl = ab:GetLevel()

                    -- Is the skill even skilled?
                    if lvl > 0 then
                        -- Fix their health
                        ent:SetHealth(2*minHP - ent:GetHealth())

                        -- Add the modifier
                        ent:AddNewModifier(ent, ab, 'modifier_abaddon_borrowed_time', {
                            duration = ab:GetSpecialValueFor('duration'),
                            duration_scepter = ab:GetSpecialValueFor('duration_scepter'),
                            redirect = ab:GetSpecialValueFor('redirect'),
                            redirect_range_tooltip_scepter = ab:GetSpecialValueFor('redirect_range_tooltip_scepter')
                        })

                        -- Apply the cooldown
                        if lvl == 1 then
                            ab:StartCooldown(60)
                        elseif lvl == 2 then
                            ab:StartCooldown(50)
                        else
                            ab:StartCooldown(40)
                        end
                    end
                end
            end
        end
    end
end, nil)



function MultiplyBaseStats(hero)
	if BUFF_STATS == false then
		return
	end
	--hero:SetBaseMoveSpeed(hero:GetBaseMoveSpeed()+(20*factor))

	-- Creates temporary item to steal the modifiers from
	local healthUpdater = CreateItem("item_health_modifier", nil, nil) 
	healthUpdater:ApplyDataDrivenModifier(hero, hero, "modifier_health_mod_" .. factor, {})
	UTIL_Remove(healthUpdater)

	--hero:SetBaseStrength((hero:GetBaseStrength() * factor) / divValue)
	--hero:SetBaseAgility((hero:GetBaseAgility() * factor) / divValue)

end


-- Stick skills into slots
PowerMultiplier.shCount = 1;
--local playFactor = {}
ListenToGameEvent('npc_spawned', function(keys)
    -- Grab the unit that spawned
    local spawnedUnit = EntIndexToHScript(keys.entindex)

    if (spawnedUnit:IsHero()) then
    	MultiplyBaseStats(spawnedUnit)
    end
	
	--[[if spawnedUnit:IsCreature() then
		Log('Is Creature: ' .. spawnedUnit:GetUnitName())
	elseif spawnedUnit:IsSummoned() then
		Log('Is Summoned: ' .. spawnedUnit:GetUnitName())
	elseif spawnedUnit:IsControllableByAnyPlayer() then
		Log('IsControllableByAnyPlayer(): ' .. spawnedUnit:GetUnitName())
	else
		--Log('else: ' .. spawnedUnit:GetUnitName())
	end]]
	
	
	
	
	
	if string.find(spawnedUnit:GetUnitName(), "roshan") then
		spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin() * factor) * 4)
		spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax() * factor) * 4)
		spawnedUnit:SetMaxHealth((spawnedUnit:GetMaxHealth() * factor) * 5)
		spawnedUnit:SetHealth((spawnedUnit:GetHealth() * factor) * 5)
		spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue() * factor) / 2)	
	end
	if string.find(spawnedUnit:GetUnitName(), "creep") or string.find(spawnedUnit:GetUnitName(), "neutral") then
		if EASY_MODE == true then
			if BUFF_CREEPS == true then
				--Log("BUFF_CREEPS == 1")
				spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin() * factor) / divValue)
				spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax() * factor) / divValue)
				spawnedUnit:SetMaxHealth((spawnedUnit:GetMaxHealth() * factor) / divValue)
				spawnedUnit:SetHealth((spawnedUnit:GetHealth() * factor) / divValue)
				spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue() * factor) / divValue)	
			end
			spawnedUnit:SetMaximumGoldBounty(spawnedUnit:GetGoldBounty() * 2)	
			spawnedUnit:SetMinimumGoldBounty(spawnedUnit:GetGoldBounty() * 2)
			spawnedUnit:SetDeathXP(spawnedUnit:GetDeathXP() * 2)			
			--Log("Maximum Gold: " .. spawnedUnit:GetGoldBounty())
			
		else
			if BUFF_CREEPS == true then
				spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin() * factor) / 2)
				spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax() * factor) / 2)
				spawnedUnit:SetMaxHealth((spawnedUnit:GetMaxHealth() * factor) / 2)
				spawnedUnit:SetHealth((spawnedUnit:GetHealth() * factor) / 2)
				spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue() * factor) / 2)
			end
		end
	end
	--Log("Unit Name: " .. spawnedUnit:GetUnitName())

    -- Make sure it is a hero
    if spawnedUnit:IsHero() then
        -- Don't touch this hero more than once :O
        if handled[spawnedUnit] then return end
        handled[spawnedUnit] = true

        -- Grab their playerID
        local playerID = spawnedUnit:GetPlayerID()
        if playerID == nil then
        	Log("PlayerID == nill ?!?!?!")
        	return
        end

        -- Don't touch bots
        if PlayerResource:IsFakeClient(playerID) then return end

        -- Grab their build
        --local build = skillList[playerID] or {}

        -- Apply the build
		
		--PrintTable(SkillManager)
		--PrintTable(getmetatable(SkillManager))
		--playFactor[playerID] = factor
		
		-- Same Hero based on host hero
		if playerID == 0 and SAME_HERO == true then
			local hostHeroName = nil
			if ALL_RANDOM == true and SAME_HERO_HOST_HERO ~= nil then
				hostHeroName = SAME_HERO_HOST_HERO
			else
				hostHeroName = PlayerResource:GetSelectedHeroName(0)
			end
			Log("Host Hero Name" .. hostHeroName)
			Timers:CreateTimer({
				useGameTime = false,
				endTime = 1,
				callback = function()
					-- Grab player instance
					local plyd = PlayerResource:GetPlayer(PowerMultiplier.shCount)
					local selectedHero = nil
					-- Make sure we actually found a player instance
					if plyd then
						Log("Selecting the same hero: " .. PowerMultiplier.shCount)
						local testhero = plyd:GetAssignedHero()
						if testhero == null then
							selectedHero = CreateHeroForPlayer(hostHeroName, plyd)
							selectedHero:SetGold(1000, false)
						else
							selectedHero = PlayerResource:ReplaceHeroWith(plyd:GetPlayerID(), hostHeroName, 1000, 0)
						end
						--SkillManager:ApplyMultiplier(selectedHero, factor)
						--MultiplyBaseStats(selectedHero)
					end		
					if PowerMultiplier.shCount < 9 then
						Log("shCount < 9 = " .. PowerMultiplier.shCount)
						PowerMultiplier.shCount = PowerMultiplier.shCount + 1
						return 0.3
					else
						Log("End of Same Hero selection")
					end
				end
			})
			spawnedUnit:SetGold(1000, false)
			--SendToServerConsole('sv_cheats 1')
			--SendToServerConsole('dota_dev forcegamestart')
			--SendToServerConsole('sv_cheats 0')
		end
		

		if RANDOM_OMG == true then
			-- Validate the build
	        validateBuild(playerID)

	        -- Grab their build
	        local build = skillList[playerID] or {}
	        Log("Build:")
	        PrintTable(build)

	        -- Apply the build
	        SkillManager:ApplyBuild(spawnedUnit, build)

	        -- Store playerID has handled
	        handledPlayerIDs[playerID] = true
	    end
		--SkillManager:ApplyMultiplier(spawnedUnit, factor)
		--MultiplyBaseStats(spawnedUnit)
		--spawnedUnit:CalculateStatBonus()
		--spawnedUnit:ModifyMoveSpeed(spawnedUnit:GetBaseMoveSpeed()+(10*factor))
		--spawnedUnit:SetBaseIntellect(100)
		--spawnedUnit:ModifyAgility(50)
		--spawnedUnit:SetMoveCapability(2)
		--spawnedUnit:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

		--print('intellect: ' .. spawnedUnit:GetIntellect())

		--hero:SwapAbilities("antimage_blink", "antimage_spell_shield", true, false)

		--local blink = spawnedUnit:FindAbilityByName("pudge_hook_x5")

		--blink:OnAbilityPinged()
		
		
    end
end, nil)


-- When a hero dies
ListenToGameEvent('entity_killed', function(keys)
    -- Grab the unit that died
    local diedUnit = EntIndexToHScript(keys.entindex_killed)
    -- Make sure it is a hero
    if diedUnit:IsHero() then
        -- Grab their playerID
        local playerID = diedUnit:GetPlayerID()
		
		-- Don't touch bots
        if PlayerResource:IsFakeClient(playerID) then return end

        -- Check if the game has started yet
        if PlayerResource:HaveAllPlayersJoined() and GameRules:State_Get() > DOTA_GAMERULES_STATE_HERO_SELECTION then
        	if DM_OMG == true then
				print('Player Respawned DM')
	            -- Remove their skills
	            SkillManager:RemoveAllSkills(diedUnit)
				
				skillList[playerID] = {}
				
	            -- Validate the build
	            validateBuild(playerID)

	            -- Grab their build
	            local build = skillList[playerID] or {}

	            -- Apply the build
	            SkillManager:ApplyBuild(diedUnit, build)
				
				-- Check the level
				local nowLevel = diedUnit:GetLevel()
				-- Give some point to distribute
				diedUnit:SetAbilityPoints(nowLevel)
			end
        end
    end
end, nil)

function PowerMultiplier:MultiplyTowers(factor)

	Log("Improving fontain!")
	-- improve fontain dmg
	local fountain = Entities:FindByClassname( nil, "ent_dota_fountain" )
	while fountain do
		fountain:SetBaseDamageMin(fountain:GetBaseDamageMin() * factor)
		fountain:SetBaseDamageMax(fountain:GetBaseDamageMax() * factor)
		fountain = Entities:FindByClassname( fountain, "ent_dota_fountain" )
    end
	
	if BUFF_TOWERS == false then
		Log("BUFF_TOWERS = FALSE, Returning!")
		return
	end

	Log("Improving towers!")
	-- improve towers
	local tower = Entities:FindByClassname( nil, "npc_dota_tower" )
    while tower do
		tower:SetBaseDamageMin((tower:GetBaseDamageMin() * factor) / 2)
		tower:SetBaseDamageMax((tower:GetBaseDamageMax() * factor) / 2)
		tower:SetMaxHealth((tower:GetMaxHealth() * factor) / 2)
		tower:SetHealth((tower:GetHealth() * factor) / 2)
		tower:SetPhysicalArmorBaseValue((tower:GetPhysicalArmorBaseValue() * factor) / 2)
		tower = Entities:FindByClassname( tower, "npc_dota_tower" )
    end

	Log("Improving barracks!")
    -- improve barracks
	local rax = Entities:FindByClassname( nil, "npc_dota_barracks" )
	while rax do
		rax:SetMaxHealth((rax:GetMaxHealth() * factor) / 2)
		rax:SetHealth((rax:GetHealth() * factor) / 2)
		rax:SetPhysicalArmorBaseValue((rax:GetPhysicalArmorBaseValue() * factor) / 2)
		rax = Entities:FindByClassname( rax, "npc_dota_barracks" )
	end

	Log("Improving ancient!")
	-- improve ancient
	local ancient = Entities:FindByClassname( nil, "npc_dota_fort" )
	while ancient do
		ancient:SetMaxHealth(ancient:GetMaxHealth() * factor)
		ancient:SetHealth(ancient:GetHealth() * factor)
		ancient:SetPhysicalArmorBaseValue(ancient:GetPhysicalArmorBaseValue() * factor)
		ancient = Entities:FindByClassname( ancient, "npc_dota_fort" )
	end
			
		
end

--[[function PowerMultiplier:OnHeroPickerHidden(keys)
  --Log('OnHeroPickerHidden')
  --PrintTable(keys)
end]]

-- Cleanup a player when they leave
function PowerMultiplier:CleanupPlayer(keys)
  Log('Player Disconnected ' .. tostring(keys.userid))
end

function PowerMultiplier:CloseServer()
  -- Just exit
  SendToServerConsole('exit')
end

function PowerMultiplier:PlayerConnect(keys)
  Log('PlayerConnect')
  --PrintTable(keys)
  
  -- Fill in the usernames for this userID
  self.vUserNames[keys.userid] = keys.name
  if keys.bot == 1 then
    -- This user is a Bot, so add it to the bots table
    self.vBots[keys.userid] = 1
  end
end


function parseCommands(cmd)
   tab = {}
   output = string.gmatch(cmd, '([^,-]+)')
   for r in output do
      output2 = string.gmatch(r, '([^:]+)')
      key = ''
      value = ''
      count = 0
      for r2 in output2 do
         if count == 0 then key = r2 end
         if count == 1 then value = r2 end
         count = count + 1
      end
      tab[key] = value
   end
   return tab
end


function PowerMultiplier:GetFirstPlayer()
	local firstPlayer = 0

	while PlayerResource:GetPlayer(firstPlayer) == nil and firstPlayer < 20 do
		Log("Invalid player id: " .. firstPlayer)
		firstPlayer = firstPlayer + 1
	end
	if (firstPlayer >= 19) then
		Log("Failed to detect the first player (host)")
		return -1
	end
	return firstPlayer
end

function PowerMultiplier:_AppendLog( name, txt )
	LogFlash(txt)
	return true
end

-- test
Convars:RegisterCommand('reload_dir', function(name)
    GameRules:Playtesting_UpdateAddOnKeyValues()
    Log("KeyVelues reloaded!")
end, 'Test reload dir', 0)

--[[function PowerMultiplier:performAllRandom()
	if ALL_RANDOM == 1 then						
		for i=0, 9 do
			-- Grab player instance
			if IsValidPlayer(i) then
				local plyd = PlayerResource:GetPlayer(i)
				-- Make sure we actually found a player instance
				if plyd then
					PlayerResource:SetHasRepicked(plyd:GetPlayerID())
					plyd:MakeRandomHeroSelection()
				end
			end
		end
	end	
	PowerMultiplier:MultiplyTowers(factor)
end]]--

function PowerMultiplier:performAllRandom()
	if ALL_RANDOM == true then
		for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
	    	if PlayerResource:IsValidPlayer(nPlayerID) then
	    		PlayerResource:SetHasRepicked(nPlayerID)
	    		local player = PlayerResource:GetPlayer(nPlayerID)
	    		player:MakeRandomHeroSelection()
	    	end
	    end
	end
end

function PowerMultiplier:sayGameModeMessage()
	local GM = nil
	if EASY_MODE == true then
		if GM ~= nil then GM = GM .. ' / ' else GM = '' end
		GM = GM .. 'Easy'
	end
	if ALL_RANDOM == true then
		if GM ~= nil then GM = GM .. ' / ' else GM = '' end
		GM = GM .. 'All Random'
	end
	if SAME_HERO == true then
		if GM ~= nil then GM = GM .. ' / ' else GM = '' end
		GM = GM .. 'Same Hero'
	end
	if GM == nil then GM = 'All Pick' end
	GM = GM .. ' x'..factor

	if RANDOM_OMG == true then
		if GM ~= nil then GM = GM .. ' / ' else GM = '' end
		GM = GM .. 'Random OMG (' .. maxSkills .. ' Skills - ' .. maxUlts .. ' Ultimates)'
	end
	if DM_OMG == true then
		if GM ~= nil then GM = GM .. ' / ' else GM = '' end
		GM = GM .. 'DM'
	end

	if BUFF_CREEPS == true then
		if GM ~= nil then GM = GM .. ' / ' else GM = '' end
		GM = GM .. 'Buff Creeps'
	end
	if BUFF_TOWERS == true then
		if GM ~= nil then GM = GM .. ' / ' else GM = '' end
		GM = GM .. 'Buff Towers'
	end
	if BUFF_STATS == true then
		if GM ~= nil then GM = GM .. ' / ' else GM = '' end
		GM = GM .. 'Buff HP + Move Speed'
	end

	if RANDOM_OMG == true then
		PowerMultiplier:PostLoadPrecache()
	else
		SkillManager:enablePick()
	end

	local txt = '<font color="'..COLOR_RED2..'">Game Mode: </font> <font color="'..COLOR_BLUE2..'">' .. GM ..'</font> '
	Say(nil, txt, false)
	if SAME_HERO == true then
		local txt2 = '<font color="'..COLOR_ORANGE2..'">Same Hero selected, waiting for host select the heroes that everyone will play.</font>'
		Say(nil, txt2, false)
	end

	SkillManager:enablePick()
end



-- Custom game specific console command "holdout_test_round"
function PowerMultiplier:_SetGameMode( name, cmd )
	Log("_SetGameMode fired: " .. cmd)
	local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
	if cmdPlayer then
		local plyID = cmdPlayer:GetPlayerID()
		Log("Player that used cmd: " .. plyID)
		if not voted then
			Log("not voted yet [ok]")
			Log("Testing player id: " .. plyID)
			local hostID = PowerMultiplier:GetFirstPlayer()
			if hostID == -1 then
				Log("Assume that host == 0")
				hostID = 0
			end

		    if plyID == hostID  then
		  		Log("issued by host")
				if cmd ~= nil then
					parsed = parseCommands(cmd)
					if (parsed.gamemode == 'ar') 	then ALL_RANDOM 	= true else ALL_RANDOM 	= false end
					if (parsed.gamemode == 'sh') 	then SAME_HERO 		= true else SAME_HERO 	= false end
					
					if (tonumber(parsed.em) == 1) then EASY_MODE = true else EASY_MODE = false end
					if (tonumber(parsed.bc) == 1) then BUFF_CREEPS = true else BUFF_CREEPS = false end
					if (tonumber(parsed.bt) == 1) then BUFF_TOWERS = true else BUFF_TOWERS = false end
					if (tonumber(parsed.bs) == 1) then BUFF_STATS = true else BUFF_STATS = false end
					if (tonumber(parsed.omg) == 1) then RANDOM_OMG = true else RANDOM_OMG = false end

					if (RANDOM_OMG == true) then
						if (tonumber(parsed.omgdm) == 1) then DM_OMG = true else DM_OMG = false end

						maxUlts		= tonumber(parsed.tultis)
						maxSlots 	= tonumber(parsed.tskills)
						maxSkills	= maxSlots - maxUlts
					end

					Log('BUFF_STATS = ' .. tostring(BUFF_STATS))
					Log('BUFF_CREEPS = ' .. tostring(BUFF_CREEPS))
					Log('BUFF_TOWERS = ' .. tostring(BUFF_TOWERS))
					Log('SAME_HERO = ' .. tostring(SAME_HERO))
					Log('RANDOM_OMG = ' .. tostring(RANDOM_OMG))
					--Log('DM_OMG = ' .. tostring(DM_OMG))
					Log('maxUlts = ' .. tostring(maxUlts))
					Log('maxSlots = ' .. tostring(maxSlots))
					Log('maxSkills = ' .. tostring(maxSkills))

					if ALL_RANDOM == true or SAME_HERO == true then
						GameRules:ResetToHeroSelection()
					end
					
					self:sayGameModeMessage()
					
					self:performAllRandom()

					PowerMultiplier:MultiplyTowers(factor)

					
					--self:ShowCenterMessage(GM ..' x' .. factor , 10)
					voted = true
					--PowerMultiplier:ReplaceAllSkills()
				else
					Log("cmd == null")
				end
			else
				Log("not host??")
			end  
	  	else
	  		Log("already voted [???]")
	  	end
	end
	return true
end



function PowerMultiplier:AutoAssignPlayer(keys)
  Log('AutoAssignPlayer')
  PrintTable(keys)
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
  
  -- set initial lvl 1
  self.vUserLevel[keys.userid] = 1
end




function PowerMultiplier:LoopOverAllHeroes(callback)
	if herokv == nil then
		heroKV = LoadKeyValues('scripts/npc/npc_heroes.txt')
	end
	for k,v in pairs(heroKV) do
	    if k ~= 'Version' and k ~= 'npc_dota_hero_base' then
	        -- If this hero has an ID
	        if v.HeroID then
	            -- return the hero name
	            if callback(k) then
			    	break
			    end

	        end
	    end
	end
end

--[[function PowerMultiplier:ShopReplacement( keys )
  Log('ShopReplacement' )
  PrintTable(keys)
  --Log('Replacing ' .. keys.itemname .. ' with: ' .. keys.itemname .. '_x2' )

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  
  local player = self.vPlayers[plyID]
  if not player then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
    
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
  --local item = self:getItemByName(player.hero, keys.itemname)
  --if not item then return end
  
  --print ( item:GetAbilityName())
  --player.hero:SetGold(itemcost, true)
  --item:Remove()
  
  --local v = player.hero
  --local item2 = CreateItem(itemName .. '_x2', v, v)
  --v:AddItem(item2)
  
end]]

function PowerMultiplier:getItemByName( hero, name )
  -- Find item by slot
  for i=0,11 do
    local item = hero:GetItemInSlot( i )
    if item ~= nil then
      local lname = item:GetAbilityName()
      if lname == name then
        return item
      end
    end
  end

  return nil
end

