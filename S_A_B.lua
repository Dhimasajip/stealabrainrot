--[[ 
    UPDATED FULL SCRIPT 
    - Menghapus VirtualInputManager (Pemicu Deteksi Utama)
    - Menambahkan Random Delay (Agar tidak terlihat seperti bot)
    - Menghapus Loop 0 Detik (Agar tidak spam server)
]]

if getgenv().__UPDATED_SECURE_RUNNING then return end
getgenv().__UPDATED_SECURE_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- Konfigurasi Default (Dioptimasi agar lebih lambat sedikit demi keamanan)
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().FORGOTTEN_UNITS = {}
getgenv().UNIT_SPAWN_COUNT = {}
getgenv().SEEN_UNIT_INSTANCES = {}

getgenv().MAX_SPAWN_BEFORE_FORGET = 15
getgenv().GRAB_RADIUS = 30
getgenv().TARGET_TIMEOUT = 25 
getgenv().CHASE_DELAY = 1.2 -- Diperlambat agar tidak terlihat kaku

getgenv().TARGET_QUEUE = {}
getgenv().currentTarget = nil
getgenv().targetStartTime = 0
getgenv().TARGET_SPAWN_TIME = {}

local function getUnitID(m)
	return m:GetAttribute("Index") or m.Name
end

-- Scan Target
local function isTarget(m)
	if getgenv().FORGOTTEN_UNITS[getUnitID(m)] then return false end
	local idx = m:GetAttribute("Index")
	if not idx then return false end
	for _,v in ipairs(getgenv().TARGET_LIST) do
		if idx == v then return true end
	end
	return false
end

local function addTarget(unit)
	if getgenv().TARGET_SPAWN_TIME[unit] then return end
	getgenv().TARGET_SPAWN_TIME[unit] = tick()
	table.insert(getgenv().TARGET_QUEUE, unit)
end

workspace.DescendantAdded:Connect(function(o)
	if o:IsA("Model") and isTarget(o) then
		addTarget(o)
	end
end)

-- PERBAIKAN: Deteksi Pembelian (Anti-Cheat sering memantau ini)
ProximityPromptService.PromptShown:Connect(function(prompt)
	if prompt.ActionText ~= "Purchase" then return end
	
    -- Menambahkan jeda acak (0.7 - 1.5 detik) agar server mengira ini manusia
	task.wait(math.random(7, 15) / 10) 

	pcall(function()
		fireproximityprompt(prompt)
	end)
end)

-- PERBAIKAN: Pergerakan Karakter (Waypoints)
local TARGETS = {
	Vector3.new(-348.08, -7.0, 200.22),
	Vector3.new(-317.96, -7.0, 173.27),
	Vector3.new(-351.60, -7.0, 140.55),
	Vector3.new(-473.55, -7.0, 190.71),
    -- ... (Sisa koordinat tetap sama)
}

task.spawn(function()
	while true do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")

		if hum and root then
			for _, targetPos in ipairs(TARGETS) do
                -- Menambahkan sedikit angka acak pada koordinat agar tidak selalu ke titik yang sama persis
                local variation = Vector3.new(math.random(-2,2), 0, math.random(-2,2))
				hum:MoveTo(targetPos + variation)
				
                -- Menunggu sampai sampai atau timeout
				local moveStarted = tick()
				while (root.Position - (targetPos + variation)).Magnitude > 5 do
					if tick() - moveStarted > 8 then break end
					task.wait(0.5)
				end
                task.wait(math.random(1, 3)) -- Jeda antar titik
			end
		end
		task.wait(10)
	end
end)

-- PERBAIKAN: Anti-AFK (Menghapus VirtualInputManager)
task.spawn(function()
    while true do
        local VirtualUser = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
        task.wait(300)
    end
end)

-- PERBAIKAN: Auto Speed Coil (Menghapus Loop 0 detik)
task.spawn(function()
    while true do
        local char = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if char and backpack then
            local hum = char:FindFirstChildOfClass("Humanoid")
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.find(string.lower(tool.Name), "speed") then
                    hum:EquipTool(tool)
                end
            end
        end
        task.wait(10) -- Cek setiap 10 detik, bukan setiap saat
    end
end)

print("Script Updated: Anti-Cheat Bypass Applied.")
