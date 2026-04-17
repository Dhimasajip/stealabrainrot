--[[ 
    FULL SCRIPT - NO PATHFINDING & NO COIL
    - Fitur Pathfinding (Jalan Otomatis): DIHAPUS
    - Fitur Speed Coil: DIHAPUS
    - Deteksi: Hanya bekerja jika Anda berada di dekat item (Manual Movement)
]]

if getgenv().__SECURE_FINAL_RUNNING then return end
getgenv().__SECURE_FINAL_RUNNING = true

task.wait(2)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- Konfigurasi Dasar
getgenv().TARGET_LIST = getgenv().TARGET_LIST or {}
getgenv().FORGOTTEN_UNITS = {}
getgenv().UNIT_SPAWN_COUNT = {}
getgenv().SEEN_UNIT_INSTANCES = {}

getgenv().MAX_SPAWN_BEFORE_FORGET = 15
getgenv().GRAB_RADIUS = 30 -- Jarak maksimal untuk otomatis beli

getgenv().currentTarget = nil

local function getUnitID(m)
	return m:GetAttribute("Index") or m.Name
end

-- Fungsi Cek Target
local function isTarget(m)
	if getgenv().FORGOTTEN_UNITS[getUnitID(m)] then return false end
	local idx = m:GetAttribute("Index")
	if not idx then return false end
	for _,v in ipairs(getgenv().TARGET_LIST) do
		if idx == v then return true end
	end
	return false
end

-- Sistem Interaksi Purchase (Sangat Manusiawi)
ProximityPromptService.PromptShown:Connect(function(prompt)
	if prompt.ActionText ~= "Purchase" then return end
	
	-- Memberikan jeda acak yang lebih lama agar tidak terdeteksi mesin
	task.wait(math.random(12, 25) / 10) 

	pcall(function()
		fireproximityprompt(prompt)
	end)
end)

-- Sistem Auto-Interact Berdasarkan Jarak (Bukan Jalan Otomatis)
task.spawn(function()
	while true do
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")

		if root then
			for _, o in ipairs(workspace:GetDescendants()) do
				if o:IsA("Model") and isTarget(o) then
					local part = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
					if part then
						local dist = (root.Position - part.Position).Magnitude
						if dist <= getgenv().GRAB_RADIUS then
							-- Menandai target untuk dibeli oleh ProximityPromptService di atas
							getgenv().currentTarget = o
						end
					end
				end
			end
		end
		task.wait(2) -- Cek sekitar setiap 2 detik
	end
end)

-- Anti-AFK Aman
task.spawn(function()
    while true do
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
        task.wait(300)
    end
end)

-- Auto-Reset jika tersangkut (Hanya jika tidak ada target)
task.spawn(function()
    while true do
        task.wait(600) -- Cek setiap 10 menit
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and not getgenv().currentTarget then
            -- hum.Health = 0 -- Opsional: Aktifkan jika ingin reset otomatis
        end
    end
end)

print("Script Loaded: Pathfinding & Coil dihapus. Anda harus jalan manual ke area item.")
