-- KAMIAPA BYPASS VERSION (STABLE NO-GLITCH)
task.spawn(function() 
    repeat task.wait(math.random(1, 3)) until game:IsLoaded()
    local p = game:GetService("Players").LocalPlayer
    local pps = game:GetService("ProximityPromptService")
    
    -- Koordinat Target
    local HP = Vector3.new(-411.6094055175781, -6.403680801391602, 230.6124725341797) 
    
    -- ANTI-AFK (Humanized - Hanya gerak kamera, tanpa input tombol)
    task.spawn(function()
        while task.wait(math.random(120, 240)) do 
            pcall(function()
                local cam = game.Workspace.CurrentCamera
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
            end)
        end
    end)

    -- STAY AT HOME & AUTO RETURN (STABLE - NO JITTER)
    task.spawn(function() 
        while task.wait(3) do -- Delay 3 detik agar tidak membebani physics game
            pcall(function() 
                local c = p.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local r = c and c:FindFirstChild("HumanoidRootPart")
                
                if h and r and h.Health > 0 then 
                    local distance = (r.Position - HP).Magnitude
                    
                    -- Hanya perintah jalan jika jarak > 8 stud (menghindari glitch/jitter)
                    if distance > 8 then 
                        h:MoveTo(HP)
                    end
                end 
            end) 
        end 
    end)

    -- AUTO PURCHASE
    pps.PromptShown:Connect(function(pr) 
        pcall(function() 
            local m = pr:FindFirstAncestorOfClass("Model")
            local targets = getgenv().TARGET_LIST or {}
            if m then
                local n = string.lower(m:GetAttribute("Index") or m.Name)
                local isT = false
                for _, t in ipairs(targets) do 
                    if string.find(n, string.lower(t)) then isT = true break end 
                end
                
                if isT then 
                    task.wait(math.random(0.5, 1.2)) 
                    pr:InputHoldBegin() 
                    task.wait(pr.HoldDuration + math.random(0.1, 0.3)) 
                    pr:InputHoldEnd() 
                end 
            end 
        end) 
    end)

    -- AUTO SPEED COIL
    task.spawn(function() 
        while task.wait(math.random(10, 20)) do 
            pcall(function() 
                local c = p.Character
                local b = p:FindFirstChildOfClass("Backpack")
                if c and b then 
                    local h = c:FindFirstChildOfClass("Humanoid")
                    local coil = c:FindFirstChild("Speed Coil") or c:FindFirstChild("Coil")
                    if not coil and h then 
                        for _, t in ipairs(b:GetChildren()) do 
                            if t:IsA("Tool") and (string.find(string.lower(t.Name), "speed") or string.find(string.lower(t.Name), "coil")) then 
                                h:EquipTool(t) 
                                break 
                            end 
                        end 
                    end 
                end 
            end) 
        end 
    end)

    print("KAMIAPA: Stable Mode Active - Teleport & Glitch Disabled")
end)
