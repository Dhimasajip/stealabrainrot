-- Menggunakan identitas acak total untuk menghindari blacklist variabel
if getgenv()._SHADOW_RUN_2024 then return end
getgenv()._SHADOW_RUN_2024 = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- KONFIGURASI TARGET DARI GAMBAR ANDA
local NEW_POSITION = Vector3.new(-410.7376708984375, -6.403680801391602, 231.48736572265625) -- 
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().GRAB_RADIUS = 30 

-- 1. PERGERAKAN YANG SANGAT LAMBAT (Anti-Detection)
local function secureMove(targetPos)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        -- Menambahkan variasi jarak agar tidak tepat di titik pusat (Bypass deteksi bot kaku)
        local offset = Vector3.new(math.random(-4, 4), 0, math.random(-4, 4))
        local goal = targetPos + offset
        
        hum:MoveTo(goal)
        
        -- Menunggu dengan jeda lebih lama agar pergerakan terlihat alami
        local s = tick()
        while (hrp.Position - goal).Magnitude > 6 do
            if tick() - s > 15 then break end 
            task.wait(1) -- Memperlambat pengecekan posisi
        end
        task.wait(math.random(3, 7)) -- Istirahat panjang seolah pemain asli
    end
end

-- 2. INTERAKSI BELI YANG SANGAT AMAN
-- BAC-9511 mendeteksi jika fireproximityprompt dipanggil terlalu cepat 
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    -- Jeda 3-5 detik (Meniru kecepatan manusia yang sedang melihat barang)
    task.wait(math.random(30, 50) / 10) 
    
    pcall(function()
        fireproximityprompt(prompt)
    end)
end)

-- 3. LOOP UTAMA (Patroli hanya di koordinat baru)
task.spawn(function()
    while true do
        local char = player.Character
        if char then
            -- Hanya menuju ke koordinat yang Anda berikan 
            secureMove(NEW_POSITION)
        end
        task.wait(math.random(10, 20)) -- Istirahat sangat lama antar siklus
    end
end)

-- 4. ANTI-AFK TANPA KEYBOARD (Bypass VirtualInputManager)
-- VirtualInputManager adalah pemicu utama Error 267 [cite: 1, 4]
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(250)
    end
end)

print("Script Ghost Version: Koordinat Tunggal Aktif.")
