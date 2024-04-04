AI = {
    Name = 'AI: M28',
    Version = '1',
    AIList = {
        {
            key = 'm28ai',
            name = '<LOC M28_0001>AI: M28',
            rating = 950,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.778,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aie',
            name = '<LOC M28_0002>AI: M28 Easy',
            rating = 750,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.778,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
    },
    CheatAIList = {
        {
            key = 'm28aicheat',
            name = '<LOC M28_0003>AIx: M28',
            rating = 900,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.778,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aiecheat',
            name = '<LOC M28_0004>AIx: M28 Easy',
            rating = 700,
            ratingCheatMultiplier = 1100.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 800.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.778,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
    },
}