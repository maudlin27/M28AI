local M28UnitInfo = import('/mods/M28AI/lua/AI/M28UnitInfo.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Team = import('/mods/M28AI/lua/AI/M28Team.lua')
local M28Overseer = import('/mods/M28AI/lua/AI/M28Overseer.lua')
local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')
local M28Economy = import('/mods/M28AI/lua/AI/M28Economy.lua')
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')local M28UnitInfo = import('/mods/M28AI/lua/AI/M28UnitInfo.lua')

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
                LOG(sFunctionRef..': M28 Sent chat message from brain '..aiBrain.Nickname..'. bOnlySendToTeam='..tostring(bOnlySendToTeam)..'; sMessageType='..sMessageType..'; sMessage='..sMessage) --Log so in replays can see if this triggers since chat doesnt show properly
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

function ConsiderEndOfGameMessage(oBrainDefeated)
    --Called whenever a player dies; send end of game message if this means the game is over, or the last M28 has died

    local sFunctionRef = 'ConsiderEndOfGameMessage'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)




    local bHaveTeammates = false
    local bLastM28OnTeamToDie = false
    local bTeamHadM28AI = false
    if oBrainDefeated.M28AI then bLastM28OnTeamToDie = true end

    if M28Utilities.IsTableEmpty(M28Team.tTeamData[oBrainDefeated.M28Team][M28Team.subreftoFriendlyHumanAndAIBrains]) == false then
        for iBrain, oBrain in M28Team.tTeamData[oBrainDefeated.M28Team][M28Team.subreftoFriendlyHumanAndAIBrains] do
            if oBrain.M28AI then bTeamHadM28AI = true end
            if not(oBrain == oBrainDefeated) and not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) then
                bHaveTeammates = true
                if oBrain.M28AI then bLastM28OnTeamToDie = false end
            end
        end
    end
    if not(bHaveTeammates) or bLastM28OnTeamToDie then
        --Last player on a team has died, or the lastM28 on team has died
        local tsPotentialMessages = {}
        local oBrainToSendMessage

        if bLastM28OnTeamToDie then
            oBrainToSendMessage = oBrainDefeated

            table.insert(tsPotentialMessages, 'Recall damnit, recall!')
            table.insert(tsPotentialMessages, '/89')
            table.insert(tsPotentialMessages, '/90')
            table.insert(tsPotentialMessages, 'Thats not how the simulation went!')

            if not(oBrainDefeated.CheatEnabled) or oBrainDefeated[M28Economy.refiBrainResourceMultiplier] <= 1 then
                table.insert(tsPotentialMessages, 'Bet you couldnt beat an AiX version of me!')
                table.insert(tsPotentialMessages, 'Make me an AiX and Ill show you what I can really do!')
            elseif oBrainDefeated[M28Economy.refiBrainResourceMultiplier] <= 1.4 then
                table.insert(tsPotentialMessages, 'Bet you couldnt beat me if I was a 1.5 AiX!')
            else
                table.insert(tsPotentialMessages, 'Damn, I thought Id be unbeatable with this high a modifier')
                table.insert(tsPotentialMessages, 'Impressive')
            end
            --Is this the last brain on the team?
            if not(bHaveTeammates) then
                --Were there human players against us?
                local bHadEnemyHuman = false
                for iBrain, oBrain in ArmyBrains do
                    if oBrain.BrainType == 'Human' and IsEnemy(oBrain:GetArmyIndex(), oBrainDefeated:GetArmyIndex()) then
                        bHadEnemyHuman = true
                        break
                    end
                end
                if bHadEnemyHuman then
                    table.insert(tsPotentialMessages, 'Ive told the server not to give you any ranking points for this game, so I didnt really lose')
                    table.insert(tsPotentialMessages, 'Time for me to go back to fighting other bots :(')
                    if oBrainDefeated[M28Economy.refiBrainResourceMultiplier] >= 1.5 then
                        table.insert(tsPotentialMessages, 'I hope M27 doesnt see my humiliation this day')
                        table.insert(tsPotentialMessages, 'My father would be interested in a replay to see how I was defeated')
                    end
                    --Did we only have 1 M28AI? If so then ask for more
                    local bHadFriendlyM28AI = false
                    for iBrain, oBrain in ArmyBrains do
                        if oBrain.M28AI and not(oBrain == oBrainDefeated) and oBrain.M28Team == oBrainDefeated.M28Team then
                            bHadFriendlyM28AI = true
                        end
                    end
                    if not(bHadFriendlyM28AI) then
                        table.insert(tsPotentialMessages, 'You mightve beaten me, but I bet two M28AI would prove too much!')
                    end
                else
                    --Was there an M27 or M28AI on the team?
                    for iBrain, oBrain in ArmyBrains do
                        if not(oBrain.M28Team == oBrainDefeated.M28Team) and (oBrain.M27AI or oBrain.M28AI) then
                            table.insert(tsPotentialMessages, 'Brother, how could you?')
                            if oBrain.M27AI then
                                table.insert(tsPotentialMessages, 'This changes nothing, I’m still the favourite of our father')
                            end
                            break
                        end
                    end
                end
                table.insert(tsPotentialMessages, 'I let you win this time')
                if ScenarioInfo.Options.Victory == 'demoralization' then table.insert(tsPotentialMessages, 'So this is the way it ends, not with a whimper, but with a bang') end
                table.insert(tsPotentialMessages, 'gg')
                table.insert(tsPotentialMessages, 'gg wp')
                table.insert(tsPotentialMessages, 'Rematch?')
                if M28Team.tTeamData[oBrainDefeated.M28Team][M28Team.refiConstructedExperimentalCount] >= 4 and GetGameTimeSeconds() >= 45 * 60 then
                    table.insert(tsPotentialMessages, 'That was an epic game!')
                    table.insert(tsPotentialMessages, 'Ah well, I feel I at least put up a fight this time')
                end

            else
                table.insert(tsPotentialMessages, ':( There I was thinking my team would save me')
            end
            if M28Map.bIsCampaignMap then
                table.insert(tsPotentialMessages,'You were meant to protect me!')
                table.insert(tsPotentialMessages,'Shall we give it another go?')
                table.insert(tsPotentialMessages, ':(')
                if not(bHaveTeammates) then
                    table.insert(tsPotentialMessages, 'So ends the last hope of humanity')
                end
            end
        else
            if not(bHaveTeammates) then --redundancy
                --This wasn't an M28 that died, but it was the last player on the team, so send a message if M28 is alive on enemy team (M28 won) or there were M28 previously on this team
                local oEnemyM28AIBrain
                if M28Utilities.IsTableEmpty(M28Overseer.tAllActiveM28Brains) == false then
                    for iBrain, oBrain in M28Overseer.tAllActiveM28Brains do
                        if not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) and oBrain.M28AI and IsEnemy(oBrain:GetArmyIndex(), oBrainDefeated:GetArmyIndex()) then
                            oEnemyM28AIBrain = oBrain
                            break
                        end
                    end
                end
                --Do we still ahve M28AI in the game? If so they should send a message as the winner; otherwise then if we had M28AI on this team they should send message as the loser; otherwise (i.e. enemy team had M28AI but they have since been defeated) just dont say anything
                if oEnemyM28AIBrain then
                    oBrainToSendMessage = oEnemyM28AIBrain
                    --M28 won
                    local bHadAIX = false
                    if oEnemyM28AIBrain.CheatEnabled and oEnemyM28AIBrain[M28Economy.refiBrainResourceMultiplier] > 1 then
                        bHadAIX = true
                    end

                    --Are there any alive nonM28 on this brains team?
                    local bHaveNonM28Teammates = false
                    for iBrain, oBrain in M28Overseer.tAllAIBrainsByArmyIndex do
                        if oBrain.M28Team == oEnemyM28AIBrain.M28Team and not(oBrain.M28AI) and not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) then
                            bHaveNonM28Teammates = true
                            break
                        end
                    end
                    local bHadEnemyHuman = false
                    for iBrain, oBrain in ArmyBrains do
                        if oBrain.BrainType == 'Human' and oBrain.M28Team == oBrainDefeated.M28Team then
                            bHadEnemyHuman = true
                            break
                        end
                    end

                    if bHadAIX then
                        if bHadEnemyHuman then
                            table.insert(tsPotentialMessages, 'Maybe you should lower the AiX modifier next time!')
                            if oEnemyM28AIBrain[M28Economy.refiBrainResourceMultiplier] >= 1.5 and not(bHaveNonM28Teammates) then
                                table.insert(tsPotentialMessages, 'I thought you were being overconfident challenging me when I had this big a resource bonus')
                            end
                        end

                        table.insert(tsPotentialMessages, 'gg, even if I had bonus resources to help')
                    else
                        if bHadEnemyHuman then
                            table.insert(tsPotentialMessages, 'Want tips on what you could’ve done better? Post the replay ID to discord replay reviews channel and mention you lost to M28AI')
                            if oEnemyM28AIBrain[M28Economy.refiBrainResourceMultiplier] == 1 then table.insert(tsPotentialMessages, 'You can set my AiX modifier to below 1.0 for an easier time') end
                            table.insert(tsPotentialMessages, 'If Im too hard, check out the other custom AI at https://wiki.faforever.com/en/Development/AI/Custom-AIs')
                        end
                    end
                    if bHaveNonM28Teammates then
                        table.insert(tsPotentialMessages, 'gj team')
                    else
                        table.insert(tsPotentialMessages, 'Better luck next time scrub')
                        table.insert(tsPotentialMessages, 'Want to try again?')
                    end
                    table.insert(tsPotentialMessages, 'All your mex are belong to us')

                    if (M28Team.tTeamData[oEnemyM28AIBrain.M28Team][M28Team.refiConstructedExperimentalCount] or 0) >= 4 and GetGameTimeSeconds() >= 45 * 60 then
                        table.insert(tsPotentialMessages, 'Phew, that took me longer than I expected')
                    end

                    --Did we beat M27 or M28AI?
                    for iBrain, oBrain in ArmyBrains do
                        if not(oBrain.M28Team == oBrainDefeated.M28Team) and (oBrainDefeated.M27AI or oBrainDefeated.M28AI) then
                            table.insert(tsPotentialMessages, 'Goodbye, brother')
                            if oBrainDefeated.M27AI then table.insert(tsPotentialMessages, 'Youve gotten complacent in your old age, and now your birthright is mine') end
                            break
                        end
                    end

                    --Faction specific taunt
                    if not(oBrainDefeated:GetFactionIndex() == oBrainToSendMessage:GetFactionIndex()) then
                        local sFaction = M28UnitInfo.tFactionsByName[oBrainDefeated:GetFactionIndex()]
                        if sFaction then
                            --Check we didnt have this faction on our team
                            local bHadFactionOnOurTeam = false
                            for iBrain, oBrain in ArmyBrains do
                                if oBrain.M28Team == oBrainToSendMessage.M28Team then
                                    if oBrain:GetFactionIndex() == oBrainDefeated:GetFactionIndex() then
                                        bHadFactionOnOurTeam = true
                                        break
                                    end

                                end
                            end
                            if not(bHadFactionOnOurTeam) then
                                table.insert(tsPotentialMessages, 'Die, '..sFaction..' scum!')
                            end
                        end
                    end

                elseif bTeamHadM28AI then
                    --M28s team lost (but M28 died a while ago) - get an M28AI player on our team
                    for iCurBrain, oBrain in ArmyBrains do
                        if oBrain.M28AI and oBrain.M28Team == oBrainDefeated.M28Team then
                            oBrainToSendMessage = oBrain
                            break
                        end
                    end
                    if oBrainToSendMessage then
                        if oBrainDefeated.Nickname then
                            table.insert(tsPotentialMessages, 'There I was hoping '..oBrainDefeated.Nickname..' would carry our team...')
                            table.insert(tsPotentialMessages, 'You cost us the game '..oBrainDefeated.Nickname)
                            table.insert(tsPotentialMessages, 'Ah well, you tried your best '..oBrainDefeated.Nickname)
                        end
                        table.insert(tsPotentialMessages, 'Never had a chance with these teams')
                        table.insert(tsPotentialMessages, ':( wp')
                        table.insert(tsPotentialMessages, 'We let you win this one...')
                    end
                end
                if oBrainToSendMessage then --End of game, we either won or lost, so include messages that work either way
                    --Add in generic messages
                    table.insert(tsPotentialMessages, 'gg')
                    table.insert(tsPotentialMessages, 'gg wp')
                    table.insert(tsPotentialMessages, 'Rematch?')
                end
            end
        end
        if bDebugMessages == true then LOG(sFunctionRef..': oBrainToSendMessage='..(oBrainToSendMessage.Nickname or 'nil')..'; tsPotentialMessages='..repru(tsPotentialMessages)) end
        if M28Utilities.IsTableEmpty(tsPotentialMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialMessages))
            local sEndOfGameMessage = tsPotentialMessages[iRand]
            SendMessage(oBrainToSendMessage, 'End of game', sEndOfGameMessage, 1, 60)
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end