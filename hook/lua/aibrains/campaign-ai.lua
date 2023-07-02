---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 17/05/2023 21:51
---
--In theory the below shouldt be needed once the FAF-Develop changes are integrated into FAF (expected June 2023), although probably no harm leaving for backwards compatibility

--local M28Events = import('/mods/M28AI/lua/AI/M28Events.lua')

local M28OldAIBrain = AIBrain
AIBrain = Class(M28OldAIBrain) {

    --[[OnDefeat = function(self)
        ForkThread(import('/mods/M28AI/lua/AI/M28Events.lua').OnPlayerDefeated, self)
        M28OldAIBrain.OnDefeat(self)
    end,--]]

    OnCreateAI = function(self, planName)
        import('/mods/M28AI/lua/AI/M28Events.lua').OnCreateBrain(self, planName, false) --dont do via forkthread or else self.m28ai wont work
        if not(self.M28AI) then
            LOG('Running normal aiBrain creation code for brain '..(self.Nickname or 'nil'))
            M28OldAIBrain.OnCreateAI(self, planName)
        end
    end,

    --[[OnCreateHuman = function(self, planName)
        M28OldAIBrain.OnCreateHuman(self, planName)
        import('/mods/M28AI/lua/AI/M28Events.lua').OnCreateBrain(self, planName, true)
    end,--]]
    --Redundancy - wouldnt expect any of below to trigger for M28, but this is as an extra redundancy
    CreateBrainShared = function(self, planName)
        if self.M28AI then
            --Do nothing
            LOG('Attempted CreateBrainShared for baseAI with M28 brain')
        else
            --LOG('CreateBrainShared for baseAI with no M28AI brain')
            M28OldAIBrain.CreateBrainShared(self, planName)
        end
    end,
    SetCurrentPlan = function(self, bestPlan)
        if self.M28AI then
            --Do nothing
            LOG('Attempted SetCurrentPlan for baseAI with M28 brain')
        else
            --LOG('SetCurrentPlan for baseAI with no M28AI brain')
            M28OldAIBrain.SetCurrentPlan(self, bestPlan)
        end
    end,
    --[[InitializeSkirmishSystems = function(self)
        if self.M28AI then
            --Do nothing
            LOG('Attempted to initialise skirmish systems for an M28Brain '..self.Nickname)
        else
            --LOG('base-ai: InitialiseSkirmishSystems')
            M28OldAIBrain.InitializeSkirmishSystems(self)
        end
    end,--]]
    InitializeAttackManager = function(self, attackDataTable)
        if self.M28AI then
            --Do nothing
            LOG('Attempted to initialise attack manager for an M28Brain '..self.Nickname)
        else
            --LOG('base-ai: InitializeAttackManager')
            M28OldAIBrain.InitializeAttackManager(self, attackDataTable)
        end
    end,
    InitializePlatoonBuildManager = function(self)
        if self.M28AI then
            --Do nothing
            LOG('Attempted to initialise platoon build manager for an M28Brain '..self.Nickname)
        else
            --LOG('base-ai: InitializePlatoonBuildManager')
            M28OldAIBrain.InitializePlatoonBuildManager(self)
        end
    end,
    BaseMonitorInitialization = function(self, spec)
        if self.M28AI then
            --Do nothing
            LOG('Attempted to initialise base monitor for an M28Brain '..self.Nickname)
        else
            --LOG('base-ai: BaseMonitorInitialization')
            M28OldAIBrain.BaseMonitorInitialization(self, spec)
        end
    end,
}