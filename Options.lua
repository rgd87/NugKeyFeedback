local L = setmetatable({}, {
    __index = function(t, k)
        -- print(string.format('L["%s"] = ""',k:gsub("\n","\\n")));
        return k
    end,
    __call = function(t,k) return t[k] end,
})
-- NugKeyFeedback.L = L

function NugKeyFeedback:CreateGUI()
    local opt = {
        type = 'group',
        name = "NugKeyFeedback Settings",
        order = 1,
        args = {
            unlock = {
                name = L"Unlock",
                type = "execute",
                desc = "Unlock anchor for dragging",
                func = function() NugKeyFeedback.anchor:Show() end,
                order = 1,
            },
            lock = {
                name = L"Lock",
                type = "execute",
                desc = "Lock anchor",
                func = function() NugKeyFeedback.anchor:Hide() end,
                order = 2,
            },
            resetToDefault = {
                name = L"Restore Defaults",
                type = 'execute',
                confirm = true,
                confirmText = L"Warning: Requires UI reloading.",
                func = function()
                    NugKeyFeedbackDB = nil
                    ReloadUI()
                end,
                order = 3,
            },

            mirrorSize = {
                name = L"Button Size",
                type = "range",
                width = "full",
                get = function(info) return NugKeyFeedback.db.mirrorSize end,
                set = function(info, v)
                    NugKeyFeedback.db.mirrorSize = tonumber(v)
                    NugKeyFeedback:RefreshSettings()
                end,
                min = 10,
                max = 150,
                step = 1,
                order = 4,
            },
            enableCooldown = {
                name = L"Show Cooldown",
                type = "toggle",
                width = "full",
                order = 4.2,
                get = function(info) return NugKeyFeedback.db.enableCooldown end,
                set = function(info, v)
                    NugKeyFeedback.db.enableCooldown = not NugKeyFeedback.db.enableCooldown
                    NugKeyFeedback:RefreshSettings()
                end
            },
            enableCastLine = {
                name = L"Cast Line",
                type = "toggle",
                width = "full",
                order = 4.5,
                get = function(info) return NugKeyFeedback.db.enableCastLine end,
                set = function(info, v)
                    NugKeyFeedback.db.enableCastLine = not NugKeyFeedback.db.enableCastLine
                    NugKeyFeedback:RefreshSettings()
                end
            },
            lineIconSize = {
                name = L"Cast Line Icon Size",
                type = "range",
                disabled = function() return not NugKeyFeedback.db.enableCastLine end,
                width = "full",
                get = function(info) return NugKeyFeedback.db.lineIconSize end,
                set = function(info, v)
                    NugKeyFeedback.db.lineIconSize = tonumber(v)
                    NugKeyFeedback:RefreshSettings()
                end,
                min = 10,
                max = 150,
                step = 1,
                order = 5,
            },
            lineDirection = {
                name = L"Cast Line Direction",
                type = 'select',
                order = 8,
                values = {
                    TOP = L"UP",
                    LEFT = L"LEFT",
                    RIGHT = L"RIGHT",
                    BOTTOM = L"DOWN",
                },
                get = function(info) return NugKeyFeedback.db.lineDirection end,
                set = function(info, v)
                    NugKeyFeedback.db.lineDirection = v
                    NugKeyFeedback:RefreshSettings()
                end,
            },

        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("NugKeyFeedbackOptions", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("NugKeyFeedbackOptions", "NugKeyFeedback")

    return panelFrame
end

function NugKeyFeedback:HookOptionsFrame()
    CreateFrame('Frame', nil, InterfaceOptionsFrame):SetScript('OnShow', function(frame)
        frame:SetScript('OnShow', nil)

        if not self.optionsPanel then
            self.optionsPanel = self:CreateGUI()
        end
    end)
end