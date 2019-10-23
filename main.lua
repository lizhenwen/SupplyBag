local hp = UnitHealth("player")
local mp = UnitPower("player")

local noticeString = "我档期的血量为"..hp.."我档期的mp是"..mp

-- 获取当前包裹的物品清单
function getMyBagsItems()
    print("get my bag's items")
end

function save()
    print("save~~~~~~")
end
function load()
    print("load~~~~~~")
end

SLASH_NOTICE1="/supplybag"
SlashCmdList["NOTICE"]=function(cmd)
    SendChatMessage("cmd:"..cmd,"say")
    print("cmd:"..cmd)
end