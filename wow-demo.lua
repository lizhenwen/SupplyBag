local hp = UnitHealth("player") 
local mp = UnitPower("player")

local noticeString = "我档期的血量为"..hp.."我档期的mp是"..mp

SLASH_NOTICE1="/notice"
SlashCmdList["NOTICE"]=function(a)
    SendChatMessage("lasdf111"..a..noticeString,"say")
end