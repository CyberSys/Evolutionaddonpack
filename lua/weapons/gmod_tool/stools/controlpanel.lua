/*
	Control Panel
	Copyright (C) 2012 by AlexALX
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("cat_decoration");
TOOL.Name=Lib.Language.GetMessage("stool_controlpanel");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/madman07/ring_panel/goauld_panel.mdl";
TOOL.List = "ControlPanelModels";
list.Set(TOOL.List,"models/madman07/ring_panel/goauld_panel.mdl",{Angle=Angle(270,0,0),Position=Vector(0,0,-12)});
list.Set(TOOL.List,"models/zsdaniel/ori-ringpanel/panel.mdl",{Angle=Angle(270,0,0),Position=Vector(0,0,-5)});
list.Set(TOOL.List,"models/madman07/ring_panel/ancient/panel.mdl",{Angle=Angle(270,0,0),Position=Vector(0,0,-10)}); // wtf? gmod blocking ancient_panel.mdl! because it found "ent_"... That's stupid...
// Madman if your are reading this, please recompile model with normal way
// because right now ancient/panel.mdl links to /ancient_panel.mdl, so if remove ancient_panel.mdl, then ancient/panel.mdl also will not work
// with hex editor i can't change model name, because then it not work...

TOOL.Entity.Class = "controlpanel";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 10;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_controlpanel_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_controlpanel_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_controlpanel_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_controlpanel_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_controlpanel_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_controlpanel_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_controlpanel_limit");

function TOOL:LeftClick(t)
	if(t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC() or t.Entity:GetClass() == self.Entity.Class)) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	if(not self:CheckLimit()) then return false end;
	if (model=="models/madman07/ring_panel/ancient/panel.mdl") then model = "models/madman07/ring_panel/ancient_panel.mdl"; end
	local e = self:SpawnSENT(p,t,model);
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model,toggle)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="controlpanel_model",Category="",Models=self.Models});
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"controlpanel_autoweld");
end

TOOL:Register();