---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by maudlin27.
--- DateTime: 02/12/2022 09:13
---
local M28Events = import('/mods/M28AI/lua/AI/M28Events.lua')

do --Per Balthazaar - encasing the code in do .... end means that you dont have to worry about using unique variables
    if false then --ORIG FAF HOOKS FROM V102 BEFORE LOUD COMPATIBILITY
        local M28OldUnit = Unit
        Unit = Class(M28OldUnit) {
            OnKilled = function(self, instigator, type, overkillRatio) --NOTE: For some reason this doesnt run a lot of the time; onkilledunit is more reliable
                M28Events.OnKilled(self, instigator, type, overkillRatio)
                M28OldUnit.OnKilled(self, instigator, type, overkillRatio)
            end,
            OnReclaimed = function(self, reclaimer)
                M28Events.OnKilled(self, reclaimer)
                M28OldUnit.OnReclaimed(self, reclaimer)
            end,
            OnDecayed = function(self)
                --LOG('OnDecayed: Time='..GetGameTimeSeconds()..'; self.UnitId='..(self.UnitId or 'nil'))
                M28Events.OnUnitDeath(self)
                M28OldUnit.OnDecayed(self)
            end,
            OnKilledUnit = function(self, unitKilled, massKilled)
                M28Events.OnKilled(unitKilled, self)
                M28OldUnit.OnKilledUnit(self, unitKilled, massKilled)
            end,
            --[[OnFailedToBeBuilt = function(self)
                LOG('OnFailedToBeBuilt: Time='..GetGameTimeSeconds()..'; self.UnitId='..(self.UnitId or 'nil'))
                M28OldUnit.OnFailedToBeBuilt(self)
            end,--]]
            OnDestroy = function(self)
                M28Events.OnUnitDeath(self) --Any custom code we want to run
                M28OldUnit.OnDestroy(self) --Normal code
            end,
            --[[OnWorkEnd = function(self, work)
                M28Events.OnWorkEnd(self, work)
                M28OldUnit.OnWorkEnd(self, work)
            end,--]]
            OnDamage = function(self, instigator, amount, vector, damageType)
                M28OldUnit.OnDamage(self, instigator, amount, vector, damageType)
                M28Events.OnDamaged(self, instigator) --Want this after just incase our code messes things up
            end,
            OnSiloBuildEnd = function(self, weapon)
                M28OldUnit.OnSiloBuildEnd(self, weapon)
                M28Events.OnMissileBuilt(self, weapon)
            end,
            OnStartBuild = function(self, built, order, ...)
                ForkThread(M28Events.OnConstructionStarted, self, built, order)
                return M28OldUnit.OnStartBuild(self, built, order, unpack(arg))
            end,
            OnStartReclaim = function(self, target)
                ForkThread(M28Events.OnReclaimStarted, self, target)
                return M28OldUnit.OnStartReclaim(self, target)
            end,
            OnStopReclaim = function(self, target)
                ForkThread(M28Events.OnReclaimFinished, self, target)
                return M28OldUnit.OnStopReclaim(self, target)
            end,

            OnStopBuild = function(self, unit)
                if unit and not(unit.Dead) and unit.GetFractionComplete and unit:GetFractionComplete() == 1 then
                    ForkThread(M28Events.OnConstructed, self, unit)
                end
                return M28OldUnit.OnStopBuild(self, unit)
            end,

            OnAttachedToTransport = function(self, transport, bone)
                ForkThread(M28Events.OnTransportLoad, self, transport, bone)
                return M28OldUnit.OnAttachedToTransport(self, transport, bone)
            end,
            OnDetachedFromTransport = function(self, transport, bone)
                ForkThread(M28Events.OnTransportUnload, self, transport, bone)
                return M28OldUnit.OnDetachedFromTransport(self, transport, bone)
            end,
            OnDetectedBy = function(self, index)

                ForkThread(M28Events.OnDetectedBy, self, index)
                return M28OldUnit.OnDetectedBy(self, index)
            end,
            OnCreate = function(self)
                M28OldUnit.OnCreate(self)
                ForkThread(M28Events.OnCreate, self)
            end,
            CreateEnhancement = function(self, enh)
                ForkThread(M28Events.OnEnhancementComplete, self, enh)
                return M28OldUnit.CreateEnhancement(self, enh)
            end,
            OnMissileImpactTerrain = function(self, target, position)
                ForkThread(M28Events.OnMissileImpactTerrain, self, target, position)
                return M28OldUnit.OnMissileImpactTerrain(self, target, position)
            end,
            OnMissileIntercepted = function(self, target, defense, position)
                ForkThread(M28Events.OnMissileIntercepted, self, target, defense, position)
                return M28OldUnit.OnMissileIntercepted(self, target, defense, position)
            end,
            OnTeleportUnit = function(self, teleporter, location, orientation)
                ForkThread(M28Events.OnTeleportComplete, self, teleporter, location, orientation)
                return M28OldUnit.OnTeleportUnit(self, teleporter, location, orientation)
            end,
            InitiateTeleportThread = function(self, teleporter, location, orientation)
                ForkThread(M28Events.OnStartTeleport, self, teleporter, location, orientation)
                return M28OldUnit.InitiateTeleportThread(self, teleporter, location, orientation)
            end,
        }
    end
    if false then --ORIG HOOKS THAT APPEARED TO WORK IN v103 FOR LOUD AND FAF, BUT WHICH CAUSED ISSUES WITH SKIRMISH
        local M28OldUnit = Unit
        Unit = Class(M28OldUnit) {
            OnCreate = function(self)
                --LOG('M28OnCreate triggering from unit.lua')
                ForkThread(M28Events.OnCreate, self)
                if M28OldUnit.OnCreate then M28OldUnit.OnCreate(self) end
            end,
            OnKilled = function(self, instigator, type, overkillRatio) --NOTE: For some reason this doesnt run a lot of the time; onkilledunit is more reliable
                --LOG('M28OnKilled triggering from unit.lua, self='..(self.UnitId or 'nil'))
                if M28OldUnit.OnKilled then M28OldUnit.OnKilled(self, instigator, type, overkillRatio) end
                --LOG('M28OnKilled about to call M28Events.OnKilled now')
                M28Events.OnKilled(self, instigator, type, overkillRatio)
            end,
            OnReclaimed = function(self, reclaimer)
                --LOG('M28OnReclaimed triggering from unit.lua')
                M28Events.OnKilled(self, reclaimer)
                if M28OldUnit.OnReclaimed then M28OldUnit.OnReclaimed(self, reclaimer) end
            end,
            OnDecayed = function(self)
                --LOG('M28OnDecayed triggering from unit.lua, Time='..GetGameTimeSeconds()..'; self.UnitId='..(self.UnitId or 'nil'))
                M28Events.OnUnitDeath(self)
                if M28OldUnit.OnDecayed then M28OldUnit.OnDecayed(self) end
            end,
            OnKilledUnit = function(self, unitKilled, massKilled)
                --LOG('M28OnKilledUnit triggering from unit.lua, self.UnitId='..(self.UnitId or 'nil'))
                M28Events.OnKilled(unitKilled, self)
                if M28OldUnit.OnKilled then M28OldUnit.OnKilledUnit(self, unitKilled, massKilled) end
            end,
            --[[OnFailedToBeBuilt = function(self)
                --LOG('OnFailedToBeBuilt: Time='..GetGameTimeSeconds()..'; self.UnitId='..(self.UnitId or 'nil'))
                M28OldUnit.OnFailedToBeBuilt(self)
            end,--]]
            OnDestroy = function(self)
                --LOG('M28OnDestroy triggering from unit.lua')
                M28Events.OnUnitDeath(self) --Any custom code we want to run
                if M28OldUnit.OnUnitDeath then M28OldUnit.OnDestroy(self) end --Normal code
            end,
            --[[OnWorkEnd = function(self, work)
                M28Events.OnWorkEnd(self, work)
                M28OldUnit.OnWorkEnd(self, work)
            end,--]]
            OnDamage = function(self, instigator, amount, vector, damageType)
                --LOG('M28OnDamage triggering from unit.lua')
                if M28OldUnit.OnDamage then M28OldUnit.OnDamage(self, instigator, amount, vector, damageType) end
                M28Events.OnDamaged(self, instigator) --Want this after just incase our code messes things up
            end,
            OnSiloBuildEnd = function(self, weapon)
                --LOG('M28OnSiloBuildEnd triggering from unit.lua')
                if M28OldUnit.OnSiloBuildEnd then M28OldUnit.OnSiloBuildEnd(self, weapon) end
                M28Events.OnMissileBuilt(self, weapon)
            end,
            OnStartBuild = function(self, built, order, ...)
                --LOG('M28OnStartBuild triggering from unit.lua')
                ForkThread(M28Events.OnConstructionStarted, self, built, order)
                if M28OldUnit.OnStartBuild then return M28OldUnit.OnStartBuild(self, built, order, unpack(arg)) end
            end,

            OnStopBuild = function(self, unit)
                --LOG('M28OnStopBuild triggering from unit.lua')
                if unit and not(unit.Dead) and unit.GetFractionComplete and unit:GetFractionComplete() == 1 then
                    ForkThread(M28Events.OnConstructed, self, unit)
                end
                if M28OldUnit.OnStopBuild then return M28OldUnit.OnStopBuild(self, unit) end
            end,

            OnTransportAttach = function(self, attachBone, unit) --LOUD specific function
                --LOG('M28OnTransportAttach triggering from unit.lua')
                ForkThread(M28Events.OnTransportLoad, self, unit, attachBone)
                if M28OldUnit.OnTransportAttach then
                    return M28OldUnit.OnTransportAttach(self, attachBone, unit)
                end
            end,
            OnTransportDetach = function(self, attachBone, unit) --LOUD specific function
                --LOG('M28OOnTransportDetach triggering from unit.lua')
                ForkThread(M28Events.OnTransportUnload, self, unit, attachBone)
                if M28OldUnit.OnTransportDetach then
                    return M28OldUnit.OnTransportDetach(self, attachBone, unit)
                end
            end,

            OnDetectedBy = function(self, index) --cant see this in FAF or LOUD :s
                --LOG('M28OnDetectedBy triggering from unit.lua')
                ForkThread(M28Events.OnDetectedBy, self, index)
                if M28OldUnit.OnDetectedBy then
                    return M28OldUnit.OnDetectedBy(self, index)
                end
            end,
            CreateEnhancement = function(self, enh)
                --LOG('M28OnCreateEnhancement triggering from unit.lua')
                ForkThread(M28Events.OnEnhancementComplete, self, enh)
                if M28OldUnit.CreateEnhancement then
                    return M28OldUnit.CreateEnhancement(self, enh)
                end
            end,

            OnTeleportUnit = function(self, teleporter, location, orientation)
                --LOG('M28OnTeleportUnit triggering from unit.lua')
                ForkThread(M28Events.OnTeleportComplete, self, teleporter, location, orientation)
                if M28OldUnit.OnTeleportUnit then
                    return M28OldUnit.OnTeleportUnit(self, teleporter, location, orientation)
                end
            end,
            InitiateTeleportThread = function(self, teleporter, location, orientation)
                --LOG('M28InitiateTeleportThread triggering from unit.lua')
                ForkThread(M28Events.OnStartTeleport, self, teleporter, location, orientation)
                if M28OldUnit.InitiateTeleportThread then
                    return M28OldUnit.InitiateTeleportThread(self, teleporter, location, orientation)
                end
            end,


            --The following arent in LOUD's unit.lua:
            OnStartReclaim = function(self, target)
                --LOG('M28OnStartReclaim triggering from unit.lua')
                ForkThread(M28Events.OnReclaimStarted, self, target)
                if M28OldUnit.OnStartReclaim then return M28OldUnit.OnStartReclaim(self, target) end
            end,
            OnStopReclaim = function(self, target)
                --LOG('M28OnStopReclaim triggering from unit.lua')
                ForkThread(M28Events.OnReclaimFinished, self, target)
                if M28OldUnit.OnStopReclaim then return M28OldUnit.OnStopReclaim(self, target) end
            end,
            OnAttachedToTransport = function(self, transport, bone)
                --LOG('M28OnAttachedToTransport triggering from unit.lua')
                ForkThread(M28Events.OnTransportLoad, self, transport, bone)
                if M28OldUnit.OnAttachedToTransport then
                    if M28OldUnit.OnAttachedToTransport then return M28OldUnit.OnAttachedToTransport(self, transport, bone) end
                end
            end,
            OnDetachedFromTransport = function(self, transport, bone)
                --LOG('M28OnDetachedFromTransport triggering from unit.lua')
                ForkThread(M28Events.OnTransportUnload, self, transport, bone)
                if M28OldUnit.OnDetachedFromTransport then return M28OldUnit.OnDetachedFromTransport(self, transport, bone) end
            end,
            OnMissileImpactTerrain = function(self, target, position)
                --LOG('M28OnMissileImpactTerrain triggering from unit.lua')
                ForkThread(M28Events.OnMissileImpactTerrain, self, target, position)
                if M28OldUnit.OnMissileImpactTerrain then return M28OldUnit.OnMissileImpactTerrain(self, target, position) end
            end,
            OnMissileIntercepted = function(self, target, defense, position)
                --LOG('M28OnMissileIntercepted triggering from unit.lua')
                ForkThread(M28Events.OnMissileIntercepted, self, target, defense, position)
                if M28OldUnit.OnMissileIntercepted then return M28OldUnit.OnMissileIntercepted(self, target, defense, position) end
            end,
        }
    end
    --REVISED HOOKS FOR v104 WHICH APPEAR TO WORK FOR BOTH FAF AND LOUD:
    local M28OldUnit = Unit
    Unit = Class(M28OldUnit) {
        OnKilled = function(self, instigator, type, overkillRatio) --NOTE: For some reason this doesnt run a lot of the time; onkilledunit is more reliable
            M28Events.OnKilled(self, instigator, type, overkillRatio)
            if M28OldUnit.OnKilled then M28OldUnit.OnKilled(self, instigator, type, overkillRatio) end
        end,
        OnReclaimed = function(self, reclaimer)
            M28Events.OnKilled(self, reclaimer)
            if M28OldUnit.OnReclaimed then M28OldUnit.OnReclaimed(self, reclaimer) end
        end,
        OnDecayed = function(self)
            --LOG('OnDecayed: Time='..GetGameTimeSeconds()..'; self.UnitId='..(self.UnitId or 'nil'))
            M28Events.OnUnitDeath(self)
            if M28OldUnit.OnDecayed then M28OldUnit.OnDecayed(self) end
        end,
        OnKilledUnit = function(self, unitKilled, massKilled)
            M28Events.OnKilled(unitKilled, self)
            if M28OldUnit.OnKilledUnit then M28OldUnit.OnKilledUnit(self, unitKilled, massKilled) end
        end,
        --[[OnFailedToBeBuilt = function(self)
            LOG('OnFailedToBeBuilt: Time='..GetGameTimeSeconds()..'; self.UnitId='..(self.UnitId or 'nil'))
            M28OldUnit.OnFailedToBeBuilt(self)
        end,--]]
        OnDestroy = function(self)
            M28Events.OnUnitDeath(self) --Any custom code we want to run
            if M28OldUnit.OnDestroy then M28OldUnit.OnDestroy(self) end --Normal code end
        end,
        --[[OnWorkEnd = function(self, work)
            M28Events.OnWorkEnd(self, work)
            M28OldUnit.OnWorkEnd(self, work)
        end,--]]
        OnDamage = function(self, instigator, amount, vector, damageType)
            M28OldUnit.OnDamage(self, instigator, amount, vector, damageType)
            if M28OldUnit.OnDamaged then M28Events.OnDamaged(self, instigator) end --Want this after just incase our code messes things up
        end,
        OnSiloBuildEnd = function(self, weapon)
            M28OldUnit.OnSiloBuildEnd(self, weapon)
            if M28OldUnit.OnMissileBuilt then M28Events.OnMissileBuilt(self, weapon) end
        end,
        OnStartBuild = function(self, built, order, ...)
            ForkThread(M28Events.OnConstructionStarted, self, built, order)
            if M28OldUnit.OnStartBuild then return M28OldUnit.OnStartBuild(self, built, order, unpack(arg)) end
        end,
        OnStartReclaim = function(self, target)
            ForkThread(M28Events.OnReclaimStarted, self, target)
            if M28OldUnit.OnStartReclaim then return M28OldUnit.OnStartReclaim(self, target) end
        end,
        OnStopReclaim = function(self, target)
            ForkThread(M28Events.OnReclaimFinished, self, target)
            if M28OldUnit.OnStopReclaim then return M28OldUnit.OnStopReclaim(self, target) end
        end,

        OnStopBuild = function(self, unit)
            if unit and not(unit.Dead) and unit.GetFractionComplete and unit:GetFractionComplete() == 1 then
                ForkThread(M28Events.OnConstructed, self, unit)
            end
            if M28OldUnit.OnStopBuild then return M28OldUnit.OnStopBuild(self, unit) end
        end,

        OnAttachedToTransport = function(self, transport, bone)
            ForkThread(M28Events.OnTransportLoad, self, transport, bone)
            if M28OldUnit.OnAttachedToTransport then return M28OldUnit.OnAttachedToTransport(self, transport, bone) end
        end,
        OnDetachedFromTransport = function(self, transport, bone)
            ForkThread(M28Events.OnTransportUnload, self, transport, bone)
            if M28OldUnit.OnDetachedFromTransport then return M28OldUnit.OnDetachedFromTransport(self, transport, bone) end
        end,
        OnDetectedBy = function(self, index)

            ForkThread(M28Events.OnDetectedBy, self, index)
            if M28OldUnit.OnDetectedBy then return M28OldUnit.OnDetectedBy(self, index) end
        end,
        OnCreate = function(self)
            M28OldUnit.OnCreate(self)
            if M28OldUnit.OnCreate then ForkThread(M28Events.OnCreate, self) end
        end,
        CreateEnhancement = function(self, enh)
            ForkThread(M28Events.OnEnhancementComplete, self, enh)
            if M28OldUnit.OnEnhancementComplete then return M28OldUnit.CreateEnhancement(self, enh) end
        end,
        OnMissileImpactTerrain = function(self, target, position)
            ForkThread(M28Events.OnMissileImpactTerrain, self, target, position)
            if M28OldUnit.OnMissilbeImpactTerrain then return M28OldUnit.OnMissileImpactTerrain(self, target, position) end
        end,
        OnMissileIntercepted = function(self, target, defense, position)
            ForkThread(M28Events.OnMissileIntercepted, self, target, defense, position)
            if M28OldUnit.OnMissileIntercepted then return M28OldUnit.OnMissileIntercepted(self, target, defense, position) end
        end,
        OnTeleportUnit = function(self, teleporter, location, orientation)
            ForkThread(M28Events.OnTeleportComplete, self, teleporter, location, orientation)
            if M28OldUnit.OnTeleportUnit then return M28OldUnit.OnTeleportUnit(self, teleporter, location, orientation) end
        end,
        InitiateTeleportThread = function(self, teleporter, location, orientation)
            ForkThread(M28Events.OnStartTeleport, self, teleporter, location, orientation)
            if M28OldUnit.InitiateTeleportThread then return M28OldUnit.InitiateTeleportThread(self, teleporter, location, orientation) end
        end,
    }

end


--Hooks not used:
--[[CreateEnhancementEffects = function(self, enhancement)
            local bp = self:GetBlueprint().Enhancements[enhancement]
            local effects = TrashBag()
            local bpTime = bp.BuildTime
            local bpBuildCostEnergy = bp.BuildCostEnergy
            if bpTime == nil then LOG('ERROR: CreateEnhancementEffects: bp.bpTime is nil; bp='..self:GetBlueprint().BlueprintId)
                bpTime = 1 end --Avoid infinite loop
            if bpBuildCostEnergy == nil then
                --LOG('ERROR: CreateEnhancementEffects: bp.BuildCostEnergy is nil; bp='..self:GetBlueprint().BlueprintId)
                bpBuildCostEnergy = 1 end
            local scale = math.min(4, math.max(1, (bpBuildCostEnergy / bpTime or 1) / 50))

            if bp.UpgradeEffectBones then
                for _, v in bp.UpgradeEffectBones do
                    if self:IsValidBone(v) then
                        EffectUtilities.CreateEnhancementEffectAtBone(self, v, self.UpgradeEffectsBag)
                    end
                end
            end

            if bp.UpgradeUnitAmbientBones then
                for _, v in bp.UpgradeUnitAmbientBones do
                    if self:IsValidBone(v) then
                        EffectUtilities.CreateEnhancementUnitAmbient(self, v, self.UpgradeEffectsBag)
                    end
                end
            end

            for _, e in effects do
                e:ScaleEmitter(scale)
                self.UpgradeEffectsBag:Add(e)
            end
        end, ]]--