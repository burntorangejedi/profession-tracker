-- UI components for the addon
ProfessionTracker.UI = {}

-- Main window
function ProfessionTracker:ShowMainWindow()
    if self.mainFrame and self.mainFrame:IsShown() then
        self.mainFrame:Show()
        return
    end
    
    -- Create main frame
    local frame = CreateFrame("Frame", "ProfessionTrackerMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(800, 600)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("Profession Tracker")
    
    self.mainFrame = frame
    
    -- Create content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    
    -- Create tabs
    self:CreateTabs(content)
    
    frame:Show()
end

-- Create tab system
function ProfessionTracker:CreateTabs(parent)
    local tabs = {"Search", "Characters", "Professions", "Settings"}
    local tabFrames = {}
    local tabButtons = {}
    
    -- Create tab buttons
    for i, tabName in ipairs(tabs) do
        local button = CreateFrame("Button", nil, parent, "CharacterFrameTabButtonTemplate")
        button:SetPoint("TOPLEFT", parent, "TOPLEFT", (i-1) * 100, 0)
        button:SetText(tabName)
        button:SetID(i)
        
        button:SetScript("OnClick", function(self)
            ProfessionTracker:SelectTab(self:GetID(), tabFrames, tabButtons)
        end)
        
        tabButtons[i] = button
        
        -- Create tab content frame
        local tabFrame = CreateFrame("Frame", nil, parent)
        tabFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -30)
        tabFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
        tabFrame:Hide()
        
        tabFrames[i] = tabFrame
        
        -- Populate tab content
        if tabName == "Search" then
            self:CreateSearchTab(tabFrame)
        elseif tabName == "Characters" then
            self:CreateCharactersTab(tabFrame)
        elseif tabName == "Professions" then
            self:CreateProfessionsTab(tabFrame)
        elseif tabName == "Settings" then
            self:CreateSettingsTab(tabFrame)
        end
    end
    
    -- Select first tab
    self:SelectTab(1, tabFrames, tabButtons)
    
    self.tabFrames = tabFrames
    self.tabButtons = tabButtons
end

-- Select a tab
function ProfessionTracker:SelectTab(tabIndex, tabFrames, tabButtons)
    for i, frame in ipairs(tabFrames) do
        if i == tabIndex then
            frame:Show()
            tabButtons[i]:SetEnabled(false)
        else
            frame:Hide()
            tabButtons[i]:SetEnabled(true)
        end
    end
end

-- Create search tab
function ProfessionTracker:CreateSearchTab(parent)
    -- Search input
    local searchLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    searchLabel:SetText("Search for items:")
    
    local searchBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    searchBox:SetSize(300, 20)
    searchBox:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -5)
    searchBox:SetAutoFocus(false)
    
    local searchButton = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    searchButton:SetSize(80, 22)
    searchButton:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    searchButton:SetText("Search")
    
    local scanButton = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    scanButton:SetSize(120, 22)
    scanButton:SetPoint("LEFT", searchButton, "RIGHT", 10, 0)
    scanButton:SetText("Scan Current")
    
    -- Results scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -20)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1)
    scrollFrame:SetScrollChild(content)
    
    self.searchContent = content
    
    -- Button functions
    searchButton:SetScript("OnClick", function()
        self:PerformSearchSimple(searchBox:GetText())
    end)
    
    scanButton:SetScript("OnClick", function()
        self:ScanProfessions()
        print("Current character scanned!")
    end)
    
    searchBox:SetScript("OnEnterPressed", function()
        self:PerformSearchSimple(searchBox:GetText())
    end)
end

-- Simple search without external UI library
function ProfessionTracker:PerformSearchSimple(searchTerm)
    -- Clear previous results
    if self.searchContent then
        for i = 1, self.searchContent:GetNumChildren() do
            local child = select(i, self.searchContent:GetChildren())
            child:Hide()
        end
    end
    
    if not searchTerm or searchTerm == "" then
        return
    end
    
    local results = self:FindCrafters(searchTerm)
    
    if #results == 0 then
        local label = self.searchContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", self.searchContent, "TOPLEFT", 0, 0)
        label:SetText("No results found for: " .. searchTerm)
        return
    end
    
    -- Display results
    local yOffset = 0
    local itemGroups = {}
    
    -- Group results by item
    for _, result in ipairs(results) do
        local itemKey = result.recipe.itemID or result.recipe.name
        if not itemGroups[itemKey] then
            itemGroups[itemKey] = {
                itemName = result.recipe.itemName or result.recipe.name,
                itemID = result.recipe.itemID,
                crafters = {}
            }
        end
        table.insert(itemGroups[itemKey].crafters, result)
    end
    
    for itemKey, itemGroup in pairs(itemGroups) do
        -- Item header
        local itemLabel = self.searchContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        itemLabel:SetPoint("TOPLEFT", self.searchContent, "TOPLEFT", 0, yOffset)
        local itemText = itemGroup.itemName
        if itemGroup.itemID then
            itemText = itemText .. " (ID: " .. itemGroup.itemID .. ")"
        end
        itemLabel:SetText(itemText)
        yOffset = yOffset - 20
        
        -- Crafters
        for _, crafter in ipairs(itemGroup.crafters) do
            local crafterLabel = self.searchContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            crafterLabel:SetPoint("TOPLEFT", self.searchContent, "TOPLEFT", 20, yOffset)
            local text = string.format("%s (%s) - %s (Level %d)",
                crafter.character.name,
                crafter.character.realm,
                crafter.profession.name,
                crafter.profession.skillLevel
            )
            crafterLabel:SetText(text)
            yOffset = yOffset - 15
        end
        
        yOffset = yOffset - 10 -- Extra space between items
    end
    
    -- Update content height
    self.searchContent:SetHeight(math.abs(yOffset))
end

-- Create characters tab
function ProfessionTracker:CreateCharactersTab(parent)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    label:SetText("Character Professions")
    
    -- Scroll frame for characters
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1)
    scrollFrame:SetScrollChild(content)
    
    self:PopulateCharactersTab(content)
end

-- Populate characters tab
function ProfessionTracker:PopulateCharactersTab(content)
    local characters = self.Database:GetAllCharacters()
    local yOffset = 0
    
    if not next(characters) then
        local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        label:SetText("No character data found. Use '/pt scan' to scan your current character.")
        return
    end
    
    for charKey, charData in pairs(characters) do
        -- Character header
        local charLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        charLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        charLabel:SetText(charData.name .. " (" .. charData.realm .. ") - Level " .. charData.level .. " " .. charData.class)
        yOffset = yOffset - 20
        
        if not next(charData.professions) then
            local noProfLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            noProfLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 20, yOffset)
            noProfLabel:SetText("No professions recorded")
            yOffset = yOffset - 15
        else
            for profID, profData in pairs(charData.professions) do
                local recipeCount = 0
                for _ in pairs(profData.recipes) do recipeCount = recipeCount + 1 end
                
                local profLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                profLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 20, yOffset)
                local text = string.format("%s: %d/%d (%d recipes)",
                    profData.name,
                    profData.skillLevel,
                    profData.maxSkillLevel,
                    recipeCount
                )
                profLabel:SetText(text)
                yOffset = yOffset - 15
            end
        end
        
        yOffset = yOffset - 10 -- Extra space between characters
    end
    
    content:SetHeight(math.abs(yOffset))
end

-- Create professions tab
function ProfessionTracker:CreateProfessionsTab(parent)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    label:SetText("Professions Overview")
    
    -- Simple text display for now
    local infoLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    infoLabel:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -20)
    infoLabel:SetText("Use the Characters tab to view profession details for each character.")
end

-- Create settings tab
function ProfessionTracker:CreateSettingsTab(parent)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    label:SetText("Settings")
    
    -- Auto scan checkbox
    local autoScanCheck = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    autoScanCheck:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -20)
    autoScanCheck.text:SetText("Auto-scan professions when logging in or opening trade skills")
    autoScanCheck:SetChecked(self.db.settings.autoScan)
    autoScanCheck:SetScript("OnClick", function(self)
        ProfessionTracker.db.settings.autoScan = self:GetChecked()
    end)
    
    -- Show tooltips checkbox
    local tooltipsCheck = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    tooltipsCheck:SetPoint("TOPLEFT", autoScanCheck, "BOTTOMLEFT", 0, -10)
    tooltipsCheck.text:SetText("Show profession info in item tooltips")
    tooltipsCheck:SetChecked(self.db.settings.showTooltips)
    tooltipsCheck:SetScript("OnClick", function(self)
        ProfessionTracker.db.settings.showTooltips = self:GetChecked()
    end)
    
    -- Statistics
    local stats = self.Database:GetStatistics()
    local statsLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statsLabel:SetPoint("TOPLEFT", tooltipsCheck, "BOTTOMLEFT", 0, -30)
    local statsText = string.format([[Statistics:
Characters tracked: %d
Total professions: %d
Total recipes: %d
Unique craftable items: %d]], stats.totalCharacters, stats.totalProfessions, stats.totalRecipes, stats.uniqueItems)
    statsLabel:SetText(statsText)
end

-- Show search results in a simple format
function ProfessionTracker:ShowSearchResults(searchTerm)
    local results = self:FindCrafters(searchTerm)
    
    if #results == 0 then
        print("No crafters found for: " .. searchTerm)
        return
    end
    
    print("Crafters for '" .. searchTerm .. "':")
    for _, result in ipairs(results) do
        local itemName = result.recipe.itemName or result.recipe.name
        print(string.format("  %s (%s) can craft %s with %s (Level %d)",
            result.character.name,
            result.character.realm,
            itemName,
            result.profession.name,
            result.profession.skillLevel
        ))
    end
end

-- Tooltip integration
local function OnTooltipSetItem(tooltip)
    if not ProfessionTracker.db.settings.showTooltips then return end
    
    local itemName, itemLink = tooltip:GetItem()
    if not itemName then return end
    
    local results = ProfessionTracker:FindCrafters(itemName)
    if #results > 0 then
        tooltip:AddLine(" ")
        tooltip:AddLine("Can be crafted by:", 0.5, 1, 0.5)
        
        for _, result in ipairs(results) do
            tooltip:AddLine(string.format("%s (%s) - %s",
                result.character.name,
                result.character.realm,
                result.profession.name
            ), 1, 1, 1)
        end
    end
end

-- Hook tooltips
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
