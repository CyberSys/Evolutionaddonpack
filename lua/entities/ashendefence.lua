--[[
	Ashen Defence System
	Copyright (C) 2010 Madman07
]]--
if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ashen Defence System"
ENT.Author = "Madman07, Rafael De Jongh"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("entity_weapon_cat");
ENT.PrintName = Lib.Language.GetMessage("entity_asgard_ashen_def");
end

end

if SERVER then

AddCSLuaFile()

ENT.Sounds = {
	Shoot = Sound("weapons/aschen_fire.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/ashen_defence/ashen_defence.mdl");

	self.Entity:SetName("Ashen Defence System");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then
		phys:Wake();
	end

	if (WireAddon) then
		self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire [NORMAL]", "Active [NORMAL]", "Entity [ENTITY]"});
	end

	self.WireShoot = nil;
	self.WireEnt = nil;
	self.WireActive = nil;

	self.Bullets = {
		Attacker = self.Entity,
		Spread = Vector(0.01,0.01,0),
		Num = 1,
		Damage = 10,
		Force = 2,
		Tracer = 1,
	}

	self.Entity:SetMaxHealth(100);
	self.Entity:SetHealth(100);

	self.Destroyed = false;
	self:AddResource("energy",2000);
	self.energy_drain = 500

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
    /*
	local PropLimit = GetConVar("EAP_ashen_max"):GetInt()
	if(ply:GetCount("EAP_ashen")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Ashen Defence System limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end
    */
	ent = ents.Create("ashen_defence");
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("EAP_ashen", ent)
	return ent
end

-----------------------------------DIFFERENT CRAP----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Entity") then self.WireEnt = value;
	elseif (variable == "Fire") then self.WireShoot = value;
	elseif (variable == "Active") then self.WireActive = value;	end
end

function ENT:OnTakeDamage(dmginfo)

	local health = self.Entity:Health();
	if not self.Destroyed then
		health = health - dmginfo:GetDamage();
		self.Entity:SetHealth(health);

		if (health < 1) then
			self.Destroyed = true;

			local Effect = EffectData()
				Effect:SetRadius(20)
				Effect:SetOrigin(self.Entity:GetPos())
				Effect:SetStart(self.Entity:GetPos())
				Effect:SetMagnitude(100)
			util.Effect("Explosion", Effect)

			self.Entity:SetModel("models/Madman07/ashen_defence/ashen_defence_gib.mdl");
		end
	end

end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	local energy = self:GetResource("energy");
	local en = Lib.CFG:Get("ashen_defence","req_energy",true);

	if(energy > self.energy_drain or !self.HasRD or !en) then

		if (self.WireActive == 1 and not self.Destroyed) then

			local Target = self.WireEnt;
			if IsValid(Target) and (Target:IsPlayer() or Target:IsNPC()) then

				local ShootPos = self.Entity:GetPos() + self.Entity:GetUp()*5;
				local ShootDir = (Target:LocalToWorld(Target:OBBCenter()) - ShootPos):GetNormal();

				self.Bullets.Src = ShootPos;
				self.Bullets.Dir = ShootDir;

				local tracedata = {
					start = ShootPos,
					endpos = Target:GetPos(),
					filter = self.Entity,
				}
				local trace = util.TraceLine(tracedata);

				if IsValid(trace.Entity) and (trace.Entity == Target) then
					if (self.WireShoot == 1) then
						if (en) then
							self:ConsumeResource("energy",self.energy_drain);
						end
						self.Entity:FireBullets(self.Bullets);
						self.Entity:EmitSound(self.Sounds.Shoot,90,math.random(98,102));
						local fx = EffectData()
							fx:SetStart(ShootPos)
							fx:SetOrigin(Target:LocalToWorld(Target:OBBCenter()))
						util.Effect("redtracer", fx )
						util.ScreenShake(self:GetPos(),2,2.5,1,300);
					end
				end

			end

		end

	end

	self.Entity:NextThink(CurTime() + 0.5);
	return true
end

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntityID = self.Entity:EntIndex()
	end         /*
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end           */

	dupeInfo.Destroyed = self.Destroyed;

	duplicator.StoreEntityModifier(self, "AshenDupeInfo", dupeInfo)
	Lib.Wire.PreEntityCopy(self)
	Lib.RD.PreEntityCopy(self)
end
duplicator.RegisterEntityModifier( "AshenDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.AshenDupeInfo

	if dupeInfo.EntityID then
		self.Entity = CreatedEntities[ dupeInfo.EntityID ]
	end

	self.Destroyed = dupeInfo.Destroyed;
	if self.Destroyed then self.Entity:SetModel("models/Madman07/ashen_defence/ashen_defence_gib.mdl"); end

	self.Owner = ply;
	Lib.RD.PostEntityPaste(self,ply,Ent,CreatedEntities)
	Lib.Wire.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

end