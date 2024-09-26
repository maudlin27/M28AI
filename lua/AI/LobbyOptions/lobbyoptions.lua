---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 14/05/2023 19:14
---

AIOpts = {
    {
        default = 8,
        label = "<LOC lobui_0102>Unit Cap",
        help = "<LOC lobui_0103>Set the maximum number of units that can be in play",
        key = 'UnitCap',
        value_text = "<LOC lobui_0719>%s",
        value_help = "<LOC lobui_0171>%s units per player may be in play",
        values = { --By having values in this format, it means that FAF will record the value in ScenarioInfo.Options (not the key)
            '125','250', '375', '500', '625', '750', '875', '1000', '1250', '1500', '2000', '2500', '3000', '4000', '5000', '7500', '10000'
        },
    },
    {
        default = 11,
        label = "<LOC aisettings_0001>>AIx Cheat Multiplier",
        help = "<LOC aisettings_0002>Set the cheat multiplier for the cheating AIs.",
        key = 'CheatMult',
        value_text = "%s",
        value_help = "<LOC aisettings_0003>Cheat multiplier of %s",
        values = { --By having values in this format, it means that FAF will record the value in ScenarioInfo.Options (not the key)
            '0.5', '0.6', '0.7', '0.8', '0.9',
            '1.0', '1.1', '1.2', '1.3', '1.4', '1.5', '1.6', '1.7', '1.8', '1.9',
            '2.0', '2.1', '2.2', '2.3', '2.4', '2.5', '2.6', '2.7', '2.8', '2.9', '3.0', '3.1', '3.2', '3.3', '3.4', '3.5', '3.6', '3.7', '3.8', '3.9',
            '4.0', '4.1', '4.2', '4.3', '4.4', '4.5', '4.6', '4.7', '4.8', '4.9', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9',
            '6.0', '6.1', '6.2', '6.3', '6.4', '6.5', '6.6', '6.7', '6.8', '6.9', '7.0', '7.1', '7.2', '7.3', '7.4', '7.5', '7.6', '7.7', '7.8', '7.9',
            '8.0', '8.1', '8.2', '8.3', '8.4', '8.5', '8.6', '8.7', '8.8', '8.9', '9.0', '9.1', '9.2', '9.3', '9.4', '9.5', '9.6', '9.7', '9.8', '9.9',
            '10.0',
        },
    },
    {
        default = 11,
        label = "<LOC aisettings_0054>AIx Build Multiplier",
        help = "<LOC aisettings_0055>Set the build rate multiplier for the cheating AIs.",
        key = 'BuildMult',
        value_text = "%s",
        value_help = "<LOC aisettings_0056>Build multiplier of %s",
        values = { --By having values in this format, it means that FAF will record the value in ScenarioInfo.Options (not the key)
            '0.5', '0.6', '0.7', '0.8', '0.9',
            '1.0', '1.1', '1.2', '1.3', '1.4', '1.5', '1.6', '1.7', '1.8', '1.9',
            '2.0', '2.1', '2.2', '2.3', '2.4', '2.5', '2.6', '2.7', '2.8', '2.9', '3.0', '3.1', '3.2', '3.3', '3.4', '3.5', '3.6', '3.7', '3.8', '3.9',
            '4.0', '4.1', '4.2', '4.3', '4.4', '4.5', '4.6', '4.7', '4.8', '4.9', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9',
            '6.0', '6.1', '6.2', '6.3', '6.4', '6.5', '6.6', '6.7', '6.8', '6.9', '7.0', '7.1', '7.2', '7.3', '7.4', '7.5', '7.6', '7.7', '7.8', '7.9',
            '8.0', '8.1', '8.2', '8.3', '8.4', '8.5', '8.6', '8.7', '8.8', '8.9', '9.0', '9.1', '9.2', '9.3', '9.4', '9.5', '9.6', '9.7', '9.8', '9.9',
            '10.0',
        },
    },
    {
        default = 9,
        label = "M28AIx Overwhelm rate",
        help = "Adjust M28AIx build and cheat modifiers by this amount periodically (0.0 to disable)",
        key = 'M28OvwR',
        value_text = "%s",
        value_help = "Amount to change the cheat modifiers by",
        values = { --By having values in this format, it means that FAF will record the value in ScenarioInfo.Options (not the key)
            '-0.5', '-0.4', '-0.3', '-0.2', '-0.1', '-0.05', '-0.02', '-0.01',
            '0.0', '0.01', '0.02', '0.05', '0.1', '0.2', '0.3', '0.4', '0.5',
        },
    },
    {
        default = 16,
        label = "M28AIx Overwhelm interval",
        help = "Time in minutes between each AIx overwhelm adjustment",
        key = 'M28OvwT',
        value_text = "%s",
        value_help = "Minutes between each change",
        values = { --By having values in this format, it means that FAF will record the value in ScenarioInfo.Options (not the key)
            '0.5', '1', '2', '3', '4', '5',
            '6', '7', '8', '9', '10',
            '11', '12', '13', '14', '15',
            '20', '25', '30', '35', '40',
            '45', '50', '55', '60',
        },
    },
    {
        default = 11,
        label = "M28AIx Overwhelm limit",
        help = "Stops changing the AIx overwhelm modifier once this AIx modifier is reached",
        key = 'M28OvwC',
        value_text = "%s",
        value_help = "Resource and build multiplier limit",
        values = { --By having values in this format, it means that FAF will record the value in ScenarioInfo.Options (not the key)
            '0.5', '0.6', '0.7', '0.8', '0.9',
            '1.0', '1.1', '1.2', '1.3', '1.4', '1.5', '1.6', '1.7', '1.8', '1.9',
            '2.0', '2.1', '2.2', '2.3', '2.4', '2.5', '2.6', '2.7', '2.8', '2.9', '3.0', '3.1', '3.2', '3.3', '3.4', '3.5', '3.6', '3.7', '3.8', '3.9',
            '4.0', '4.1', '4.2', '4.3', '4.4', '4.5', '4.6', '4.7', '4.8', '4.9', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9',
            '6.0', '6.1', '6.2', '6.3', '6.4', '6.5', '6.6', '6.7', '6.8', '6.9', '7.0', '7.1', '7.2', '7.3', '7.4', '7.5', '7.6', '7.7', '7.8', '7.9',
            '8.0', '8.1', '8.2', '8.3', '8.4', '8.5', '8.6', '8.7', '8.8', '8.9', '9.0', '9.1', '9.2', '9.3', '9.4', '9.5', '9.6', '9.7', '9.8', '9.9',
            '10.0',
        },
    },
    {
        default = 1,
        label = "M28 Coop: Use M28 AI?",
        help = "Apply M28 to non-player AIs in campaign missions (you may also want to enable cheats to allow the option of killing objective units stuck off-map)",
        key = 'CampAI', --refer to this with ScenarioInfo.Options.CampAI, which will return the key value below
        value_text = "",
        value_help = "Which AI to apply M28 to",
        values = {
            { --By having values in table like this, it means that FAF will record the key in ScenarioInfo.Options (not the text)
                text = 'None (i.e. only M28 players)',
                help = 'None (i.e. only M28 players)',
                key = 1,
            },
            {
                text = 'Allied AI Only',
                help = 'Allied AI Only',
                key = 2,
            },
            {
                text = 'Enemy AI Only',
                help = 'Enemy AI Only',
                key = 3,
            },
            {
                text = 'Allied and Enemy AI',
                help = 'Allied and Enemy AI',
                key = 4,
            },
        },
    },
    {
        default = 9,
        label = "M28 Coop: Hostile combat delay",
        help = "If M28 is being used for enemy campaign AI, this delays when M28 will try to attack",
        key = 'CmpAIDelay', --refer to this with ScenarioInfo.Options.CmpAIDelay, which will return the key value below; relevant for brains where aiBrain.HostileCampaignAI is true
        value_text = "%s",
        value_help = "Delay (if any) in seconds to apply",
        values = { --By having values in this format, it means that FAF will record the value in ScenarioInfo.Options (not the key)
            '0','30','60','90','120',
            '150', '180', '240', '300', '360', '420', '480', '540', '600',
            '720', '900', '1080', '1200', '1800', '2400', '3000', '3600',
        },
    },
    {
        default = 2,
        label = "M28 Coop: Use AIx modifiers?",
        help = "If M28 is being applied to hostile and/or allied campaign AI, this gives them the AIx build rate and resource rate modifiers specified in game options",
        key = 'CmApplyAIx',
        value_text = "",
        value_help = "Apply AIx Resource and build rate to campaign AI?",
        values = {
            { --By having values in table like this, it means that FAF will record the key in ScenarioInfo.Options (not the text)
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
    },
    {
        default = 2,
        label = "M28 Coop: Use M28Easy?",
        help = "If M28 is being applied to hostile and/or allied campaign AI, this makes them use M28Easy logic (which disables most micro used by M28)",
        key = 'CmM28Easy',
        value_text = "",
        value_help = "Use M28Easy logic, disabling most micro?",
        values = {
            { --By having values in table like this, it means that FAF will record the key in ScenarioInfo.Options (not the text)
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
    },
    {
        default = 1,
        label = "M28 time between orders",
        help = "Minimum number of seconds between orders for most units (e.g. makes M28 kiting significantly weaker).  Doesnt affect certain microing",
        key = 'M28TimeBetweenOrders',
        value_text = "%s",
        value_help = "Seconds between orders",
        values = { --By having values in this format, it means that FAF will record the value in ScenarioInfo.Options (not the key)
            '1.0', '1.1', '1.2', '1.3', '1.4', '1.5',
            '2.0', '2.5', '3.0', '3.5', '4.0', '5.0',
            '6.0', '7.0', '8.0', '9.0', '10.0'
        },
    },
    {
        default = 1,
        label = "M28: Prioritise stronger units?",
        help = 'By default M28 will always build certain T1-T3 land units over others (e.g. bricks instead of loyalists after a few have been built); disabling this should increase variety of units built',
        key = 'M28PrioritiseBPs',
        value_text = "",
        value_help = "Apply land unit prioritisation?",
        values = {
            { --By having values in table like this, it means that FAF will record the key in ScenarioInfo.Options (not the text)
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
        value_text = "",
        value_help = "Dodge slow moving shots?",
        values = {
            { --By having values in table like this, it means that FAF will record the key in ScenarioInfo.Options (not the text)
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
        value_text = "",
        value_help = "Allow M28 to take control of certain units?",
        values = {
            { --By having values in table like this, it means that FAF will record the key in ScenarioInfo.Options (not the text)
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
        },
    },
    {
        default = 2,
        label = "M28: CA Inherit constructing unit status?",
        help = 'If combined armies are enabled, this determines whether units starting control will be based on their parent/constructing unit',
        key = 'M28CAInherit',
        value_text = "",
        value_help = "M28AI will by default control units built by M28AI controlled shared army units",
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