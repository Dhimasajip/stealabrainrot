-- Memastikan skrip tidak berjalan dua kali
if getgenv().__KAMI_FIXED_RUNNING then return end
getgenv().__KAMI_FIXED_RUNNING = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- Konfigurasi yang lebih aman
local SETTINGS = {
    GRAB_RADIUS = 30,
    CHASE_DELAY = 1.2, -- Ditambah agar tidak terlihat seperti bot kaku
    RETRY_INTERVAL = 1.5,
    MOVE_TIMEOUT = 8
}

-- Fungsi pembantu untuk pergerakan yang lebih halus
local function safeMoveTo(humanoid, hrp, targetPos)
    local goal = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
    humanoid:MoveTo(goal)
    
    local start = tick()
    while tick() - start < SETTINGS.MOVE_TIMEOUT do
        if (hrp.Position - goal).Magnitude <= 4 then return true end
        task.wait(0.2)
    end
    return false
end

-- Perbaikan pada Sistem Purchase (Anti-Spam) 
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText == "Purchase" then
        -- Memberikan jeda acak agar tidak terlihat seperti skrip instan
        task.wait(math.random(0.3, 0.7)) 
        fireproximityprompt(prompt)
    end
end)

-- Perbaikan Auto-Equip Speed Coil (Menghapus loop task.wait(0)) 
local function equipSpeedCoil()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    
    if hum and backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), "speed") then
                hum:EquipTool(tool)
                break
            end
        end
    end
end

-- Menjalankan cek equip setiap 5 detik, bukan setiap milidetik agar tidak lag/kick 
task.spawn(function()
    while true do
        equipSpeedCoil()
        task.wait(5)
    end
end)

-- Perbaikan Anti-AFK (Menghapus VirtualInputManager yang berbahaya)
-- Menggunakan simulasi IDLE bawaan Roblox yang lebih aman
player.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
end)

print("Skrip berhasil dioptimasi. Tetap gunakan dengan bijak.")
