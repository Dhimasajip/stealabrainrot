--[[ 
    FULL UPDATED SCRIPT (SINGLE TARGET MODE)
    - Semua koordinat lama: DIHAPUS
    - Koordinat baru dari gambar: DITAMBAHKAN 
    - Fitur Coil & Anti-AFK Keyboard: DIHAPUS (Bypass BAC-9511) 
]]

if getgenv().__KAMI_SINGLE_TARGET_RUNNING then return end
getgenv().__KAMI_SINGLE_TARGET_RUNNING = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- 1. KONFIGURASI TARGET
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().FORGOTTEN_UNITS = {}
getgenv().currentTarget = nil
getgenv().GRAB_RADIUS = 30 

local function getUnitID(m)
    return m:GetAttribute("Index") or m.Name
end

local function isTarget(m)
    local idx = m:GetAttribute("Index")
    if not idx then return false end
    for _,v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return true end
    end
    return false
end

-- 2. SISTEM PERGERAKAN MANUSIAWI
local function humanMoveTo(targetPos)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        -- Variasi posisi agar tidak terdeteksi pola bot kaku [cite: 1]
        local offset = Vector3.new(math.random(-2,2), 0, math.random(-2,2))
        local finalGoal = targetPos + offset
        
        hum:MoveTo(finalGoal)
        
        local start = tick()
        while (hrp.Position - finalGoal).Magnitude > 5 do
            if tick() - start > 10 then break end 
            task.wait(0.2)
        end
        task.wait(math.random(1, 2)) 
    end
end

-- 3. LOGIKA OTOMATIS BELI (Anti-Cheat Bypass)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    -- Jeda acak agar tidak terdeteksi mesin 
    task.wait(math.random(10, 18) / 10) 
    
    pcall(function()
        fireproximityprompt(prompt)
    end)
end)

-- 4. KOORDINAT TUNGGAL (Hanya koordinat terakhir yang Anda kirim)
local SINGLE_TARGET = Vector3.new(-410.7376708984375, -6.403680801391602, 231.48736572265625) -- 

-- 5. LOOP UTAMA: KEJAR ITEM ATAU STANDBY DI KOORDINAT
task.spawn(function()
    while true do
        local foundTarget = false
        
        -- Scan area untuk mencari unit target
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and isTarget(o) and not getgenv().FORGOTTEN_UNITS[getUnitID(o)] then
                local part = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                if part and o.Parent then
                    foundTarget = true
                    getgenv().currentTarget = o
                    humanMoveTo(part.Position)
                    task.wait(1.5)
                    break 
                end
            end
        end
        
        -- Jika tidak ada target muncul, pergi/tetap di koordinat baru Anda 
        if not foundTarget then
            humanMoveTo(SINGLE_TARGET)
        end
        
        task.wait(1)
    end
end)

-- 6. ANTI-AFK (Metode Aman)
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(240)
    end
end)

print("Skrip Aktif: Semua koordinat lama dihapus. Fokus pada koordinat baru.")
