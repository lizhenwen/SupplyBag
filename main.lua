-- Number of bags a player has, think it's safe to hardcode it.
local GS_PLAYER_BAG_COUNT = 5

-- 获取当前包裹的物品清单
function getMyBagsItems()
    print("get my bag's items")
    -- we loop over the bag indexes
    for bag = 0, GS_PLAYER_BAG_COUNT - 1, 1 do
      for bagSlot = 1, GetContainerNumSlots(bag), 1 do
        local item = GetContainerItemLink(bag, bagSlot);
        local unusedTexture, itemCount = GetContainerItemInfo(bag, bagSlot);
        if (not (item == nil)) then 
          local itemName, itemLink, itemRarity,
          itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
          itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)
  
          print(itemName..':itemcount='..itemCount..', itemStackCount='..itemStackCount)
  
        end -- closing if item is not nil
      end -- closing the looping inside a bag
    end -- closing the looping over all bags
end

function save()
    print("save~~~~~~")
    getMyBagsItems()
end
function load()
    print("load~~~~~~")
end

SLASH_NOTICE1="/supplybag"
SlashCmdList["NOTICE"]=function(cmd)
    print("cmd:"..cmd)
    if cmd == 'save' then
        save()
    end
end