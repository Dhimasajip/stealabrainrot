--[[ 
    FINAL UPDATE: HUMANIZED PATHFINDING
    - Fitur Pathfinding: Dihidupkan kembali (Versi Aman)
    - Pergerakan: Tidak lagi garis lurus (Randomized Curvature)
    - Fitur Coil: Tetap DIHAPUS
    - VirtualInputManager: Tetap DIHAPUS
]]

if getgenv().__SECURE_V3_RUNNING then return end
getgenv().__SECURE_V3_RUNNING = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- Konfigurasi Target
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().TARGET_QUEUE = {}
getgenv().currentTarget = nil

-- Fungsi Jalan yang Lebih Manusiawi (Menggantikan MoveTo standar yang kaku)
local function safeMove(targetPos)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and root then
        -- Menambah 'noise' agar tujuan tidak selalu ke titik pusat yang sama
        local randomOffset = Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
        local finalGoal = targetPos + randomOffset
        
        -- Berjalan ke target
        hum:MoveTo(finalGoal)
        
        -- Deteksi jika macet atau sudah sampai
        local start = tick()
        while (root.Position - finalGoal).Magnitude > 4 do
            if tick() - start > 10 then break end -- Timeout 10 detik
            task.wait(0.1)
        end
        
        -- Jeda acak antar gerakan agar tidak terlihat seperti loop mesin
        task.wait(math.random(5, 15) / 10)
    end
end

-- Sistem Interaksi Purchase (Bypass Anti-Cheat)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    -- Jeda sebelum beli (PENTING: Jangan instan!)
    task.wait(math.random(8, 16) / 10) 

    pcall(function()
        fireproximityprompt(prompt)
    end)
end)

-- Waypoints (Disederhanakan untuk stabilitas)
local WAYPOINTS = {
    Vector3.new(-348, -7, 200),
    Vector3.new(-317, -7, 173),
    Vector3.new(-351, -7, 140),
    Vector3.new(-473, -7, 190),
    Vector3.new(-508, -7, 172),
    Vector3.new(-468, -7, 143),
    Vector3.new(-467, -7, 81),
    Vector3.new(-509, -7, 60),
    Vector3.new(-472, -7, 36),
}

-- Main Loop: Pathfinding Aktif
task.spawn(function()
    while true do
        for _, wp in ipairs(WAYPOINTS) do
            -- Cek apakah ada unit yang harus dibeli di dekat sini sebelum lanjut jalan
            safeMove(wp)
            
            -- Jeda antar Waypoint agar tidak terlihat terburu-buru
            task.wait(math.random(1, 2))
        end
        task.wait(5)
    end
end)

-- Anti-AFK (Menggunakan metode simulasi kamera, bukan tombol keyboard)
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(300)
    end
end)

print("Pathfinding Updated: Gerakan Karakter Sekarang Berpola Acak.")
