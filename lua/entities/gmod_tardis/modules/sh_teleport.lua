-- Teleport

-- Binds
TARDIS:AddKeyBind("teleport-demat",{
	name="Demat",
	section="Teleport",
	func=function(self,down,ply)
		if TARDIS:HUDScreenOpen(ply) then return end
		if SERVER then
			if ply==self.pilot and (not down) then
				if not self:GetData("vortex") then
					local pos,ang=self:GetThirdPersonTrace(ply,ply:GetTardisData("viewang"))
					self:Demat(pos,ang)
				end
			end
		else
			if down and (not (self:GetData("vortex") or self:GetData("teleport"))) then
				self:SetData("teleport-trace",true)
			else
				self:SetData("teleport-trace",false)
				--Derma_Query("Do you want to teleport to AimPos?", "TARDIS Interface", "OK", function() end, "Cancel", function() end)
			end
		end
	end,
	key=MOUSE_LEFT,
	exterior=true	
})

TARDIS:AddKeyBind("teleport-mat",{
	name="Mat",
	section="Teleport",
	func=function(self,down,ply)
		if TARDIS:HUDScreenOpen(ply) then return end
		if ply==self.pilot and down then
			if self:GetData("vortex") then
				self:Mat()
			end
		end
	end,
	serveronly=true,
	key=MOUSE_LEFT,
	exterior=true	
})

if SERVER then
	function ENT:Demat(pos,ang,callback)
		if self:CallHook("CanDemat")~=false then
			self:CloseDoor(function(state)
				if state then
					if callback then callback(false) end
				else
					pos=pos or self:GetPos()
					ang=ang or self:GetAngles()
					self:SetBodygroup(1,0)
					self:SendMessage("demat")
					self:SetData("demat",true)
					self:SetData("demat-pos",pos)
					self:SetData("demat-ang",ang)
					self:SetData("step",1)
					self:SetData("teleport",true)
					self:SetCollisionGroup( COLLISION_GROUP_WORLD )
					self:DrawShadow(false)
					for k,v in pairs(self.parts) do
						v:DrawShadow(false)
					end
					local attached = constraint.GetAllConstrainedEntities(self)
					if attached then
						for k,v in pairs(attached) do
							if v.TardisPart or v==self then
								attached[k]=nil
							end
						end
						for k,v in pairs(attached) do
							local a=v:GetColor().a
							if not (a==255) then
								v.tempa=a
							end
						end
					end
					self:SetData("demat-attached",attached)
					if callback then callback(true) end
				end
			end)
		else
			if callback then callback(false) end
		end
	end
	function ENT:Mat(callback)
		if self:CallHook("CanMat")~=false then
			self:SendMessage("premat",function() net.WriteVector(self:GetData("demat-pos",Vector())) end)
			self:SetData("teleport",true)
			timer.Simple(8.5,function()
				if not IsValid(self) then return end
				self:SendMessage("mat")
				self:SetData("mat",true)
				self:SetData("step",1)
				self:SetData("vortex",false)
				self:SetSolid(SOLID_VPHYSICS)
				self.phys:EnableMotion(true)
				self.phys:Wake()
				
				local pos=self:GetData("demat-pos",Vector())
				local ang=self:GetData("demat-ang",Angle())
				local attached=self:GetData("demat-attached")
				if attached then
					for k,v in pairs(attached) do
						if IsValid(v) and not IsValid(v:GetParent()) then
							v.telepos=v:GetPos()-self:GetPos()
							if v:GetClass()=="gmod_hoverball" then // fixes hoverballs spazzing out
								v:SetTargetZ( (pos-self:GetPos()).z+v:GetTargetZ() )
							end
						end
					end
				end
				self:SetPos(pos)
				self:SetAngles(ang)
				if attached then
					for k,v in pairs(attached) do
						if IsValid(v) and not IsValid(v:GetParent()) then
							if v:IsRagdoll() then
								for i=0,v:GetPhysicsObjectCount() do
									local bone=v:GetPhysicsObjectNum(i)
									if IsValid(bone) then
										bone:SetPos(self:GetPos()+v.telepos)
									end
								end
							end
							v:SetPos(self:GetPos()+v.telepos)
							v.telepos=nil
							local phys=v:GetPhysicsObject()
							if phys and IsValid(phys) then
								if not v.frozen and not v.physlocked then
									phys:EnableMotion(true)
								end
								v:SetSolid(SOLID_VPHYSICS)
							end
							v.frozen=nil
							v.nocollide=nil
						end
					end
				end
				self:SetData("demat-pos",nil)
				self:SetData("demat-ang",nil)
			end)
			if callback then callback(true) end
		else
			if callback then callback(false) end
		end
	end
	function ENT:StopDemat()
		self:SetData("demat",false)
		self:SetData("step",1)
		self:SetData("vortex",true)
		self:SetData("teleport",false)
		self:SetSolid(SOLID_NONE)
		self.phys:EnableMotion(false)
		local attached=self:GetData("demat-attached")
		if attached then
			for k,v in pairs(attached) do
				if IsValid(v) and not IsValid(v:GetParent()) then
					local phys=v:GetPhysicsObject()
					if phys and IsValid(phys) then
						if not phys:IsMotionEnabled() then
							v.frozen=true
						end
						phys:EnableMotion(false)
						v:SetSolid(SOLID_NONE)
					end
				end
			end
		end
	end
	function ENT:StopMat()
		self:SetBodygroup(1,1)
		self:SetData("mat",false)
		self:SetData("step",1)
		self:SetData("teleport",false)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:DrawShadow(true)
		for k,v in pairs(self.parts) do
			v:DrawShadow(true)
		end
		local attached=self:GetData("demat-attached")
		if attached then
			for k,v in pairs(attached) do
				if IsValid(v) and v.tempa then
					local col=v:GetColor()
					col=Color(col.r,col.g,col.b,v.tempa)
					v:SetColor(col)
					v.tempa=nil
				end
			end
		end
		self:SetData("demat-attached")
	end
	
	ENT:AddHook("CanDemat", "teleport", function(self)
		if self:GetData("teleport") or self:GetData("vortex") then
			return false
		end
	end)
	
	ENT:AddHook("CanMat", "teleport", function(self)
		if self:GetData("teleport") then
			return false
		end
	end)
	
	ENT:AddHook("CanToggleDoor","teleport",function(self,state)
		if self:GetData("teleport") or self:GetData("vortex") then
			return false
		end
	end)
	
	ENT:AddHook("ShouldThinkFast","teleport",function(self)
		if self:GetData("teleport") then
			return true
		end
	end)
	
	ENT:AddHook("CanPlayerEnter","teleport",function(self)
		if self:GetData("teleport") then
			return false
		end
	end)
	
	ENT:AddHook("CanPlayerExit","teleport",function(self)
		if self:GetData("teleport") then
			return false
		end
	end)
	
	ENT:AddHook("ShouldTurnOnRotorwash", "teleport", function(self)
		if self:GetData("teleport") then
			return true
		end
	end)
	
	ENT:AddHook("ShouldTurnOffRotorwash", "teleport", function(self)
		if self:GetData("vortex") then
			return true
		end
	end)
else
	TARDIS:AddSetting({
		id="teleport-sound",
		name="Sound",
		section="Teleport",
		value=true,
		type="bool",
		option=true
	})

	local function dopredraw(self,part)
		if self:GetData("teleport") or self:GetData("teleport-trace") then
			render.SetBlend((self:GetData("teleport-trace") and 20 or self:GetData("alpha",255))/255)
		end
	end
	
	local function dodraw(self,part)
		if self:GetData("teleport") or self:GetData("teleport-trace") then
			render.SetBlend(1)
		end
	end
	ENT:AddHook("PreDraw","teleport",dopredraw)
	ENT:AddHook("PreDrawPart","teleport",dopredraw)
	ENT:AddHook("Draw","teleport",dodraw)
	ENT:AddHook("DrawPart","teleport",dodraw)
	
	ENT:AddHook("ShouldDraw","teleport",function(self)
		if self:GetData("vortex") and (not (self:GetData("mat") or self:GetData("demat"))) and (self:GetData("alpha",255)==self:GetData("alphatarget",255)) then
			return false
		end
	end)
	
	ENT:AddHook("ShouldTurnOnLight","teleport",function(self)
		if self:GetData("teleport") then
			return true
		end
	end)
	
	ENT:AddHook("ShouldTurnOffLight","teleport",function(self)
		if self:GetData("vortex") then
			return true
		end
	end)
	
	ENT:AddHook("ShouldTurnOffFlightSound", "teleport", function(self)
		if self:GetData("teleport") or self:GetData("vortex") then
			return true
		end
	end)
	
	ENT:OnMessage("demat", function(self)
		self:SetData("demat",true)
		self:SetData("step",1)
		self:SetData("teleport",true)
		if TARDIS:GetSetting("teleport-sound") and TARDIS:GetSetting("sound") then
			if LocalPlayer():GetTardisData("exterior")==self then
				self:EmitSound("tardis/demat.wav")
				self.interior:EmitSound("tardis/demat.wav")
			else
				sound.Play("tardis/demat.wav",self:GetPos())
			end
		end
	end)
	
	ENT:OnMessage("premat", function(self)
		self:SetData("teleport",true)
		if TARDIS:GetSetting("teleport-sound") and TARDIS:GetSetting("sound") then
			local pos=net.ReadVector()
			if LocalPlayer():GetTardisData("exterior")==self then
				self:EmitSound("tardis/mat.wav")
				self.interior:EmitSound("tardis/mat.wav")
			else
				sound.Play("tardis/mat.wav",pos)
			end
		end
	end)
	
	ENT:OnMessage("mat", function(self)
		self:SetData("mat",true)
		self:SetData("step",1)
		self:SetData("vortex",false)
	end)
	
	function ENT:StopDemat()
		self:SetData("demat",false)
		self:SetData("step",1)
		self:SetData("vortex",true)
		self:SetData("teleport",false)
	end
	
	function ENT:StopMat()
		self:SetData("mat",false)
		self:SetData("step",1)
		self:SetData("teleport",false)
	end
	
	hook.Add("PostDrawTranslucentRenderables", "tardis-trace", function()
		local ext=TARDIS:GetExteriorEnt()
		if IsValid(ext) and ext:GetData("teleport-trace") then
			local pos,ang=ext:GetThirdPersonTrace(LocalPlayer(),LocalPlayer():EyeAngles())
			local fw=ang:Forward()
			local bk=fw*-1
			local ri=ang:Right()
			local le=ri*-1
			
			local size=10
			local col=Color(255,0,0)
			render.DrawLine(pos,pos+(fw*size),col)
			render.DrawLine(pos,pos+(bk*size),col)
			render.DrawLine(pos,pos+(ri*size),col)
			render.DrawLine(pos,pos+(le*size),col)
		end
	end)
end

ENT.dematvalues={
	150,
	200,
	100,
	150,
	50,
	100,
	0
}
ENT.matvalues={
	100,
	50,
	150,
	100,
	200,
	150,
	255
}

function ENT:GetTargetAlpha()
	local demat=self:GetData("demat")
	local mat=self:GetData("mat")
	local step=self:GetData("step",1)
	if demat and (not mat) then
		return self.dematvalues[step]
	elseif mat and (not demat) then
		return self.matvalues[step]
	else
		return 255
	end
end

ENT:AddHook("Think","teleport",function(self,delta)
	local demat=self:GetData("demat")
	local mat=self:GetData("mat")
	if not (demat or mat) then return end
	local alpha=self:GetData("alpha",255)
	local target=self:GetData("alphatarget",255)
	local step=self:GetData("step",1)
	if alpha==target then
		if demat then
			if step>=#self.dematvalues then
				self:StopDemat()
				return
			else
				self:SetData("step",step+1)
			end
		elseif mat then
			if step>=#self.matvalues then
				self:StopMat()
				return
			else
				self:SetData("step",step+1)
			end
		end
		target=self:GetTargetAlpha()
		self:SetData("alphatarget",target)
	end
	alpha=math.Approach(alpha,target,delta*66*0.85)
	self:SetData("alpha",alpha)
	local attached=self:GetData("demat-attached")
	if attached then
		for k,v in pairs(attached) do
			if IsValid(v) then
				local col=v:GetColor()
				col=Color(col.r,col.g,col.b,alpha)
				if not (v.tempa==0) then
					if not (v:GetRenderMode()==RENDERMODE_TRANSALPHA) then
						v:SetRenderMode(RENDERMODE_TRANSALPHA)
					end
					v:SetColor(col)
				end
			end
		end
	end
end)