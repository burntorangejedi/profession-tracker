# Profession Tracker - World of Warcraft Addon

A comprehensive World of Warcraft addon that tracks all your characters' professions and makes it easy to find which character can craft specific items.

## Features

- **Character Profession Tracking**: Automatically scans and stores profession data for all your characters
- **Recipe Database**: Tracks all known recipes for each character's professions
- **Smart Search**: Search for items by name or ID to find which characters can craft them
- **Cross-Character Reference**: View all characters and their professions in one place
- **Tooltip Integration**: Shows crafting information directly in item tooltips
- **Auto-Scanning**: Automatically updates profession data when you log in or open trade skills
- **Data Management**: Clean old data and manage your profession database

## Installation

1. Copy the `ProfessionTracker` folder to your World of Warcraft addons directory:
   ```
   World of Warcraft\_retail_\Interface\AddOns\ProfessionTracker\
   ```

2. Restart World of Warcraft or reload your UI with `/reload`

3. The addon will automatically load and begin tracking your professions

## Usage

### Slash Commands

- `/pt` or `/professiontracker` - Open the main interface
- `/pt scan` - Manually scan current character's professions
- `/pt find <item name or ID>` - Search for who can craft an item
- `/pt help` - Show available commands

### Main Interface

The addon provides a tabbed interface with four main sections:

#### 1. Search Tab
- Search for items by name or ID
- View detailed results showing which characters can craft each item
- Includes character name, realm, profession, and skill level
- Quick access to scan current character

#### 2. Characters Tab
- View all tracked characters and their professions
- See profession skill levels and recipe counts
- Delete old character data if needed

#### 3. Professions Tab
- Browse by profession type
- See all characters with each profession
- Compare skill levels across characters

#### 4. Settings Tab
- Toggle auto-scanning on login and trade skill opening
- Enable/disable tooltip integration
- View database statistics
- Clean old character data

### Automatic Features

- **Auto-Scan**: When enabled, automatically scans professions when you log in or open trade skills
- **Tooltip Integration**: Hover over items to see which of your characters can craft them
- **Cross-Realm Support**: Tracks characters across different realms
- **Persistent Data**: All data is saved between game sessions

## How It Works

1. **Data Collection**: The addon scans your character's professions and known recipes whenever you:
   - Log in (if auto-scan is enabled)
   - Open a trade skill window (if auto-scan is enabled)
   - Use the manual scan command

2. **Recipe Tracking**: For each profession, it records:
   - All known recipes
   - Items that can be crafted
   - Current skill level
   - Maximum skill level

3. **Search Functionality**: When you search for an item, the addon:
   - Searches through all stored recipe data
   - Matches against item names, recipe names, and IDs
   - Returns all characters capable of crafting the item

## Tips

- **First Time Setup**: Log in to each of your characters and open their trade skill windows to populate the database
- **Keeping Data Current**: Enable auto-scan to automatically update data as you learn new recipes
- **Finding Items**: You can search by partial item names (e.g., "flask" to find all flasks)
- **Item IDs**: Use Wowhead or similar sites to find specific item IDs for precise searches

## Troubleshooting

### No Results Found
- Make sure you've scanned the character with the profession on that character
- Try searching with partial names or different keywords
- Verify the item is actually craftable (not all items can be crafted)

### Missing Professions
- Log in to the character and open their trade skill windows
- Use `/pt scan` to manually update profession data
- Check that the character actually has professions trained

### Interface Issues
- Try `/reload` to refresh the UI
- Make sure you're running a compatible version of WoW (Retail)

## Data Storage

All data is stored in the `ProfessionTrackerDB` saved variable, which includes:
- Character information (name, realm, class, level)
- Profession data (skill levels, known recipes)
- Settings and preferences
- Last update timestamps

## Version Compatibility

This addon is designed for World of Warcraft Retail (currently targeting interface version 110002). It may need updates for future game versions.

## Support

If you encounter issues or have suggestions for improvements, please check that:
1. You're running the latest version of the addon
2. Your game client is up to date
3. You've tried basic troubleshooting steps (reload UI, rescan professions)

---

**Happy Crafting!** 🔨⚒️
