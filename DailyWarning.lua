local function AddQuestIcon(button)
  if not button or button.questIcon then
    return
  end

  local icon = button:CreateTexture(nil, "OVERLAY")
  icon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
  --icon:SetSize(16, 16)
  icon:SetPoint("RIGHT", button, "RIGHT", -10, 0)
  button.questIcon = icon
end

local function AddQuestIcons()
  AddQuestIcon(GameMenuButtonLogout)
  AddQuestIcon(GameMenuButtonQuit)
end

local function AddTooltip(button, completedQuests)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Completed Daily Quests", 1, 1, 1)
    if #completedQuests == 0 then
      GameTooltip:AddLine("None", 0.8, 0.8, 0.8)
    else
      for _, questName in ipairs(completedQuests) do
        GameTooltip:AddLine(questName, 1, 1, 0)
      end
    end
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
end

local function RemoveTooltip(button)
  button:SetScript("OnEnter", nil)
  button:SetScript("OnLeave", nil)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
  AddQuestIcons()
  frame:UnregisterAllEvents()
end)

-- QuestLog API is very unintuitive. Care
local function GetCompletedDailyQuests()
  local completedQuests = {}
  local numQuestTitles, numQuests = GetNumQuestLogEntries()
  for i = 1, numQuestTitles do
    -- GetQuestLogTitle(n) returns the category headers or the quest titles from the same function
    local titleText, level, type, _, _, _, isComplete, isDaily = GetQuestLogTitle(i)
    -- type can be "PvP" for pvp dailys, "Heroic" for hc daily

    if isDaily and isComplete then
      table.insert(completedQuests, titleText)
    end
  end
  return completedQuests
end

local function UpdateQuestIcons()
  local completedQuests = GetCompletedDailyQuests()
  if #completedQuests > 0 then
    GameMenuButtonLogout.questIcon:Show()
    GameMenuButtonQuit.questIcon:Show()
    AddTooltip(GameMenuButtonLogout, completedQuests)
    AddTooltip(GameMenuButtonQuit, completedQuests)
  else
    GameMenuButtonLogout.questIcon:Hide()
    GameMenuButtonQuit.questIcon:Hide()
    RemoveTooltip(GameMenuButtonLogout)
    RemoveTooltip(GameMenuButtonQuit)
  end
end

GameMenuFrame:HookScript("OnShow", function()
  UpdateQuestIcons()
end)
