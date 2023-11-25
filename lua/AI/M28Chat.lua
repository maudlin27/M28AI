local M28UnitInfo = import('/mods/M28AI/lua/AI/M28UnitInfo.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Team = import('/mods/M28AI/lua/AI/M28Team.lua')
local M28Overseer = import('/mods/M28AI/lua/AI/M28Overseer.lua')
local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')

local SUtils = import('/lua/AI/sorianutilities.lua')

tiM28VoiceTauntByType = {} --[x] = string for the type of voice taunt (functionref), returns gametimeseconds it was last issued
bConsideredSpecificMessage = false --set to true by any AI
bSentSpecificMessage = false

function SendSuicideMessage(aiBrain)
    --See the taunt.lua for a full list of taunts
    local sFunctionRef = 'SendSuicideMessage'
    if GetGameTimeSeconds() - (tiM28VoiceTauntByType[sFunctionRef] or -10000) > 60 then

        aiBrain.LastVocTaunt = GetGameTimeSeconds()
        local iFactionIndex = aiBrain:GetFactionIndex()
        local tTauntsByFaction = {
            [M28UnitInfo.refFactionUEF] = {7,22}, --Hall: I guess it’s time to end this farce; Fletcher: Theres no stopping me
            [M28UnitInfo.refFactionAeon] = {28, 38}, --For the Aeon!; My time is wasted on you
            [M28UnitInfo.refFactionCybran] = {82, 84}, --If you destroy this ACU, another shall rise in its place. I am endless.; My time is wasted on you
            [M28UnitInfo.refFactionSeraphim] = {82, 94}, --If you destroy this ACU...'; Do not fret. Dying by my hand is the supreme honor
            [M28UnitInfo.refFactionNomads] = {82} --If you destroy this ACU...;
        }
        local iTauntOptions
        local iTauntTableRef
        local sTauntChatCode = 82
        if M28Utilities.IsTableEmpty(tTauntsByFaction[iFactionIndex]) == false then
            iTauntOptions = table.getn(tTauntsByFaction[iFactionIndex])
            iTauntTableRef = math.random(1, iTauntOptions)
            sTauntChatCode = tTauntsByFaction[iFactionIndex][iTauntTableRef]
        end

        LOG(sFunctionRef..': Sent chat message '..sTauntChatCode) --Log so in replays can see if this triggers since chat doesnt show properly
        SUtils.AISendChat('all', aiBrain.Nickname, '/'..sTauntChatCode) --QAI I cannot be defeated.
        tiM28VoiceTauntByType[sFunctionRef] = GetGameTimeSeconds()
    end
end

function SendForkedGloatingMessage(aiBrain, iOptionalDelay, iOptionalTimeBetweenTaunts)
    --Call via sendgloatingmessage
    --Sends a taunt message after waiting iOptionalDelay, provided we havent sent one within 60s or iOptionalTimeBetweenTaunts
    local sFunctionRef = 'SendForkedGloatingMessage'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if iOptionalDelay then
        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
        WaitSeconds(iOptionalDelay)
        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    end
    if bDebugMessages == true then LOG(sFunctionRef..': iOptionalTimeBetweenTaunts='..(iOptionalTimeBetweenTaunts or 'nil')..'; tiM28VoiceTauntByType[sFunctionRef]='..(tiM28VoiceTauntByType[sFunctionRef] or 'nil')..'; Cur game time='..GetGameTimeSeconds()) end

    if GetGameTimeSeconds() - (tiM28VoiceTauntByType[sFunctionRef] or -10000) > (iOptionalTimeBetweenTaunts or 60) then
        local iFactionIndex = aiBrain:GetFactionIndex()
        local tTauntsByFaction = {
            [M28UnitInfo.refFactionUEF] = {1,4,7,16}, --Hall: You will not stop the UEF; The gloves are coming off; I guess its time to end this farce, Fletcher: I feel a bit bad, beatin' up on you like this
            [M28UnitInfo.refFactionAeon] = {26, 28, 30,39,40,41}, --Rhiza: All enemies of the Princess will be destroyed; For the Aeon; Behold the power of the Illuminate; run while you can; it must be frustrating to be so completely overmatched; beg for mercy
            [M28UnitInfo.refFactionCybran] = {58, 59, 60, 62, 74, 77, 78, 79, 81}, --Dostya: Observe. You may learn something; I would flee if I were you; You will be just another in my list of victories; Your defeat is without question; QAI: Your destruction is 99% certain; My victory is without question; Your defeat can be the only outcome; Your efforts are futile; All calculations indicate that your demise is near
            [M28UnitInfo.refFactionSeraphim] = {94,97,98}, --Sera: Do not fret. Dying by my hand is the supreme honor; Bow down before our might, and we may spare you; You will perish at my hand
            [M28UnitInfo.refFactionNomads] = {81} --QAI: All calculations indicate that your demise is near
        }
        local iTauntOptions
        local iTauntTableRef
        local sTauntChatCode = 81
        if M28Utilities.IsTableEmpty(tTauntsByFaction[iFactionIndex]) == false then
            iTauntOptions = table.getn(tTauntsByFaction[iFactionIndex])
            iTauntTableRef = math.random(1, iTauntOptions)
            sTauntChatCode = tTauntsByFaction[iFactionIndex][iTauntTableRef]
        end
        if bDebugMessages == true then LOG(sFunctionRef..': Will send chat with taunt code '..sTauntChatCode) end

        LOG(sFunctionRef..': Sent chat message '..sTauntChatCode) --Log so in replays can see if this triggers since chat doesnt show properly
        SUtils.AISendChat('all', aiBrain.Nickname, '/'..sTauntChatCode)

        tiM28VoiceTauntByType[sFunctionRef] = GetGameTimeSeconds()
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendGloatingMessage(aiBrain, iOptionalDelayInSeconds, iOptionalTimeBetweenTaunts)
    ForkThread(SendForkedGloatingMessage, aiBrain, iOptionalDelayInSeconds, iOptionalTimeBetweenTaunts)
end

function SendForkedMessage(aiBrain, sMessageType, sMessage, iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU)
    --Use SendMessage rather than this to reduce risk of error

    --If just sending a message rather than a taunt then can use this. sMessageType will be used to check if we have sent similar messages recently with the same sMessageType
    --if bOnlySendToTeam is true then will both only consider if message has been sent to teammates before (not all AI), and will send via team chat
    --bWaitUntilHaveACU - if true then will wait until aiBrain has an ACU (e.g. use for start of game messages in campaign)
    local sFunctionRef = 'SendForkedMessage'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    --Do we have allies?
    if not(bOnlySendToTeam) or table.getn(M28Team.tTeamData[aiBrain.M28Team][M28Team.subreftoFriendlyHumanAndAIBrains]) > 1 then


        if (iOptionalDelayBeforeSending or 0) > 0 then
            M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
            WaitSeconds(iOptionalDelayBeforeSending)
            M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
        end

        local bAbort = false

        if bWaitUntilHaveACU then
            local iCount = 0

            while M28Utilities.IsTableEmpty( aiBrain:GetListOfUnits(categories.COMMAND, false, true)) do
                M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
                WaitSeconds(1)
                M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
                iCount = iCount + 1
                --FA Mission 6 - end up waiting more than 6m, so changed to 400s
                if iCount >= 400 then M28Utilities.ErrorHandler('Waited '..iCount..' times so wont send chat message '..sMessage)
                    bAbort = true
                    break
                end

            end
            local tFriendlyACUs = aiBrain:GetListOfUnits(categories.COMMAND, false, true)
            if M28Utilities.IsTableEmpty(tFriendlyACUs) then
            end
        end

        if not(bAbort) then
            local iTimeSinceSentSimilarMessage
            if bOnlySendToTeam then
                iTimeSinceSentSimilarMessage = GetGameTimeSeconds() - (M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages][sMessageType] or -100000)
            else
                iTimeSinceSentSimilarMessage = GetGameTimeSeconds() - (tiM28VoiceTauntByType[sMessageType] or -100000000)
            end

            if bDebugMessages == true then LOG(sFunctionRef..': sMessageType='..(sMessageType or 'nil')..'; iOptionalTimeBetweenTaunts='..(iOptionalTimeBetweenMessageType or 'nil')..'; tiM28VoiceTauntByType[sMessageType]='..(tiM28VoiceTauntByType[sMessageType] or 'nil')..'; Cur game time='..GetGameTimeSeconds()..'; iTimeSinceSentSimilarMessage='..iTimeSinceSentSimilarMessage) end

            if iTimeSinceSentSimilarMessage > (iOptionalTimeBetweenMessageType or 60) then
                if bOnlySendToTeam then
                    SUtils.AISendChat('allies', aiBrain.Nickname, sMessage)
                    M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages][sMessageType] = GetGameTimeSeconds()
                    if bDebugMessages == true then LOG(sFunctionRef..': Sent a team chat message') end
                else
                    SUtils.AISendChat('all', aiBrain.Nickname, sMessage)
                    tiM28VoiceTauntByType[sMessageType] = GetGameTimeSeconds()
                end
                LOG(sFunctionRef..': Sent chat message. bOnlySendToTeam='..tostring(bOnlySendToTeam)..'; sMessageType='..sMessageType..'; sMessage='..sMessage) --Log so in replays can see if this triggers since chat doesnt show properly
            end
            if bDebugMessages == true then LOG(sFunctionRef..': tiM28VoiceTauntByType='..repru(tiM28VoiceTauntByType)..'; M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages='..repru(M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages])) end
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendMessage(aiBrain, sMessageType, sMessage, iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU)
    --Fork thread as backup to make sure any unforseen issues dont break the code that called this
    ForkThread(SendForkedMessage, aiBrain, sMessageType, sMessage, iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU)
end

--[[function SendGameCompatibilityWarning(aiBrain, sMessage, iOptionalDelay, iOptionalTimeBetweenTaunts)
    local sFunctionRef = 'SendGameCompatibilityWarning'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if iOptionalDelay then
        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
        WaitSeconds(iOptionalDelay)
        M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    end
    if bDebugMessages == true then LOG(sFunctionRef..': iOptionalTimeBetweenTaunts='..(iOptionalTimeBetweenTaunts or 'nil')..'; tiM28VoiceTauntByType[sFunctionRef]='..(tiM28VoiceTauntByType[sFunctionRef] or 'nil')..'; Cur game time='..GetGameTimeSeconds()) end

    if GetGameTimeSeconds() - (tiM28VoiceTauntByType[sFunctionRef] or -10000) > (iOptionalTimeBetweenTaunts or 60) then
        LOG(sFunctionRef..': Sent chat message '..sMessage) --Log so in replays can see if this triggers since chat doesnt show properly
        SUtils.AISendChat('all', aiBrain.Nickname, sMessage)
        tiM28VoiceTauntByType[sFunctionRef] = GetGameTimeSeconds()
    end
    if bDebugMessages == true then LOG(sFunctionRef..': tiM28VoiceTauntByType='..repru(tiM28VoiceTauntByType)) end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end--]]

function ConsiderPlayerSpecificMessages(aiBrain)
    --Call via ForkThread( given the delay - considers messages at start of game, including generic gl hf
    local sFunctionRef = 'ConsiderPlayerSpecificMessages'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    if bDebugMessages == true then LOG(sFunctionRef..': Is table of enemy brains empty='..tostring(M28Utilities.IsTableEmpty(M28Team.tTeamData[aiBrain.M28Team][M28Team.subreftoEnemyBrains]))) end
    WaitSeconds(5)
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    if bDebugMessages == true then LOG(sFunctionRef..': Is table of enemy brains empty after waiting 5s='..tostring(M28Utilities.IsTableEmpty(M28Team.tTeamData[aiBrain.M28Team][M28Team.subreftoEnemyBrains]))) end
    if M28Utilities.IsTableEmpty(M28Team.tTeamData[aiBrain.M28Team][M28Team.subreftoEnemyBrains]) == false then
        if M28Utilities.IsTableEmpty(tiM28VoiceTauntByType['Specific opponent']) then
            if not(bConsideredSpecificMessage) then
                bConsideredSpecificMessage = true
                for iBrain, oBrain in M28Team.tTeamData[aiBrain.M28Team][M28Team.subreftoEnemyBrains] do
                    if bDebugMessages == true then LOG(sFunctionRef..': oBrain.BrainType='..oBrain.BrainType..'; oBrain.Nickname='..oBrain.Nickname) end
                    if oBrain.BrainType == 'Human' then
                        local i, j = string.find(oBrain.Nickname, 'maudlin27')
                        if bDebugMessages == true then LOG(sFunctionRef..': i='..(i or 'nil')..'; j='..(j or 'nil')) end
                        if i > 0 then
                            if bDebugMessages == true then LOG(sFunctionRef..': maudlin27 is playing') end
                            if math.random(0, 6) == 6 then
                                SendMessage(oBrain, 'Specific opponent', 'What is this, what are you doing, my son?', 10, 0)
                                SendMessage(aiBrain, 'Specific opponent', 'Succeeding you, father', 15, 0)
                                bSentSpecificMessage = true
                            end
                        elseif (oBrain.Nickname == 'Jip' or oBrain.Nickname == 'FAF_Jip') and math.random(0,5) == 1 then
                            SendMessage(aiBrain, 'Specific opponent', 'Jip! Without you Id be fighting blind on the battlefield', 10, 10000)
                            bSentSpecificMessage = true
                        else
                            if math.random(0,5) == 1 then
                                --local tPrevPlayers = {'gunner1069', 'relentless', 'Azraeel', 'Babel', 'Wingflier', 'Radde', 'YungDookie', 'Spyro', 'Skinnydude', 'savinguptobebrok', 'Tomma', 'IgneusTempus', 'tyne141', 'Jip', 'Teralitha', 'RottenBanana', 'Deribus', 'SpikeyNoob'}
                                local tPrevPlayers = {} --Update when replays get sent of M28
                                if M28Utilities.IsTableEmpty(tPrevPlayers) == false then
                                    for iPlayer, sPlayer in tPrevPlayers do
                                        if oBrain.Nickname == sPlayer or oBrain.Nickname == 'FAF_'..sPlayer then
                                            SendMessage(aiBrain, 'Specific opponent', '/83', 5, 10000) --QAI message re analysing prev subroutines
                                            bSentSpecificMessage = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if not(bSentSpecificMessage) and M28Utilities.IsTableEmpty(tiM28VoiceTauntByType['Specific opponent']) then
                local sMessage
                local iRandom = math.random(1, 8)
                if iRandom == 1 then sMessage = 'good luck'
                elseif iRandom == 2 then sMessage = 'let'..'\''..'s do this'
                elseif iRandom == 3 then sMessage = 'let'..'\''..'s dance'
                elseif iRandom == 4 then sMessage = 'have fun'
                elseif iRandom == 5 then sMessage = 'good luck have fun'
                elseif iRandom == 6 then sMessage = 'gl hf'
                elseif iRandom == 7 then sMessage = 'gl'
                elseif iRandom == 8 then sMessage = 'hf'
                end
                SendMessage(aiBrain, 'Initial greeting', sMessage, 50 - math.floor(GetGameTimeSeconds()), 10)
                --Do we have an enemy M28 brain?
                for iBrain, oBrain in ArmyBrains do
                    if bDebugMessages == true then LOG(sFunctionRef..': Considering brain '..oBrain.Nickname..'; ArmyIndex='..oBrain:GetArmyIndex()..'; .M28AI='..tostring(oBrain.M28AI or false)) end
                    if oBrain.M28AI and not(oBrain == aiBrain) and IsEnemy(aiBrain:GetArmyIndex(), oBrain:GetArmyIndex()) then
                        if bDebugMessages == true then LOG(sFunctionRef..': Will send thanks you too message') end
                        SendMessage(oBrain, 'Initial greeting', 'thx, u2', 55 - math.floor(GetGameTimeSeconds()), 0)
                        break
                    end
                end
            else
            bConsideredSpecificMessage = true
            end
        end
    end

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end