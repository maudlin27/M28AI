M28AIBrainClass = AIBrain
AIBrain = Class(M28AIBrainClass) {

    --[[OnDefeat = function(self)
        ForkThread(M27Events.OnPlayerDefeated, self)
        M28AIBrainClass.OnDefeat(self)
    end,--]]

    OnCreateAI = function(self, planName)
        LOG('OnCreateAI hook for ai with personality '..ScenarioInfo.ArmySetup[self.Name].AIPersonality)
        if ScenarioInfo.ArmySetup[self.Name].AIPersonality == 'm28ai' or ScenarioInfo.ArmySetup[self.Name].AIPersonality == 'm28aicheat' then
            LOG('M28 brain created')
            --ForkThread(SpawnMain.TransferACU, self)
            self:CreateBrainShared(planName)
            --self:InitializeEconomyState()
            self.BrainType = 'AI'
            --M28AIBrainClass.OnCreateAI(self, planName)

        else
            M28AIBrainClass.OnCreateAI(self, planName)
        end
    end,
}

