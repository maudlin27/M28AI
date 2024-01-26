AI = {
    Name = 'AI: M28',
    Version = '1',
    AIList = {
        {
            key = 'm28ai',
            name = '<LOC M28_0001>AI: M28',
            rating = 750,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.8,   -- 5x5
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
            rating = -2250,
            ratingCheatMultiplier = 1700.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1300.0,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.8,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
    },
}