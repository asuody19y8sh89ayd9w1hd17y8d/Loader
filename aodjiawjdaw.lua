getgenv().Zoom = {
    Enabled = false -- Set this to true or false to enable/disable the zoom
}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local defaultMaxZoom = 100
local currentMaxZoom = defaultMaxZoom  -- Store the initial max zoom

-- Initially set the camera's max zoom distance to the default value
player.CameraMaxZoomDistance = defaultMaxZoom

local isEnabled = getgenv().Zoom.Enabled

local function onMouseWheel(input, gameProcessed)
    if not isEnabled or gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local currentZoom = (camera.CFrame.Position - camera.Focus.Position).Magnitude
        
        if input.Position.Z < 0 then
            if currentZoom >= currentMaxZoom * 0.9 then
                currentMaxZoom = currentMaxZoom * 1.5
                player.CameraMaxZoomDistance = currentMaxZoom
            end
        end
    end
end

-- Function to toggle the zoom functionality on or off
local function toggleZoom(state)
    getgenv().Zoom.Enabled = state
    isEnabled = state

    if not isEnabled then
        -- When disabled, set CameraMaxZoomDistance back to the default value
        player.CameraMaxZoomDistance = defaultMaxZoom
    end
end

UserInputService.InputChanged:Connect(onMouseWheel)
