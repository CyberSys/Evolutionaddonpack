ENT.Base = "ship_base"
ENT.Type = "vehicle"
ENT.Spawnable = true

ENT.PrintName = Lib.Language.GetMessage('ent_ship_replicator');
ENT.Author = "Elanis, Lilou"
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
AddCSLuaFile()

ENT.Model = Model("models/ship/rship01.mdl")

ENT.Sounds = {
	Staff=Sound("sound/eap/ship/armes/replicateurweapon.mp3")
}

function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("EAP_ships_max"):GetInt()
	if(ply:GetCount("EAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("ship_replicateur")
	e:SetPos(tr.HitPos + Vector(0,0,350))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("EAP_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex
	self.BaseClass.Initialize(self);
	self.Vehicle = "ReplicateurMS"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 25000 --Health 25000 + Shield 0
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetNWInt("maxEntHealth",self.EntHealth)
	self:SetNWInt("CanFire",1)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()

	--####### Attack vars
	self.LastBlast=0
	self.Delay=10
	self.CanFire = true;

	--######### Flight Vars
	self.Accel = {}
	self.Accel.FWD = 0
	self.Accel.RIGHT = 0
	self.Accel.UP = 0
	self.ForwardSpeed = 1500
	self.BackwardSpeed = -750
	self.UpSpeed=600
	self.MaxSpeed = 2000
	self.RightSpeed = 750
	self.Accel.SpeedForward = 10
	self.Accel.SpeedRight = 7
	self.Accel.SpeedUp = 7
	self.RollSpeed = 5
	self.num = 0
	self.num2 = 0
	self.num3 =0
	self.Roll=0
	self.Hover=true
	self.GoesRight=true
	self.GoesUp=true
	self.CanRoll=true
	self:CreateWireOutputs("Health");

	local phys = self:GetPhysicsObject()
	self:GetPhysicsObject():EnableMotion(false)

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
end

function ENT:Think()

	self.BaseClass.Think(self);
	self.ExitPos = self:GetPos()-self:GetRight()*400-self:GetUp()*200;

	if(IsValid(self.Pilot)) then
		if(self.Pilot:KeyDown("EAP_KEYBOARD","DHD")) then
			--self:OpenDHD(self.Pilot);
		end

		if(self.Pilot:KeyDown("EAP_KEYBOARD","FIRE")) then
			if(self.CanFire) then
				self:FireBlast(self:GetRight()*0);
				self:FireBlast(self:GetRight()*-0);
				self.CanFire = false;
				timer.Create("ReplicateurCanFire"..self:EntIndex(),2,1,function()
					self.CanFire = true;
				end)
			end
		end
	end
end

function ENT:OnRemove()	self.BaseClass.OnRemove(self) end

function ENT:OnTakeDamage(dmg) --########## Gliders aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health-dmg:GetDamage());

	if((health-dmg:GetDamage())<=0) then
		self:Bang() -- Go boom
	end

	/*timer.Create("ReplicateurHealth"..self:EntIndex(),1,0,function(self)
		if(self:GetNWInt("health") < self:GetNWInt("maxEntHealth")) then
			local health = self:GetNWInt("health")
			local maxHealth = self:GetNWInt("maxEntHealth")
			if((maxHealth-health)<5)then
				self:SetNWInt("health",health+(maxHealth-health));
			else
				self:SetNWInt("health",health+5)
			end
		end
	end)*/
end

function ENT:FireBlast(diff)
	if(self.CanFire) then
		-- local fx = EffectData();
			-- fx:SetStart(self:GetPos()+diff);
			-- fx:SetAngles(Angle(255,200,120));
			-- fx:SetRadius(80);
		-- util.Effect("avon_energy_muzzle",fx,true);
		local e = ents.Create("energy_pulse_wraith");
		e:PrepareBullet(self:GetForward(), 10, 16000, 6, {self.Entity});
		e:SetPos(self:GetPos()+diff);
		e:SetOwner(self);
		e.Owner = self;
		e:Spawn();
		e:Activate();
		self:EmitSound(self.Sounds.Staff,90,math.random(90,110))
	end
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage('cat_capital_ship');
ENT.PrintName = Lib.Language.GetMessage("ent_ship_replicator");
end
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Sounds={
	Engine=Sound("eap/ship/moteur/destiny.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or Lib.Settings.KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "ReplicateurMS"
end

--[[

function SGGGCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	--self.BaseClass.CalcView(self,Player, Origin, Angles, FieldOfView)
	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if(IsValid(self) and self:GetClass()=="sg_vehicle_gate_glider") then
		if(self.FirstPerson) then
			local pos = self:GetPos()+self:GetUp()*20+self:GetForward()*70;
			local angle = self:GetAngles( );
				view.origin = pos		;
				view.angles = angle;
				view.fov = FieldOfView + 20;
			return view;
		else
			local pos = self:GetPos()+self:GetUp()*self.Udist+Player:GetAimVector():GetNormal()*-self.Dist;
			local face = ( ( self.Entity:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle() + Angle(0,180,0);
				view.origin = pos;
				view.angles = face;
			return view;
		end
	end
end
hook.Add("CalcView", "SGGGCalcView", SGGGCalcView)
]]--

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local Ship = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((Ship)and((Ship)==self)and(Ship:IsValid())) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end

	if((Ship)and((Ship)==self)and(Ship:IsValid())) then
		if(p:KeyDown("EAP_KEYBOARD","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("EAP_KEYBOARD","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("EAP_KEYBOARD","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("EAP_KEYBOARD","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("EAP_KEYBOARD","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

local hudpos = {
	healthw = (ScrW()/10*6.5),
	healthh = (ScrH()/10*8.94),
}

function DrawHUD() -- Draw that HUD @Elanis

	local ply = LocalPlayer();
	local self = ply:GetNetworkedEntity("ScriptedVehicle", NULL)
    local vehicle = ply:GetNWEntity("ReplicateurMS")

	if (self and self:IsValid() and vehicle and vehicle:IsValid() and self==vehicle) then

		local MainHud = surface.GetTextureID("vgui/hud/replicateur_hud/main_hud");

		surface.SetTexture(MainHud);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(0,0,ScrW(),ScrH());
			local health = math.Round(self:GetNetworkedInt("health")/25000*100) -- test fix
			draw.WordBox(8,hudpos.healthw,hudpos.healthh, Lib.Language.GetMessage("health")..": "..health.."%","ScoreboardText",Color(50,50,75,0), Color(100,0,100,255))

	end

end
hook.Add("HUDPaint","DrawHUDReplicateurMS",DrawHUD);

end