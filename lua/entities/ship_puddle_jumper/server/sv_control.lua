
function ENT:ExitJumper() --################# Get out the jumper@RononDex
	if (IsValid(self.Pilot)) then
		Lib.KeyBoard.ResetKeys(self.Pilot,"PuddleJumper");

		self.Pilot:UnSpectate()
		self.Pilot:DrawViewModel(true)
		self.Pilot:DrawWorldModel(true)
		self.Pilot:Spawn()
		self.Pilot:SetNetworkedBool("isFlyingjumper",false)
		self.Pilot:SetPos(self:GetPos()+self:GetForward()*15+self:GetUp()*-40)
		self.AllowActivation=false
		self.Pilot:SetHealth(self.health)
		self.Pilot:SetMoveType(MOVETYPE_WALK)
		--self.Pilot:SetScriptedVehicle(NULL)
		self.Pilot:SetNetworkedEntity("ScriptedVehicle", NULL)
		self.Pilot:SetViewEntity(NULL)
		for k,v in pairs(self.PWeapons) do
			self.Pilot:Give(tostring(v))
		end
		self.Pilot = nil;
	end

	if(IsValid(self)) then
		self:EmitSound(self.Sounds.Shutdown,100,100)
		self:SetNetworkedEntity("jumper",NULL)
		self.HoverPos = self:GetPos();
		self:SetWire("Driver",NULL)

		self:RemoveDrones() -- Remove the drone props... SO MANY BUGS BECAUSE OF THESE THINGS!
		self.Roll=0
		self.LiftOff = false
		self.Inflight=false
		self.Accel.FWD = 0;
		self.Accel.RIGHT = 0;
		self.Accel.UP = 0;

		self:SetNetworkedBool("JumperInflight",false);

		self:SpawnToggleButton(self.Owner);
		self:SpawnBulkHeadDoor(nil,self.Owner);
		self:SpawnBackDoor(nil,self.Owner);
		if(self.door) then
			self.Door:SetSolid(SOLID_NONE);
		end
		self:SpawnOpenedDoor(self.Owner);
		//self:SpawnSeats();

		self:ToggleRotorwash(false);

		if(self.epodo) then
			self:TogglePods()
		end
		timer.Simple( 0.75, function()
			self.AllowActivation = true
		end);
	end

end

function ENT:AutoPilot(b)
	
	if(b) then
		if self.Autopilot then return end;
		local gate = self:FindGate(5000);
		if(IsValid(gate)) then
			if((self:GetPos()-gate:GetPos()):DotProduct(gate:GetForward()) > 0) then
			
				local Dist = self:WorldToLocal(gate:GetPos()).x;
				if(Dist < 600) then Dist = 600 end;
				self.AutoAlignPos = gate:GetPos()+gate:GetForward()*Dist;
				
				//self.AutoAlignAng = Angle(0,0,0)
				
				local gateRoll = gate:GetAngles().r;
				self.AutoAlignAng = gate:GetAngles() + Angle(180,0,-180-gateRoll*2);
				
				self.Autopilot = true;
				self.AutoGate = gate;
				self.Pilot:ChatPrint("AutoPilot Engaged");
				
				if(self.epodo) then
					self:TogglePods();
				end
				
				if(self.Cloaked) then
					self:ToggleCloak();
				end
				
				if(self.Shielded) then
					self:ToggleShield();
				end
				
				if(self.door) then
					self:ToggleDoor();
				end
			else
				self.Pilot:ChatPrint("Please Move to the front of the Stargate");
			end
		else
			self.Pilot:ChatPrint("You are not in range of a Stargate");
		end
	else
		self.AutoAlignPos = nil;
		self.AutoAlignAng = nil;
		self.Autopilot = false;
		self.AutoGate = NULL;
		self.FinalAlignment = false;
		self.Pilot:ChatPrint("AutoPilot Disengaged");
	end

end


function ENT:EnterJumper(ply) --############### Get in the jumper @ RononDex

	if(self.AllowActivation) then

		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableMotion(true)
		self.Inflight = true
		self.Pilot = true
		self.Pilot=ply
		self:SetWire("Driver",self.Pilot)
		self.Roll=0
		if(self.BulkHead) then
			self:ToggleBulkHead()
		end

		if(not self.Cloaked) then
			self:ToggleRotorwash(true)
		end

		--ply:SetScriptedVehicle(self)
		ply:SetNetworkedEntity("ScriptedVehicle", self) -- still needed for event horizon
		ply:SetViewEntity(self)

		for _,v in pairs(ply:GetWeapons()) do
			table.insert(self.PWeapons, v:GetClass())
		end
		self.health=ply:Health()

		self.AllowActivation=false
		self.LiftOff = true
		self:EmitSound(self.Sounds.Startup, 100, 100)
		ply:SetMoveType(MOVETYPE_OBSERVER)
		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)

		self.StartPos = self:GetPos()

		self:RemoveAll(); -- We need to remove all welded props in order to go through gates properly.

		ply:Spectate( OBS_MODE_CHASE )
		ply:StripWeapons()

		ply:SetNetworkedBool("isFlyingjumper",true)
		ply:SetNetworkedEntity("jumper",self)
		self:SetNetworkedBool("JumperInflight",true);

		ply:SetEyeAngles(self:GetAngles());

		ply:Flashlight(false);
		
	end
	self.Entered=true
	timer.Simple( 0.75, function()
		self.AllowActivation=true
		self.LiftOff=false
	end)
end