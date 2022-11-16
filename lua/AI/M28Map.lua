---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 16/11/2022 07:22
---

local M28Profiling = import('/mods/M28AI/lua/AI/M28Profiling.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local NavUtils = import("/lua/sim/navutils.lua")

--Pathing types
--NavLayers 'Land' | 'Water' | 'Amphibious' | 'Hover' | 'Air'
refPathingTypeAmphibious = 'Amphibious'
refPathingTypeNavy = 'Water'
refPathingTypeAir = 'Air'
refPathingTypeLand = 'Land'
refPathingTypeNone = 'None'
refPathingTypeAll = {refPathingTypeAmphibious, refPathingTypeNavy, refPathingTypeAir, refPathingTypeLand}

--Map size
rMapPlayableArea = {0,0, 256, 256} --{x1,z1, x2,z2} - Set at start of the game, use instead of the scenarioinfo method

--Resource information
tMassPoints = {} --[x] is an integer count, returns the location of a mass point; stores all mexes on the map
tHydroPoints = {} --[x] is an integer count, returns the location of a hydro point; stores all hydro points on the map
tMexByPathingAndGrouping = {} --Stores position of each mex based on the pathing group that it's part of; [a][b][c]: [a] = pathing type ('Land' etc.); [b] = Segment grouping; [c] = Mex position
tHydroByPathingAndGrouping = {} --as above but for hydros


--Land zone variables
iLandZoneSegmentSize = 5 --Gets updated by the SetupLandZones - the size of one side of the square that is the lowest resolution land zones go to
tLandZonesByPlateau = {} --[x] is the plateau group number, returns a table where [y] is the land zone number, which then returns details on the land zone
subrefLZMexCount = 'MexCount' --against tLandZonesByPlateau[iPlateau][iLZ], returns number of mexes in the LZ
subrefLZMexLocations = 'MexLoc' --against tLandZonesByPlateau[iPlateau][iLZ], returns table of mex locations in the LZ
subrefLZReclaimMass = 'ReclaimMass' --against tLandZonesByPlateau[iPlateau][iLZ], returns total mass reclaim in the LZ

--Plateaus
tAllPlateausWithMexes = {} --[x] = AmphibiousPathingGroup, [y]: subrefs, e.g. subrefPlateauMexes;
--aibrain variables for plateaus:
reftPlateausOfInterest = 'M27PlateausOfInterest' --[x] = Amphibious pathing group; will record a table of the pathing groups we're interested in expanding to, returns the location of then earest mex
refiLastPlateausUpdate = 'M27LastTimeUpdatedPlateau' --gametime that we last updated the plateaus
reftOurPlateauInformation = 'M27OurPlateauInformation' --[x] = AmphibiousPathingGroup; [y] = subref, e.g. subrefPlateauLandFactories; Used to store details such as factories on the plateau
refiOurBasePlateauGroup = 'M27PlateausOurBaseGroup' --Segment group of our base (so can easily check somewhere is in a dif plateau)

--subrefs for tables
--tAllPlateausWithMexes subrefs
subrefPlateauMexes = 'M27PlateauMex' --[x] = mex count, returns mex position
subrefPlateauMinXZ = 'M27PlateauMinXZ' --{x,z} min values
subrefPlateauMaxXZ = 'M27PlateauMaxXZ' --{x,z} max values - i.e. can create a rectangle covering entire plateau using min and max xz values
subrefPlateauTotalMexCount = 'M27PlateauMexCount' --Number of mexes on the plateau
subrefPlateauReclaimSegments = 'M27PlateauReclaimSegments' --[x] = reclaim segment x, [z] = reclaim segment z, returns true if part of plateau
subrefPlateauMidpoint = 'M27PlateauMidpoint' --Location of the midpoint of the plateau
subrefPlateauMaxRadius = 'M27PlateauMaxRadius' --Radius to use to ensure the circle coveres the square of the plateau
subrefPlateauContainsActiveStart = 'M27PlateauContainsActiveStart' --True if the plateau is pathable amphibiously to a start position that was active at the start of the game

--reftOurPlateauInformation subrefs (NOTE: If adding more info here need to update in several places, including ReRecordUnitsAndPlatoonsInPlateaus)
subrefPlateauLandFactories = 'M27PlateauLandFactories'

subrefPlateauLandCombatPlatoons = 'M27PlateauLandCombatPlatoons'
subrefPlateauIndirectPlatoons = 'M27PlateauIndirectPlatoons'
subrefPlateauMAAPlatoons = 'M27PlateauMAAPlatoons'
subrefPlateauScoutPlatoons = 'M27PlateauScoutPlatoons'

subrefPlateauEngineers = 'M27PlateauEngineers' --[x] is engineer unique ref (per m27engineeroverseer), returns engineer object



function GetPathingSegmentFromPosition(tPosition)
    --The map is divided into equal sized square segments; this can be used to get the segment X and Z references
    return math.floor( (tPosition[1] - rMapPlayableArea[1]) / iLandZoneSegmentSize) + 1, math.floor((tPosition[3] - rMapPlayableArea[2]) / iLandZoneSegmentSize) + 1
end

function GetPositionFromPathingSegments(iSegmentX, iSegmentZ)
    --If given base level segment positions
    local x = iSegmentX * iSizeOfBaseLevelSegment - iLandZoneSegmentSize * 0.5 + rMapPlayableArea[1]
    local z = iSegmentZ * iSizeOfBaseLevelSegment - iLandZoneSegmentSize * 0.5 + rMapPlayableArea[2]
    return {x, GetTerrainHeight(x, z), z}
end

function RecordResourcePoint(sResourceType,x,y,z,size)
    --called by hook into simInit, more reliable method of figuring out if have adaptive map
    local bDebugMessages = true if M28Profiling.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'RecordResourcePoint'
    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerStart)
    if bDebugMessages == true then LOG(sFunctionRef..': sResourceType='..sResourceType..'; x='..x..'; y='..y..'; z='..z..'; size='..repru(size)..'; Mass count pre update='..table.getn(tMassPoints)..'; Hydro points pre update='..table.getn(tHydroPoints)) end

    if sResourceType == 'Mass' then
        table.insert(tMassPoints, {x,y,z})
    elseif sResourceType == 'Hydrocarbon' then
        table.insert(tHydroPoints, {x,y,z})
    end
    if bDebugMessages == true then LOG(sFunctionRef..': End of hook; Mass points post update='..table.getn(tMassPoints)..'; Hydro poitns post update='..table.getn(tHydroPoints)) end
    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerEnd)
end

function GetSegmentGroupOfLocation(sPathing, tLocation)
    return NavUtils.GetLabel(sPathing, tLocation)

end

function RecordMexForPathingGroup()
    local bDebugMessages = true if M28Profiling.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'RecordMexForPathingGroup'
    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerStart)
    if bDebugMessages == true then LOG(sFunctionRef..': About to record mexes for each pathing group. MassPoints='..repru(tMassPoints)) end
    local tsPathingTypes = {refPathingTypeAmphibious, refPathingTypeNavy, refPathingTypeLand}
    local iCurResourceGroup
    local iValidCount = 0
    tMexByPathingAndGrouping = {}
    if bDebugMessages == true then
        LOG(sFunctionRef..': NavUtils test - will cycle through each mex and get land label')
        for iMex, tMex in tMassPoints do
            LOG(sFunctionRef..': tMex='..repru(tMex)..'; Label='..(NavUtils.GetLabel('Land', tMex) or 'nil'))
            if not(NavUtils.GetLabel('Land', tMex)) then
                LOG(sFunctionRef..': Waiting 1 sec')
                WaitSeconds(1)
            end
        end
    end
    for iPathingType, sPathing in tsPathingTypes do
        tMexByPathingAndGrouping[sPathing] = {}
        iValidCount = 0

        if bDebugMessages == true then
            LOG(sFunctionRef..': About to record all mexes for pathing type sPathing='..sPathing)
        end

        for iCurMex, tMexLocation in tMassPoints do
            iValidCount = iValidCount + 1
            iCurResourceGroup = NavUtils.GetLabel(sPathing, tMexLocation)
            if not(iCurResourceGroup) then M28Utilities.ErrorHandler('Dont have a resource group for mex location '..repru(tMexLocation)..'; This is expected if mexes are located outside the playable area', true)
            else
                if bDebugMessages == true then
                    LOG(sFunctionRef..': iCurMex='..iCurMex..'; About to get segment group for pathing='..sPathing..'; location='..repru((tMexLocation or {'nil'}))..'; iCurResourceGroup='..(iCurResourceGroup or 'nil'))
                    local iSegmentX, iSegmentZ = GetPathingSegmentFromPosition(tMexLocation)
                    LOG(sFunctionRef..': Pathing segments='..(iSegmentX or 'nil')..'; iSegmentZ='..(iSegmentZ or 'nil')..'; rMapPlayableArea='..repru(rMapPlayableArea)..'; iSizeOfBaseLevelSegment='..(iSizeOfBaseLevelSegment or 'nil'))
                end
                if tMexByPathingAndGrouping[sPathing][iCurResourceGroup] == nil then
                    tMexByPathingAndGrouping[sPathing][iCurResourceGroup] = {}
                    iValidCount = 1
                else iValidCount = table.getn(tMexByPathingAndGrouping[sPathing][iCurResourceGroup]) + 1
                end
                tMexByPathingAndGrouping[sPathing][iCurResourceGroup][iValidCount] = tMexLocation
                if bDebugMessages == true then LOG(sFunctionRef..': iValidCount='..iValidCount..'; sPathing='..sPathing..'; iCurResourceGroup='..iCurResourceGroup..'; just added tMexLocation='..repru(tMexLocation)..' to this group') end
            end
        end
    end
    if bDebugMessages == true then LOG(sFunctionRef..'; tMexByPathingAndGrouping='..repru(tMexByPathingAndGrouping)) end
    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerEnd)
end

function RecordAllPlateaus()
    local bDebugMessages = true if M28Profiling.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'RecordAllPlateaus'
    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerStart)
    --Records any plateaus that contain mexes, along with info on the plateau such as a rectangle that covers the entire plateau

    --tMexByPathingAndGrouping --[a][b][c]: [a] = pathing type ('Land' etc.); [b] = Segment grouping; [c] = Mex position
    --tAllPlateausWithMexes = {} --v41 - decided to take this out to see if it helps with issue where plateau number changes and all existing platoons become invalid


    local iCurPlateauMex, iMinX, iMaxX, iMinZ, iMaxZ, iSegmentCount
    local iMinSegmentX, iMinSegmentZ, iMaxSegmentX, iMaxSegmentZ, iCurSegmentGroup

    if bDebugMessages == true then LOG(sFunctionRef..': About to get max map segment X and Z based on rMapPlayableArea='..repru(rMapPlayableArea)) end
    local iMapMaxSegmentX, iMapMaxSegmentZ = GetPathingSegmentFromPosition({rMapPlayableArea[3], 0, rMapPlayableArea[4]})
    local iStartSegmentX, iStartSegmentZ
    local bSearchingForBoundary
    local iCurCount
    local tSegmentPosition
    local iReclaimSegmentStartX, iReclaimSegmentStartZ, iReclaimSegmentEndX, iReclaimSegmentEndZ
    local sPathing = refPathingTypeAmphibious




    for iSegmentGroup, tSubtable in tMexByPathingAndGrouping[sPathing] do
        if not(tAllPlateausWithMexes[iSegmentGroup]) then

            --if not(tiBasePathingGroups[iSegmentGroup]) and not(tAllPlateausWithMexes[iSegmentGroup]) then
            --Have a plateau with mexes that havent already recorded
            tAllPlateausWithMexes[iSegmentGroup] = {}
            tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMexes] = {}
            iCurPlateauMex = 0
            for iMex, tMex in tMexByPathingAndGrouping[sPathing][iSegmentGroup] do
                iCurPlateauMex = iCurPlateauMex + 1
                tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMexes][iCurPlateauMex] = tMex
            end
            tAllPlateausWithMexes[iSegmentGroup][subrefPlateauTotalMexCount] = iCurPlateauMex
            if iCurPlateauMex > 0 then
                --Record size information

                --Start from mex, and move up on map to determine top point; then move left to determine left point, and right to determine right point
                --i.e. dont want to go through every segment on map every time since could take ages if lots of plateaus and may only be dealing with small area
                iStartSegmentX, iStartSegmentZ = GetPathingSegmentFromPosition(tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMexes][1])

                --First find the smallest z (so go up)
                bSearchingForBoundary = true
                iCurCount = 0
                while bSearchingForBoundary do
                    iCurCount = iCurCount + 1
                    if iCurCount > 10000 then
                        M28Utilities.ErrorHandler('Infinite loop')
                        break
                    end
                    --Stop if we will exceed map bounds
                    if iCurCount > iStartSegmentZ then break end
                    --Are we still in the same pathing group?
                    iCurSegmentGroup = NavUtils.GetLabel(refPathingTypeLand, GetPositionFromPathingSegments(iStartSegmentX, iStartSegmentZ - iCurCount))  --tPathingSegmentGroupBySegment[sPathing][iStartSegmentX][iStartSegmentZ - iCurCount]
                    if not(iCurSegmentGroup == iSegmentGroup) then
                        --Can we find anywhere else with the same Z value in the pathing group?
                        bSearchingForBoundary = false
                        for iAltStartX = 1, iMapMaxSegmentX do
                            iCurSegmentGroup = NavUtils.GetLabel(refPathingTypeLand, GetPositionFromPathingSegments(iAltStartX, iStartSegmentZ - iCurCount)) --tPathingSegmentGroupBySegment[sPathing][iAltStartX][iStartSegmentZ - iCurCount]
                            if iCurSegmentGroup == iSegmentGroup then
                                iStartSegmentX = iAltStartX
                                bSearchingForBoundary = true
                                break
                            end
                        end
                    end
                end
                --Will have the min Z value now
                iMinSegmentZ = iStartSegmentZ - iCurCount + 1


                --Now check for the min X value
                bSearchingForBoundary = true
                iCurCount = 0
                while bSearchingForBoundary do
                    iCurCount = iCurCount + 1
                    if iCurCount > 10000 then
                        M28Utilities.ErrorHandler('Infinite loop')
                        break
                    end
                    --Stop if we will exceed map bounds
                    if iCurCount > iStartSegmentX then break end
                    --Are we still in the same pathing group?
                    iCurSegmentGroup = NavUtils.GetLabel(refPathingTypeLand, GetPositionFromPathingSegments((iStartSegmentX - iCurCount), iStartSegmentZ)) --tPathingSegmentGroupBySegment[sPathing][iStartSegmentX - iCurCount][iStartSegmentZ]
                    if not(iCurSegmentGroup == iSegmentGroup) then
                        --Can we find anywhere else with the same X value in the pathing group?
                        bSearchingForBoundary = false
                        for iAltStartZ = iMinSegmentZ, iMapMaxSegmentZ do
                            iCurSegmentGroup = NavUtils.GetLabel(refPathingTypeLand, GetPositionFromPathingSegments((iStartSegmentX - iCurCount), iAltStartZ)) --tPathingSegmentGroupBySegment[sPathing][iStartSegmentX - iCurCount][iAltStartZ]
                            if iCurSegmentGroup == iSegmentGroup then
                                iStartSegmentZ = iAltStartZ
                                bSearchingForBoundary = true
                                break
                            end
                        end
                    end
                end

                --Will now have the min X value
                iMinSegmentX = iStartSegmentX - iCurCount + 1

                --Now get max Z value
                bSearchingForBoundary = true
                iCurCount = 0
                while bSearchingForBoundary do
                    iCurCount = iCurCount + 1
                    if iCurCount > 10000 then
                        M28Utilities.ErrorHandler('Infinite loop')
                        break
                    end
                    --Stop if we will exceed map bounds
                    if iCurCount + iStartSegmentZ > iMapMaxSegmentZ then break end
                    --Are we still in the same pathing group?
                    iCurSegmentGroup = NavUtils.GetLabel(refPathingTypeLand, GetPositionFromPathingSegments(iStartSegmentX, (iStartSegmentZ + iCurCount))) --tPathingSegmentGroupBySegment[sPathing][iStartSegmentX][iStartSegmentZ + iCurCount]
                    if not(iCurSegmentGroup == iSegmentGroup) then
                        --Can we find anywhere else with the same Z value in the pathing group?
                        bSearchingForBoundary = false
                        for iAltStartX = iMinSegmentX, iMapMaxSegmentX do
                            iCurSegmentGroup = NavUtils.GetLabel(refPathingTypeLand, GetPositionFromPathingSegments(iAltStartX, (iStartSegmentZ + iCurCount))) --tPathingSegmentGroupBySegment[sPathing][iAltStartX][iStartSegmentZ + iCurCount]
                            if iCurSegmentGroup == iSegmentGroup then
                                iStartSegmentX = iAltStartX
                                bSearchingForBoundary = true
                                break
                            end
                        end
                    end
                end
                iMaxSegmentZ = iStartSegmentZ + iCurCount - 1

                --Now get the max X value
                bSearchingForBoundary = true
                iCurCount = 0
                while bSearchingForBoundary do
                    iCurCount = iCurCount + 1
                    if iCurCount > 10000 then
                        M28Utilities.ErrorHandler('Infinite loop')
                        break
                    end
                    --Stop if we will exceed map bounds
                    if iCurCount + iStartSegmentX > iMapMaxSegmentX then break end
                    --Are we still in the same pathing group?
                    iCurSegmentGroup = NavUtils.GetLabel(refPathingTypeLand, GetPositionFromPathingSegments((iStartSegmentX + iCurCount), iStartSegmentZ)) --tPathingSegmentGroupBySegment[sPathing][iStartSegmentX + iCurCount][iStartSegmentZ]
                    if not(iCurSegmentGroup == iSegmentGroup) then
                        --Can we find anywhere else with the same Z value in the pathing group?
                        bSearchingForBoundary = false
                        for iAltStartZ = iMinSegmentZ, iMaxSegmentZ do
                            iCurSegmentGroup = NavUtils.GetLabel(refPathingTypeLand, GetPositionFromPathingSegments((iStartSegmentX + iCurCount), iAltStartZ)) --tPathingSegmentGroupBySegment[sPathing][iStartSegmentX + iCurCount][iAltStartZ]
                            if iCurSegmentGroup == iSegmentGroup then
                                iStartSegmentZ = iAltStartZ
                                bSearchingForBoundary = true
                                break
                            end
                        end
                    end
                end
                iMaxSegmentX = iStartSegmentX + iCurCount - 1

                tSegmentPosition = GetPositionFromPathingSegments(iMinSegmentX, iMinSegmentZ)
                tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMinXZ] = {tSegmentPosition[1], tSegmentPosition[3]}
                iReclaimSegmentStartX, iReclaimSegmentStartZ = GetReclaimSegmentsFromLocation(tSegmentPosition)

                tSegmentPosition = GetPositionFromPathingSegments(iMaxSegmentX, iMaxSegmentZ)
                tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMaxXZ] = {tSegmentPosition[1], tSegmentPosition[3]}
                iReclaimSegmentEndX, iReclaimSegmentEndZ = GetReclaimSegmentsFromLocation(tSegmentPosition)


                --Record all reclaim segments that are part of the plateau
                tAllPlateausWithMexes[iSegmentGroup][subrefPlateauReclaimSegments] = {}
                for iCurReclaimSegmentX = iReclaimSegmentStartX, iReclaimSegmentEndX do
                    tAllPlateausWithMexes[iSegmentGroup][subrefPlateauReclaimSegments][iCurReclaimSegmentX] = {}
                    for iCurReclaimSegmentZ = iReclaimSegmentStartZ, iReclaimSegmentEndZ do
                        if iSegmentGroup == GetSegmentGroupOfLocation(sPathing, GetReclaimLocationFromSegment(iCurReclaimSegmentX, iCurReclaimSegmentZ)) then
                            tAllPlateausWithMexes[iSegmentGroup][subrefPlateauReclaimSegments][iCurReclaimSegmentX][iCurReclaimSegmentZ] = true
                        end
                    end
                end
                --Clear any empty values
                for iCurReclaimSegmentX = iReclaimSegmentStartX, iReclaimSegmentEndX do
                    if tAllPlateausWithMexes[iSegmentGroup][subrefPlateauReclaimSegments][iCurReclaimSegmentX] and M28Utilities.IsTableEmpty(tAllPlateausWithMexes[iSegmentGroup][subrefPlateauReclaimSegments][iCurReclaimSegmentX]) then tAllPlateausWithMexes[iSegmentGroup][subrefPlateauReclaimSegments][iCurReclaimSegmentX] = nil end
                end

                --Record midpoint
                local iXRadius = (tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMaxXZ][1] - tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMinXZ][1])*0.5
                local iZRadius = (tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMaxXZ][2] - tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMinXZ][2])*0.5
                tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMidpoint] = {tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMinXZ][1] + iXRadius, 0, tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMinXZ][2] + iZRadius}
                tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMidpoint][2] = GetTerrainHeight(tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMidpoint][1], tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMidpoint][3])
                --CIrcle radius will be the square/rectangle diagonal, so (square radius^2*2)^0.5 for a square, or (x^2+z^2)^0.5

                tAllPlateausWithMexes[iSegmentGroup][subrefPlateauMaxRadius] = (iXRadius^2+iZRadius^2)^0.5
            end
        end
    end
    if bDebugMessages == true then LOG(sFunctionRef..': End of code, listing tAllPlateausWithMexes='..repru(tAllPlateausWithMexes)) end
    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerEnd)
end

function SetupLandZones()
    --Divdeds the map into land pathable zones based on mex placement
    --Intended to be called at start of game when AI is created (so after siminit and recordresourcepoints has run)

    local bDebugMessages = true if M28Profiling.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'SetupLandZones'
    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerStart)
    if bDebugMessages == true then LOG('About to setup land zones') end

    --Decide on zone size
    local iHighestSize = math.max(rMapPlayableArea[3] - rMapPlayableArea[1], rMapPlayableArea[4] - rMapPlayableArea[2])
    local iTableSizeCap = 50000

    --50000 = SegmentCount^2; SegmentCount = iTotalSize / SegmentSize; (TotalSize/SegmentSize)^2 = 50k; SemgentSize = TotalSize/Sqrt(50k)

    iLandZoneSegmentSize = math.ceil(iHighestSize / math.sqrt(iTableSizeCap))

    if bDebugMessages == true then LOG(sFunctionRef..': iHighestSize='..iHighestSize..'; iTableSizeCap='..iTableSizeCap..'; iLandZoneSegmentSize='..iLandZoneSegmentSize) end

    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerEnd)
end

function SetupMap()
    --Sets up non-brain specific info on the map
    local bDebugMessages = true if M28Profiling.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'SetupMap'
    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerStart)


    if ScenarioInfo.MapData.PlayableRect then
        rMapPlayableArea = ScenarioInfo.MapData.PlayableRect
    else
        rMapPlayableArea = {0, 0, ScenarioInfo.size[1], ScenarioInfo.size[2]}
    end

    RecordMexForPathingGroup()

    RecordAllPlateaus()

    SetupLandZones()

    M28Profiling.FunctionProfiler(sFunctionRef, M28Profiling.refProfilerEnd)
end

