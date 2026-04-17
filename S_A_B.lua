--[[ 
    FINAL REVISED SCRIPT
    - Fokus Koordinat Baru: -410.73, -6.40, 231.48
    - Sistem Beli: Diperbaiki agar mengejar target di sekitar titik tersebut
    - Keamanan: No Coil, No VirtualInput, Jeda Manusiawi
]]

if getgenv()._FINAL_STRICT_RUN then return end
getgenv()._FINAL_STRICT_RUN = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- KONFIGURASI TARGET
local MY_POINT = Vector3.new(-410.7376708984375, -6.403680801391602, 231.48736572265625) --
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {} --
getgenv().GRAB_RADIUS = 30 --

local function getUnitID(m)
    return m:GetAttribute("Index") or m.Name --
end

local function isTarget(m)
    local idx = m:GetAttribute("Index") --
    if not idx then return false end
    for _, v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return true end --
    end
    return false
end

-- 1. FUNGSI JALAN (Dengan Toleransi Jarak)
local function goTo(targetPos)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        -- Gunakan sedikit variasi agar tidak terdeteksi kaku
        local goal = targetPos + Vector3.new(math.random(-1,1), 0, math.random(-1,1))
        hum:MoveTo(goal) --
        
        local s = tick()
        while (hrp.Position - goal).Magnitude > 4 do
            if tick() - s > 8 then break end 
            task.wait(0.2)
        end
    end
end

-- 2. SISTEM PEMBELIAN OTOMATIS (Diperbaiki)
-- Fungsi ini akan memicu 'E' saat prompt muncul
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end --
    
    -- Jeda agar tidak terkena kick BAC-9511
    task.wait(math.random(10, 18) / 10) 
    
    pcall(function()
        fireproximityprompt(prompt) --
    end)
end)

-- 3. LOOP UTAMA: SCAN -> MOVE -> BUY
task.spawn(function()
    while true do
        local foundItem = false
        
        -- Scan apakah ada item target di sekitar koordinat Anda
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and isTarget(o) then
                local part = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart") --
                if part and o.Parent then
                    -- Jika ada target, tinggalkan titik koordinat sebentar untuk membeli
                    goTo(part.Position)
                    foundItem = true
                    task.wait(1)
                    break 
                end
            end
        end
        
        -- Jika tidak ada item yang muncul, kembali/tetap di koordinat Anda
        if not foundItem then
            goTo(MY_POINT)
        end
        
        task.wait(1.5)
    end
end)

-- 4. ANTI-AFK AMAN (Tanpa Keyboard SendKeyEvent)
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(200)
    end
end)

print("Script Fixed: Menetap di koordinat baru dan akan mengejar item target jika muncul.")
