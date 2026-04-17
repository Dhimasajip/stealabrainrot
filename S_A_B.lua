-- Menggunakan nama variabel acak agar tidak mudah di-scan sistem
local _G_SECURE_MODE = true 

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- Koordinat target dengan sedikit variasi (agar tidak terdeteksi botting posisi)
local WAYPOINTS = {
    Vector3.new(-348.1, -7.0, 200.2),
    Vector3.new(-318.0, -7.0, 173.3),
    Vector3.new(-351.6, -7.0, 140.6),
    -- ... (tambahkan koordinat lainnya di sini)
}

-- 1. Pergerakan yang Lebih Manusiawi
local function walkTo(targetPos)
    -- Menambahkan "Random Offset" agar posisi tidak selalu sama persis
    local randomOffset = Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
    local finalGoal = targetPos + randomOffset
    
    hum:MoveTo(finalGoal)
    
    -- Menunggu sampai tiba dengan batas waktu (timeout)
    local start = tick()
    while (root.Position - finalGoal).Magnitude > 5 do
        if tick() - start > 10 then break end -- Berhenti jika tersangkut
        task.wait(0.5)
    end
    
    -- Jeda acak antar titik agar tidak terlihat seperti bot
    task.wait(math.random(1, 3)) 
end

-- 2. Anti-AFK yang Lebih Aman (Tanpa VirtualInputManager)
-- VirtualInputManager adalah pemicu utama kick BAC-9511
player.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(0.5)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- 3. Auto-Equip yang Tidak Spamming
task.spawn(function()
    while _G_SECURE_MODE do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            local coil = backpack:FindFirstChildWhichIsA("Tool") -- Mencari tool apa saja
            if coil and not char:FindFirstChild(coil.Name) then
                hum:EquipTool(coil)
            end
        end
        task.wait(10) -- Cek setiap 10 detik saja, jangan 0 detik
    end
end)

-- Loop Pergerakan Utama
task.spawn(function()
    while _G_SECURE_MODE do
        for _, wp in ipairs(WAYPOINTS) do
            walkTo(wp)
        end
        task.wait(math.random(15, 30)) -- Istirahat panjang setelah satu putaran
    end
end)

print("Secure Script Loaded - Jalur pergerakan kini diacak.")
