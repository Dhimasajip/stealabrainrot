-- [[ KAMIAPA MAIN SCRIPT - COORDINATE FIXED ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ KOORDINAT TITIK AMAN BARU ]]
-- Menggunakan data dari image_9ac102.png
local HOME_POS = Vector3.new(-410.873046875, -6.403680801391602, -86.57219696044922) 
local RETURN_DISTANCE = 2 

-- [[ FUNGSI DETEKSI TARGET ]]
local function isTarget(model)
    if not getgenv().TARGET_LIST then return false end
    local name = model:GetAttribute("Index") or model.Name
    local billboard = model:FindFirstChildOfClass("BillboardGui")
    local textLabel = billboard and billboard:FindFirstChildOfClass("TextLabel")
    local screenName = textLabel and textLabel.Text or ""

    for _, targetName in ipairs(getgenv().TARGET_LIST) do
        if string.find(string.lower(name), string.lower(targetName)) or 
           string.find(string.lower(screenName), string.lower(targetName)) then
            return true
        end
    end
    return false
end

-- [[ STAY AT HOME - TETAP DI TITIK BARU ]]
task.spawn(function()
    local lastHealth = 100
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 then
            -- Ini yang mengatur agar karakter tetap di koordinat baru
            local targetPos = Vector3.new(HOME_POS.X, root.Position.Y, HOME_POS.Z)
            
            if hum.Health < lastHealth then
                root.CFrame = CFrame.new(targetPos)
            end

            if (root.Position - targetPos).Magnitude >= RETURN_DISTANCE then
                hum:MoveTo(targetPos)
            end
            lastHealth = hum.Health
        end
        task.wait(0.1)
    end
end)

-- [[ AUTO PURCHASE ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        task.wait(0.15) 
        fireproximityprompt(prompt)
    end
end)

-- [[ ANTI-AFK ]]
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
        task.wait(300)
    end
end)

print("KAMIAPA: Koordinat Baru Berhasil Diterapkan!")
