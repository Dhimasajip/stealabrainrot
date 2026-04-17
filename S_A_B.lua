-- Menggunakan nama variabel acak agar tidak terkena blacklist nama variabel 
if getgenv()._INTERNAL_SECURE_VER then return end
getgenv()._INTERNAL_SECURE_VER = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- KONFIGURASI TARGET
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

-- 1. PERGERAKAN YANG SANGAT MANUSIAWI (Bypass Deteksi Pergerakan Kaku) 
local function humanMoveTo(targetPos)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        -- Menambahkan offset acak yang lebih besar agar tidak presisi seperti bot [cite: 4]
        local offset = Vector3.new(math.random(-3,3), 0, math.random(-3,3))
        local finalGoal = targetPos + offset
        
        hum:MoveTo(finalGoal)
        
        local start = tick()
        while (hrp.Position - finalGoal).Magnitude > 6 do
            if tick() - start > 12 then break end 
            task.wait(0.5) -- Interval pengecekan diperlambat agar tidak membebani server
        end
        -- Jeda istirahat seolah-olah pemain sedang melihat layar
        task.wait(math.random(2, 4)) 
    end
end

-- 2. SISTEM PEMBELIAN DENGAN JEDA LAMA (Bypass BAC-9511 Purchase Scan) 
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end
    
    -- Jeda ditingkatkan menjadi 2-3 detik (Sangat Aman) 
    task.wait(math.random(20, 35) / 10) 
    
    pcall(function()
        fireproximityprompt(prompt)
    end)
end)

-- 3. KOORDINAT TUNGGAL DARI GAMBAR ANDA [cite: 4]
local SINGLE_TARGET = Vector3.new(-410.7376708984375, -6.403680801391602, 231.48736572265625) 

-- 4. LOOP UTAMA (Prioritas pada Keselamatan Akun)
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
                    task.wait(2)
                    break 
                end
            end
        end
        
        -- Jika tidak ada target, kembali ke koordinat standby Anda
        if not foundTarget then
            humanMoveTo(SINGLE_TARGET)
        end
        
        task.wait(5) -- Jeda antar siklus diperlama agar tidak terdeteksi botting 
    end
end)

-- 5. ANTI-AFK TANPA INPUT KEYBOARD (Bypass Deteksi VirtualInput) 
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(200)
    end
end)

print("Secure Mode Loaded: Fokus Koordinat -410.7, -6.4, 231.4")
