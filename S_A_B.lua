-- Menggunakan identitas unik yang berbeda total untuk menghindari blacklist nama variabel
if getgenv()._STRICT_SECURE_LOADED then return end
getgenv()._STRICT_SECURE_LOADED = true

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- KONFIGURASI ULTRA AMAN
local SETTINGS = {
    WALK_VARIATION = 4.5, -- Membuat karakter tidak jalan ke titik yang sama persis
    WAIT_BETWEEN_WP = math.random(3, 6), -- Jeda antar titik yang lebih lama
    MAX_MOVE_TIME = 12
}

-- 1. PERGERAKAN YANG DIACAK (Humanoid:MoveTo memicu flag jika terlalu presisi)
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
        while (hrp.Position - randomGoal).Magnitude > 6 do
            if tick() - start > SETTINGS.MAX_MOVE_TIME then break end
            task.wait(0.5)
        end
        -- Berhenti sejenak seolah-olah pemain sedang berpikir
        task.wait(math.random(1, 2))
    end
end

-- 2. PENGGANTIAN FIREPROXIMITYPROMPT (Metode ini pemicu Error 267 paling sering) 
-- Skrip ini sekarang hanya membawa Anda ke target. 
-- Disarankan untuk interaksi (E) dilakukan secara manual atau dengan autoclicker luar.
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

-- 3. PEMBERSIHAN JEJAK (Menghapus variabel yang mungkin di-scan) 
local function cleanup()
    getgenv().currentTarget = nil
    getgenv().TARGET_QUEUE = {}
    getgenv().__KAMI_APA_MAIN_RUNNING = nil -- Menghapus sisa variabel lama
end

-- 4. LOOP UTAMA (Sangat lambat agar terlihat seperti pemain asli)
task.spawn(function()
    cleanup()
    while true do
        findTargetAndGo()
        -- Istirahat sangat lama setelah satu putaran agar tidak terdeteksi botting 
        task.wait(math.random(20, 40)) 
    end
end)

-- 5. AUTO EQUIP (Tanpa loop task.wait(0) yang memicu spam deteksi) 
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
        task.wait(15) -- Cek setiap 15 detik saja
    end
end)

print("Versi Ultra-Safe Loaded. Pola pergerakan kini diacak total.")
