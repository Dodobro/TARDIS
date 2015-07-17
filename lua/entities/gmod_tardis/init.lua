AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction( ply, tr, ClassName )
	if (  !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	local ang=Angle(0, (ply:GetPos()-SpawnPos):Angle().y, 0)
	ent:SetAngles( ang )
	ent:SetCreator( ply )
	ent:Spawn()
	ent:Activate()
	return ent
end

util.AddNetworkString("TARDIS-Initialize")
net.Receive("TARDIS-Initialize", function(len,ply)
	local ext=net.ReadEntity()
	if IsValid(ext) then
		net.Start("TARDIS-Initialize")
			net.WriteEntity(ext)
			net.WriteEntity(ext.interior)
			net.WriteEntity(ext:GetCreator())
		net.Send(ply)
		ext:SendData(ply)
	end
end)
function ENT:Initialize()
	self:SetModel( "models/drmatt/tardis/exterior/exterior.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_NORMAL )
	self:SetUseType( SIMPLE_USE )
	
	self.phys = self:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
	end
	
	self:SetBodygroup(1,1) -- Sticker
	self:SetBodygroup(2,1) -- Lit sign
	
	self.occupants={}
	
	self:CallHook("Initialize")
end

function ENT:PhysicsUpdate(ph)
	self:CallHook("PhysicsUpdate", ph)
end

function ENT:Think()
	for k,v in pairs(self.occupants) do
		if not k or not IsValid(k) then
			self.occupants[k]=nil
		end
	end
	
	self:CallHook("Think")
end