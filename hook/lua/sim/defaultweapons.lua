---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 02/12/2022 09:10
---
--WARNING: CAREFUL with below hooks - caused spamming of error messages when T1 arti fired despite the event code being commented out
local M28Events = import('/mods/M28AI/lua/AI/M28Events.lua')

M28DefaultProjectileWeapon = DefaultProjectileWeapon

DefaultProjectileWeapon = Class(M28DefaultProjectileWeapon) {
    OnWeaponFired = function(self)
        M28DefaultProjectileWeapon.OnWeaponFired(self)
        M28Events.OnWeaponFired(self)
    end,
    CalculateBallisticAcceleration = function(self, projectile)
        ForkThread(M28Events.OnBombFired, self, projectile)
        return M28DefaultProjectileWeapon.CalculateBallisticAcceleration(self, projectile)
    end,
    CreateProjectileAtMuzzle = function(self, muzzle)
        ForkThread(M28Events.OnWeaponFired, self)
        return M28DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
    end,
}