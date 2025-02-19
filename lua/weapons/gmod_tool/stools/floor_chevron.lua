/*   Copyright (C) 2011 by Llapp   */
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("stool_stargate");
TOOL.Name=Lib.Language.GetMessage("stool_fchev");
TOOL.ClientConVar["model"] = "models/The_Sniper_9/Universe/Stargate/floorchevron.mdl";
TOOL.ClientConVar["autoweld"] = 1;
TOOL.List = "FloorChevronModels";
list.Set(TOOL.List,"models/The_Sniper_9/Universe/Stargate/floorchevron.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/ramps/sgu_ramp/floor_chev.mdl",{});
TOOL.Entity.Class = "floor_chevron";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 10;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_floorchevron_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_floorchevron_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_floorchevron_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_floorchevron_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_floorchevron_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_floorchevron_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_floorchevron_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	if(not IsValid(t.Entity) or not t.Entity:GetClass():find("sg_universe")) then
	    p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_floorchevron_err\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	for _,v in pairs(Lib.GetConstrainedEnts(t.Entity,2) or {}) do
		if(IsValid(v) and v:GetClass():find("floorchevron")) then
		   p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_floorchevron_exs\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		   return
		end
	end
	local e = self:SpawnSENT(p,t,model);
	if (not IsValid(e)) then return end
	local ang = t.Entity:GetAngles(); ang.y = ang.y+180;
	local vec = Vector(40,0,-90);
	e:SetPos(t.Entity:LocalToWorld(vec))
	e:SetAngles(ang);
    local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
    Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="floor_chevron_model",Category="",Models=self.Models});
	Panel:AddControl("Label", {Text = "\n"..Lib.Language.GetMessage("stool_desc").."\n\n"..Lib.Language.GetMessage("stool_floorchevron_fulldesc"),})
end

TOOL:Register();