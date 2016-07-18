--[[
	Jamming Device
	Copyright (C) 2010 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Jamming Device"
ENT.Author			= "Madman07"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Category		= "Stargate Carter Addon Pack"

ENT.Spawnable	= false
ENT.AdminSpawnable = false
ENT.CapJammingDevice = true --Compatibility With CAP
ENT.JammingDevice = true

if SERVER then

AddCSLuaFile()

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetName("Jamming Device");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Size = 100;
	self.Immunity = false;
	self.IsEnabled = false;

	self.Allow = {};

	if (WireAddon) then
		self:CreateWireInputs("Activate","Set Radius");
		self:CreateWireOutputs("Activated");
	end

end

-----------------------------------SETUP----------------------------------

function ENT:Setup(size, immunity)
	self.Size = math.Clamp(size,1,1024);
	self.Immunity = immunity;
end

-----------------------------------WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Activate") then
		self.IsEnabled = util.tobool(value)
		if (self.IsEnabled) then
			self:SetWire("Activated",1);
		else
			self:SetWire("Activated",0);
		end
	elseif (variable == "Set Radius") then
		self.Size = math.Clamp(value,1,1024)
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think()
	self.Entity:ShowOutput(self.IsEnabled);
	self.Entity:NextThink(CurTime()+0.25);
	return true
end

function ENT:ShowOutput(active)
	local add = "Off";
	local enabled = 0;
	if(active) then
		add = "On";
		enabled = 1;
	end
	self:SetOverlayText("Jamming device ("..add..")\nSize: "..self.Size);
end

function ENT:SetOverlayText( text )
       self:SetNetworkedString( "GModOverlayText", text )
end

-----------------------------------USE---------------------------------

function ENT:Use(ply)
	if(self.IsEnabled) then
		self.IsEnabled = false;
		self.Allow = nil;
		self.Allow = {};
		self:SetWire("Activated",0);
	else
		self.IsEnabled = true;
		self:SetWire("Activated",1);
		-- for what is this? not work correct
		/*
		for _,v in pairs(player.GetAll()) do
			if Lib.IsInEllipsoid(v:GetPos(), self.Entity, self.Size) then
				table.insert(self.Allow, v);
			end
		end  */
	end
end

end