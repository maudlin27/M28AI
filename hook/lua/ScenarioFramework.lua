---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 14/05/2023 08:19
---


local M28OldSetPlayableArea = SetPlayableArea
SetPlayableArea = function(rect, voFlag)
    M28OldSetPlayableArea(rect, voFlag)
    ForkThread(ForkedPlayableAreaChange, rect, voFlag)
end

function ForkedPlayableAreaChange(rect, voFlag)
    --If run too early M28 code wont have loaded
    while GetGameTimeSeconds() < 3 do
        WaitTicks(1)
    end
    local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')
    local bDebugMessages = true if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    local sFunctionRef = 'ForkedPlayableAreaChange'
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    if bDebugMessages == true then LOG(sFunctionRef..': rect='..repru(rect)..'; voFlag='..reprs(voFlag)) end
    ForkThread(import('/mods/M28AI/lua/AI/M28Events.lua').OnPlayableAreaChange, rect, voFlag)
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end