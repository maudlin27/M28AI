----------------------------------------------------------------------------
--
--  Based on code originally written by Michael Robbins aka Sorian
----------------------------------------------------------------------------

function SyncAIChat(data)
    local Sync = Sync
    Sync.AIChat = Sync.AIChat or { }
    table.insert(Sync.AIChat, data)
end

--- Function to handle AI sending chat messages.
---@param aigroup string
---@param ainickname string
---@param aiaction string
---@param targetnickname string
---@param extrachat string
function AISendChat(aigroup, ainickname, aiaction, targetnickname, extrachat)
    if aigroup then
        local aiBrain
        for iBrain, oBrain in ArmyBrains do
            if oBrain.Nickname == ainickname then
                aiBrain = oBrain
                break
            end
        end
        if aiBrain and not(aiBrain:IsDefeated()) then
            SyncAIChat({group=aigroup, text=aiaction, sender=ainickname})
        end
    end
end