-- Database functions for managing profession data
ProfessionTracker.Database = {}

-- Get all characters
function ProfessionTracker.Database:GetAllCharacters()
    return ProfessionTracker.db.characters
end

-- Get character data
function ProfessionTracker.Database:GetCharacter(characterKey)
    return ProfessionTracker.db.characters[characterKey]
end

-- Delete character data
function ProfessionTracker.Database:DeleteCharacter(characterKey)
    ProfessionTracker.db.characters[characterKey] = nil
    print("Deleted character data for: " .. characterKey)
end

-- Get all unique professions across all characters
function ProfessionTracker.Database:GetAllProfessions()
    local professions = {}
    for charKey, charData in pairs(ProfessionTracker.db.characters) do
        for profID, profData in pairs(charData.professions) do
            if not professions[profID] then
                professions[profID] = {
                    name = profData.name,
                    icon = profData.icon,
                    id = profID
                }
            end
        end
    end
    return professions
end

-- Get all characters with a specific profession
function ProfessionTracker.Database:GetCharactersWithProfession(professionID)
    local characters = {}
    for charKey, charData in pairs(ProfessionTracker.db.characters) do
        if charData.professions[professionID] then
            table.insert(characters, {
                key = charKey,
                data = charData,
                profession = charData.professions[professionID]
            })
        end
    end
    return characters
end

-- Get all unique craftable items
function ProfessionTracker.Database:GetAllCraftableItems()
    local items = {}
    for charKey, charData in pairs(ProfessionTracker.db.characters) do
        for profID, profData in pairs(charData.professions) do
            for recipeID, recipeData in pairs(profData.recipes) do
                if recipeData.itemID and recipeData.itemName then
                    if not items[recipeData.itemID] then
                        items[recipeData.itemID] = {
                            itemID = recipeData.itemID,
                            itemName = recipeData.itemName,
                            crafters = {}
                        }
                    end
                    table.insert(items[recipeData.itemID].crafters, {
                        character = charData,
                        profession = profData,
                        recipe = recipeData
                    })
                end
            end
        end
    end
    return items
end

-- Search for items by name
function ProfessionTracker.Database:SearchItems(searchTerm)
    local results = {}
    local searchLower = searchTerm:lower()
    
    local allItems = self:GetAllCraftableItems()
    for itemID, itemData in pairs(allItems) do
        if itemData.itemName:lower():find(searchLower) then
            table.insert(results, itemData)
        end
    end
    
    -- Sort by item name
    table.sort(results, function(a, b) return a.itemName < b.itemName end)
    return results
end

-- Get statistics
function ProfessionTracker.Database:GetStatistics()
    local stats = {
        totalCharacters = 0,
        totalProfessions = 0,
        totalRecipes = 0,
        uniqueItems = 0,
        professionCounts = {}
    }
    
    local uniqueItems = {}
    
    for charKey, charData in pairs(ProfessionTracker.db.characters) do
        stats.totalCharacters = stats.totalCharacters + 1
        
        for profID, profData in pairs(charData.professions) do
            stats.totalProfessions = stats.totalProfessions + 1
            
            if not stats.professionCounts[profData.name] then
                stats.professionCounts[profData.name] = 0
            end
            stats.professionCounts[profData.name] = stats.professionCounts[profData.name] + 1
            
            for recipeID, recipeData in pairs(profData.recipes) do
                stats.totalRecipes = stats.totalRecipes + 1
                if recipeData.itemID then
                    uniqueItems[recipeData.itemID] = true
                end
            end
        end
    end
    
    for itemID in pairs(uniqueItems) do
        stats.uniqueItems = stats.uniqueItems + 1
    end
    
    return stats
end

-- Export data
function ProfessionTracker.Database:ExportData()
    local exportData = {
        version = ProfessionTracker.version,
        exportTime = time(),
        characters = ProfessionTracker.db.characters
    }
    return exportData
end

-- Import data
function ProfessionTracker.Database:ImportData(importData)
    if not importData.characters then
        return false, "Invalid import data"
    end
    
    local imported = 0
    for charKey, charData in pairs(importData.characters) do
        ProfessionTracker.db.characters[charKey] = charData
        imported = imported + 1
    end
    
    return true, "Imported " .. imported .. " characters"
end

-- Clean old data
function ProfessionTracker.Database:CleanOldData(daysOld)
    local cutoffTime = time() - (daysOld * 24 * 60 * 60)
    local cleaned = 0
    
    for charKey, charData in pairs(ProfessionTracker.db.characters) do
        if charData.lastUpdate and charData.lastUpdate < cutoffTime then
            ProfessionTracker.db.characters[charKey] = nil
            cleaned = cleaned + 1
        end
    end
    
    return cleaned
end
