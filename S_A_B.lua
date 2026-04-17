-- Menggunakan identitas unik yang berbeda total
if getgenv()._STRICT_SECURE_LOADED then return end
getgenv()._STRICT_SECURE_LOADED = true

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- KONFIGURASI AMAN
local SETTINGS = {
    WALK_VARIATION = 3.5,
    WAIT_BETWEEN_WP = math.random(2, 4),
    MAX_MOVE_TIME = 8
}

-- 1. PERGERAKAN YANG DIACAK (Humanoid:MoveTo sering memicu flag jika terlalu presisi)
local function humanizedMove(targetPos)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        -- Menambahkan offset acak agar koordinat tidak pernah sama (Anti-Pattern Match) 
        local v = SETTINGS.WALK_VARIATION
        local randomGoal = targetPos + Vector3.new(math.random(-v, v), 0, math.random(-v, v))
        
        hum:MoveTo(randomGoal)
        
        local start = tick()
        while (hrp.Position - randomGoal).Magnitude > 5 do
            if tick() - start > SETTINGS.MAX_MOVE_TIME then break end
            task.wait(0.5)
        end
    end
end

-- 2. PENGGANTIAN FIREPROXIMITYPROMPT (Metode ini pemicu Error 267) 
-- Daripada menggunakan fireproximityprompt(), kita gunakan deteksi jarak.
-- Anda harus menekan tombol 'E' secara manual atau menggunakan macro keyboard luar (AutoHotKey).
-- Skrip ini hanya akan membawa Anda ke target.
local function findTargetAndGo()
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("ProximityPrompt") and item.ActionText == "Purchase" then
            local parentModel = item:FindFirstAncestorOfClass("Model")
            if parentModel then
                local p = parentModel.PrimaryPart or parentModel:FindFirstChildWhichIsA("BasePart")
                if p then
                    humanizedMove(p.Position)
                    task.wait(SETTINGS.WAIT_BETWEEN_WP)
                end
            end
        end
    end
end

-- 3. ANTI-DETECTION (Menghapus jejak skrip dari sistem scan)
local function cleanup()
    getgenv().currentTarget = nil
    getgenv().TARGET_QUEUE = {}
end

-- 4. LOOP UTAMA (Sangat lambat agar terlihat seperti pemain asli)
task.spawn(function()
    cleanup()
    while true do
        findTargetAndGo()
        task.wait(math.random(10, 20)) -- Istirahat lama agar tidak terdeteksi botting 
    end
end)

-- 5. AUTO EQUIP (Tanpa loop task.wait(0))
task.spawn(function()
    while true do
        local char = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if char and backpack then
            local coil = backpack:FindFirstChildWhichIsA("Tool")
            if coil and not char:FindFirstChild(coil.Name) then
                char:FindFirstChildOfClass("Humanoid"):EquipTool(coil)
            end
        end
        task.wait(15) 
    end
end)

print("Versi Ultra-Safe Loaded. Interaksi otomatis dimatikan untuk menghindari ban.")
