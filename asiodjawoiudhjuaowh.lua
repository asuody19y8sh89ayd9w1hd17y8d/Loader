getgenv().Visuals = {
    ForceFieldEnabled = false,
    ForceFieldGunEnabled = false,
    TrailEnabled = false,
    ForceFieldColor = Color3.fromRGB(255, 255, 255),
    ForceFieldGunColor = Color3.fromRGB(255, 255, 255),
    TrailColor = Color3.fromRGB(255, 255, 255),
    TrailLifetime = 1.5,
    TrailWidth = 0.6,
    TrailInstance = nil,
    OriginalColors = {} -- Przechowywanie oryginalnych kolorów części postaci
}

local function updateForceField()
    if LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
            if obj:IsA("BasePart") or obj:IsA("Accessory") then
                local part = obj:IsA("Accessory") and obj:FindFirstChild("Handle") or obj
                
                if part and part:IsA("BasePart") then
                    if getgenv().Visuals.ForceFieldEnabled then
                        -- Zapisz oryginalny kolor przed zmianą
                        if not getgenv().Visuals.OriginalColors[part] then
                            getgenv().Visuals.OriginalColors[part] = part.Color
                        end
                        part.Material = Enum.Material.ForceField
                        part.Color = getgenv().Visuals.ForceFieldColor
                    else
                        part.Material = Enum.Material.Plastic
                        -- Przywróć oryginalny kolor
                        if getgenv().Visuals.OriginalColors[part] then
                            part.Color = getgenv().Visuals.OriginalColors[part]
                        end
                    end
                end
            end
        end
    end
end

local function updateForceFieldGun()
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                if getgenv().Visuals.ForceFieldGunEnabled then
                    -- Zapisz oryginalny kolor przed zmianą
                    if not getgenv().Visuals.OriginalColors[handle] then
                        getgenv().Visuals.OriginalColors[handle] = handle.Color
                    end
                    handle.Material = Enum.Material.ForceField
                    handle.Color = getgenv().Visuals.ForceFieldGunColor
                else
                    handle.Material = Enum.Material.Plastic
                    -- Przywróć oryginalny kolor
                    if getgenv().Visuals.OriginalColors[handle] then
                        handle.Color = getgenv().Visuals.OriginalColors[handle]
                    end
                end
            end
        end
    end
end

local function createTrail()
    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local trail = Instance.new("Trail")
        trail.Color = ColorSequence.new(getgenv().Visuals.TrailColor)
        trail.Lifetime = getgenv().Visuals.TrailLifetime
        trail.WidthScale = NumberSequence.new(getgenv().Visuals.TrailWidth)
        trail.Enabled = true

        local attachment0 = Instance.new("Attachment", humanoidRootPart)
        local attachment1 = Instance.new("Attachment", humanoidRootPart)
        attachment0.Position = Vector3.new(0, -0.5, 0)
        attachment1.Position = Vector3.new(0, -0.5, -1)

        trail.Attachment0 = attachment0
        trail.Attachment1 = attachment1
        trail.Parent = humanoidRootPart

        getgenv().Visuals.TrailInstance = trail
    end
end

local function updateTrail()
    if getgenv().Visuals.TrailEnabled then
        if not getgenv().Visuals.TrailInstance or not getgenv().Visuals.TrailInstance.Parent then
            createTrail()
        else
            getgenv().Visuals.TrailInstance.Enabled = true
            getgenv().Visuals.TrailInstance.Color = ColorSequence.new(getgenv().Visuals.TrailColor)
        end
    elseif getgenv().Visuals.TrailInstance then
        getgenv().Visuals.TrailInstance:Destroy()
        getgenv().Visuals.TrailInstance = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if getgenv().Visuals.TrailEnabled then
        createTrail() -- Tworzenie nowego traila po respawnie
    end
    updateForceField()
end)

RunService.Heartbeat:Connect(function()
    updateForceField()
    updateForceFieldGun()
    updateTrail()
end)
