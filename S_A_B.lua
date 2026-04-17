--[[ 
    FULL SCRIPT - CLEAN VERSION (NO COIL)
    - Fitur Speed Coil: DIHAPUS
    - VirtualInputManager: DIHAPUS
    - Jeda Interaksi: DITAMBAHKAN (Anti-Kick)
]]

if getgenv().__SECURE_MAIN_RUNNING then return end
getgenv().__SECURE_MAIN_RUNNING = true

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
getgenv().GRAB_RADIUS = 30
getgenv().TARGET_TIMEOUT = 25 
getgenv().CHASE_DELAY = 1.2 

getgenv().TARGET_QUEUE = {}
getgenv().currentTarget = nil
getgenv().targetStartTime = 0
getgenv().TARGET_SPAWN_TIME = {}

local function getUnitID(m)
	return m:GetAttribute("Index") or m.Name
end

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

-- Scan Otomatis
workspace.DescendantAdded:Connect(function(o)
	if o:IsA("Model") and isTarget(o) then
		addTarget(o)
	end
end)

-- Sistem Interaksi Purchase (Diberi Jeda agar tidak terdeteksi)
ProximityPromptService.PromptShown:Connect(function(prompt)
	if prompt.ActionText ~= "Purchase" then return end
	
    -- Jeda acak 1-2 detik agar terlihat seperti klik manual
	task.wait(math.random(10, 20) / 10) 

	pcall(function()
		fireproximityprompt(prompt)
	end)
end)

-- Daftar Koordinat Waypoints
local TARGETS = {
	Vector3.new(-348.08, -7.0, 200.22),
	Vector3.new(-317.96, -7.0, 173.27),
	Vector3.new(-351.60, -7.0, 140.55),
	Vector3.new(-473.55, -7.0, 190.71),
	Vector3.new(-508.02, -7.0, 172.87),
	Vector3.new(-468.29, -7.0, 143.89),
	Vector3.new(-467.09, -7.0, 81.65),
	Vector3.new(-509.83, -7.0, 60.71),
	Vector3.new(-472.07, -7.0, 36.39),
	Vector3.new(-469.87, -7.0, -15.74),
	Vector3.new(-344.73, -7.0, -17.09),
	Vector3.new(-348.09, -7.0, 38.18),
	Vector3.new(-303.98, -7.0, 66.93),
	Vector3.new(-350.02, -7.0, 80.84),
	Vector3.new(-351.59, -7.0, -22.45),
	Vector3.new(-313.39, -7.0, -41.65),
	Vector3.new(-348.01, -7.0, -75.82),
	Vector3.new(-478.14, -7.0, -26.70),
	Vector3.new(-518.76, -7.0, -46.07),
	Vector3.new(-471.65, -7.0, -69.66),
	Vector3.new(-465.01, -7.0, -129.68),
	Vector3.new(-346.22, -7.0, -123.08),
	Vector3.new(-434.94, -6.6, 62.77),
}

-- Loop Pergerakan Karakter (Dengan Variasi agar tidak kaku)
task.spawn(function()
	while true do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")

		if hum and root then
			for _, targetPos in ipairs(TARGETS) do
                -- Variasi posisi 2-3 meter agar tidak selalu ke titik yang sama persis
                local variation = Vector3.new(math.random(-2,2), 0, math.random(-2,2))
				hum:MoveTo(targetPos + variation)
				
				local moveStarted = tick()
				while (root.Position - (targetPos + variation)).Magnitude > 5 do
					if tick() - moveStarted > 10 then break end -- Timeout jika tersangkut
					task.wait(0.5)
				end
                task.wait(math.random(1, 4)) -- Istirahat sejenak antar waypoint
			end
		end
		task.wait(15) -- Jeda sebelum mengulang rute
	end
end)

-- Anti-AFK (Metode Paling Aman)
task.spawn(function()
    while true do
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
        task.wait(200)
    end
end)

print("Script Loaded: Fitur Coil dihapus, bypass keamanan diterapkan.")
