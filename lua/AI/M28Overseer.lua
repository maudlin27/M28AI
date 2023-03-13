---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 16/11/2022 07:20
---

local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')
local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')
local M28UnitInfo = import('/mods/M28AI/lua/AI/M28UnitInfo.lua')
local M28Economy = import('/mods/M28AI/lua/AI/M28Economy.lua')
local M28ACU = import('/mods/M28AI/lua/AI/M28ACU.lua')
local M28Engineer = import('/mods/M28AI/lua/AI/M28Engineer.lua')
local M28Factory = import('/mods/M28AI/lua/AI/M28Factory.lua')
local M28Team = import('/mods/M28AI/lua/AI/M28Team.lua')
local M28Conditions = import('/mods/M28AI/lua/AI/M28Conditions.lua')
local M28Chat = import('/mods/M28AI/lua/AI/M28Chat.lua')
local M28Land = import('/mods/M28AI/lua/AI/M28Land.lua')


bInitialSetup = false
tAllActiveM28Brains = {} --[x] is just a unique integer starting with 1 (so table.getn works on this), not the armyindex; returns the aiBrain object
tAllAIBrainsByArmyIndex = {} --[x] is the brain army index, returns the aibrain

--aiBrain variables
refiDistanceToNearestEnemyBase = 'M28OverseerDistToNearestEnemyBase'
refoNearestEnemyBrain = 'M28OverseerNearestEnemyBrain'

function GetNearestEnemyBrain(aiBrain)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'GetNearestEnemyBrain'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if (aiBrain[refoNearestEnemyBrain] and not(aiBrain[refoNearestEnemyBrain].M28IsDefeated) and not(aiBrain[refoNearestEnemyBrain]:IsDefeated())) or aiBrain.M28IsDefeated then
        return aiBrain[refoNearestEnemyBrain]
    else
        if bDebugMessages == true then LOG(sFunctionRef..': GameTime='..GetGameTimeSeconds()..'; Is pathing complete='..tostring(M28Map.bMapLandSetupComplete)..'; Dont have a valid nearest enemy already recorded for aiBrain '..(aiBrain.Nickname or 'nil')..' with index '..aiBrain:GetArmyIndex()..' so will get a new one; are all enemies defeated for team '..aiBrain.M28Team..'='..tostring(M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefbAllEnemiesDefeated])) end
        local oNearestBrain
        if M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefbAllEnemiesDefeated] then
            --All enemies defeated so will consider civilians as enemy brains
            local oCivilianBrain
            for iCurBrain, oBrain in ArmyBrains do
                if bDebugMessages == true then LOG(sFunctionRef..': Considering obrain '..(oBrain.Nickname or 'nil')..'; is enemy to us='..tostring(IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()))) end
                if IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()) then
                    oNearestBrain = oBrain
                    break
                elseif M28Conditions.IsCivilianBrain(oBrain) then
                    oCivilianBrain = oBrain
                end
            end
            if bDebugMessages == true then LOG(sFunctionRef..': All normal enemies defeated, oNearestBrain='..(oNearestBrain.Nickname or 'nil')..'; oCivilianBrain='..(oCivilianBrain.Nickname or 'nil')) end

            if not (oNearestBrain) then
                oNearestBrain = oCivilianBrain
            end
        else
            local iCurDist
            local iMinDistToEnemy = 10000000

            if bDebugMessages == true then LOG(sFunctionRef .. ': Start before looping through brains; aiBrain personality=' .. ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality .. '; brain.Name=' .. aiBrain.Name) end

            for iCurBrain, oBrain in ArmyBrains do
                if bDebugMessages == true then LOG(sFunctionRef .. ': Start of brain loop, iCurBrain=' .. iCurBrain .. '; brain personality=' .. ScenarioInfo.ArmySetup[oBrain.Name].AIPersonality .. '; brain Nickname=' .. oBrain.Nickname .. '; Brain index=' .. oBrain:GetArmyIndex() .. '; if brain isnt equal to our AI brain then will get its start position etc. IsCivilian='..tostring(M28Conditions.IsCivilianBrain(oBrain))..'; IsEnemy='..tostring(IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()))) end
                if not (oBrain == aiBrain) and (not (M28Conditions.IsCivilianBrain(oBrain)) and IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex())) then
                    if bDebugMessages == true then LOG(sFunctionRef .. ': Brain is dif to aiBrain and a non civilian enemy so will record its start position number if it doesnt have one already') end

                    if not (oBrain:IsDefeated()) and not (oBrain.M28IsDefeated) then
                        --Redundancy for AI like DD that may not trigger the aibrain hook
                        if not(M28Map.PlayerStartPoints[oBrain:GetArmyIndex()]) then
                            local iStartPositionX, iStartPositionZ = oBrain:GetArmyStartPos()
                            M28Map.PlayerStartPoints[oBrain:GetArmyIndex()] = {iStartPositionX, GetSurfaceHeight(iStartPositionX, iStartPositionZ), iStartPositionZ}
                            tAllAIBrainsByArmyIndex[oBrain:GetArmyIndex()] = oBrain
                        end
                        if bDebugMessages == true then
                            LOG(sFunctionRef .. ': Considering nearest enemy for our brain index '..aiBrain:GetArmyIndex()..'; enemy brain with index' .. oBrain:GetArmyIndex() .. ' and nickname '..(oBrain.Nickname or 'nil')..' is not defeated and is an enemy; M28Map.PlayerStartPoints='..repru( M28Map.PlayerStartPoints))
                            local iX, iZ = oBrain:GetArmyStartPos()
                            LOG(sFunctionRef..': Enemy Start iX='..(iX or 'nil')..'; Start iZ+'..(iZ or 'nil'))
                        end
                        iCurDist = M28Utilities.GetDistanceBetweenPositions(M28Map.PlayerStartPoints[aiBrain:GetArmyIndex()], M28Map.PlayerStartPoints[oBrain:GetArmyIndex()])
                        if iCurDist < iMinDistToEnemy then
                            iMinDistToEnemy = iCurDist
                            oNearestBrain = oBrain
                        end
                    end

                    --Strange bug where still returns true for empty slot - below line to avoid this:
                    --[[if GetGameTimeSeconds() <= 5 or brain:GetCurrentUnits(categories.ALLUNITS) > 0 then
                        if bDebugMessages == true then
                            LOG(sFunctionRef .. ': brain has some units')
                        end
                        if M28Map.PlayerStartPoints[brain:GetArmyIndex()] then
                            iDistToCurEnemy = M28Utilities.GetDistanceBetweenPositions(M28Map.PlayerStartPoints[aiBrain:GetArmyIndex()], M28Map.PlayerStartPoints[brain:GetArmyIndex()])
                            if bDebugMessages == true then LOG(sFunctionRef..': Dist between brain and aibrain start points='..iDistToCurEnemy) end
                            if iDistToCurEnemy < iMinDistToEnemy then
                                iMinDistToEnemy = iDistToCurEnemy
                                iNearestEnemyIndex = brain:GetArmyIndex()
                                if bDebugMessages == true then
                                    LOG(sFunctionRef .. ': Current nearest enemy index=' .. iNearestEnemyIndex .. '; startp osition of this enemy=' .. repru(M28Map.PlayerStartPoints[iNearestEnemyIndex]))
                                end
                            end
                        else
                            if bDebugMessages == true then
                                LOG(sFunctionRef .. ': Map info doesnt have a start point for brain with index=' .. brain:GetArmyIndex()..' and nickanme='..(brain.Nickname or 'nil')..'; PlayerStartPoints='..repru(M28Map.PlayerStartPoints))
                            end
                        end
                    else
                        --Can have some cases where have an aibrain but no units, e.g. map Africa has ARMY_9 aibrain name, with no personality, that has no units; will flag the brain as being defeated to be safe if getgametimeseonds is more than 1min
                        if bDebugMessages == true then
                            LOG(sFunctionRef .. ': WARNING: brain isnt defeated but has no units; brain:ArmyIndex=' .. brain:GetArmyIndex())
                        end
                        if GetGameTimeSeconds() >= 60 then brain.M28IsDefeated = true end
                    end--]]
                end
            end
        end
        if not(oNearestBrain) then
            M28Utilities.ErrorHandler('Couldnt find a nearest brain to aiBrain='..aiBrain.Nickname)
            if GetGameTimeSeconds() <= 10 then M28Chat.SendForkedMessage(aiBrain, 'NoEnemies', 'Unable to identify any enemies, M28 may not function properly', 0, 10000, false) end
            M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefbAllEnemiesDefeated] = true
            --Set the nearest enemy as the furthest away other brain (even if it isnt an enemy) - i.e. if do as furthest enemy then more likely to have units passing enemy units
            local iFurthestDist = 0
            local iCurDist
            for iBrain, oBrain in ArmyBrains do
                if not(oBrain == aiBrain) then
                    iCurDist = M28Utilities.GetDistanceBetweenPositions(M28Map.PlayerStartPoints[aiBrain:GetArmyIndex()], M28Map.PlayerStartPoints[oBrain:GetArmyIndex()])
                    if iCurDist > iFurthestDist then
                        oNearestBrain = oBrain
                        iFurthestDist = iCurDist
                    end
                end
            end
        end
        aiBrain[refoNearestEnemyBrain] = oNearestBrain
    end
    return aiBrain[refoNearestEnemyBrain]
end

function M28BrainCreated(aiBrain)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'M28BrainCreated'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if bDebugMessages == true then LOG(sFunctionRef..': M28 Brain has just been created for aiBrain '..aiBrain.Nickname..'; Index='..aiBrain:GetArmyIndex()) end

    aiBrain.M28AI = true
    table.insert(tAllActiveM28Brains, aiBrain)


    if not(bInitialSetup) then
        bInitialSetup = true
        _G.repru = rawget(_G, 'repru') or repr --With thanks to Balthazar for suggesting this for where e.g. FAF develop has a function that isnt yet in FAF main
        if bDebugMessages == true then LOG(sFunctionRef..': About to do one-off setup for all brains') end
        M28Utilities.bM28AIInGame = true

        ForkThread(M28Map.SetupMap)

    end

    ForkThread(OverseerManager, aiBrain)

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)

end

function TestCustom(aiBrain)
    --Destroy a T3 fixed shield to see if we rebuild it
    if GetGameTimeSeconds() >= 1200 and GetGameTimeSeconds() <= 1201 then
        local tFixedShields = aiBrain:GetListOfUnits(M28UnitInfo.refCategoryFixedShield)
        if M28Utilities.IsTableEmpty(tFixedShields) == false then
            for iUnit, oUnit in tFixedShields do
                oUnit:Kill()
                break
            end
        end
    end

    --Detail rally point info for a land zone - Forbidden pass - do we detect that the ridge is pathable?
    --[[local NavUtils = import("/lua/sim/navutils.lua")
    local tPosition = { 260.06228637695, 67.514915466309, 148.83508300781 }
    M28Utilities.DrawLocation(tPosition)
    LOG('NavUtils for tPosition='..(NavUtils.GetLabel('Land', tPosition) or 'nil'))--]]

    --[[local tLZData = M28Map.tAllPlateaus[27][M28Map.subrefPlateauLandZones][20]
    local tStartMidpoint = tLZData[M28Map.subrefLZMidpoint]
    local tRallyPoint = M28Land.GetNearestLandRallyPoint(tLZData, 1, 27, 20, 3)--]]
    --LOG('tStartMidpoint='..repru(tStartMidpoint)..'; tRallyPoint='..repru(tRallyPoint)..'; Path from LZ20 to LZ5='..repru(tLZData[M28Map.subrefLZPathingToOtherLandZones][tLZData[M28Map.subrefLZPathingToOtherLZEntryRef][5]]))

    --Draw specific land zones
    --M28Map.DrawSpecificLandZone(27, 33, 2)
    --M28Map.DrawSpecificLandZone(27, 34, 1)

    --Test alternative to table.remove for sequentially indexed numerical keys
    --[[local tTestArray = {[1] = 'Test1', [2] = 'Test2', [3] = 'Test3', [4] = 'Test4'}
    local function WantToKeep(tArray, i, j)
        if tArray[i] == 'Test2' then return false else return true end
    end
    M28Utilities.RemoveEntriesFromArrayBasedOnCondition(tTestArray, WantToKeep)
    LOG('Finished updating array, tTestArray='..repru(tTestArray))--]]


    --Check for sparky and how many orders it has
    --[[local tOurSparkies = aiBrain:GetListOfUnits(categories.FIELDENGINEER, false, true)
    if M28Utilities.IsTableEmpty(tOurSparkies) == false then
        for iUnit, oUnit in tOurSparkies do
            local tQueue = oUnit:GetCommandQueue()
            LOG('Considering sparky '..oUnit.UnitId..M28UnitInfo.GetUnitLifetimeCount(oUnit)..': About to list out command queue details. Is queue empty='..tostring(M28Utilities.IsTableEmpty(tQueue)))

            if M28Utilities.IsTableEmpty(tQueue) == false then
                LOG('Total commands='..table.getn(tQueue))
                for iCommand, tOrder in ipairs(tQueue) do
                    LOG('iCommand='..iCommand..'; tOrder='..repru(tOrder)..'; position='..repru(tOrder.position)..'; Type='..repru(tOrder.type))
                end
            end
        end
    end--]]

    M28Utilities.ErrorHandler('Disable testcustom code for final')
end




function Initialisation(aiBrain)
    --Called after 1 tick has passed so all aibrains should hopefully exist now
    ForkThread(M28UnitInfo.CalculateBlueprintThreatsByType) --Records air and ground threat values for every blueprint
    ForkThread(M28Team.RecordAllPlayers, aiBrain)
    ForkThread(M28Economy.EconomyInitialisation, aiBrain)
    ForkThread(M28Engineer.EngineerInitialisation, aiBrain)
    ForkThread(M28ACU.ManageACU, aiBrain)
    ForkThread(M28Factory.SetPreferredUnitsByCategory, aiBrain)
    ForkThread(M28Factory.IdleFactoryMonitor, aiBrain)
    ForkThread(M28Map.RecordPondToExpandTo, aiBrain)

end

function OverseerManager(aiBrain)
    --TestCustom(aiBrain)

    --Make sure map setup will be done
    WaitTicks(1)
    while not(M28Map.bMapLandSetupComplete) do
        WaitTicks(1)
    end
    --Initialise main systems
    ForkThread(Initialisation, aiBrain)

    --Wait until we can give orders before doing main logic
    while (GetGameTimeSeconds() <= 4.5) do
        WaitTicks(1)
    end

    while not(aiBrain:IsDefeated()) and not(aiBrain.M28IsDefeated) do
        --TestCustom(aiBrain)

        ForkThread(M28Economy.RefreshEconomyData, aiBrain)
        WaitSeconds(1)
    end
end