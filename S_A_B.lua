--[[ 
    ULTRA SECURE VERSION
    - Koordinat Tunggal: -410.73, -6.40, 231.48
    - Perbaikan Target: Memastikan hanya membeli item di TARGET_LIST
    - Keamanan: Menghapus VirtualInputManager & Fitur Coil
]]

if getgenv().__SECURE_FINAL_FIX then return end
getgenv().__SECURE_FINAL_FIX = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- 1. KONFIGURASI TARGET (HANYA KOORDINAT DARI GAMBAR)
local MY_POINT = Vector3.new(-410.7376708984375, -6.403680801391602, 231.48736572265625)
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().GRAB_RADIUS = 25 -- Jarak diperdekat agar tidak membeli barang yang jauh

local function getUnitID(m)
    return m:GetAttribute("Index") or m.Name
end

-- Memastikan hanya item yang terdaftar di TARGET_LIST yang diproses
local function isTarget(m)
    local idx = m:GetAttribute("Index")
    if not idx then return false end
    for _, v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return true end
    end
    return false
end

-- 2. FUNGSI PERGERAKAN (DIBUAT SANGAT LAMBAT AGAR AMAN)
local function secureMove(targetPos)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        -- Menambah variasi acak agar tidak terdeteksi pola bot
        local goal = targetPos + Vector3.new(math.random(-2,2), 0, math.random(-2,2))
        hum:MoveTo(goal)
        
        local s = tick()
        while (hrp.Position - goal).Magnitude > 5 do
            if tick() - s > 10 then break end 
            task.wait(0.5)
        end
    end
end

-- 3. LOGIKA PEMBELIAN (DIBERIKAN JEDA LAMA AGAR TIDAK TERDETEKSI)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    -- Memberikan jeda manusiawi (1.5 - 3 detik) agar tidak terkena BAC-9511
    task.wait(math.random(15, 30) / 10) 
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end)

-- 4. LOOP UTAMA: STANDBY DI TITIK KOORDINAT
task.spawn(function()
    while true do
        local foundItem = false
        
        -- Hanya scan item di sekitar karakter agar tidak lari terlalu jauh
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and isTarget(o) then
                local part = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                if part and o.Parent then
                    local dist = (player.Character.HumanoidRootPart.Position - part.Position).Magnitude
                    if dist <= getgenv().GRAB_RADIUS then
                        secureMove(part.Position)
                        foundItem = true
                        task.wait(2)
                        break
                    end
                end
            end
        end
        
        -- Kembali ke koordinat utama jika tidak ada item target
        if not foundItem then
            secureMove(MY_POINT)
        end
        
        task.wait(3) -- Jeda antar siklus diperlama agar tidak spamming
    end
end)

-- 5. ANTI-AFK (METODE AMAN TANPA SIMULASI KEYBOARD)
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(240)
    end
end)

print("Script Fixed: Standby di koordinat baru, hanya beli item yang sesuai target.")
