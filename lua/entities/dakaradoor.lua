--[[
	Dakara Doors
	Copyright (C) 2011 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Dakara Doors"
ENT.Author = "Madman07"
ENT.Category = ""

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.AutomaticFrameAdvance = true

if SERVER then

AddCSLuaFile();

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Doors");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.CanDoAnim = true;
	self.Delay = 5;
	self.Sound = false;
	self.OpenSound = "";
	self.CloseSound = "";
	self.PlaybackRate = 1;
end

function ENT:Think()
	if not self.CanDoAnim then --run often only if doors are busy
		self:NextThink(CurTime());
		return true
	end
end

function ENT:Toggle()
	if self.CanDoAnim then
		self.CanDoAnim = false;
		timer.Create("Close"..self:EntIndex(),self.Delay,1,function() --How long until we can do the anim again?
			self.CanDoAnim = true;
		end);
		local shakepos = Vector(1,1,1);
		if (self.Type == 1) then
			shakepos = self.Parent:LocalToWorld(Vector(608, 105, 277));
			sound.Play( "dakara/dakara_door.wav", shakepos, 100, 100);
		elseif (self.Type == 2) then
			shakepos = self.Parent:LocalToWorld(Vector(550, 330, 277));
			sound.Play( "dakara/dakara_door.wav", shakepos, 100, 100);
		end
		util.ScreenShake(shakepos,2,6,4,400);
		self:SetPlaybackRate(self.PlaybackRate);
		if self.Open then
			self.Open = false;
			self:SetNotSolid(false);
			self:ResetSequence(self:LookupSequence("close")); -- play the sequence
		else
			self.Open = true;
			self:SetNotSolid(true);
			self:ResetSequence(self:LookupSequence("open")); -- play the sequence
		end
	end
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dakaradoor", Lib.EAP_GmodDuplicator, "Data" )
end

end