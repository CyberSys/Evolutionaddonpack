ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Adrenaline"
ENT.Author = "Gmod4phun, AlexALX"

if SERVER then

AddCSLuaFile()

function ENT:Initialize()
	self:SetModel("models/pg_props/pg_stargate/pg_shot.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	--self:SetCollisionGroup(COLLISION_GROUP_NONE)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end

    local ent = ents.Create("sg_adrenalineThrown")
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:OnTakeDamage(dmginfo)
	--self:GetPhysicsObject():AddVelocity(dmginfo:GetDamageForce() * 0.1)
end

function ENT:Touch(activator)
	if activator:IsPlayer() and not IsValid(activator:GetWeapon("eap_sg_adrenaline")) then
		activator:Give("eap_sg_adrenaline")
		activator:EmitSound("items/ammo_pickup.wav",100,100)
		self:Remove()
	end
end

function ENT:OnRemove()
	return false
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_adrenalineThrown", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

function ENT:Initialize()
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
end

end