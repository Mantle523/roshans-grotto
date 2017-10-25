ROSHANSGROTTO_VERSION = "1.00"

ROSHANSGROTTO_DEBUG_SPEW = true 



function RoshansGrotto:PostLoadPrecache()
  DebugPrint("[ROSHANSGROTTO] Performing Post-Load precache")    

end


function RoshansGrotto:OnFirstPlayerLoaded()
  DebugPrint("[ROSHANSGROTTO] First Player has loaded")
end


function RoshansGrotto:OnAllPlayersLoaded()
  DebugPrint("[ROSHANSGROTTO] All Players have loaded into the game")
end


function RoshansGrotto:OnHeroInGame(hero)
  DebugPrint("[ROSHANSGROTTO] Hero spawned in game for first time -- " .. hero:GetUnitName())

  local innate_abilities = {
   "rg_gift_present",
   "rg_gift_coal"
}

-- Cycle through any innate abilities found, then level them
  for i = 1, #innate_abilities do
   local current_ability = hero:FindAbilityByName(innate_abilities[i])
   if current_ability then
      current_ability:SetLevel(1)
   end
  end


  --hero:SetGold(500, false)


end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function RoshansGrotto:OnGameInProgress()
  DebugPrint("[ROSHANSGROTTO] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
    end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function RoshansGrotto:InitRoshansGrotto()
  RoshansGrotto = self
  DebugPrint('[ROSHANSGROTTO] Starting to load RoshansGrotto roshansgrotto...')

  DebugPrint('[ROSHANSGROTTO] Done loading RoshansGrotto roshansgrotto!\n\n')

end

function RoshansGrotto:InitGameMode()

  currentRound = nil
  RoundInProgress = 0

  GameRules:SetHeroRespawnEnabled(false)
  GameRules:SetSameHeroSelectionEnabled(true)
  GameRules:SetPostGameTime(100)
  GameRules:SetPreGameTime(30)
  GameRules:SetHeroSelectionTime(0)
  GameRules:SetGoldPerTick(0)

  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
  GameRules:GetGameModeEntity():SetCustomGameForceHero( "npc_dota_hero_wisp")


  ListenToGameEvent( "npc_spawned", Dynamic_Wrap( RoshansGrotto, "OnNPCSpawned" ), self )
  ListenToGameEvent( "player_reconnected", Dynamic_Wrap( RoshansGrotto, 'OnPlayerReconnected' ), self )
  ListenToGameEvent( "entity_killed", Dynamic_Wrap( RoshansGrotto, 'OnEntityKilled' ), self )
  ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( RoshansGrotto, "OnGameRulesStateChange" ), self )

  Timers:CreateTimer(function ()
      RoshansGrotto:OnThink()
      return 0.25
    end)
end


function RoshansGrotto:OnGameRulesStateChange()
  print( "recognised game_rules_state_change")
  local nNewState = GameRules:State_Get() 
  if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
    ShowGenericPopup("#roshansgrotto_instructions_title", "#roshansgrotto_instructions_body","", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN)
  elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then 
    --start first round
    print( "starting first round" )
    currentRound = 1
    RoshansGrottoRound:Begin()
    RoundInProgress = 1
  end
end

function RoshansGrotto:OnThink() -- REMEMBER TO RE-ENABLE DEFEAT CHECK!!!!!!!!!!!!!
  --print("thinking")
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    --self._CheckForDefeat()
  elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    return nil
  end
  return 1
end

function RoshansGrotto:_RefreshPlayers()
  for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    if PlayerResource:HasSelectedHero( nPlayerID ) then
      local  hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
      if not hero:IsAlive() then
        return
      end
      hero:SetHealth(hero:GetMaxHealth() )
      hero:SetMana(hero:GetMaxMana() )
    end
  end 
end

function RoshansGrotto:_CheckForDefeat()
  if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    return
  end

  local  bAllGoodDead = true
  local  bAllBadDead = true
  for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then 
      if not PlayerResource:HasSelectedHero( nPlayerID ) then
       bAllGoodDead = false
      else
        local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
        if hero and hero:IsAlive() then
          bAllGoodDead = false
        end
      end
    end
  end
  for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then 
      if not PlayerResource:HasSelectedHero( nPlayerID ) then
       bAllBadDead = false
      else
        local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
        if hero and hero:IsAlive() then
          bAllBadDead = false
        end
      end
    end
  end  

  if bAllGoodDead then 
    GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
    return
  end

  if bAllBadDead then
    GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
    return
  end
end

function RoshansGrotto:_SpawnHeroClientEffects( hero, nPlayerID )
  ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticleForPlayer( "particles/generic_gameplay/winter_effects_hero.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, PlayerResource:GetPlayer( nPlayerID ) ) )
end

function RoshansGrotto:OnNPCSpawned( event )
  print("npc spawned")
  local spawnedUnit = EntIndexToHScript(event.entindex)
  if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
    return
  end

  if spawnedUnit:IsCreature() then
    spawnedUnit:SetMaxHealth(spawnedUnit:GetLevel() )
    spawnedUnit:SetHPGain( 0 )
    spawnedUnit:SetManaGain( 0 )
    spawnedUnit:SetHPRegenGain( 0 )
    spawnedUnit:SetManaRegenGain( 0 )
    spawnedUnit:SetDamageGain(0)
    spawnedUnit:SetArmorGain( 0 )
    spawnedUnit:SetMagicResistanceGain( 0 )
    spawnedUnit:SetDisableResistanceGain( 0 )
    spawnedUnit:SetAttackTimeGain( 0 )
    spawnedUnit:SetMoveSpeedGain( 0 )
    spawnedUnit:SetBountyGain( 0 )
    spawnedUnit:SetDeathXP( 0 )
    spawnedUnit:SetXPGain( 0 )
  end

  if spawnedUnit:IsRealHero() then
    for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
      if ( PlayerResource:IsValidPlayer( nPlayerID ) ) then
        self:_SpawnHeroClientEffects( spawnedUnit, nPlayerID )
      end
    end
  end
end

function RoshansGrotto:OnPlayerReconnected( event )
  local nReconnectedPlayerID = event.PlayerID
  for _, hero in pairs(Entities:FindAllByClassname("npc_dota_hero") ) do 
    if hero:IsRealHero() then 
      self:_SpawnHeroClientEffects( hero, nReconnectedPlayerID)
    end
  end
end

function RoshansGrotto:OnEntityKilled( event )
end



