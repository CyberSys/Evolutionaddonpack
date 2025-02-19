/*
	Doors
	Copyright (C) 2010  Madman07
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("cat_decoration");
TOOL.Name=Lib.Language.GetMessage("stool_doors");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["toggle"] = KEY_PAD_2;
TOOL.ClientConVar["diff_text"] = 0;
TOOL.ClientConVar["model"] = "models/cryptalchemy_models/destiny/bridge_door/bridge_door.mdl";
TOOL.ClientConVar["doormodel"] = "";

TOOL.List = "DoorsModels";
list.Set(TOOL.List,"models/madman07/doors/dest_door.mdl",{});
list.Set(TOOL.List,"models/cryptalchemy_models/destiny/bridge_door/bridge_door.mdl",{});
list.Set(TOOL.List,"models/madman07/doors/atl_door1.mdl",{});
list.Set(TOOL.List,"models/madman07/doors/atl_door2.mdl",{});
list.Set(TOOL.List,"models/madman07/doors/atl_door3.mdl",{});

TOOL.Entity.Class = "doors_frame";
TOOL.Entity.Keys = {"model","toggle", "diff_text", "doormodel"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 10;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_doors_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_doors_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_doors_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_doors_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_doors_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_doors_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_doors_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model"):lower();
	local toggle = self:GetClientNumber("toggle");
	local diff_text = util.tobool(self:GetClientNumber("diff_text"));
	local doormodel = model;
	if (model == "models/madman07/doors/dest_door.mdl") then model = "models/madman07/doors/dest_frame.mdl";
	elseif (model == "models/cryptalchemy_models/destiny/bridge_door/bridge_door.mdl") then model = "models/cryptalchemy_models/destiny/bridge_door/bridge_door_frame.mdl";
	elseif (model == "models/madman07/doors/atl_door3.mdl") then model = "models/gmod4phun/props/atlantis_door_frame_2.mdl"; -- New door and frame
	else model = "models/madman07/doors/atl_frame.mdl"; end

	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model,toggle, diff_text, doormodel);
	if (not IsValid(e)) then return end
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);

	e.DoorModel = doormodel;
	if (IsValid(e.Door)) then e.Door:SetAngles(e:GetAngles()) end -- fix
	if (model == "models/madman07/doors/atl_frame.mdl") then
		if diff_text then e:SetMaterial("madman07/doors/atlwall_red"); end
	end
	if (model == "models/madman07/doors/dest_frame.mdl") then e:SoundType(1);
	elseif (model == "models/cryptalchemy_models/destiny/bridge_door/bridge_door_frame.mdl") then e:SoundType(3);
	else e:SoundType(2); end

	return true;
end

function TOOL:PreEntitySpawn(p,e,model,toggle, diff_text, doormodel)
	e:SetModel(model);
	e.DoorModel = doormodel;
	e.Owner = p;
end

function TOOL:PostEntitySpawn(p,e,model,toggle, diff_text, doormodel)
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleDoors",e);
	end
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="doors_model",Category="",Models=self.Models});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=Lib.Language.GetMessage("stool_toggle"),
		Command="doors_toggle",
	});
	Panel:CheckBox(Lib.Language.GetMessage("stool_doors_redt"),"doors_diff_text");
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"doors_autoweld");
end

if SERVER then
	numpad.Register("ToggleDoors",
		function(p,e)
			if (IsValid(e)) then
				e:Toggle();
			end
		end
	);
end

TOOL:Register();
