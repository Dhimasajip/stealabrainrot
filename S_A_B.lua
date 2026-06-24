-- KAMIAPA BYPASS VERSION (HUMANIZED + DUAL COORDINATE)
task.spawn(function() 
    repeat task.wait(math.random(1, 3)) until game:IsLoaded()[cite: 1]
    local p = game:GetService("Players").LocalPlayer[cite: 1]
    local pps = game:GetService("ProximityPromptService")[cite: 1]
    
    -- ================= CONFIG KOORDINAT =================
    -- KOORDINAT PERTAMA (Dari Gambar image_7b44e1.png)
    local HP_1 = Vector3.new(-438.3928527832031, -4.257575035095215, 61.922977447509766) 
    
    -- KOORDINAT KEDUA (Bawaan Script / loader.lua)[cite: 1]
    local HP_2 = Vector3.new(-410.287, -6.403, -68.402)[cite: 1] 
    
    -- Set true untuk menggunakan koordinat pertama, atau false untuk menggunakan koordinat kedua
    local USE_FIRST_COORDINATE = true 
    
    local HP = USE_FIRST_COORDINATE and HP_1 or HP_2
    -- ====================================================
    
    -- ANTI-AFK HUMANIZED (Gerak kamera sedikit)
    task.spawn(function()
        while task.wait(math.random(120, 240)) do -- Gerak tiap 2-4 menit[cite: 1]
            pcall(function()
                local cam = game.Workspace.CurrentCamera[cite: 1]
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)[cite: 1]
            end)
        end
    end)

    -- STAY AT HOME & AUTO RETURN (Humanized MoveTo)
    task.spawn(function() 
        while task.wait(math.random(1, 2)) do[cite: 1]
            pcall(function() 
                local c = p.Character[cite: 1]
                local h = c and c:FindFirstChildOfClass("Humanoid")[cite: 1]
                local r = c and c:FindFirstChild("HumanoidRootPart")[cite: 1]
                
                if h and r and h.Health > 0 then[cite: 1]
                    local distance = (r.Position - HP).Magnitude[cite: 1]
                    
                    -- Bergerak perlahan ke posisi jika jauh
                    if distance > 5 then[cite: 1]
                        h:MoveTo(HP)[cite: 1]
                    end
                end 
            end) 
        end 
    end)

    -- AUTO PURCHASE (Humanized Delay)
    pps.PromptShown:Connect(function(pr)[cite: 1]
        pcall(function() 
            local m = pr:FindFirstAncestorOfClass("Model")[cite: 1]
            local targets = getgenv().TARGET_LIST or {}[cite: 1]
            if m then[cite: 1]
                local n = string.lower(m:GetAttribute("Index") or m.Name)[cite: 1]
                local isT = false[cite: 1]
                for _, t in ipairs(targets) do[cite: 1]
                    if string.find(n, string.lower(t)) then isT = true break end[cite: 1]
                end
                
                if isT then[cite: 1]
                    task.wait(math.random(0.5, 1.2)) -- Jeda acak sebelum interaksi[cite: 1]
                    pr:InputHoldBegin()[cite: 1]
                    task.wait(pr.HoldDuration + math.random(0.1, 0.3))[cite: 1]
                    pr:InputHoldEnd()[cite: 1]
                end 
            end 
        end) 
    end)

    -- AUTO SPEED COIL
    task.spawn(function() 
        while task.wait(math.random(10, 20)) do[cite: 1]
            pcall(function() 
                local c = p.Character[cite: 1]
                local b = p:FindFirstChildOfClass("Backpack")[cite: 1]
                if c and b then[cite: 1]
                    local h = c:FindFirstChildOfClass("Humanoid")[cite: 1]
                    local coil = c:FindFirstChild("Speed Coil") or c:FindFirstChild("Coil")[cite: 1]
                    if not coil and h then[cite: 1]
                        for _, t in ipairs(b:GetChildren()) do[cite: 1]
                            if t:IsA("Tool") and (string.find(string.lower(t.Name), "speed") or string.find(string.lower(t.Name), "coil")) then[cite: 1]
                                task.wait(math.random(0.5, 1))[cite: 1]
                                h:EquipTool(t)[cite: 1]
                                break[cite: 1]
                            end 
                        end 
                    end 
                end 
            end) 
        end 
    end)

    print("KAMIAPA: Humanized Script Loaded - Good Luck")[cite: 1]
end)
