
-- general-purpose information about every type of tile in the game
tileData = {
    -- basic tiles
    ['dirt'] = {
        points = 0,
        messages = {},
        name = "Dirt",
        description = "Plain and simple.",
    },
    ['dirt+'] = {
        points = 0,
        messages = {},
        name = "Gravel",
        description = "Not quite as easy as dirt, but just as useless.",
        hp = 2,
        transform = "dirt",
    },
    ['dirt++'] = {
        points = 1,
        messages = {},
        name = "Loose stones",
        description = "They make it more difficult to dig through. Contains some value.",
        hp = 3,
        transform = "dirt+",
    },
    ['dirt+++'] = {
        points = 2,
        messages = {},
        name = "Strong stone",
        description = "Very difficult to dig through. Try to avoid doing that.",
        hp = 4,
        transform = "dirt++",
    },

    -- special level tiles
    ['entrance'] = {
        points = 0,
        messages = {},
    },
    ['exit'] = {
        points = 0,
        messages = {},
    },
    ['exit_wall'] = {
        points = 0,
        messages = {},
        name = "A hole",
        description = "If you're going deeper underground, this is where it's happening.",
        transform = "exit",
    },

    -- valuables
    ['skeleton'] = {
        points = 10,
        messages = {"Wow, a skeleton! Wonder how long he's been down here..."},
        name = "Skeleton",
        description = "The remains of a human. Some scientists might be interested.",
        hp = 2,
    },
    ['fossil'] = {
        points = 15,
        messages = {"Alright, prehistoric snails!"},
        name = "Fossil",
        description = "An ancient organism, encrusted in stone.",
    },
    ['tablet'] = {
        points = 30,
        messages = {"You see a finely crafted stone tablet. On it are two dwarves. The dwarves are digging."},
        name = "Stone Tablet",
        description = "Fine craftsmanship. Considering the low-tech tools available at the time.",
    },
    ['emerald'] = {
        points = 50,
        messages = {"Shiny!"},
        name = "Gem",
        description = "Precious and fragile, needs special handling when dog out.",
        hp = 5,
    },

    -- powerups
    ['ducktape'] = {
        points = 1,
        messages = {"Buried duck tape, seriously?!"},
        name = "Duck Tape",
        description = "Referred to as \"Duct Tape\" by our ancient forefathers. Rumored to have mystical repairing properties. Can be used multiple times.",
    },
    ['helmet'] = {
        points = 5,
        messages = {"This should help me see better."},
        name = "Mining Helmet",
        description = "Even the batteries are still intact. Very useful!",
    },
    ['ring'] = {
        points = 20,
        messages = {"You do not simply dig a ring out of a mountain!"},
        name = "One Ring",
        description = "Because nobody really needs two rings. Increases your power. Can be used multiple times.",
    },
    ['amulet'] = {
        points = 60,
        messages = {"It fits snugly around my neck. Bring on the bling!"},
        name = "Golden Amulet",
        description = "Magical or not, this is bound to be valuable! Helps you treat your pick better.",
    },
    ['chain'] = {
        points = 10,
        messages = {"I got nothing...", "It's too long for my neck? Still shiny, still taking it!"},
        name = "Silver Chain",
        description = "A bit too big to carry comfortably. Helps you treat your pick better.",
    },
    ['cape'] = {
        points = 20,
        messages = {"A fine garment!"},
        name = "Blue Cape",
        description = "Look like a superhero! Increases your power.",
    },
    ['drill'] = {
        points = 10,
        messages = {"Vrooooom!", "Hey dirt, here comes your spiral doom!"},
        name = "Battery-Powered Drill",
        description = "Superpowers! For a short while at least, and you don't have to use your pick.",
    },

    -- game enders / goal type stuff
    ["tikimask"] = {
        points = 0,
        messages = {},
        name = "Mask of Zuul",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
        hp = 15,
    },
    ["goldidol"] = {
        points = 0,
        messages = {},
        name = "Idol of Garana",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
        hp = 15,
    },
    ["goldscepter"] = {
        points = 0,
        messages = {},
        name = "Scepter of Dha'Li",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
        hp = 15,
    },
    ["holygrail"] = {
        points = 0,
        messages = {},
        name = "Holy Grail",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
        hp = 15,
    },
    ["fountain"] = {
        points = 0,
        messages = {},
        name = "Fountain of Youth",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
        hp = 15,
    },
}
