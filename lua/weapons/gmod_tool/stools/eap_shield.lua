/*
	Shield Spawner for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--################# Header
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");
TOOL.Category=Lib.Language.GetMessage("stool_tech");
TOOL.Name=Lib.Language.GetMessage("stool_shield");

TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["immunity"] = 0;
TOOL.ClientConVar["size"] = 100;
TOOL.ClientConVar["toggle"] = KEY_PAD_2;
TOOL.ClientConVar["strength"] = 0;
TOOL.ClientConVar["bubble"] = 1;
TOOL.ClientConVar["containment"] = 0;
TOOL.ClientConVar["passing_draw"] = 0;
TOOL.ClientConVar["anti_noclip"] = 0;
TOOL.ClientConVar["r"] = 255;
TOOL.ClientConVar["g"] = 255;
TOOL.ClientConVar["b"] = 255;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/micropro/shield_gen.mdl";
TOOL.MaximumShieldSize = Lib.CFG:Get("shield","max_size",2048); -- A person generally can spawn 1 shield
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "StargateShieldModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/micropro/shield_gen.mdl",{}); -- Thanks micropro for this model!
list.Set(TOOL.List,"models/props_combine/weaponstripper.mdl",{Angle=Angle(-90,0,0),Position=Vector(15,0,-60)});
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{});
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001a.mdl",{});
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{});
if (file.Exists("models/props_c17/pottery08a.mdl","GAME")) then
	list.Set(TOOL.List,"models/props_c17/pottery08a.mdl",{});
end
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{});
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "shields_generator";
TOOL.Entity.Keys = {"toggle_shield","model","size","immunity","strength_multiplier","r","g","b","bubble","containment","passing_draw","Strength","anti_noclip"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 1; -- A person generally can spawn 1 shield

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_stargate_shield_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_stargate_shield_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_stargate_shield_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_stargate_shield_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_stargate_shield_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_stargate_shield_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_stargate_shield_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local toggle = self:GetClientNumber("toggle");
	local model = self:GetClientInfo("model");
	local size = self:GetClientNumber("size");
	local immunity = self:GetClientNumber("immunity");
	local strength = self:GetClientNumber("strength");
	local bubble = self:GetClientNumber("bubble");
	-- Due to compatibility issues with Gmod2007, we need to divide by 255
	local r = self:GetClientNumber("r")/255;
	local g = self:GetClientNumber("g")/255;
	local b = self:GetClientNumber("b")/255;
	local containment = self:GetClientNumber("containment");
	local passing_draw = self:GetClientNumber("passing_draw");
	local anti_noclip = self:GetClientNumber("anti_noclip");
	--######## Spawn SENT
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		t.Entity:SetSize(size);
		t.Entity.ImmuneOwner = false;
		if(util.tobool(immunity)) then
			t.Entity.ImmuneOwner = true;
		end
		t.Entity.DrawBubble = false;
		if(util.tobool(bubble)) then
			t.Entity.DrawBubble = true;
		end
		t.Entity:SetMultiplier(strength);
		t.Entity:SetShieldColor(r,g,b);
		t.Entity.PassingDraw = util.tobool(passing_draw);
		t.Entity.AntiNoclip = util.tobool(anti_noclip);
		t.Entity.Containment = util.tobool(containment);
		-- Make changes take effect immediately, when shield is turned on
		if(t.Entity:Enabled()) then
			t.Entity:Status(false,true);
			local e = t.Entity;
			timer.Simple(0.1,
				function()
					if(e and e:IsValid()) then
						e:Status(true,true);
					end
				end
			);
		end
		-- THIS FUNCTIONS SAVES THE MODIFIED KEYS TO THE SENT, SO THEY ARE AVAILABLE WHEN COPIED WITH DUPLICATOR!
		t.Entity:UpdateKeys(_,_,size,immunity,strength,r,g,b,bubble,containment,passing_draw,0,anti_noclip);
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,toggle,model,size,immunity,strength,r,g,b,bubble,containment,passing_draw,0,anti_noclip);
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity); -- Link to that energy system, if valid
	end
	--######## Weld things?
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,toggle,model,size,immunity,strength_multiplier,r,g,b,bubble,containment,passing_draw,Strength,anti_noclip)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,toggle,model,size,immunity,strength_multiplier,r,g,b,bubble,containment,passing_draw,Strength,anti_noclip)
	e.ImmuneOwner = util.tobool(immunity);
	e.DrawBubble = util.tobool(bubble);
	e.PassingDraw = util.tobool(passing_draw);
	e.Containment = util.tobool(containment);
	e:SetSize(size or 80);
	e:SetMultiplier(strength_multiplier);
	e.AntiNoclip = util.tobool(anti_noclip);
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleShield",e);
	end
	local num = tonumber(Strength);
	if(Strength and num and type(num) == "number") then
		e.Strength = num;
	end
	e:SetShieldColor(r,g,b);
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("ComboBox",{
		Text="Presets",
		MenuButton=1,
		Folder="eap_shield",
		Options={
			Default=self:GetDefaultSettings(),
			["Goa'uld"] = {
				stargate_shield_r = 255,
				stargate_shield_g = 128,
				stargate_shield_b = 59,
			},
			["Asgard"] = {
				stargate_shield_r = 170,
				stargate_shield_g = 189,
				stargate_shield_b = 255,
			},
			["Alteran"] = {
				stargate_shield_r = 124,
				stargate_shield_g = 255,
				stargate_shield_b = 189,
			},
		},
		CVars=self:GetSettingsNames(),
	});
	Panel:NumSlider(Lib.Language.GetMessage("stool_size"),"eap_shield_size",100,self.MaximumShieldSize,0);
	Panel:NumSlider(Lib.Language.GetMessage("stool_shield_str"),"eap_shield_strength",-5,5,2):SetToolTip(Lib.Language.GetMessage("stool_stargate_shield_str_desc"));
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=Lib.Language.GetMessage("stool_toggle"),
		Command="eap_shield_toggle",
	});
	Panel:AddControl("Color",{
		Label = Lib.Language.GetMessage("stool_shield_str_color"),
		Red = "eap_shield_r",
		Green = "eap_shield_g",
		Blue = "eap_shield_b",
		ShowAlpha = 0,
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255,
	});
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="eap_shield_model",Category="",Models=self.Models});
	Panel:CheckBox(Lib.Language.GetMessage("stool_immunity"),"eap_shield_immunity"):SetToolTip(Lib.Language.GetMessage("stool_shield_imm"));
	Panel:CheckBox(Lib.Language.GetMessage("stool_shield_db"),"eap_shield_bubble"):SetToolTip(Lib.Language.GetMessage("stool_shield_db_desc"));
	Panel:CheckBox(Lib.Language.GetMessage("stool_shield_se"),"eap_shield_passing_draw"):SetToolTip(Lib.Language.GetMessage("stool_shield_se_desc"));
	if(Lib.CFG:Get("shield","allow_containment",true)) then
		Panel:CheckBox(Lib.Language.GetMessage("stool_shield_co"),"eap_shield_containment"):SetToolTip(Lib.Language.GetMessage("stool_shield_co_desc"));
	end
	Panel:CheckBox(Lib.Language.GetMessage("stool_shield_an"), "eap_shield_anti_noclip"):SetToolTip(Lib.Language.GetMessage("stool_shield_an_desc"));
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"eap_shield_autoweld");
	if(Lib.HasResourceDistribution) then
		Panel:CheckBox(Lib.Language.GetMessage("stool_autolink"),"eap_shield_autolink"):SetToolTip(Lib.Language.GetMessage("stool_autolink_desc"));
	end
end

--################# Numpad bindings
if SERVER then
	numpad.Register("ToggleShield",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(e:Enabled()) then
				e:Status(false);
			else
				e:Status(true);
			end
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();