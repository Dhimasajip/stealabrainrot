--[[ 
    ULTRA-LOCK VERSION
    - Gerakan: DIKUNCI (Hanya diam di koordinat baru)
    - Pembelian: Hanya jika item nempel/sangat dekat [cite: 1]
    - Filter: Hanya membeli ID yang ada di TARGET_LIST 
]]

if getgenv().__LOCK_FINAL_STRICT then return end
getgenv().__LOCK_FINAL_STRICT = true

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- 1. KOORDINAT TETAP (DARI GAMBAR)
local STAY_POINT = Vector3.new(-410.7376708984375, -6.403680801391602, 231.48736572265625)

-- 2. KONFIGURASI TARGET
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {} [cite: 1]
getgenv().FORGOTTEN_UNITS = {} [cite: 1]
getgenv().BUY_RANGE = 10 -- Jarak sangat dekat agar tidak lari-lari

local function isTarget(m)
    local idx = m:GetAttribute("Index") [cite: 1]
    if not idx then return false end
    for _, v in ipairs(getgenv().TARGET_LIST) do
        if idx == v then return true end [cite: 2]
    end
    return false
end

-- 3. LOGIKA PEMBELIAN AMAN (ANTI-KICK BAC-9511)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if prompt.ActionText ~= "Purchase" then return end [cite: 3]
    
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then [cite: 1, 3]
        -- Jeda manusiawi agar tidak terdeteksi bot
        task.wait(math.random(20, 35) / 10) 
        
        pcall(function()
            fireproximityprompt(prompt) [cite: 3]
        end)
    end
end)

-- 4. LOOP UTAMA: HANYA DIAM & MENUNGGU
task.spawn(function()
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp then
            -- Paksa karakter tetap di titik koordinat
            if (hrp.Position - STAY_POINT).Magnitude > 3 then
                hum:MoveTo(STAY_POINT) [cite: 4]
            end
        end
        
        -- Tidak ada perintah MoveTo ke item lain agar tidak bergerak ke mana-mana
        task.wait(2)
    end
end)

-- 5. ANTI-AFK TANPA KEYBOARD (BYPASS ERROR 267)
task.spawn(function()
    while true do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
        task.wait(200)
    end
end)

print("Karakter dikunci di koordinat. Hanya akan membeli jika target di TARGET_LIST muncul di dekat Anda.")
