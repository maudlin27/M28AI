---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 02/12/2022 09:11
---
do --Per Balthazaar - encasing the code in do .... end means that you dont have to worry about using unique variables
    local M28OldProjectile = Projectile
    Projectile = Class(M28OldProjectile) {

        OnImpact = function(self, targetType, targetEntity)
            M28OldProjectile.OnImpact(self, targetType, targetEntity)

        end,
    }
end