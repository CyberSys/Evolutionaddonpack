include("shared.lua");
if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
language.Add("ship_shield",Lib.Language.GetMessage("ship_shield"));
end
if (Lib==nil or Lib.Trace==nil) then return end
-- Register shield SENT to the trace class
Lib.Trace:Add("shield",
	function(e,values,trace,in_box)
		local depleted = e:GetNetworkedBool("depleted",false);
		local containment = e:GetNWBool("containment",false);
		if(not depleted) then
			if((containment and in_box) or (not containment and not in_box)) then
				return true;
			end
		end
	end
);
function ENT:Draw() end -- Do not draw the shield
--################# Retrieves the shield color @aVoN
function ENT:GetShieldColor()
	local v = self.Entity:GetNWVector("shield_color",Vector(1,1,1));
	return Color(v.x,v.y,v.z);
end


