local items = {}
local current = nil
local rolls = {}
local reasons = {[98]="transmog", [99]="off spec", [100]="main spec"}

local getWinner, sold, goingTwice, goingOnce, start;

local function raidWarning(msg)
  SendChatMessage(msg, "RAID_WARNING")
end

getWinner = function()
  local winner = nil
  for k, v in pairs(rolls) do
    if winner == nil or v.max > rolls[winner].max or (v.max == rolls[winner].max and v.result > rolls[winner].result) then
      winner = k
    end
  end
  if (winner == nil) then return "no one"; end
  return winner .. " for " .. reasons[rolls[winner].max]
end

sold = function()
  local winner = getWinner()
  raidWarning(current.owner .. "'s " .. current.link .. " Sold to " .. winner .. "!")
  current = nil
  C_Timer.After(5, start)
end

start = function()
  if current ~= nil then return; end
  current = table.remove(items, 1)
  if current == nil then return; end
  rolls = {}
  raidWarning("Rolls on " .. current.owner .. "'s ".. current.link .. "! (ms = /roll, os = /roll 99, xmog = /roll 98)")
  C_Timer.After(15, goingOnce)
end

goingOnce = function()
  raidWarning(current.owner .. "'s " .. current.link .. " Going once! (Winning: " .. getWinner().. ")")
  C_Timer.After(5, goingTwice)
end

goingTwice = function()
  raidWarning(current.owner .. "'s " .. current.link .. " Going twice! (Winning: " .. getWinner().. ")")
  C_Timer.After(5, sold)
end

local messageFrame = CreateFrame("FRAME", "ScalebaneLootMessageFrame")
messageFrame :RegisterEvent("CHAT_MSG_RAID")
messageFrame :RegisterEvent("CHAT_MSG_RAID_LEADER")
messageFrame :SetScript("OnEvent", function (self, event, message, author)
  local sName = GetItemInfo(message)
  if sName == nil then return; end
  local item = {link=message, owner=author}
  table.insert(items, item)
  C_Timer.After(5, start)
end)

local rollFrame = CreateFrame("FRAME", "ScalebaneLootRollFrame")
rollFrame :RegisterEvent("CHAT_MSG_SYSTEM")
rollFrame :SetScript("OnEvent", function(self, event, message)
  local roller, result, minStr, maxStr = string.match(message, "(.+) rolls (%d+) %((%d+)-(%d+)%)")
  local min = tonumber(minStr)
  local max = tonumber(maxStr)
  if current == nil or roller == nil or rolls[roller] ~= nil or min ~= 1 or max < 98 or max > 100 then return; end
  rolls[roller] = {result=result, max=max}
end)
