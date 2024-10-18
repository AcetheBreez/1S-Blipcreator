Config = {}

-- Choose the framework being used: 'esx', 'qbcore', or 'qbox'
Config.Framework = 'qbcore' 

-- Blip Options
Config.BlipOptions = {
    sprite = {
        min = 1,  -- Minimum value for blip sprite
        max = 999 -- Maximum value for blip sprite
    },
    color = {
        min = 0,  -- Minimum value for blip color
        max = 83  -- Maximum value for blip color 
    }
}