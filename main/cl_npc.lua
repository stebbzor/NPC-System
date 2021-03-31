-- Configuration
-- Max distance to interact with an NPC when facing it.
local cMaxDistance = 5.0
-- Default bind to interact with an NPC
local cDefaultBind = "E"
-- Enable debug prints (Not really needed)
local DebugEnabled = false

NPCS = {}
NPCS.List = {}

DecorRegister("ST_NPC_ID", 3)
DecorRegisterLock()

function NPCS:Register(pTable)
	if (not pTable or type(pTable) ~= "table") then return end

	if (pTable.model == nil) then 
		pTable.model = 803106487 
	end

	if (pTable.location == nil) then 
		print("^1Could not setup NPC " .. pTable.name .. ", missing vector.")
		return
	end

	local npcBuild = {}
	npcBuild.name = pTable.name or "John Doe"
	npcBuild.desc = pTable.desc or ""
	npcBuild.location = pTable.location
    npcBuild.heading = pTable.heading or 0
    npcBuild.greetingSound = pTable.greetingSound or true
	npcBuild.model = type(pTable.model) == "string" and GetHashKey(pTable.model) or pTable.model
	npcBuild.anim = pTable.anim or "WORLD_HUMAN_GUARD_PATROL"
	npcBuild.init = pTable.init or function() return end
	npcBuild.onUse = pTable.onUse or function() return end

	RequestModel(npcBuild.model)

	while not HasModelLoaded(npcBuild.model) do
		Citizen.Wait(0)
	end

	npcBuild.entity = CreatePed(1, npcBuild.model, npcBuild.location.x, npcBuild.location.y, npcBuild.location.z, npcBuild.heading, false, true)
	SetBlockingOfNonTemporaryEvents(npcBuild.entity, true)
	SetPedDiesWhenInjured(npcBuild.entity, false)
	SetPedCanPlayAmbientAnims(npcBuild.entity, true)
	SetPedCanRagdollFromPlayerImpact(npcBuild.entity, false)
	SetEntityInvincible(npcBuild.entity, true)
	FreezeEntityPosition(npcBuild.entity, true)
    TaskStartScenarioInPlace(npcBuild.entity, npcBuild.anim, 0, true)
    PlaceObjectOnGroundProperly(npcBuild.entity)

	npcBuild.uid = #self.List + 1

	DecorSetInt(npcBuild.entity, "ST_NPC_ID", npcBuild.uid)

	npcBuild.init(npcBuild.entity)

	self.List[npcBuild.uid] = npcBuild

	SetModelAsNoLongerNeeded(npcBuild.model)
end

function NPCS:GetNPC(pId)
    if not self.List[pId] then return nil end
    return self.List[pId]
end

function Debug(...)
    if (DebugEnabled) then
        print("[NPC-Interactions]", ...)
    end
end

-- Credit to Naikzer on github
function GetEntInFrontOfPlayer(pDistance)
  local mEnt = nil
  local mCoordA = GetEntityCoords(PlayerPedId(), 1)
  local mCoordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, pDistance, 0.0)
  local mRayHandle = StartShapeTestRay(mCoordA.x, mCoordA.y, mCoordA.z, mCoordB.x, mCoordB.y, mCoordB.z, -1, PlayerPedId(), 0)
  local _,_,_,_,mEnt = GetRaycastResult(mRayHandle)
  return mEnt
end
-------------------------------------------

function HandleNPCInteractions()
    local getEntityHit = GetEntInFrontOfPlayer(cMaxDistance)

    if (DoesEntityExist(getEntityHit) and IsEntityAPed(getEntityHit)) then
        if (DecorExistOn(getEntityHit, "ST_NPC_ID")) then
            -- We found our entity

            local mTargetID = DecorGetInt(getEntityHit, "ST_NPC_ID")
            Debug("Target ID is " .. mTargetID, type(mTargetID))

            local mNPC = NPCS:GetNPC(mTargetID)

            if mNPC ~= nil then
                if mNPC.greetingSound then
                    PlayAmbientSpeech1(getEntityHit, "GENERIC_HOWS_IT_GOING", "SPEECH_PARAMS_FORCE_SHOUTED")
                end

                mNPC.onUse(getEntityHit, mNPC.name, mNPC.desc)
            end
        end
    end
end

Citizen.CreateThread(function()
    RegisterKeyMapping('+st_npcInteraction', "Interact with NPC", 'keyboard', cDefaultBind)
    RegisterCommand('+st_npcInteraction', HandleNPCInteractions, false)
    RegisterCommand('-st_npcInteraction', function() end, false)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    for _, v in pairs(NPCS.List) do
        if DoesEntityExist(v.entity) then
            DeleteEntity(v.entity)
        end
    end
end)
