local M28Overseer = import('/mods/M28AI/lua/AI/M28Overseer.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')
local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')
local M28Config = import('/mods/M28AI/lua/M28Config.lua')
local M28Events = import('/mods/M28AI/lua/AI/M28Events.lua')

--Note - looks like this logic may be moved to lua\aibrains\base-ai.lua at some point based on FAF develop (as at May 2023)
--In theory the below shouldt be needed once the FAF-Develop changes are integrated into FAF (expected June 2023), although probably no harm leaving for backwards compatibility
--Superceded from the June 2023 changes by M28Brain.lua and index.lua
    --V24 - removed the below as couldn't get the new appraoch (which requires map to be generated later than OnCreateAI triggers) to work with this code still here

M28AIBrainClass = AIBrain
AIBrain = Class(M28AIBrainClass) {

    OnDefeat = function(self)
        M28AIBrainClass.OnDefeat(self)
        if M28Utilities.bSteamActive then
            ForkThread(M28Events.OnPlayerDefeated, self)
        end
    end,

    OnCreateAI = function(self, planName)
        if M28Utilities.bSteamActive then
            local M28Conditions = import('/mods/M28AI/lua/AI/M28Conditions.lua')
            --Only apply M28 to easy and normal
            LOG('Brain OnCreateAI for brain'..self.Nickname..' with personality '..(self.Personality or ScenarioInfo.ArmySetup[self.Name].AIPersonality or 'nil'))
            local sPersonality = self.Personality or ScenarioInfo.ArmySetup[self.Name].AIPersonality
            if not(M28Conditions.IsCivilianBrain(self)) and (sPersonality == 'easy' or sPersonality == 'normal') then
                self.M28AI = true
                M28Utilities.bM28AIInGame = true
                ForkThread(M28Events.OnCreateBrain, self, planName, false)--]]
            else
                M28AIBrainClass.OnCreateAI(self, planName)
            end
        else
            M28AIBrainClass.OnCreateAI(self, planName)
        end
        --[[if (ScenarioInfo.ArmySetup[self.Name].AIPersonality == 'm28ai' or ScenarioInfo.ArmySetup[self.Name].AIPersonality == 'm28aicheat') then
            self.M28AI = true
            M28Utilities.bM28AIInGame = true
        end
        if not(self.M28AI) then
            LOG('Running normal aiBrain creation code for brain '..(self.Nickname or 'nil'))
            M28AIBrainClass.OnCreateAI(self, planName)
        end
        ForkThread(M28Events.OnCreateBrain, self, planName, false)--]]
    end,

    --[[OnBeginSession = function(self)
        M28AIBrainClass.OnBeginSession(self)
        M28Overseer.bBeginSessionTriggered = true
        import("/lua/sim/NavUtils.lua").Generate()
    end,--]]

    OnCreateHuman = function(self, planName)
        M28AIBrainClass.OnCreateHuman(self, planName)
        if M28Utilities.bSteamActive then
            ForkThread(M28Events.OnCreateBrain, self, planName, true)
        end
    end,

    --Redundancy - make sure base AI doesnt run for M28AI
    InitializeSkirmishSystems = function(self)
        if self.M28AI then
            --Do nothing
            LOG('BaseAIHook - M28AI InitializeSkirmishSystems disabled')
        else
            --LOG('BaseAIHook - InitializeSkirmishSystems, self='..(self.Nickname or 'nil'))
            M28AIBrainClass.InitializeSkirmishSystems(self)
        end
    end,
    InitializeAttackManager = function(self, attackDataTable)
        if self.M28AI then
            --Do nothing
            LOG('BaseAIHook - M28AI InitializeAttackManager disabled')
        else
            --LOG('BaseAIHook - InitializeAttackManager, ai='..(self.Nickname or 'nil'))
            M28AIBrainClass.InitializeAttackManager(self, attackDataTable)
        end
    end,
    InitializePlatoonBuildManager = function(self)
        if self.M28AI then
            --Do nothing
            LOG('BaseAIHook - M28AI InitializePlatoonBuildManager disabled')
        else
            --LOG('BaseAIHook - InitializePlatoonBuildManager, ai='..(self.Nickname or 'nil'))
            M28AIBrainClass.InitializePlatoonBuildManager(self)
        end
    end,
    BaseMonitorInitialization = function(self, spec)
        if self.M28AI then
            --Do nothing
            LOG('BaseAIHook - M28AI BaseMonitorInitialization disabled')
        else
            --LOG('BaseAIHook - BaseMonitorInitialization, ai='..(self.Nickname or 'nil'))
            M28AIBrainClass.BaseMonitorInitialization(self, spec)
        end
    end,
    BaseMonitorInitializationSorian = function(self, spec)
        if self.M28AI then
            --Do nothing
            LOG('BaseAIHook - M28AI BaseMonitorInitializationSorian disabled')
        else
            --LOG('BaseAIHook - BaseMonitorInitializationSorian, ai='..(self.Nickname or 'nil'))
            M28AIBrainClass.BaseMonitorInitializationSorian(self, spec)
        end
    end,
}