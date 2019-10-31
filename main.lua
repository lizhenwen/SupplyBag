-- Number of bags a player has, think it's safe to hardcode it.
local GS_PLAYER_BAG_COUNT = 5
local SAVE_TMP

--//网摘,直接打印到屏幕
function printTable(t, n)
  if "table" ~= type(t) then
    return 0;
  end
  n = n or 0;
  local str_space = "";
  for i = 1, n do
    str_space = str_space.."  ";
  end
  print(str_space.."{");
  for k, v in pairs(t) do
    local str_k_v
    if(type(k)=="string")then
      str_k_v = str_space.."  "..tostring(k).." = ";
    else
      str_k_v = str_space.."  ["..tostring(k).."] = ";
    end
    if "table" == type(v) then
      print(str_k_v);
      printTable(v, n + 1);
    else
      if(type(v)=="string")then
        str_k_v = str_k_v.."\""..tostring(v).."\"";
      else
        str_k_v = str_k_v..tostring(v);
      end
      print(str_k_v);
    end
  end
  print(str_space.."}");
end

--复制table
function clone(org)
  local function copy(org, res)
      for k,v in pairs(org) do
          if type(v) ~= "table" then
              res[k] = v;
          else
              res[k] = {};
              copy(v, res[k])
          end
      end
  end

  local res = {}
  copy(org, res)
  return res
end

-- 获取当前包裹的物品清单
function getMyBagsItems()
    local itemList = {}
    -- we loop over the bag indexes
    for bag = 0, GS_PLAYER_BAG_COUNT - 1, 1 do
      for bagSlot = 1, GetContainerNumSlots(bag), 1 do
        local item = GetContainerItemLink(bag, bagSlot);
        local unusedTexture, itemCount = GetContainerItemInfo(bag, bagSlot);

        if (not (item == nil)) then 
          local itemName, itemLink, itemRarity,
          itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
          itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)
          local itemFullInfo = {}
          itemFullInfo['itemName'] = itemName
          itemFullInfo['itemCount'] = itemCount
          itemFullInfo['itemStackCount'] = itemStackCount

          table.insert(itemList,itemFullInfo)
        end -- closing if item is not nil

      end -- closing the looping inside a bag
    end -- closing the looping over all bags
    --printTable(itemList)
    return itemList
end

function save()
    print("save~~~~~~")
    local itemList = {}
    -- we loop over the bag indexes
    for bag = 0, GS_PLAYER_BAG_COUNT - 1, 1 do
      for bagSlot = 1, GetContainerNumSlots(bag), 1 do
        local item = GetContainerItemLink(bag, bagSlot);
        local unusedTexture, itemCount = GetContainerItemInfo(bag, bagSlot);

        if (not (item == nil)) then 
          local itemName, itemLink, itemRarity,
          itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
          itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)
          local curItemInfo = {}
          curItemInfo['itemName'] = itemName
          curItemInfo['itemCount'] = itemCount
          curItemInfo['itemStackCount'] = itemStackCount

          if(itemList[itemName]) then
            itemList[itemName]['itemCount'] = itemList[itemName]['itemCount'] + itemCount
          else 
            itemList[itemName] = curItemInfo
          end
        end -- closing if item is not nil

      end -- closing the looping inside a bag
    end -- closing the looping over all bags

    SAVE_TMP = itemList
end

function show()
    print("show~~~~~~")
    printTable(SAVE_TMP)
end

function load()
    print("load~~~~~~")
    local storeItems = clone(SAVE_TMP)
    local bagItems = getMyBagsItems()

    local needToBank = {} --需要存到银行的物品
    local needToBag = {} --需要从银行取出到背包的物品
    -- 把背包里面不是的存进银行
    for bag = 0, GS_PLAYER_BAG_COUNT - 1, 1 do
      for bagSlot = 1, GetContainerNumSlots(bag), 1 do
        local item = GetContainerItemLink(bag, bagSlot);
        local unusedTexture, itemCount = GetContainerItemInfo(bag, bagSlot);

        if (not (item == nil)) then 
          local itemName, itemLink, itemRarity,
          itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
          itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)

          local curStoreItem = storeItems[itemName]
          if(curStoreItem && curStoreItem.itemCount>0) then
            --如果store里有该物品，则保留该物品，并减掉store里的数量
            storeItems[itemName].itemCount = storeItems[itemName].itemCount - itemCount
          else
            --store里没有该物品，存到银行
            --PickupContainerItem(bagTypes[bag],slot)
            --PickupContainerItem(bkTypes[bkBag],bkSlot)
          end

        end -- closing if item is not nil

      end -- closing the looping inside a bag
    end -- closing the looping over all bags

end

SLASH_NOTICE1="/supplybag"
SlashCmdList["NOTICE"]=function(cmd)
    print("cmd:"..cmd)
    if cmd == 'save' then
        save()
      elseif cmd == 'show' then
        show()
      elseif cmd == 'load' then
        load()
    end
end