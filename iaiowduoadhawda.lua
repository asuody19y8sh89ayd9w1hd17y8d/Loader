getgenv().NoRecoil = {
    Enabled = false
}

-- Funkcja sprawdzająca, czy skrypt to "Framework"
function isframework(scriptInstance)
    return tostring(scriptInstance) == "Framework"
end

-- Funkcja sprawdzająca argumenty
function checkArgs(instance, index)
    return tostring(instance):lower():find("camera") and tostring(index) == "CFrame"
end

-- Hookowanie funkcji __newindex
local newindex
newindex = hookmetamethod(game, "__newindex", function(self, index, value)
    if not getgenv().NoRecoil.Enabled then  -- Jeśli NoRecoil jest wyłączone, nie rób nic
        return newindex(self, index, value)
    end

    local callingScr = getcallingscript()
    if isframework(callingScr) and checkArgs(self, index) then
        return  -- Blokuje zmianę CFrame kamery, jeśli NoRecoil jest włączone
    end

    return newindex(self, index, value)
end)
