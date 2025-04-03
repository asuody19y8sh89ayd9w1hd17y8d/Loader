getgenv().Yuth = {
    Enabled = false,
    usefov = true,
    Keybind = Enum.KeyCode.P,
    Prediction = 0,
    HitPart = "HumanoidRootPart",
    WallCheck = false,
    KnockCheck = false,
    resolver = true,

    FOV = {
        Radius = 200,
        Visible = false,
        Transparency = 1
    },
    
    Highlight = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.5
    },

    Tracer = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.6,
        Transparency = 1
    },

    Crosshair = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Rotation = false,
        Gap = 4,
        Length = 50,
        Thickness = 2.5,
        RotationSpeed = 25,
        Position = "Target",
        ShowText = false,
        TextColor = Color3.fromRGB(255, 255, 255)
    },

    TargetInfo = {
        Enabled = false,
        Position = {0.5, -100, 0.7, -1}, -- Ustawienia pozycji: {anchorX, offsetX, anchorY, offsetY}
        HealthBar = {Enabled = true, Color = Color3.fromRGB(0, 255, 0)}
    }
}

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local SilentAimTarget = nil
local HighlightObject = nil

local Inset, Mouse, Client, Vector2New, Cam =
    game:GetService("GuiService"):GetGuiInset().Y,
    game.Players.LocalPlayer:GetMouse(),
    game.Players.LocalPlayer,
    Vector2.new,
    workspace.CurrentCamera

local FOVCircle = Drawing.new("Circle")
FOVCircle.Transparency = getgenv().Yuth.FOV.Transparency
FOVCircle.Thickness = 1.6
FOVCircle.Color = Color3.fromRGB(230, 230, 250)
FOVCircle.Filled = false

local TracerLine = Drawing.new("Line")
TracerLine.Transparency = getgenv().Yuth.Tracer.Transparency
TracerLine.Thickness = getgenv().Yuth.Tracer.Thickness
TracerLine.Color = getgenv().Yuth.Tracer.Color

local Crosshair = {}
Crosshair.Lines = {}
Crosshair.Angle = 0

-- Funkcja tworząca linię
local function CreateLine()
    local Line = Drawing.new("Line")
    Line.Thickness = getgenv().Yuth.Crosshair.Thickness
    Line.Color = getgenv().Yuth.Crosshair.Color
    Line.Visible = getgenv().Yuth.Crosshair.Enabled
    return Line
end

-- Tworzenie 4 linii celownika
for i = 1, 4 do
    Crosshair.Lines[i] = CreateLine()
end

-- Tworzenie napisu pod celownikiem
local TextLabel = Drawing.new("Text")
TextLabel.Size = 20
TextLabel.Visible = getgenv().Yuth.Crosshair.ShowText
TextLabel.Text = "Invasion"
TextLabel.Outline = true
TextLabel.Color = getgenv().Yuth.Crosshair.TextColor

-- GUI dla informacji o celu
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local targetInfoPosition = getgenv().Yuth.TargetInfo.Position
Frame.Position = UDim2.new(targetInfoPosition[1], targetInfoPosition[2], targetInfoPosition[3], targetInfoPosition[4])
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.BackgroundTransparency = 0
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
Frame.BorderSizePixel = 3

local AvatarImage = Instance.new("ImageLabel", Frame)
AvatarImage.Position = UDim2.new(0, 10, 0, 10)
AvatarImage.Size = UDim2.new(0, 50, 0, 50)
AvatarImage.BackgroundTransparency = 1

local NameLabel = Instance.new("TextLabel", Frame)
NameLabel.Position = UDim2.new(0, 70, 0, 10)
NameLabel.Size = UDim2.new(0, 120, 0, 20)
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "Name: "
NameLabel.Font = Enum.Font.SourceSansBold
NameLabel.TextSize = 18

local HealthLabel = Instance.new("TextLabel", Frame)
HealthLabel.Position = UDim2.new(0, 70, 0, 40)
HealthLabel.Size = UDim2.new(0, 120, 0, 20)
HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HealthLabel.BackgroundTransparency = 1
HealthLabel.Text = "Health: "
HealthLabel.Font = Enum.Font.SourceSansBold
HealthLabel.TextSize = 18

local HealthBarFrame = Instance.new("Frame", Frame)
HealthBarFrame.Position = UDim2.new(0, 10, 1, -20)
HealthBarFrame.Size = UDim2.new(1, -20, 0, 10)
HealthBarFrame.BackgroundTransparency = 0.5
HealthBarFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
HealthBarFrame.BorderSizePixel = 0

local HealthBar = Instance.new("Frame", HealthBarFrame)
HealthBar.Size = UDim2.new(1, 0, 1, 0)
HealthBar.BackgroundColor3 = getgenv().Yuth.TargetInfo.HealthBar.Color
HealthBar.BorderSizePixel = 0

local function UpdateTargetInfo()
    if getgenv().Yuth.TargetInfo.Enabled and SilentAimTarget and SilentAimTarget.Character and SilentAimTarget.Character:FindFirstChild("Humanoid") then
        local Humanoid = SilentAimTarget.Character.Humanoid
        AvatarImage.Image = Players:GetUserThumbnailAsync(SilentAimTarget.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        NameLabel.Text = "Name: " .. SilentAimTarget.Name
        HealthLabel.Text = "Health: " .. math.floor(Humanoid.Health)
        HealthBar.Size = UDim2.new(Humanoid.Health / Humanoid.MaxHealth, 0, 1, 0)
        Frame.Size = UDim2.new(0, 90 + NameLabel.TextBounds.X, 0, 100)
        Frame.Visible = true
    else
        Frame.Visible = false
    end
end

local function UpdateFOV()
    if not getgenv().Yuth.Enabled then
        FOVCircle.Visible = false
        return
    end
    if not FOVCircle then return end
    FOVCircle.Position = Vector2New(Mouse.X, Mouse.Y + (Inset))
    FOVCircle.Visible = getgenv().Yuth.FOV.Visible and getgenv().Yuth.usefov
    FOVCircle.Radius = getgenv().Yuth.FOV.Radius
    return FOVCircle
end

local function UpdateTracer()
    if getgenv().Yuth.Enabled and getgenv().Yuth.Tracer.Enabled and SilentAimTarget and SilentAimTarget.Character and SilentAimTarget.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HeadPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(SilentAimTarget.Character.Head.Position)
        local StartPos, StartOnScreen = workspace.CurrentCamera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
        if OnScreen and StartOnScreen then
            TracerLine.From = Vector2.new(StartPos.X, StartPos.Y)
            TracerLine.To = Vector2.new(HeadPos.X, HeadPos.Y)
            TracerLine.Visible = true
        else
            TracerLine.Visible = false
        end
    else
        TracerLine.Visible = false
    end
end

local function UpdateCrosshair()
    if not getgenv().Yuth.Crosshair.Enabled or not SilentAimTarget then
        for _, line in pairs(Crosshair.Lines) do
            line.Visible = false
        end
        TextLabel.Visible = false
        return
    end

    local Center
    if getgenv().Yuth.Crosshair.Position == "Target" and SilentAimTarget and SilentAimTarget.Character then
        local TargetPart = SilentAimTarget.Character:FindFirstChild(getgenv().Yuth.HitPart)
        if TargetPart then
            Center = Vector2New(Camera:WorldToViewportPoint(TargetPart.Position).X, Camera:WorldToViewportPoint(TargetPart.Position).Y)
        else
            Center = Vector2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    elseif getgenv().Yuth.Crosshair.Position == "Mouse" then
        Center = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    else
        Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    local Gap = math.clamp(getgenv().Yuth.Crosshair.Gap, 0, 20)
    local Length = math.clamp(getgenv().Yuth.Crosshair.Length, 0, 150)
    local Thickness = math.clamp(getgenv().Yuth.Crosshair.Thickness, 0, 10)
    local RotationSpeed = math.clamp(getgenv().Yuth.Crosshair.RotationSpeed, 0, 1000)

    if getgenv().Yuth.Crosshair.Rotation then
        Crosshair.Angle = Crosshair.Angle + (RotationSpeed / 1000)
    end

    local Directions = {
        Vector2.new(1, 0),
        Vector2.new(-1, 0),
        Vector2.new(0, 1),
        Vector2.new(0, -1)
    }

    for i, Dir in ipairs(Directions) do
        local RotatedDir = Vector2.new(
            Dir.X * math.cos(Crosshair.Angle) - Dir.Y * math.sin(Crosshair.Angle),
            Dir.X * math.sin(Crosshair.Angle) + Dir.Y * math.cos(Crosshair.Angle)
        )

        local StartPos = Center + RotatedDir * Gap
        local EndPos = Center + RotatedDir * (Gap + Length)

        local Line = Crosshair.Lines[i]
        Line.From = StartPos
        Line.To = EndPos
        Line.Thickness = Thickness
        Line.Color = getgenv().Yuth.Crosshair.Color
        Line.Visible = true
    end

    -- Ustawienie tekstu pod celownikiem
    if getgenv().Yuth.Crosshair.ShowText then
        TextLabel.Position = Vector2.new(Center.X - (TextLabel.TextBounds.X / 2), Center.Y + Gap + Length + 10)
        TextLabel.Color = getgenv().Yuth.Crosshair.TextColor
        TextLabel.Visible = true
    else
        TextLabel.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    UpdateFOV()
    UpdateTracer()
    UpdateCrosshair()
    UpdateTargetInfo()
end)

local LastPositions = {}

local function CalculateVelocity(Character)
    if not getgenv().Yuth.Enabled then return Vector3.new(0, 0, 0) end
    if not LastPositions[Character] then
        LastPositions[Character] = {
            Position = Character.HumanoidRootPart.Position,
            Tick = tick()
        }
        return Vector3.new(0, 0, 0)
    end

    local LastData = LastPositions[Character]
    local DeltaTime = tick() - LastData.Tick
    local DeltaPosition = Character.HumanoidRootPart.Position - LastData.Position

    LastPositions[Character] = {
        Position = Character.HumanoidRootPart.Position,
        Tick = tick()
    }

    return DeltaPosition / DeltaTime
end

local function IsKnocked(target)
    local Humanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
    return Humanoid and Humanoid.Health <= 0
end

local function IsVisible(targetPart)
    local origin = game.Workspace.CurrentCamera.CFrame.Position
    local direction = (targetPart.Position - origin).unit * 500
    local ray = Ray.new(origin, direction)
    local hit, position = game.Workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
    return hit and hit:IsDescendantOf(targetPart.Parent)
end

local function GetClosestTarget()
    if not getgenv().Yuth.Enabled then return nil end
    local Target, Closest = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player ~= LocalPlayer then
            local HitPart = player.Character:FindFirstChild(getgenv().Yuth.HitPart)
            if HitPart then
                local Position, OnScreen = Camera:WorldToScreenPoint(HitPart.Position)
                local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                if Distance < Closest and OnScreen then
                    if getgenv().Yuth.usefov and Distance < getgenv().Yuth.FOV.Radius then
                        if getgenv().Yuth.WallCheck and not IsVisible(HitPart) then
                            continue
                        end
                        if getgenv().Yuth.KnockCheck and IsKnocked(player) then
                            continue
                        end
                        Closest = Distance
                        Target = player
                    elseif not getgenv().Yuth.usefov then
                        if getgenv().Yuth.WallCheck and not IsVisible(HitPart) then
                            continue
                        end
                        if getgenv().Yuth.KnockCheck and IsKnocked(player) then
                            continue
                        end
                        Closest = Distance
                        Target = player
                    end
                end
            end
        end
    end
    return Target
end

local function CreateHighlight(target)
    if not getgenv().Yuth.Enabled then return end
    if getgenv().Yuth.Highlight.Enabled and target and target.Character then
        if HighlightObject then HighlightObject:Destroy() end

        local highlight = Instance.new("Highlight")
        highlight.Adornee = target.Character
        highlight.Parent = game.CoreGui
        highlight.FillColor = getgenv().Yuth.Highlight.Color
        highlight.FillTransparency = getgenv().Yuth.Highlight.Transparency
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0

        HighlightObject = highlight
    end
end

local function RemoveHighlight()
    if HighlightObject then
        HighlightObject:Destroy()
        HighlightObject = nil
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == getgenv().Yuth.Keybind then
        if getgenv().Yuth.Enabled then
            getgenv().Yuth.Enabled = false
            SilentAimTarget = nil
            RemoveHighlight()
        else
            getgenv().Yuth.Enabled = true
            SilentAimTarget = GetClosestTarget()
            CreateHighlight(SilentAimTarget)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not getgenv().Yuth.Enabled then
        SilentAimTarget = nil
        RemoveHighlight()
        Frame.Visible = false
        return
    end

    if getgenv().Yuth.usefov then
        SilentAimTarget = GetClosestTarget()
        if SilentAimTarget then
            CreateHighlight(SilentAimTarget)
        else
            SilentAimTarget = nil
            RemoveHighlight()
        end
    else
        if SilentAimTarget then
            CreateHighlight(SilentAimTarget)
        else
            RemoveHighlight()
        end
    end
end)

local grmt = getrawmetatable(game)
local backupindex = grmt.__index
setreadonly(grmt, false)

grmt.__index = newcclosure(function(self, v)
    if getgenv().Yuth.Enabled and SilentAimTarget and tostring(v) == "Hit" then
        local hitPart = getgenv().Yuth.HitPart
        if SilentAimTarget.Character and SilentAimTarget.Character:FindFirstChild(hitPart) then
            local targetPart = SilentAimTarget.Character[hitPart]
            local Velocity = CalculateVelocity(SilentAimTarget.Character)
            local predictedPosition = targetPart.Position + (Velocity * getgenv().Yuth.Prediction)
            return CFrame.new(predictedPosition)
        end
    end
    return backupindex(self, v)
end)

setreadonly(grmt, true)
