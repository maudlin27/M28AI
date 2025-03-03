---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 19/06/2024 08:07
---


--WARNING: LOUD APPEARS TO USE THE KEY IN SCENARIOINFO NOT THE TEXT/VALUE

LobbyGlobalOptions = {
    {
        default = 9,
        label = "M28: AIx Overwhelm rate",
        help = "Adjust M28 AIx build and cheat modifiers by this amount periodically (0.0 to disable)",
        key = 'M28OvwR',
        pref = 'pref_M28AIxOverwhelmR',
        --pref = 'lob_teams_combo',
        --type = 'index',
        --value_text = "%s",
        --value_help = "Amount to change the cheat modifiers by",
        values = {
            {
                text = '-0.5',
                help = 'Amount to change AIx modifier by',
                key = 1,
            },
            {
                text = '-0.4',
                help = 'Amount to change AIx modifier by',
                key = 2,
            },
            {
                text = '-0.3',
                help = 'Amount to change AIx modifier by',
                key = 3,
            },
            {
                text = '-0.2',
                help = 'Amount to change AIx modifier by',
                key = 4,
            },
            {
                text = '-0.1',
                help = 'Amount to change AIx modifier by',
                key = 5,
            },
            {
                text = '-0.05',
                help = 'Amount to change AIx modifier by',
                key = 6,
            },
            {
                text = '-0.02',
                help = 'Amount to change AIx modifier by',
                key = 7,
            },
            {
                text = '-0.01',
                help = 'Amount to change AIx modifier by',
                key = 8,
            },
            {
                text = '0.0',
                help = 'Amount to change AIx modifier by',
                key = 9,
            },
            {
                text = '0.01',
                help = 'Amount to change AIx modifier by',
                key = 10,
            },
            {
                text = '0.02',
                help = 'Amount to change AIx modifier by',
                key = 11,
            },
            {
                text = '0.05',
                help = 'Amount to change AIx modifier by',
                key = 12,
            },
            {
                text = '0.1',
                help = 'Amount to change AIx modifier by',
                key = 13,
            },
            {
                text = '0.2',
                help = 'Amount to change AIx modifier by',
                key = 14,
            },
            {
                text = '0.3',
                help = 'Amount to change AIx modifier by',
                key = 15,
            },
            {
                text = '0.4',
                help = 'Amount to change AIx modifier by',
                key = 16,
            },
            {
                text = '0.5',
                help = 'Amount to change AIx modifier by',
                key = 17,
            },
        },
    },
    {
        default = 16,
        label = "M28: AIx Overwhelm interval",
        help = "Time in minutes between each AIx overwhelm adjustment",
        key = 'M28OvwT',
        pref = 'pref_M28AIxOverwhelmT',
        --pref = 'lob_teams_combo',
        --type = 'index',
        --value_text = "%s",
        --value_help = "Minutes between each change",
        values = {
            {
                text = '0.5',
                help = 'Minutes between overwhelm adj',
                key = 1,
            },
            {
                text = '1',
                help = 'Minutes between overwhelm adj',
                key = 2,
            },
            {
                text = '2',
                help = 'Minutes between overwhelm adj',
                key = 3,
            },
            {
                text = '3',
                help = 'Minutes between overwhelm adj',
                key = 4,
            },
            {
                text = '4',
                help = 'Minutes between overwhelm adj',
                key = 5,
            },
            {
                text = '5',
                help = 'Minutes between overwhelm adj',
                key = 6,
            },
            {
                text = '6',
                help = 'Minutes between overwhelm adj',
                key = 7,
            },
            {
                text = '7',
                help = 'Minutes between overwhelm adj',
                key = 8,
            },
            {
                text = '8',
                help = 'Minutes between overwhelm adj',
                key = 9,
            },
            {
                text = '9',
                help = 'Minutes between overwhelm adj',
                key = 10,
            },
            {
                text = '10',
                help = 'Minutes between overwhelm adj',
                key = 11,
            },
            {
                text = '11',
                help = 'Minutes between overwhelm adj',
                key = 12,
            },
            {
                text = '12',
                help = 'Minutes between overwhelm adj',
                key = 13,
            },
            {
                text = '13',
                help = 'Minutes between overwhelm adj',
                key = 14,
            },
            {
                text = '14',
                help = 'Minutes between overwhelm adj',
                key = 15,
            },
            {
                text = '15',
                help = 'Minutes between overwhelm adj',
                key = 16,
            },
            {
                text = '20',
                help = 'Minutes between overwhelm adj',
                key = 17,
            },
            {
                text = '25',
                help = 'Minutes between overwhelm adj',
                key = 18,
            },
            {
                text = '30',
                help = 'Minutes between overwhelm adj',
                key = 19,
            },
            {
                text = '35',
                help = 'Minutes between overwhelm adj',
                key = 20,
            },
            {
                text = '40',
                help = 'Minutes between overwhelm adj',
                key = 21,
            },
            {
                text = '45',
                help = 'Minutes between overwhelm adj',
                key = 22,
            },
            {
                text = '50',
                help = 'Minutes between overwhelm adj',
                key = 23,
            },
            {
                text = '55',
                help = 'Minutes between overwhelm adj',
                key = 24,
            },
            {
                text = '60',
                help = 'Minutes between overwhelm adj',
                key = 25,
            },
            {
                text = '90',
                help = 'Minutes between overwhelm adj',
                key = 26,
            },
        },
    },
    {
        default = 11,
        label = "M28: AIx Overwhelm limit",
        help = "Stops changing the AIx overwhelm modifier once this AIx modifier is reached",
        key = 'M28OvwC',
        pref = 'pref_M28AIxOverwhelmL',
        --pref = 'lob_teams_combo',
        --type = 'index',
        --value_text = "%s",
        --value_help = "Resource and build multiplier limit",
        values = {
            {
                text = '0.5',
                help = 'AIx Overwhelm limit',
                key = 1,
            },
            {
                text = '0.6',
                help = 'AIx Overwhelm limit',
                key = 2,
            },
            {
                text = '0.7',
                help = 'AIx Overwhelm limit',
                key = 3,
            },
            {
                text = '0.8',
                help = 'AIx Overwhelm limit',
                key = 4,
            },
            {
                text = '0.9',
                help = 'AIx Overwhelm limit',
                key = 5,
            },
            {
                text = '1.0',
                help = 'AIx Overwhelm limit',
                key = 6,
            },
            {
                text = '1.1',
                help = 'AIx Overwhelm limit',
                key = 7,
            },
            {
                text = '1.2',
                help = 'AIx Overwhelm limit',
                key = 8,
            },
            {
                text = '1.3',
                help = 'AIx Overwhelm limit',
                key = 9,
            },
            {
                text = '1.4',
                help = 'AIx Overwhelm limit',
                key = 10,
            },
            {
                text = '1.5',
                help = 'AIx Overwhelm limit',
                key = 11,
            },
            {
                text = '1.6',
                help = 'AIx Overwhelm limit',
                key = 12,
            },
            {
                text = '1.7',
                help = 'AIx Overwhelm limit',
                key = 13,
            },
            {
                text = '1.8',
                help = 'AIx Overwhelm limit',
                key = 14,
            },
            {
                text = '1.9',
                help = 'AIx Overwhelm limit',
                key = 15,
            },
            {
                text = '2.0',
                help = 'AIx Overwhelm limit',
                key = 16,
            },
            {
                text = '2.1',
                help = 'AIx Overwhelm limit',
                key = 17,
            },
            {
                text = '2.2',
                help = 'AIx Overwhelm limit',
                key = 18,
            },
            {
                text = '2.3',
                help = 'AIx Overwhelm limit',
                key = 19,
            },
            {
                text = '2.4',
                help = 'AIx Overwhelm limit',
                key = 20,
            },
            {
                text = '2.5',
                help = 'AIx Overwhelm limit',
                key = 21,
            },
            {
                text = '2.6',
                help = 'AIx Overwhelm limit',
                key = 22,
            },
            {
                text = '2.7',
                help = 'AIx Overwhelm limit',
                key = 23,
            },
            {
                text = '2.8',
                help = 'AIx Overwhelm limit',
                key = 24,
            },
            {
                text = '2.9',
                help = 'AIx Overwhelm limit',
                key = 25,
            },
            {
                text = '3.0',
                help = 'AIx Overwhelm limit',
                key = 26,
            },
            {
                text = '3.1',
                help = 'AIx Overwhelm limit',
                key = 27,
            },
            {
                text = '3.2',
                help = 'AIx Overwhelm limit',
                key = 28,
            },
            {
                text = '3.3',
                help = 'AIx Overwhelm limit',
                key = 29,
            },
            {
                text = '3.4',
                help = 'AIx Overwhelm limit',
                key = 30,
            },
            {
                text = '3.5',
                help = 'AIx Overwhelm limit',
                key = 31,
            },
            {
                text = '3.6',
                help = 'AIx Overwhelm limit',
                key = 32,
            },
            {
                text = '3.7',
                help = 'AIx Overwhelm limit',
                key = 33,
            },
            {
                text = '3.8',
                help = 'AIx Overwhelm limit',
                key = 34,
            },
            {
                text = '3.9',
                help = 'AIx Overwhelm limit',
                key = 35,
            },
            {
                text = '4.0',
                help = 'AIx Overwhelm limit',
                key = 36,
            },
            {
                text = '4.1',
                help = 'AIx Overwhelm limit',
                key = 37,
            },
            {
                text = '4.2',
                help = 'AIx Overwhelm limit',
                key = 38,
            },
            {
                text = '4.3',
                help = 'AIx Overwhelm limit',
                key = 39,
            },
            {
                text = '4.4',
                help = 'AIx Overwhelm limit',
                key = 40,
            },
            {
                text = '4.5',
                help = 'AIx Overwhelm limit',
                key = 41,
            },
            {
                text = '4.6',
                help = 'AIx Overwhelm limit',
                key = 42,
            },
            {
                text = '4.7',
                help = 'AIx Overwhelm limit',
                key = 43,
            },
            {
                text = '4.8',
                help = 'AIx Overwhelm limit',
                key = 44,
            },
            {
                text = '4.9',
                help = 'AIx Overwhelm limit',
                key = 45,
            },
            {
                text = '5.0',
                help = 'AIx Overwhelm limit',
                key = 46,
            },
            {
                text = '5.1',
                help = 'AIx Overwhelm limit',
                key = 47,
            },
            {
                text = '5.2',
                help = 'AIx Overwhelm limit',
                key = 48,
            },
            {
                text = '5.3',
                help = 'AIx Overwhelm limit',
                key = 49,
            },
            {
                text = '5.4',
                help = 'AIx Overwhelm limit',
                key = 50,
            },
            {
                text = '5.5',
                help = 'AIx Overwhelm limit',
                key = 51,
            },
            {
                text = '5.6',
                help = 'AIx Overwhelm limit',
                key = 52,
            },
            {
                text = '5.7',
                help = 'AIx Overwhelm limit',
                key = 53,
            },
            {
                text = '5.8',
                help = 'AIx Overwhelm limit',
                key = 54,
            },
            {
                text = '5.9',
                help = 'AIx Overwhelm limit',
                key = 55,
            },
            {
                text = '6.0',
                help = 'AIx Overwhelm limit',
                key = 56,
            },
            {
                text = '6.1',
                help = 'AIx Overwhelm limit',
                key = 57,
            },
            {
                text = '6.2',
                help = 'AIx Overwhelm limit',
                key = 58,
            },
            {
                text = '6.3',
                help = 'AIx Overwhelm limit',
                key = 59,
            },
            {
                text = '6.4',
                help = 'AIx Overwhelm limit',
                key = 60,
            },
            {
                text = '6.5',
                help = 'AIx Overwhelm limit',
                key = 61,
            },
            {
                text = '6.6',
                help = 'AIx Overwhelm limit',
                key = 62,
            },
            {
                text = '6.7',
                help = 'AIx Overwhelm limit',
                key = 63,
            },
            {
                text = '6.8',
                help = 'AIx Overwhelm limit',
                key = 64,
            },
            {
                text = '6.9',
                help = 'AIx Overwhelm limit',
                key = 65,
            },
            {
                text = '7.0',
                help = 'AIx Overwhelm limit',
                key = 66,
            },
            {
                text = '7.1',
                help = 'AIx Overwhelm limit',
                key = 67,
            },
            {
                text = '7.2',
                help = 'AIx Overwhelm limit',
                key = 68,
            },
            {
                text = '7.3',
                help = 'AIx Overwhelm limit',
                key = 69,
            },
            {
                text = '7.4',
                help = 'AIx Overwhelm limit',
                key = 70,
            },
            {
                text = '7.5',
                help = 'AIx Overwhelm limit',
                key = 71,
            },
            {
                text = '7.6',
                help = 'AIx Overwhelm limit',
                key = 72,
            },
            {
                text = '7.7',
                help = 'AIx Overwhelm limit',
                key = 73,
            },
            {
                text = '7.8',
                help = 'AIx Overwhelm limit',
                key = 74,
            },
            {
                text = '7.9',
                help = 'AIx Overwhelm limit',
                key = 75,
            },
            {
                text = '8.0',
                help = 'AIx Overwhelm limit',
                key = 76,
            },
            {
                text = '8.1',
                help = 'AIx Overwhelm limit',
                key = 77,
            },
            {
                text = '8.2',
                help = 'AIx Overwhelm limit',
                key = 78,
            },
            {
                text = '8.3',
                help = 'AIx Overwhelm limit',
                key = 79,
            },
            {
                text = '8.4',
                help = 'AIx Overwhelm limit',
                key = 80,
            },
            {
                text = '8.5',
                help = 'AIx Overwhelm limit',
                key = 81,
            },
            {
                text = '8.6',
                help = 'AIx Overwhelm limit',
                key = 82,
            },
            {
                text = '8.7',
                help = 'AIx Overwhelm limit',
                key = 83,
            },
            {
                text = '8.8',
                help = 'AIx Overwhelm limit',
                key = 84,
            },
            {
                text = '8.9',
                help = 'AIx Overwhelm limit',
                key = 85,
            },
            {
                text = '9.0',
                help = 'AIx Overwhelm limit',
                key = 86,
            },
            {
                text = '9.1',
                help = 'AIx Overwhelm limit',
                key = 87,
            },
            {
                text = '9.2',
                help = 'AIx Overwhelm limit',
                key = 88,
            },
            {
                text = '9.3',
                help = 'AIx Overwhelm limit',
                key = 89,
            },
            {
                text = '9.4',
                help = 'AIx Overwhelm limit',
                key = 90,
            },
            {
                text = '9.5',
                help = 'AIx Overwhelm limit',
                key = 91,
            },
            {
                text = '9.6',
                help = 'AIx Overwhelm limit',
                key = 92,
            },
            {
                text = '9.7',
                help = 'AIx Overwhelm limit',
                key = 93,
            },
            {
                text = '9.8',
                help = 'AIx Overwhelm limit',
                key = 94,
            },
            {
                text = '9.9',
                help = 'AIx Overwhelm limit',
                key = 95,
            },
            {
                text = '10.0',
                help = 'AIx Overwhelm limit',
                key = 96,
            },
        },
    },
    --[[{
        default = 2,
        label = "M28: Use AIx modifiers?",
        help = "Applies AIx resource and build rate modifiers to all M28AI",
        key = 'CmApplyAIx',
        value_text = "",
        value_help = "Apply AIx Resource and build rate to campaign AI?",
        values = {
            {
                text = 'Yes',
                help = 'Apply AIx modifiers',
                key = 1,
            },
            {
                text = 'No',
                help = 'Dont apply AIx modifiers',
                key = 2,
            },
        },
    },--]]

    --[[{
        default = 2,
        label = "M28: Use M28Easy?",
        help = 'Applies M28Easy logic instead of M28AI; M28Easy disables most micro',
        key = 'CmM28Easy',
        --pref = 'lob_teams_combo',
        --type = 'index',
        --value_text = "",
        --value_help = "Use M28Easy logic, disabling most micro?",
        values = {
            {
                text = 'Yes',
                help = 'Apply M28Easy logic',
                key = 1,
            },
            {
                text = 'No',
                help = 'Use normal M28AI logic',
                key = 2,
            },
        },
    },--]]
    {
        default = 10,
        label = "M28: aggression override",
        help = "Use 1.0 if you want a competitive experience - this adjusts M28's calculation of the value/threat of enemy units by the value specified (a value below 1 means M28 will treat enemy units as being worth less, and so will be more likely to engage with land units, but also less likely to consider nuke targets as worth nuking)",
        key = 'M28Aggression',
        pref = 'pref_M28Aggression',
        bUseKeyAsValueInScenarioInfo = false, --referenced by M28 in initialisation where it updates scenarioinfo.option values so are being consistent in how variables are stored
        values = {
            {
                text = '0.1',
                help = 'Enemy threat factor',
                key = 1,
            },
            {
                text = '0.2',
                help = 'Enemy threat factor',
                key = 2,
            },
            {
                text = '0.3',
                help = 'Enemy threat factor',
                key = 3,
            },
            {
                text = '0.4',
                help = 'Enemy threat factor',
                key = 4,
            },
            {
                text = '0.5',
                help = 'Enemy threat factor',
                key = 5,
            },
            {
                text = '0.6',
                help = 'Enemy threat factor',
                key = 6,
            },
            {
                text = '0.7',
                help = 'Enemy threat factor',
                key = 7,
            },
            {
                text = '0.8',
                help = 'Enemy threat factor',
                key = 8,
            },
            {
                text = '0.9',
                help = 'Enemy threat factor',
                key = 9,
            },
            {
                text = '1.0',
                help = 'Enemy threat factor',
                key = 10,
            },
            {
                text = '1.1',
                help = 'Enemy threat factor',
                key = 11,
            },
            {
                text = '1.2',
                help = 'Enemy threat factor',
                key = 12,
            },
            {
                text = '1.3',
                help = 'Enemy threat factor',
                key = 13,
            },
            {
                text = '1.4',
                help = 'Enemy threat factor',
                key = 14,
            },
            {
                text = '1.5',
                help = 'Enemy threat factor',
                key = 15,
            },
            {
                text = '1.6',
                help = 'Enemy threat factor',
                key = 16,
            },
            {
                text = '1.7',
                help = 'Enemy threat factor',
                key = 17,
            },
            {
                text = '1.8',
                help = 'Enemy threat factor',
                key = 18,
            },
            {
                text = '1.9',
                help = 'Enemy threat factor',
                key = 19,
            },
            {
                text = '2.0',
                help = 'Enemy threat factor',
                key = 20,
            },
            {
                text = '2.5',
                help = 'Enemy threat factor',
                key = 21,
            },
            {
                text = '3',
                help = 'Enemy threat factor',
                key = 22,
            },
            {
                text = '4',
                help = 'Enemy threat factor',
                key = 23,
            },
            {
                text = '5',
                help = 'Enemy threat factor',
                key = 24,
            },

        },
    },
    {
        default = 1,
        label = "M28: Time between orders",
        help = "Minimum number of seconds between orders for most units (e.g. makes M28 kiting significantly weaker).  Doesnt affect certain microing",
        key = 'M28TimeBetweenOrders',
        pref = 'pref_M28TimeBetweenOrders',
        bUseKeyAsValueInScenarioInfo = false, --referenced by M28 in initialisation where it updates scenarioinfo.option values so are being consistent in how variables are stored
        values = {
            {
                text = '1.0',
                 help = 'Seconds between orders',
                key = 1,
            },
            {
                text = '1.1',
                 help = 'Seconds between orders',
                key = 2,
            },
            {
                text = '1.2',
                 help = 'Seconds between orders',
                key = 3,
            },
            {
                text = '1.3',
                 help = 'Seconds between orders',
                key = 4,
            },
            {
                text = '1.4',
                 help = 'Seconds between orders',
                key = 5,
            },
            {
                text = '1.5',
                 help = 'Seconds between orders',
                key = 6,
            },
            {
                text = '2.0',
                 help = 'Seconds between orders',
                key = 7,
            },
            {
                text = '3.0',
                 help = 'Seconds between orders',
                key = 8,
            },
            {
                text = '4.0',
                 help = 'Seconds between orders',
                key = 9,
            },
            {
                text = '5.0',
                 help = 'Seconds between orders',
                key = 10,
            },
            {
                text = '6.0',
                 help = 'Seconds between orders',
                key = 11,
            },
            {
                text = '7.0',
                 help = 'Seconds between orders',
                key = 12,
            },
            {
                text = '8.0',
                 help = 'Seconds between orders',
                key = 13,
            },
            {
                text = '9.0',
                 help = 'Seconds between orders',
                key = 14,
            },
            {
                text = '10.0',
                 help = 'Seconds between orders',
                key = 15,
            },
        },
    },
    {
        default = 2,
        label = "M28: CPU performance mode?",
        help = 'If enabled, M28 will use simpler functionality for parts of its logic, making it less challenging but also faster to run',
        key = 'M28CPUPerformance',
        pref = 'pref_M28CPUPerformance',
        bUseKeyAsValueInScenarioInfo = true,
        values = {
            { --By having values in table like this, it means that FAF will record the key in ScenarioInfo.Options (not the text)
                text = 'Yes',
                help = 'Apply CPU performance mode',
                key = 1,
            },
            {
                text = 'No',
                help = 'Dont enable performance mode (recommended)',
                key = 2,
            },
        },
    },
    {
        default = 1,
        label = "M28: Prioritise stronger units?",
        help = 'By default M28 will always build certain T1-T3 land and certain experimental units over others (e.g. bricks instead of loyalists after a few have been built); disabling this should increase variety of units built',
        key = 'M28PrioritiseBPs',
        pref = 'pref_M28PrioritiseBPs',
        bUseKeyAsValueInScenarioInfo = true,
        values = {
            {
                text = 'Yes',
                help = 'Apply land unit prioritisation',
                key = 1,
            },
            {
                text = 'No',
                help = 'Dont prioritise certain land units',
                key = 2,
            },
        },

    },
    {
        default = 1,
        label = "M28: Use dodge micro?",
        help = 'By default M28 will try and dodge slow moving shots and bombs with units (except for M28Easy)',
        key = 'M28DodgeMicro',
        pref = 'pref_M28DodgeMicro',
        bUseKeyAsValueInScenarioInfo = true,
        values = {
            {
                text = 'Yes',
                help = 'Dodge slow moving shots',
                key = 1,
            },
            {
                text = 'No',
                help = 'Dont try dodging shots',
                key = 2,
            },
        },
    },
    {
        default = 2,
        label = "M28: Combined AI-Human armies?",
        help = 'If enabled, then human players can toggle M28AI logic on individual units',
        key = 'M28CombinedArmy',
        pref = 'pref_M28CombinedArmy',
        bUseKeyAsValueInScenarioInfo = true,
        values = {
            {
                text = 'Yes',
                help = 'Enable combined armies',
                key = 1,
            },
            {
                text = 'No',
                help = 'Disable combined armies',
                key = 2,
            },
            {
                text = 'MOBA (all non-ACU units)',
                help = 'MOBA mode - AI controls everything except your ACU',
                key = 3,
            },
            {
                text = 'No (hide button)',
                help = 'Disable combined armies, and dont show the UI button in-game',
                key = 4,
            },
        },
    },
    {
        default = 2,
        label = "M28: CA Inherit constructing unit status?",
        help = 'If combined armies are enabled, this determines whether units starting control will be based on their parent/constructing unit',
        key = 'M28CAInherit',
        pref = 'pref_M28CAInherit',
        values = {
            { --By having values in table like this, it means that FAF will record the key in ScenarioInfo.Options (not the text)
                text = 'Yes',
                help = 'Inherit control',
                key = 1,
            },
            {
                text = 'No',
                help = 'Disable control by default',
                key = 2,
            },
        },
    },
}