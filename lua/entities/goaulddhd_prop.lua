--[[
	Goauld DHD
	Copyright (C) 2010 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Goa'uld DHD"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Goa'uld DHD"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

AddCSLuaFile();

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Boba_Fett/portable_dhd/portable_dhd.mdl")
	self.Entity:SetModel("models/Boba_Fett/portable_dhd/portable_dhd.mdl");

	self.Entity:SetName("Goa'uld DHD");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	-- now its wrong, zpms have new code for energy and this thing not work anymore, also all this shit not work with Environments addon
	-- and like i remember it can dial only 7 chevrons, so goauld_dhd_pros is like dhd and this code not needed.
	/*self.MaxEnergy = Lib.CFG:Get("zpm","capacity",10000000);
	self:AddResource("ZPE",self.MaxEnergy); --ZeroPoint energy @Anorr
	self:SupplyResource("ZPE",self.MaxEnergy);
	self:AddResource("energy",Lib.CFG:Get("zpm","energy_capacity",5000)); -- Maximum energy to store in a ZPM is 5000 units   */


end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	ply:Give("eap_goauld_dhd");
	ply:SelectWeapon("eap_goauld_dhd");
	self.Entity:Remove()
end

function ENT:DialMenu()
	//if(self.HasRD) then self.Entity:Power(); end
	if(hook.Call("Lib.Player.CanDialGate",GAMEMODE,self.Owner,self.Gates) == false) then return end;
	net.Start("Lib.VGUI.Menu");
	net.WriteEntity(self.Gates);
	net.WriteInt(1,8);
	net.Send(self.Owner);
end

       /*
--This is from aVoN's wire_rd detection but
--################# What version is installed? @aVoN
local RD; -- QuickIndex
local IsThree;
local function RDThree()
	if(IsThree ~= nil) then return IsThree end;
	if(CAF and CAF.GetAddon("Resource Distribution")) then
		IsThree = true;
		RD = CAF.GetAddon("Resource Distribution");
		return true;
	end
	IsThree = false;
	return false;
end

function ENT:Power()

	if(RDThree()) then
		RD.Link(self.Entity,self.Gates)
	else
		Dev_Link(self.Entity,self.Gates)
	end
end*/

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "goaulddhd_prop", Lib.EAP_GmodDuplicator, "Data" )
end

end