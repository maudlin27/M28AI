AI = {
    Name = 'AI: M28',
    Version = '1',
    AIList = {
        {
            key = 'm28ai',
            name = 'AI: M28',
            rating = 1000,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aie',
            name = 'AI: M28 Easy',
            rating = 775,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
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
            name = 'AIx: M28',
            rating = 1000,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aiecheat',
            name = 'AIx: M28 Easy',
            rating = 775,
            ratingCheatMultiplier = 1100.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 800.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
    },
}