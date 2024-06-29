---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 25/06/2023 18:40
---
--safeGetGlobal provided by ChatGPT
local function safeGetGlobal(varName)
    local value = rawget(_G, varName)
    if value then
        return value
    else
        return nil
    end
    --[[local success, value = pcall(function() return _G[varName] end)
    if success then
        return value
    else
        return nil
    end--]]
end

local function AltGetGlobal(varName)
    local success, value = pcall(function() return _G[varName] end)
    if success then
        return value
    else
        return nil
    end
end

local M28OldACreateArmyGroupAsPlatoon
if safeGetGlobal('CreateArmyGroupAsPlatoon') then M28OldACreateArmyGroupAsPlatoon = CreateArmyGroupAsPlatoon end --safeGetGlobal('CreateArmyGroupAsPlatoon') or function() end

if M28OldACreateArmyGroupAsPlatoon then
    --_G.CreateArmyGroupAsPlatoon = function(strArmy, strGroup, formation, tblNode, platoon, balance)
    CreateArmyGroupAsPlatoon = function(strArmy, strGroup, formation, tblNode, platoon, balance)
        --LOG('CreateArmyGroupAsPlatoon start')
        local oPlatoon = M28OldACreateArmyGroupAsPlatoon(strArmy, strGroup, formation, tblNode, platoon, balance)

        ForkThread(import('/mods/M28AI/lua/AI/M28Events.lua').ScenarioPlatoonCreated, oPlatoon, strArmy, strGroup, formation, tblNode, platoon, balance)
        return oPlatoon
    end
    LOG('Hooked CreateArmyGroupAsPlatoon')
else
    LOG('Unable to hook CreateArmyGroupAsPlatoon')
end

--[[local M28OldACreateArmyGroupAsPlatoon = CreateArmyGroupAsPlatoon
---@param strArmy string
---@param strGroup string
---@param formation any
---@param tblNode table
---@param platoon --Platoon
---@param balance any
---@return --Platoon|nil
CreateArmyGroupAsPlatoon = function(strArmy, strGroup, formation, tblNode, platoon, balance)
    --LOG('CreateArmyGroupAsPlatoon start')
    local oPlatoon = M28OldACreateArmyGroupAsPlatoon(strArmy, strGroup, formation, tblNode, platoon, balance)

    ForkThread(import('/mods/M28AI/lua/AI/M28Events.lua').ScenarioPlatoonCreated, oPlatoon, strArmy, strGroup, formation, tblNode, platoon, balance)
    return oPlatoon
end
    --]]

local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
M28Utilities.ConsiderIfLoudActive()

local M28Events = import('/mods/M28AI/lua/AI/M28Events.lua')

--LOG('safeGetGlobal InitializeSkirmishSystems ='..tostring(safeGetGlobal('InitializeSkirmishSystems') or false)..'; AltGetGlobal(varName)='..tostring(AltGetGlobal('InitializeSkirmishSystems' or false)))

--NOTE: For some reason we cant do a non-destructiveh ook of InitializeSkirmishSystems, as the safeGetGlobal and other attempts dont trigger when this is loaded in LOUD; will therefore do destructive hook
--if OrigInitializeSkirmishSystems then --safeGetGlobal('InitializeSkirmishSystems') then
    --OrigInitializeSkirmishSystems = InitializeSkirmishSystems
    InitializeSkirmishSystems = function(self)
        LOG('Hook active for InitializeSkirmishSystems')
        if M28Utilities.bLoudModActive then
            import('/mods/M28AI/lua/AI/M28Overseer.lua').bBeginSessionTriggered = true --needed for M28 code to run and not get stuck in a loop
            local LoudCompatibility = import('/mods/M28AI/lua/AI/LOUD/M28OtherLOUDCompatibility.lua')
            LoudCompatibility.UpdateUnitCategories()
            local oBrain = self
            LOG('oBrain='..(oBrain.Nickname or 'nil')..' with index='..oBrain:GetArmyIndex()..': ArmyIsCivilian(oBrain)='..tostring(ArmyIsCivilian(oBrain:GetArmyIndex()))..'; Brain type is AI='..tostring( oBrain.BrainType == 'AI')..'; .CheatValue='..(oBrain.CheatValue or 'nil')..'; .CheatingAI='..tostring(oBrain.CheatingAI or false))
            if oBrain.BrainType == 'AI' and not(ArmyIsCivilian(oBrain:GetArmyIndex())) then
                --If we have no team, or our team is an odd number, then use M28
                local iTeam = oBrain.Team or ScenarioInfo.ArmySetup[oBrain.Name].Team or -1
                LOG('WIll consider applying M28 logic if are an odd team or not specified, iTeam='..iTeam..'; ScenarioInfo.Options.M28Teams='..(ScenarioInfo.Options.M28Teams or 'nil')..'; M28Utilities.DoesAINicknameContainM28(oBrain.Nickname)='..tostring(M28Utilities.DoesAINicknameContainM28(oBrain.Nickname)))
                if M28Utilities.DoesAINicknameContainM28(oBrain.Nickname) or tonumber(ScenarioInfo.Options.M28Teams) == 3 or (tonumber(ScenarioInfo.Options.M28Teams) == 2 and (iTeam <= 0 or iTeam == 1 or iTeam == 3 or iTeam == 5 or iTeam == 7)) then
                    LOG('Will apply M28 logic to the AI')
                    oBrain.M28AI = true
                    if ScenarioInfo.Options.CmM28Easy == 1 then
                        oBrain.M28Easy = true
                    end
                    M28Utilities.bM28AIInGame = true
                    if ScenarioInfo.Options.CmApplyAIx == 1 then oBrain.CheatEnabled = true end
                    ForkThread(M28Events.OnCreateBrain, oBrain, nil, false)
                end
            end

            if self.M28AI or self.M28Easy then
                self.CheatingAI = false

                -- Base counters
                self.NumBases = 0
                self.NumBasesLand = 0
                self.NumBasesNaval = 0

                -- Veterancy multiplier
                self.VeterancyMult = 1.0

                -- Create the SelfUpgradeIssued counter
                -- holds the number of units that have recently issued a self-upgrade
                -- is used to limit the # of self-upgrades that can be issued in a given time
                -- to avoid having more than X units trying to upgrade at once
                self.UpgradeIssued = 0

                self.UpgradeIssuedLimit = 1
                self.UpgradeIssuedPeriod = 225

                -- if outnumbered increase the number of simultaneous upgrades allowed
                -- and reduce the waiting period by 2 seconds ( about 10% )
                if self.OutnumberedRatio > 1.0 then

                    self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                    self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                    -- if really outnumbered do this a second time
                    if self.OutnumberedRatio > 1.5 then

                        self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                        self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                        -- if really badly outnumbered then we do it a 3rd time
                        if self.OutnumberedRatio > 2.0 then

                            self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                            self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                        end
                    end
                end

                LOG("*AI DEBUG "..self.Nickname.." Upgrade Issued Limit is "..self.UpgradeIssuedLimit.." Standard Upgraded Issued Delay Period is "..self.UpgradeIssuedPeriod )

                -- set the base radius according to map size -- affects platoon formation radius and base alert radius


                -- record the starting unit cap
                -- caps of 1000+ trigger some conditions
                self.StartingUnitCap = GetArmyUnitCap(self.ArmyIndex)

                --if self.CheatingAI then
                    import('/lua/ai/aiutilities.lua').SetupAICheat( self )
                --end

                return
            else
                LOG('Calling normal LOUD OrigInitializeSkirmishSystems logic for brain '..self.Nickname)
                --OrigInitializeSkirmishSystems(self) --Get an error when using the default function - the below was copied from the LOUD version in early-mid June 2024

                -- don't do anything else for a human player
                if self.BrainType == 'Human' then
                    return
                end

                -- put some initial threat at all enemy positions
                for k,brain in ArmyBrains do

                    if self.ArmyIndex != brain.ArmyIndex and brain.Nickname != 'civilian' and (not brain:IsDefeated()) and (not IsAlly(self.ArmyIndex, brain.ArmyIndex)) then

                local place = brain:GetStartVector3f()
                local threatlayer = 'AntiAir'

                --LOG("*AI DEBUG "..brain.Nickname.." "..brain.BrainType.." enemy found at "..repr(place).." posting Economy threat")

                -- assign 500 ecothreat for 10 minutes
                self:AssignThreatAtPosition( place, 5000, 0.005, 'Economy' )
                end
                end

                if ScenarioInfo.Options.AIResourceSharing == 'off' then

                    self:SetResourceSharing(false)

                elseif ScenarioInfo.Options.AIResourceSharing == 'aiOnly' then

                    for i, playerInfo in ArmyBrains do

                        -- If this AI is allied to a human, disable resource sharing
                        if IsAlly(i, self.ArmyIndex) and playerInfo.BrainType == 'Human' then

                            self:SetResourceSharing(false)
                            break
                        end
                    end

                else
                    self:SetResourceSharing(true)
                end

                -- Create the Condition monitor
                self.ConditionsMonitor = import('/lua/sim/BrainConditionsMonitor.lua').CreateConditionsMonitor(self)

                -- Create the Economy Data structures and start Economy monitor thread
                self:ForkThread1(loudUtils.EconomyMonitor)

                -- Base counters
                self.NumBases = 0
                self.NumBasesLand = 0
                self.NumBasesNaval = 0

                -- Veterancy multiplier
                self.VeterancyMult = 1.0

                -- Create the SelfUpgradeIssued counter
                -- holds the number of units that have recently issued a self-upgrade
                -- is used to limit the # of self-upgrades that can be issued in a given time
                -- to avoid having more than X units trying to upgrade at once
                self.UpgradeIssued = 0

                self.UpgradeIssuedLimit = 1
                self.UpgradeIssuedPeriod = 225

                -- if outnumbered increase the number of simultaneous upgrades allowed
                -- and reduce the waiting period by 2 seconds ( about 10% )
                if self.OutnumberedRatio > 1.0 then

                    self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                    self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                    -- if really outnumbered do this a second time
                    if self.OutnumberedRatio > 1.5 then

                        self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                        self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                        -- if really badly outnumbered then we do it a 3rd time
                        if self.OutnumberedRatio > 2.0 then

                            self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                            self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                        end
                    end
                end

                LOG("*AI DEBUG "..self.Nickname.." Upgrade Issued Limit is "..self.UpgradeIssuedLimit.." Standard Upgraded Issued Delay Period is "..self.UpgradeIssuedPeriod )

                -- set the base radius according to map size -- affects platoon formation radius and base alert radius
                local mapSizex = ScenarioInfo.size[1]

                local BuilderRadius = math.max(90, (mapSizex/16)) -- should give a range between 90 and 256+
                local BuilderRadius = math.min(BuilderRadius, 140) -- and then limit it to no more than 140

                local RallyPointRadius = 49	-- create automatic rally points at 49 from centre

                -- Set the flag that notes if an expansion base is being setup -- when an engineer takes on an expansion task, he'll set this flag to true
                -- when he dies or starts building the new base, he'll set it back to false
                -- we use this to keep the AI from doing more than one expansion at a time
                self.BaseExpansionUnderway = false

                -- level AI starting locations
                --loudUtils.LevelStartBaseArea(self:GetStartVector3f(), RallyPointRadius )

                -- Create the Builder Managers for the MAIN base
                self:AddBuilderManagers(self:GetStartVector3f(), BuilderRadius, 'MAIN', false, RallyPointRadius, true, 'FRONT')

                -- turn on the PrimaryLandAttackBase flag for MAIN
                self.BuilderManagers.MAIN.PrimaryLandAttackBase = true
                self.PrimaryLandAttackBase = 'MAIN'

                -- Create the Strategy Manager (disabled) from the Sorian AI
                --self.BuilderManagers.MAIN.StrategyManager = StratManager.CreateStrategyManager(self, 'MAIN', self:GetStartVector3f(), 100)

                -- create Persistent Pool platoons

                -- for isolating structures (used by LOUD AI)
                local structurepool = self:MakePlatoon('StructurePool','none')

                structurepool:UniquelyNamePlatoon('StructurePool')
                structurepool.BuilderName = 'Struc'
                structurepool.UsingTransport = true     -- insures that it never gets reviewed in a merge operation

                self.StructurePool = structurepool

                -- for isolating aircraft low on fuel (used by LOUD AI)
                local refuelpool = self:MakePlatoon('RefuelPool','none')

                refuelpool:UniquelyNamePlatoon('RefuelPool')
                refuelpool.BuilderName = 'Refuel'
                refuelpool.UsingTransport = true        -- never gets reviewed in a merge --

                self.RefuelPool = refuelpool

                -- the standard Army Pool
                local armypool = self:GetPlatoonUniquelyNamed('ArmyPool')

                armypool:UniquelyNamePlatoon('ArmyPool')
                armypool.BuilderName = 'Army'

                self.ArmyPool = armypool

                -- Start the Dead Base Monitor
                self:ForkThread1( loudUtils.DeadBaseMonitor )

                -- Start the Enemy Picker (AttackPlanner, etc)
                self.EnemyPickerThread = self:ForkThread( loudUtils.PickEnemy )

                -- Start the Path Generator
                self:ForkThread1( loudUtils.PathGeneratorThread )

                -- start PlatoonDistressMonitor
                self:ForkThread1( loudUtils.PlatoonDistressMonitor )

                -- start watching the intel data
                self:ForkThread1( loudUtils.ParseIntelThread )

                -- record the starting unit cap
                -- caps of 1000+ trigger some conditions
                self.StartingUnitCap = GetArmyUnitCap(self.ArmyIndex)

                if self.CheatingAI then
                    import('/lua/ai/aiutilities.lua').SetupAICheat( self )
                end

                if self.OutnumberedRatio > 1.5 and (self.VeterancyMult < self.OutnumberedRatio) then

                    local AISendChat = import('/lua/ai/sorianutilities.lua').AISendChat

                    ForkThread( AISendChat, 'enemies', self.Nickname, "WOW - Why dont you just beat me with a stick?" )
                    ForkThread( AISendChat, 'enemies', self.Nickname, "You Outnumber me "..tostring(self.OutnumberedRatio).." to 1 !")
                    ForkThread( AISendChat, 'enemies', self.Nickname, "And all you give me is a "..tostring(self.VeterancyMult).." bonus?")

                end
            end
        else
            LOG('Calling normal OrigInitializeSkirmishSystems logic for brain '..self.Nickname)
            OrigInitializeSkirmishSystems(self)
        end
end

--[[local OrigInitializeArmies = InitializeArmies
InitializeArmies = function()
    --M28ParentDetails.ConsiderIfLoudActive() --done earlier now
    LOG('M28 InitializeArmies start, M28Utilities.bLoudModActive='..tostring(M28Utilities.bLoudModActive or false))
    if M28Utilities.bLoudModActive then
        if ArmyBrains then
            import('/mods/M28AI/lua/AI/M28Overseer.lua').bBeginSessionTriggered = true --needed for M28 code to run and not get stuck in a loop
            for iBrain, oBrain in ArmyBrains do
                LOG('oBrain='..(oBrain.Nickname or 'nil')..'; ArmyIsCivilian(oBrain)='..tostring(ArmyIsCivilian(oBrain:GetArmyIndex()))..'; Brain type is AI='..tostring( oBrain.BrainType == 'AI'))
                if oBrain.BrainType == 'AI' and not(ArmyIsCivilian(oBrain:GetArmyIndex())) then
                    --If we have no team, or our team is an odd number, then use M28
                    local iTeam = oBrain.Team or ScenarioInfo.ArmySetup[oBrain.Name].Team or -1
                    LOG('WIll consider applying M28 logic if are an odd team or not specified, iTeam='..iTeam..'; ScenarioInfo.Options.M28Teams='..(ScenarioInfo.Options.M28Teams or 'nil'))
                    if tonumber(ScenarioInfo.Options.M28Teams) == 2 or iTeam <= 0 or iTeam == 1 or iTeam == 3 or iTeam == 5 or iTeam == 7 then
                        LOG('Will apply M28 logic to the AI')
                        oBrain.M28AI = true
                        if ScenarioInfo.Options.CmM28Easy == 1 then
                            oBrain.M28Easy = true
                        end
                        M28Utilities.bM28AIInGame = true
                        if ScenarioInfo.Options.CmApplyAIx == 1 then oBrain.CheatEnabled = true end
                        ForkThread(M28Events.OnCreateBrain, oBrain, nil, false)
                    end
                end
            end
        end

        local loudUtils = import('/lua/loudutilities.lua')

        --Loop through active mods
        for i, m in __active_mods do

            -- Some custom Scenario variables to support certain mods

            if m.name == 'Metal World' then
                LOG("*AI DEBUG METAL WORLD Installed")
                ScenarioInfo.MetalWorld = true
            end

            if m.name == 'Mass Point RNG' then
                LOG("*AI DEBUG Mass Point RNG Installed")
                ScenarioInfo.MassPointRNG = true
            end

        end

        import('/lua/sim/scenarioutilities.lua').CreateResources()

        import('/lua/sim/scenarioutilities.lua').CreateProps()

        ScenarioInfo.biggestTeamSize = 0

        local function InitializeSkirmishSystems(self)
            if self.M28AI or self.M28Easy then
                self.CheatingAI = false
            end
            -- store which team we're on
            if ScenarioInfo.ArmySetup[self.Name].Team == 1 then
                self.Team = -1 * self.ArmyIndex  -- no team specified
            else
                self.Team = ScenarioInfo.ArmySetup[self.Name].Team  -- specified team number
            end

            local Opponents = 0
            local TeamSize = 1

            -- calculate team sizes
            for index, playerInfo in ArmyBrains do

                if ArmyIsCivilian(playerInfo.ArmyIndex) or index == self.ArmyIndex then continue end

                if IsAlly( index, self.ArmyIndex) then
                    TeamSize = TeamSize + 1
                else
                    Opponents = Opponents + 1
                end

            end

            local color = ScenarioInfo.ArmySetup[self.Name].WheelColor

            SetArmyColor(self.ArmyIndex, color[1], color[2], color[3])

            -- Don't need WheelColor anymore, so delete it
            ScenarioInfo.ArmySetup[self.Name].WheelColor = nil

            if ScenarioInfo.Options.AIFactionColor == 'on' and self.BrainType ~= 'Human' then
                -- These colours are based on the lobby faction dropdown icons
                if self.FactionIndex == 1 then
                    SetArmyColor(self.ArmyIndex, 44, 159, 200)
                elseif self.FactionIndex == 2 then
                    SetArmyColor(self.ArmyIndex, 104, 171, 77)
                elseif self.FactionIndex == 3 then
                    SetArmyColor(self.ArmyIndex, 255, 0, 0)
                elseif self.FactionIndex == 4 then
                    SetArmyColor(self.ArmyIndex, 254, 189, 44)
                end
            end

            -- number of Opponents in the game
            self.NumOpponents = Opponents

            -- default outnumbered ratio
            self.OutnumberedRatio = 1

            -- number of players in the game
            self.Players = ScenarioInfo.Options.PlayerCount

            LOG("*AI DEBUG "..self.Nickname.." Team "..self.Team.." Teamsize is "..TeamSize.." Opponents is "..Opponents)

            self.TeamSize = TeamSize

            if self.TeamSize > ScenarioInfo.biggestTeamSize then
                ScenarioInfo.biggestTeamSize = TeamSize
            end
            if self.M28AI or self.M28Easy then return end
            -- don't do anything else for a human player
            if self.BrainType == 'Human' then
                return
            end

            self.OutnumberedRatio = math.max( 1, ScenarioInfo.biggestTeamSize/self.TeamSize )

            if self.OutnumberedRatio > 1 then
                LOG("*AI DEBUG "..self.Nickname.." OutnumberedRatio is "..self.OutnumberedRatio)
            end

            -- put some initial threat at all enemy positions
            for k,brain in ArmyBrains do

                --LOG("*AI DEBUG Reviewing Brain "..repr(brain.Nickname).." "..repr(brain) )

                if not(self.ArmyIndex == brain.ArmyIndex) and not(brain.Nickname == 'civilian') and (not brain:IsDefeated()) and (not IsAlly(self.ArmyIndex, brain.ArmyIndex)) then

            local place = brain:GetStartVector3f()
            local threatlayer = 'AntiAir'

            --LOG("*AI DEBUG "..brain.Nickname.." "..brain.BrainType.." enemy found at "..repr(place).." posting Economy threat")

            -- assign 500 ecothreat for 10 minutes
            self:AssignThreatAtPosition( place, 5000, 0.005, 'Economy' )
            end
            end

            if ScenarioInfo.Options.AIResourceSharing == 'off' then

                self:SetResourceSharing(false)

            elseif ScenarioInfo.Options.AIResourceSharing == 'aiOnly' then

                local allPlayersAI = true

                for i, playerInfo in ArmyBrains do

                    -- If this AI is allied to a human, disable resource sharing
                    if IsAlly(i, self.ArmyIndex) and playerInfo.BrainType == 'Human' then

                        self:SetResourceSharing(false)
                        break

                    end

                end

            else
                self:SetResourceSharing(true)
            end

            -- Create the Condition monitor
            self.ConditionsMonitor = import('/lua/sim/BrainConditionsMonitor.lua').CreateConditionsMonitor(self)

            -- Create the Economy Data structures and start Economy monitor thread
            self:ForkThread1(loudUtils.EconomyMonitor)

            -- Base counters
            self.NumBases = 0
            self.NumBasesLand = 0
            self.NumBasesNaval = 0

            -- Veterancy multiplier
            self.VeterancyMult = 1.0

            -- Create the SelfUpgradeIssued counter
            -- holds the number of units that have recently issued a self-upgrade
            -- is used to limit the # of self-upgrades that can be issued in a given time
            -- to avoid having more than X units trying to upgrade at once
            self.UpgradeIssued = 0

            self.UpgradeIssuedLimit = 1
            self.UpgradeIssuedPeriod = 225

            -- if outnumbered increase the number of simultaneous upgrades allowed
            -- and reduce the waiting period by 2 seconds ( about 10% )
            if self.OutnumberedRatio > 1.0 then

                self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                -- if really outnumbered do this a second time
                if self.OutnumberedRatio > 1.5 then

                    self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                    self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                    -- if really badly outnumbered then we do it a 3rd time
                    if self.OutnumberedRatio > 2.0 then

                        self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                        self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20

                    end
                end
            end

            LOG("*AI DEBUG "..self.Nickname.." Upgrade Issued Limit is "..self.UpgradeIssuedLimit.." Standard Upgraded Issued Delay Period is "..self.UpgradeIssuedPeriod )

            -- set the base radius according to map size -- affects platoon formation radius and base alert radius
            local mapSizex = ScenarioInfo.size[1]

            local BuilderRadius = math.max(90, (mapSizex/16)) -- should give a range between 90 and 256+
            local BuilderRadius = math.min(BuilderRadius, 140) -- and then limit it to no more than 140

            local RallyPointRadius = 49	-- create automatic rally points at 49 from centre

            -- Set the flag that notes if an expansion base is being setup -- when an engineer takes on an expansion task, he'll set this flag to true
            -- when he dies or starts building the new base, he'll set it back to false
            -- we use this to keep the AI from doing more than one expansion at a time
            self.BaseExpansionUnderway = false

            -- level AI starting locations
            --loudUtils.LevelStartBaseArea(self:GetStartVector3f(), RallyPointRadius )

            -- Create the Builder Managers for the MAIN base
            self:AddBuilderManagers(self:GetStartVector3f(), BuilderRadius, 'MAIN', false, RallyPointRadius, true, 'FRONT')

            -- turn on the PrimaryLandAttackBase flag for MAIN
            self.BuilderManagers.MAIN.PrimaryLandAttackBase = true
            self.PrimaryLandAttackBase = 'MAIN'

            -- Create the Strategy Manager (disabled) from the Sorian AI
            --self.BuilderManagers.MAIN.StrategyManager = StratManager.CreateStrategyManager(self, 'MAIN', self:GetStartVector3f(), 100)

            -- create Persistent Pool platoons

            -- for isolating structures (used by LOUD AI)
            local structurepool = self:MakePlatoon('StructurePool','none')

            structurepool:UniquelyNamePlatoon('StructurePool')
            structurepool.BuilderName = 'Struc'
            structurepool.UsingTransport = true     -- insures that it never gets reviewed in a merge operation

            self.StructurePool = structurepool

            -- for isolating aircraft low on fuel (used by LOUD AI)
            local refuelpool = self:MakePlatoon('RefuelPool','none')

            refuelpool:UniquelyNamePlatoon('RefuelPool')
            refuelpool.BuilderName = 'Refuel'
            refuelpool.UsingTransport = true        -- never gets reviewed in a merge --

            self.RefuelPool = refuelpool

            -- the standard Army Pool
            local armypool = self:GetPlatoonUniquelyNamed('ArmyPool')

            armypool:UniquelyNamePlatoon('ArmyPool')
            armypool.BuilderName = 'Army'

            self.ArmyPool = armypool


            -- Start the Dead Base Monitor
            self:ForkThread1( loudUtils.DeadBaseMonitor )

            -- Start the Enemy Picker
            self:ForkThread1( loudUtils.PickEnemy )

            -- Start the Path Generator
            self:ForkThread1( loudUtils.PathGeneratorThread )

            -- start PlatoonDistressMonitor
            self:ForkThread1( loudUtils.PlatoonDistressMonitor )

            -- start watching the intel data
            self:ForkThread1( loudUtils.ParseIntelThread )

            -- record the starting unit cap
            -- caps of 1000+ trigger some conditions
            self.StartingUnitCap = GetArmyUnitCap(self.ArmyIndex)

            if self.CheatingAI then
                import('/lua/ai/aiutilities.lua').SetupAICheat( self )
            end

            if self.OutnumberedRatio > 1.5 and (self.VeterancyMult < self.OutnumberedRatio) then

                local AISendChat = import('/lua/ai/sorianutilities.lua').AISendChat

                ForkThread( AISendChat, 'enemies', self.Nickname, "WOW - Why dont you just beat me with a stick?" )
                ForkThread( AISendChat, 'enemies', self.Nickname, "You Outnumber me "..tostring(self.OutnumberedRatio).." to 1 !")
                ForkThread( AISendChat, 'enemies', self.Nickname, "And all you give me is a "..tostring(self.VeterancyMult).." bonus?")

            end

        end


        local tblGroups = {}
        local tblArmy = ListArmies()

        local civOpt = ScenarioInfo.Options.CivilianAlliance
        local bCreateInitial = ShouldCreateInitialArmyUnits()

        -- setup teams and civilians, add custom units, wrecks
        -- call out to Initialize SkirimishSystems (a great deal of AI setup)
        for iArmy, strArmy in pairs(tblArmy) do

            -- release some data we don't need anymore
            ScenarioInfo.ArmySetup[strArmy].BadMap = nil
            ScenarioInfo.ArmySetup[strArmy].LEM = nil
            ScenarioInfo.ArmySetup[strArmy].MapVersion = nil
            ScenarioInfo.ArmySetup[strArmy].Ready = nil
            ScenarioInfo.ArmySetup[strArmy].StartSpot = nil

            local tblData = ScenarioInfo.Env.Scenario.Armies[strArmy]
            local armyIsCiv = ScenarioInfo.ArmySetup[strArmy].Civilian

            tblGroups[ strArmy ] = {}

            if tblData then

                -- setup neutral/enemy status of civlians --
                -- and allied status of other players --
                for iEnemy, strEnemy in pairs(tblArmy) do

                    local enemyIsCiv = ScenarioInfo.ArmySetup[strEnemy].Civilian

                    -- if another army and you AND they are NOT NEUTRAL civilians --
                    if not(iArmy == iEnemy) and not(strArmy == 'NEUTRAL_CIVILIAN') and not(strEnemy == 'NEUTRAL_CIVILIAN') then

                if (armyIsCiv or enemyIsCiv) and civOpt == 'neutral' then
                SetAlliance( iArmy, iEnemy, 'Neutral')
                else
                SetAlliance( iArmy, iEnemy, 'Enemy')
                end

                -- in order to be ALLIED - players must be on specific teams --
                if not(ScenarioInfo.ArmySetup[strArmy].Team == 1) then

                if ScenarioInfo.ArmySetup[strArmy].Team == ScenarioInfo.ArmySetup[strEnemy].Team then
                SetAlliance( iArmy, iEnemy, 'Ally')
                end

                end

                -- if only they are NEUTRAL civilians
                elseif strArmy == 'NEUTRAL_CIVILIAN' or strEnemy == 'NEUTRAL_CIVILIAN' then

                SetAlliance( iArmy, iEnemy, 'Neutral')
                    end

                end

                -- if this is not civilian - mark the use of certain mods
                -- and add custom unit tables to each AI
                if not armyIsCiv then
                    loudUtils.AddCustomUnitSupport(GetArmyBrain(strArmy))
                end

                SetArmyEconomy( strArmy, tblData.Economy.mass, tblData.Economy.energy)

                if not armyIsCiv then
                    -- this insures proper setting of teammate counts and
                    -- calculation of the largest team size for ALL players (human and AI)
                    InitializeSkirmishSystems( GetArmyBrain(strArmy) )
                end

                if (not armyIsCiv and bCreateInitial) or (armyIsCiv and not(civOpt == 'removed')) then

            local commander = (not ScenarioInfo.ArmySetup[strArmy].Civilian)
            local cdrUnit

            tblGroups[strArmy], cdrUnit = CreateInitialArmyGroup( strArmy, commander)

            if commander and cdrUnit and ArmyBrains[iArmy].Nickname then
            cdrUnit:SetCustomName( ArmyBrains[iArmy].Nickname )
            end

            end

            local wreckageGroup = FindUnitGroup('WRECKAGE', ScenarioInfo.Env.Scenario.Armies[strArmy].Units)

            -- if there is wreckage to be created --
            if wreckageGroup then

            local platoonList, tblResult, treeResult = CreatePlatoons(strArmy, wreckageGroup )

            for num,unit in tblResult do
            -- all wrecks created here get 1800 second lifetime (30 minutes)
            unit:CreateWreckageProp(0, 1800)
            unit:Destroy()
                end

                end

            end

        end



        if ScenarioInfo.Env.Scenario.Areas.AREA_1 then

            LOG("*AI DEBUG ScenarioInfo Map is "..repr(ScenarioInfo.Env.Scenario.Areas) )



            import('/lua/scenarioframework.lua').SetPlayableArea( 'AREA_1', false )

        end

        ScenarioInfo.Configurations = nil

        ScenarioInfo.TeamMassPointList = {}

        --3+ Teams Unit Cap Fix, setting up the Unit Cap part of SetupAICheat,
        -- get each AI to build it's scouting locations
        -- now that we know what is the number of armies in the biggest team.
        for _, strArmy in tblArmy do

            local armyIsCiv = ScenarioInfo.ArmySetup[strArmy].Civilian

            local aiBrain = GetArmyBrain(strArmy)

            if aiBrain.BrainType == 'AI' and not armyIsCiv then

                loudUtils.BuildScoutLocations(aiBrain)

                import('/lua/ai/aiutilities.lua').SetupAICheatUnitCap( aiBrain, ScenarioInfo.biggestTeamSize )

                if not ScenarioInfo.TeamMassPointList[aiBrain.Team] then

                    LOG("*AI DEBUG Creating Starting Mass Point List for Team "..aiBrain.Team)

                    ScenarioInfo.TeamMassPointList[aiBrain.Team] = {}

                    -- each team is intially allocated the entire mass point list
                    if ScenarioInfo.StartingMassPointList[1] then
                        ScenarioInfo.TeamMassPointList[aiBrain.Team] = table.copy(ScenarioInfo.StartingMassPointList)
                    end

                end

                aiBrain.StartingMassPointList = {}  -- initialize starting mass point list for this brain

                -- each brain can store a different amount of points, based upon team size, player count and OutnumberedRatio
                aiBrain.MassPointShare = math.min( 12 + ScenarioInfo.Options.PlayerCount, math.floor(ScenarioInfo.NumMassPoints/ScenarioInfo.Options.PlayerCount) - 1)

                if aiBrain.OutnumberedRatio >= aiBrain.CheatValue then
                    aiBrain.MassPointShare = math.min( math.floor(ScenarioInfo.NumMassPoints/ScenarioInfo.Options.PlayerCount), math.floor(aiBrain.MassPointShare * (aiBrain.OutnumberedRatio/aiBrain.CheatValue)))
                end
            end

        end

        for k, v in ScenarioInfo.TeamMassPointList do

            LOG("*AI DEBUG Processing TeamMassPoints for team "..repr(k))

            local count = 0
            local apply = true

            while apply do

                apply = false

                for a, brain in ArmyBrains do

                    if count < brain.MassPointShare then

                        if brain.BrainType == 'AI' and brain.Team == k then

                            if count == 0 then
                                LOG("*AI DEBUG "..brain.Nickname.." storing "..brain.MassPointShare.." Mass Points")
                            end

                            local Position = { brain.StartPosX, 0, brain.StartPosZ }

                            -- sort the list for closest
                            table.sort(ScenarioInfo.TeamMassPointList[brain.Team], function(a,b) return VDist3( a.Position, Position ) < VDist3( b.Position, Position) end )

                            -- take the closest one and remove it from master list
                            table.insert( brain.StartingMassPointList, table.remove( ScenarioInfo.TeamMassPointList[brain.Team], 1 ))

                            apply = true

                        end

                    else
                        --if brain.BrainType == 'AI' and brain.Team == k and count == brain.MassPointShare + 1 then
                        --  LOG("*AI DEBUG "..brain.Nickname.." Starting Mass Point list is "..repr(brain.StartingMassPointList))
                        --end
                    end

                end

                count = count + 1

            end

        end

        loudUtils.StartAdaptiveCheatThreads()

        --loudUtils.StartSpeedProfile()     -- this was a crude benchmarking tool

        ScenarioInfo.StartingMassPointList = nil
        ScenarioInfo.TeamMassPointList = nil

        ScenarioInfo.Options.AIResourceSharing = nil
        ScenarioInfo.Options.AIFactionColor = nil

        return tblGroups
    else
        OrigInitializeArmies()
    end
end--]]