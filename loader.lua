-- [[ CONFIGURATION ]] --
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local scripts = {
    FPS = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0RoaW1hc2FqaXAvc3RlYWxhYnJhaW5yb3QvcmVmcy9oZWFkcy9tYWluL0ZQUy5sdWE=",
    Main = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0RoaW1hc2FqaXAvc3RlYWxhYnJhaW5yb3QvcmVmcy9oZWFkcy9tYWluL1NfQV9CLmx1YQ=="
}

-- [[ DECODE FUNCTION ]] --
local function decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do
            r = r .. (f%2^i - f%2^(i-1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c=0
        for i=1,8 do
            c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0)
        end
        return string.char(c)
    end))
end

-- [[ LOADER CORE ]] --
local function ExecuteScript(name, encodedUrl)
    local url = decode(encodedUrl)
    print("Attempting to load " .. name .. "...")
    
    local success, content = pcall(game.HttpGet, game, url)
    
    if success and content then
        local func, err = loadstring(content)
        if func then
            task.spawn(func) -- Menggunakan task.spawn agar skrip berjalan di thread terpisah
            print("Successfully executed: " .. name)
        else
            warn("Error compiling " .. name .. ": " .. tostring(err))
        end
    else
        warn("Failed to download " .. name .. ". Check your connection or URL.")
    end
end

-- [[ EXECUTION ]] --
-- Memulai optimasi FPS terlebih dahulu
ExecuteScript("FPS Booster", scripts.FPS)

-- Memberi jeda sedikit agar tidak bentrok saat loading
task.wait(1)

-- Menjalankan skrip utama
ExecuteScript("Main Script (S_A_B)", scripts.Main)
