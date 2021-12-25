local timeWait = 5 -- Time in minutes to wait until trying to start the event. --

function onThink(interval)
    if MW_STATUS == 0 then
        Game.broadcastMessage("Monster wave event is now open. Enter the event portal to particiapte.", 1)
        MW_STATUS = 1
        addEvent(MW_tryEvent, timeWait * 60 * 1000)
    end
    return true
end