local moveevent = MoveEvent()
local moveevent1 = MoveEvent()

local pos = getPlayerPosition(cid)
local effectItem = 7697

function moveevent.onEquip(player, item, slot, isCheck)
    for _, player in ipairs(Game.getPlayers()) do
    local ring = player:getSlotItem(CONST_SLOT_RING)
        if ring and ring:getId() == effectItem then
        player:getPosition():sendMagicEffect(234) -- sends effect 234
    end
    end
    return true
end

function moveevent1.onDeEquip(player, item, slot, isCheck)
player:getPosition():sendMagicEffect(235) -- sends effect 235
return true
end

moveevent:type("equip")
moveevent:id(effectItem)
moveevent:register()
moveevent1:type("deEquip")
moveevent1:id(effectItem)
moveevent1:register()