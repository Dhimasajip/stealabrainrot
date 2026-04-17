--[[ 
    SECURE WALKING VERSION (NO TELEPORT)
    - Metode: Humanoid:MoveTo (Jalan Kaki)
    - Koordinat: -412.61, -6.40, 218.96
    - Fitur: Auto-Purchase tetap aktif saat berjalan
]]

if getgenv().__SECURE_WALK_RUN then return end
getgenv().__SECURE_WALK_RUN = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- 1. KOORDINAT TARGET
local TARGET_POS = Vector3.new(-412.615478515625, -6.403680801391602, 218.9698028564453)

-- 2. KONFIGURASI TARGET LIST
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}

local function isTarget(m)
    local idx = m:GetAttribute("Index")
    if not idx then return false end
    for _, v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return true end
    end
    return false
end

-- 3. LOGIKA PEMBELIAN (Dibuat independen agar selalu siap)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        -- Jeda manusiawi (2 detik) agar tidak terdeteksi BAC-9511
        task.wait(2) 
        
        fireproximityprompt(prompt)
        print("Berhasil membeli: " .. model.Name)
    end
end)

-- 4. LOGIKA PERGERAKAN (Looping MoveTo)
task.spawn(function()
    while true do
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")
        
        -- Cek jarak, jika lebih dari 3 meter, jalan ke titik tersebut
        if (hrp.Position - TARGET_POS).Magnitude > 3 then
            hum:MoveTo(TARGET_POS)
        end
        
        -- Jeda pengecekan agar tidak spamming CPU
        task.wait(1) 
    end
end)

-- 5. ANTI-AFK (Metode Pasif)
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(240)
    end
end)

print("Skrip Aktif: Karakter akan jalan ke titik koordinat dan menunggu target.")
