function onSay(player, words, param, channel)
    if not player:getGroup():getAccess() then
        return true
    end

    if MW_STATUS == 1 or MW_STATUS == 2 then
        MW_endEvent()
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You have ended the event. It will start again after the defined time in the lib file.")
    else
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "The event is not running.")
    end
    return true
end