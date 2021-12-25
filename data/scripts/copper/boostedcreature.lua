boosted = {}
boosted.creatures = {}
-- possible monsters
boosted.possible = {
    {
        {"Demon", "Hellhound", "Grim Reaper", "Juggernaut"}, -- exp list
        1.1 -- exp rate
    },
    {
        {"Dragon Lord", "Medusa", "Hydra", "Serpent Spawn"}, -- loot list
        1.2 -- loot rate
    },
    {
        {"Warlock", "Infernalist", "Demon Outcast", "Nightmare"}, -- extraloot list
        {{2494, 1, 25}, {2646, 1, 10}, {2469, 2, 15}, {2352, 1, 50}} -- items list
    }
}

function getBoostedCreature()
    local t = {
        monster = {exp = boosted.creatures[1], loot = boosted.creatures[2], extraloot = boosted.creatures[3]},
        rate = {exp = boosted.possible[1][2], loot = boosted.possible[2][2], extraloot = boosted.possible[3][2]}
    }
    return t
end

local boostedInfo = ""
local globalevent = GlobalEvent("boostedcreatures")

function globalevent.onStartup()
    -- select monsters
    local monster1 = boosted.possible[1][1][math.random(#boosted.possible[1][1])]
    local monster2 = boosted.possible[2][1][math.random(#boosted.possible[2][1])]
    local monster3 = boosted.possible[3][1][math.random(#boosted.possible[3][1])]

    boosted.creatures[1] = monster1
    boosted.creatures[2] = monster2
    boosted.creatures[3] = monster3

    -- string for talkaction
    boostedInfo = boostedInfo .. ('Today daily creatures are: %s has extra exp %.1f\n%s has extra loot rate %.1f\n%s has extraloot, list of possible items:\n\n'):format(monster1, getBoostedCreature().rate.exp, monster2, getBoostedCreature().rate.loot, monster3)
    for index, value in ipairs(boosted.possible[3][2]) do
        boostedInfo = boostedInfo .. "[" .. ItemType(value[1]):getName() .. "]: count; " .. value[2] .. ", chance; " .. (not value and "100%" or value[3] .. "%") .. ((#boosted.possible[3][2] > 1 and index < #boosted.possible[3][2]) and "\n" or "")
    end

    -- in case you forget to register the event in monsterfile.xml
    MonsterType(monster1):registerEvent("BoostedDeath")
    MonsterType(monster2):registerEvent("BoostedDeath")
    MonsterType(monster3):registerEvent("BoostedDeath")
    return true
end

globalevent:register()

local creatureevent = CreatureEvent("BoostedLogin")

function creatureevent.onLogin(player)
    local boosted = getBoostedCreature()
    local message = "Today daily creatures are: " .. boosted.monster.exp .. " has extra exp rate " .. boosted.rate.exp .. "\n" .. boosted.monster.loot .. " has extra loot rate " .. boosted.rate.loot .. "\n" .. boosted.monster.extraloot .. " has extra loot: type !extraloot for more information \n\nEnjoy!"
    player:sendTextMessage(MESSAGE_INFO_DESCR, message)
    return true
end

creatureevent:register()

local creatureevent = CreatureEvent("BoostedDeath")

function creatureevent.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if not creature:isMonster() or not killer:isPlayer() or not corpse then
        return true
    end

    local BOOSTED = getBoostedCreature()
    -- exp
    if creature:getName():lower() == BOOSTED.monster.exp:lower() then
        local exp = math.floor(MonsterType(creature:getName()):experience() * (Game.getExperienceStage(killer:getLevel()) + BOOSTED.rate.exp))
        killer:addExperience(exp, true)

    -- loot
    elseif creature:getName():lower() == BOOSTED.monster.loot:lower() then
        local monsterloot = MonsterType(creature:getName()):getLoot()
        local bp = corpse:addItem(1987, 1)
        local str = ""
        local rate = BOOSTED.rate.loot * configManager.getNumber(configKeys.RATE_LOOT)
        for i, loot in pairs(monsterloot) do
            if math.random(100000) <= rate * loot.chance then
                local count = loot.maxCount > 1 and math.random(loot.maxCount) or 1
                bp:addItem(loot.itemId, count)
                str = str .. count .. " " .. ItemType(loot.itemId):getName() .. ", "
            end
        end
        if str ~= "" then
            if str:sub(-2, -2) == "," then
                str = str:sub(1, str:len() - 2)
            end
            killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Loot bonus [" .. creature:getName() .. "]: " .. str .. '.')
            creature:getPosition():sendMagicEffect(CONST_ME_TUTORIALARROW, killer)
            creature:getPosition():sendMagicEffect(CONST_ME_TUTORIALSQUARE, killer)
        end
    -- extraloot
    elseif creature:getName():lower() == BOOSTED.monster.extraloot:lower() then
        local bp = corpse:addItem(1987, 1)
        local str = ""
        for index, value in ipairs(boosted.possible[3][2]) do
            if not value[3] or math.random(100) <= value[3] then
                if ItemType(value[1]):isStackable() then
                    bp:addItem(value[1], value[2])
                else
                    for i = 1, value[2] do
                        bp:addItem(value[1], 1)
                    end
                end
                str = str .. value[2] .. " " .. ItemType(value[1]):getName() .. ", "
            end
        end
        if str ~= "" then
            if str:sub(-2, -2) == "," then
                str = str:sub(1, str:len() - 2)
            end
            creature:getPosition():sendMagicEffect(CONST_ME_TUTORIALARROW, killer)
            creature:getPosition():sendMagicEffect(CONST_ME_TUTORIALSQUARE, killer)
            killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Extra loot [" .. creature:getName() .. "]: " .. str .. '.')
        end
    end
    return true
end

creatureevent:register()

local talkaction = TalkAction('!extraloot')

function talkaction.onSay(player, words, param)
    player:popupFYI(boostedInfo)
    return false
end

talkaction:separator(" ")
talkaction:register()