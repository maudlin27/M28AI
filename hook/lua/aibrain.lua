local M28Overseer = import('/mods/M28AI/lua/AI/M28Overseer.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')

M28AIBrainClass = AIBrain
AIBrain = Class(M28AIBrainClass) {

    --[[OnDefeat = function(self)
        ForkThread(M27Events.OnPlayerDefeated, self)
        M28AIBrainClass.OnDefeat(self)
    end,--]]

    OnCreateAI = function(self, planName)
        LOG('OnCreateAI hook for ai with personality '..ScenarioInfo.ArmySetup[self.Name].AIPersonality)
        --Logic to run for all brains
        local iStartPositionX, iStartPositionZ = self:GetArmyStartPos()
        M28Map.PlayerStartPoints[self:GetArmyIndex()] = {iStartPositionX, GetSurfaceHeight(iStartPositionX, iStartPositionZ), iStartPositionZ}
        M28Overseer.tAllAIBrainsByArmyIndex[self:GetArmyIndex()] = self

        if ScenarioInfo.ArmySetup[self.Name].AIPersonality == 'm28ai' or ScenarioInfo.ArmySetup[self.Name].AIPersonality == 'm28aicheat' then
            LOG('M28 brain created')
            self:CreateBrainShared(planName)
            --self:InitializeEconomyState()
            self.BrainType = 'AI'
            --M28AIBrainClass.OnCreateAI(self, planName)
            ForkThread(M28Overseer.BrainCreated, self)

        else
            M28AIBrainClass.OnCreateAI(self, planName)
        end
    end,

    OnCreateHuman = function(self, planName)
        M28AIBrainClass.OnCreateHuman(self, planName)
        local iStartPositionX, iStartPositionZ = self:GetArmyStartPos()
        M28Map.PlayerStartPoints[self:GetArmyIndex()] = {iStartPositionX, GetSurfaceHeight(iStartPositionX, iStartPositionZ), iStartPositionZ}
        M28Overseer.tAllAIBrainsByArmyIndex[self:GetArmyIndex()] = self
        LOG('Human player brain '..self.Nickname..' created; start position='..repru(M28Map.PlayerStartPoints[self:GetArmyIndex()]))
    end
}

