---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 25/08/2024 17:35
---
---
Callbacks.M28SharedArmiesCallback = function(data, units)
    if not(tonumber(ScenarioInfo.Options.M28CombinedArmy or 2) == 1) then --i.e. option 1 enables; 2 and 4 disable (shouldnt be able to get here if are option 4), and 3 is moba mode
        local M28Chat = import('/mods/M28AI/lua/AI/M28Chat.lua')
        local aiBrain
        for _, oUnit in units or {} do
            if oUnit.GetAIBrain and not (oUnit.Dead) then
                aiBrain = oUnit:GetAIBrain()
                break
            end
        end
        if aiBrain then
            if tonumber(ScenarioInfo.Options.M28CombinedArmy or 2) == 2 then
                M28Chat.SendMessage(aiBrain, 'SharedAI', 'You need to enable combined AI-Human armies in game settings for this option to work.  You can also hide this button in the game settings.', 0, 1, nil, false, nil, nil, aiBrain)
                LOG('We havent enabled M28AI combined armies in game settings')
            else
                M28Chat.SendMessage(aiBrain, 'SharedAI', 'In MOBA mode M28AI logic always applies to non-ACU units, and never applies to the ACU', 0, 1, nil, false, nil, nil, aiBrain)
            end
        end
    else
        for _, oUnit in units or {} do
            if IsEntity(oUnit) then
                --LOG('M28SharedArmiesCallback for unit with ID='..(oUnit.UnitId or 'nil')..'; data.auto='..tostring(data.Enable or false)..'; unit is owned by brain '..oUnit:GetAIBrain().Nickname..'; Time='..GetGameTimeSeconds())
                oUnit.M28Active = data.Enable
                local iValue = 0
                if data.Enable then iValue = 1 end
                oUnit:UpdateStat('M28Active', iValue)
            end
        end
    end
end