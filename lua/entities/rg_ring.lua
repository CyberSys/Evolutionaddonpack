ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Untouchable = true

if SERVER then

AddCSLuaFile()

ENT.EAP_NotSave = true
ENT.DoNotDuplicate = true 

function ENT:Initialize()

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	self.Phys=self.Entity:GetPhysicsObject()
	self.Phys:EnableCollisions(true)
	self.Phys:Wake()
	self.Phys:EnableMotion(true)

	self.Parent=self.Entity:GetParent()
	self.Entity:SetParent(nil)

	self.ReachedPos=true
	self.DesiredPos=self.Entity:GetPos()
	self.Return=true
	self.Ang=self.Entity:GetAngles()
	self.Entity:StartMotionController()
	self.Dir = self.Dir or 1;

	self.Entity:SetTrigger(true)

end

function ENT:PhysicsSimulate( phys, deltatime )
		if (not IsValid(self.Parent)) then return end
		phys:Wake()
		local pr={}
			pr.secondstoarrive	= 1
			local pos=self.Parent:LocalToWorld(self.DesiredPos)
			pr.pos			= pos
				if self.Return then
					if (self.Dir==-1) then
						pr.pos 	= self.Parent:GetPos()+Vector(0,0,15)
					else
						pr.pos 	= self.Parent:GetPos()
					end
				end
			pr.maxangular		= 5000
			pr.maxangulardamp	= 10000
			pr.maxspeed			= 10000
			pr.maxspeeddamp		= 100000
			pr.dampfactor		= 0.2
			if not self.Return and self.ReachedPos then
				pr.secondstoarrive	= 0.01
				pr.dampfactor		= 1
			end
			pr.teleportdistance	= 10000
			pr.angle			= self.Ang
			pr.deltatime		= deltatime
		phys:ComputeShadowControl(pr)
end

function ENT:StartTouch(ent)
	if not IsValid(ent) or ent.IsRings then return end

	local phys = ent:GetPhysicsObject()
	if (IsValid(phys) and not phys:IsMotionEnabled()) then
		constraint.NoCollide( self, ent, 0, 0 );
		phys:EnableMotion(true);
		phys:EnableMotion(false);
	end

	if ent:IsPlayer() and not self.ReachedPos then
		local velo = ent:GetVelocity();
		if velo == Vector(0,0,0) then ent:TakeDamage(1000, self.Entity) return end
		--ent:SetVelocity(-10*velo);
	end
end


function ENT:GotoPos(len)
	if not self or not self.Entity or not self.Entity:IsValid() then return end
	self.Return=false
	self.ReachedPos=false
	self.DesiredPos=len
end

function ENT:ReturnPos()
	if not self or not self.Entity or not self.Entity:IsValid() then return end
	self.Return=true
end

function ENT:Think()
	if (not IsValid(self.Parent)) then self:Remove() end
	if not self.ReachedPos then
		local pos=self.Parent:LocalToWorld(self.DesiredPos)
		if self.Entity:GetPos():Distance(pos)<10 then
			self.ReachedPos=true
			self.Parent:ReportReachedPos(self.Entity)
		end
	end
end

function ENT:ChangeMaterial()
	self.Entity:SetMaterial("Boba_Fett/rings/ori_ring_on");
	local e = self.Entity
	timer.Create("Ring"..self:EntIndex(), 1, 1, function()
		if IsValid(e) then e:SetMaterial(""); end
	end);
end

end

if CLIENT then

function ENT:Draw()
	self.Entity:DrawModel()
end

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
language.Add("ring_ring",Lib.Language.GetMessage("ring_kill"))
end

end