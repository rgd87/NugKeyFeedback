local addonName, ns = ...


local NugCastFeedback = CreateFrame("Button", nil, UIParent)
NugCastFeedback:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

-- local Masque = LibStub("Masque", true)
-- local MasqueIcon
NugCastFeedback:RegisterEvent("ADDON_LOADED")

function NugCastFeedback.ADDON_LOADED(self,event,arg1)
    if arg1 == addonName then
        
        -- NugCastFeedbackDB = NugCastFeedbackDB or {}
        -- SetupDefaults(NugCastFeedbackDB, defaults)

        local player = self:SpawnIconLine("player")
        player:SetPoint("TOPLEFT", UIParent, "CENTER", 110, 15)
        player:SetSize(30, 30)


        -- SLASH_NUGCASTFEEDBACK1= "/nugready"
        -- SlashCmdList["NUGCASTFEEDBACK"] = function(msg)
        --     if msg == "unlock" then
        --         NugCastFeedback:EnableMouse(true)
        --         NugCastFeedback:Show()
        --     elseif msg == "lock" then
        --         NugCastFeedback:EnableMouse(false)
        --     else
        --         DEFAULT_CHAT_FRAME:AddMessage([[Usage:
        --         /ncf unlock
        --         /ncf lock
        --         ]], 0.6, 1, 0.6)
        --     end
        -- end
    end
end


local function UNIT_SPELLCAST_SUCCEEDED_HANDLER(self, event, unit, lineID, spellID)
    if IsPlayerSpell(spellID) then
        if spellID == 75 then return end -- Autoshot
        local index = self.iconpool.current
        local icon = self.iconpool[index]

        local texture = select(3,GetSpellInfo(spellID))
        icon.texture:SetTexture(texture)
        icon:Show()
        icon.ag:Play()

        self.iconpool.current = (index == #self.iconpool) and 1 or index+1
    end
end

function NugCastFeedback:SpawnIconLine(unit)
    local line = self:CreateLastSpellIconLine()
    line:SetScript("OnEvent", UNIT_SPELLCAST_SUCCEEDED_HANDLER)
    line:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
    return line
end

function NugCastFeedback.CreateLastSpellIconLine(parent)

    local self = CreateFrame("Frame", UIParent)

    self.iconpool = {}
    self:SetHeight(40)
    self:SetWidth(40)

    -- local t = self:CreateTexture(nil, "ARTWORK")
    -- t:SetAllPoints(self)
    -- t:SetTexCoord(.1, .9, .1, .9)
    -- t:SetTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield") 

    for i=1,3 do
        local f = CreateFrame("Button", nil, self)

        f:SetAllPoints(self)
        -- f:SetHeight(40)-
        -- f:SetWidth(40)-
        local t = f:CreateTexture(nil, "ARTWORK")
        t:SetTexCoord(.1, .9, .1, .9)
        t:SetAllPoints(f)
        f.texture = t
        f:SetAlpha(0)

        local backdrop = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = true, tileSize = 0,
            insets = {left = -2, right = -2, top = -2, bottom = -2},
        }
        f:SetBackdrop(backdrop)
        f:SetBackdropColor(0, 0, 0, 0.7)

        -- MasqueIcon:AddButton(f, {Icon = t})

        t:SetTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield")

        local ag = f:CreateAnimationGroup()
        f.ag = ag

        local scaleOrigin = "RIGHT"
        local translateX = -100

        
        local s1 = ag:CreateAnimation("Scale")
        s1:SetScale(0.01,1)
        s1:SetDuration(0)
        s1:SetOrigin(scaleOrigin,0,0)
        s1:SetOrder(1)

        local s2 = ag:CreateAnimation("Scale")
        s2:SetScale(100,1)
        s2:SetDuration(0.5)
        s2:SetOrigin(scaleOrigin,0,0)
        s2:SetSmoothing("OUT")
        s2:SetOrder(2)

        local a1 = ag:CreateAnimation("Alpha")
        a1:SetFromAlpha(0)
        a1:SetToAlpha(1)
        a1:SetDuration(0.1)
        a1:SetOrder(2)

        local a2 = ag:CreateAnimation("Translation")
        a2:SetOffset(translateX,0)
        a2:SetDuration(1.2)
        a2:SetSmoothing("IN")
        a2:SetOrder(2)

        local a3 = ag:CreateAnimation("Alpha")
        a3:SetFromAlpha(1)
        a3:SetToAlpha(0)
        a3:SetSmoothing("OUT")
        a3:SetDuration(0.5)
        a3:SetStartDelay(0.6)
        a3:SetOrder(2)

        ag:SetScript("OnFinished", function(self)
            self:GetParent():Hide()
        end)

        table.insert(self.iconpool, f)
    end

    self.iconpool.current = 1
    
    return self
end

