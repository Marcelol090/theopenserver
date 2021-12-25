---- DONT TOUCH ---
MW_STATUS = 0
MW_PLAYERS = {}
MW_MONSTERS = {}
local MW_WAVE = 1
-------------------

--- CONFIG ----
MW_minLevel = 50 -- Player must be this level to enter event --
MW_positionEnter = Position(1000, 1000, 7) -- Wait area for event to start position --
MW_positionLeave = Position(1000, 1000, 7) -- Exit waiting area position --
local MW_minPlayersToStart = 5 -- How many people are required for event to start --
local MW_firstWaveStart = 30 -- 30 seconds for the first wave to start --
local MW_reTryEvent = 60 -- Time in minutes to retry the event if there are not enough players --
local MW_startEventAgain = 60 -- Start the event again after 60 minutes --
---------------

local MW_PLAYER_TELEPORT_TO = { -- Teleport players to this area for event --
    min = Position(1000, 1000, 7), -- Top left square of area --
    max = Position(1000, 1000, 7) -- bottom right square of area --
}

local MONSTER_WAVES = {
    [1] = {exp = 20000, waitTimeBoss = 60,
        monsters = {
            {"Cyclops", Position(1000, 1000, 7)},
            {"Cyclops", Position(1000, 1000, 7)},
            {"Cyclops", Position(1000, 1000, 7)},
            {"Cyclops Drone", Position(1000, 1000, 7)},
            {"Cyclops Drone", Position(1000, 1000, 7)}
        },
        boss = { -- Boss is spawned after waitTimeBoss seconds after the wave is stated --
            {"Cyclops Smith", Position(1000, 1000, 7)}
        }
        itemRewards = { -- Items rewarded for completing the wave. --
            {2152, 50},
            {2160, 1}
        },
        outfitReward = {male = 260, female = 261, addons = 0, name = "Citizen"}, -- outfit rewards for completing the wave --
        mountReward = {126, "Horse"}
    } -- You can delete any of the values to remove it from the wave. exp, itemreward, boss, outfitreward, mountreward (DO NOT DELETE THE monsters TABLE) --
  
    -- [2]
  
}

function MW_sendMessage(msgType, msg)
    for i = 1, #MW_PLAYERS do
        local player = Player(MW_PLAYERS[i])
        if player then
            player:sendTextMessage(msgType, msg)
        end
    end
end

function MW_teleportPlayers()
    for i = 1, #MW_PLAYERS do
        local player = Player(MW_PLAYERS[i])
        if player then
            local position = Position(math.random(MW_PLAYER_TELEPORT_TO.min.x, MW_PLAYER_TELEPORT_TO.max.x),math.random(MW_PLAYER_TELEPORT_TO.min.y, MW_PLAYER_TELEPORT_TO.max.y), MW_PLAYER_TELEPORT_TO.min.z)
            player:teleportTo(position)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Welcome to monster wave event. It will begin in "..MW_firstWaveStart.." seconds.")
        end
    end
end

function MW_tryEvent()
    if #MW_PLAYERS < MW_minPlayersToStart then
        MW_sendMessage(MESSAGE_STATUS_CONSOLE_RED, "There are not enough players for the event to start. The event will try again after "..MW_reTryEvent.." minutes.")
        addEvent(MW_tryEvent, MW_reTryEvent * 60 * 1000)
        return true
    end
  
    MW_teleportPlayers()
    MW_STATUS = 2
    addEvent(MW_startWave, MW_firstWaveStart * 1000)
end

function MW_checkMonsters()
    for i = 1, #MW_MONSTERS do
        local monster = Monster(MW_MONSTERS[i])
        if monster then
            return true
        end
    end
    return false
end

function MW_removeMonsters()
    for i = 1, #MW_MONSTERS do
        local monster = Monster(MW_MONSTERS[i])
        if monster then
            monster:remove()
        end
        MW_MONSTERS[i] = nil
    end
end

function MW_startWave()
    local WAVE = MONSTER_WAVES[MW_WAVE]
  
    for i = 1, #WAVE.monsters do
        local MONS = Game.createMonster(WAVE.monsters[i][1], WAVE.monsters[i][2])
        if not MW_MONSTERS[1] then
            MW_MONSTERS[1] = MONS:getId()
        else
            MW_MONSTERS[#MW_MONSTERS + 1] = MONS:getId()
        end
    end
  
    MW_sendMessage(MESSAGE_STATUS_CONSOLE_BLUE, "The wave has spawned. Kill all monsters for the next wave to begin.")
  
    if WAVE.boss then
        addEvent(spawnBosses, WAVE.waitTimeBoss * 1000, WAVE)
        MW_sendMessage(MESSAGE_STATUS_CONSOLE_BLUE, "This waves bosses will spawn in "..WAVE.waitTimeBoss.." seconds.")
    end
  
    addEvent(MW_proccessWave, 60 * 1000)
end

function MW_spawnBosses(waveTable)
    for i = 1, #waveTable.boss do
        local MONS = Game.createMonster(waveTable[i].boss[1], waveTable[i].boss[2])
        MW_MONSTERS[#MW_MONSTERS + 1] = MONS:getId()
    end
end

function MW_addOutfitReward(WAVE, player)
    if player:getSex() == 0 then
        player:addOutfit(WAVE.outfitReward.female)
        if addons > 0 then
            for x = 1, addons do
                player:addOutfitAddons(WAVE.outfitReward.female, x)
            end
        end
    else
        player:addOutfit(WAVE.outfitReward.male)
        if addons > 0 then
            for x = 1, addons do
                player:addOutfitAddons(WAVE.outfitReward.male, x)
            end
        end
    end
end

function MW_proccessWave()
    if MW_checkMonsters() then
        MW_sendMessage(MESSAGE_STATUS_CONSOLE_RED, "There are still monsters left to kill. Kill them to start the next wave.")
        addEvent(MW_proccessWave, 60 * 1000)
        return true
    end
  
    local WAVE = MONSTER_WAVES[MW_WAVE]
  
    local text = "[WAVE REWARD]:"
  
    if WAVE.exp then
        for i = 1, #MW_PLAYERS do
            local player = Player(MW_PLAYERS[i])
            if player then
                if i == 1 then
                    text = text.." "..WAVE.exp.." experience."
                end
                player:addExperience(WAVE.exp)
            end
        end
    end
  
    if WAVE.outfitReward then
        for i = 1, #MW_PLAYERS do
            local player = Player(MW_PLAYERS[i])
            if player then
                if i == 1 then
                    text = text.." "..WAVE.outfitReward.name.." outfit."
                end
                MW_addOutfitReward(WAVE, player)  
            end
        end
    end
  
    if WAVE.mountReward then
        for i = 1, #MW_PLAYERS do
            local player = Player(MW_PLAYERS[i])
            if player then
                if i == 1 then
                    text = text.." "..WAVE.mountReward[2].." mount."
                end
                player:addMount(WAVE.mountReward[1])
            end
        end
    end
  
    MW_sendMessage(MESSAGE_STATUS_CONSOLE_RED, text)
    MW_WAVE = MW_WAVE + 1
    MW_removeMonsters()
  
    if not MONSTER_WAVES[MW_WAVE] then
        MW_sendMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Well done. You completed all waves. The event will end in 30 seconds!")
        MW_STATUS = 3
        addEvent(MW_endEvent, 30 * 1000)
        return true
    end
  
    MW_sendMessage(MESSAGE_STATUS_CONSOLE_BLUE, "The next wave will spawn in 1 minute.")
    addEvent(MW_startWave, 60 * 1000)
    addEvent(MW_CleanFields, 5 * 1000)
end

function MW_endEvent()
    for i = 1, #MW_PLAYERS do
        local player = Player(MW_PLAYERS[i])
        if player then
            player:teleportTo(MW_positionLeave)
        end
        MW_PLAYERS[i] = nil
    end
  
    MW_removeMonsters()
    addEvent(MW_restartEvent, MW_startEventAgain * 60 * 1000)
end

function MW_restartEvent()
    MW_STATUS = 0
end

function MW_CleanFields()
local area = {
      fromPos = {x = 32470, y = 32315, z = 9},
      toPos = {x = 32479, y = 32322, z = 9}
  }

local tileCache = {}

local itemIds = {1487, 1486,1485,1490,1491,1497}
    -- initialize tiles we need to clean, store all tiles in a cache to avoid reconstructing them in the future
    if #tileCache == 0 then
        for x = area.fromPos.x, area.toPos.x do
            for y = area.fromPos.y, area.toPos.y do
                for z = area.fromPos.z, area.toPos.z do
                    tileCache[#tileCache+1] = Tile(x, y, z)
                end
            end
        end
    end
    -- clean based off of cache
    for i = 1, #tileCache do
        local items = tileCache[i]:getItems()
        if items and next(items) then
            for index = 1, #items do
                local item = items[index]
                if table.contains(itemIds, item:getId()) then
                    item:remove()
                end
            end
        end
    end
    return true
end