# Quick Installation Guide

## Installation Steps

1. **Locate your WoW Addons folder:**
   - Navigate to: `World of Warcraft\_retail_\Interface\AddOns\`
   - If the `AddOns` folder doesn't exist, create it

2. **Copy the addon:**
   - Copy the entire `ProfessionTracker` folder into the `AddOns` directory
   - The final path should be: `World of Warcraft\_retail_\Interface\AddOns\ProfessionTracker\`

3. **Verify installation:**
   - The folder should contain these files:
     - `ProfessionTracker.toc`
     - `Config.lua`
     - `Core.lua`
     - `Database.lua`
     - `UI.lua`

4. **Launch WoW:**
   - Start World of Warcraft
   - At the character selection screen, click "AddOns" and make sure "Profession Tracker" is checked
   - Log in with any character

## First Use

1. **Initial scan:**
   - Type `/pt scan` to scan your current character's professions
   - Or open any profession window (the addon will auto-scan if enabled)

2. **Open the interface:**
   - Type `/pt` to open the main window
   - Use the Search tab to find who can craft items

3. **Scan other characters:**
   - Log in to each of your other characters
   - The addon will automatically scan their professions on login (if auto-scan is enabled)
   - Or manually scan with `/pt scan`

## Quick Commands

- `/pt` - Open main interface
- `/pt scan` - Scan current character
- `/pt find <item>` - Search for crafters
- `/pt help` - Show help

## Troubleshooting

- **No professions found:** Make sure you have professions trained and try `/pt scan`
- **Interface won't open:** Try `/reload` to refresh the UI
- **No search results:** Ensure you've scanned the character who knows the recipe
