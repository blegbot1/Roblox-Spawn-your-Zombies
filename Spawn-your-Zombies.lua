-- ELITE HUB | АВТОФАРМ (чистая версия)

local player = game.Players.LocalPlayer
local print = function(msg) warn("[ELITE HUB] " .. tostring(msg)) end

print("✅ АВТОФАРМ ЗАПУЩЕН! Рома — лох")

-- НАСТРОЙКИ
local TELEPORT_DELAY = 0.3
local FARM_CYCLES = 3
local COOLDOWN = 5
local LOBBY_RADIUS = 60

-- ОБЪЕКТЫ
local lobbySpawn = workspace:FindFirstChild("LobbySpawn")
local redSpawn = workspace:FindFirstChild("RedSpawn")
local blueSpawn = workspace:FindFirstChild("BlueSpawn")

local redBlock = workspace:FindFirstChild("BlockPile") and workspace.BlockPile:FindFirstChild("Red")
local blueBlock = workspace:FindFirstChild("BlockPile") and workspace.BlockPile:FindFirstChild("Blue")

local redButtons = {}
local blueButtons = {}
local teamBase = workspace:FindFirstChild("TeamBase")

if teamBase then
    for _, name in ipairs({"RedBase_Center", "RedBase_Left", "RedBase_Right"}) do
        local btn = teamBase:FindFirstChild(name)
        if btn then table.insert(redButtons, btn) end
    end
    for _, name in ipairs({"BlueBase_Center", "BlueBase_Left", "BlueBase_Right"}) do
        local btn = teamBase:FindFirstChild(name)
        if btn then table.insert(blueButtons, btn) end
    end
end

print("🔴 Красных кнопок: " .. #redButtons)
print("🔵 Синих кнопок: " .. #blueButtons)

-- REMOTE
local replicatedStorage = game:GetService("ReplicatedStorage")
local useAbility = replicatedStorage:FindFirstChild("UseAbility")

if not useAbility then
    print("❌ UseAbility не найден!")
    return
end

print("✅ UseAbility найден!")

-- ФУНКЦИИ
local function useAbilityByName(abilityName)
    if not useAbility then return false end
    local success = false
    pcall(function()
        useAbility:FireServer(abilityName)
        success = true
    end)
    return success
end

local function getLocation()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pos = root.Position
    
    if lobbySpawn and (pos - lobbySpawn.Position).Magnitude < LOBBY_RADIUS then
        return "Lobby"
    end
    if redSpawn and (pos - redSpawn.Position).Magnitude < 40 then
        return "Red"
    end
    if blueSpawn and (pos - blueSpawn.Position).Magnitude < 40 then
        return "Blue"
    end
    for _, btn in ipairs(redButtons) do
        if (pos - btn.Position).Magnitude < 80 then return "Red" end
    end
    for _, btn in ipairs(blueButtons) do
        if (pos - btn.Position).Magnitude < 80 then return "Blue" end
    end
    return "Unknown"
end

local function getLobbyCenter()
    local players = game:GetService("Players"):GetPlayers()
    local positions = {}
    for _, plr in ipairs(players) do
        if plr ~= player then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                table.insert(positions, root.Position)
            end
        end
    end
    if #positions == 0 then
        return lobbySpawn and lobbySpawn.Position or nil
    end
    local avgX, avgY, avgZ = 0, 0, 0
    for _, pos in ipairs(positions) do
        avgX = avgX + pos.X
        avgY = avgY + pos.Y
        avgZ = avgZ + pos.Z
    end
    avgX = avgX / #positions
    avgY = avgY / #positions
    avgZ = avgZ / #positions
    return Vector3.new(avgX, avgY, avgZ)
end

local function teleportTo(target)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and target then
        local cf
        if typeof(target) == "Vector3" then
            cf = CFrame.new(target)
        else
            cf = target.CFrame
        end
        root.CFrame = cf + Vector3.new(0, 2.5, 0)
        return true
    end
    return false
end

local function farm(color)
    local block = (color == "Red") and redBlock or blueBlock
    local bases = (color == "Red") and redButtons or blueButtons
    if not block or #bases == 0 then return end
    for _, base in ipairs(bases) do
        teleportTo(block)
        task.wait(TELEPORT_DELAY)
        teleportTo(base)
        task.wait(TELEPORT_DELAY)
    end
end

-- ГЛАВНЫЙ ЦИКЛ
print("🚀 ЗАПУСК АВТОФАРМА...")
print("💰 Урон=5, Усиление=7, Исцеление=8")
print("📍 ВСТАНЬ НА БАЗУ (КРАСНУЮ ИЛИ СИНЮЮ) ДЛЯ НАЧАЛА ФАРМА!")

local cycle = 0
local location = nil
local abilityCooldowns = {Damage = 0, Boost = 0, Heal = 0}
local waitCounter = 0

while true do
    local newLocation = getLocation()
    if newLocation ~= location then
        location = newLocation
        print("📍 " .. (location or "Unknown"))
    end

    if location == "Lobby" then
        waitCounter = waitCounter + 1
        if waitCounter % 5 == 0 then
            print("⏸ В лобби, жду раунда...")
        end
        local center = getLobbyCenter()
        if center then teleportTo(center) end
        task.wait(1)
        continue
    end
    waitCounter = 0

    if location == "Unknown" or location == nil then
        task.wait(0.5)
        continue
    end

    cycle = cycle + 1
    print("════════════════════════════")
    print("🔄 ЦИКЛ " .. cycle .. " | " .. location)

    print("⛏ ФАРМ...")
    for i = 1, FARM_CYCLES do
        farm(location)
    end

    print("📈 ПРОКАЧКА...")
    local now = tick()

    local remaining = math.ceil(COOLDOWN - (now - abilityCooldowns.Damage))
    if remaining <= 0 then
        print("   💥 Урон (5)")
        if useAbilityByName("Damage") then
            abilityCooldowns.Damage = now
            print("   ✅ Активирован!")
        else
            print("   ❌ Не активирован")
        end
    else
        print("   ⏳ Урон: " .. remaining .. " сек")
    end
    task.wait(0.3)

    remaining = math.ceil(COOLDOWN - (now - abilityCooldowns.Boost))
    if remaining <= 0 then
        print("   ⚡ Усиление (7)")
        if useAbilityByName("Boost") then
            abilityCooldowns.Boost = now
            print("   ✅ Активирован!")
        else
            print("   ❌ Не активирован")
        end
    else
        print("   ⏳ Усиление: " .. remaining .. " сек")
    end
    task.wait(0.3)

    remaining = math.ceil(COOLDOWN - (now - abilityCooldowns.Heal))
    if remaining <= 0 then
        print("   ❤ Исцеление (8)")
        if useAbilityByName("Heal") then
            abilityCooldowns.Heal = now
            print("   ✅ Активирован!")
        else
            print("   ❌ Не активирован")
        end
    else
        print("   ⏳ Исцеление: " .. remaining .. " сек")
    end
    task.wait(0.3)

    task.wait(0.5)
end
