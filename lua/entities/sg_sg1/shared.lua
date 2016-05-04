ENT.Type = "anim"
ENT.Base = "sg_base"
ENT.PrintName = "Stargate (SG1)"
ENT.Author = "aVoN, Madman07, Llapp, Boba Fett, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"
ENT.Spawnable = true

ENT.WireDebugName = "Stargate SG1"
list.Set("EAP", ENT.PrintName, ENT);

function ENT:GetRingAng()
	if not IsValid(self.EntRing) then self.EntRing=self:GetNWEntity("EntRing") if not IsValid(self.EntRing) then return end end   -- Use this trick beacause NWVars hooks not works yet...
	local angle = tonumber(math.NormalizeAngle(self.EntRing:GetLocalAngles().r));
	return (angle<0) and angle+360 or angle
end

properties.Add( "Lib.SGCType.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_13"),
	Order		=	-150,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						local vg = {"sg_movie","sg_sg1","sg_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActSGCT",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("SGC Type",1);
					end

});

properties.Add( "Lib.SGCType.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_13d"),
	Order		=	-150,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
                        local vg = {"sg_movie","sg_sg1","sg_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActSGCT",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("SGC Type",0);
					end

});

properties.Add( "Lib.PoO",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_14"),
	Order		=	-170,
	MenuIcon	=	"icon16/plugin_link.png",

	Filter		=	function( self, ent, ply )
						local vg = {"sg_movie","sg_sg1","sg_infinity","sg_tollan"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
						return true

					end,

	MenuOpen = function( self, option, ent, tr )
		local submenu = option:AddSubMenu()
		local poo = ent:GetNWInt("Point_of_Origin",0);
		for i=0,2 do
			local option = submenu:AddOption( Lib.Language.GetMessage("stargate_c_tool_14_"..i+1), function() self:SetPoo( ent, i ) end )
			if ( poo == i ) then
				option:SetChecked( true )
			end
		end
	end,

	SetPoo		=	function( self, ent, i )

						self:MsgStart()
							net.WriteEntity( ent )
							net.WriteInt(i,8)
						self:MsgEnd()

					end,

	Action 		= 	function() end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("Set Point of Origin",net.ReadInt(8));
					end

});