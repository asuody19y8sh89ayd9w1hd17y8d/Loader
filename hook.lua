local MetaTable = getrawmetatable(game)
local OldIndex = MetaTable.__index
setreadonly(MetaTable, false)

MetaTable.__index = function(self, key)
    if not checkcaller() and self == localPlayer:GetMouse() and Invasion.Silent and Invasion.Silent.Enabled then
        if key == "Hit" or key == "Target" then
            local targetPlayer = getClosestPlayerToCursor(inf)
            if targetPlayer and targetPlayer.Character then
                local targetPart = targetPlayer.Character:FindFirstChild(Invasion.Silent.Part)
                if targetPart then
                    local velocity = targetPart.Velocity or Vector3.zero
                    local predictedPosition = targetPart.Position + (velocity * Invasion.Silent.Prediction)
                    return key == "Hit" and CFrame.new(predictedPosition) or targetPart
                end
            end
        end
    end
    return OldIndex(self, key)
end
setreadonly(MetaTable, true)
