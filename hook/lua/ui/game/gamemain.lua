---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 01/12/2022 08:27
---
local M28Config = import('/mods/M28AI/lua/M28Config.lua')

local M28OnFirstUpdate = OnFirstUpdate
function OnFirstUpdate()
    M28OnFirstUpdate()
    if M28Config.M28RunVeryFast == true then
        ConExecute("WLD_GameSpeed 15")
        ForkThread(
                function()
                    WaitSeconds(1.5)
                    WaitSeconds(1.5)

                    ConExecute('path_armybudget = 6500')
                    ConExecute('path_backgroundbudget = 3000')
                    ConExecute('path_maxinstantworkunits = 1250')
                end
        )
        --(tried testing with a similar fork thread for adjusting game speed or pausing later on and failed, unsure why - commented out the failed code below - the first log triggers, but not the second)
        --[[ForkThread(
                function()
                    LOG('Will try waiting 10s and then pausing or slowing game')
                    WaitSeconds(10)
                    LOG('About to run ConExecute for gamespeed')
                    ConExecute("WLD_GameSpeed 1")
                    LOG('About to do sessionrequestpause')
                    SessionRequestPause()

                end
        )--]]
    end
    --WaitSeconds(3) --If we try to wait it causes an error
    --Thanks to Sprouto for providing the below - it didnt solve the issue I was having, but have left this in in case it is of use at solving other issues, as Sprouto mentioned the sim can sometimes get overloaded and for the clost of some memory the below can avoid most issues
    --NOTE - suspect the below may cause replays to desync so have disabled
    --[[ConExecute('path_armybudget = 6500')
    ConExecute('path_backgroundbudget = 3000')
    ConExecute('path_maxinstantworkunits = 1250')--]]
end
