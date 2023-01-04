local M28Overseer = import('/mods/M28AI/lua/AI/M28Overseer.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')
local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')
local M28Config = import('/mods/M28AI/lua/M28Config.lua')
local M28Events = import('/mods/M28AI/lua/AI/M28Events.lua')

M28AIBrainClass = AIBrain
AIBrain = Class(M28AIBrainClass) {

    --[[OnDefeat = function(self)
        ForkThread(M27Events.OnPlayerDefeated, self)
        M28AIBrainClass.OnDefeat(self)
    end,--]]

    OnCreateAI = function(self, planName)
        M28Events.OnCreateBrain(self, planName, false)
        if not(self.M28AI) then M28AIBrainClass.OnCreateAI(self, planName) end
    end,

    OnCreateHuman = function(self, planName)
        M28AIBrainClass.OnCreateHuman(self, planName)
        M28Events.OnCreateBrain(self, planName, true)
    end
}

