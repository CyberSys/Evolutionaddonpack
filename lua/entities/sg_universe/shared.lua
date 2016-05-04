ENT.Type = "anim"
ENT.Base = "sg_base"
ENT.PrintName = "Stargate (Universe)"
ENT.Author = "Madman07, Llapp, Boba Fett, TheSniper9, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);
ENT.WireDebugName = "Stargate Universe"

ENT.IsUniverseGate = true;

function ENT:GetRingAng()
	if not IsValid(self.EntRing) then self.EntRing=self:GetNWEntity("EntRing") if not IsValid(self.EntRing) then return end end   -- Use this trick beacause NWVars hooks not works yet...
	local angle = tonumber(math.NormalizeAngle(self.EntRing:GetLocalAngles().r));
	return (angle<0) and angle+360 or angle
end

properties.Add( "Lib.Uni.SymLight.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_10"),
	Order		=	-200,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActSymsAL",false)) then return false end
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

						ent:TriggerInput("Activate All Symbols",1);
					end

});

properties.Add( "Lib.Uni.SymLight.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_10d"),
	Order		=	-200,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_universe" || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActSymsAL",false)) then return false end
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

						ent:TriggerInput("Activate All Symbols",0);
					end

});

properties.Add( "Lib.Uni.SymInc.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_12"),
	Order		=	-199,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("ActSymsI",0)!=0) then return false end
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

						ent:TriggerInput("Inbound Symbols",1);
					end

});

properties.Add( "Lib.Uni.SymInc.On2",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_12b"),
	Order		=	-199,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("ActSymsI",0)!=1) then return false end
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

						ent:TriggerInput("Inbound Symbols",2);
					end

});

properties.Add( "Lib.Uni.SymInc.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_12d"),
	Order		=	-199,
	MenuIcon	=	"icon16/plugin_link.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("ActSymsI",0)!=2) then return false end
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

						ent:TriggerInput("Inbound Symbols",0);
					end

});