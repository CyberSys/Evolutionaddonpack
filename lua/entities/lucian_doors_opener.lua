/*
	Lucian Door Opener
	Copyright (C) 2015 Gmod4phun
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Lucian Door Opener"
ENT.Author = "Gmod4phun"
ENT.Category = ""

ENT.WireDebugName = "Lucian Door Opener"

ENT.AutomaticFrameAdvance = true

if CLIENT then

ENT.SpritePositions = {
    Vector(1.5,1.5,0.545),
	Vector(1.6,1.4,0.545),
	Vector(1.4,1.6,0.545),
	Vector(-1.5,1.5,0.545),
	Vector(-1.6,1.4,0.545),
	Vector(-1.4,1.6,0.545),
	Vector(1.5,-1.5,0.545),
	Vector(1.6,-1.4,0.545),
	Vector(1.4,-1.6,0.545),
	Vector(-1.5,-1.5,0.545),
	Vector(-1.6,-1.4,0.545),
	Vector(-1.4,-1.6,0.545),
}

ENT.SpriteColor = Color(255,0,0,255)
/*
function ENT:Initialize()
	self:SetPredictable(false)
end*/

function ENT:Draw()
    self:DrawModel();
	
	render.SetMaterial( Material("sprites/bluecore") )
	for i=1,table.Count(self.SpritePositions) do
		render.DrawSprite( self:LocalToWorld(self.SpritePositions[i]), 0.2, 0.2, self.Entity.SpriteColor )
	end
	
end

function ENT:OnRemove()
end

end

if SERVER then

AddCSLuaFile();

function ENT:Initialize()
	self.Entity:SetModel("models/gmod4phun/lucian_door_opener.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(ONOFF_USE)
	self.Entity.Attached = false
	self.Entity.SecondAttached = false
	self.Entity.TargetDoor = nil
	self.Entity.IsMain = nil
	self.CanUse = CurTime()
	self.GetTimer = 0
	self.Activator = NULL
end
/*
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("lucian_doors_opener");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(true) end

	return ent
end*/

function ENT:RemoveBothLDO()
	if IsValid(self.Entity) then
		self.Entity:Remove()
	end
	if IsValid(self.Entity) and IsValid(self.Entity.SecondLucianDevice) then
		self.Entity.SecondLucianDevice:Remove()
	end
	if IsValid(self.Entity) and IsValid(self.Entity.MainLDO) then
		self.Entity.MainLDO:Remove()
	end
end

function ENT:Use(activator,_,use)
	
	if self.CanUse>CurTime() then
		if (use==0) then
			self.GetTimer = 0
			self.Activator = NULL
		end
		return
	end

	if not IsValid(self.TargetDoor) then return end
	
	self.CanUse = CurTime()+2.5
	self.GetTimer = CurTime()+0.75
	self.Activator = activator
	
	/*if IsValid(self.Entity) and IsValid(self.Entity.TargetDoor) and activator:KeyDown(IN_WALK) then
		activator:Give("sgwp_lucian_doors_opener")
		self.Entity:RemoveBothLDO()
		return
	end*/

	if IsValid(self.Entity) and IsValid(self.Entity.TargetDoor) and !activator:KeyDown(IN_WALK) then
	
		if self.Entity.TargetDoor.Open != true and self.Entity.TargetDoor.CanDoAnim then
			self.Entity:EmitSound("npc/scanner/cbot_servoscared.wav",70,100)
			timer.Simple(0.7, function() if IsValid(self.Entity) and IsValid(self.Entity.TargetDoor) then self.Entity:EmitSound("npc/scanner/combat_scan4.wav",70,100) end end)
			timer.Simple(1.2, function() if IsValid(self.Entity) and IsValid(self.Entity.TargetDoor) then self.Entity.TargetDoor:Toggle() end end)
		end
		
		if self.Entity.TargetDoor.Open == true and self.Entity.TargetDoor.CanDoAnim then
			self.Entity.TargetDoor:Toggle()
		end
	
	end

end

function ENT:Touch(ent)
	
	if ent:GetClass() == "doors" and ent:GetModel() == "models/madman07/doors/dest_door.mdl" and ent.Attached != true then
		ent.Attached = true
		self.Entity.IsMain = true
		self.Entity.TargetDoor = ent
		self.Entity:SetPos(self.Entity.TargetDoor:LocalToWorld(Vector(0,0,0)))
		self.Entity:SetAngles(self.Entity.TargetDoor:LocalToWorldAngles(Angle(90,0,0)))
		self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self.Entity:FollowBone(self.Entity.TargetDoor, self.Entity.TargetDoor:LookupBone("RightLock"))
	--	constraint.Weld(self.Entity,self.Entity.TargetDoor,0,0,0,true)
		constraint.NoCollide(self.Entity,self.Entity.TargetDoor,0,0)
	end
	
	if ent:GetClass() == "doors_frame" and ent:GetModel() == "models/madman07/doors/dest_frame.mdl" and ent.Door.Attached != true then
		ent.Door.Attached = true
		self.Entity.IsMain = true
		self.Entity.TargetDoor = ent.Door
		self.Entity:SetPos(self.Entity.TargetDoor:LocalToWorld(Vector(0,0,0)))
		self.Entity:SetAngles(self.Entity.TargetDoor:LocalToWorldAngles(Angle(90,0,0)))
		self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self.Entity:FollowBone(self.Entity.TargetDoor, self.Entity.TargetDoor:LookupBone("RightLock"))
	--	constraint.Weld(self.Entity,self.Entity.TargetDoor,0,0,0,true)
		constraint.NoCollide(self.Entity,self.Entity.TargetDoor,0,0)
	end
	
end


function ENT:Think()

	if not IsValid(self.Entity.TargetDoor) then
		self:Remove()
		return
	end
	
	if (self.GetTimer!=0 and CurTime()-self.GetTimer>0) then
		local activator = self.Activator
		if (IsValid(activator)) then
			activator:Give("sgwp_lucian_doors_opener")
		end
		self:RemoveBothLDO()
		return
	end
	
	if self.Entity.TargetDoor.Attached and not self.Entity.SecondAttached and not self.Entity.TargetDoor.LucianProcessDone then
		local second = ents.Create("lucian_doors_opener");
		second:Spawn();
		second:Activate();
		self.Entity.SecondAttached = true
		second.MainLDO = self.Entity
		second.IsMain = false
		second.TargetDoor = self.Entity.TargetDoor
		second:SetPos(self.Entity.TargetDoor:LocalToWorld(Vector(0,0,0)))
		second:SetAngles(self.Entity.TargetDoor:LocalToWorldAngles(Angle(90,0,0)))
		second:SetCollisionGroup(COLLISION_GROUP_WORLD)
		second:FollowBone(self.Entity.TargetDoor, self.Entity.TargetDoor:LookupBone("LeftLock"))
	--	constraint.Weld(second,self.Entity.TargetDoor,0,0,0,true)
		constraint.NoCollide(second,self.Entity.TargetDoor,0,0)
		self.Entity.SecondLucianDevice = second
		self.Entity.SecondLucianDevice.Untouchable = true
		self.Entity.TargetDoor.LucianProcessDone = true
	end

	--if self.Entity.TargetDoor.Attached and self.Entity.TargetDoor.CanDoAnim then
		self.Entity:NextThink(CurTime());
	--end
	
end

function ENT:OnRemove()
	self.Entity.Attached = false
	self.Entity.SecondAttached = false
	
	if IsValid(self.Entity.TargetDoor) then
		self.Entity.TargetDoor.Attached = false
		self.Entity.TargetDoor.LucianProcessDone = false
		--self.Entity.TargetDoor.Attached = false
	end
	
	if IsValid(self.Entity.SecondLucianDevice) then
		self.Entity.SecondLucianDevice:Remove()
		self.Entity:Remove()
	end
	
	if IsValid(self.Entity) and IsValid(self.Entity.SecondLucianDevice) then
		self.Entity.SecondLucianDevice:Remove()
	end
	
	if IsValid(self.Entity) and IsValid(self.Entity.TargetDoor) and self.Entity.TargetDoor.Open == true then
		self.Entity.TargetDoor:Toggle()
	end
	
end

function ENT:PostEntityPaste() 
	self:Remove()
end

end