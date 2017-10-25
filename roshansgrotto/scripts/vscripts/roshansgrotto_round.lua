function RoshansGrottoRound:Precache()

end

function RoshansGrottoRound:Begin()
	print("starting round")
	print(currentRound)


	self._vEnemiesSpawned = {}
	self._vEventHandles = {
		ListenToGameEvent( "npc_spawned", Dynamic_Wrap( RoshansGrottoRound, "OnNPCSpawned" ), self ),
		ListenToGameEvent( "entity_killed", Dynamic_Wrap( RoshansGrottoRound, "OnEntityKilled" ), self ),
	}

	self._vPlayerStats = {}
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		self._vPlayerStats[ nPlayerID ] = {}
	end

	--Remove a muting Modifier from players
end

function RoshansGrottoRound:End()
	for _, eID in pairs(self._vEventHandles) do
		StopListeningToGameEvent(eID)
	end

	self._vEventHandles = {}

	if self._entQuest then
		UTIL_RemoveImmediate(self._entQuest)
		self._entQuest = nil

	--Maybe add a wait time here, to prevent abuse
	--Clear all non-hero units in the game, and record how many were removed
	local fBadUnits = 0
	local fGoodUnits = 0
	local fBadLiveUnits = 0
	local fGoodLiveUnits = 0

	for _,unit in pairs( FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false)) do
		if not unit:IsTower() then
			fBadUnits = fBadUnits + 1
			if unit:IsAlive() then
				fBadLiveUnits = fBadLiveUnits + 1
			end
		end

		UTIL_RemoveImmediate(unit)
	end

	for _,unit in pairs( FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false)) do
		if not unit:IsTower() then
			fGoodUnits = fGoodUnits + 1
			if unit:IsAlive() then
				fGoodLiveUnits = fGoodLiveUnits + 1
			end
		end

		UTIL_RemoveImmediate(unit)
	end

	--Store a record for both live and dead creeps for both players at the end of a round
	print(fBadUnits)
	print(fBadLiveUnits)
	print(fGoodUnits)
	print(fGoodLiveUnits)

	--Reset per-round variables
	iGoodUnits = 0
	iBadUnits = 0 
	RoundInProgress = 0
	self:_RefreshPlayers()


end

function RoshansGrottoRound:IsFinished()
	-- Search for any Units affected by a "frostivus spirit" modifier
	local nAggroUnits = 0
	for _,unit in pairs( FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		if unit:HasModifier("modifier_frostivus_spirit_dire") then
			 nAggroUnits = nAggroUnits + 1
		else if unit:HasModifier("modifier_frostivus_spirit_radiant") then
			 nAggroUnits = nAggroUnits + 1
		end
	end
	-- if there is 1 or more affected units return false, else return true
 	if nAggroUnits >= 1 then return false
		else return true
	end
end

function RoshansGrottoRound:OnNPCSpawned(event)
	print("npc spawned round")
	local spawnedUnit = EntIndexToHScript(event.entindex)
	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
    	return
  	end
  	-- Record how many of each teams units have been spawned
  	-- 2 = Goodguys
  	-- 3 = Badguys

  	if spawnedUnit:GetTeamNumber() = 2 then 
  		iGoodUnits = iGoodUnits + 1
  		print(iGoodUnits)
  	elseif spawnedUnit:GetTeamNumber() = 3 then
  		iBadUnits = iBadUnits + 1
  		print(iBadUnits)
  	end	
end


function RoshansGrottoRound:OnEntityKilled( event )
end