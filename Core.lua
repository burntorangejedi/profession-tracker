-- Core addon initialization and event handling
ProfessionTracker = {}
ProfessionTracker.version = "1.0.0"

-- Initialize saved variables
function ProfessionTracker:InitializeDB()
    if not ProfessionTrackerDB then
        ProfessionTrackerDB = {
            characters = {},
            settings = {
                showTooltips = true,
                autoScan = true,
                showSkillLevel = true
            }
        }
    end
    self.db = ProfessionTrackerDB
end

-- Get current character key
function ProfessionTracker:GetCharacterKey()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    return playerName .. "-" .. realmName
end

-- Scan current character's professions
function ProfessionTracker:ScanProfessions()
    local characterKey = self:GetCharacterKey()
    local characterData = {
        name = UnitName("player"),
        realm = GetRealmName(),
        class = select(2, UnitClass("player")),
        level = UnitLevel("player"),
        professions = {},
        lastUpdate = time()
    }
    
    -- Get profession information using modern API
    local professionInfo = C_TradeSkillUI.GetAllProfessionTradeSkillLines()
    
    if professionInfo then
        for _, profData in ipairs(professionInfo) do
            if profData.skillLineID then
                local skillLineInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(profData.skillLineID)
                if skillLineInfo then
                    characterData.professions[profData.skillLineID] = {
                        name = skillLineInfo.professionName or profData.parentProfessionName,
                        icon = skillLineInfo.professionIcon,
                        skillLevel = skillLineInfo.skillLevel,
                        maxSkillLevel = skillLineInfo.skillModifier,
                        skillLineID = profData.skillLineID,
                        recipes = {}
                    }
                    
                    -- Scan recipes for this profession
                    self:ScanRecipesModern(profData.skillLineID, characterData.professions[profData.skillLineID])
                end
            end
        end
    end
    
    -- Fallback to old API if new one doesn't work
    if not next(characterData.professions) then
        local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
        local professionSlots = {prof1, prof2, archaeology, fishing, cooking}
        
        for i, profSlot in ipairs(professionSlots) do
            if profSlot then
                local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine = GetProfessionInfo(profSlot)
                if name and skillLine then
                    characterData.professions[skillLine] = {
                        name = name,
                        icon = icon,
                        skillLevel = skillLevel,
                        maxSkillLevel = maxSkillLevel,
                        skillLineID = skillLine,
                        recipes = {}
                    }
                    
                    -- Get known recipes for this profession
                    self:ScanRecipesLegacy(profSlot, characterData.professions[skillLine])
                end
            end
        end
    end
    
    self.db.characters[characterKey] = characterData
    print("ProfessionTracker: Scanned professions for " .. characterKey)
end

-- Scan recipes using modern API
function ProfessionTracker:ScanRecipesModern(skillLineID, professionData)
    -- Open the profession if it's not already open
    local wasOpen = C_TradeSkillUI.IsTradeSkillReady()
    if not wasOpen then
        C_TradeSkillUI.OpenTradeSkill(skillLineID)
    end
    
    -- Wait a bit for the UI to be ready
    C_Timer.After(0.1, function()
        local recipes = C_TradeSkillUI.GetAllRecipeIDs()
        if recipes then
            for _, recipeID in ipairs(recipes) do
                local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
                if recipeInfo and recipeInfo.learned then
                    local itemID = recipeInfo.itemID
                    local itemName = nil
                    
                    if itemID then
                        itemName = C_Item.GetItemNameByID(itemID)
                    end
                    
                    professionData.recipes[recipeID] = {
                        name = recipeInfo.name,
                        itemID = itemID,
                        itemName = itemName,
                        difficulty = recipeInfo.difficulty
                    }
                end
            end
        end
        
        -- Close profession if we opened it
        if not wasOpen then
            C_TradeSkillUI.CloseTradeSkill()
        end
    end)
end

-- Fallback scan for older API
function ProfessionTracker:ScanRecipesLegacy(professionIndex, professionData)
    local numRecipes = select(4, GetProfessionInfo(professionIndex))
    if not numRecipes then return end
    
    for i = 1, numRecipes do
        local recipeName, recipeType, numAvailable, isExpanded, serviceType, numSkillUps, recipeID = GetTradeSkillInfo(i)
        if recipeID and recipeName and recipeType ~= "header" then
            local link = GetTradeSkillItemLink(i)
            local itemID = nil
            local itemName = nil
            
            if link then
                itemID = tonumber(link:match("item:(%d+)"))
                itemName = GetItemInfo(itemID)
            end
            
            professionData.recipes[recipeID] = {
                name = recipeName,
                itemID = itemID,
                itemName = itemName
            }
        end
    end
end

-- Find characters who can craft an item
function ProfessionTracker:FindCrafters(searchTerm)
    local results = {}
    local searchLower = searchTerm:lower()
    
    for charKey, charData in pairs(self.db.characters) do
        for profID, profData in pairs(charData.professions) do
            for recipeID, recipeData in pairs(profData.recipes) do
                local match = false
                
                -- Check if search matches item name, recipe name, or item ID
                if recipeData.itemName and recipeData.itemName:lower():find(searchLower) then
                    match = true
                elseif recipeData.name and recipeData.name:lower():find(searchLower) then
                    match = true
                elseif tostring(recipeData.itemID) == searchTerm then
                    match = true
                elseif tostring(recipeID) == searchTerm then
                    match = true
                end
                
                if match then
                    table.insert(results, {
                        character = charData,
                        profession = profData,
                        recipe = recipeData,
                        recipeID = recipeID
                    })
                end
            end
        end
    end
    
    return results
end

-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("TRADE_SKILL_SHOW")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "ProfessionTracker" then
            ProfessionTracker:InitializeDB()
            print("ProfessionTracker loaded! Type /pt to open the interface.")
        end
    elseif event == "PLAYER_LOGIN" then
        if ProfessionTracker.db.settings.autoScan then
            C_Timer.After(5, function() ProfessionTracker:ScanProfessions() end)
        end
    elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_LIST_UPDATE" then
        if ProfessionTracker.db.settings.autoScan then
            -- Delay scan slightly to ensure trade skill data is loaded
            C_Timer.After(1, function() ProfessionTracker:ScanProfessions() end)
        end
    end
end)

-- Slash commands
SLASH_PROFESSIONTRACKER1 = "/pt"
SLASH_PROFESSIONTRACKER2 = "/professiontracker"

SlashCmdList["PROFESSIONTRACKER"] = function(msg)
    local args = {strsplit(" ", msg)}
    local command = args[1] and args[1]:lower() or ""
    
    if command == "scan" then
        ProfessionTracker:ScanProfessions()
    elseif command == "find" or command == "search" then
        local searchTerm = msg:gsub("^%w+%s*", "")
        if searchTerm and searchTerm ~= "" then
            ProfessionTracker:ShowSearchResults(searchTerm)
        else
            print("Usage: /pt find <item name or ID>")
        end
    elseif command == "show" or command == "" then
        ProfessionTracker:ShowMainWindow()
    elseif command == "help" then
        print("ProfessionTracker Commands:")
        print("/pt or /pt show - Open main window")
        print("/pt scan - Scan current character's professions")
        print("/pt find <item> - Search for who can craft an item")
        print("/pt help - Show this help")
    else
        print("Unknown command. Type '/pt help' for help.")
    end
end
