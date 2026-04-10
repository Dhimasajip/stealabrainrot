-- [[ KAMIAPA MAIN SCRIPT - FULL & FIXED ]]
if getgenv().__KAMI_APA_MAIN_RUNNING then return end
getgenv().__KAMI_APA_MAIN_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- [[ KOORDINAT TITIK AMAN ]]
local HOME_POS = Vector3.new(-410.1356201171875, -6.501974582672119, 208.25595092773438) 
local RETURN_DISTANCE = 2 

-- [[ FUNGSI DETEKSI TARGET ]]
local function isTarget(model)
    if not getgenv().TARGET_LIST then return false end
    
    local name = model:GetAttribute("Index") or model.Name
    local billboard = model:FindFirstChildOfClass("BillboardGui")
    local textLabel = billboard and billboard:FindFirstChildOfClass("TextLabel")
    local screenName = textLabel and textLabel.Text or ""

    for _, targetName in ipairs(getgenv().TARGET_LIST) do
        -- Cek kecocokan nama pada atribut, nama model, atau teks melayang
        if string.find(string.lower(name), string.lower(targetName)) or 
           string.find(string.lower(screenName), string.lower(targetName)) then
            return true
        end
    end
    return false
end

-- [[ STAY AT HOME & RETURN ON HIT ]]
task.spawn(function()
    local lastHealth = 100
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 then
            local targetPos = Vector3.new(HOME_POS.X, root.Position.Y, HOME_POS.Z)
            
            -- Balik instan jika dipukul
            if hum.Health < lastHealth then
                root.CFrame = CFrame.new(targetPos)
            end

            -- Selalu kembali ke titik aman jika terdorong
            if (root.Position - targetPos).Magnitude >= RETURN_DISTANCE then
                hum:MoveTo(targetPos)
            end
            lastHealth = hum.Health
        end
        task.wait(0.1)
    end
end)

-- [[ AUTO PURCHASE (ANTI-MISS) ]]
ProximityPromptService.PromptShown:Connect(function(prompt)
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and isTarget(model) then
        task.wait(0.15) -- Jeda sedikit agar server menerima input
        fireproximityprompt(prompt)
        print("KAMIAPA: Berhasil membeli " .. model.Name)
    end
end)

-- [[ AUTO SPEED COIL (ANTI-SPAM) ]]
task.spawn(function()
    while true do
        local char = player.Character
        local backpack = player:FindFirstChildOfClass("Backpack")
        
        if char and backpack then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local holdingCoil = false
            
            -- Cek apakah sudah pegang coil
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "speed") or string.find(string.lower(tool.Name), "coil")) then
                    holdingCoil = true
                    break
                end
            end

            -- Jika belum pegang, baru equip
            if not holdingCoil then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "speed") or string.find(string.lower(tool.Name), "coil")) then
                        hum:EquipTool(tool)
                        break
                    end
                end
            end
        end
        task.wait(5)
    end
end)

-- [[ ANTI-AFK ]]
task.spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
        task.wait(300)
    end
end)

print("KAMIAPA: Skrip Berhasil Dimuat dari GitHub!")
