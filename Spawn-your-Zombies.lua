-- ELITE HUB | ЗАШИФРОВАННЫЙ АВТОФАРМ
local function a1(...) local t={...} local r="" for i=1,#t do r=r..t[i] end return r end
local function b2(...) local t={...} local r="" for i=#t,1,-1 do r=r..t[i] end return r end

local c3 = a1("P","l","a","y","e","r","s")
local d4 = a1("W","o","r","k","s","p","a","c","e")
local e5 = a1("R","e","p","l","i","c","a","t","e","d","S","t","o","r","a","g","e")
local f6 = a1("U","s","e","A","b","i","l","i","t","y")
local g7 = a1("L","o","b","b","y","S","p","a","w","n")
local h8 = a1("R","e","d","S","p","a","w","n")
local i9 = a1("B","l","u","e","S","p","a","w","n")
local j10 = a1("B","l","o","c","k","P","i","l","e")
local k11 = a1("R","e","d")
local l12 = a1("B","l","u","e")
local m13 = a1("T","e","a","m","B","a","s","e")
local n14 = a1("R","e","d","B","a","s","e","_","C","e","n","t","e","r")
local o15 = a1("R","e","d","B","a","s","e","_","L","e","f","t")
local p16 = a1("R","e","d","B","a","s","e","_","R","i","g","h","t")
local q17 = a1("B","l","u","e","B","a","s","e","_","C","e","n","t","e","r")
local r18 = a1("B","l","u","e","B","a","s","e","_","L","e","f","t")
local s19 = a1("B","l","u","e","B","a","s","e","_","R","i","g","h","t")
local t20 = a1("[","E","L","I","T","E"," ","H","U","B","]")
local u21 = a1("H","u","m","a","n","o","i","d","R","o","o","t","P","a","r","t")

local v22 = game:GetService(c3)
local w23 = v22.LocalPlayer
local x24 = game:GetService(d4)
local y25 = x24:FindFirstChild(g7)
local z26 = x24:FindFirstChild(h8)
local aa27 = x24:FindFirstChild(i9)

local ab28 = x24:FindFirstChild(j10)
local ac29 = ab28 and ab28:FindFirstChild(k11)
local ad30 = ab28 and ab28:FindFirstChild(l12)

local ae31 = x24:FindFirstChild(m13)
local af32 = {}
local ag33 = {}
if ae31 then
    for _, ah34 in ipairs({n14, o15, p16}) do
        local ai35 = ae31:FindFirstChild(ah34)
        if ai35 then table.insert(af32, ai35) end
    end
    for _, ah34 in ipairs({q17, r18, s19}) do
        local ai35 = ae31:FindFirstChild(ah34)
        if ai35 then table.insert(ag33, ai35) end
    end
end

local aj36 = game:GetService(e5)
local ak37 = aj36:FindFirstChild(f6)

local al38 = function(am39) 
    if not ak37 then return false end
    local an40 = false
    pcall(function() ak37:FireServer(am39) an40 = true end)
    return an40
end

local ao41 = function()
    local ap42 = w23.Character
    local aq43 = ap42 and ap42:FindFirstChild(u21)
    if not aq43 then return nil end
    local ar44 = aq43.Position
    if y25 and (ar44 - y25.Position).Magnitude < 60 then return "Lobby" end
    if z26 and (ar44 - z26.Position).Magnitude < 40 then return k11 end
    if aa27 and (ar44 - aa27.Position).Magnitude < 40 then return l12 end
    for _, ai35 in ipairs(af32) do
        if (ar44 - ai35.Position).Magnitude < 80 then return k11 end
    end
    for _, ai35 in ipairs(ag33) do
        if (ar44 - ai35.Position).Magnitude < 80 then return l12 end
    end
    return "Unknown"
end

local as45 = function()
    local at46 = v22:GetPlayers()
    local au47 = {}
    for _, av48 in ipairs(at46) do
        if av48 ~= w23 then
            local aw49 = av48.Character
            local ax50 = aw49 and aw49:FindFirstChild(u21)
            if ax50 then table.insert(au47, ax50.Position) end
        end
    end
    if #au47 == 0 then return y25 and y25.Position or nil end
    local ay51, az52, ba53 = 0, 0, 0
    for _, bb54 in ipairs(au47) do
        ay51 = ay51 + bb54.X
        az52 = az52 + bb54.Y
        ba53 = ba53 + bb54.Z
    end
    ay51 = ay51 / #au47
    az52 = az52 / #au47
    ba53 = ba53 / #au47
    return Vector3.new(ay51, az52, ba53)
end

local bc55 = function(bd56)
    local be57 = w23.Character
    local bf58 = be57 and be57:FindFirstChild(u21)
    if bf58 and bd56 then
        local bg59
        if type(bd56) == "Vector3" then
            bg59 = CFrame.new(bd56)
        else
            bg59 = bd56.CFrame
        end
        bf58.CFrame = bg59 + Vector3.new(0, 2.5, 0)
        return true
    end
    return false
end

local bh60 = function(bi61, bj62)
    local bk63 = (bi61 == k11) and ac29 or ad30
    local bl64 = (bi61 == k11) and af32 or ag33
    if not bk63 or #bl64 == 0 then return end
    for _, bm65 in ipairs(bl64) do
        if not bn66 then return end
        bc55(bk63)
        task.wait(0.3)
        bc55(bm65)
        task.wait(0.3)
    end
end

local bo67 = 0
local bp68 = nil
local bq69 = {Damage = 0, Boost = 0, Heal = 0}
local br70 = 0
local bs71 = true

warn(t20 .. " ✅ АВТОФАРМ ЗАПУЩЕН! Рома — лох")
warn(t20 .. " 🚀 НАЧАЛО РАБОТЫ...")
warn(t20 .. " 📍 ВСТАНЬ НА БАЗУ ДЛЯ ФАРМА")

while bs71 do
    local bt72 = ao41()
    if bt72 ~= bp68 then
        bp68 = bt72
        warn(t20 .. " 📍 " .. (bp68 or "Unknown"))
    end

    if bp68 == "Lobby" then
        br70 = br70 + 1
        if br70 % 5 == 0 then
            warn(t20 .. " ⏸ В ЛОББИ, ЖДУ РАУНДА...")
        end
        local bu73 = as45()
        if bu73 then bc55(bu73) end
        task.wait(1)
        continue
    end
    br70 = 0

    if bp68 == "Unknown" or bp68 == nil then
        task.wait(0.5)
        continue
    end

    bo67 = bo67 + 1
    warn(t20 .. " ════════════════════════════")
    warn(t20 .. " 🔄 ЦИКЛ " .. bo67 .. " | " .. bp68)

    warn(t20 .. " ⛏ ФАРМ...")
    for bv74 = 1, 3 do
        if not bs71 then break end
        bh60(bp68)
    end

    if not bs71 then break end

    warn(t20 .. " 📈 ПРОКАЧКА...")
    local bw75 = tick()

    local bx76 = math.ceil(5 - (bw75 - bq69.Damage))
    if bx76 <= 0 then
        warn(t20 .. "    💥 Урон (5)")
        if al38("Damage") then
            bq69.Damage = bw75
            warn(t20 .. "    ✅ Активирован!")
        end
    else
        warn(t20 .. "    ⏳ Урон: " .. bx76 .. " сек")
    end
    task.wait(0.3)

    bx76 = math.ceil(5 - (bw75 - bq69.Boost))
    if bx76 <= 0 then
        warn(t20 .. "    ⚡ Усиление (7)")
        if al38("Boost") then
            bq69.Boost = bw75
            warn(t20 .. "    ✅ Активирован!")
        end
    else
        warn(t20 .. "    ⏳ Усиление: " .. bx76 .. " сек")
    end
    task.wait(0.3)

    bx76 = math.ceil(5 - (bw75 - bq69.Heal))
    if bx76 <= 0 then
        warn(t20 .. "    ❤ Исцеление (8)")
        if al38("Heal") then
            bq69.Heal = bw75
            warn(t20 .. "    ✅ Активирован!")
        end
    else
        warn(t20 .. "    ⏳ Исцеление: " .. bx76 .. " сек")
    end
    task.wait(0.3)

    task.wait(0.5)
end
