ENT:AddHook("Initialize", "cloak-init", function(self)
    self:SetData("cloaked", false, true)

    self.cloakmat = "models/shadertest/shader3"

    self.mins = self:OBBMins()
    self.maxs = self:OBBMaxs()
    self.maxs.z = self.maxs.z + 25 -- We are adding on to the value to avoid any of the top of model appearing when flying
    self.height = (self.maxs.z - self.mins.z)

    self.phaseTimeCloak = CurTime() + 1
    self.phaseTimeUncloak = CurTime() - 1

    self.percent = 1

    -- For animating with math.approach
    self.LastThink = 0
end)

if SERVER then
    function ENT:SetCloak(toggle)
        if toggle then
            self:SendMessage("cloaksound")
        end

        return self:SetData("cloaked", toggle, true)
    end
    
    function ENT:ToggleCloak()
        local shouldCloak = !self:GetData("cloaked", false)
        return self:SetCloak(shouldCloak)
    end
else
    ENT:AddHook("Draw", "cloak-draw", function(self)
        local isCloaked = self:GetData("cloaked", false)
        local doors = self:GetPart("door")

        local now = CurTime()
	    local timepassed = now - self.LastThink
	    self.LastThink = now

        if isCloaked then
            self.percent = math.Approach(self.percent, 0, 0.5 * timepassed)
        else
            self.percent = math.Approach(self.percent, 1, 0.5 * timepassed)
        end
        
        self.highPercent = (self.percent + 0.5)

        self.percent = math.Clamp(self.percent, 0, 1)
        self.highPercent = math.Clamp(self.highPercent, 0, 1)

        -- Plane clipping, for animating the invisible effect
        local normal = self:GetUp()
        local pos = self:GetPos() + self:GetUp() * (self.maxs.z - (self.height * self.percent))
        local dist = normal:Dot(pos)

        self:SetRenderClipPlaneEnabled(true)
        self:SetRenderClipPlane(normal, dist)

        doors:SetRenderClipPlaneEnabled(true)
        doors:SetRenderClipPlane(normal, dist)

        --[[local oldClip = render.EnableClipping(true)

        local restoreT = self:GetMaterial()

        render.MaterialOverride(Material(self.cloakmat))

        normal = self:GetUp()
        dist = normal:Dot(pos)

        render.PushCustomClipPlane(normal, dist)

        local normal2 = self:GetUp() * -1
		local pos2 = self:GetPos() + self:GetUp() * (self.maxs.z - (self.height * self.percent))
		local dist2 = normal2:Dot(pos2)
		
        render.PushCustomClipPlane(normal2, dist2)
			self:DrawModel()
            doors:DrawModel()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		
		render.MaterialOverride(restoreT)
		render.EnableClipping(oldClip)--]]
    end)

    TARDIS:AddSetting({
        id = "cloaksound-enabled",
        name = "Cloak Sound",
        desc = "Whether a sound should play or not when the player cloaks",
        section = "Sound",
        value = true,
        type = "bool",
        option = true
    })

    ENT:OnMessage("cloaksound", function(self)
        local snd = self.metadata.Exterior.Sounds.Cloak

        if TARDIS:GetSetting("cloaksound-enabled") && TARDIS:GetSetting("sound") then
            self:EmitSound(snd)

            if IsValid(self.interior) then
                self.interior:EmitSound(snd)
            end
        end
    end)
end