if RoshansGrotto == nil then
    --DebugPrint( "[ROSHANSGROTTO] creating roshansgrotto game mode" )
    _G.RoshansGrotto = class({})
end

--requrie list
local requires = {
	"internal/util",
	"roshansgrotto",
	"libraries/timers",
	"libraries/physics",
	"libraries/projectiles",
	"libraries/notifications",
	"libraries/animations",
	"libraries/playertables",
	"libraries/containers",
	"libraries/pathgraph",
	"libraries/selection",
	
	"internal/roshansgrotto",
	"internal/events",

	"settings",

	"events",

	--add game logic files here as they are made
	--"",
}

for _, r in pairs(requires) do
	require(r)
end




function Precache( context )
		-- create a kv file containing all precache material
end


function Activate()
  GameRules.RoshansGrotto = RoshansGrotto()
  GameRules.RoshansGrotto:InitGameMode()
  RoshansGrotto.HasRunOnce = true
  print("Activated")
end

--[[if RoshansGrotto.HasRunOnce then
	RoshansGrotto:OnScriptReload()
end
]]