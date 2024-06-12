local M28UnitInfo = import('/mods/M28AI/lua/AI/M28UnitInfo.lua')
local M28Utilities = import('/mods/M28AI/lua/AI/M28Utilities.lua')
local M28Team = import('/mods/M28AI/lua/AI/M28Team.lua')
local M28Overseer = import('/mods/M28AI/lua/AI/M28Overseer.lua')
local M28Profiler = import('/mods/M28AI/lua/AI/M28Profiler.lua')
local M28Economy = import('/mods/M28AI/lua/AI/M28Economy.lua')
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')
local M28UnitInfo = import('/mods/M28AI/lua/AI/M28UnitInfo.lua')
local M28Conditions = import('/mods/M28AI/lua/AI/M28Conditions.lua')
local SUtils = import('/lua/AI/sorianutilities.lua')

tiM28VoiceTauntByType = {} --[x] = string for the type of voice taunt (functionref), returns gametimeseconds it was last issued
bConsideredSpecificMessage = false --set to true by any AI, e.g. for start of game messages (not implemented, see M27 for example implementation)
bSentSpecificMessage = false
iTimeOfLastAudioMessage = -100 --Time of last audio message being sent, used to avoid multiple audio messages playing at the same time
tbAssignedPersonalities = {} --M28 brains assigned a particular 'personality' for purposes of voice taunts
refiAssignedPersonality = 'M28ChatPers' --Assigned against the brain, indicates characters pecific voice taunts to consider
refiFletcher = 1
refiHall = 2
refiCelene = 3
refiRhiza = 4
refiVendetta = 5
refiAmalia = 6 --Only 1 voice message so want to be very low likelihood - doesnt get included with the other aeon by default but instead used as a backup once all other Aeon are used
refiKael = 7
refiGari = 8
refiDostya = 9
refiHex5 = 10
refiBrackman = 11
refiQAI = 12
refiThelUuthow = 13
refiOumEoshi = 14 --will also use SethIavow
tiPersonalitiesByFaction = {} --Will be set by AssignAIPersonalityAndRating
tsPersonalityNames = {[refiFletcher] = 'Fletcher', [refiHall] = 'Hall', [refiCelene] = 'Celene', [refiRhiza] = 'Rhiza', [refiVendetta] = 'Vendetta', [refiAmalia] = 'Amalisa', [refiKael] = 'Kael', [refiGari] = 'Gari', [refiDostya] = 'Dostya', [refiHex5]='Hex5', [refiBrackman] = 'Brackman', [refiQAI]='QAI', [refiThelUuthow]='ThelUuthow', [refiOumEoshi]='OumEoshi'}

--Against specific unit
refbGivenUnitRelatedMessage = 'M28ChtUnitMs' --true if given unitspecific message involving this (used e.g. for ondamaged trigger for an experimental)

--Other global variables
iNukeGloatingMessagesSent = 0

function SendSuicideMessage(aiBrain)
    --See the taunt.lua for a full list of taunts; recommended to manually use these via soundcue and bank info so can avoid voice audio overlapping
    --Below was based on M27 - not actually used so commented out
    M28Utilities.ErrorHandler('Old code, usage should be reviewed', true)
    --[[
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
    end--]]
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

function SendGenericGloatingMessage(aiBrain, iOptionalDelayInSeconds, iOptionalTimeBetweenTaunts)
    --Note: Not recommended to use generally since it risks voice taunts overlapping
    ForkThread(SendForkedGloatingMessage, aiBrain, iOptionalDelayInSeconds, iOptionalTimeBetweenTaunts)
end

function SendGloatingMessage(aiBrain, iDelayBeforeSending, iMinDelayBetweenSimilarMessages)
    local sFunctionRef = 'SendGloatingMessage'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    if not(aiBrain[refiAssignedPersonality]) or (aiBrain[refiAssignedPersonality] == refiQAI and (not(aiBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran) or (M28Map.bIsCampaignMap and not(aiBrain.Nickname == 'QAI') and not(aiBrain.Name == 'QAI')))) then
        SendGenericGloatingMessage(aiBrain, iDelayBeforeSending, iMinDelayBetweenSimilarMessages)
    else
        local tsPotentialMessages = {}
        local tsCueByMessageIndex = {}
        local tsBankBymessageIndex = {}
        local oBrainToSendMessage = aiBrain

        local tsPotentialTeamMessages = {}
        local tsTeamCueIndex = {}
        local tsTeamBankIndex = {}

        function AddPotentialMessage(sMessage, sOptionalCue, sOptionalBank, bIsTeamMessage)
            if bIsTeamMessage then
                table.insert(tsPotentialTeamMessages, sMessage)
                if sOptionalCue and sOptionalBank then
                    local iRef = table.getn(tsPotentialTeamMessages)
                    tsTeamCueIndex[iRef] = sOptionalCue
                    tsTeamBankIndex[iRef] = sOptionalBank
                end

            else
                table.insert(tsPotentialMessages, sMessage)
                if sOptionalCue and sOptionalBank then
                    local iRef = table.getn(tsPotentialMessages)
                    tsCueByMessageIndex[iRef] = sOptionalCue
                    tsBankBymessageIndex[iRef] = sOptionalBank
                end
            end
        end

        if oBrainToSendMessage[refiAssignedPersonality] == refiFletcher then
            AddPotentialMessage(LOC('<LOC X06_T01_860_010>[{i Fletcher}]: There is no stopping me!'), 'X06_Fletcher_T01_03047', 'X06_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_100_010>[{i Fletcher}]: You\'re not puttin\' up much of a fight.'), 'XGG_Fletcher_MP1_04575', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_110_010>[{i Fletcher}]: Do you have any idea of what you\'re doing?'), 'XGG_Fletcher_MP1_04576', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_120_010>[{i Fletcher}]: Not much on tactics, are ya?'), 'XGG_Fletcher_MP1_04577', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_140_010>[{i Fletcher}]: You ain\'t too good at this, are you?'), 'XGG_Fletcher_MP1_04579', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_150_010>[{i Fletcher}]: Guess I got time to smack you around.'), 'XGG_Fletcher_MP1_04580', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_160_010>[{i Fletcher}]: I feel a bit bad, beatin\' up on you like this.'), 'XGG_Fletcher_MP1_04581', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiHall then
            AddPotentialMessage(LOC('<LOC XGG_MP1_030_010>[{i Hall}]: You\'re not going to stop me.'), 'XGG_Hall__04568', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_040_010>[{i Hall}]: The gloves are coming off.'), 'XGG_Hall__04569', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_050_010>[{i Hall}]: You\'re in my way.'), 'XGG_Hall__04570', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_080_010>[{i Hall}]: You\'ve got no chance against me!'), 'XGG_Hall__04573', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiGari then
            AddPotentialMessage(LOC('<LOC X01_M02_161_010>[{i Gari}]: Ha-ha-ha!'), 'X01_Gari_M02_04245', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_040_010>[{i Gari}]: Your tenacity is admirable, but the outcome of this battle was determined long ago.'), 'X01_Gari_T01_04514', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_060_010>[{i Gari}]: Now you will taste the fury of the Order of the Illuminate.'), 'X01_Gari_T01_04516', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_070_010>[{i Gari}]: You have nowhere to hide, nowhere to run.'), 'X01_Gari_T01_04517', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_110_010>[{i Gari}]: Beg for mercy and perhaps I shall grant you an honorable death.'), 'X01_Gari_T01_04521', 'X01_VO')

            --Does enemy have UEF and we dont?
            local bHaveUEFOnTeam = false
            local bEnemyHasUEF = false
            local bEnemyHasAeon = false
            for iBrain, oBrain in ArmyBrains do
                if not(oBrain.M28IsDefeated) and not(M28Conditions.IsCivilianBrain(aiBrain)) and not(oBrain:IsDefeated()) then
                    if oBrain.M28Team == oBrainToSendMessage.M28Team and not(oBrain == aiBrain) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                            bHaveUEFOnTeam = true
                        end
                    elseif IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                            bEnemyHasUEF = true
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                            bEnemyHasAeon = true
                        end
                    end
                end
            end
            if not(bHaveUEFOnTeam) and bEnemyHasUEF then
                AddPotentialMessage(LOC('<LOC X01_M02_250_010>[{i Gari}]: At long last, the end of the UEF is within my sights. This day has been a long time coming.'), 'X01_Gari_M02_03664', 'X01_VO')
            end
            --Does enemy have Aeon and we dont?
            if bEnemyHasAeon then
                AddPotentialMessage(LOC('<LOC X01_M02_270_010>[{i Gari}]: You have abandoned your people, your heritage and your gods. For that, you will be destroyed.'), 'X01_Gari_M02_03668', 'X01_VO')
            end
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiRhiza then
            --Does enemy have UEF and we dont?
            local bEnemyHasAeon = false
            for iBrain, oBrain in ArmyBrains do
                if not(oBrain.M28IsDefeated) and not(M28Conditions.IsCivilianBrain(aiBrain)) and not(oBrain:IsDefeated()) then
                    if not(oBrain.M28Team == oBrainToSendMessage.M28Team) and IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                            bEnemyHasAeon = true
                            break
                        end
                    end
                end
            end

            if bEnemyHasAeon then
                AddPotentialMessage(LOC('<LOC X01_M02_270_020>[{i Rhiza}]: You have perverted The Way with your fanaticism. For that, you will be destroyed.'), 'X01_Rhiza_M02_03669', 'X01_VO')
            end
            AddPotentialMessage(LOC('<LOC X06_T01_900_010>[{i Rhiza}]: Glory to the Princess!'), 'X06_Rhiza_T01_03050', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_910_010>[{i Rhiza}]: It is unwise to ignore me.'), 'X06_Rhiza_T01_03051', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_920_010>[{i Rhiza}]: Soon you will know my wrath!'), 'X06_Rhiza_T01_03052', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_930_010>[{i Rhiza}]: The will of the Princess will not be denied!'), 'X06_Rhiza_T01_03053', 'X06_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_170_010>[{i Rhiza}]: Glory to the Princess!'), 'XGG_Rhiza_MP1_04582', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_180_010>[{i Rhiza}]: Glorious!'), 'XGG_Rhiza_MP1_04583', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_190_010>[{i Rhiza}]: I will not be stopped!'), 'XGG_Rhiza_MP1_04584', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_220_010>[{i Rhiza}]: For the Aeon!'), 'XGG_Rhiza_MP1_04587', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_240_010>[{i Rhiza}]: Behold the power of the Illuminate!'), 'XGG_Rhiza_MP1_04589', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiKael then
            AddPotentialMessage(LOC('<LOC X03_M02_115_020>[{i Kael}]: Ha-ha-ha!'), 'X03_Kael_M02_04368', 'X03_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_280_010>[{i Kael}]: You\'re beginning to bore me.'), 'XGG_Kael_MP1_04593', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_290_010>[{i Kael}]: My time is wasted on you.'), 'XGG_Kael_MP1_04594', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_310_010>[{i Kael}]: It must be frustrating to be so completely overmatched.'), 'XGG_Kael_MP1_04596', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_320_010>[{i Kael}]: Beg for mercy.'), 'XGG_Kael_MP1_04597', 'XGG')

        elseif oBrainToSendMessage[refiAssignedPersonality] == refiCelene then
            AddPotentialMessage(LOC('<LOC X02_T01_090_010>[{i Celene}]: Nothing can save you now!'), 'X02_Celene_T01_04544', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_095_010>[{i Celene}]: Beg me for mercy! Beg!'), 'X02_Celene_T01_04545', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_070_010>[{i Celene}]: Every day you grow weaker. Your end is drawing near.'), 'X02_Celene_T01_04542', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_090_010>[{i Celene}]: Nothing can save you now!'), 'X02_Celene_T01_04544', 'X02_VO')

        elseif oBrainToSendMessage[refiAssignedPersonality] == refiVendetta then
            local bHaveTeammates = false
            for iBrain, oBrain in ArmyBrains do
                if oBrain.M28Team == oBrainToSendMessage.M28Team and not(oBrain==oBrainToSendMessage) and not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) then
                    bHaveTeammates = true
                    break
                end
            end
            local bEnemyHasAeon = false
            local bEnemyHasCybran = false
            for iBrain, oBrain in ArmyBrains do
                if not(oBrain.M28IsDefeated) and not(M28Conditions.IsCivilianBrain(aiBrain)) and not(oBrain:IsDefeated()) then
                    if not(oBrain.M28Team == oBrainToSendMessage.M28Team) and IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                            bEnemyHasAeon = true
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then
                            bEnemyHasCybran = true
                        end
                    end
                end
            end

            if bHaveTeammates then
                AddPotentialMessage(LOC('<LOC X06_T01_500_010>[{i Vendetta}]: Why are you still fighting us?'), 'X06_Vedetta_T01_03012', 'X06_VO')
            end

            if bEnemyHasCybran then
                AddPotentialMessage(LOC('<LOC X06_T01_520_010>[{i Vendetta}]: You are an abomination.'), 'X06_Vedetta_T01_03014', 'X06_VO')
            end
            if bEnemyHasAeon then
                AddPotentialMessage(LOC('<LOC X06_T01_540_010>[{i Vendetta}]: You will die by my hand, traitor.'), 'X06_Vedetta_T01_03016', 'X06_VO')
            end
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiDostya then
            AddPotentialMessage(LOC('<LOC XGG_MP1_340_010>[{i Dostya}]: Observe. You may learn something.'), 'XGG_Dostya_MP1_04599', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_370_010>[{i Dostya}]: You are not worth my time.'), 'XGG_Dostya_MP1_04602', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_380_010>[{i Dostya}]: Your defeat is without question.'), 'XGG_Dostya_MP1_04603', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_390_010>[{i Dostya}]: You seem to have courage. Intelligence seems to be lacking.'), 'XGG_Dostya_MP1_04604', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_400_010>[{i Dostya}]: I will destroy you.'), 'XGG_Dostya_MP1_04605', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiBrackman then
            AddPotentialMessage(LOC('<LOC XGG_MP1_410_010>[{i Brackman}]: I\'m afraid there is no hope for you, oh yes.'), 'XGG_Brackman_MP1_04606', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_420_010>[{i Brackman}]: Well, at least you provided me with some amusement.'), 'XGG_Brackman_MP1_04607', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_430_010>[{i Brackman}]: Perhaps some remedial training is in order?'), 'XGG_Brackman_MP1_04608', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_450_010>[{i Brackman}]: They do not call me a genius for nothing, you know.'), 'XGG_Brackman_MP1_04610', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_460_010>[{i Brackman}]: Defeating you is hardly worth the effort, oh yes.'), 'XGG_Brackman_MP1_04611', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_470_010>[{i Brackman}]: There is nothing you can do.'), 'XGG_Brackman_MP1_04612', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_480_010>[{i Brackman}]: At least you will not suffer long.'), 'XGG_Brackman_MP1_04613', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiHex5 then
            AddPotentialMessage(LOC('<LOC X05_T01_150_010>[{i Hex5}]: You are weak and soft, frightened by what you don\'t understand.'), 'X05_Hex5_T01_04429', 'X05_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_580_010>[{i Hex5}]: I do make it look easy.'), 'XGG_Hex5_MP1_04623', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_610_010>[{i Hex5}]: So, I guess failure runs in your family?'), 'XGG_Hex5_MP1_04626', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_620_010>[{i Hex5}]: Man, I\'m good at this!'), 'XGG_Hex5_MP1_04627', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_640_010>[{i Hex5}]: Don\'t worry, it\'ll be over soon.'), 'XGG_Hex5_MP1_04629', 'XGG')

        elseif oBrainToSendMessage[refiAssignedPersonality] == refiQAI then
            AddPotentialMessage(LOC('<LOC X02_T01_210_010>[{i QAI}]: My influence is much more vast than you can imagine.'), 'X02_QAI_T01_04557', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_220_010>[{i QAI}]: All calculations indicate that your demise is near.'), 'X02_QAI_T01_04558', 'X02_VO')

            local bNoUEFOrAeonTeammate = true
            local bEnemyHasHuman = false
            for iBrain, oBrain in ArmyBrains do
                if not(oBrain.M28IsDefeated) and not(M28Conditions.IsCivilianBrain(aiBrain)) and not(oBrain:IsDefeated()) then
                    if oBrain.M28Team == oBrainToSendMessage.M28Team and not(oBrain == aiBrain) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                            bNoUEFOrAeonTeammate = false
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                            bNoUEFOrAeonTeammate = false
                        end
                    elseif IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                            bEnemyHasHuman = true
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                            bEnemyHasHuman = true
                        end
                    end
                end
            end
            if bEnemyHasHuman and bNoUEFOrAeonTeammate then
                AddPotentialMessage(LOC('<LOC X02_T01_180_010>[{i QAI}]: Humans are such curious creatures. Even in the face of insurmountable odds, you continue to resist.'), 'X02_QAI_T01_04554', 'X02_VO')
            end
            AddPotentialMessage(LOC('<LOC XGG_MP1_550_010>[{i QAI}]: Your efforts are futile.'), 'XGG_QAI_MP1_04620', 'XGG')

        elseif oBrainToSendMessage[refiAssignedPersonality] == refiOumEoshi then
            AddPotentialMessage(LOC('<LOC X04_M03_055_010>[{i OumEoshi}]: Only now do you realize the futility of your situation. We know what you know, we see what you see. There is no stopping us.'), 'X04_Oum-Eoshi_M03_04402', 'X04_VO')
            AddPotentialMessage(LOC('<LOC X04_T01_030_010>[{i OumEoshi}]: Do not fret. Dying by my hand is the supreme honor.'), 'X04_Oum-Eoshi_T01_04385', 'X04_VO')
            --If against non-Seraphim
            local bEnemyHasNoSeraphim = true
            local bWeHaveNoUEF = true
            local bEnemyHasUEF = false
            for iBrain, oBrain in ArmyBrains do
                if not(oBrain.M28IsDefeated) and not(M28Conditions.IsCivilianBrain(aiBrain)) and not(oBrain:IsDefeated()) then
                    if oBrain.M28Team == oBrainToSendMessage.M28Team and not(oBrain == aiBrain) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                            bWeHaveNoUEF = false
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                            bWeHaveNoUEF = false
                        end
                    elseif IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionSeraphim then
                            bEnemyHasNoSeraphim = false
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                            bEnemyHasUEF = true
                        end
                    end
                end
            end

            if bEnemyHasNoSeraphim and bWeHaveNoUEF then
                AddPotentialMessage(LOC('<LOC X04_M03_057_010>[{i OumEoshi}]: Humanity\'s time is at an end. You will be rendered extinct.'), 'X04_Oum-Eoshi_M03_04404', 'X04_VO')
            end
            if bEnemyHasUEF and bWeHaveNoUEF then
                AddPotentialMessage(LOC('<LOC X04_M03_090_010>[{i OumEoshi}]: You will share the fate of Riley and Clarke. Goodbye, Colonel.'), 'X04_Oum-Eoshi_M03_03767', 'X04_VO')
            end
            AddPotentialMessage(LOC('<LOC X01_T01_250_010>[{i ShunUllevash}]: (Laughter)'), 'X01_seraphim_T01_05123', 'X01_VO')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiThelUuthow then
            AddPotentialMessage(LOC('<LOC X06_T01_240_010>[{i ThelUuthow}]: Bow down before our might, and we may spare you.'), 'X06_Thel-Uuthow_T01_02976', 'X06_VO')

            local bEnemyHasNoSeraphim = true
            local bEnemyHasCybran = false
            local bWeHaveNoUEF = true
            local bWeHaveNoCybran = true
            for iBrain, oBrain in ArmyBrains do
                if not(oBrain.M28IsDefeated) and not(M28Conditions.IsCivilianBrain(aiBrain)) and not(oBrain:IsDefeated()) then
                    if oBrain.M28Team == oBrainToSendMessage.M28Team and not(oBrain == aiBrain) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                            bWeHaveNoUEF = false
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then
                            bWeHaveNoCybran = false
                        end
                    elseif IsEnemy(oBrain:GetArmyIndex(), aiBrain:GetArmyIndex()) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionSeraphim then
                            bEnemyHasNoSeraphim = false
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then
                            bEnemyHasCybran = true
                        end
                    end
                end
            end

            if bEnemyHasNoSeraphim and bWeHaveNoUEF then
                AddPotentialMessage(LOC('<LOC X06_T01_190_010>[{i ThelUuthow}]: Your kind began this war. We are merely finishing it.'), 'X06_Thel-Uuthow_T01_02971', 'X06_VO')
            end
            if bEnemyHasCybran and bWeHaveNoCybran then
                AddPotentialMessage(LOC('<LOC X06_T01_210_010>[{i ThelUuthow}]: You Cybrans die as easily as any other human.'), 'X06_Thel-Uuthow_T01_02973', 'X06_VO')
            end
            AddPotentialMessage(LOC('<LOC X06_T01_260_010>[{i ThelUuthow}]: You will perish at my hand.'), 'X06_Thel-Uuthow_T01_02978', 'X06_VO')
        end

        if bDebugMessages == true then LOG(sFunctionRef..': Finished getting potential global and team messages, tsPotentialMessages='..repru(tsPotentialMessages)..'; tsPotentialTeamMessages='..repru(tsPotentialTeamMessages)..'; oBrainToSendMessage='..(oBrainToSendMessage.Nickname or 'nil')) end
        local bSendGlobal = true
        local bSendTeam = true
        if M28Utilities.IsTableEmpty(tsPotentialMessages) == false and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false then
            if math.random(1,2) == 1 then bSendGlobal = false else bSendTeam = false end
        end
        if bSendGlobal and M28Utilities.IsTableEmpty(tsPotentialMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialMessages))
            --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
            SendMessage(oBrainToSendMessage, 'Taunt'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialMessages[iRand], iDelayBeforeSending, iMinDelayBetweenSimilarMessages, false, M28Map.bIsCampaignMap, tsCueByMessageIndex[iRand], tsBankBymessageIndex[iRand])
        end
        if bSendTeam and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialTeamMessages))
            --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
            SendMessage(oBrainToSendMessage, oBrainToSendMessage.M28Team..'Taunt'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialTeamMessages[iRand], iDelayBeforeSending, iMinDelayBetweenSimilarMessages, true, M28Map.bIsCampaignMap, tsTeamCueIndex[iRand], tsTeamBankIndex[iRand])
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendForkedMessageForSpecialUseOnly(aiBrain, sMessageType, sMessage, iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
    --WARNING: Use SendMessage rather than this to reduce risk of error

    --If just sending a message rather than a taunt then can use this. sMessageType will be used to check if we have sent similar messages recently with the same sMessageType
    --if bOnlySendToTeam is true then will both only consider if message has been sent to teammates before (not all AI), and will send via team chat
    --bWaitUntilHaveACU - if true then will wait until aiBrain has an ACU (e.g. use for start of game messages in campaign)
    local sFunctionRef = 'SendForkedMessageForSpecialUseOnly'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    if bDebugMessages == true then LOG(sFunctionRef..': start of code, aiBrain='..aiBrain.Nickname..'; sMessage='..sMessage..'; iOptionalDelayBeforeSending='..(iOptionalDelayBeforeSending or 'nil')..'; iOptionalTimeBetweenMessageType='..(iOptionalTimeBetweenMessageType or 'nil')..'; bOnlySendToTeam='..tostring(bOnlySendToTeam or false)..'; sOptionalSoundCue='..(sOptionalSoundCue or 'nil')..'; Time='..GetGameTimeSeconds()) end
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
                local bCancelAsAudioLikelyPlaying = false
                if sOptionalSoundCue and GetGameTimeSeconds() - iTimeOfLastAudioMessage <= 4 then
                    bCancelAsAudioLikelyPlaying = true
                end
                if not(bCancelAsAudioLikelyPlaying) then
                    if bOnlySendToTeam then
                        SUtils.AISendChat('allies', aiBrain.Nickname, sMessage)
                        if not(M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages]) then M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages] = {} end
                        M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages][sMessageType] = GetGameTimeSeconds()
                        if bDebugMessages == true then LOG(sFunctionRef..': Sent a team chat message') end
                    else
                        SUtils.AISendChat('all', aiBrain.Nickname, sMessage)
                        tiM28VoiceTauntByType[sMessageType] = GetGameTimeSeconds()
                    end
                    if sOptionalSoundCue and sOptionalSoundBank then
                        local iOptionalTeamArmyIndex
                        if bOnlySendToTeam and aiBrain.GetArmyIndex then
                            iOptionalTeamArmyIndex = aiBrain:GetArmyIndex()
                        end
                        SendAudioMessage(sOptionalSoundCue, sOptionalSoundBank, 0, iOptionalTeamArmyIndex)
                    end
                end
                LOG(sFunctionRef..': M28 Sent chat message from brain '..aiBrain.Nickname..'. bOnlySendToTeam='..tostring(bOnlySendToTeam)..'; sMessageType='..sMessageType..'; sMessage='..sMessage) --Log so in replays can see if this triggers since chat doesnt show properly
            end
            if bDebugMessages == true then LOG(sFunctionRef..': tiM28VoiceTauntByType='..repru(tiM28VoiceTauntByType)..'; M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages='..repru(M28Team.tTeamData[aiBrain.M28Team][M28Team.reftiTeamMessages])) end
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendMessage(aiBrain, sMessageType, sMessage, iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
    --Fork thread as backup to make sure any unforseen issues dont break the code that called this
    ForkThread(SendForkedMessageForSpecialUseOnly, aiBrain, sMessageType, sMessage, iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
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

    --Below is based off M27 code, not actually used by M28 but left commented out in case decide want to make use of it
    M28Utilities.ErrorHandler('Old chat code, usage should be reviewed', true)
    --[[
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
                        if not(IsCivilianBrain(oBrain)) then
                            if bDebugMessages == true then LOG(sFunctionRef..': Will send thanks you too message') end
                            SendMessage(oBrain, 'Initial greeting', 'thx, u2', 55 - math.floor(GetGameTimeSeconds()), 0)
                        end
                        break
                    end
                end
            else
            bConsideredSpecificMessage = true
            end
        end
    end

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)--]]
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
    local tsPotentialMessages = {}
    local tsCueByMessageIndex = {}
    local tsBankBymessageIndex = {}
    local oBrainToSendMessage
    local sMessageType

    local tsPotentialTeamMessages = {}
    local tsTeamCueIndex = {}
    local tsTeamBankIndex = {}

    function AddPotentialMessage(sMessage, sOptionalCue, sOptionalBank, bIsTeamMessage)
        if bIsTeamMessage then
            table.insert(tsPotentialTeamMessages, sMessage)
            if sOptionalCue and sOptionalBank then
                local iRef = table.getn(tsPotentialTeamMessages)
                tsTeamCueIndex[iRef] = sOptionalCue
                tsTeamBankIndex[iRef] = sOptionalBank
            end

        else
            table.insert(tsPotentialMessages, sMessage)
            if sOptionalCue and sOptionalBank then
                local iRef = table.getn(tsPotentialMessages)
                tsCueByMessageIndex[iRef] = sOptionalCue
                tsBankBymessageIndex[iRef] = sOptionalBank
            end
        end
    end

    --Consider if last M28 that has died for special message; otherwise (or 25% of the time) consider message for ACU dying
    local iRandGroupingType
    local iOrigM28BrainCountOnTeam = 0
    local iHumansOnSameTeamAsDefeatedM28 = 0
    local iHumansOnDifferentTeamToDefeatedBrain = 0
    local iNonM28AIPresent = 0
    for iBrain, oBrain in ArmyBrains do
        if oBrain.M28AI and oBrain.M28Team == oBrainDefeated.M28Team then
            iOrigM28BrainCountOnTeam = iOrigM28BrainCountOnTeam + 1
        elseif oBrain.BrainType == 'Human' then
            if not(oBrain.M28Team == oBrainDefeated.M28Team) then
                iHumansOnDifferentTeamToDefeatedBrain = iHumansOnDifferentTeamToDefeatedBrain + 1
            elseif oBrain.M28Team == oBrainDefeated.M28Team and oBrainDefeated.M28AI then
                iHumansOnSameTeamAsDefeatedM28 = iHumansOnSameTeamAsDefeatedM28 + 1
            end
        elseif not(M28Conditions.IsCivilianBrain(oBrain)) then
            iNonM28AIPresent = iNonM28AIPresent + 1
        end
    end
    if iOrigM28BrainCountOnTeam == 1 and (not(bHaveTeammates) or iHumansOnSameTeamAsDefeatedM28 > 0) then
        --33% to 50% chance of using the on ACU death message instead of the game ended message
        if math.random(1,2) == 1 then
            iRandGroupingType = math.random(1,2)
        else
            iRandGroupingType = math.random(1,3)
        end
    else
        --25% chance of using the ACU death emssage instead of the game ended message
        iRandGroupingType = math.random(1, 4)
    end
    if bDebugMessages == true then LOG(sFunctionRef..': Deciding if should get end of game type messages, or ACU death type messages, bHaveTeammates='..tostring(bHaveTeammates)..'; bLastM28OnTeamToDie='..tostring(bLastM28OnTeamToDie)..'; oBrainDefeated personality='..(oBrainDefeated[refiAssignedPersonality] or 'nil')..'; iRandGroupingType='..iRandGroupingType..'; Is this assassination='..tostring(ScenarioInfo.Options.Victory == 'demoralization')..'; iOrigM28BrainCountOnTeam='..iOrigM28BrainCountOnTeam) end
    if (not(bHaveTeammates) or bLastM28OnTeamToDie) and (not(oBrainDefeated.M28AI) or not(oBrainDefeated[refiAssignedPersonality]) or not(ScenarioInfo.Options.Victory == 'demoralization') or oBrainDefeated[refiAssignedPersonality] == refiQAI or iRandGroupingType > 1) then
        sMessageType = 'End of Game'
        --Last player on a team has died, or the lastM28 on team has died

        if bLastM28OnTeamToDie then
            oBrainToSendMessage = oBrainDefeated
            if bDebugMessages == true then LOG(sFunctionRef..': Campaign map='..tostring(M28Map.bIsCampaignMap)..'; Assigned personality='..oBrainDefeated[refiAssignedPersonality]..'; Resource mod='..oBrainDefeated[M28Economy.refiBrainResourceMultiplier]..'; Build mod='..oBrainDefeated[M28Economy.refiBrainBuildRateMultiplier]..'; Map size='..M28Map.iMapSize..'; bNonAISimModsActive='..tostring(M28Overseer.bNonAISimModsActive)..'; iHumansOnSameTeamAsDefeatedM28='..iHumansOnSameTeamAsDefeatedM28..'; iNonM28AIPresent='..iNonM28AIPresent..'; iHumansOnDifferentTeamToDefeatedBrain='..iHumansOnDifferentTeamToDefeatedBrain..'; iOrigM28BrainCountOnTeam='..iOrigM28BrainCountOnTeam..'; bUnitRestrictionsArePresent='..tostring(M28Overseer.bUnitRestrictionsArePresent)..'; Map and brackman='..tostring(not(M28Map.bIsCampaignMap) and oBrainDefeated[refiAssignedPersonality] == refiBrackman)..'; Modifiers='..tostring(oBrainDefeated[M28Economy.refiBrainResourceMultiplier] >= 1.5 and oBrainDefeated[M28Economy.refiBrainBuildRateMultiplier] >= 1.5)..'; Map size and mod cond='..tostring(M28Map.iMapSize >= 512 and M28Map.iMapSize <= 1024 and M28Overseer.bNonAISimModsActive == false)..'; Brain count conditions='..tostring(iHumansOnSameTeamAsDefeatedM28 == 0 and iNonM28AIPresent == 0 and iHumansOnDifferentTeamToDefeatedBrain <= iOrigM28BrainCountOnTeam)) end
            if not(M28Map.bIsCampaignMap) and oBrainDefeated[refiAssignedPersonality] == refiBrackman and oBrainDefeated[M28Economy.refiBrainResourceMultiplier] >= 1.5 and oBrainDefeated[M28Economy.refiBrainBuildRateMultiplier] >= 1.5 and M28Map.iMapSize >= 512 and M28Map.iMapSize <= 1024 and M28Overseer.bNonAISimModsActive == false and iHumansOnSameTeamAsDefeatedM28 == 0 and iNonM28AIPresent == 0 and iHumansOnDifferentTeamToDefeatedBrain <= iOrigM28BrainCountOnTeam and not(M28Overseer.bUnitRestrictionsArePresent) then
                AddPotentialMessage(LOC('<LOC X04_M03_260_010>[{i Brackman}]: Hi, this is Jamieson Price, the voice of Dr. Brackman. Your skills are so impressive that you knocked me out of character, and now I have to re-record my VO! Gimme a moment while I dial it back in ... oh yes ... there we go, much better. Much better.'), 'X04_Brackman_M03_05106', 'X04_VO')
            else
                AddPotentialMessage( 'Recall damnit, recall!')
                AddPotentialMessage( 'That\'s not how the simulation went!')

                if not(M28Map.bIsCampaignMap) and (not(oBrainDefeated.CheatEnabled) or oBrainDefeated[M28Economy.refiBrainResourceMultiplier] <= 1) then
                    if oBrainDefeated.M28Easy then
                        AddPotentialMessage( 'Time for the training wheels to come off')
                        AddPotentialMessage( 'Well done, but I was going easy on you')
                    else
                        AddPotentialMessage( 'Bet you couldnt beat an AIx version of me!')
                        AddPotentialMessage( 'Make me an AIx and Ill show you what I can really do!')
                    end
                elseif not(M28Map.bIsCampaignMap) and oBrainDefeated[M28Economy.refiBrainResourceMultiplier] <= 1.4 then
                    AddPotentialMessage( 'Bet you couldnt beat me if I was a 1.5 AIx!')
                elseif not(M28Map.bIsCampaignMap) then
                    AddPotentialMessage( 'Damn, I thought Id be unbeatable with this high a modifier')
                    AddPotentialMessage( 'Impressive')
                end
                --Is this the last brain on the team? (means it wont be campaign map anyway)
                if bDebugMessages == true then LOG(sFunctionRef..': Are last M28 on team to die, bHaveTeammates='..tostring(bHaveTeammates)) end
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
                        --Check enemy has ACU (i.e. it is unlikely to be a draw)
                        for iBrain, oBrain in ArmyBrains do
                            if not(oBrain:IsDefeated()) and not(oBrain.M28IsDefeated) and IsEnemy(oBrain:GetArmyIndex(), oBrainDefeated:GetArmyIndex()) and oBrain:GetCurrentUnits(categories.COMMAND) > 0 then
                                LOG('Brain '..oBrain.Nickname..' has an ACU and isnt defeated')
                                AddPotentialMessage( 'Ive told the server not to give you any ranking points for this game, so I didnt really lose')
                                break
                            end
                        end
                        AddPotentialMessage( 'Time for me to go back to fighting other bots :(')
                        if oBrainDefeated[M28Economy.refiBrainResourceMultiplier] >= 1.5 then
                            AddPotentialMessage( 'I hope M27 doesnt see my humiliation this day')
                            AddPotentialMessage( 'My father would be interested in a replay to see how I was defeated')
                        end
                        --Did we only have 1 M28AI? If so then ask for more
                        local bHadFriendlyM28AI = false
                        for iBrain, oBrain in ArmyBrains do
                            if oBrain.M28AI and not(oBrain == oBrainDefeated) and oBrain.M28Team == oBrainDefeated.M28Team then
                                bHadFriendlyM28AI = true
                            end
                        end
                        if not(bHadFriendlyM28AI) then
                            AddPotentialMessage( 'You might\'ve beaten me, but I bet two M28AI would prove too much!')
                        end
                    else
                        --Was there an M27 or M28AI on the team?
                        for iBrain, oBrain in ArmyBrains do
                            if not(oBrain.M28Team == oBrainDefeated.M28Team) and (oBrain.M27AI or oBrain.M28AI) then
                                AddPotentialMessage( 'Brother, how could you?')
                                if oBrain.M27AI then
                                    AddPotentialMessage( 'This changes nothing, I’m still our father\'s favourite')
                                end
                                break
                            end
                        end
                    end
                    AddPotentialMessage( 'I let you win this time')
                    if ScenarioInfo.Options.Victory == 'demoralization' then AddPotentialMessage( 'So this is the way it ends, not with a whimper, but with a bang') end
                    AddPotentialMessage( 'gg')
                    AddPotentialMessage( 'gg wp')
                    AddPotentialMessage( 'Rematch?')
                    if M28Team.tTeamData[oBrainDefeated.M28Team][M28Team.refiConstructedExperimentalCount] >= 4 and GetGameTimeSeconds() >= 45 * 60 then
                        AddPotentialMessage( 'That was an epic game!')
                        AddPotentialMessage( 'Ah well, I feel I at least put up a fight this time')
                    end
                    --If we had more than 1 teammate
                    local iPlayersOnTeam = 0
                    for iBrain, oBrain in ArmyBrains do
                        if oBrain.M28Team == oBrainDefeated.M28Team then iPlayersOnTeam = iPlayersOnTeam + 1 end
                    end
                    if iPlayersOnTeam >= 2 then
                        AddPotentialMessage(LOC('<LOC X03_M02_170_010>[{i Princess}]: They\'re ... they\'re dead ... I shall forever mourn their loss.'),'X03_Princess_M02_03334', 'X03_VO')
                    end
                    if oBrainDefeated.M28AI and (oBrainDefeated[refiAssignedPersonality] == refiFletcher or oBrainDefeated[refiAssignedPersonality] == refiHall or oBrainDefeated[refiAssignedPersonality] == refiRhiza or oBrainDefeated[refiAssignedPersonality] == refiBrackman or oBrainDefeated[refiAssignedPersonality] == refiDostya or oBrainDefeated[refiAssignedPersonality] == refiAmalia) then
                        AddPotentialMessage(LOC('<LOC X05_DB01_030_010>[{i HQ}]: The operation has ended in failure. All is lost.'), 'X05_HQ_DB01_04956', 'Briefings')
                        AddPotentialMessage(LOC('<LOC X06_M01_130_010>[{i HQ}]: Looks like the Commander just ate it. Poor bastard.'), 'X06_HQ_M01_04960', 'X06_VO')
                        AddPotentialMessage(LOC('<LOC X06_M01_140_010>[{i HQ}]: Commander, you read me? Commander? Ah hell...'),'X06_HQ_M01_04961', 'X06_VO')
                    end
                else
                    AddPotentialMessage( ':( There I was thinking my team would save me')
                end
                if M28Map.bIsCampaignMap then
                    AddPotentialMessage('You were meant to protect me!')
                    AddPotentialMessage('Shall we give it another go?')
                    AddPotentialMessage( ':(')
                    if not(bHaveTeammates) then
                        AddPotentialMessage( 'So ends the last hope of humanity')
                    end
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
                            AddPotentialMessage( 'Maybe you should lower the AIx modifier next time!')
                            if oEnemyM28AIBrain[M28Economy.refiBrainResourceMultiplier] >= 1.5 and not(bHaveNonM28Teammates) then
                                AddPotentialMessage( 'I thought you were being overconfident challenging me when I had this big a resource bonus')
                            end
                        end

                        AddPotentialMessage( 'gg, even if I had bonus resources to help')
                    else
                        if bHadEnemyHuman then
                            AddPotentialMessage( 'Want tips on what you could’ve done better? Post the replay ID to discord replay reviews channel and mention you lost to M28AI')
                            if (oEnemyM28AIBrain[M28Economy.refiBrainResourceMultiplier] or 1) == 1 then
                                AddPotentialMessage( 'You can set my AIx modifier to below 1.0 for an easier time')
                                if not(oEnemyM28AIBrain.M28Easy) then AddPotentialMessage( 'If you found me too hard you could practice against M28Easy') end
                            end
                            AddPotentialMessage( 'If I\'m too hard, check out the other custom AI at https://wiki.faforever.com/en/Development/AI/Custom-AIs')
                        end
                    end
                    if bHaveNonM28Teammates then
                        AddPotentialMessage( 'gj team', nil, nil, true)
                    else
                        AddPotentialMessage( 'Better luck next time scrub')
                        AddPotentialMessage( 'Want to try again?')
                    end
                    AddPotentialMessage( 'All your mex are belong to us')

                    if (M28Team.tTeamData[oEnemyM28AIBrain.M28Team][M28Team.refiConstructedExperimentalCount] or 0) >= 4 and GetGameTimeSeconds() >= 45 * 60 then
                        AddPotentialMessage( 'Phew, that took me longer than I expected')
                    end

                    --Did we beat M27 or M28AI?
                    for iBrain, oBrain in ArmyBrains do
                        if not(oBrain.M28Team == oBrainDefeated.M28Team) and (oBrainDefeated.M27AI or oBrainDefeated.M28AI) then
                            AddPotentialMessage( 'Goodbye, brother')
                            if oBrainDefeated.M27AI then AddPotentialMessage( 'Youve gotten complacent in your old age, and now your birthright is mine') end
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
                                AddPotentialMessage( 'Die, '..sFaction..' scum!')
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
                            AddPotentialMessage( 'There I was hoping '..oBrainDefeated.Nickname..' would carry our team...')
                            AddPotentialMessage( 'You cost us the game '..oBrainDefeated.Nickname)
                            AddPotentialMessage( 'Ah well, you tried your best '..oBrainDefeated.Nickname)
                        end
                        AddPotentialMessage( 'Never had a chance with these teams')
                        AddPotentialMessage( ':( wp')
                        AddPotentialMessage( 'We let you win this one...')
                    end
                end
                if oBrainToSendMessage then --End of game, we either won or lost, so include messages that work either way
                    --Add in generic messages
                    AddPotentialMessage( 'gg')
                    AddPotentialMessage( 'Rematch?')
                end
            end
        end
    else
        if ScenarioInfo.Options.Victory == 'demoralization' and oBrainDefeated.M28AI and not(M28Map.bIsCampaignMap) then
            oBrainToSendMessage = oBrainDefeated
            sMessageType = 'ACU Death'
            if bDebugMessages == true then LOG(sFunctionRef..': ACU death, personality='..(oBrainDefeated[refiAssignedPersonality] or 'nil')) end
            --Get personality specific death message if not campaign
            if oBrainDefeated[refiAssignedPersonality] == refiFletcher then
                AddPotentialMessage(LOC('<LOC X01_T01_240_010>[{i Fletcher}]: You\'ve got to be kidding!'), 'X01_Fletcher_T01_04535', 'X01_VO')
            elseif oBrainDefeated[refiAssignedPersonality] == refiHall then
                AddPotentialMessage(LOC('<LOC XGG_MP1_070_010>[{i Hall}]: I guess it\'s time to end this farce.'), 'XGG_Hall__04572', 'XGG')
            elseif oBrainDefeated[refiAssignedPersonality] == refiCelene then
                AddPotentialMessage(LOC('<LOC X02_D01_020_010>[{i Celene}]: Wait! I\'m not ready to die!'), 'X02_Celene_D01_03178', 'X02_VO')
            elseif oBrainDefeated[refiAssignedPersonality] == refiRhiza then
                AddPotentialMessage(LOC('<LOC X03_M02_115_010>[{i Rhiza}]: NOOOOOOOOOOOOO!'),'X03_Rhiza_M02_03319', 'X03_VO')
                AddPotentialMessage(LOC('<LOC X06_M02_260_010>[{i Rhiza}]: Nooooooo!'), 'X06_Rhiza_M02_05599', 'X06_VO')
                AddPotentialMessage(LOC('<LOC X06_M02_270_010>[{i Rhiza}]: [High Pitched Death Scream]'), 'X06_Rhiza_M02_05125', 'X06_VO')
                if bHaveTeammates then
                    --Do we have a human teammate?
                    local bHaveHumanTeammate = false
                    for iBrain, oBrain in ArmyBrains do
                        if oBrain.M28Team == oBrainDefeated.M28Team and oBrainDefeated.BrainType == 'Human' then
                            bHaveHumanTeammate = true
                            break
                        end
                    end
                    if bHaveHumanTeammate then
                        AddPotentialMessage(LOC('<LOC X03_M03_235_010>[{i Rhiza}]: I\'m taking too much damage -- I must recall. Commander, continue the fight without me!'), 'X03_Rhiza_M03_04708', 'X03_VO')
                    end
                end
            elseif oBrainDefeated[refiAssignedPersonality] == refiAmalia then
                AddPotentialMessage(LOC('<LOC X05_M02_190_010>[{i Amalia}]: Remember that I fought honorably!'), 'X05_Amalia_M02_03852', 'X05_VO')
            elseif oBrainDefeated[refiAssignedPersonality] == refiVendetta then
                AddPotentialMessage(LOC('<LOC X06_T01_580_010>[{i Vendetta}]: Aaaaaaaaah!'),'X06_Vedetta_T01_03020', 'X06_VO')
            elseif oBrainDefeated[refiAssignedPersonality] == refiThelUuthow then
                AddPotentialMessage(LOC('<LOC X06_T01_270_010>[{i ThelUuthow}]: I serve to the end!'), 'X06_Thel-Uuthow_T01_02979', 'X06_VO')
            elseif oBrainDefeated[refiAssignedPersonality] == refiDostya then
                AddPotentialMessage(LOC('<LOC X04_M03_016_010>[{i Dostya}]: Getting hit from all sides ... too many of them ... too many ...'), 'X04_Dostya_M03_03755', 'X04_VO')
            elseif oBrainDefeated[refiAssignedPersonality] == refiHex5 then
                AddPotentialMessage(LOC('<LOC X05_M02_200_009>[{i Hex5}]: Wait! Master!'), 'X05_Hex5_T01_04437', 'X05_VO')
            elseif oBrainDefeated[refiAssignedPersonality] == refiBrackman then
                AddPotentialMessage(LOC('<LOC X05_M03_135_010>[{i Brackman}]: At last I shall have peace.'), 'X05_Brackman_M03_04444', 'X05_VO')
                AddPotentialMessage(LOC('<LOC X05_M03_327_010>[{i Brackman}]: Goodbye.'), 'X05_Brackman_M03_04452', 'X05_VO')
            elseif oBrainDefeated[refiAssignedPersonality] == refiGari then
                local bNoSeraphimOnEnemyTeam = true
                for iBrain, oBrain in ArmyBrains do
                    if not(oBrain.M28Team == oBrainDefeated.M28Team) and not(M28Conditions.IsCivilianBrain(oBrain)) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionSeraphim then
                            bNoSeraphimOnEnemyTeam = false
                            break
                        end
                    end
                end
                if bNoSeraphimOnEnemyTeam then
                    AddPotentialMessage(LOC('<LOC X01_T01_190_010>[{i Gari}]: The Seraphim will never be defeated!'), 'X01_Gari_T01_04530', 'X01_VO')
                end
            elseif oBrainDefeated[refiAssignedPersonality] == refiQAI then
                AddPotentialMessage(LOC('<LOC X02_D01_030_010>[{i QAI}]: This is just a shell.'),'X02_QAI_D01_03179', 'X02_VO')
                AddPotentialMessage(LOC('<LOC X02_T01_290_010>[{i QAI}]: This is just a shell...'), 'X02_QAI_T01_04565', 'X02_VO')
            end
            if M28Utilities.IsTableEmpty(tsPotentialMessages) then
                AddPotentialMessage('gg')
                AddPotentialMessage(':(')
                AddPotentialMessage('Recall damnit, recall!')
                if oBrainDefeated.GetArmyFaction and oBrainDefeated:GetArmyFaction() == M28UnitInfo.refFactionAeon then
                    AddPotentialMessage('You may have defeated me, but my spirit lives on in the way!')
                end
                local bHaveNonM28Teammates = false
                for iBrain, oBrain in M28Overseer.tAllAIBrainsByArmyIndex do
                    if oBrain.M28Team == oBrainDefeated.M28Team and not(oBrain.M28AI) and not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) then
                        bHaveNonM28Teammates = true
                        break
                    end
                end
                if bHaveNonM28Teammates then
                    AddPotentialMessage('Sorry team, I\'ve failed', nil, nil, true)
                end

            end
        end
    end
    if bDebugMessages == true then LOG(sFunctionRef..': oBrainToSendMessage='..(oBrainToSendMessage.Nickname or 'nil')..'; tsPotentialMessages='..repru(tsPotentialMessages)) end
    if M28Utilities.IsTableEmpty(tsPotentialMessages) == false and oBrainToSendMessage then
        local iRand = math.random(1, table.getn(tsPotentialMessages))
        if bDebugMessages == true then LOG(sFunctionRef..': will try and send message with index='..iRand) end
        --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
        SendMessage(oBrainToSendMessage, sMessageType, tsPotentialMessages[iRand], 1, 60, false, nil, tsCueByMessageIndex[iRand], tsBankBymessageIndex[iRand])
    end
    if M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false and oBrainToSendMessage then
        local iRand = math.random(1, table.getn(tsPotentialTeamMessages))
        --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
        SendMessage(oBrainToSendMessage, 'Team'..oBrainToSendMessage.M28Team..'Death', tsPotentialTeamMessages[iRand], 5, 60, true, M28Map.bIsCampaignMap, tsTeamCueIndex[iRand], tsTeamBankIndex[iRand])
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendForkedAudioMessage(sCue, sBank, iDelayInSeconds, iOptionalTeamArmyIndex)
    if iDelayInSeconds then
        WaitSeconds(iDelayInSeconds)
    end
    iTimeOfLastAudioMessage = GetGameTimeSeconds()
    local SyncVoice = import("/lua/simsyncutils.lua").SyncVoice
    if not(iOptionalTeamArmyIndex) or (GetFocusArmy() > 0 and not(IsEnemy(GetFocusArmy(), iOptionalTeamArmyIndex))) then --Thanks to Jip for explaining this is how to get an audio message to only play for particular players
        --WARNING: Only affect UI here; any code affecting the SIM will cause a desync (per Jip)
        SyncVoice({Cue = sCue, Bank = sBank})
    end
end

function SendAudioMessage(sCue, sBank, iDelayInSeconds, iOptionalTeamArmyIndex)
    if not(iDelayInSeconds) then iTimeOfLastAudioMessage = GetGameTimeSeconds() end
    ForkThread(SendForkedAudioMessage, sCue, sBank, iDelayInSeconds, iOptionalTeamArmyIndex)
end

function AssignAIPersonalityAndRating(aiBrain)
    local sFunctionRef = 'AssignAIPersonalityAndRating'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)
    if aiBrain.M28AI then
        if M28Utilities.IsTableEmpty(tiPersonalitiesByFaction) then
            tiPersonalitiesByFaction = {[M28UnitInfo.refFactionUEF] = {refiFletcher, refiHall}, [M28UnitInfo.refFactionAeon] = {refiCelene, refiRhiza, refiVendetta, refiKael, refiGari}, [M28UnitInfo.refFactionCybran] = {refiDostya, refiHex5, refiBrackman, refiQAI}, [M28UnitInfo.refFactionSeraphim] = {refiThelUuthow, refiOumEoshi}}
        end
        if bDebugMessages == true then LOG(sFunctionRef..': Considering assignemtn for brain nickanme='..aiBrain.Nickname..'; reprs='..reprs(aiBrain)) end
        if not(M28Map.bIsCampaignMap) then
            local tiPotentialPersonalities = {}
            local iFactionIndex = aiBrain:GetFactionIndex()
            local bAlreadyHaveNickname = false
            if M28Utilities.IsTableEmpty(tiPersonalitiesByFaction[iFactionIndex]) == false then
                if aiBrain.Nickname then
                    for iEntry, iPersonality in tiPersonalitiesByFaction[iFactionIndex] do
                        if bDebugMessages == true then LOG(sFunctionRef..': Considering if brain '..aiBrain.Nickname..' is a match to iPersonality='..iPersonality..'; tsPersonalityNames[iPersonality]='..tsPersonalityNames[iPersonality]..'; is string.find reversed nil='..tostring(string.find(tsPersonalityNames[iPersonality], aiBrain.Nickname) == nil)..'; string.find result is nil?='..tostring(string.find(aiBrain.Nickname, tsPersonalityNames[iPersonality]) == nil)) end
                        if string.find(aiBrain.Nickname, tsPersonalityNames[iPersonality]) then
                            bAlreadyHaveNickname = true
                            table.insert(tiPotentialPersonalities, iPersonality)
                            break
                        end
                    end
                end
                if not(bAlreadyHaveNickname) then
                    LOG('Dont already have nickname for .nickname='..aiBrain.Nickname)
                    for iEntry, iPersonality in tiPersonalitiesByFaction[iFactionIndex] do
                        if not(tbAssignedPersonalities[iPersonality]) then
                            table.insert(tiPotentialPersonalities, iPersonality)
                        end
                    end
                end
            end
            if M28Utilities.IsTableEmpty(tiPotentialPersonalities) then
                --Aeon - consider amalia if all others are taken
                if iFactionIndex == M28UnitInfo.refFactionAeon and not(tbAssignedPersonalities[refiAmalia]) then
                    table.insert(tiPotentialPersonalities, refiAmalia)
                else
                    table.insert(tiPotentialPersonalities, refiQAI)
                end
            end
            local iRand = math.random(1, table.getn(tiPotentialPersonalities))
            aiBrain[refiAssignedPersonality] = tiPotentialPersonalities[iRand]
            tbAssignedPersonalities[aiBrain[refiAssignedPersonality]] = true
        else
            --Campaign AI - add for specific AI
            local tsPersonalityByName = {['Fletcher'] = refiFletcher,
                                         ['Hex5'] = refiHex5,
                                         ['Dostya'] = refiDostya,
                                         ['Brackman'] = refiBrackman,
                                         ['Rhiza'] = refiRhiza,
                                         ['Hall'] = refiHall,
                                         ['Celene'] = refiCelene,
                                         ['Vendetta'] = refiVendetta,
                                         ['Amalia'] = refiAmalia,
                                         ['Kael'] = refiKael,
                                         ['Gari'] = refiGari,
                                         ['QAI'] = refiQAI,
                                         ['Thel-Uuthow'] = refiThelUuthow,
                                         ['Oum-Eoshi'] = refiOumEoshi}
            local iPersonality = tsPersonalityByName[aiBrain.Nickname] or tsPersonalityByName[aiBrain.Name]
            if iPersonality then aiBrain[refiAssignedPersonality] = iPersonality end
        end
    end
    if aiBrain.M28AI then
        LOG('AI rating='..(ScenarioInfo.Options.Ratings[aiBrain.Nickname] or 'nil')..'; Name='..aiBrain.Nickname)
        if (ScenarioInfo.Options.Ratings[aiBrain.Nickname] or 0) == 0 then --Hopefully will be able to get FAF to assign ratings at start of game via lobby, so below is temporary to provide basic compatibility in the meantime - wont affect displayed rating via scoreboards though, only relevant for things like full-share to make sure AIx gets stuff in priority to AI
            local iBaseRating = 750
            local iApproxRating
            local bIsCheatingAI = aiBrain.CheatEnabled
            local iOmniCheat = 50
            local iResourceBaseMod = 1700 --i.e. if had AIx 1.5, then its rank shoudl be increased by 50% * this
            local iBuildRateBaseMod = 1300 --i.e. if had AIx 1.5, then its rank shoudl be increased by 50% * this
            local iHigherThreshold = 2000 --The point at which the AI rating will be increased at a much lower rate to avoid absurd ratings
            local iGeneralRatingFactor = 0.9 --The expected rating should be multiplied by this - e.g. can use to be a bit conservative with the AI expected rating (since it impacts on which player gets units in fullshare)

            --Does the AI in question have rating options specified? If not then revert to default (rating of 0)
            if iBaseRating then
                if bIsCheatingAI then
                    local iResourceMultiplier = tonumber(ScenarioInfo.Options.CheatMult)
                    local iBuildMultiplier = tonumber(ScenarioInfo.Options.BuildMult)
                    iApproxRating = math.max(iBaseRating + iOmniCheat + (iResourceMultiplier - 1) * iResourceBaseMod + (iBuildMultiplier - 1) * iBuildRateBaseMod, 0)
                    if iApproxRating > iHigherThreshold then
                        iApproxRating = iHigherThreshold + (iApproxRating - iHigherThreshold) * 0.2
                    end
                else
                    iApproxRating = iBaseRating
                end
                iApproxRating = iApproxRating * iGeneralRatingFactor
                --Round to the nearest 25:
                iApproxRating = math.round(iApproxRating / 25) * 25
                ScenarioInfo.Options.Ratings[aiBrain.Nickname] = iApproxRating --only affects things like full share since scoreboards likely use the value at start of game before AI have been created
            end
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendStartOfGameMessage(aiBrain, iOptionalExtraDelayInSeconds, sOptionalMessageTypePrefix)
    local sFunctionRef = 'SendStartOfGameMessage'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
    WaitSeconds(20)
    if iOptionalExtraDelayInSeconds then
        WaitSeconds(iOptionalExtraDelayInSeconds)
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    local tsPotentialMessages = {}
    local tsCueByMessageIndex = {}
    local tsBankBymessageIndex = {}
    local tsPotentialTeamMessages = {}
    local tsTeamCueIndex = {}
    local tsTeamBankIndex = {}

    function AddPotentialMessage(sMessage, sOptionalCue, sOptionalBank, bIsTeamMessage)
        if bIsTeamMessage then
            table.insert(tsPotentialTeamMessages, sMessage)
            if sOptionalCue and sOptionalBank then
                local iRef = table.getn(tsPotentialTeamMessages)
                tsTeamCueIndex[iRef] = sOptionalCue
                tsTeamBankIndex[iRef] = sOptionalBank
            end

        else
            table.insert(tsPotentialMessages, sMessage)
            if sOptionalCue and sOptionalBank then
                local iRef = table.getn(tsPotentialMessages)
                tsCueByMessageIndex[iRef] = sOptionalCue
                tsBankBymessageIndex[iRef] = sOptionalBank
            end
        end
    end

    if M28Map.bIsCampaignMap then
        AddPotentialMessage('Let\'s do this!')
        AddPotentialMessage('Time to foil their plans')
        AddPotentialMessage('I didnt ask for this...')
        AddPotentialMessage('Its time to end this')
        AddPotentialMessage('I hope youve got my back commander')
        AddPotentialMessage('So...I just need to eco right?')
        AddPotentialMessage('This doesnt look as easy as the simulation...')

        --Faction specific message
        if aiBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
            AddPotentialMessage('They will not stop the UEF')
        elseif aiBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
            AddPotentialMessage('For the Aeon!')
        elseif aiBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then
            AddPotentialMessage('Their defeat can be the only outcome')
        else
            AddPotentialMessage('They will perish at my hand')
        end
    else

        local iEnemyHumans = 0
        local iAllyHumans = 0
        local bEnemyHasNonSeraphimFaction
        local tbEnemyFactions = {}
        local tbAlliedHumanFactions = {}
        local tbAlliedFactions = {}
        for iBrain, oBrain in ArmyBrains do
            if not(oBrain.M28Team == aiBrain.M28Team) then
                if oBrain.BrainType == 'Human' then
                    iEnemyHumans = iEnemyHumans + 1
                end
                if not(M28Conditions.IsCivilianBrain(oBrain)) then
                    if not(oBrain:GetFactionIndex() == M28UnitInfo.refFactionSeraphim) then
                        bEnemyHasNonSeraphimFaction = true
                    end
                    tbEnemyFactions[oBrain:GetFactionIndex()] = true
                end
            else
                if oBrain.BrainType == 'Human' then
                    iAllyHumans = iAllyHumans + 1
                    tbAlliedHumanFactions[oBrain:GetFactionIndex()] = true
                    tbAlliedFactions[oBrain:GetFactionIndex()] = true
                else
                    tbAlliedFactions[oBrain:GetFactionIndex()] = true
                end
            end
        end
        if iEnemyHumans >= 2 then
            AddPotentialMessage('Time to separate the wheat from the chaff')
            if iEnemyHumans >= 3 and iAllyHumans == 0 then AddPotentialMessage('Your lack of coordination shall be your undoing') end
            if iEnemyHumans > iAllyHumans + M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefiActiveM28BrainCount] and math.max(M28Team.tTeamData[aiBrain.M28Team][M28Team.refiHighestBrainBuildMultiplier], M28Team.tTeamData[aiBrain.M28Team][M28Team.refiHighestBrainResourceMultiplier]) == 1 then
                if M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefiActiveM28BrainCount] > 1 then
                    AddPotentialMessage('So, you didn\'t feel like you could take us on in an equal fight?')
                else
                    AddPotentialMessage('So, you didn\'t feel like you could take me on in an equal fight?')
                end
            end
        end
        if bDebugMessages == true then LOG(sFunctionRef..': Considering whether to include outnumbered message, iEnemyHumans='..iEnemyHumans..'; iAllyHumans='..iAllyHumans..'; Active brain count='..M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefiActiveM28BrainCount]) end
        if iEnemyHumans < iAllyHumans + M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefiActiveM28BrainCount] then
            --Check the most brains on a team
            local tiBrainsByTeam = {}
            for iBrain, oBrain in M28Team.tTeamData[aiBrain.M28Team][M28Team.subreftoEnemyBrains] do
                tiBrainsByTeam[oBrain.M28Team] = (tiBrainsByTeam[oBrain.M28Team] or 0) + 1
            end
            local iHighestCount = 0
            for iTeam, iCount in tiBrainsByTeam do
                iHighestCount = math.max(iCount, iHighestCount)
            end
            if bDebugMessages == true then LOG(sFunctionRef..': iHighestCount='..iHighestCount..'; Our team count='..iAllyHumans + M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefiActiveM28BrainCount]) end
            if iHighestCount < iAllyHumans + M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefiActiveM28BrainCount] then
                AddPotentialMessage('You\'re outnumbered, you should retreat while you still can')
            end
        end

        --Get personality specific enemy and ally greetings
        if aiBrain[refiAssignedPersonality] == refiHall then
            if not(tbEnemyFactions[M28UnitInfo.refFactionUEF]) then
                AddPotentialMessage(LOC('<LOC XGG_MP1_010_010>[{i Hall}]: You will not stop the UEF!'), 'XGG_Hall__04566', 'XGG')
            end
            AddPotentialMessage(LOC('<LOC XGG_MP1_020_010>[{i Hall}]: Humanity will be saved!'), 'XGG_Hall__04567', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_030_010>[{i Hall}]: You\'re not going to stop me.'), 'XGG_Hall__04568', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_060_010>[{i Hall}]: Get out of here while you still can.'), 'XGG_Hall__04571', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_080_010>[{i Hall}]: You\'ve got no chance against me!'), 'XGG_Hall__04573', 'XGG')
        elseif aiBrain[refiAssignedPersonality] == refiFletcher then
            AddPotentialMessage(LOC('<LOC X01_T01_200_010>[{i Fletcher}]: It\'s time for this to get serious.'), 'X01_Fletcher_T01_04531', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X06_M02_011_010>[{i Fletcher}]: I spent a lot of time thinking about this. There\'s only one possible outcome. One way for this to end.'), 'X06_Fletcher_M02_04482', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_830_010>[{i Fletcher}]: This war is your fault! And now you will pay.'), 'X06_Fletcher_T01_03044', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_840_010>[{i Fletcher}]: You and your kind are responsible for this war.'),'X06_Fletcher_T01_03045', 'X06_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_130_010>[{i Fletcher}]: If you run now, I\'ll let ya go.'), 'XGG_Fletcher_MP1_04578', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_090_010>[{i Fletcher}]: This ain\'t gonna be much of a fight.'), 'XGG_Fletcher_MP1_04574', 'XGG')
            if iAllyHumans > 0 then
                AddPotentialMessage(LOC('<LOC X01_M01_030_010>[{i Fletcher}]: You just gated into a hell of a mess, Colonel, but I\'m glad you\'re here.'),'X01_Fletcher_M01_03419', 'X01_VO', true)
                if tbAlliedHumanFactions[M28UnitInfo.refFactionAeon] then
                    AddPotentialMessage(LOC('<LOC X01_M01_050_010>[{i Fletcher}]: I got my eyes on you, Aeon. I haven\'t forgotten what you people did during the War.'),'X01_Fletcher_M01_02879', 'X01_VO', true)
                end
            end
            if iAllyHumans > 0 and tbAlliedHumanFactions[M28UnitInfo.refFactionCybran] then
                AddPotentialMessage(LOC('<LOC X01_M01_040_010>[{i Fletcher}]: A Cybran, huh? I thought you guys would be busy changing the water in Brackman\'s brain tank.'), 'X01_Fletcher_M01_02877', 'X01_VO', true)
            elseif tbEnemyFactions[M28UnitInfo.refFactionCybran] and not(tbAlliedFactions[M28UnitInfo.refFactionCybran]) then
                AddPotentialMessage(LOC('<LOC X01_M01_040_010>[{i Fletcher}]: A Cybran, huh? I thought you guys would be busy changing the water in Brackman\'s brain tank.'), 'X01_Fletcher_M01_02877', 'X01_VO')
            end
            if tbEnemyFactions[M28UnitInfo.refFactionSeraphim] and not(tbAlliedFactions[M28UnitInfo.refFactionSeraphim]) then
                AddPotentialMessage(LOC('<LOC X01_T01_210_010>[{i Fletcher}]: You freaks are going to pay for what you did to Earth.'), 'X01_Fletcher_T01_04532', 'X01_VO')
            end
            if tbEnemyFactions[M28UnitInfo.refFactionUEF] then
                local sEnemyUEFNickname
                for iBrain, oBrain in ArmyBrains do
                    if not(oBrain.M28Team == aiBrain.M28Team) and not(M28Conditions.IsCivilianBrain(oBrain)) and oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                        sEnemyUEFNickname = oBrain.Nickname
                        if sEnemyUEFNickname then break end
                    end
                end
                if sEnemyUEFNickname then
                    AddPotentialMessage(LOC('<LOC X06_T01_680_010>[{i Fletcher}]: I thought I could trust you! You\'re a traitor '..sEnemyUEFNickname..'.'), 'X06_Fletcher_T01_03029', 'X06_VO')
                end
            end
        elseif aiBrain[refiAssignedPersonality] == refiGari then
            AddPotentialMessage(LOC('<LOC X01_M02_013_010>[{i Gari}]: I shall cleanse everyone on this planet! You are fools to stand against our might!'),'X01_Gari_M02_02896', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_180_010>[{i Gari}]: The Order is eternal. There is no stopping us.'), 'X01_Gari_T01_04529', 'X01_VO')
            if not(tbAlliedFactions[M28UnitInfo.refFactionUEF]) and tbEnemyFactions[M28UnitInfo.refFactionUEF] then
                AddPotentialMessage(LOC('<LOC X01_T01_120_010>[{i Gari}]: The UEF is finished. There will be no escaping us this time.'),'X01_Gari_T01_04522', 'X01_VO')
            end
            if not(tbAlliedFactions[M28UnitInfo.refFactionCybran]) and tbEnemyFactions[M28UnitInfo.refFactionCybran] then
                AddPotentialMessage(LOC('<LOC X01_T01_150_010>[{i Gari}]: You are an abomination. I will take great pleasure in exterminating you.'), 'X01_Gari_T01_04525', 'X01_VO')
                if math.random(1,2) == 1 then
                    AddPotentialMessage(LOC('<LOC X01_T01_140_010>[{i Gari}]: Brackman is a doddering old fool.'),'X01_Gari_T01_04524', 'X01_VO')
                end
            end
            if not(tbEnemyFactions[M28UnitInfo.refFactionSeraphim]) and tbAlliedFactions[M28UnitInfo.refFactionSeraphim] then
                AddPotentialMessage(LOC('<LOC X01_T01_160_010>[{i Gari}]: You are a fool for rejecting the Seraphim.'), 'X01_Gari_T01_04526', 'X01_VO')
            end
            AddPotentialMessage(LOC('<LOC X01_T01_060_010>[{i Gari}]: Now you will taste the fury of the Order of the Illuminate.'), 'X01_Gari_T01_04516', 'X01_VO')

        elseif aiBrain[refiAssignedPersonality] == refiCelene then
            if tbEnemyFactions[M28UnitInfo.refFactionUEF] and not(tbAlliedFactions[M28UnitInfo.refFactionUEF]) then
                AddPotentialMessage(LOC('<LOC X02_T01_100_010>[{i Celene}]: The UEF will fall. You have no future.'), 'X02_Celene_T01_04546', 'X02_VO')
            end
            if tbEnemyFactions[M28UnitInfo.refFactionCybran] and not(tbAlliedFactions[M28UnitInfo.refFactionCybran]) then
                AddPotentialMessage(LOC('<LOC X02_T01_110_010>[{i Celene}]: There is nothing I enjoy more than hunting Cybrans.'), 'X02_Celene_T01_04547', 'X02_VO')
            end

            AddPotentialMessage(LOC('<LOC X02_M01_050_010>[{i Celene}]: You do not comprehend the power that is arrayed against you.'), 'X02_Celene_M01_03130', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_M01_060_010>[{i Celene}]: Your mere presence here desecrates this planet. You are an abomination.'), 'X02_Celene_M01_03131', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_M02_060_020>[{i Celene}]: There is nothing here for you but death.'), 'X02_Celene_M02_04277',  'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_120_010>[{i Celene}]: Thousands of your brothers and sisters have fallen by my hand, and you will soon share their fate.'), 'X02_Celene_T01_04548',  'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_150_010>[{i Celene}]: I will not be defeated by the likes of you!'), 'X02_Celene_T01_04551','X02_VO')

        elseif aiBrain[refiAssignedPersonality] == refiRhiza then
            if tbEnemyFactions[M28UnitInfo.refFactionSeraphim] and not(tbAlliedFactions[M28UnitInfo.refFactionSeraphim]) then
                AddPotentialMessage(LOC('<LOC X06_T01_940_010>[{i Rhiza}]: There is nothing here save destruction for you, Seraphim!'), 'X06_Rhiza_T01_03054', 'X06_VO')
            end
            if iAllyHumans > 0 then
                AddPotentialMessage(LOC('<LOC X03_M01_032_010>[{i Rhiza}]: Prepare your forces. Rhiza out.'), 'X03_Rhiza_M01_04864', 'X03_VO', true)
                AddPotentialMessage(LOC('<LOC X03_M01_042_010>[{i Rhiza}]: Prepare your forces. Rhiza out.'), 'X03_Rhiza_M01_04866', 'X03_VO', true)
            end
            AddPotentialMessage(LOC('<LOC XGG_MP1_200_010>[{i Rhiza}]: All enemies of the Princess will be destroyed!'),'XGG_Rhiza_MP1_04585', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_230_010>[{i Rhiza}]: Flee while you can!'), 'XGG_Rhiza_MP1_04588', 'XGG')
            AddPotentialMessage(LOC('<LOC X06_T01_920_010>[{i Rhiza}]: Soon you will know my wrath!'), 'X06_Rhiza_T01_03052', 'X06_VO')
        elseif aiBrain[refiAssignedPersonality] == refiVendetta then
            AddPotentialMessage(LOC('<LOC X06_T01_530_010>[{i Vendetta}]: Your reliance on technology shall be your undoing.'), 'X06_Vedetta_T01_03015', 'X06_VO')
        elseif aiBrain[refiAssignedPersonality] == refiKael then
            AddPotentialMessage(LOC('<LOC XGG_MP1_250_010>[{i Kael}]: The Order will not be defeated!'), 'XGG_Kael_MP1_04590', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_270_010>[{i Kael}]: There will be nothing left of you when I am done.'), 'XGG_Kael_MP1_04592', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_300_010>[{i Kael}]: Run while you can.'), 'XGG_Kael_MP1_04595', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_260_010>[{i Kael}]: If you grovel, I may let you live.'), 'XGG_Kael_MP1_04591', 'XGG')
            --QAI - see above
        elseif aiBrain[refiAssignedPersonality] == refiDostya then
            AddPotentialMessage(LOC('<LOC XGG_MP1_330_010>[{i Dostya}]: I have little to fear from the likes of you.'), 'XGG_Dostya_MP1_04598', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_350_010>[{i Dostya}]: I would flee, if I were you.'), 'XGG_Dostya_MP1_04600', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_360_010>[{i Dostya}]: You will be just another in my list of victories.'), 'XGG_Dostya_MP1_04601', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_400_010>[{i Dostya}]: I will destroy you.'), 'XGG_Dostya_MP1_04605', 'XGG')
        elseif aiBrain[refiAssignedPersonality] == refiBrackman then
            AddPotentialMessage(LOC('<LOC XGG_MP1_410_010>[{i Brackman}]: I\'m afraid there is no hope for you, oh yes.'), 'XGG_Brackman_MP1_04606', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_460_010>[{i Brackman}]: Defeating you is hardly worth the effort, oh yes.'), 'XGG_Brackman_MP1_04611', 'XGG')
        elseif aiBrain[refiAssignedPersonality] == refiHex5 then
            AddPotentialMessage(LOC('<LOC X05_M02_010_010>[{i Hex5}]: You are incapable of comprehending our might. The Master is endless, his wisdom infinite. You will never defeat us.'), 'X05_Hex5_M02_03825', 'X05_VO')
            AddPotentialMessage(LOC('<LOC X05_M02_270_020>[{i Hex5}]: You will not defeat us. The Master is eternal, his wisdom infinite.'), 'X05_Hex5_M02_04949', 'X05_VO')
            AddPotentialMessage(LOC('<LOC X05_T01_160_010>[{i Hex5}]: You do not stand a chance against the Master. It will destroy you.'), 'X05_Hex5_T01_04430', 'X05_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_570_010>[{i Hex5}]: You\'re screwed!'), 'XGG_Hex5_MP1_04622', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_590_010>[{i Hex5}]: You should probably run away now.'), 'XGG_Hex5_MP1_04624', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_600_010>[{i Hex5}]: A smoking crater is going to be all that\'s left of you.'), 'XGG_Hex5_MP1_04625', 'XGG')
            if not(tbEnemyFactions[M28UnitInfo.refFactionSeraphim]) then
                AddPotentialMessage(LOC('<LOC X05_T01_190_010>[{i Hex5}]: You will bow before the Seraphim.'), 'X05_Hex5_T01_04433', 'X05_VO')
            end
        elseif aiBrain[refiAssignedPersonality] == refiOumEoshi then
            AddPotentialMessage(LOC('<LOC X04_T01_010_010>[{i OumEoshi}]: Your galaxy will soon be ours.'), 'X04_Oum-Eoshi_T01_04383', 'X04_VO')
            if not(tbEnemyFactions[M28UnitInfo.refFactionSeraphim]) then
                AddPotentialMessage(LOC('<LOC X04_T01_020_010>[{i OumEoshi}]: Only one species can attain perfection.'), 'X04_Oum-Eoshi_T01_04384', 'X04_VO')
            end
            if iEnemyHumans > 0 and not(tbEnemyFactions[M28UnitInfo.refFactionSeraphim]) then
                AddPotentialMessage(LOC('<LOC X06_M03_200_010>[{i SethIavow}]: You have no hope of standing against us: The Seraphim are eternal. Destroy the human.'), 'X06_Seth-iavow_M03_03997', 'X06_VO')
            end
            AddPotentialMessage(LOC('<LOC X04_T01_040_010>[{i OumEoshi}]: Soon there will be more of us than you can possibly ever hope to defeat.'), 'X04_Oum-Eoshi_T01_04386', 'X04_VO')
        elseif aiBrain[refiAssignedPersonality] == refiThelUuthow then
            if tbEnemyFactions[M28UnitInfo.refFactionUEF] and not(tbAlliedFactions[M28UnitInfo.refFactionUEF]) then
                AddPotentialMessage(LOC('<LOC X06_T01_200_010>[{i ThelUuthow}]: Your Earth fell easily. You will prove no different.'), 'X06_Thel-Uuthow_T01_02972',  'X06_VO')
            end
            if tbEnemyFactions[M28UnitInfo.refFactionCybran] and not(tbAlliedFactions[M28UnitInfo.refFactionCybran]) then
                AddPotentialMessage(LOC('<LOC X06_T01_210_010>[{i ThelUuthow}]: You Cybrans die as easily as any other human.'), 'X06_Thel-Uuthow_T01_02973', 'X06_VO')
            end
            if tbEnemyFactions[M28UnitInfo.refFactionAeon] or tbEnemyFactions[M28UnitInfo.refFactionSeraphim] then
                AddPotentialMessage(LOC('<LOC X06_T01_220_010>[{i ThelUuthow}]: Your faith in technology will be your undoing.'), 'X06_Thel-Uuthow_T01_02974', 'X06_VO')
            end
            AddPotentialMessage(LOC('<LOC X06_T01_260_010>[{i ThelUuthow}]: You will perish at my hand.'), 'X06_Thel-Uuthow_T01_02978', 'X06_VO')
        else
            --I.e. where personality is QAI, or we dont have a personality
            --if (aiBrain[refiAssignedPersonality] or refiQAI) == refiQAI then
            if iEnemyHumans >= 1 and bEnemyHasNonSeraphimFaction then
                AddPotentialMessage(LOC('<LOC X02_T01_180_010>: Humans are such curious creatures. Even in the face of insurmountable odds, you continue to resist.'), 'X02_QAI_T01_04554', 'X02_VO')
            end
            AddPotentialMessage(LOC('<LOC X05_T01_100_010>: On this day, I will teach you the true power of the Quantum Realm.'), 'X05_QAI_T01_04424', 'X05_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_280_010>: If you destroy this ACU, another shall rise in its place. I am endless.'), 'X02_QAI_T01_04564', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_220_010>: All calculations indicate that your demise is near.'), 'X02_QAI_T01_04558', 'X02_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_490_010>[{i QAI}]: You will not prevail.'), 'XGG_QAI_MP1_04614', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_500_010>[{i QAI}]: Your destruction is 99% certain.'), 'XGG_QAI_MP1_04615', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_510_010>[{i QAI}]: I cannot be defeated.'), 'XGG_QAI_MP1_04616', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_530_010>[{i QAI}]: My victory is without question.'), 'XGG_QAI_MP1_04618', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_540_010>[{i QAI}]: Your defeat can be the only outcome.'), 'XGG_QAI_MP1_04619', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_560_010>[{i QAI}]: Retreat is your only logical option.'), 'XGG_QAI_MP1_04621',  'XGG')

            if tbEnemyFactions[M28UnitInfo.refFactionCybran] then
                AddPotentialMessage(LOC('<LOC X02_T01_250_010>[{i QAI}]: All Symbionts will soon call me Master.'), 'X02_QAI_T01_04561', 'X02_VO')
            end
            if tbEnemyFactions[M28UnitInfo.refFactionUEF] and not(tbAlliedFactions[M28UnitInfo.refFactionUEF]) then
                AddPotentialMessage(LOC('<LOC X05_T01_070_010>[{i QAI}]: The UEF has lost 90% of its former territories. You are doomed.'), 'X05_QAI_T01_04421', 'X05_VO')
            end
            if iEnemyHumans > 1 then
                AddPotentialMessage(LOC('<LOC X05_T01_080_010>[{i QAI}]: I have examined our previous battles and created the appropriate subroutines to counter your strategies. You cannot win.'), 'X05_QAI_T01_04422', 'X05_VO')
                AddPotentialMessage(LOC('<LOC X05_T01_010_010>[{i QAI}]: Another Commander will not make a difference. You will never defeat me.'), 'X05_QAI_T01_04415','X05_VO')
            end
            if (tbAlliedFactions[M28UnitInfo.refFactionUEF] or tbAlliedFactions[M28UnitInfo.refFactionAeon]) and (tbEnemyFactions[M28UnitInfo.refFactionUEF] or tbEnemyFactions[M28UnitInfo.refFactionAeon]) and (aiBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF or aiBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon) then
                AddPotentialMessage(LOC('<LOC X05_M03_150_020>[{i QAI}]: The Seven Hand Node was quite effective at obtaining the schematics to your weapon systems. Now you shall be destroyed by your own weapons.'), 'X05_QAI_M03_04446', 'X05_VO')
            end
            if not(tbEnemyFactions[M28UnitInfo.refFactionSeraphim]) and aiBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then
                AddPotentialMessage(LOC('<LOC X05_T01_110_010>[{i QAI}]: The Seraphim are the true gods. You would be wise to remember that.'), 'X05_QAI_T01_04425', 'X05_VO')
            end
            if not(tbEnemyFactions[M28UnitInfo.refFactionSeraphim]) and tbAlliedFactions[M28UnitInfo.refFactionSeraphim] and aiBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then
                if tbEnemyFactions[M28UnitInfo.refFactionAeon] then
                    AddPotentialMessage(LOC('<LOC X02_T01_270_010>[{i QAI}]: I have witnessed the truth and beauty of the Seraphim. They are the true gods, and you are a fool for abandoning them.'), 'X02_QAI_T01_04563', 'X02_VO')
                end
                AddPotentialMessage(LOC('<LOC X02_T01_200_010>[{i QAI}]: You have no chance of defeating the Seraphim.'), 'X02_QAI_T01_04556', 'X02_VO')
            end
        end
        if M28Utilities.IsTableEmpty(tsPotentialMessages) or table.getn(tsPotentialMessages) <= 3 or math.random(1,2) == 1 then
            AddPotentialMessage('gl hf')
            AddPotentialMessage('gl')
        end
    end
    local oBrainToSendMessage = aiBrain
    if bDebugMessages == true then LOG(sFunctionRef..': Finished getting potential global and team messages, tsPotentialMessages='..repru(tsPotentialMessages)..'; tsPotentialTeamMessages='..repru(tsPotentialTeamMessages)..'; oBrainToSendMessage='..(oBrainToSendMessage.Nickname or 'nil')..'; Table size='..table.getn(tsPotentialMessages)) end
    --Have already waited 20s before getting to this point
    if M28Utilities.IsTableEmpty(tsPotentialMessages) == false and oBrainToSendMessage then
        --Its likely just coincidence, but just incase, will add some randomness based on game settings
        local iTableSize = table.getn(tsPotentialMessages)
        local iRand = math.random(1, iTableSize)
        local iRandomResetCycle = math.min(10, math.floor((math.random(2,3) + M28Team.iPlayersAtGameStart + aiBrain:GetArmyIndex()) * 0.5))
        while iRandomResetCycle > 0 do
            local iTempRand = math.random(1, iTableSize)
            if bDebugMessages == true then LOG(sFunctionRef..': iTempRand='..iTempRand) end
            iRandomResetCycle = iRandomResetCycle - 1
        end
        if bDebugMessages == true then LOG(sFunctionRef..': iRand='..iRand..'; Chosen message='..tsPotentialMessages[iRand]..'; new math.random result='..math.random(1,iTableSize)..'; and a second time='..math.random(1, iTableSize)..'; iTableSize='..iTableSize..'; random 4th time iwth iTableSize='..math.random(1, iTableSize)..'; random 5th time but with hardcoded 6 instead of variable='..math.random(1,6)..'; random 6th time iwth iTableSize='..math.random(1, iTableSize)) end
        --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
        SendMessage(oBrainToSendMessage, (sOptionalMessageTypePrefix or '')..'Start', tsPotentialMessages[iRand], 20, 60, false, M28Map.bIsCampaignMap, tsCueByMessageIndex[iRand], tsBankBymessageIndex[iRand])
    end
    if M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false and oBrainToSendMessage then
        local iRand = math.random(1, table.getn(tsPotentialTeamMessages))
        if bDebugMessages == true then LOG(sFunctionRef..': iRand='..iRand..'; Chosen team message='..tsPotentialTeamMessages[iRand]) end
        --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
        SendMessage(oBrainToSendMessage, (sOptionalMessageTypePrefix or '')..'Team'..(aiBrain.M28Team or 1)..'Start', tsPotentialTeamMessages[iRand], 0, 60, true, M28Map.bIsCampaignMap, tsTeamCueIndex[iRand], tsTeamBankIndex[iRand])
    end

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function ConsiderPerTeamStartMessage(aiBrain)
    ForkThread(SendStartOfGameMessage, aiBrain, (aiBrain.M28Team - 1) * 10, aiBrain.M28Team)
end

function ConsiderMessageForACUInTrouble(oACU, aiBrain)
    --Will have been through some conditions just to get here
    local sFunctionRef = 'ConsiderMessageForACUInTrouble'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)


    if aiBrain.M28AI and not(aiBrain.M28IsDefeated) and not(aiBrain:IsDefeated()) and EntityCategoryContains(categories.COMMAND + categories.SUBCOMMANDER, oACU.UnitId) and M28UnitInfo.IsUnitValid(oACU) and M28UnitInfo.GetUnitHealthPercent(oACU) >= 0.15 then
        local tsPotentialMessages = {}
        local tsCueByMessageIndex = {}
        local tsBankBymessageIndex = {}
        local oBrainToSendMessage = aiBrain

        local tsPotentialTeamMessages = {}
        local tsTeamCueIndex = {}
        local tsTeamBankIndex = {}

        function AddPotentialMessage(sMessage, sOptionalCue, sOptionalBank, bIsTeamMessage)
            if bIsTeamMessage then
                table.insert(tsPotentialTeamMessages, sMessage)
                if sOptionalCue and sOptionalBank then
                    local iRef = table.getn(tsPotentialTeamMessages)
                    tsTeamCueIndex[iRef] = sOptionalCue
                    tsTeamBankIndex[iRef] = sOptionalBank
                end

            else
                table.insert(tsPotentialMessages, sMessage)
                if sOptionalCue and sOptionalBank then
                    local iRef = table.getn(tsPotentialMessages)
                    tsCueByMessageIndex[iRef] = sOptionalCue
                    tsBankBymessageIndex[iRef] = sOptionalBank
                end
            end
        end

        local bHaveTeammates = false
        for iBrain, oBrain in ArmyBrains do
            if oBrain.M28Team == aiBrain.M28Team and not(oBrain == aiBrain) and not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) then
                bHaveTeammates = true
            end
        end
        if oBrainToSendMessage[refiAssignedPersonality] == refiFletcher then
            AddPotentialMessage(LOC('<LOC X01_M03_100_010>[{i Fletcher}]: Where are my reinforcements?'), 'X01_Fletcher_M03_03695', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_230_010>[{i Fletcher}]: I\'m in a lot of trouble!'), 'X01_Fletcher_T01_04534', 'X01_VO')
            if bHaveTeammates then
                AddPotentialMessage(LOC('<LOC X05_M02_300_010>[{i Fletcher}]: I\'m getting hit pretty hard! Get over here and help me! Fletcher out.'), 'X05_Fletcher_M02_05108', 'X05_VO', true)
                AddPotentialMessage(LOC('<LOC X01_T01_220_010>[{i Fletcher}]: Commander, I could use a hand over here. I\'m getting hit pretty hard.'), 'X01_Fletcher_T01_04533', 'X01_VO', true)
                local bHaveUEFTeammate = false
                local bHaveCybranTeammate = false
                for iBrain, oBrain in ArmyBrains do
                    if oBrain.M28Team == aiBrain.M28Team and not(oBrain == aiBrain) and not(oBrain.M28IsDefeated) then
                        if oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then bHaveUEFTeammate = true
                        elseif oBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then bHaveCybranTeammate = true
                        end
                    end
                end
                if bHaveUEFTeammate then
                    AddPotentialMessage(LOC('<LOC X05_M02_310_010>[{i Fletcher}]: Colonel, I\'d really appreciate it if you could help me out. The enemy is pounding me pretty hard. Fletcher out.'), 'X05_Fletcher_M02_05109', 'X05_VO', true)
                end
                if bHaveCybranTeammate then
                    AddPotentialMessage(LOC('<LOC X05_M02_320_010>[{i Fletcher}]: Get it in gear, Cybran! The enemy is kicking the tar out of me and I need your help. Fletcher out.'), 'X05_Fletcher_M02_05110', 'X05_VO', true)
                end
            end
            --is the enemy likely to kill us with air?
            if M28Team.tTeamData[aiBrain.M28Team][M28Team.refiEnemyAirToGroundThreat] >= 500 then
                local tUnitLZData, tUnitLZTeamData = M28Map.GetLandOrWaterZoneData(oACU:GetPosition(), true, aiBrain.M28Team)
                if (tUnitLZTeamData[M28Map.refiEnemyAirToGroundThreat] or 0) >= 400 and (tUnitLZTeamData[M28Map.subrefTThreatEnemyCombatTotal] or 0) <= math.max(200, (tUnitLZTeamData[M28Map.refiEnemyAirToGroundThreat] or 0) * 0.75) then
                    AddPotentialMessage(LOC('<LOC X06_T01_690_010>[{i Fletcher}]: You\'re a coward.'), 'X06_Fletcher_T01_03030', 'X06_VO')
                end
            end
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiAmalia then
            AddPotentialMessage(LOC('<LOC X05_M02_170_010>[{i Amalia}]: My ACU is seriously damaged, Commander!'), 'X05_Amalia_M02_03850', 'X05_VO')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiKael then
            if bHaveTeammates then
                AddPotentialMessage(LOC('<LOC X06_M03_060_020>[{i Kael}]: Do something!'), 'X06_Kael_M03_04499', 'X06_VO', true)
            end
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiRhiza then
            AddPotentialMessage(LOC('<LOC X06_T01_885_010>[{i Rhiza}]: Such a thing will not stop me!'), 'X06_Rhiza_T01_04508', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_887_010>[{i Rhiza}]: You mistake me if you think I will be cowed!'), 'X06_Rhiza_T01_04510', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_885_010>[{i Rhiza}]: Such a thing will not stop me!'), 'X06_Rhiza_T01_04508', 'X06_VO')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiKael then
            AddPotentialMessage(LOC('<LOC XGG_MP1_250_010>[{i Kael}]: The Order will not be defeated!'), 'XGG_Kael_MP1_04590', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiBrackman then
            if bHaveTeammates then
                AddPotentialMessage(LOC('<LOC X05_M03_016_010>[{i Brackman}]: I am under attack, my child. Under attack. Please defend me.'), 'X05_Brackman_M03_04953', 'X05_VO', true)
                AddPotentialMessage(LOC('<LOC X05_M03_070_010>[{i Brackman}]: Hull integrity is dropping. Please help me, Commander.'), 'X05_Brackman_M03_03864', 'X05_VO', true)
            end
            AddPotentialMessage(LOC('<LOC XGG_MP1_440_010>[{i Brackman}]: Are you sure you want to do that?'), 'XGG_Brackman_MP1_04609', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiHex5 then
            AddPotentialMessage(LOC('<LOC X05_T01_140_010>[{i Hex5}]: The Master will punish you for that.'), 'X05_Hex5_T01_04428', 'X05_VO')
            AddPotentialMessage(LOC('<LOC X05_T01_220_010>[{i Hex5}]: Even if you destroy me, the Master lives on.'), 'X05_Hex5_T01_04436', 'X05_VO')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiQAI then
            AddPotentialMessage(LOC('<LOC X05_M03_325_040>[{i QAI}]: Your efforts will be for -- what are you doing? That is not possible.'), 'X05_QAI_M03_04450', 'X05_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_520_010>[{i QAI}]: Your strategies are without merit.'), 'XGG_QAI_MP1_04617', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiThelUuthow then
            AddPotentialMessage(LOC('<LOC X06_T01_250_010>[{i ThelUuthow}]: Perhaps you are a greater threat than I thought?'), 'X06_Thel-Uuthow_T01_02977', 'X06_VO')
        end

        --General messages
        if bHaveTeammates and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) and M28Utilities.IsTableEmpty(tsPotentialMessages) then
            AddPotentialMessage('I could use a hand here!', nil, nil, true)
            AddPotentialMessage('Uh-oh, I think I\'m in trouble here', nil, nil, true)
            AddPotentialMessage('I don\'t think I\'m going to survive this one...', nil, nil, true)
            AddPotentialMessage('I fear I have failed us, please accept my apologies if I die', nil, nil, true)
            --Does the enemy have more nearby land than us?
            local tUnitLZData, tUnitLZTeamData = M28Map.GetLandOrWaterZoneData(oACU:GetPosition(), true, aiBrain.M28Team)
            if tUnitLZTeamData[M28Map.refiModDistancePercent] >= 0.35 and tUnitLZTeamData[M28Map.subrefTThreatEnemyCombatTotal] >= 1000 and M28Team.tTeamData[aiBrain.M28Team][M28Team.subrefiHighestEnemyGroundTech] <= 2 then
                AddPotentialMessage('Maybe I shouldnt have overextended so much...')
            end
        end

        --If we have a team only message and a global message then only send one of them
        if bDebugMessages == true then LOG(sFunctionRef..': Finished getting potential global and team messages, tsPotentialMessages='..repru(tsPotentialMessages)..'; tsPotentialTeamMessages='..repru(tsPotentialTeamMessages)..'; oBrainToSendMessage='..(oBrainToSendMessage.Nickname or 'nil')) end
        local bSendGlobal = true
        local bSendTeam = true
        if M28Utilities.IsTableEmpty(tsPotentialMessages) == false and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false then
            if math.random(1,2) == 1 then bSendGlobal = false else bSendTeam = false end
        end
        if bSendGlobal and M28Utilities.IsTableEmpty(tsPotentialMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialMessages))
            --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
            SendMessage(oBrainToSendMessage, 'LostUnit'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialMessages[iRand], 0, 1200, false, M28Map.bIsCampaignMap, tsCueByMessageIndex[iRand], tsBankBymessageIndex[iRand])
        end
        if bSendTeam and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialTeamMessages))
            --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
            SendMessage(oBrainToSendMessage, oBrainToSendMessage.M28Team..'LostUnit'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialTeamMessages[iRand], 3, 1200, true, M28Map.bIsCampaignMap, tsTeamCueIndex[iRand], tsTeamBankIndex[iRand])
        end
    end

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function JustLostValuableUnit(oUnitID, oKilledUnitBrain)
    local sFunctionRef = 'JustLostValuableUnit'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)


    local aiBrain = oKilledUnitBrain
    if aiBrain.M28AI and not(aiBrain.M28IsDefeated) and not(aiBrain:IsDefeated()) then
        local tsPotentialMessages = {}
        local tsCueByMessageIndex = {}
        local tsBankBymessageIndex = {}
        local oBrainToSendMessage = aiBrain

        local tsPotentialTeamMessages = {}
        local tsTeamCueIndex = {}
        local tsTeamBankIndex = {}

        function AddPotentialMessage(sMessage, sOptionalCue, sOptionalBank, bIsTeamMessage)
            if bIsTeamMessage then
                table.insert(tsPotentialTeamMessages, sMessage)
                if sOptionalCue and sOptionalBank then
                    local iRef = table.getn(tsPotentialTeamMessages)
                    tsTeamCueIndex[iRef] = sOptionalCue
                    tsTeamBankIndex[iRef] = sOptionalBank
                end

            else
                table.insert(tsPotentialMessages, sMessage)
                if sOptionalCue and sOptionalBank then
                    local iRef = table.getn(tsPotentialMessages)
                    tsCueByMessageIndex[iRef] = sOptionalCue
                    tsBankBymessageIndex[iRef] = sOptionalBank
                end
            end
        end
        local bHaveTeammates = false
        for iBrain, oBrain in ArmyBrains do
            if oBrain.M28Team == aiBrain.M28Team and not(oBrain == aiBrain) and not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) then
                bHaveTeammates = true
            end
        end

        if oBrainToSendMessage[refiAssignedPersonality] == refiFletcher then
            AddPotentialMessage(LOC('<LOC X01_M03_100_010>[{i Fletcher}]: Where are my reinforcements?'), 'X01_Fletcher_M03_03695', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_230_010>[{i Fletcher}]: I\'m in a lot of trouble!'), 'X01_Fletcher_T01_04534', 'X01_VO')
            if bHaveTeammates then
                AddPotentialMessage(LOC('<LOC X05_M02_330_010>[{i Fletcher}]: My base is being destroyed. I need help! I can\'t hold them off!'), 'X05_Fletcher_M02_05111', 'X05_VO')
                AddPotentialMessage(LOC('<LOC X05_M02_300_010>[{i Fletcher}]: I\'m getting hit pretty hard! Get over here and help me! Fletcher out.'), 'X05_Fletcher_M02_05108', 'X05_VO')
                AddPotentialMessage(LOC('<LOC X05_M02_340_010>[{i Fletcher}]: Enemy units are hitting my base pretty hard. I need you to reinforce my position. Fletcher out.'), 'X05_Fletcher_M02_05112', 'X05_VO')
            end
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiCelene then
            AddPotentialMessage(LOC('<LOC X02_M02_176_010>[{i Celene}]: I can still make things right.'), 'X02_Celene_M02_04287', 'X02_VO')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiKael then
            AddPotentialMessage(LOC('<LOC X06_M03_060_020>[{i Kael}]: Do something!'), 'X06_Kael_M03_04499', 'X06_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_250_010>[{i Kael}]: The Order will not be defeated!'), 'XGG_Kael_MP1_04590', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiVendetta then
            AddPotentialMessage(LOC('<LOC X06_T01_570_010>[{i Vendetta}]: I am not defeated yet!'), 'X06_Vedetta_T01_03019', 'X06_VO')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiRhiza then
            AddPotentialMessage(LOC('<LOC X06_T01_883_010>[{i Rhiza}]: It does not matter, I will continue to attack!'), 'X06_Rhiza_T01_04506', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_885_010>[{i Rhiza}]: Such a thing will not stop me!'), 'X06_Rhiza_T01_04508', 'X06_VO')
            if EntityCategoryContains(M28UnitInfo.refCategoryStructure, oUnitID) then AddPotentialMessage(LOC('<LOC X06_T01_886_010>[{i Rhiza}]: I will rebuild twice as strong!'), 'X06_Rhiza_T01_04509', 'X06_VO') end
            AddPotentialMessage(LOC('<LOC X06_T01_887_010>[{i Rhiza}]: You mistake me if you think I will be cowed!'), 'X06_Rhiza_T01_04510', 'X06_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_210_010>[{i Rhiza}]: I will hunt you to the ends of the galaxy!'), 'XGG_Rhiza_MP1_04586', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiBrackman then
            AddPotentialMessage(LOC('<LOC XGG_MP1_440_010>[{i Brackman}]: Are you sure you want to do that?'), 'XGG_Brackman_MP1_04609', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiHex5 then
            AddPotentialMessage(LOC('<LOC X05_T01_140_010>[{i Hex5}]: The Master will punish you for that.'), 'X05_Hex5_T01_04428', 'X05_VO')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiQAI then
            if EntityCategoryContains(M28UnitInfo.refCategoryStructure, oUnitID) then
                AddPotentialMessage(LOC('<LOC X05_T01_040_010>[{i QAI}]: Those bases are of no consequence.'), 'X05_QAI_T01_04418', 'X05_VO')
                AddPotentialMessage(LOC('<LOC X05_T01_050_010>[{i QAI}]: That building means nothing to me.'), 'X05_QAI_T01_04419', 'X05_VO')
            end
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiThelUuthow then
            AddPotentialMessage(LOC('<LOC X06_T01_010_010>[{i ThelUuthow}]: You have accomplished nothing. You will never defeat us.'), 'X06_Thel-Uuthow_T01_04462', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_250_010>[{i ThelUuthow}]: Perhaps you are a greater threat than I thought?'), 'X06_Thel-Uuthow_T01_02977', 'X06_VO')
        end

        if bDebugMessages == true then LOG(sFunctionRef..': Finished getting potential global and team messages, tsPotentialMessages='..repru(tsPotentialMessages)..'; tsPotentialTeamMessages='..repru(tsPotentialTeamMessages)..'; oBrainToSendMessage='..(oBrainToSendMessage.Nickname or 'nil')) end
        local bSendGlobal = true
        local bSendTeam = true
        if M28Utilities.IsTableEmpty(tsPotentialMessages) == false and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false then
            if math.random(1,2) == 1 then bSendGlobal = false else bSendTeam = false end
        end
        if bSendGlobal and M28Utilities.IsTableEmpty(tsPotentialMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialMessages))
            --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
            SendMessage(oBrainToSendMessage, 'LostUnit'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialMessages[iRand], 0, 1200, false, M28Map.bIsCampaignMap, tsCueByMessageIndex[iRand], tsBankBymessageIndex[iRand])
        end
        if bSendTeam and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialTeamMessages))
            --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
            SendMessage(oBrainToSendMessage, oBrainToSendMessage.M28Team..'LostUnit'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialTeamMessages[iRand], 3, 1200, true, M28Map.bIsCampaignMap, tsTeamCueIndex[iRand], tsTeamBankIndex[iRand])
        end
    end

    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function JustKilledEnemyValuableUnit(oUnitID, oKilledUnitBrain, oKillerBrain)
    local sFunctionRef = 'JustKilledEnemyValuableUnit'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if oKillerBrain.M28AI and oKillerBrain[refiAssignedPersonality] and (not(oKillerBrain[refiAssignedPersonality] == refiQAI) or oKillerBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran) then
        local tsPotentialMessages = {}
        local tsCueByMessageIndex = {}
        local tsBankBymessageIndex = {}
        local oBrainToSendMessage = oKillerBrain

        local tsPotentialTeamMessages = {}
        local tsTeamCueIndex = {}
        local tsTeamBankIndex = {}

        function AddPotentialMessage(sMessage, sOptionalCue, sOptionalBank, bIsTeamMessage)
            if bIsTeamMessage then
                table.insert(tsPotentialTeamMessages, sMessage)
                if sOptionalCue and sOptionalBank then
                    local iRef = table.getn(tsPotentialTeamMessages)
                    tsTeamCueIndex[iRef] = sOptionalCue
                    tsTeamBankIndex[iRef] = sOptionalBank
                end

            else
                table.insert(tsPotentialMessages, sMessage)
                if sOptionalCue and sOptionalBank then
                    local iRef = table.getn(tsPotentialMessages)
                    tsCueByMessageIndex[iRef] = sOptionalCue
                    tsBankBymessageIndex[iRef] = sOptionalBank
                end
            end
        end

        if oBrainToSendMessage[refiAssignedPersonality] == refiFletcher then
            AddPotentialMessage(LOC('<LOC X01_M03_170_010>[{i Fletcher}]: That\'s what I love to see. Burn, baby, burn!'), 'X01_Fletcher_M03_03701', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_860_010>[{i Fletcher}]: There is no stopping me!'), 'X06_Fletcher_T01_03047', 'X06_VO')
            local bHaveTeammates = false
            for iBrain, oBrain in ArmyBrains do
                if oBrain.M28Team == oBrainToSendMessage.M28Team and not(oBrain == oBrainToSendMessage) and not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) then
                    bHaveTeammates = true
                    break
                end
            end
            if bHaveTeammates then
                AddPotentialMessage(LOC('<LOC X05_M02_120_010>[{i Fletcher}]: We got him on the ropes!'), 'X05_Fletcher_M02_03845', 'X05_VO')
                if M28Utilities.IsTableEmpty(M28Team.tTeamData[oBrainToSendMessage.M28Team][M28Team.reftEnemyLandExperimentals]) then
                    AddPotentialMessage(LOC('<LOC X05_M02_140_010>[{i Fletcher}]: He\'s got almost nothing left! Take him out!'), 'X05_Fletcher_M02_03847', 'X05_VO')
                end
            end
            AddPotentialMessage(LOC('<LOC XGG_MP1_100_010>[{i Fletcher}]: You\'re not puttin\' up much of a fight.'), 'XGG_Fletcher_MP1_04575', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_110_010>[{i Fletcher}]: Do you have any idea of what you\'re doing?'), 'XGG_Fletcher_MP1_04576', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_120_010>[{i Fletcher}]: Not much on tactics, are ya?'), 'XGG_Fletcher_MP1_04577', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_140_010>[{i Fletcher}]: You ain\'t too good at this, are you?'), 'XGG_Fletcher_MP1_04579', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_150_010>[{i Fletcher}]: Guess I got time to smack you around.'), 'XGG_Fletcher_MP1_04580', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_160_010>[{i Fletcher}]: I feel a bit bad, beatin\' up on you like this.'), 'XGG_Fletcher_MP1_04581', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiHall then
            AddPotentialMessage(LOC('<LOC XGG_MP1_030_010>[{i Hall}]: You\'re not going to stop me.'), 'XGG_Hall__04568', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_040_010>[{i Hall}]: The gloves are coming off.'), 'XGG_Hall__04569', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_050_010>[{i Hall}]: You\'re in my way.'), 'XGG_Hall__04570', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_080_010>[{i Hall}]: You\'ve got no chance against me!'), 'XGG_Hall__04573', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiGari then
            AddPotentialMessage(LOC('<LOC X01_M02_161_010>[{i Gari}]: Ha-ha-ha!'), 'X01_Gari_M02_04245', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_040_010>[{i Gari}]: Your tenacity is admirable, but the outcome of this battle was determined long ago.'), 'X01_Gari_T01_04514', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_060_010>[{i Gari}]: Now you will taste the fury of the Order of the Illuminate.'), 'X01_Gari_T01_04516', 'X01_VO')
            AddPotentialMessage(LOC('<LOC X01_T01_070_010>[{i Gari}]: You have nowhere to hide, nowhere to run.'), 'X01_Gari_T01_04517', 'X01_VO')
            if EntityCategoryContains(categories.EXPERIMENTAL, oUnitID) then AddPotentialMessage(LOC('<LOC X01_T01_100_010>[{i Gari}]: Not even your most powerful weapon can stand before me.'), 'X01_Gari_T01_04520', 'X01_VO') end
            AddPotentialMessage(LOC('<LOC X01_T01_110_010>[{i Gari}]: Beg for mercy and perhaps I shall grant you an honorable death.'), 'X01_Gari_T01_04521', 'X01_VO')
            if oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                --Check no UEF on our team
                local bHaveUEFOnTeam = false
                for iBrain, oBrain in ArmyBrains do
                    if oBrain.M28Team == oBrainToSendMessage.M28Team and oBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                        bHaveUEFOnTeam = true
                        break
                    end
                end
                if not(bHaveUEFOnTeam) then
                    AddPotentialMessage(LOC('<LOC X01_M02_250_010>[{i Gari}]: At long last, the end of the UEF is within my sights. This day has been a long time coming.'), 'X01_Gari_M02_03664', 'X01_VO')
                end
            elseif oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                AddPotentialMessage(LOC('<LOC X01_M02_270_010>[{i Gari}]: You have abandoned your people, your heritage and your gods. For that, you will be destroyed.'), 'X01_Gari_M02_03668', 'X01_VO')
            end
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiRhiza then
            if oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                AddPotentialMessage(LOC('<LOC X01_M02_270_020>[{i Rhiza}]: You have perverted The Way with your fanaticism. For that, you will be destroyed.'), 'X01_Rhiza_M02_03669', 'X01_VO')
            end
            AddPotentialMessage(LOC('<LOC X06_T01_900_010>[{i Rhiza}]: Glory to the Princess!'), 'X06_Rhiza_T01_03050', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_910_010>[{i Rhiza}]: It is unwise to ignore me.'), 'X06_Rhiza_T01_03051', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_920_010>[{i Rhiza}]: Soon you will know my wrath!'), 'X06_Rhiza_T01_03052', 'X06_VO')
            AddPotentialMessage(LOC('<LOC X06_T01_930_010>[{i Rhiza}]: The will of the Princess will not be denied!'), 'X06_Rhiza_T01_03053', 'X06_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_170_010>[{i Rhiza}]: Glory to the Princess!'), 'XGG_Rhiza_MP1_04582', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_180_010>[{i Rhiza}]: Glorious!'), 'XGG_Rhiza_MP1_04583', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_190_010>[{i Rhiza}]: I will not be stopped!'), 'XGG_Rhiza_MP1_04584', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_220_010>[{i Rhiza}]: For the Aeon!'), 'XGG_Rhiza_MP1_04587', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_240_010>[{i Rhiza}]: Behold the power of the Illuminate!'), 'XGG_Rhiza_MP1_04589', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiKael then
            AddPotentialMessage(LOC('<LOC X03_M02_115_020>[{i Kael}]: Ha-ha-ha!'), 'X03_Kael_M02_04368', 'X03_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_280_010>[{i Kael}]: You\'re beginning to bore me.'), 'XGG_Kael_MP1_04593', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_290_010>[{i Kael}]: My time is wasted on you.'), 'XGG_Kael_MP1_04594', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_310_010>[{i Kael}]: It must be frustrating to be so completely overmatched.'), 'XGG_Kael_MP1_04596', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_320_010>[{i Kael}]: Beg for mercy.'), 'XGG_Kael_MP1_04597', 'XGG')

        elseif oBrainToSendMessage[refiAssignedPersonality] == refiCelene then
            if EntityCategoryContains(categories.EXPERIMENTAL, oUnitID) then
                AddPotentialMessage(LOC('<LOC X02_T01_001_010>[{i Celene}]: No, you may not have that experimental.'), 'X02_Celene_T01_04782', 'X02_VO')
            end
            AddPotentialMessage(LOC('<LOC X02_T01_090_010>[{i Celene}]: Nothing can save you now!'), 'X02_Celene_T01_04544', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_095_010>[{i Celene}]: Beg me for mercy! Beg!'), 'X02_Celene_T01_04545', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_070_010>[{i Celene}]: Every day you grow weaker. Your end is drawing near.'), 'X02_Celene_T01_04542', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_090_010>[{i Celene}]: Nothing can save you now!'), 'X02_Celene_T01_04544', 'X02_VO')

        elseif oBrainToSendMessage[refiAssignedPersonality] == refiVendetta then
            local bHaveTeammates = false
            for iBrain, oBrain in ArmyBrains do
                if oBrain.M28Team == oBrainToSendMessage.M28Team and not(oBrain==oBrainToSendMessage) and not(oBrain.M28IsDefeated) and not(oBrain:IsDefeated()) then
                    bHaveTeammates = true
                    break
                end
            end
            if bHaveTeammates then
                AddPotentialMessage(LOC('<LOC X06_T01_500_010>[{i Vendetta}]: Why are you still fighting us?'), 'X06_Vedetta_T01_03012', 'X06_VO')
            end
            if oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then
                AddPotentialMessage(LOC('<LOC X06_T01_520_010>[{i Vendetta}]: You are an abomination.'), 'X06_Vedetta_T01_03014', 'X06_VO')
            end
            if oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionAeon then
                AddPotentialMessage(LOC('<LOC X06_T01_540_010>[{i Vendetta}]: You will die by my hand, traitor.'), 'X06_Vedetta_T01_03016', 'X06_VO')
            end
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiDostya then
            AddPotentialMessage(LOC('<LOC XGG_MP1_340_010>[{i Dostya}]: Observe. You may learn something.'), 'XGG_Dostya_MP1_04599', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_370_010>[{i Dostya}]: You are not worth my time.'), 'XGG_Dostya_MP1_04602', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_380_010>[{i Dostya}]: Your defeat is without question.'), 'XGG_Dostya_MP1_04603', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_390_010>[{i Dostya}]: You seem to have courage. Intelligence seems to be lacking.'), 'XGG_Dostya_MP1_04604', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_400_010>[{i Dostya}]: I will destroy you.'), 'XGG_Dostya_MP1_04605', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiBrackman then
            AddPotentialMessage(LOC('<LOC XGG_MP1_410_010>[{i Brackman}]: I\'m afraid there is no hope for you, oh yes.'), 'XGG_Brackman_MP1_04606', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_420_010>[{i Brackman}]: Well, at least you provided me with some amusement.'), 'XGG_Brackman_MP1_04607', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_430_010>[{i Brackman}]: Perhaps some remedial training is in order?'), 'XGG_Brackman_MP1_04608', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_450_010>[{i Brackman}]: They do not call me a genius for nothing, you know.'), 'XGG_Brackman_MP1_04610', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_460_010>[{i Brackman}]: Defeating you is hardly worth the effort, oh yes.'), 'XGG_Brackman_MP1_04611', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_470_010>[{i Brackman}]: There is nothing you can do.'), 'XGG_Brackman_MP1_04612', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_480_010>[{i Brackman}]: At least you will not suffer long.'), 'XGG_Brackman_MP1_04613', 'XGG')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiHex5 then
            AddPotentialMessage(LOC('<LOC X05_T01_150_010>[{i Hex5}]: You are weak and soft, frightened by what you don\'t understand.'), 'X05_Hex5_T01_04429', 'X05_VO')
            AddPotentialMessage(LOC('<LOC XGG_MP1_580_010>[{i Hex5}]: I do make it look easy.'), 'XGG_Hex5_MP1_04623', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_610_010>[{i Hex5}]: So, I guess failure runs in your family?'), 'XGG_Hex5_MP1_04626', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_620_010>[{i Hex5}]: Man, I\'m good at this!'), 'XGG_Hex5_MP1_04627', 'XGG')
            AddPotentialMessage(LOC('<LOC XGG_MP1_640_010>[{i Hex5}]: Don\'t worry, it\'ll be over soon.'), 'XGG_Hex5_MP1_04629', 'XGG')

        elseif oBrainToSendMessage[refiAssignedPersonality] == refiQAI then
            AddPotentialMessage(LOC('<LOC X02_T01_210_010>[{i QAI}]: My influence is much more vast than you can imagine.'), 'X02_QAI_T01_04557', 'X02_VO')
            AddPotentialMessage(LOC('<LOC X02_T01_220_010>[{i QAI}]: All calculations indicate that your demise is near.'), 'X02_QAI_T01_04558', 'X02_VO')
            if not(oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionSeraphim) then
                AddPotentialMessage(LOC('<LOC X02_T01_180_010>[{i QAI}]: Humans are such curious creatures. Even in the face of insurmountable odds, you continue to resist.'), 'X02_QAI_T01_04554', 'X02_VO')
            end
            AddPotentialMessage(LOC('<LOC XGG_MP1_550_010>[{i QAI}]: Your efforts are futile.'), 'XGG_QAI_MP1_04620', 'XGG')

        elseif oBrainToSendMessage[refiAssignedPersonality] == refiOumEoshi then
            AddPotentialMessage(LOC('<LOC X04_M03_055_010>[{i OumEoshi}]: Only now do you realize the futility of your situation. We know what you know, we see what you see. There is no stopping us.'), 'X04_Oum-Eoshi_M03_04402', 'X04_VO')
            AddPotentialMessage(LOC('<LOC X04_T01_030_010>[{i OumEoshi}]: Do not fret. Dying by my hand is the supreme honor.'), 'X04_Oum-Eoshi_T01_04385', 'X04_VO')
            --If against non-Seraphim
            if not(oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionSeraphim) then
                AddPotentialMessage(LOC('<LOC X04_M03_057_010>[{i OumEoshi}]: Humanity\'s time is at an end. You will be rendered extinct.'), 'X04_Oum-Eoshi_M03_04404', 'X04_VO')
            end
            if oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionUEF then
                AddPotentialMessage(LOC('<LOC X04_M03_090_010>[{i OumEoshi}]: You will share the fate of Riley and Clarke. Goodbye, Colonel.'), 'X04_Oum-Eoshi_M03_03767', 'X04_VO')
            end
            AddPotentialMessage(LOC('<LOC X01_T01_250_010>[{i ShunUllevash}]: (Laughter)'), 'X01_seraphim_T01_05123', 'X01_VO')
        elseif oBrainToSendMessage[refiAssignedPersonality] == refiThelUuthow then
            AddPotentialMessage(LOC('<LOC X06_T01_240_010>[{i ThelUuthow}]: Bow down before our might, and we may spare you.'), 'X06_Thel-Uuthow_T01_02976', 'X06_VO')
            if not(oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionSeraphim) then
                AddPotentialMessage(LOC('<LOC X06_T01_190_010>[{i ThelUuthow}]: Your kind began this war. We are merely finishing it.'), 'X06_Thel-Uuthow_T01_02971', 'X06_VO')
            end
            if oKilledUnitBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran then
                AddPotentialMessage(LOC('<LOC X06_T01_210_010>[{i ThelUuthow}]: You Cybrans die as easily as any other human.'), 'X06_Thel-Uuthow_T01_02973', 'X06_VO')
            end
            AddPotentialMessage(LOC('<LOC X06_T01_260_010>[{i ThelUuthow}]: You will perish at my hand.'), 'X06_Thel-Uuthow_T01_02978', 'X06_VO')
        end

        if bDebugMessages == true then LOG(sFunctionRef..': Finished getting potential global and team messages, tsPotentialMessages='..repru(tsPotentialMessages)..'; tsPotentialTeamMessages='..repru(tsPotentialTeamMessages)..'; oBrainToSendMessage='..(oBrainToSendMessage.Nickname or 'nil')) end
        local bSendGlobal = true
        local bSendTeam = true
        if M28Utilities.IsTableEmpty(tsPotentialMessages) == false and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false then
            if math.random(1,2) == 1 then bSendGlobal = false else bSendTeam = false end
        end
        if bSendGlobal and M28Utilities.IsTableEmpty(tsPotentialMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialMessages))
            --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
            SendMessage(oBrainToSendMessage, 'KilledUnit'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialMessages[iRand], 0, 1200, false, M28Map.bIsCampaignMap, tsCueByMessageIndex[iRand], tsBankBymessageIndex[iRand])
        end
        if bSendTeam and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false and oBrainToSendMessage then
            local iRand = math.random(1, table.getn(tsPotentialTeamMessages))
            --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
            SendMessage(oBrainToSendMessage, oBrainToSendMessage.M28Team..'KilledUnit'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialTeamMessages[iRand], 3, 1200, true, M28Map.bIsCampaignMap, tsTeamCueIndex[iRand], tsTeamBankIndex[iRand])
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function PartCompleteExperimentalDamaged(oUnitDamaged, oUnitCausingDamage)
    local sFunctionRef = 'PartCompleteExperimentalDamaged'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    if not(oUnitDamaged[refbGivenUnitRelatedMessage]) then
        local oM28DamagerBrain = oUnitCausingDamage:GetAIBrain()
        if oM28DamagerBrain.M28AI and oM28DamagerBrain[refiAssignedPersonality] and (not(oM28DamagerBrain[refiAssignedPersonality] == refiQAI) or oM28DamagerBrain:GetFactionIndex() == M28UnitInfo.refFactionCybran) then
            oUnitDamaged[refbGivenUnitRelatedMessage] = true --even if dont have message set to true so we arent reconsidering this every time it takes damage

            local tsPotentialMessages = {}
            local tsCueByMessageIndex = {}
            local tsBankBymessageIndex = {}
            local oBrainToSendMessage = oM28DamagerBrain

            local tsPotentialTeamMessages = {}
            local tsTeamCueIndex = {}
            local tsTeamBankIndex = {}

            function AddPotentialMessage(sMessage, sOptionalCue, sOptionalBank, bIsTeamMessage)
                if bIsTeamMessage then
                    table.insert(tsPotentialTeamMessages, sMessage)
                    if sOptionalCue and sOptionalBank then
                        local iRef = table.getn(tsPotentialTeamMessages)
                        tsTeamCueIndex[iRef] = sOptionalCue
                        tsTeamBankIndex[iRef] = sOptionalBank
                    end

                else
                    table.insert(tsPotentialMessages, sMessage)
                    if sOptionalCue and sOptionalBank then
                        local iRef = table.getn(tsPotentialMessages)
                        tsCueByMessageIndex[iRef] = sOptionalCue
                        tsBankBymessageIndex[iRef] = sOptionalBank
                    end
                end
            end
            if oM28DamagerBrain[refiAssignedPersonality] == refiFletcher then
                AddPotentialMessage(LOC('<LOC X06_T01_585_010>[{i Fletcher}]: I won\'t let you use that experimental!'),'X06_Fletcher_T01_04803', 'X06_VO')
                AddPotentialMessage(LOC('<LOC X06_T01_587_010>[{i Fletcher}]: You can\'t stop me with that experimental! I\'ll destroy it first!'), 'X06_Fletcher_T01_04805', 'X06_VO')

            elseif oM28DamagerBrain[refiAssignedPersonality] == refiGari then
                AddPotentialMessage(LOC('<LOC X01_T01_001_010>[{i Gari}]: I will not allow you to build that experimental.'), 'X01_Gari_T01_04779', 'X01_VO')
                AddPotentialMessage(LOC('<LOC X01_T01_002_010>[{i Gari}]: No, you will not complete that experimental.'), 'X01_Gari_T01_04780', 'X01_VO')
                AddPotentialMessage(LOC('<LOC X01_T01_003_010>[{i Gari}]: An experimental? I am not so foolish as to let you finish that.'), 'X01_Gari_T01_04781', 'X01_VO')
            elseif oM28DamagerBrain[refiAssignedPersonality] == refiCelene then
                AddPotentialMessage(LOC('<LOC X02_T01_002_010>[{i Celene}]: I will destroy that experimental before you even finish it!'), 'X02_Celene_T01_04783', 'X02_VO')
                AddPotentialMessage(LOC('<LOC X02_T01_003_010>[{i Celene}]: Watch as I destroy your experimental even before it can be activated.'), 'X02_Celene_T01_04784', 'X02_VO')
            elseif oM28DamagerBrain[refiAssignedPersonality] == refiVendetta then
                AddPotentialMessage(LOC('<LOC X06_T01_275_010>[{i Vendetta}]: Your experimental could cause me problems, so I think I will eliminate it.'), 'X06_Vedetta_T01_04800', 'X06_VO')
                AddPotentialMessage(LOC('<LOC X06_T01_276_010>[{i Vendetta}]: No, you will not finish that experimental!'), 'X06_Vedetta_T01_04801', 'X06_VO')
                AddPotentialMessage(LOC('<LOC X06_T01_277_010>[{i Vendetta}]: Do not think you will complete that experimental!'), 'X06_Vedetta_T01_04802', 'X06_VO')
            elseif oM28DamagerBrain[refiAssignedPersonality] == refiQAI then
                AddPotentialMessage(LOC('<LOC X02_T01_165_010>[{i QAI}]: You will not complete that experimental unit.'), 'X02_QAI_T01_04785', 'X02_VO')
                AddPotentialMessage(LOC('<LOC X02_T01_166_010>[{i QAI}]: I will not allow you to jeopardize my mission by finishing that experimental.'), 'X02_QAI_T01_04786', 'X02_VO')
                AddPotentialMessage(LOC('<LOC X02_T01_167_010>[{i QAI}]: Your experimental unit may actually be dangerous if completed. Ergo, I will destroy it now.'), 'X02_QAI_T01_04787', 'X02_VO')
            elseif oM28DamagerBrain[refiAssignedPersonality] == refiHex5 then
                AddPotentialMessage(LOC('<LOC X05_T01_125_010>[{i Hex5}]: Completing that experimental unit could interfere with the Master\'s plans. I will not allow that.'), 'X05_Hex5_T01_04794', 'X05_VO')
                AddPotentialMessage(LOC('<LOC X05_T01_126_010>[{i Hex5}]: The Master wills that your experimental will not come online.'), 'X05_Hex5_T01_04795', 'X05_VO')
                AddPotentialMessage(LOC('<LOC X05_T01_127_010>[{i Hex5}]: That experimental unit will not be completed!'), 'X05_Hex5_T01_04796', 'X05_VO')
            elseif oM28DamagerBrain[refiAssignedPersonality] == refiOumEoshi then
                AddPotentialMessage(LOC('<LOC X04_T01_001_010>[{i OumEoshi}]: Your experimental units are actually troublesome. It will be destroyed before it is completed.'), 'X04_Oum-Eoshi_T01_04788', 'X04_VO')
                AddPotentialMessage(LOC('<LOC X04_T01_002_010>[{i OumEoshi}]: I admire your tenacity, but I will not allow you to complete that experimental unit.'), 'X04_Oum-Eoshi_T01_04789', 'X04_VO')
                AddPotentialMessage(LOC('<LOC X04_T01_003_010>[{i OumEoshi}]: Your doom is without question, yet I cannot allow you to finish that experimental.'), 'X04_Oum-Eoshi_T01_04790', 'X04_VO')
            elseif oM28DamagerBrain[refiAssignedPersonality] == refiThelUuthow then
                AddPotentialMessage(LOC('<LOC X06_T01_001_010>[{i ThelUuthow}]: I will not allow your experimental to interfere with my mission!'), 'X06_Thel-Uuthow_T01_04797', 'X06_VO')
                AddPotentialMessage(LOC('<LOC X06_T01_002_010>[{i ThelUuthow}]: I will eliminate your experimental just as we will eventually eliminate your Coalition!'), 'X06_Thel-Uuthow_T01_04798', 'X06_VO')
                AddPotentialMessage(LOC('<LOC X06_T01_003_010>[{i ThelUuthow}]: Your experimental will never activate!'), 'X06_Thel-Uuthow_T01_04799', 'X06_VO')
            end

            if bDebugMessages == true then LOG(sFunctionRef..': Finished getting potential global and team messages, tsPotentialMessages='..repru(tsPotentialMessages)..'; tsPotentialTeamMessages='..repru(tsPotentialTeamMessages)..'; oBrainToSendMessage='..(oBrainToSendMessage.Nickname or 'nil')) end
            local bSendGlobal = true
            local bSendTeam = true
            if M28Utilities.IsTableEmpty(tsPotentialMessages) == false and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false then
                if math.random(1,2) == 1 then bSendGlobal = false else bSendTeam = false end
            end

            if bSendGlobal and M28Utilities.IsTableEmpty(tsPotentialMessages) == false and oBrainToSendMessage then
                local iRand = math.random(1, table.getn(tsPotentialMessages))
                --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
                SendMessage(oBrainToSendMessage, 'ExpDam'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialMessages[iRand], 0, 600, false, M28Map.bIsCampaignMap, tsCueByMessageIndex[iRand], tsBankBymessageIndex[iRand])
            end
            if bSendTeam and M28Utilities.IsTableEmpty(tsPotentialTeamMessages) == false and oBrainToSendMessage then
                local iRand = math.random(1, table.getn(tsPotentialTeamMessages))
                --SendMessage(aiBrain, sMessageType, sMessage,                          iOptionalDelayBeforeSending, iOptionalTimeBetweenMessageType, bOnlySendToTeam, bWaitUntilHaveACU, sOptionalSoundCue, sOptionalSoundBank)
                SendMessage(oBrainToSendMessage, oBrainToSendMessage.M28Team..'ExpDam'..(oBrainToSendMessage[refiAssignedPersonality] or 0), tsPotentialTeamMessages[iRand], 3, 600, true, M28Map.bIsCampaignMap, tsTeamCueIndex[iRand], tsTeamBankIndex[iRand])
            end
        end
    end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendUnitCapMessage(oBrainToSendMessage)
    local sFunctionRef = 'SendUnitCapMessage'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    local tsPotentialMessages = {
        'If only the unit cap was higher...',
        ':( I hate having to kill my own units due to the unit cap',
        'If I lose this I\'m blaming the unit cap!',
        'I hope the unit cap is hurting you as much as it\'s hurting me',
        'Can your CPU not handle a higher unit cap?'
    }
    local iRand = math.random(1, table.getn(tsPotentialMessages))
    if bDebugMessages == true then LOG(sFunctionRef..': iRand='..iRand..'; Will send message if it hasnt already been sent, message='..(tsPotentialMessages[iRand] or 'nil')..'; Time='..GetGameTimeSeconds()) end
    SendMessage(oBrainToSendMessage, 'UnitCap', tsPotentialMessages[iRand], 0, 1000000, false)
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendUnitReclaimedMessage(oEngineer, oReclaim)
    local sFunctionRef = 'SendUnitReclaimedMessage'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    local tsPotentialMessages = {
        'Great, now I have to deal with my so called teammates reclaiming my units, thanks a lot ' .. oEngineer:GetAIBrain().Nickname,
        'Hey ' .. oEngineer:GetAIBrain().Nickname .. ', quit reclaiming my units!',
        'You\’re reclaiming my unit ' .. oEngineer:GetAIBrain().Nickname .. '? You know I’m on the same team as you right?',
        'Just be warnted ' .. oEngineer:GetAIBrain().Nickname .. ', if you keep reclaiming my units, I have more apm for a reclaim war!',
        oEngineer:GetAIBrain().Nickname..' stop reclaiming my units, I don\'t like toxic teammates.',
        'No need to be greedy by reclaiming my units '..oEngineer:GetAIBrain().Nickname,
    }
    local sBlueprintDesc
    local oBP
    if oReclaim.GetBlueprint then oBP = oReclaim:GetBlueprint() sBlueprintDesc = LOC(oBP.Description) end
    if sBlueprintDesc then
        table.insert(tsPotentialMessages, 'Why are you reclaiming my '..sBlueprintDesc..' '..oEngineer:GetAIBrain().Nickname..'?')
        table.insert(tsPotentialMessages, 'Why would you reclaim my '..sBlueprintDesc..' '..oEngineer:GetAIBrain().Nickname..'? There I was thinking we could be friends.')
    end

    local iRand = math.random(1, table.getn(tsPotentialMessages))
    if bDebugMessages == true then LOG(sFunctionRef..': iRand='..iRand..'; Will send message if it hasnt already been sent, message='..(tsPotentialMessages[iRand] or 'nil')..'; Time='..GetGameTimeSeconds()) end
    SendMessage(oReclaim:GetAIBrain(), 'Ally reclaiming'..oEngineer:GetAIBrain():GetArmyIndex(), tsPotentialMessages[iRand], 0, 100000, false)
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

function SendSlowdownModeMessage(oBrainToSendMessage)
    local sFunctionRef = 'SendSlowdownModeMessage'
    local bDebugMessages = false if M28Profiler.bGlobalDebugOverride == true then   bDebugMessages = true end
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerStart)

    local tsPotentialMessages = {
        'Even my apm cant keep up with this many units!',
        'I have too many units to handle, I\'m going to have to take things at a slower pace',
        'I hope your cpu can keep up with this many units',
        'Engaging protocols for handling large unit numbers',
        'I\'m all worn out managing this many units, I think I\'ll take things a bit slower now',
    }
    local iRand = math.random(1, table.getn(tsPotentialMessages))
    if bDebugMessages == true then LOG(sFunctionRef..': iRand='..iRand..'; Will send message if it hasnt already been sent, message='..(tsPotentialMessages[iRand] or 'nil')..'; Time='..GetGameTimeSeconds()) end
    SendMessage(oBrainToSendMessage, 'Slowdown', tsPotentialMessages[iRand], 0, 1000000, false, true)
    M28Profiler.FunctionProfiler(sFunctionRef, M28Profiler.refProfilerEnd)
end

--List of potential voice messages
--intro:
    --By UEF
        --{LOC('<LOC X01_M01_030_010>[{i Fletcher}]: You just gated into a hell of a mess, Colonel, but I\'m glad you\'re here.', vid = 'X01_Fletcher_M01_03419.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_M01_03419', faction = 'UEF'},
        --{LOC('<LOC X01_M01_040_010>[{i Fletcher}]: A Cybran, huh? I thought you guys would be busy changing the water in Brackman\'s brain tank.', vid = 'X01_Fletcher_M01_02877.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_M01_02877', faction = 'UEF'},
        --{LOC('<LOC X01_M01_050_010>[{i Fletcher}]: I got my eyes on you, Aeon. I haven\'t forgotten what you people did during the War.', vid = 'X01_Fletcher_M01_02879.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_M01_02879', faction = 'UEF'},
        --{LOC('<LOC X01_T01_200_010>[{i Fletcher}]: It\'s time for this to get serious.', vid = 'X01_Fletcher_T01_04531.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_T01_04531', faction = 'UEF'},
        --{LOC('<LOC X01_T01_210_010>[{i Fletcher}]: You freaks are going to pay for what you did to Earth.', vid = 'X01_Fletcher_T01_04532.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_T01_04532', faction = 'UEF'},
        --{LOC('<LOC X06_M02_011_010>[{i Fletcher}]: I spent a lot of time thinking about this. There\'s only one possible outcome. One way for this to end.', vid = 'X06_Fletcher_M02_04482.sfd', bank = 'X06_VO', cue = 'X06_Fletcher_M02_04482', faction = 'UEF'},
        --{LOC('<LOC X06_T01_680_010>[{i Fletcher}]: I thought I could trust you! You\'re a traitor.', vid = 'X06_Fletcher_T01_03029.sfd', bank = 'X06_VO', cue = 'X06_Fletcher_T01_03029', faction = 'UEF'},
        --{LOC('<LOC X06_T01_830_010>[{i Fletcher}]: This war is your fault! And now you will pay.', vid = 'X06_Fletcher_T01_03044.sfd', bank = 'X06_VO', cue = 'X06_Fletcher_T01_03044', faction = 'UEF'},
        --{LOC('<LOC X06_T01_840_010>[{i Fletcher}]: You and your kind are responsible for this war.', vid = 'X06_Fletcher_T01_03045.sfd', bank = 'X06_VO', cue = 'X06_Fletcher_T01_03045', faction = 'UEF'},

    --By Aeon
        --{LOC('<LOC X01_M02_013_010>[{i Gari}]: I shall cleanse everyone on this planet! You are fools to stand against our might!', vid = 'X01_Gari_M02_02896.sfd', bank = 'X01_VO', cue = 'X01_Gari_M02_02896', faction = 'Aeon'},
        --{LOC('<LOC X01_T01_120_010>[{i Gari}]: The UEF is finished. There will be no escaping us this time.', vid = 'X01_Gari_T01_04522.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04522', faction = 'Aeon'},
        --{LOC('<LOC X02_T01_100_010>[{i Celene}]: The UEF will fall. You have no future.', vid = 'X02_Celene_T01_04546.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04546', faction = 'Aeon'},
        --{LOC('<LOC X01_T01_150_010>[{i Gari}]: You are an abomination. I will take great pleasure in exterminating you.', vid = 'X01_Gari_T01_04525.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04525', faction = 'Aeon'},
        --{LOC('<LOC X02_M01_050_010>[{i Celene}]: You do not comprehend the power that is arrayed against you.', vid = 'X02_Celene_M01_03130.sfd', bank = 'X02_VO', cue = 'X02_Celene_M01_03130', faction = 'Aeon'},
        --{LOC('<LOC X02_M01_060_010>[{i Celene}]: Your mere presence here desecrates this planet. You are an abomination.', vid = 'X02_Celene_M01_03131.sfd', bank = 'X02_VO', cue = 'X02_Celene_M01_03131', faction = 'Aeon'},
        --{LOC('<LOC X02_M02_060_020>[{i Celene}]: There is nothing here for you but death.', vid = 'X02_Celene_M02_04277.sfd', bank = 'X02_VO', cue = 'X02_Celene_M02_04277', faction = 'Aeon'},
        --{LOC('<LOC X02_T01_110_010>[{i Celene}]: There is nothing I enjoy more than hunting Cybrans.', vid = 'X02_Celene_T01_04547.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04547', faction = 'Aeon'},
        --{LOC('<LOC X02_T01_120_010>[{i Celene}]: Thousands of your brothers and sisters have fallen by my hand, and you will soon share their fate.', vid = 'X02_Celene_T01_04548.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04548', faction = 'Aeon'},
        --{LOC('<LOC X02_T01_150_010>[{i Celene}]: I will not be defeated by the likes of you!', vid = 'X02_Celene_T01_04551.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04551', faction = 'Aeon'},
        --{LOC('<LOC X03_M01_032_010>[{i Rhiza}]: Prepare your forces. Rhiza out.', vid = 'X03_Rhiza_M01_04864.sfd', bank = 'X03_VO', cue = 'X03_Rhiza_M01_04864', faction = 'Aeon'},
        --{LOC('<LOC X03_M01_042_010>[{i Rhiza}]: Prepare your forces. Rhiza out.', vid = 'X03_Rhiza_M01_04866.sfd', bank = 'X03_VO', cue = 'X03_Rhiza_M01_04866', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_530_010>[{i Vendetta}]: Your reliance on technology shall be your undoing.', vid = 'X06_Vedetta_T01_03015.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03015', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_940_010>[{i Rhiza}]: There is nothing here save destruction for you, Seraphim!', vid = 'X06_Rhiza_T01_03054.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_03054', faction = 'Aeon'},

    --By Cybran
        --{LOC('<LOC X02_T01_250_010>[{i QAI}]: All Symbionts will soon call me Master.', vid = 'X02_QAI_T01_04561.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04561', faction = 'Cybran'},
        --{LOC('<LOC X05_M02_010_010>[{i Hex5}]: You are incapable of comprehending our might. The Master is endless, his wisdom infinite. You will never defeat us.', vid = 'X05_Hex5_M02_03825.sfd', bank = 'X05_VO', cue = 'X05_Hex5_M02_03825', faction = 'Cybran'},
        --{LOC('<LOC X05_M02_270_020>[{i Hex5}]: You will not defeat us. The Master is eternal, his wisdom infinite.', vid = 'X05_Hex5_M02_04949.sfd', bank = 'X05_VO', cue = 'X05_Hex5_M02_04949', faction = 'Cybran'},
        --{LOC('<LOC X05_T01_070_010>[{i QAI}]: The UEF has lost 90% of its former territories. You are doomed.', vid = 'X05_QAI_T01_04421.sfd', bank = 'X05_VO', cue = 'X05_QAI_T01_04421', faction = 'Cybran'},
        --{LOC('<LOC X05_T01_160_010>[{i Hex5}]: You do not stand a chance against the Master. It will destroy you.', vid = 'X05_Hex5_T01_04430.sfd', bank = 'X05_VO', cue = 'X05_Hex5_T01_04430', faction = 'Cybran'},

    --By seraphim
        --{LOC('<LOC X04_T01_010_010>[{i OumEoshi}]: Your galaxy will soon be ours.', vid = 'X04_Oum-Eoshi_T01_04383.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04383', faction = 'Seraphim'},
        --{LOC('<LOC X04_T01_020_010>[{i OumEoshi}]: Only one species can attain perfection.', vid = 'X04_Oum-Eoshi_T01_04384.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04384', faction = 'Seraphim'},
        --{LOC('<LOC X06_M03_200_010>[{i SethIavow}]: You have no hope of standing against us: The Seraphim are eternal. Destroy the human.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'X06_VO', cue = 'X06_Seth-iavow_M03_03997', faction = 'Seraphim'},
        --{LOC('<LOC X06_T01_200_010>[{i ThelUuthow}]: Your Earth fell easily. You will prove no different.', vid = 'X06_Thel-Uuthow_T01_02972.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02972', faction = 'Seraphim'},
        --{LOC('<LOC X06_T01_210_010>[{i ThelUuthow}]: You Cybrans die as easily as any other human.', vid = 'X06_Thel-Uuthow_T01_02973.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02973', faction = 'Seraphim'},
        --{LOC('<LOC X06_T01_220_010>[{i ThelUuthow}]: Your faith in technology will be your undoing.', vid = 'X06_Thel-Uuthow_T01_02974.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02974', faction = 'Seraphim'},

--Need help/close to death/lost significant unit
    --UEF
        --{LOC('<LOC X01_M02_037_010>[{i Graham}]: We\'re getting hit from all directions! Oh god, please help us...', vid = 'X01_Graham_M02_04244.sfd', bank = 'X01_VO', cue = 'X01_Graham_M02_04244', faction = 'UEF'},
        --{LOC('<LOC X01_M03_100_010>[{i Fletcher}]: Where are my reinforcements?', vid = 'X01_Fletcher_M03_03695.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_M03_03695', faction = 'UEF'},
        --{LOC('<LOC X01_T01_230_010>[{i Fletcher}]: I\'m in a lot of trouble!', vid = 'X01_Fletcher_T01_04534.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_T01_04534', faction = 'UEF'},
        --{LOC('<LOC X05_M02_300_010>[{i Fletcher}]: I\'m getting hit pretty hard! Get over here and help me! Fletcher out.', vid = 'X05_Fletcher_M02_05108.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_05108', faction = 'UEF'},
        --{text = '<LOC X01_T01_220_010>[{i Fletcher}]: Commander, I could use a hand over here. I\'m getting hit pretty hard.', vid = 'X01_Fletcher_T01_04533.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_T01_04533', faction = 'UEF'},
        --{LOC('<LOC X05_M02_310_010>[{i Fletcher}]: Colonel, I\'d really appreciate it if you could help me out. The enemy is pounding me pretty hard. Fletcher out.', vid = 'X05_Fletcher_M02_05109.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_05109', faction = 'UEF'},
        --{LOC('<LOC X05_M02_320_010>[{i Fletcher}]: Get it in gear, Cybran! The enemy is kicking the tar out of me and I need your help. Fletcher out.', vid = 'X05_Fletcher_M02_05110.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_05110', faction = 'UEF'},
        --{LOC('<LOC X05_M02_330_010>[{i Fletcher}]: My base is being destroyed. I need help! I can\'t hold them off!', vid = 'X05_Fletcher_M02_05111.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_05111', faction = 'UEF'},
        --{LOC('<LOC X05_M02_340_010>[{i Fletcher}]: Enemy units are hitting my base pretty hard. I need you to reinforce my position. Fletcher out.', vid = 'X05_Fletcher_M02_05112.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_05112', faction = 'UEF'},
        --{LOC('<LOC X05_M02_170_010>[{i Amalia}]: My ACU is seriously damaged, Commander!', vid = 'X05_Amalia_M02_03850.sfd', bank = 'X05_VO', cue = 'X05_Amalia_M02_03850', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_690_010>[{i Fletcher}]: You\'re a coward.', vid = 'X06_Fletcher_T01_03030.sfd', bank = 'X06_VO', cue = 'X06_Fletcher_T01_03030', faction = 'UEF'},

    --Aeon
        --{LOC('<LOC X02_M02_176_010>[{i Celene}]: I can still make things right.', vid = 'X02_Celene_M02_04287.sfd', bank = 'X02_VO', cue = 'X02_Celene_M02_04287', faction = 'Aeon'},
        --{LOC('<LOC X06_M03_060_020>[{i Kael}]: Do something!', vid = 'X06_Kael_M03_04499.sfd', bank = 'X06_VO', cue = 'X06_Kael_M03_04499', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_570_010>[{i Vendetta}]: I am not defeated yet!', vid = 'X06_Vedetta_T01_03019.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03019', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_883_010>[{i Rhiza}]: It does not matter, I will continue to attack!', vid = 'X06_Rhiza_T01_04506.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_04506', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_885_010>[{i Rhiza}]: Such a thing will not stop me!', vid = 'X06_Rhiza_T01_04508.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_04508', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_886_010>[{i Rhiza}]: I will rebuild twice as strong!', vid = 'X06_Rhiza_T01_04509.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_04509', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_887_010>[{i Rhiza}]: You mistake me if you think I will be cowed!', vid = 'X06_Rhiza_T01_04510.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_04510', faction = 'Aeon'},
        --AddPotentialMessage(LOC('<LOC XGG_MP1_210_010>[{i Rhiza}]: I will hunt you to the ends of the galaxy!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04586'},
        --AddPotentialMessage(LOC('<LOC X06_T01_885_010>[{i Rhiza}]: Such a thing will not stop me!', bank = 'X06_VO', cue = 'X06_Rhiza_T01_04508'},
        --AddPotentialMessage(LOC('<LOC X06_T01_920_010>[{i Rhiza}]: Soon you will know my wrath!', bank = 'X06_VO', cue = 'X06_Rhiza_T01_03052'},
        --AddPotentialMessage(LOC('<LOC XGG_MP1_250_010>[{i Kael}]: The Order will not be defeated!', bank = 'XGG', cue = 'XGG_Kael_MP1_04590'},


    --Cybran
        --{LOC('<LOC X05_M03_016_010>[{i Brackman}]: I am under attack, my child. Under attack. Please defend me.', vid = 'X05_Brackman_M03_04953.sfd', bank = 'X05_VO', cue = 'X05_Brackman_M03_04953', faction = 'Cybran'},
        --{LOC('<LOC X05_M03_070_010>[{i Brackman}]: Hull integrity is dropping. Please help me, Commander.', vid = 'X05_Brackman_M03_03864.sfd', bank = 'X05_VO', cue = 'X05_Brackman_M03_03864', faction = 'Cybran'},
        --AddPotentialMessage(LOC('<LOC XGG_MP1_440_010>[{i Brackman}]: Are you sure you want to do that?', bank = 'XGG', cue = 'XGG_Brackman_MP1_04609'},
        --{LOC('<LOC X05_T01_140_010>[{i Hex5}]: The Master will punish you for that.', vid = 'X05_Hex5_T01_04428.sfd', bank = 'X05_VO', cue = 'X05_Hex5_T01_04428', faction = 'Cybran'},
        --{LOC('<LOC X05_T01_220_010>[{i Hex5}]: Even if you destroy me, the Master lives on.', vid = 'X05_Hex5_T01_04436.sfd', bank = 'X05_VO', cue = 'X05_Hex5_T01_04436', faction = 'Cybran'},
        --{text = '<LOC X05_M03_325_040>[{i QAI}]: Your efforts will be for -- what are you doing? That is not possible.', vid = 'X05_QAI_M03_04450.sfd', bank = 'X05_VO', cue = 'X05_QAI_M03_04450', faction = 'Cybran'},
        --{text = '<LOC X05_T01_050_010>[{i QAI}]: That building means nothing to me.', vid = 'X05_QAI_T01_04419.sfd', bank = 'X05_VO', cue = 'X05_QAI_T01_04419', faction = 'Cybran'},
        --{text = '<LOC X05_T01_040_010>[{i QAI}]: Those bases are of no consequence.', vid = 'X05_QAI_T01_04418.sfd', bank = 'X05_VO', cue = 'X05_QAI_T01_04418', faction = 'Cybran'},
        --AddPotentialMessage(LOC('<LOC XGG_MP1_520_010>[{i QAI}]: Your strategies are without merit.', bank = 'XGG', cue = 'XGG_QAI_MP1_04617'},

    --Seraphim
        --{LOC('<LOC X06_T01_010_010>[{i ThelUuthow}]: You have accomplished nothing. You will never defeat us.', vid = 'X06_Thel-Uuthow_T01_04462.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_04462', faction = 'Seraphim'},
        --{LOC('<LOC X06_T01_250_010>[{i ThelUuthow}]: Perhaps you are a greater threat than I thought?', vid = 'X06_Thel-Uuthow_T01_02977.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02977', faction = 'Seraphim'},

--On death
    --By UEF
        --On death: {LOC('<LOC X01_T01_240_010>[{i Fletcher}]: You\'ve got to be kidding!', vid = 'X01_Fletcher_T01_04535.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_T01_04535', faction = 'UEF'},

    --By Aeon
        --{LOC('<LOC X02_D01_020_010>[{i Celene}]: Wait! I\'m not ready to die!', vid = 'X02_Celene_D01_03178.sfd', bank = 'X02_VO', cue = 'X02_Celene_D01_03178', faction = 'Aeon'},
        --{LOC('<LOC X03_M02_115_010>[{i Rhiza}]: NOOOOOOOOOOOOO!', vid = 'X03_Rhiza_M02_03319.sfd', bank = 'X03_VO', cue = 'X03_Rhiza_M02_03319', faction = 'Aeon'},
        --{LOC('<LOC X06_M02_260_010>[{i Rhiza}]: Nooooooo!', vid = 'X06_Rhiza_M02_05599.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_M02_05599', faction = 'Aeon'},
        --{LOC('<LOC X06_M02_270_010>[{i Rhiza}]: [High Pitched Death Scream]', vid = 'X06_Rhiza_M02_05125.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_M02_05125', faction = 'Aeon'},
        --{LOC('<LOC X03_M02_170_010>[{i Princess}]: They\'re ... they\'re dead ... I shall forever mourn their loss.', vid = 'X03_Princess_M02_03334.sfd', bank = 'X03_VO', cue = 'X03_Princess_M02_03334', faction = 'Aeon'},
        --{LOC('<LOC X03_M03_235_010>[{i Rhiza}]: I\'m taking too much damage -- I must recall. Commander, continue the fight without me!', vid = 'X03_Rhiza_M03_04708.sfd', bank = 'X03_VO', cue = 'X03_Rhiza_M03_04708', faction = 'Aeon'},
        --{LOC('<LOC X05_M02_190_010>[{i Amalia}]: Remember that I fought honorably!', vid = 'X05_Amalia_M02_03852.sfd', bank = 'X05_VO', cue = 'X05_Amalia_M02_03852', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_580_010>[{i Vendetta}]: Aaaaaaaaah!', vid = 'X06_Vedetta_T01_03020.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03020', faction = 'Aeon'},

    --By seraphim
        --{LOC('<LOC X03_T01_490_010>[{i ZanAishahesh}]: [Language Not Recognized]', vid = 'X03_Zan-Aishahesh_T01_04351.sfd', bank = 'X03_VO', cue = 'X03_Zan-Aishahesh_T01_04351', faction = 'Seraphim'},
        --{LOC('<LOC X06_T01_270_010>[{i ThelUuthow}]: I serve to the end!', vid = 'X06_Thel-Uuthow_T01_02979.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02979', faction = 'Seraphim'},

    --By Cybran
        --{LOC('<LOC X04_M03_016_010>[{i Dostya}]: Getting hit from all sides ... too many of them ... too many ...', vid = 'X04_Dostya_M03_03755.sfd', bank = 'X04_VO', cue = 'X04_Dostya_M03_03755', faction = 'Cybran'},
        --{LOC('<LOC X05_DB01_030_010>[{i HQ}]: The operation has ended in failure. All is lost.', vid = 'X05_HQ_DB01_04956.sfd', bank = 'Briefings', cue = 'X05_HQ_DB01_04956', faction = 'NONE'},
        --{LOC('<LOC X05_M02_200_009>[{i Hex5}]: Wait! Master!', vid = 'X05_Hex5_T01_04437.sfd', bank = 'X05_VO', cue = 'X05_Hex5_T01_04437', faction = 'Cybran'},
        --AddPotentialMessage(LOC('<LOC XGG_MP1_630_010>[{i Hex5}]: Goodbye!', bank = 'XGG', cue = 'XGG_Hex5_MP1_04628'},
        --{LOC('<LOC X05_M03_135_010>[{i Brackman}]: At last I shall have peace.', vid = 'X05_Brackman_M03_04444.sfd', bank = 'X05_VO', cue = 'X05_Brackman_M03_04444', faction = 'Cybran'},
        --{LOC('<LOC X05_M03_327_010>[{i Brackman}]: Goodbye.', vid = 'X05_Brackman_M03_04452.sfd', bank = 'X05_VO', cue = 'X05_Brackman_M03_04452', faction = 'Cybran'},

    --All factions
        --{LOC('<LOC X02_D01_030_010>[{i QAI}]: This is just a shell.', vid = 'X02_QAI_D01_03179.sfd', bank = 'X02_VO', cue = 'X02_QAI_D01_03179', faction = 'Cybran'},
        --{LOC('<LOC X02_T01_290_010>[{i QAI}]: This is just a shell...', vid = 'X02_QAI_T01_04565.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04565', faction = 'Cybran'},
        --{LOC('<LOC X06_M01_130_010>[{i HQ}]: Looks like the Commander just ate it. Poor bastard.', vid = 'X06_HQ_M01_04960.sfd', bank = 'X06_VO', cue = 'X06_HQ_M01_04960', faction = 'NONE'},
        --{LOC('<LOC X06_M01_140_010>[{i HQ}]: Commander, you read me? Commander? Ah hell...', vid = 'X06_HQ_M01_04961.sfd', bank = 'X06_VO', cue = 'X06_HQ_M01_04961', faction = 'NONE'},

--taunt or enemy exp destroyed
    --By UEF
        --{LOC('<LOC X01_M03_170_010>[{i Fletcher}]: That\'s what I love to see. Burn, baby, burn!', vid = 'X01_Fletcher_M03_03701.sfd', bank = 'X01_VO', cue = 'X01_Fletcher_M03_03701', faction = 'UEF'},
        --{LOC('<LOC X05_M02_120_010>[{i Fletcher}]: We got him on the ropes!', vid = 'X05_Fletcher_M02_03845.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_03845', faction = 'UEF'},
        --{LOC('<LOC X05_M02_140_010>[{i Fletcher}]: He\'s got almost nothing left! Take him out!', vid = 'X05_Fletcher_M02_03847.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_03847', faction = 'UEF'},
        --{LOC('<LOC X06_T01_860_010>[{i Fletcher}]: There is no stopping me!', vid = 'X06_Fletcher_T01_03047.sfd', bank = 'X06_VO', cue = 'X06_Fletcher_T01_03047', faction = 'UEF'},
    --By Aeon
        --{LOC('<LOC X01_M02_161_010>[{i Gari}]: Ha-ha-ha!', vid = 'X01_Gari_M02_04245.sfd', bank = 'X01_VO', cue = 'X01_Gari_M02_04245', faction = 'Aeon'},
        --{LOC('<LOC X03_M02_115_020>[{i Kael}]: Ha-ha-ha!', vid = 'X03_Kael_M02_04368.sfd', bank = 'X03_VO', cue = 'X03_Kael_M02_04368', faction = 'Aeon'},
        --{LOC('<LOC X01_M02_250_010>[{i Gari}]: At long last, the end of the UEF is within my sights. This day has been a long time coming.', vid = 'X01_Gari_M02_03664.sfd', bank = 'X01_VO', cue = 'X01_Gari_M02_03664', faction = 'Aeon'},
        --{LOC('<LOC X01_M02_270_010>[{i Gari}]: You have abandoned your people, your heritage and your gods. For that, you will be destroyed.', vid = 'X01_Gari_M02_03668.sfd', bank = 'X01_VO', cue = 'X01_Gari_M02_03668', faction = 'Aeon'},
        --{LOC('<LOC X01_M02_270_020>[{i Rhiza}]: You have perverted The Way with your fanaticism. For that, you will be destroyed.', vid = 'X01_Rhiza_M02_03669.sfd', bank = 'X01_VO', cue = 'X01_Rhiza_M02_03669', faction = 'Aeon'},
        --{LOC('<LOC X01_T01_040_010>[{i Gari}]: Your tenacity is admirable, but the outcome of this battle was determined long ago.', vid = 'X01_Gari_T01_04514.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04514', faction = 'Aeon'},
        --{LOC('<LOC X01_T01_060_010>[{i Gari}]: Now you will taste the fury of the Order of the Illuminate.', vid = 'X01_Gari_T01_04516.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04516', faction = 'Aeon'},
        --{LOC('<LOC X01_T01_070_010>[{i Gari}]: You have nowhere to hide, nowhere to run.', vid = 'X01_Gari_T01_04517.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04517', faction = 'Aeon'},
        --{LOC('<LOC X01_T01_100_010>[{i Gari}]: Not even your most powerful weapon can stand before me.', vid = 'X01_Gari_T01_04520.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04520', faction = 'Aeon'},
        --{LOC('<LOC X01_T01_110_010>[{i Gari}]: Beg for mercy and perhaps I shall grant you an honorable death.', vid = 'X01_Gari_T01_04521.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04521', faction = 'Aeon'},
        --{LOC('<LOC X02_T01_001_010>[{i Celene}]: No, you may not have that experimental.', vid = 'X02_Celene_T01_04782.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04782', faction = 'Aeon'},
        --{LOC('<LOC X02_T01_090_010>[{i Celene}]: Nothing can save you now!', vid = 'X02_Celene_T01_04544.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04544', faction = 'Aeon'},
        --{LOC('<LOC X02_T01_095_010>[{i Celene}]: Beg me for mercy! Beg!', vid = 'X02_Celene_T01_04545.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04545', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_500_010>[{i Vendetta}]: Why are you still fighting us?', vid = 'X06_Vedetta_T01_03012.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03012', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_520_010>[{i Vendetta}]: You are an abomination.', vid = 'X06_Vedetta_T01_03014.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03014', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_540_010>[{i Vendetta}]: You will die by my hand, traitor.', vid = 'X06_Vedetta_T01_03016.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03016', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_900_010>[{i Rhiza}]: Glory to the Princess!', vid = 'X06_Rhiza_T01_03050.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_03050', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_910_010>[{i Rhiza}]: It is unwise to ignore me.', vid = 'X06_Rhiza_T01_03051.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_03051', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_920_010>[{i Rhiza}]: Soon you will know my wrath!', vid = 'X06_Rhiza_T01_03052.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_03052', faction = 'Aeon'},
        --{LOC('<LOC X06_T01_930_010>[{i Rhiza}]: The will of the Princess will not be denied!', vid = 'X06_Rhiza_T01_03053.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_03053', faction = 'Aeon'},

    --By Cybran
        --{LOC('<LOC X05_T01_150_010>[{i Hex5}]: You are weak and soft, frightened by what you don\'t understand.', vid = 'X05_Hex5_T01_04429.sfd', bank = 'X05_VO', cue = 'X05_Hex5_T01_04429', faction = 'Cybran'},
        --{text = '<LOC X02_T01_210_010>[{i QAI}]: My influence is much more vast than you can imagine.', vid = 'X02_QAI_T01_04557.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04557', faction = 'Cybran'},
        --{text = '<LOC X02_T01_220_010>[{i QAI}]: All calculations indicate that your demise is near.', vid = 'X02_QAI_T01_04558.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04558', faction = 'Cybran'},
        --{text = '<LOC X02_T01_180_010>[{i QAI}]: Humans are such curious creatures. Even in the face of insurmountable odds, you continue to resist.', vid = 'X02_QAI_T01_04554.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04554', faction = 'Cybran'},

--By Seraphim
--{LOC('<LOC X01_T01_250_010>[{i ShunUllevash}]: (Laughter)', vid = 'X01_Seraphim_T01_05123.sfd', bank = 'X01_VO', cue = 'X01_seraphim_T01_05123', faction = 'Seraphim'},
--{LOC('<LOC X04_M03_055_010>[{i OumEoshi}]: Only now do you realize the futility of your situation. We know what you know, we see what you see. There is no stopping us.', vid = 'X04_Oum-Eoshi_M03_04402.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_M03_04402', faction = 'Seraphim'},
--{LOC('<LOC X04_M03_057_010>[{i OumEoshi}]: Humanity\'s time is at an end. You will be rendered extinct.', vid = 'X04_Oum-Eoshi_M03_04404.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_M03_04404', faction = 'Seraphim'},
--{LOC('<LOC X04_M03_090_010>[{i OumEoshi}]: You will share the fate of Riley and Clarke. Goodbye, Colonel.', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_M03_03767', faction = 'Seraphim'},
--{LOC('<LOC X04_T01_030_010>[{i OumEoshi}]: Do not fret. Dying by my hand is the supreme honor.', vid = 'X04_Oum-Eoshi_T01_04385.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04385', faction = 'Seraphim'},
--{LOC('<LOC X06_T01_190_010>[{i ThelUuthow}]: Your kind began this war. We are merely finishing it.', vid = 'X06_Thel-Uuthow_T01_02971.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02971', faction = 'Seraphim'},
--{LOC('<LOC X06_T01_240_010>[{i ThelUuthow}]: Bow down before our might, and we may spare you.', vid = 'X06_Thel-Uuthow_T01_02976.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02976', faction = 'Seraphim'},

--Victory (some of above would also work)
--{LOC('<LOC X03_M02_082_010>[{i HQ}]: Holy ... I can\'t believe it. You actually destroyed them.', vid = 'X03_HQ_M02_04843.sfd', bank = 'X03_VO', cue = 'X03_HQ_M02_04843', faction = 'NONE'},
--{LOC('<LOC X06_T01_950_010>[{i Rhiza}]: Victory to the Coalition!', vid = 'X06_Rhiza_T01_03055.sfd', bank = 'X06_VO', cue = 'X06_Rhiza_T01_03055', faction = 'Aeon'},

--special:
-- e.g. beat 2.0 AIx cybran with no non ai mods:
--{LOC('<LOC X04_M03_260_010>[{i Brackman}]: Hi, this is Jamieson Price, the voice of Dr. Brackman. Your skills are so impressive that you knocked me out of character, and now I have to re-record my VO! Gimme a moment while I dial it back in ... oh yes ... there we go, much better. Much better.', vid = 'X04_Brackman_M03_05106.sfd', bank = 'X04_VO', cue = 'X04_Brackman_M03_05106', faction = 'Cybran'},
--Kill scathis with M28 as UEF:
--{LOC('<LOC X05_M02_050_010>[{i Fletcher}]: Scratch one Scathis. Fletcher out.', vid = 'X05_Fletcher_M02_03831.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_03831', faction = 'UEF'},
--Enemy soulripper damages M28 fatboy:
--{LOC('<LOC X05_M02_240_010>[{i Fletcher}]: Soul Rippers are tearing up my Fatboy! I need air cover, now!', vid = 'X05_Fletcher_M02_04945.sfd', bank = 'X05_VO', cue = 'X05_Fletcher_M02_04945', faction = 'UEF'},
--Intercept Nuke with Aeon SMD:
--{LOC('<LOC X06_T01_560_010>[{i Vendetta}]: Nice try.', vid = 'X06_Vedetta_T01_03018.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03018', faction = 'Aeon'},

--Construct a land experimental, and have more land experimentals than enemy team (send on a 30s delay)
    --{text = '<LOC X02_M02_160_010>[{i QAI}]: It is time to end this. My primary attack force is moving into position.', vid = 'X02_QAI_M02_04278.sfd', bank = 'X02_VO', cue = 'X02_QAI_M02_04278', faction = 'Cybran'},

--Taunts (some of which may already be above):
--[[
{text = '<LOC XGG_MP1_010_010>[{i Hall}]: You will not stop the UEF!', bank = 'XGG', cue = 'XGG_Hall__04566'},
{text = '<LOC XGG_MP1_020_010>[{i Hall}]: Humanity will be saved!', bank = 'XGG', cue = 'XGG_Hall__04567'},
{text = '<LOC XGG_MP1_030_010>[{i Hall}]: You\'re not going to stop me.', bank = 'XGG', cue = 'XGG_Hall__04568'},
{text = '<LOC XGG_MP1_040_010>[{i Hall}]: The gloves are coming off.', bank = 'XGG', cue = 'XGG_Hall__04569'},
{text = '<LOC XGG_MP1_050_010>[{i Hall}]: You\'re in my way.', bank = 'XGG', cue = 'XGG_Hall__04570'},
{text = '<LOC XGG_MP1_060_010>[{i Hall}]: Get out of here while you still can.', bank = 'XGG', cue = 'XGG_Hall__04571'},
{text = '<LOC XGG_MP1_070_010>[{i Hall}]: I guess it\'s time to end this farce.', bank = 'XGG', cue = 'XGG_Hall__04572'},
{text = '<LOC XGG_MP1_080_010>[{i Hall}]: You\'ve got no chance against me!', bank = 'XGG', cue = 'XGG_Hall__04573'},
{text = '<LOC XGG_MP1_090_010>[{i Fletcher}]: This ain\'t gonna be much of a fight.', bank = 'XGG', cue = 'XGG_Fletcher_MP1_04574'},
{text = '<LOC XGG_MP1_100_010>[{i Fletcher}]: You\'re not puttin\' up much of a fight.', bank = 'XGG', cue = 'XGG_Fletcher_MP1_04575'},
{text = '<LOC XGG_MP1_110_010>[{i Fletcher}]: Do you have any idea of what you\'re doing?', bank = 'XGG', cue = 'XGG_Fletcher_MP1_04576'},
{text = '<LOC XGG_MP1_120_010>[{i Fletcher}]: Not much on tactics, are ya?', bank = 'XGG', cue = 'XGG_Fletcher_MP1_04577'},
{text = '<LOC XGG_MP1_130_010>[{i Fletcher}]: If you run now, I\'ll let ya go.', bank = 'XGG', cue = 'XGG_Fletcher_MP1_04578'},
{text = '<LOC XGG_MP1_140_010>[{i Fletcher}]: You ain\'t too good at this, are you?', bank = 'XGG', cue = 'XGG_Fletcher_MP1_04579'},
{text = '<LOC XGG_MP1_150_010>[{i Fletcher}]: Guess I got time to smack you around.', bank = 'XGG', cue = 'XGG_Fletcher_MP1_04580'},
{text = '<LOC XGG_MP1_160_010>[{i Fletcher}]: I feel a bit bad, beatin\' up on you like this.', bank = 'XGG', cue = 'XGG_Fletcher_MP1_04581'},
{text = '<LOC X01_M01_040_010>[{i Fletcher}]: A Cybran, huh? I thought you guys would be busy changing the water in Brackman\'s brain tank.', bank = 'X01_VO', cue = 'X01_Fletcher_M01_02877'},
{text = '<LOC X01_M03_170_010>[{i Fletcher}]: That\'s what I love to see. Burn, baby, burn!', bank = 'X01_VO', cue = 'X01_Fletcher_M03_03701'},
{text = '<LOC X05_M02_270_030>[{i Fletcher}]: Yeah, yeah. Give it a rest already.', bank = 'X05_VO', cue = 'X05_Fletcher_M02_04950'},
{text = '<LOC X06_T01_587_010>[{i Fletcher}]: You can\'t stop me with that experimental! I\'ll destroy it first!', bank = 'X06_VO', cue = 'X06_Fletcher_T01_04805'},
{text = '<LOC X06_T01_690_010>[{i Fletcher}]: You\'re a coward.', bank = 'X06_VO', cue = 'X06_Fletcher_T01_03030'},
{text = '<LOC X06_T01_860_010>[{i Fletcher}]: There is no stopping me!', bank = 'X06_VO', cue = 'X06_Fletcher_T01_03047'},
{text = '<LOC XGG_MP1_170_010>[{i Rhiza}]: Glory to the Princess!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04582'},
{text = '<LOC XGG_MP1_180_010>[{i Rhiza}]: Glorious!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04583'},
{text = '<LOC XGG_MP1_190_010>[{i Rhiza}]: I will not be stopped!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04584'},
{text = '<LOC XGG_MP1_200_010>[{i Rhiza}]: All enemies of the Princess will be destroyed!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04585'},
{text = '<LOC XGG_MP1_210_010>[{i Rhiza}]: I will hunt you to the ends of the galaxy!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04586'},
{text = '<LOC XGG_MP1_220_010>[{i Rhiza}]: For the Aeon!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04587'},
{text = '<LOC XGG_MP1_230_010>[{i Rhiza}]: Flee while you can!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04588'},
{text = '<LOC XGG_MP1_240_010>[{i Rhiza}]: Behold the power of the Illuminate!', bank = 'XGG', cue = 'XGG_Rhiza_MP1_04589'},
{text = '<LOC X06_T01_885_010>[{i Rhiza}]: Such a thing will not stop me!', bank = 'X06_VO', cue = 'X06_Rhiza_T01_04508'},
{text = '<LOC X06_T01_887_010>[{i Rhiza}]: You mistake me if you think I will be cowed!', bank = 'X06_VO', cue = 'X06_Rhiza_T01_04510'},
{text = '<LOC X06_T01_920_010>[{i Rhiza}]: Soon you will know my wrath!', bank = 'X06_VO', cue = 'X06_Rhiza_T01_03052'},
{text = '<LOC XGG_MP1_250_010>[{i Kael}]: The Order will not be defeated!', bank = 'XGG', cue = 'XGG_Kael_MP1_04590'},
{text = '<LOC XGG_MP1_260_010>[{i Kael}]: If you grovel, I may let you live.', bank = 'XGG', cue = 'XGG_Kael_MP1_04591'},
{text = '<LOC XGG_MP1_270_010>[{i Kael}]: There will be nothing left of you when I am done.', bank = 'XGG', cue = 'XGG_Kael_MP1_04592'},
{text = '<LOC XGG_MP1_280_010>[{i Kael}]: You\'re beginning to bore me.', bank = 'XGG', cue = 'XGG_Kael_MP1_04593'},
{text = '<LOC XGG_MP1_290_010>[{i Kael}]: My time is wasted on you.', bank = 'XGG', cue = 'XGG_Kael_MP1_04594'},
{text = '<LOC XGG_MP1_300_010>[{i Kael}]: Run while you can.', bank = 'XGG', cue = 'XGG_Kael_MP1_04595'},
{text = '<LOC XGG_MP1_310_010>[{i Kael}]: It must be frustrating to be so completely overmatched.', bank = 'XGG', cue = 'XGG_Kael_MP1_04596'},
{text = '<LOC XGG_MP1_320_010>[{i Kael}]: Beg for mercy.', bank = 'XGG', cue = 'XGG_Kael_MP1_04597'},
{text = '<LOC X02_M02_060_020>[{i Celene}]: There is nothing here for you but death.', bank = 'X02_VO', cue = 'X02_Celene_M02_04277'},
{text = '<LOC X02_T01_070_010>[{i Celene}]: Every day you grow weaker. Your end is drawing near.', bank = 'X02_VO', cue = 'X02_Celene_T01_04542'},
{text = '<LOC X02_T01_090_010>[{i Celene}]: Nothing can save you now!', bank = 'X02_VO', cue = 'X02_Celene_T01_04544'},
{text = '<LOC X02_T01_110_010>[{i Celene}]: There is nothing I enjoy more than hunting Cybrans.', bank = 'X02_VO', cue = 'X02_Celene_T01_04547'},
{text = '<LOC X02_T01_150_010>[{i Celene}]: I will not be defeated by the likes of you!', bank = 'X02_VO', cue = 'X02_Celene_T01_04551'},
{text = '<LOC X02_T01_001_010>[{i Celene}]: No, you may not have that experimental.', bank = 'X02_VO', cue = 'X02_Celene_T01_04782'},
{text = '<LOC X01_T01_040_010>[{i Gari}]: Your tenacity is admirable, but the outcome of this battle was determined long ago.', bank = 'X01_VO', cue = 'X01_Gari_T01_04514'},
{text = '<LOC X01_T01_060_010>[{i Gari}]: Now you will taste the fury of the Order of the Illuminate.', bank = 'X01_VO', cue = 'X01_Gari_T01_04516'},
{text = '<LOC X01_T01_070_010>[{i Gari}]: You have nowhere to hide, nowhere to run.', bank = 'X01_VO', cue = 'X01_Gari_T01_04517'},
{text = '<LOC X01_T01_100_010>[{i Gari}]: Not even your most powerful weapon can stand before me.', bank = 'X01_VO', cue = 'X01_Gari_T01_04520'},
{text = '<LOC X01_T01_110_010>[{i Gari}]: Beg for mercy and perhaps I shall grant you an honorable death.', bank = 'X01_VO', cue = 'X01_Gari_T01_04521'},
{text = '<LOC X01_T01_150_010>[{i Gari}]: You are an abomination. I will take great pleasure in exterminating you.', bank = 'X01_VO', cue = 'X01_Gari_T01_04525'},
{text = '<LOC X01_T01_180_010>[{i Gari}]: The Order is eternal. There is no stopping us.', bank = 'X01_VO', cue = 'X01_Gari_T01_04529'},
{text = '<LOC X06_T01_560_010>[{i Vendetta}]: Nice try.', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03018'},
{text = '<LOC X06_T01_570_010>[{i Vendetta}]: I am not defeated yet!', bank = 'X06_VO', cue = 'X06_Vedetta_T01_03019'},
{text = '<LOC XGG_MP1_330_010>[{i Dostya}]: I have little to fear from the likes of you.', bank = 'XGG', cue = 'XGG_Dostya_MP1_04598'},
{text = '<LOC XGG_MP1_340_010>[{i Dostya}]: Observe. You may learn something.', bank = 'XGG', cue = 'XGG_Dostya_MP1_04599'},
{text = '<LOC XGG_MP1_350_010>[{i Dostya}]: I would flee, if I were you.', bank = 'XGG', cue = 'XGG_Dostya_MP1_04600'},
{text = '<LOC XGG_MP1_360_010>[{i Dostya}]: You will be just another in my list of victories.', bank = 'XGG', cue = 'XGG_Dostya_MP1_04601'},
{text = '<LOC XGG_MP1_370_010>[{i Dostya}]: You are not worth my time.', bank = 'XGG', cue = 'XGG_Dostya_MP1_04602'},
{text = '<LOC XGG_MP1_380_010>[{i Dostya}]: Your defeat is without question.', bank = 'XGG', cue = 'XGG_Dostya_MP1_04603'},
{text = '<LOC XGG_MP1_390_010>[{i Dostya}]: You seem to have courage. Intelligence seems to be lacking.', bank = 'XGG', cue = 'XGG_Dostya_MP1_04604'},
{text = '<LOC XGG_MP1_400_010>[{i Dostya}]: I will destroy you.', bank = 'XGG', cue = 'XGG_Dostya_MP1_04605'},
{text = '<LOC XGG_MP1_410_010>[{i Brackman}]: I\'m afraid there is no hope for you, oh yes.', bank = 'XGG', cue = 'XGG_Brackman_MP1_04606'},
{text = '<LOC XGG_MP1_420_010>[{i Brackman}]: Well, at least you provided me with some amusement.', bank = 'XGG', cue = 'XGG_Brackman_MP1_04607'},
{text = '<LOC XGG_MP1_430_010>[{i Brackman}]: Perhaps some remedial training is in order?', bank = 'XGG', cue = 'XGG_Brackman_MP1_04608'},
{text = '<LOC XGG_MP1_440_010>[{i Brackman}]: Are you sure you want to do that?', bank = 'XGG', cue = 'XGG_Brackman_MP1_04609'},
{text = '<LOC XGG_MP1_450_010>[{i Brackman}]: They do not call me a genius for nothing, you know.', bank = 'XGG', cue = 'XGG_Brackman_MP1_04610'},
{text = '<LOC XGG_MP1_460_010>[{i Brackman}]: Defeating you is hardly worth the effort, oh yes.', bank = 'XGG', cue = 'XGG_Brackman_MP1_04611'},
{text = '<LOC XGG_MP1_470_010>[{i Brackman}]: There is nothing you can do.', bank = 'XGG', cue = 'XGG_Brackman_MP1_04612'},
{text = '<LOC XGG_MP1_480_010>[{i Brackman}]: At least you will not suffer long.', bank = 'XGG', cue = 'XGG_Brackman_MP1_04613'},
{text = '<LOC XGG_MP1_490_010>[{i QAI}]: You will not prevail.', bank = 'XGG', cue = 'XGG_QAI_MP1_04614'},
{text = '<LOC XGG_MP1_500_010>[{i QAI}]: Your destruction is 99% certain.', bank = 'XGG', cue = 'XGG_QAI_MP1_04615'},
{text = '<LOC XGG_MP1_510_010>[{i QAI}]: I cannot be defeated.', bank = 'XGG', cue = 'XGG_QAI_MP1_04616'},
{text = '<LOC XGG_MP1_520_010>[{i QAI}]: Your strategies are without merit.', bank = 'XGG', cue = 'XGG_QAI_MP1_04617'},
{text = '<LOC XGG_MP1_530_010>[{i QAI}]: My victory is without question.', bank = 'XGG', cue = 'XGG_QAI_MP1_04618'},
{text = '<LOC XGG_MP1_540_010>[{i QAI}]: Your defeat can be the only outcome.', bank = 'XGG', cue = 'XGG_QAI_MP1_04619'},
{text = '<LOC XGG_MP1_550_010>[{i QAI}]: Your efforts are futile.', bank = 'XGG', cue = 'XGG_QAI_MP1_04620'},
{text = '<LOC XGG_MP1_560_010>[{i QAI}]: Retreat is your only logical option.', bank = 'XGG', cue = 'XGG_QAI_MP1_04621'},
{text = '<LOC X02_T01_220_010>[{i QAI}]: All calculations indicate that your demise is near.', bank = 'X02_VO', cue = 'X02_QAI_T01_04558'},
{text = '<LOC X02_T01_280_010>[{i QAI}]: If you destroy this ACU, another shall rise in its place. I am endless.', bank = 'X02_VO', cue = 'X02_QAI_T01_04564'},
{text = '<LOC X05_T01_080_010>[{i QAI}]: I have examined our previous battles and created the appropriate subroutines to counter your strategies. You cannot win.', bank = 'X05_VO', cue = 'X05_QAI_T01_04422'},
{text = '<LOC XGG_MP1_570_010>[{i Hex5}]: You\'re screwed!', bank = 'XGG', cue = 'XGG_Hex5_MP1_04622'},
{text = '<LOC XGG_MP1_580_010>[{i Hex5}]: I do make it look easy.', bank = 'XGG', cue = 'XGG_Hex5_MP1_04623'},
{text = '<LOC XGG_MP1_590_010>[{i Hex5}]: You should probably run away now.', bank = 'XGG', cue = 'XGG_Hex5_MP1_04624'},
{text = '<LOC XGG_MP1_600_010>[{i Hex5}]: A smoking crater is going to be all that\'s left of you.', bank = 'XGG', cue = 'XGG_Hex5_MP1_04625'},
{text = '<LOC XGG_MP1_610_010>[{i Hex5}]: So, I guess failure runs in your family?', bank = 'XGG', cue = 'XGG_Hex5_MP1_04626'},
{text = '<LOC XGG_MP1_620_010>[{i Hex5}]: Man, I\'m good at this!', bank = 'XGG', cue = 'XGG_Hex5_MP1_04627'},
{text = '<LOC XGG_MP1_630_010>[{i Hex5}]: Goodbye!', bank = 'XGG', cue = 'XGG_Hex5_MP1_04628'},
{text = '<LOC XGG_MP1_640_010>[{i Hex5}]: Don\'t worry, it\'ll be over soon.', bank = 'XGG', cue = 'XGG_Hex5_MP1_04629'},
{text = '<LOC X05_T01_190_010>[{i Hex5}]: You will bow before the Seraphim.', bank = 'X05_VO', cue = 'X05_Hex5_T01_04433'},
{text = '<LOC X04_T01_020_010>[{i OumEoshi}]: Only one species can attain perfection.', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04384'},
{text = '<LOC X04_T01_030_010>[{i OumEoshi}]: Do not fret. Dying by my hand is the supreme honor.', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04385'},
{text = '<LOC X04_T01_040_010>[{i OumEoshi}]: Soon there will be more of us than you can possibly ever hope to defeat.', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04386'},
{text = '<LOC X06_T01_210_010>[{i ThelUuthow}]: You Cybrans die as easily as any other human.', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02973'},
{text = '<LOC X06_T01_240_010>[{i ThelUuthow}]: Bow down before our might, and we may spare you.', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02976'},
{text = '<LOC X06_T01_260_010>[{i ThelUuthow}]: You will perish at my hand.', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_02978'},--]]


--Taunts re stopping player completing an experimental
--[[
{text = '<LOC X06_T01_585_010>[{i Fletcher}]: I won\'t let you use that experimental!', vid = 'X06_Fletcher_T01_04803.sfd', bank = 'X06_VO', cue = 'X06_Fletcher_T01_04803', faction = 'UEF'},
{text = '<LOC X06_T01_587_010>[{i Fletcher}]: You can\'t stop me with that experimental! I\'ll destroy it first!', vid = 'X06_Fletcher_T01_04805.sfd', bank = 'X06_VO', cue = 'X06_Fletcher_T01_04805', faction = 'UEF'},

{text = '<LOC X01_T01_001_010>[{i Gari}]: I will not allow you to build that experimental.', vid = 'X01_Gari_T01_04779.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04779', faction = 'Aeon'},
{text = '<LOC X01_T01_002_010>[{i Gari}]: No, you will not complete that experimental.', vid = 'X01_Gari_T01_04780.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04780', faction = 'Aeon'},
{text = '<LOC X01_T01_003_010>[{i Gari}]: An experimental? I am not so foolish as to let you finish that.', vid = 'X01_Gari_T01_04781.sfd', bank = 'X01_VO', cue = 'X01_Gari_T01_04781', faction = 'Aeon'},
{text = '<LOC X02_T01_002_010>[{i Celene}]: I will destroy that experimental before you even finish it!', vid = 'X02_Celene_T01_04783.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04783', faction = 'Aeon'},
{text = '<LOC X02_T01_003_010>[{i Celene}]: Watch as I destroy your experimental even before it can be activated.', vid = 'X02_Celene_T01_04784.sfd', bank = 'X02_VO', cue = 'X02_Celene_T01_04784', faction = 'Aeon'},
{text = '<LOC X06_T01_275_010>[{i Vendetta}]: Your experimental could cause me problems, so I think I will eliminate it.', vid = 'X06_Vedetta_T01_04800.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_04800', faction = 'Aeon'},
{text = '<LOC X06_T01_276_010>[{i Vendetta}]: No, you will not finish that experimental!', vid = 'X06_Vedetta_T01_04801.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_04801', faction = 'Aeon'},
{text = '<LOC X06_T01_277_010>[{i Vendetta}]: Do not think you will complete that experimental!', vid = 'X06_Vedetta_T01_04802.sfd', bank = 'X06_VO', cue = 'X06_Vedetta_T01_04802', faction = 'Aeon'},

{text = '<LOC X02_T01_165_010>[{i QAI}]: You will not complete that experimental unit.', vid = 'X02_QAI_T01_04785.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04785', faction = 'Cybran'},
{text = '<LOC X02_T01_166_010>[{i QAI}]: I will not allow you to jeopardize my mission by finishing that experimental.', vid = 'X02_QAI_T01_04786.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04786', faction = 'Cybran'},
{text = '<LOC X02_T01_167_010>[{i QAI}]: Your experimental unit may actually be dangerous if completed. Ergo, I will destroy it now.', vid = 'X02_QAI_T01_04787.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04787', faction = 'Cybran'},
{text = '<LOC X05_T01_125_010>[{i Hex5}]: Completing that experimental unit could interfere with the Master\'s plans. I will not allow that.', vid = 'X05_Hex5_T01_04794.sfd', bank = 'X05_VO', cue = 'X05_Hex5_T01_04794', faction = 'Cybran'},
{text = '<LOC X05_T01_126_010>[{i Hex5}]: The Master wills that your experimental will not come online.', vid = 'X05_Hex5_T01_04795.sfd', bank = 'X05_VO', cue = 'X05_Hex5_T01_04795', faction = 'Cybran'},
{text = '<LOC X05_T01_127_010>[{i Hex5}]: That experimental unit will not be completed!', vid = 'X05_Hex5_T01_04796.sfd', bank = 'X05_VO', cue = 'X05_Hex5_T01_04796', faction = 'Cybran'},

{text = '<LOC X04_T01_001_010>[{i OumEoshi}]: Your experimental units are actually troublesome. It will be destroyed before it is completed.', vid = 'X04_Oum-Eoshi_T01_04788.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04788', faction = 'Seraphim'},
{text = '<LOC X04_T01_002_010>[{i OumEoshi}]: I admire your tenacity, but I will not allow you to complete that experimental unit.', vid = 'X04_Oum-Eoshi_T01_04789.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04789', faction = 'Seraphim'},
{text = '<LOC X04_T01_003_010>[{i OumEoshi}]: Your doom is without question, yet I cannot allow you to finish that experimental.', vid = 'X04_Oum-Eoshi_T01_04790.sfd', bank = 'X04_VO', cue = 'X04_Oum-Eoshi_T01_04790', faction = 'Seraphim'},
{text = '<LOC X06_T01_001_010>[{i ThelUuthow}]: I will not allow your experimental to interfere with my mission!', vid = 'X06_Thel-Uuthow_T01_04797.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_04797', faction = 'Seraphim'},
{text = '<LOC X06_T01_002_010>[{i ThelUuthow}]: I will eliminate your experimental just as we will eventually eliminate your Coalition!', vid = 'X06_Thel-Uuthow_T01_04798.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_04798', faction = 'Seraphim'},
{text = '<LOC X06_T01_003_010>[{i ThelUuthow}]: Your experimental will never activate!', vid = 'X06_Thel-Uuthow_T01_04799.sfd', bank = 'X06_VO', cue = 'X06_Thel-Uuthow_T01_04799', faction = 'Seraphim'},
--]]