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
local M28Air = import('/mods/M28AI/lua/AI/M28Air.lua')
local M28Orders = import('/mods/M28AI/lua/AI/M28Orders.lua')


bInitialSetup = false
tAllActiveM28Brains = {} --[x] is just a unique integer starting with 1 (so table.getn works on this), not the armyindex; returns the aiBrain object
tAllAIBrainsByArmyIndex = {} --[x] is the brain army index, returns the aibrain

--Special settings - restrictions and norush
bUnitRestrictionsArePresent = false
bAirFactoriesCantBeBuilt = false
bNoRushActive = false
iNoRushRange = 0
iNoRushTimer = 0 --Gametimeseconds that norush should end
reftNoRushCentre = 'M28OverseerNRCtre'

--aiBrain variables
refiDistanceToNearestEnemyBase = 'M28OverseerDistToNearestEnemyBase'
refoNearestEnemyBrain = 'M28OverseerNearestEnemyBrain'
refbCloseToUnitCap = 'M28OverseerCloseToUnitCap'
refiExpectedRemainingCap = 'M28OverseerUnitCap' --number of units to be built before we potentially hit the unit cap, i.e. used as a rough guide for when shoudl call the code to check the unit cap
refiUnitCapCategoriesDestroyed = 'M28OverseerLstCatDest' --Last category destroyed by unit cap logic

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

function GameSettingWarningsAndChecks(aiBrain)
    --One once at start of the game if an M28 brain is present
    local sFunctionRef = 'GameSettingWarningsAndChecks'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    if bDebugMessages == true then
        LOG(sFunctionRef .. ': Start of compatibility check.  Size of tAllActiveM28Brains=' .. table.getsize(tAllActiveM28Brains))
    end
    local sIncompatibleMessage = ''
    local bIncompatible = false
    local bHaveOtherAIMod = false
    if M28Utilities.IsTableEmpty(ScenarioInfo.Options.RestrictedCategories) == false then
        bIncompatible = true
        bUnitRestrictionsArePresent = true
        sIncompatibleMessage = sIncompatibleMessage .. ' Unit restrictions. '
    end
    --Check if we can build air factories
    local tFriendlyACU = aiBrain:GetListOfUnits(categories.COMMAND, false, true)
    if bDebugMessages == true then LOG(sFunctionRef..': Is table of friendly ACU empty='..tostring(M28Utilities.IsTableEmpty(tFriendlyACU))) end
    if M28Utilities.IsTableEmpty(tFriendlyACU) == false then
        local sBlueprint = M28Factory.GetBlueprintsThatCanBuildOfCategory(aiBrain, M28UnitInfo.refCategoryAirFactory, tFriendlyACU[1])
        if bDebugMessages == true then LOG(sFunctionRef..': If ACU '..tFriendlyACU[1].UnitId..M28UnitInfo.GetUnitLifetimeCount(tFriendlyACU[1])..' tries to build an air factory, sBLueprint is '..(sBlueprint or 'nil')) end
        if not(sBlueprint) then
            bAirFactoriesCantBeBuilt = true
            if not(bUnitRestrictionsArePresent) then
                bUnitRestrictionsArePresent = true
                sIncompatibleMessage = sIncompatibleMessage .. ' Custom map script or mod preventing air factories'
            end
        end
    end

    if not (ScenarioInfo.Options.NoRushOption == "Off") then
        bIncompatible = true
        sIncompatibleMessage = sIncompatibleMessage .. ' No rush timer. '
    end
    --Check for non-AI sim-mods.  Thanks to Softles for pointing me towards the __active_mods variable
    local tSimMods = __active_mods or {}
    local tAIModNameWhitelist = {
        'M27AI', 'AI-Swarm', 'AI-Uveso', 'AI: DilliDalli', 'Dalli AI', 'Dilli AI', 'M20AI', 'Marlo\'s Sorian AI edit', 'RNGAI', 'SACUAI', 'M28AI'
    }

    local tAIModNameWhereExpectAI = {
        'AI-Swarm', 'AI-Uveso', 'AI: DilliDalli', 'Dalli AI', 'Dilli AI', 'M20AI', 'Marlo\'s Sorian AI edit', 'RNGAI', 'M28AI'
    }
    local tModIsOk = {}
    local bHaveOtherAI = false
    local sUnnecessaryAIMod
    local iUnnecessaryAIModCount = 0
    for iAI, sAI in tAIModNameWhitelist do
        tModIsOk[sAI] = true
    end

    local iSimModCount = 0
    local bFlyingEngineers
    for iMod, tModData in tSimMods do
        if not (tModIsOk[tModData.name]) and tModData.enabled and not (tModData.ui_only) then
            iSimModCount = iSimModCount + 1
            bIncompatible = true
            if iSimModCount == 1 then
                sIncompatibleMessage = sIncompatibleMessage .. ' SIM mods '
            else
                sIncompatibleMessage = sIncompatibleMessage .. '; '
            end
            sIncompatibleMessage = sIncompatibleMessage .. ' ' .. (tModData.name or 'UnknownName')
            if bDebugMessages == true then
                LOG('Whitelist of mod names=' .. repru(tModIsOk))
                LOG(sFunctionRef .. ' About to do reprs of the tModData for mod ' .. (tModData.name or 'nil')..': '..reprs(tModData))
            end

            if string.find(tModData.name, 'Flying engineers') then
                bFlyingEngineers = true
                if bDebugMessages == true then LOG(sFunctionRef..': Have flying engineers mod enabled so will adjust engineer categories') end
            end
        elseif tModIsOk[tModData.name] then
            if not(bHaveOtherAIMod) then
                for iAIMod, sAIMod in tAIModNameWhereExpectAI do
                    if sAIMod == tModData.name then
                        bHaveOtherAIMod = true
                        break
                    end
                end
                if bHaveOtherAIMod then
                    --Do we have non-M28 AI?
                    for iBrain, oBrain in ArmyBrains do
                        if bDebugMessages == true then LOG(sFunctionRef..': Have another AI mod enabled. reprs of oBrain='..reprs(oBrain)..'; is BrainType empty='..tostring(oBrain.BrainType == 'nil')..'; is brian type an empty string='..tostring(oBrain.BrainType == '')) end
                        if ((oBrain.BrainType == 'AI' and not(oBrain.M28AI)) or oBrain.DilliDalli) and not(M28Conditions.IsCivilianBrain(oBrain)) then
                            bHaveOtherAI = true
                            if bDebugMessages == true then LOG('Have an AI for a brain') end
                            break
                        end
                    end
                end
            end
            if bHaveOtherAIMod and not(bHaveOtherAI) then
                local bUnnecessaryMod = false
                for iAIMod, sAIMod in tAIModNameWhereExpectAI do
                    if sAIMod == tModData.name then
                        bUnnecessaryMod = true
                        break
                    end
                end
                if bUnnecessaryMod then

                    iUnnecessaryAIModCount = iUnnecessaryAIModCount + 1
                    if iUnnecessaryAIModCount == 1 then
                        sUnnecessaryAIMod = tModData.name
                    else
                        sUnnecessaryAIMod = sUnnecessaryAIMod..', '..tModData.name
                    end
                end
            end
        end
    end

    if iSimModCount > 0 then
        sIncompatibleMessage = sIncompatibleMessage .. '. '
    end
    if bDebugMessages == true then
        LOG(sFunctionRef .. ': Finished checking compatibility; compatibility message=' .. sIncompatibleMessage .. '; iSimModCount=' .. iSimModCount)
    end

    if iSimModCount > 0 then
        --Basic compatibiltiy with flying engineers mod - allow air engineers to be treated as engineers; also work on mods with similar effect but different name
        if not(bFlyingEngineers) and M28Utilities.IsTableEmpty(EntityCategoryGetUnitList(M28UnitInfo.refCategoryEngineer * categories.TECH1)) then bFlyingEngineers = true end
        if bFlyingEngineers then
            M28UnitInfo.refCategoryEngineer = M28UnitInfo.refCategoryEngineer + categories.ENGINEER * categories.AIR * categories.CONSTRUCTION - categories.EXPERIMENTAL
        end
    end

    if bIncompatible then
        M28Chat.SendMessage(aiBrain, 'SendGameCompatibilityWarning', 'Detected '..sIncompatibleMessage .. ' if you come across M28AI issues with these settings/mods let maudlin27 know via Discord', 0, 10)
    end
    if bHaveOtherAIMod and not(bHaveOtherAI) and sUnnecessaryAIMod then
        M28Chat.SendMessage(aiBrain, 'UnnecessaryMods', 'No other AI detected, These AI mods can be disabled: '..sUnnecessaryAIMod, 1, 10)
    end

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
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

        --Send a message warning players this could take a while
        M28Chat.SendForkedMessage(aiBrain, 'LoadingMap', 'Analysing map, this usually freezes the game for 1-2 minutes (more on large maps)...', 0, 10000, false)
        ForkThread(GameSettingWarningsAndChecks, aiBrain)
        ForkThread(M28Map.SetupMap)

    end

    ForkThread(OverseerManager, aiBrain)

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)

end

function SetupNoRushDetails(aiBrain)
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'SetupNoRushDetails'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if bDebugMessages == true then LOG(sFunctionRef..': Start of code') end

    if ScenarioInfo.Options.NoRushOption  and not(ScenarioInfo.Options.NoRushOption == 'Off') then
        if bDebugMessages == true then LOG(sFunctionRef..': No rush isnt active, will record details') end
        if not(bNoRushActive) then --This is the first time for any AI that this is run (redundancy)
            if bDebugMessages == true then LOG(sFunctionRef..': Log of ScenarioInfo='..repru(ScenarioInfo)) end
            bNoRushActive = true
            iNoRushTimer = tonumber(ScenarioInfo.Options.NoRushOption) * 60
            ForkThread(NoRushMonitor)
            if bDebugMessages == true then LOG(sFunctionRef..': First time have run this so ahve set bNoRushActive='..tostring(bNoRushActive)..' and started iNoRushTimer for '..iNoRushTimer..' to change norush back to false') end
        end
        --Setup details of norush range for each M28AI
        if bNoRushActive then
            local tMapInfo = ScenarioInfo
            aiBrain[reftNoRushCentre] = {M28Map.PlayerStartPoints[aiBrain:GetArmyIndex()][1], 0, M28Map.PlayerStartPoints[aiBrain:GetArmyIndex()][3]}
            local sXRef = 'norushoffsetX_ARMY_'..aiBrain:GetArmyIndex()
            local sZRef = 'norushoffsetY_ARMY_'..aiBrain:GetArmyIndex()
            if bDebugMessages == true then LOG(sFunctionRef..': Checking norush adjustments, sXRef='..sXRef..'; sZRef='..sZRef..'; MapInfoX='..(tMapInfo[sXRef] or 'nil')..'; MapInfoZ='..(tMapInfo[sZRef] or 'nil')..'; aiBrain[reftNoRushCentre] before adjustment='..repru(aiBrain[reftNoRushCentre])) end
            if tMapInfo[sXRef] then aiBrain[reftNoRushCentre][1] = aiBrain[reftNoRushCentre][1] + (tMapInfo[sXRef] or 0) end
            if tMapInfo[sZRef] then aiBrain[reftNoRushCentre][3] = aiBrain[reftNoRushCentre][3] + (tMapInfo[sZRef] or 0) end
            aiBrain[reftNoRushCentre][2] = GetTerrainHeight(aiBrain[reftNoRushCentre][1], aiBrain[reftNoRushCentre][3])
            iNoRushRange = tMapInfo.norushradius
            if bDebugMessages == true then
                LOG(sFunctionRef..': Have recorded key norush details for the ai with index='..aiBrain:GetArmyIndex()..'; iNoRushRange='..iNoRushRange..'; aiBrain[reftNoRushCentre]='..repru(aiBrain[reftNoRushCentre])..'; will draw a circle now in white around the area')
                M28Utilities.DrawCircleAtTarget(aiBrain[reftNoRushCentre], 7, 500, iNoRushRange)
            end

        end
    else
        if bDebugMessages == true then LOG(sFunctionRef..': No rush isnt active') end
        bNoRushActive = false --(redundancy)
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function NoRushMonitor()
    local sFunctionRef = 'NoRushMonitor'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    WaitSeconds(iNoRushTimer)
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    bNoRushActive = false
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function TestCustom(aiBrain)
    local tWZTeamData = M28Map.tPondDetails[552][M28Map.subrefPondWaterZones][25][M28Map.subrefWZTeamData][aiBrain.M28Team]
    LOG('WZ25 pond 552 closest friendly base='..repru(tWZTeamData[M28Map.reftClosestFriendlyBase]))
    --WaitSeconds(5)
    --M28Air.CalculateAirTravelPath(0, 18, 0, 22)
    --[[M28Utilities.DrawLocation({10,GetTerrainHeight(10,10),10}, 3)
    M28Utilities.DrawLocation({12,GetTerrainHeight(12,12),10}, 4)
    M28Utilities.DrawLocation({14,GetTerrainHeight(14,14),14}, 5)--]]


    --Destroy a T3 fixed shield to see if we rebuild it
    --[[if GetGameTimeSeconds() >= 1200 and GetGameTimeSeconds() <= 1201 then
        local tFixedShields = aiBrain:GetListOfUnits(M28UnitInfo.refCategoryFixedShield)
        if M28Utilities.IsTableEmpty(tFixedShields) == false then
            for iUnit, oUnit in tFixedShields do
                oUnit:Kill()
                break
            end
        end
    end--]]

    --Detail rally point info for a land zone - Forbidden pass - do we detect that the ridge is pathable?
    --[[local NavUtils = import("/lua/sim/navutils.lua")
    local tPosition = { 260.06228637695, 67.514915466309, 148.83508300781 }
    M28Utilities.DrawLocation(tPosition)
    LOG('NavUtils for tPosition='..(NavUtils.GetLabel('Land', tPosition) or 'nil'))--]]

    --[[local tLZData = M28Map.tAllPlateaus[27][M28Map.subrefPlateauLandZones][20]
    local tStartMidpoint = tLZData[M28Map.subrefMidpoint]
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
    ForkThread(SetupNoRushDetails, aiBrain)
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
    --ForkThread(TestCustom, aiBrain)

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

function CheckUnitCap(aiBrain)
    local sFunctionRef = 'CheckUnitCap'
    local bDebugMessages = false
    if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    local iUnitCap = tonumber(ScenarioInfo.Options.UnitCap)
    local iCurUnits = aiBrain:GetCurrentUnits(categories.ALLUNITS - M28UnitInfo.refCategoryWall) + aiBrain:GetCurrentUnits(M28UnitInfo.refCategoryWall) * 0.25
    local iThreshold = math.max(math.ceil(iUnitCap * 0.02), 10)
    local iCurUnitsDestroyed = 0
    if bDebugMessages == true then LOG(sFunctionRef..': Start of code at time '..GetGameTimeSeconds()..'; iCurUnits='..iCurUnits..'; iUnitCap='..iUnitCap..'; iThreshold='..iThreshold) end
    if iCurUnits > (iUnitCap - iThreshold * 5) then
        aiBrain[refbCloseToUnitCap] = true
        M28Team.tTeamData[aiBrain.M28Team][M28Team.refiTimeLastNearUnitCap] = GetGameTimeSeconds()
        local iMaxToDestroy = math.max(5, math.ceil(iUnitCap * 0.01), 20 - (iUnitCap - iCurUnits))
        if iUnitCap - iCurUnits < 10 then iMaxToDestroy = math.max(10, iMaxToDestroy) end
        local tUnitsToDestroy
        local tiCategoryToDestroy = {
            [0] = categories.TECH1 - categories.COMMAND - M28UnitInfo.refCategoryT1Mex + M28UnitInfo.refCategoryAllAir * categories.TECH2,
            [1] = M28UnitInfo.refCategoryAllAir * categories.TECH1 + categories.NAVAL * categories.MOBILE * categories.TECH1,
            [2] = M28UnitInfo.refCategoryMobileLand * categories.TECH2 - categories.COMMAND - M28UnitInfo.refCategoryMAA + M28UnitInfo.refCategoryAirScout + M28UnitInfo.refCategoryAirAA * categories.TECH1,
            [3] = M28UnitInfo.refCategoryMobileLand * categories.TECH1 - categories.COMMAND,
            [4] = M28UnitInfo.refCategoryWall + M28UnitInfo.refCategoryEngineer - categories.TECH3,
        }
        if bDebugMessages == true then LOG(sFunctionRef..': We are over the threshold for ctrlking units') end
        if aiBrain:GetCurrentUnits(M28UnitInfo.refCategoryEngineer) > iUnitCap * 0.35 then tiCategoryToDestroy[0] = tiCategoryToDestroy[0] + M28UnitInfo.refCategoryEngineer end
        local iCumulativeCategory = tiCategoryToDestroy[4]
        for iAdjustmentLevel = 4, 0, -1 do
            if iAdjustmentLevel < 4 then
                iCumulativeCategory = iCumulativeCategory + tiCategoryToDestroy[iAdjustmentLevel]
            end
            if bDebugMessages == true then LOG(sFunctionRef..': iCurUnitsDestroyed so far='..iCurUnitsDestroyed..'; iMaxToDestroy='..iMaxToDestroy..'; iAdjustmentLevel='..iAdjustmentLevel..'; iCurUnits='..iCurUnits..'; Unit cap='..iUnitCap..'; iThreshold='..iThreshold) end
            if iCurUnits > (iUnitCap - iThreshold * iAdjustmentLevel) or iCurUnitsDestroyed == 0 then
                tUnitsToDestroy = aiBrain:GetListOfUnits(tiCategoryToDestroy[iAdjustmentLevel], false, false)
                if M28Utilities.IsTableEmpty(tUnitsToDestroy) == false then
                    for iUnit, oUnit in tUnitsToDestroy do
                        if oUnit.Kill then
                            if bDebugMessages == true then LOG(sFunctionRef..': iCurUnitsDestroyed so far='..iCurUnitsDestroyed..'; Will destroy unit '..oUnit.UnitId..M28UnitInfo.GetUnitLifetimeCount(oUnit)..' to avoid going over unit cap') end
                            M28Orders.IssueTrackedKillUnit(oUnit)
                            if EntityCategoryContains(M28UnitInfo.refCategoryWall, oUnit.UnitId) then
                                iCurUnitsDestroyed = iCurUnitsDestroyed + 0.25
                            else
                                iCurUnitsDestroyed = iCurUnitsDestroyed + 1
                            end
                            if iCurUnitsDestroyed >= iMaxToDestroy then break end
                        end
                    end
                end
                if iCurUnitsDestroyed >= iMaxToDestroy then break end
            else
                break
            end
        end
        aiBrain[refiUnitCapCategoriesDestroyed] = iCumulativeCategory
        if bDebugMessages == true then LOG(sFunctionRef..': FInished destroying units, iCurUnitsDestroyed='..iCurUnitsDestroyed) end
    else
        if aiBrain[refbCloseToUnitCap] then
            --Only reset cap if we have a bit of leeway
            if iCurUnits < 10 + (iUnitCap - iThreshold * 5) then
                aiBrain[refbCloseToUnitCap] = false
            end
        end
    end
    aiBrain[refiExpectedRemainingCap] = iUnitCap - iCurUnits + iCurUnitsDestroyed
    if aiBrain[refbCloseToUnitCap] and aiBrain[refiExpectedRemainingCap] <= 25 then
        --Recheck in 30s
        ForkThread(DelayedUnitCapCheck, aiBrain)
    end
    if bDebugMessages == true then LOG(sFunctionRef..': End of code, expected remaining cap='..aiBrain[refiExpectedRemainingCap]) end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function DelayedUnitCapCheck(aiBrain)
    WaitSeconds(30)
    CheckUnitCap(aiBrain)
end