--[[ 
    FINAL SECURE VERSION 
    - Fokus Koordinat: -412.61, -6.40, 218.96
    - Sistem: Hanya Diam & Menunggu (Lock Position)
    - Keamanan: No VirtualInput, No Speed Coil Loop 
]]

if getgenv().__ULTRA_SECURE_RUNNING then return end
getgenv().__ULTRA_SECURE_RUNNING = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- 1. KOORDINAT BARU (DARI GAMBAR ANDA)
local LOCK_POINT = Vector3.new(-412.615478515625, -6.403680801391602, 218.9698028564453)

-- 2. KONFIGURASI TARGET
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {} [cite: 1]
getgenv().BUY_RANGE = 15 -- Jarak interaksi aman

local function isTarget(m)
    local idx = m:GetAttribute("Index") [cite: 1]
    if not idx then return false end
    for _, v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return true end [cite: 2]
    end
    return false
end

-- 3. LOGIKA PEMBELIAN AMAN (DENGAN JEDA MANUSIAWI)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end [cite: 3]
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        -- Jeda acak agar tidak terdeteksi bot (1.5 - 3 detik)
        task.wait(math.random(15, 30) / 10) 
        
        pcall(function()
            fireproximityprompt(prompt) [cite: 3]
        end)
    end
end)

-- 4. LOOP UTAMA: MENJAGA POSISI
task.spawn(function()
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp then
            -- Memastikan karakter berada di titik koordinat baru
            if (hrp.Position - LOCK_POINT).Magnitude > 2 then
                hum:MoveTo(LOCK_POINT)
            end
        end
        task.wait(2)
    end
end)

-- 5. ANTI-AFK AMAN (TANPA KEYBOARD INPUT)
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(240)
    end
end)

print("Script Locked: Karakter akan diam di koordinat baru dan membeli target saat muncul.")
