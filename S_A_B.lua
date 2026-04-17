--[[ 
    ULTRA-FORCE VERSION (FINAL ATTEMPT)
    - Metode: Teleportasi Koordinat (Bypass MoveTo)
    - Koordinat: -412.61, -6.40, 218.96
    - Anti-Cheat: Menggunakan jeda panjang dan proteksi variabel
]]

if getgenv().__FORCE_ULTIMATE_RUN then return end
getgenv().__FORCE_ULTIMATE_RUN = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- 1. KOORDINAT TARGET
local LOCK_POINT = Vector3.new(-412.615478515625, -6.403680801391602, 218.9698028564453)

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

-- 3. FUNGSI TELEPORTASI (Jika MoveTo diblokir)
local function forceTeleport(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    -- Teleportasi langsung ke koordinat
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) 
    print("Teleportasi berhasil ke koordinat baru.")
end

-- 4. LOGIKA PEMBELIAN (Direct Execution)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        -- Jeda 2.5 detik (Sangat penting agar tidak kena kick instan)
        task.wait(2.5) 
        
        -- Memaksa interaksi
        task.spawn(function()
            fireproximityprompt(prompt)
        end)
        print("Mencoba membeli target: " .. model.Name)
    end
end)

-- 5. LOOP PENJAGA (Memastikan Karakter Tetap Di Sana)
task.spawn(function()
    -- Jalankan teleportasi pertama kali
    forceTeleport(LOCK_POINT)
    
    while true do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            -- Jika posisi melenceng lebih dari 10 meter, tarik balik (Teleport)
            if (hrp.Position - LOCK_POINT).Magnitude > 10 then
                forceTeleport(LOCK_POINT)
            end
        end
        task.wait(5)
    end
end)

-- 6. ANTI-AFK (Simulasi Klik Layar)
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(200)
    end
end)

print("Script Force Teleport Loaded. Karakter akan dipindahkan paksa ke koordinat.")
