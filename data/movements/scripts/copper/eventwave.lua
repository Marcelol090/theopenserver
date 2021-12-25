local aidEnter = 1510 -- ActionID of teleport/tile to enter the event waiting area
local aidLeave = 1511 -- ActionId of teleport/tile to leave the event waiting area

function onStepIn(creature, item, position, fromPosition)
    local player = Player(creature)

    if not player then creature:teleportTo(fromPosition) return true end

    if item.actionid == aidEnter then
        if MW_STATUS ~= 1 then
            player:teleportTo(fromPosition)
            player:sendCancelMessage("Monster wave event is not open.")
            return true
        end
    
        if player:getLevel() < MW_minLevel then
            player:teleportTo(fromPosition)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You must be level "..MW_minLevel.." to enter this event.")
        else
            player:teleportTo(MW_positionEnter)
            if not MW_PLAYERS[1] then
                MW_PLAYERS[1] = player:getName()
            else
                MW_PLAYERS[#MW_PLAYERS + 1] = player:getName()
            end
        end
    else
        for i = 1, #MW_PLAYERS do
            if MW_PLAYERS[i] == player:getName() then
                MW_PLAYERS[i] = nil
            end
        end
    
        player:teleportTo(MW_positionLeave)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You will no longer paticipate in the event.")
    end
    return true
end