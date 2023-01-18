---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 05/12/2022 21:39
---
local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Orders = import('/mods/M28AI/lua/AI/M28Orders.lua')
local M28Overseer = import('/mods/M28AI/lua/AI/M28Overseer.lua')
local M28Engineer = import('/mods/M28AI/lua/AI/M28Engineer.lua')
local M28UnitInfo = import('/mods/M28AI/lua/AI/M28UnitInfo.lua')
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')
local M28Land = import('/mods/M28AI/lua/AI/M28Land.lua')
local M28Economy = import('/mods/M28AI/lua/AI/M28Economy.lua')
local M28Team = import('/mods/M28AI/lua/AI/M28Team.lua')
local M28Factory = import('/mods/M28AI/lua/AI/M28Factory.lua')
local M28Logic = import('/mods/M28AI/lua/AI/M28Logic.lua')

function AreMobileLandUnitsInRect(rRectangleToSearch)
    --returns true if have mobile land units in rRectangleToSearch
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end

    local sFunctionRef = 'AreMobileUnitsInRect'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    local tBlockingUnits = GetUnitsInRect(rRectangleToSearch)
    if M28Utilities.IsTableEmpty(tBlockingUnits) then
        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
        return false
    else
        for iUnit, oUnit in tBlockingUnits do
            if oUnit.UnitId and EntityCategoryContains(categories.MOBILE * categories.LAND, oUnit.UnitId) then
                M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                return true
            end
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    return false
end

function GetTeamLifetimeBuildCount(iTeam, category)
    --Intended for use for M28 teams only
    local iTotalBuild = 0
    if M28Utilities.IsTableEmpty(M28Team.tTeamData[iTeam][M28Team.subreftoFriendlyActiveM28Brains]) == false then
        for iBrain, oBrain in M28Team.tTeamData[iTeam][M28Team.subreftoFriendlyActiveM28Brains] do
            iTotalBuild = iTotalBuild + GetLifetimeBuildCount(oBrain, category)
        end
    end
    return iTotalBuild
end

function GetLifetimeBuildCount(aiBrain, category)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'GetLifetimeBuildCount'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    local iTotalBuilt = 0
    local testCat = category
    if type(category) == 'string' then
        testCat = ParseEntityCategory(category)
    end
    local tUnitBPIDs = EntityCategoryGetUnitList(category)
    local oCurBlueprint
    local iCurCount

    if tUnitBPIDs == nil then
        M28Utilities.ErrorHandler('tUnitBPIDs is nil, so wont have built any')
        iTotalBuilt = 0
    else
        if bDebugMessages == true then LOG(sFunctionRef..': cycling through tUnitBPIDs') end
        for _, sBPID in tUnitBPIDs do
            oCurBlueprint = __blueprints[sBPID]
            iCurCount = aiBrain.M28LifetimeUnitCount[sBPID]
            if iCurCount == nil then iCurCount = 0 end
            if bDebugMessages == true then LOG(sFunctionRef..': sBPID='..sBPID..'; LifetimeCount='..iCurCount) end
            iTotalBuilt = iTotalBuilt + iCurCount
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    return iTotalBuilt
end

function IsCivilianBrain(aiBrain)
    --Is this an AI brain?
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'IsCivilianBrain'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if aiBrain.M28IsCivilian == nil then
        local bIsCivilian = false
        if bDebugMessages == true then
            LOG(sFunctionRef..': Brain index='..aiBrain:GetArmyIndex()..'; BrainType='..(aiBrain.BrainType or 'nil')..'; Personality='..ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality..'; reprs of brain='..reprs(aiBrain))
        end
        --Basic check that it appears to have the values we'd expect
        --if aiBrain.BrainType and aiBrain.Name then
        if aiBrain.BrainType == nil or aiBrain.BrainType == "AI" or string.find(aiBrain.BrainType, "AI") then
            if bDebugMessages == true then LOG('Dealing with an AI brain') end
            --Does it have no personality?
            if not(ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality) or ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality == "" then
                if bDebugMessages == true then LOG(sFunctionRef..': Index='..aiBrain:GetArmyIndex()..'; Has no AI personality so will treat as being a civilian brain unless nickname contains AI or AIX and doesnt contain civilian') end
                bIsCivilian = true
                if string.find(aiBrain.Nickname, '%(AI') and not(string.find(aiBrain.Nickname, "civilian")) then
                    if bDebugMessages == true then LOG(sFunctionRef..': AI nickanme suggests its an actual AI and the developer has forgotten to give it a personality') end
                    bIsCivilian = false
                end
            end
        end
        aiBrain.M28IsCivilian = bIsCivilian
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    return aiBrain.M28IsCivilian
end

function GetLifetimeBuildCount(aiBrain, category)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'GetLifetimeBuildCount'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    local iTotalBuilt = 0
    local testCat = category
    if type(category) == 'string' then
        testCat = ParseEntityCategory(category)
    end
    local tUnitBPIDs = EntityCategoryGetUnitList(category)
    local oCurBlueprint
    local iCurCount

    if tUnitBPIDs == nil then
        M28Utilities.ErrorHandler('tUnitBPIDs is nil, so wont have built any')
        iTotalBuilt = 0
    else
        if bDebugMessages == true then LOG(sFunctionRef..': cycling through tUnitBPIDs') end
        for _, sBPID in tUnitBPIDs do
            oCurBlueprint = __blueprints[sBPID]
            iCurCount = aiBrain.M28LifetimeUnitCount[sBPID]
            if iCurCount == nil then iCurCount = 0 end
            if bDebugMessages == true then LOG(sFunctionRef..': sBPID='..sBPID..'; LifetimeCount='..iCurCount) end
            iTotalBuilt = iTotalBuilt + iCurCount
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    return iTotalBuilt
end

function IsEngineerAvailable(oEngineer)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'IsEngineerAvailable'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    --if oEngineer.UnitId..M28UnitInfo.GetUnitLifetimeCount(oEngineer) == 'uel010510' then bDebugMessages = true end


    if bDebugMessages == true then
        local iCurPlateau, iCurLZ = M28Map.GetPlateauAndLandZoneReferenceFromPosition(oEngineer:GetPosition(), true, oEngineer)
        LOG(sFunctionRef..': GameTIme '..GetGameTimeSeconds()..': Engineer '..oEngineer.UnitId..M28UnitInfo.GetUnitLifetimeCount(oEngineer)..' owned by '..oEngineer:GetAIBrain().Nickname..': oEngineer:GetFractionComplete()='..oEngineer:GetFractionComplete()..'; Unit state='..M28UnitInfo.GetUnitState(oEngineer)..'; Are last orders empty='..tostring(oEngineer[M28Orders.reftiLastOrders] == nil)..'; Engineer Plateau='..(iCurPlateau or 'nil')..'; LZ='..(iCurLZ or 'nil'))
    end
    if oEngineer:GetFractionComplete() == 1 and not(oEngineer:IsUnitState('Attached')) then
        M28Orders.UpdateRecordedOrders(oEngineer)
        if not(oEngineer[M28Orders.reftiLastOrders]) then
            if bDebugMessages == true then LOG(sFunctionRef..': Engineer has no last orders active so is available') end
            M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
            return true
        else
            --If engineer is moving but it doesnt have an assignment, or its assignment isnt to move, then make it available, unless it has special micro active
            if oEngineer[M28UnitInfo.refbSpecialMicroActive] then return false
            else
                local iLastOrderType = oEngineer[M28Orders.reftiLastOrders][table.getn(oEngineer[M28Orders.reftiLastOrders])][M28Orders.subrefiOrderType]
                if bDebugMessages == true then LOG(sFunctionRef..': Engineer '..oEngineer.UnitId..M28UnitInfo.GetUnitLifetimeCount(oEngineer)..' owned by '..oEngineer:GetAIBrain().Nickname..' has a last order type of '..(iLastOrderType or 'nil')..'; and an action assigned of '..(oEngineer[M28Engineer.refiAssignedAction] or 'nil')..'; Order for this action='..(M28Engineer.tiActionOrder[oEngineer[M28Engineer.refiAssignedAction]] or 'nil')) end
                if iLastOrderType == M28Orders.refiOrderIssueMove then
                    if oEngineer[M28Engineer.refiAssignedAction] and M28Engineer.tiActionOrder[oEngineer[M28Engineer.refiAssignedAction]] == iLastOrderType then
                        --Engineer not available, unless its order was to move to a land zone, in which case check if it is now in that land zone
                        if oEngineer[M28Engineer.refiAssignedAction] == M28Engineer.refActionMoveToLandZone then
                            local iCurPlateau, iCurLZ = M28Map.GetPlateauAndLandZoneReferenceFromPosition(oEngineer:GetPosition(), true, oEngineer)
                            if bDebugMessages == true then LOG(sFunctionRef..': Engineer has action to move to LZ, reftiPlateauAndLZToMoveTo='..reprs(oEngineer[M28Land.reftiPlateauAndLZToMoveTo])..'; Eng position iCurPlateau='..(iCurPlateau or 'nil')..'; iCurLZ='..(iCurLZ or 'nil')) end
                            if iCurPlateau == oEngineer[M28Land.reftiPlateauAndLZToMoveTo][1] and iCurLZ == oEngineer[M28Land.reftiPlateauAndLZToMoveTo][2] then
                                M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                                return true
                            else
                                M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                                return false
                            end
                        elseif oEngineer[M28Engineer.refiAssignedAction] == M28Engineer.refActionRunToLandZone then --Make available if no enemies in cur LZ and adjacent LZ, or alternatively none in cur LZ, and have friendly cmobat in cur LZ and dont need more
                            local iCurPlateau, iCurLZ = M28Map.GetPlateauAndLandZoneReferenceFromPosition(oEngineer:GetPosition(), true, oEngineer)
                            if bDebugMessages == true then LOG(sFunctionRef..': Engineer has action to run to LZ, reftiPlateauAndLZToMoveTo='..reprs(oEngineer[M28Land.reftiPlateauAndLZToMoveTo])..'; Eng position iCurPlateau='..(iCurPlateau or 'nil')..'; iCurLZ='..(iCurLZ or 'nil')) end
                            if iCurPlateau == oEngineer[M28Land.reftiPlateauAndLZToMoveTo][1] and iCurLZ == oEngineer[M28Land.reftiPlateauAndLZToMoveTo][2] then
                                M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                                return true
                            else
                                local tLZTeamData = M28Map.tAllPlateaus[iCurPlateau][M28Map.subrefPlateauLandZones][iCurLZ][M28Map.subrefLZTeamData][oEngineer:GetAIBrain().M28Team]
                                if bDebugMessages == true then LOG(sFunctionRef..': Engineer isnt at LZ to run to yet, are there enemies in this or adjacent LZ='..tostring(tLZTeamData[M28Map.subrefbEnemiesInThisOrAdjacentLZ])) end
                                if not(tLZTeamData[M28Map.subrefbEnemiesInThisOrAdjacentLZ]) then
                                    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                                    return true
                                else
                                    if tLZTeamData[M28Map.subrefLZTThreatEnemyCombatTotal] >= 10 then
                                        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                                        return false
                                    else
                                        local iTotalEnemyThreatNearby = tLZTeamData[M28Map.subrefLZTThreatEnemyCombatTotal]
                                        if M28Utilities.IsTableEmpty(M28Map.tAllPlateaus[iCurPlateau][M28Map.subrefPlateauLandZones][iCurLZ][M28Map.subrefLZAdjacentLandZones]) == false then
                                            for _, iAdjLZ in M28Map.tAllPlateaus[iCurPlateau][M28Map.subrefPlateauLandZones][iCurLZ][M28Map.subrefLZAdjacentLandZones] do
                                                iTotalEnemyThreatNearby = iTotalEnemyThreatNearby + M28Map.tAllPlateaus[iCurPlateau][M28Map.subrefPlateauLandZones][iAdjLZ][M28Map.subrefLZTeamData][oEngineer:GetAIBrain().M28Team][M28Map.subrefLZTThreatEnemyCombatTotal]
                                            end
                                        end
                                        if bDebugMessages == true then LOG(sFunctionRef..': iTotalEnemyThreatNearby='..iTotalEnemyThreatNearby..'; tLZTeamData[M28Map.subrefLZThreatAllyMobileDFTotal]='..tLZTeamData[M28Map.subrefLZThreatAllyMobileDFTotal]) end
                                        if iTotalEnemyThreatNearby * 5 < tLZTeamData[M28Map.subrefLZThreatAllyMobileDFTotal] then
                                            M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                                            return true
                                        end
                                    end
                                    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                                    return false
                                end
                            end
                        else
                            M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                            return false
                        end
                    else
                        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                        return true
                    end
                else
                    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                    return false
                end
            end
        end
    else
        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
        return false
    end
end

function IsResourceBlockedByResourceBuilding(iResourceCategory, sResourceBlueprint, tResourceLocation)
    --True if there is a mex or hydro at the location - used since CanBuildStructureAt can return false if reclaim is on the resource location (but we can sitll build there)
    local rRectangleToSearch = M28Utilities.GetRectAroundLocation(tResourceLocation, M28UnitInfo.GetBuildingSize(sResourceBlueprint) * 0.5)
    local tUnitsInRect = GetUnitsInRect(rRectangleToSearch)
    if M28Utilities.IsTableEmpty(tUnitsInRect) == false then
        if M28Utilities.IsTableEmpty(EntityCategoryFilterDown(iResourceCategory, tUnitsInRect)) == false then
            --if sResourceBlueprint == 'ueb1102' then LOG('Have units in rectangle around tResourceLocation='..repru(tResourceLocation)) end
            return true
        end
    end
    return false
end

function CanBuildStorageAtLocation(tLocation)
    if M28Overseer.tAllActiveM28Brains[1]:CanBuildStructureAt('ueb1106', tLocation) == true then
        return true
    else
        return not(IsResourceBlockedByResourceBuilding(M28UnitInfo.refCategoryStructure, 'ueb1106', tLocation))
    end
end

function CanBuildOnMexLocation(tMexLocation)
    --True if can build on mex location; will return true if aiBrain result is true
    --Want to use a function in case t urns out reclaim on a mex means aibrain canbuild returns false
    if M28Overseer.tAllActiveM28Brains[1]:CanBuildStructureAt('urb1103', tMexLocation) == true then
        return true
    else
        return not(IsResourceBlockedByResourceBuilding(M28UnitInfo.refCategoryMex, 'urb1103', tMexLocation))
    end
end

function CanBuildOnHydroLocation(tHydroLocation)
    --True if can build on hydro; will return true if aiBrain result is true
    --Want to use a function in case t urns out reclaim on a hydro means aibrain canbuild returns false
    if M28Overseer.tAllActiveM28Brains[1]:CanBuildStructureAt('ueb1102', tHydroLocation) == true then
        return true
    else
        --local iPlateau, iLZ = M28Map.GetPlateauAndLandZoneReferenceFromPosition(tHydroLocation)
        --LOG('CanBuildOnHydroLocation: Considering for tHydroLocation='..repru(tHydroLocation)..' at iPlateau='..iPlateau..'; iLZ='..iLZ..'; IsResourceBlockedByResourceBuilding='..tostring(IsResourceBlockedByResourceBuilding(M28UnitInfo.refCategoryHydro, 'ueb1102', tHydroLocation)))
        return not(IsResourceBlockedByResourceBuilding(M28UnitInfo.refCategoryHydro, 'ueb1102', tHydroLocation))
    end
end

function IsUnitVisibleSEEBELOW()  end --To help with finding canseeunit
function CanSeeUnit(aiBrain, oUnit, bFalseIfOnlySeeBlip)
    --returns true if aiBrain can see oUnit
    --bFalseIfOnlySeeBlip - if true, then returns false if can see the blip but have never seen what the unit was for the blip; defaults to false
    local iUnitBrain = oUnit:GetAIBrain()
    if iUnitBrain == aiBrain then return true
    else
        local iArmyIndex = aiBrain:GetArmyIndex()
        if not(oUnit.Dead) then
            if not(oUnit.GetBlip) then
                --ErrorHandler('oUnit with UnitID='..(oUnit.UnitId or 'nil')..' has no blip, will assume can see it')
                return true
            else
                local oBlip = oUnit:GetBlip(iArmyIndex)
                if oBlip then
                    if bFalseIfOnlySeeBlip and not(oBlip:IsSeenEver(iArmyIndex)) then return false
                    else return true
                    end
                end
            end
        end
    end
    return false
end

function SafeToUpgradeUnit(oUnit)
    --Returns true if safe to upgrade oUnit:
    local iPlateau, iLandZone = M28Map.GetPlateauAndLandZoneReferenceFromPosition(oUnit:GetPosition(), true, oUnit)
    if (iLandZone or 'nil') > 0 then
        local tLZTeamData = M28Map.tAllPlateaus[iPlateau][M28Map.subrefPlateauLandZones][iLandZone][M28Map.subrefLZTeamData][oUnit:GetAIBrain().M28Team]
        if not(tLZTeamData[M28Map.subrefbEnemiesInThisOrAdjacentLZ]) then
            return true
        elseif tLZTeamData[M28Map.subrefLZTCoreBase] and tLZTeamData[M28Map.subrefLZTThreatEnemyCombatTotal] < 150 then
            return true
        end
    end
    return false

end

function HaveLowMass(aiBrain)
    --Not actually used as yet
    local bHaveLowMass = false
    if aiBrain[M28Economy.refiGrossMassBaseIncome] <= 200 then --i.e. we dont ahve a paragon or crazy amount of SACUs
        local iMassStoredRatio = aiBrain:GetEconomyStoredRatio('MASS')
        if (iMassStoredRatio <= 0.15 or aiBrain:GetEconomyStored('MASS') <= 300) then
            if aiBrain[M28Economy.refiNetMassBaseIncome] < 0.2 then bHaveLowMass = true
            elseif iMassStoredRatio <= 0.05 and aiBrain[M28Economy.refiNetMassBaseIncome] < aiBrain[M28Economy.refiGrossMassBaseIncome] * 0.05 then bHaveLowMass = true
            end
        end
    end
    return bHaveLowMass
end

function TeamHasLowMass(iTeam)
    local bHaveLowMass = false
    if M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossMass] <= 200 then --i.e. we dont ahve a paragon or crazy amount of SACUs
        local iMassStoredRatio = M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestMassPercentStored]

        if (iMassStoredRatio <= 0.15 or M28Team.tTeamData[iTeam][M28Team.subrefiTeamMassStored] <= 300 * M28Team.tTeamData[iTeam][M28Team.subrefiActiveM28BrainCount]) then
            if M28Team.tTeamData[iTeam][M28Team.subrefiTeamNetMass] < 0.2 then bHaveLowMass = true
            elseif iMassStoredRatio <= 0.05 and M28Team.tTeamData[iTeam][M28Team.subrefiTeamNetMass] < M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossMass] * 0.05 then bHaveLowMass = true
            elseif GetGameTimeSeconds() - (M28Team.tTeamData[iTeam][M28Team.refiTimeOfLastMassStall] or -10) < 10 then
                bHaveLowMass = true
            end
        end
    end
    return bHaveLowMass
end

function HaveLowPower(iTeam)
    if M28Team.tTeamData[iTeam][M28Team.subrefiTeamNetEnergy] < 0 or M28Team.tTeamData[iTeam][M28Team.subrefbTeamIsStallingEnergy] or M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestEnergyPercentStored] < 0.5 or (M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestMassPercentStored] >= 0.15 and M28Team.tTeamData[iTeam][M28Team.subrefbTooLittleEnergyForUpgrade]) or M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy] < math.max((M28Economy.tiMinEnergyPerTech[M28Team.tTeamData[iTeam][M28Team.subrefiHighestFriendlyFactoryTech]] or 0), M28Team.tTeamData[iTeam][M28Team.subrefiGrossEnergyWhenStalled] * 1.05) then
        if not(M28Team.tTeamData[iTeam][M28Team.refbJustBuiltLotsOfPower]) then
            return true
        else return false
        end
    end
    return false
end

function GetNumberOfUnitsMeetingCategoryUnderConstructionInLandZone(tLZTeamData, iCategoryWanted)
    --Returns the number of factories that are building a unit meeting iCategoryWanted
    local iAlreadyBuilding = 0
    local tLZFactories = EntityCategoryFilterDown(categories.FACTORY, tLZTeamData[M28Map.subrefLZTAlliedUnits])
    if M28Utilities.IsTableEmpty(tLZFactories) == false then
        local oCurUnitBuilding
        for iFactory, oFactory in tLZFactories do
            oCurUnitBuilding = oFactory:GetFocusUnit()
            if oCurUnitBuilding and EntityCategoryContains(iCategoryWanted, oCurUnitBuilding) then
                --LOG('Temp to check we have a factory building the category wanted - we do, oFactory='..oFactory.UnitId..M28UnitInfo.GetUnitLifetimeCount(oFactory)..'; Unit building='..oCurUnitBuilding.UnitId)
                iAlreadyBuilding = iAlreadyBuilding + 1
            end
        end
    end
    return iAlreadyBuilding
end

function WantMorePower(iTeam)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'WantMorePower'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    local bWantMorePower = false
    if M28Team.tTeamData[iTeam][M28Team.refbJustBuiltLotsOfPower] then
        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
        return false
    else
        if HaveLowPower(iTeam) then bWantMorePower = true
        else
            if M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy] < M28Team.tTeamData[iTeam][M28Team.subrefiGrossEnergyWhenStalled] * 1.1 then bWantMorePower = true
            else
                local iNetPowerWanted
                local iHighestTeamTech = M28Team.tTeamData[iTeam][M28Team.subrefiHighestFriendlyFactoryTech]
                if iHighestTeamTech >= 3 then
                    iNetPowerWanted = math.max(50, M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy] * 0.2)
                elseif iHighestTeamTech == 2 then
                    iNetPowerWanted = math.max(15, M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy] * 0.15)
                elseif M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy] >= 20 * M28Team.tTeamData[iTeam][M28Team.subrefiActiveM28BrainCount] then
                    iNetPowerWanted = math.max(3, M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy] * 0.1)
                else
                    iNetPowerWanted = 2
                end
                if M28Team.tTeamData[iTeam][M28Team.subrefiTeamNetEnergy] < iNetPowerWanted then
                    bWantMorePower = true
                end
            end
        end
    end
    if bDebugMessages == true then LOG(sFunctionRef..': End of code, bWantMorePower='..tostring(bWantMorePower)..'; Just built lots of power='..tostring(M28Team.tTeamData[iTeam][M28Team.refbJustBuiltLotsOfPower] or false)..'; HaveLowPower='..tostring(HaveLowPower(iTeam))..'; M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy]='..(M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy] or 'nil')..'; M28Team.tTeamData[iTeam][M28Team.subrefiHighestFriendlyFactoryTech]='..M28Team.tTeamData[iTeam][M28Team.subrefiHighestFriendlyFactoryTech]..'; M28Team.tTeamData[iTeam][M28Team.subrefiTeamNetEnergy]='..M28Team.tTeamData[iTeam][M28Team.subrefiTeamNetEnergy]) end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    return bWantMorePower
end

function WantToReclaimEnergyNotMass(iTeam, iPlateau, iLandZone)
    if M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestEnergyPercentStored] <= 0.7 and M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossEnergy] <= 80 and M28Map.tAllPlateaus[iPlateau][M28Map.subrefPlateauLandZones][iLandZone][M28Map.refReclaimTotalEnergy] >= 100 and M28Team.tTeamData[iTeam][M28Team.subrefiTeamNetEnergy] < 2 then
        return true
    end
    return false
end


function HaveFactionTech(iSubteam, iFactoryType, iFactionWanted, iMinTechLevelNeeded)
    for iCurTech = iMinTechLevelNeeded, 3 do
        if M28Team.tLandSubteamData[iSubteam][M28Team.subrefFactoriesByTypeFactionAndTech][iFactoryType][iFactionWanted][iCurTech] > 0 then
            return true
        end
    end
    return false
end

function CloseToEnemyUnit(tStartPosition, tUnitsToCheck, iDistThreshold, iTeam, bIncludeEnemyDFRange)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'CloseToEnemyUnit'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    local iCurDist
    if bDebugMessages == true then
        LOG(sFunctionRef..': tStartPosition='..repru(tStartPosition)..'; Size of tUnitsToCheck='..table.getn(tUnitsToCheck)..'; iDistThreshold='..iDistThreshold..'; bIncludeEnemyDFRange='..tostring(bIncludeEnemyDFRange or false))
        for iUnit, oUnit in tUnitsToCheck do
            LOG(sFunctionRef..': Dist to oUnit '..oUnit.UnitId..M28UnitInfo.GetUnitLifetimeCount(oUnit)..' = '..M28Utilities.GetDistanceBetweenPositions(tStartPosition, oUnit[M28UnitInfo.reftLastKnownPositionByTeam][iTeam])..' based on last known position of '..repru(oUnit[M28UnitInfo.reftLastKnownPositionByTeam][iTeam])..'; actual unit position='..repru(oUnit:GetPosition())..'; Unit range='..(oUnit[M28UnitInfo.refiDFRange] or 0)..'; Is distance less tahn threshold='..tostring(M28Utilities.GetDistanceBetweenPositions(tStartPosition, oUnit[M28UnitInfo.reftLastKnownPositionByTeam][iTeam]) < iDistThreshold))
        end
    end
    for iUnit, oUnit in tUnitsToCheck do
        iCurDist = M28Utilities.GetDistanceBetweenPositions(tStartPosition, oUnit[M28UnitInfo.reftLastKnownPositionByTeam][iTeam])
        if bIncludeEnemyDFRange then iCurDist = iCurDist - (oUnit[M28UnitInfo.refiDFRange] or 0) end
        if iCurDist <= iDistThreshold then
            if bDebugMessages == true then LOG(sFunctionRef..': Are close to unit '..oUnit.UnitId..M28UnitInfo.GetUnitLifetimeCount(oUnit)) end
            M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
            return true
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    return false
end

function WantMoreFactories(iTeam, iPlateau, iLandZone)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'WantMoreFactories'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    --e.g. 1 t1 land factory building tank uses 0.4 mass per tick, so would want 1 factory for every 0.8 mass as a rough baseline; T2 is 0.9 mass per tick, T3 is 1.6; probably want ratio to be 50%-50%-33%
    if bDebugMessages == true then LOG(sFunctionRef..': Checking if want more factories at gamttime '..GetGameTimeSeconds()..' for iTeam='..iTeam..'; iPlateau='..iPlateau..'; iLandZone='..iLandZone..'; Mass % stored='..M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestMassPercentStored]..'; Land fac count='..M28Team.tTeamData[iTeam][M28Team.subrefiTotalFactoryCountByType][M28Factory.refiFactoryTypeLand]..'; Gross mass count='..M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossMass]..'; Highest factory tech='..M28Team.tTeamData[iTeam][M28Team.subrefiHighestFriendlyFactoryTech]) end
    local tiFactoryToMassByTechRatioWanted = {[1] = 0.8, [2] = 1.8, [3] = 4.8}
    if (M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestMassPercentStored] >= 0.05 or (M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestMassPercentStored] >= 0.01 and M28Team.tTeamData[iTeam][M28Team.subrefiHighestFriendlyFactoryTech] == 1 and M28Utilities.IsTableEmpty(M28Team.tTeamData[iTeam][M28Team.subreftTeamUpgradingMexes]) == false and table.getn(M28Team.tTeamData[iTeam][M28Team.subreftTeamUpgradingMexes]) >= 3))  and (M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestMassPercentStored] >= 0.4 or (M28Team.tTeamData[iTeam][M28Team.subrefiTotalFactoryCountByType][M28Factory.refiFactoryTypeLand] + M28Team.tTeamData[iTeam][M28Team.subrefiTotalFactoryCountByType][M28Factory.refiFactoryTypeAir] <= math.max(4 * M28Team.tTeamData[iTeam][M28Team.subrefiActiveM28BrainCount], M28Team.tTeamData[iTeam][M28Team.subrefiTeamGrossMass] * tiFactoryToMassByTechRatioWanted[M28Team.tTeamData[iTeam][M28Team.subrefiHighestFriendlyFactoryTech]])) or (M28Team.tTeamData[iTeam][M28Team.subrefiHighestFriendlyFactoryTech] == 1 and GetGameTimeSeconds() <= 600)) then
        --If we dont have at least 25% mass stored, do we have an enemy in the same plateau as us who is within 300 land travel distance?
        if M28Team.tTeamData[iTeam][M28Team.subrefiTeamLowestMassPercentStored] < 0.25 then
            local iStartPlateau, iStartLandZone
            for iBrain, oBrain in M28Team.tTeamData[iTeam][M28Team.subreftoEnemyBrains] do
                iStartPlateau, iStartLandZone = M28Map.GetPlateauAndLandZoneReferenceFromPosition(M28Map.PlayerStartPoints[oBrain:GetArmyIndex()])
                if iStartPlateau == iPlateau and iStartLandZone > 0 then
                    if M28Map.GetTravelDistanceBetweenLandZones(iPlateau, iLandZone, iStartLandZone) <= 350 then
                        return true
                    end
                end
            end
        else
            return true
        end
    end
    return false
end

function GetActiveMexUpgrades(tLZTeamData)
    local iActiveMexUpgrades = 0
    if M28Utilities.IsTableEmpty(tLZTeamData[M28Map.subrefActiveUpgrades]) == false then
        for iUpgrade, oUpgrade in tLZTeamData[M28Map.subrefActiveUpgrades] do
            if EntityCategoryContains(M28UnitInfo.refCategoryMex, oUpgrade.UnitId) then iActiveMexUpgrades = iActiveMexUpgrades + 1 end
        end
    end
    return iActiveMexUpgrades
end

function CanUnitUseOvercharge(aiBrain, oUnit)
    --For now checks if enough energy and not underwater and not fired in last 5s; separate function used as may want to expand this with rate of fire check in future
    local sFunctionRef = 'CanUnitUseOvercharge'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local oBP = oUnit:GetBlueprint()
    local iEnergyNeeded
    local bCanUseOC = false
    if GetGameTimeSeconds() - (oUnit[M28UnitInfo.refiTimeOfLastOverchargeShot] or -100) >= 5 then
        for iWeapon, oWeapon in oBP.Weapon do
            if oWeapon.OverChargeWeapon then
                if oWeapon.EnergyRequired then
                    iEnergyNeeded = oWeapon.EnergyRequired
                    break
                end
            end
        end

        if aiBrain:GetEconomyStored('ENERGY') >= iEnergyNeeded then bCanUseOC = true end
        if bDebugMessages == true then LOG(sFunctionRef..': iEnergyNeeded='..iEnergyNeeded..'; aiBrain:GetEconomyStored='..aiBrain:GetEconomyStored('ENERGY')..'; bCanUseOC='..tostring(bCanUseOC)) end
        if bCanUseOC == true then
            --Check if underwater
            local oUnitPosition = oUnit:GetPosition()
            local iHeightAtWhichConsideredUnderwater = M28Map.IsUnderwater(oUnitPosition, true) + 0.25 --small margin of error
            local tFiringPositionStart = M28Logic.GetDirectFireWeaponPosition(oUnit)
            if tFiringPositionStart then
                local iFiringHeight = tFiringPositionStart[2]
                if iFiringHeight <= iHeightAtWhichConsideredUnderwater then
                    if bDebugMessages == true then LOG(sFunctionRef..': ACU is underwater; iFiringHeight='..iFiringHeight..'; iHeightAtWhichConsideredUnderwater='..iHeightAtWhichConsideredUnderwater) end
                    bCanUseOC = false
                end
            end
        end
    elseif bDebugMessages == true then LOG(sFunctionRef..': Has been less tahn 5s since last overcharged')
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    return bCanUseOC
end