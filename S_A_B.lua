--[[ 
    FINAL REVISED: FORCE MOVE VERSION
    - Koordinat: -412.61, -6.40, 218.96
    - Masalah: Karakter tidak bergerak (FIXED)
    - Keamanan: No VirtualInput, No Coil (Anti-Ban)
]]

if getgenv().__SECURE_FORCE_RUN then return end
getgenv().__SECURE_FORCE_RUN = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- 1. KOORDINAT TARGET
local LOCK_POINT = Vector3.new(-412.615478515625, -6.403680801391602, 218.9698028564453)

-- 2. KONFIGURASI TARGET LIST
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().BUY_RANGE = 15

local function isTarget(m)
    local idx = m:GetAttribute("Index")
    if not idx then return false end
    for _, v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return true end
    end
    return false
end

-- 3. FUNGSI GERAK PAKSA (Agar Karakter Pasti Jalan)
local function forceMoveToPoint(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    print("Memulai pergerakan ke koordinat baru...")
    
    -- Menggunakan loop kecil agar perintah MoveTo tidak terabaikan oleh game
    local attempt = 0
    repeat
        hum:MoveTo(pos)
        task.wait(0.5)
        attempt = attempt + 1
    until (hrp.Position - pos).Magnitude < 3 or attempt > 20
    
    print("Karakter telah sampai di lokasi atau timeout.")
end

-- 4. LOGIKA PEMBELIAN (Anti-Kick BAC-9511)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        -- Jeda manusiawi agar tidak terdeteksi (2 detik)
        task.wait(2) 
        
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end)

-- 5. JALANKAN GERAKAN PERTAMA KALI
task.spawn(function()
    forceMoveToPoint(LOCK_POINT)
end)

-- 6. LOOP PENJAGA (Menjaga agar tetap di titik tersebut)
task.spawn(function()
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp then
            -- Jika terdorong atau bergeser jauh, balikkan ke titik target
            if (hrp.Position - LOCK_POINT).Magnitude > 5 then
                hum:MoveTo(LOCK_POINT)
            end
        end
        task.wait(3)
    end
end)

-- 7. ANTI-AFK AMAN
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(240)
    end
end)

print("Skrip Aktif: Karakter dipaksa bergerak ke koordinat baru.")
