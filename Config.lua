-- Example configuration and helper functions
ProfessionTracker.Config = {
    -- Profession skill line IDs (these may need updating for current WoW)
    PROFESSIONS = {
        [171] = "Alchemy",
        [164] = "Blacksmithing",
        [333] = "Enchanting",
        [202] = "Engineering",
        [182] = "Herbalism",
        [773] = "Inscription",
        [755] = "Jewelcrafting",
        [165] = "Leatherworking",
        [186] = "Mining",
        [393] = "Skinning",
        [197] = "Tailoring",
        [185] = "Cooking",
        [129] = "First Aid", -- No longer in game but kept for old data
        [356] = "Fishing",
        [794] = "Archaeology"
    },
    
    -- UI Settings
    UI = {
        MAIN_FRAME_WIDTH = 800,
        MAIN_FRAME_HEIGHT = 600,
        SEARCH_RESULTS_HEIGHT = 400,
        TAB_HEIGHT = 30
    },
    
    -- Colors (RGB values)
    COLORS = {
        HEADER = {1, 0.82, 0},      -- Gold
        NORMAL = {1, 1, 1},         -- White
        HIGHLIGHT = {0, 1, 0},      -- Green
        ERROR = {1, 0, 0}           -- Red
    }
}

-- Helper function to get profession name by ID
function ProfessionTracker.Config:GetProfessionName(skillLineID)
    return self.PROFESSIONS[skillLineID] or "Unknown"
end

-- Helper function to validate profession data
function ProfessionTracker.Config:IsValidProfession(skillLineID)
    return self.PROFESSIONS[skillLineID] ~= nil
end
