-- Number of bags a player has, think it's safe to hardcode it.
local GS_PLAYER_BAG_COUNT = 5

--//直接打印table
function printTable(t, n)
  if "table" ~= type(t) then
    return 0
  end
  n = n or 0
  local str_space = ""
  for i = 1, n do
    str_space = str_space.."  "
  end
  print(str_space.."{")
  for k, v in pairs(t) do
    local str_k_v
    if(type(k)=="string")then
      str_k_v = str_space.."  "..tostring(k).." = "
    else
      str_k_v = str_space.."  ["..tostring(k).."] = "
    end
    if "table" == type(v) then
      print(str_k_v)
      printTable(v, n + 1)
    else
      if(type(v)=="string")then
        str_k_v = str_k_v.."\""..tostring(v).."\""
      else
        str_k_v = str_k_v..tostring(v)
      end
      print(str_k_v)
    end
  end
  print(str_space.."}")
end

--复制table
function clone(org)
  local function copy(org, res)
      for k,v in pairs(org) do
          if type(v) ~= "table" then
              res[k] = v
          else
              res[k] = {}
              copy(v, res[k])
          end
      end
  end

  local res = {}
  copy(org, res)
  return res
end

function getTableLen(tab)
  local count=0
  for k,v in pairs(tab) do
      count = count + 1
  end
  return count
end


-- 获取当前包裹的物品清单
function getMyBagsItems()
    local itemList = {}
    -- we loop over the bag indexes
    for bag = 0, GS_PLAYER_BAG_COUNT - 1, 1 do
      for bagSlot = 1, GetContainerNumSlots(bag), 1 do
        local item = GetContainerItemLink(bag, bagSlot)
        local unusedTexture, itemCount = GetContainerItemInfo(bag, bagSlot)

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

function getConfig(name) 
  return SupplyBagSavedVariablesPerCharacter.data[name]
end
function saveConfig(name,itemList) 
  SupplyBagSavedVariablesPerCharacter.data = SupplyBagSavedVariablesPerCharacter.data or {}
  SupplyBagSavedVariablesPerCharacter.data[name] = itemList
end

function save(name)
    print("save~~~~~~")
    local itemList = {}
    -- we loop over the bag indexes
    for bag = 0, GS_PLAYER_BAG_COUNT - 1, 1 do
      for bagSlot = 1, GetContainerNumSlots(bag), 1 do
        local item = GetContainerItemLink(bag, bagSlot)
        local unusedTexture, itemCount = GetContainerItemInfo(bag, bagSlot)

        if (not (item == nil)) then 
          local itemName, itemLink, itemRarity,
          itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
          itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)
          local curItemInfo = {}
          curItemInfo['itemName'] = itemName
          curItemInfo['itemCount'] = itemCount
          curItemInfo['itemStackCount'] = itemStackCount

          if(itemList[itemName]) then --重复的物品，增加计数
            itemList[itemName]['itemCount'] = itemList[itemName]['itemCount'] + itemCount
          else
            itemList[itemName] = curItemInfo
          end
        end -- closing if item is not nil

      end -- closing the looping inside a bag
    end -- closing the looping over all bags

    saveConfig(name,itemList)
end

function list()
  local allList = SupplyBagSavedVariablesPerCharacter.data
  if not allList then
    print('没有配置')
  else
    local listStr = ''
    for k in pairs(allList) do
      listStr = listStr..k..'\n'
    end
    if string.len(listStr)<=0 then
      print('没有配置')
    else
      print('目前已有以下配置: \n'..listStr)
    end
  end
end

function remove(key)
  local allList = SupplyBagSavedVariablesPerCharacter.data
  if not allList then
    print('没有配置')
  else
    local curConfig = allList[key]
    if not curConfig then
      print('没有找到配置"'..key..'"')
    else
      allList[key] = nil
      print('删除配置成功')
    end
  end
end

function load(key)
    if not SupplyBag.bankOpened then
      print('请打开银行进行补给')
      return
    end
    
    local storeConfig = getConfig(key)
    if not storeConfig then
      print('没有配置'..key)
      return
    end
    
    local storeItems = clone(storeConfig)
    local storeItemsLen = getTableLen(storeItems)
    local storeDone = 0
    local bagItems = getMyBagsItems()

    local bagEmptySlot = {}

    -- 把背包里面不是的存进银行
    for bag = 0, NUM_BAG_SLOTS do
      for bagSlot = 1, GetContainerNumSlots(bag), 1 do
        local item = GetContainerItemLink(bag, bagSlot)
        local unusedTexture, itemCount = GetContainerItemInfo(bag, bagSlot)

        if (not (item == nil)) then 
          local itemName, itemLink, itemRarity,
          itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
          itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)

          local curStoreItem = storeItems[itemName]
          if(curStoreItem and curStoreItem.itemCount>0) then
            --如果store里有该物品，则保留背包里该物品，并减掉store里的数量
            local count = storeItems[itemName].itemCount - itemCount
            storeItems[itemName].itemCount = count
            if (count<=0) then
              storeDone = storeDone+1
              storeItems[itemName] = nil
            end
          else
            --store里没有该物品，存到银行
            --PickupContainerItem(bagTypes[bag],slot)
            --PickupContainerItem(bkTypes[bkBag],bkSlot)
          end
        else --空背包先存着，后面取物品需要
          local emptySlot = {bag,bagSlot}
          table.insert(bagEmptySlot,emptySlot)
        end
      end
    end

    if (storeDone >= storeItemsLen) then --不用从银行取货了
      print('背包里面物品齐全，不需要补充')
    else  --开始从银行里取物品
      -- 5 to 11 for bank bags (numbered left to right, was 5-10 prior to 2.0)
      -- -1是银行原始包，坑
      --https://wowwiki.fandom.com/wiki/BagId
      for bankBag = -1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
        if (bankBag >= 0 and bankBag<NUM_BAG_SLOTS+1) then
          --不是银行背包，不作处理，lua没有continue，先这么着
        else
          for bankBagSlot = 1, GetContainerNumSlots(bankBag), 1 do
            local item = GetContainerItemLink(bankBag, bankBagSlot)
            local unusedTexture, itemCount = GetContainerItemInfo(bankBag, bankBagSlot)
    
            if (not (item == nil)) then 
              local itemName, itemLink, itemRarity,
              itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
              itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)
              
              local storeItem = storeItems[itemName]
              if (storeItem and storeItem.itemCount>0) then --需要放到背包
                -- 放到背包
                PickupContainerItem(bankBag, bankBagSlot)
                local emptySlot = bagEmptySlot[1]
                PickupContainerItem(emptySlot[1], emptySlot[2])
                table.remove(bagEmptySlot,1)

                local count = storeItem.itemCount - itemCount
                storeItem.itemCount = count
                if (count<=0) then --如果这个物品都拿完了，就记个数，后面校验是否有缺的物品
                  storeDone = storeDone+1
                end
              end
              
            end
          end
        end
      end
    end

    if (storeDone >= storeItemsLen) then --不用从银行取货了
      print('已经补充完毕')
    else
      print('还缺少东西没补充: ')

      local listStr = ''
      for k in pairs(storeItems) do
        listStr = listStr..k..'\n'
      end
      print(listStr)
    end

end

--BANKFRAME_OPENED

SLASH_SUPPLYBAG1="/supplybag"
SlashCmdList["SUPPLYBAG"]=function(msg)
    local arr = {}
    for w in string.gmatch(msg, "%S+") do
      table.insert(arr,w)
    end
    local cmd = arr[1]
    local key = arr[2]

    if cmd == 'save' then
        if (not key) then
          print('请输入要保存的名称')
        else
          save(key)
        end
      elseif cmd == 'list' then
        list()
      elseif cmd == 'load' then
        if (not key) then
          print('请输入要加载的配置名称')
        else
          load(key)
        end
      elseif cmd == 'remove' then
        if (not key) then
          print('请输入要删除的配置名称')
        else
          remove(key)
        end
    end
end

SupplyBag = CreateFrame"Frame"
SupplyBag:SetScript("OnEvent", function(self, event, ...) self[event](self,event,...) end)
local version = GetAddOnMetadata("SupplyBag", "Version") or "alpha"
SupplyBag.version = version

function SupplyBag:ADDON_LOADED(event, addon)
	if addon ~= 'SupplyBag' then return end
	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
	
	SupplyBagSavedVariablesPerCharacter = SupplyBagSavedVariablesPerCharacter or {}
	
	local oldver = SupplyBagSavedVariablesPerCharacter.version
	if oldver ~= version then
		SupplyBagSavedVariablesPerCharacter.version = version
	end
	
	print(format('SupplyBag %s loaded!', version))
	
	SupplyBag:RegisterEvent"BANKFRAME_OPENED"
	SupplyBag:RegisterEvent"BANKFRAME_CLOSED"
	
end
SupplyBag:RegisterEvent"ADDON_LOADED"

function SupplyBag:BANKFRAME_OPENED()
	SupplyBag.bankOpened = true
end

function SupplyBag:BANKFRAME_CLOSED()
	SupplyBag.bankOpened = false
end