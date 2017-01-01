--[[
	Doors
	Copyright (C) 2011 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Cap Doors"
ENT.Author = "Madman07"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.AutomaticFrameAdvance = true

ENT.Untouchable = true

if SERVER then

AddCSLuaFile();

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Doors");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.CanDoAnim = true;
	self.Delay = 2.5;
	self.Sound = false;
	self.OpenSound = "";
	self.CloseSound = "";
	self.PlaybackRate = 1;
	self.Shake = false;
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
		if self.Shake then util.ScreenShake(self:GetPos(),2,6,4,400); end
		self:SetPlaybackRate(self.PlaybackRate);
		if self.Open then
			self.Open = false;
			self:SetNotSolid(false);
			self:ResetSequence(self:LookupSequence("close")); -- play the sequence
			if self.Sound then
				self:EmitSound(self.CloseSound,100,math.random(90,110));
			end
		else
			self.Open = true;
			self:SetNotSolid(true);
			self:ResetSequence(self:LookupSequence("open")); -- play the sequence
			if self.Sound then
				self:EmitSound(self.OpenSound,100,math.random(90,110));
			end
		end
	end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if IsValid(self.Frame) then
		dupeInfo.EntIDFrame = self.Frame:EntIndex()
		if WireAddon then
			dupeInfo.WireData = WireLib.BuildDupeInfo( self.Frame )
		end
	end

	dupeInfo.DoorModel = self.Frame.DoorModel;

	duplicator.StoreEntityModifier(self, "DupeInfo", dupeInfo)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.DupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end
	if dupeInfo.EntID then
		self.Frame = CreatedEntities[ dupeInfo.EntIDFrame ]
	end

	if (IsValid(self.Frame)) then
		self.Frame.DoorModel = dupeInfo.DoorModel;
	end

	if(WireAddon and Ent.EntityMods and Ent.EntityMods.DupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.DupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "doors", Lib.EAP_GmodDuplicator, "Data" )
end

end