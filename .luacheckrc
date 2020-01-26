std = "lua51"
max_line_length = false
exclude_files = {
    "**/Libs",
}
only = {
    "011", -- syntax
    "1", -- globals
    "3", -- Value unused
    "41", -- Redefining
}
ignore = {
    "11/SLASH_.*", -- slash handlers
    "1/[A-Z][A-Z][A-Z0-9_]+", -- three letter+ constants
    "211", -- Unused variable
    "212", -- Unused argument.
    "213", -- Unused loop variable
    "42", -- Shadowing
    "43", -- Shadowing an upvalue.
}
globals = {
    -- wow std api
    "abs",
    "acos",
    "asin",
    "atan",
    "atan2",
    "bit",
    "ceil",
    "cos",
    "date",
    "debuglocals",
    "debugprofilestart",
    "debugprofilestop",
    "debugstack",
    "deg",
    "difftime",
    "exp",
    "fastrandom",
    "floor",
    "forceinsecure",
    "foreach",
    "foreachi",
    "format",
    "frexp",
    "geterrorhandler",
    "getn",
    "gmatch",
    "gsub",
    "hooksecurefunc",
    "issecure",
    "issecurevariable",
    "ldexp",
    "log",
    "log10",
    "max",
    "min",
    "mod",
    "rad",
    "random",
    "scrub",
    "securecall",
    "seterrorhandler",
    "sin",
    "sort",
    "sqrt",
    "strbyte",
    "strchar",
    "strcmputf8i",
    "strconcat",
    "strfind",
    "string.join",
    "strjoin",
    "strlen",
    "strlenutf8",
    "strlower",
    "strmatch",
    "strrep",
    "strrev",
    "strsplit",
    "strsub",
    "strtrim",
    "strupper",
    "table.wipe",
    "tan",
    "time",
    "tinsert",
    "tremove",
    "wipe",


    "NugKeyFeedback",
    "NugKeyFeedbackDB",
    -- everything else
    "CreateFrame",
    "C_PetBattles",
    "UIParent",
    "LibStub",
    "CopyTable",
    "SlashCmdList",
    "IsPlayerSpell",
    "GetSpellInfo",
    "GetActionTexture",
    "CreateFramePool",
    "UIParent",
    "GetActionCooldown",
    "GetActionCharges",
    "CooldownFrame_Set",
    "HasAction",
    "InterfaceOptionsFrame_OpenToCategory",
    "ReloadUI",
    "InterfaceOptionsFrame",
    "IsAddOnLoaded",
}
