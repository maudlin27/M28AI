---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 08/12/2022 07:09
---

local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')
local M28UnitInfo = import('/mods/M28AI/lua/AI/M28UnitInfo.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Team = import('/mods/M28AI/lua/AI/M28Team.lua')
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')
local M28Land = import('/mods/M28AI/lua/AI/M28Land.lua')

function RecordNewAirUnitForTeam(iTeam, oUnit)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'RecordNewAirUnitForTeam'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if bDebugMessages == true then LOG(sFunctionRef..': iTeam='..iTeam..'; oUnit='..oUnit.UnitId..M28UnitInfo.GetUnitLifetimeCount(oUnit)) end
    local sTeamTableRef
    --Is this an enemy unit?
    if not(oUnit:GetAIBrain().M28Team == iTeam) then
        if EntityCategoryContains(M28UnitInfo.refCategoryAirToGround, oUnit.UnitId) then
            sTeamTableRef = M28Team.reftoEnemyAirToGround
        elseif EntityCategoryContains(M28UnitInfo.refCategoryAirAA, oUnit.UnitId) then
            sTeamTableRef = M28Team.reftoEnemyAirAA
        elseif EntityCategoryContains(M28UnitInfo.refCategoryTorpBomber, oUnit.UnitId) then
            sTeamTableRef = M28Team.reftoEnemyTorpBombers
        else
            sTeamTableRef = M28Team.reftoEnemyAirOther
        end
        if bDebugMessages == true then LOG(sFunctionRef..': About to insert unit '..oUnit.UnitId..M28UnitInfo.GetUnitLifetimeCount(oUnit)..'; into table sTeamTableRef='..sTeamTableRef) end
        table.insert(M28Team.tTeamData[iTeam][sTeamTableRef], oUnit)
        table.insert(M28Team.tTeamData[iTeam][M28Team.reftoAllEnemyAir], oUnit)


        local iPlateau, iLandZone = M28Map.GetPlateauAndLandZoneReferenceFromPosition(oUnit:GetPosition(), false, nil)
        if (iLandZone or 0) == 0 then
            --Does it have a water zone?
            local iSegmentX, iSegmentZ = M28Map.GetPathingSegmentFromPosition(tPosition)
            local iWaterZone = M28Map.tWaterZoneBySegment[iSegmentX][iSegmentZ]
            if iWaterZone > 0 then
                local aiBrain
                for iBrain, oBrain in M28Team.tTeamData[iTeam][M28Team.subreftoFriendlyActiveM28Brains] do
                    aiBrain = oBrain
                    break
                end
                M28Team.AddUnitToWaterZoneForBrain(aiBrain, oUnit, iWaterZone, true)
            else
                RecordEnemyAirUnitWithNoZone(iTeam, oUnit)
            end
        else
            local aiBrain
            for iBrain, oBrain in M28Team.tTeamData[iTeam][M28Team.subreftoFriendlyActiveM28Brains] do
                aiBrain = oBrain
                break
            end
            M28Team.AddUnitToLandZoneForBrain(aiBrain, oUnit, iPlateau, iLandZone, true)
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function RecordEnemyAirUnitWithNoZone(iTeam, oUnit)
    table.insert(M28Team.tTeamData[iTeam][M28Team.reftoEnemyUnitsWithNoLZ], oUnit)
    if not(oUnit[M28UnitInfo.reftAssignedPlateauAndLandZoneByTeam][iTeam]) then
        if not(oUnit[M28UnitInfo.reftAssignedPlateauAndLandZoneByTeam]) then oUnit[M28UnitInfo.reftAssignedPlateauAndLandZoneByTeam] = {} end
        oUnit[M28UnitInfo.reftAssignedPlateauAndLandZoneByTeam][iTeam] = {}
    end
    if not(oUnit[M28UnitInfo.reftAssignedWaterZoneByTeam][iTeam]) then
        if not(oUnit[M28UnitInfo.reftAssignedWaterZoneByTeam]) then oUnit[M28UnitInfo.reftAssignedWaterZoneByTeam] = {} end
        oUnit[M28UnitInfo.reftAssignedWaterZoneByTeam][iTeam] = {}
    end
end

function RefreshZonelessAir(iTeam)
    if M28Utilities.IsTableEmpty(M28Team.tTeamData[iTeam][M28Team.reftoEnemyUnitsWithNoLZ]) == false then
        local aiBrain

        for iBrain, oBrain in M28Team.tTeamData[iTeam][M28Team.subreftoFriendlyActiveM28Brains] do
            aiBrain = oBrain
            break
        end
        --UpdateUnitPositionsAndLandZone(aiBrain, tUnits,                                                       iTeam, iRecordedPlateau, iRecordedLandZone, bUseLastKnownPosition, bAreAirUnits)
        M28Land.UpdateUnitPositionsAndLandZone(aiBrain, M28Team.tTeamData[iTeam][M28Team.reftoEnemyUnitsWithNoLZ], iTeam, nil,              nil,            true,                   true)
    end
end

function UpdateEnemyAirThreats(iTeam)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'UpdateEnemyAirThreats'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    --Calculate threat ratings
    if bDebugMessages == true then
        LOG(sFunctionRef..': Start of code, gametime='..GetGameTimeSeconds()..'; Is table of enemy air to ground threat empty='..tostring(M28Utilities.IsTableEmpty(M28Team.tTeamData[iTeam][M28Team.reftoEnemyAirToGround])))
        if M28Utilities.IsTableEmpty(M28Team.tTeamData[iTeam][M28Team.reftoEnemyAirToGround]) == false then
            for iUnit, oUnit in M28Team.tTeamData[iTeam][M28Team.reftoEnemyAirToGround] do
                LOG(sFunctionRef..': unit '..iUnit..' in enemy air to ground, ref='..oUnit.UnitId..M28UnitInfo.GetUnitLifetimeCount(oUnit)..' has an air to ground threat of '..M28UnitInfo.GetAirThreatLevel({ oUnit }, true, false, false, true, false, false))
            end
        end
    end
                                                                        --GetAirThreatLevel(tUnits,                                             bEnemyUnits,    bIncludeAirToAir, bIncludeGroundToAir, bIncludeAirToGround, bIncludeNonCombatAir, bIncludeAirTorpedo, bBlueprintThreat)
    M28Team.tTeamData[iTeam][M28Team.refiEnemyAirAAThreat] = M28UnitInfo.GetAirThreatLevel(M28Team.tTeamData[iTeam][M28Team.reftoAllEnemyAir], true,            true,               false,              false,                  false,              false)
    M28Team.tTeamData[iTeam][M28Team.refiEnemyAirToGroundThreat] = M28UnitInfo.GetAirThreatLevel(M28Team.tTeamData[iTeam][M28Team.reftoEnemyAirToGround], true, false,              false,              true,                   false, false)
    M28Team.tTeamData[iTeam][M28Team.refiEnemyTorpBombersThreat] = M28UnitInfo.GetAirThreatLevel(M28Team.tTeamData[iTeam][M28Team.reftoEnemyTorpBombers], true, false,              false,              false,                  false, true)
    M28Team.tTeamData[iTeam][M28Team.refiEnemyAirOtherThreat] = M28UnitInfo.GetAirThreatLevel(M28Team.tTeamData[iTeam][M28Team.reftoEnemyAirOther], true, true, false,              true,               true,                   true)
    if bDebugMessages == true then LOG(sFunctionRef..': End of code, time='..GetGameTimeSeconds()..'; Enemy AirAA threat='..M28Team.tTeamData[iTeam][M28Team.refiEnemyAirAAThreat]..'; Air to ground threat='..M28Team.tTeamData[iTeam][M28Team.refiEnemyAirToGroundThreat]..'; Torp bomber threat='..M28Team.tTeamData[iTeam][M28Team.refiEnemyTorpBombersThreat]..'; Other threat='..M28Team.tTeamData[iTeam][M28Team.refiEnemyAirOtherThreat]) end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function AirTeamOverseer(iTeam)
    while M28Team.tTeamData[iTeam][M28Team.subrefiActiveM28BrainCount] > 0 do
        ForkThread(RefreshZonelessAir, iTeam)
        WaitTicks(1)
        ForkThread(UpdateEnemyAirThreats, iTeam)

        WaitTicks(8)
    end
end

function AirTeamInitialisation(iTeam)
    M28Team.tTeamData[iTeam][M28Team.reftoAllEnemyAir] = {}
    M28Team.tTeamData[iTeam][M28Team.reftoEnemyAirAA] = {}
    M28Team.tTeamData[iTeam][M28Team.reftoEnemyAirToGround] = {}
    M28Team.tTeamData[iTeam][M28Team.reftoEnemyTorpBombers] = {}
    M28Team.tTeamData[iTeam][M28Team.reftoEnemyAirOther] = {}
    M28Team.tTeamData[iTeam][M28Team.reftoEnemyUnitsWithNoLZ] = {}
    M28Team.tTeamData[iTeam][M28Team.refiEnemyAirAAThreat] = 0
    M28Team.tTeamData[iTeam][M28Team.refiEnemyAirToGroundThreat] = 0
    M28Team.tTeamData[iTeam][M28Team.refiEnemyTorpBombersThreat] = 0
    M28Team.tTeamData[iTeam][M28Team.refiEnemyAirOtherThreat] = 0

    ForkThread(AirTeamOverseer, iTeam)
end

function AirSubteamInitialisation(iAirSubteam)
    M28Team.tAirSubteamData[iAirSubteam][M28Team.refbFarBehindOnAir] = true
    M28Team.tAirSubteamData[iAirSubteam][M28Team.refbHaveAirControl] = false

    M28Utilities.ErrorHandler('To add code for air subteam '..iAirSubteam..'; e.g. managing friendly air units')
end