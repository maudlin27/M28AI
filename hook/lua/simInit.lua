
local M28Map = import('/mods/M28AI/lua/AI/M28Map.lua')

--Approach of hooking to get around adaptive map issues is based on Softels DilliDalli AI - alternative is using CanBuildStructureAt to check, but that runs into issues if the resource point has reclaim on it
local M28OldCreateResourceDeposit = CreateResourceDeposit
CreateResourceDeposit = function(t,x,y,z,size)
    M28Map.RecordResourcePoint(t,x,y,z,size)
    M28OldCreateResourceDeposit(t,x,y,z,size)
end