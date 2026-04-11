-- [[ KAMIAPA MAIN SCRIPT - FIXED PURCHASE ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ KONFIGURASI POSISI ]]
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) 
local RETURN_DISTANCE = 2 

-- [[ FUNGSI CEK TARGET ]]
local function isTarget(model)
    if not getgenv().TARGET_LIST then return false end
    
    -- Cek berdasarkan Atribut "Index" atau Nama Model
    local name = model:GetAttribute("Index") or model.Name
    for _, targetName in ipairs(getgenv().TARGET_LIST) do
        if name == targetName then
            return true
        end
    end
    return false
end

-- [[ LOGIKA STAY & RETURN ON HIT ]]
task.spawn(function()
    local lastHealth = 100
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 then
            local currentPos = root.Position
            local targetPos = Vector3.new(HOME_POS.X, currentPos.Y, HOME_POS.Z)
            
            if hum.Health < lastHealth then
                root.CFrame = CFrame.new(targetPos)
            end

            if (currentPos - targetPos).Magnitude >= RETURN_DISTANCE then
                hum:MoveTo(targetPos)
            end
            lastHealth = hum.Health
        end
        task.wait(0.1)
    end
end)

-- [[ SISTEM AUTO PURCHASE - PERBAIKAN ]]
-- Fungsi ini akan mendeteksi setiap kali ProximityPrompt (tombol E) muncul
ProximityPromptService.PromptShown:Connect(function(prompt)
    -- Pastikan ini adalah prompt untuk membeli
    if prompt.ActionText == "Purchase" or prompt.ObjectText ~= "" then
        local model = prompt:FindFirstAncestorOfClass("Model")
        if model and isTarget(model) then
            task.wait(0.1) -- Jeda sebentar agar tidak terdeteksi spam
            fireproximityprompt(prompt)
            print("Berhasil membeli: " .. model.Name)
        end
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

print("KAMIAPA: Skrip Berhasil Dimuat!")
