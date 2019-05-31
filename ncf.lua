local addonName, ns = ...


local NugCastFeedback = CreateFrame("Frame", nil, UIParent)
NugCastFeedback:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

local Masque = LibStub("Masque", true)
local MasqueGroup
NugCastFeedback:RegisterEvent("ADDON_LOADED")

function NugCastFeedback.ADDON_LOADED(self,event,arg1)
    if arg1 == addonName then
        
        -- NugCastFeedbackDB = NugCastFeedbackDB or {}
        -- SetupDefaults(NugCastFeedbackDB, defaults)

        if Masque then
            MasqueGroup = Masque:Group(addonName, "FeedbackButtons")
        end
        self.mirror = self:CreateMirrorButton()
        local player = self:SpawnIconLine("player")
        player:SetPoint("TOPLEFT", UIParent, "CENTER", 90, 75)
        player:SetSize(30, 30)
    end
end


function NugCastFeedback:UNIT_SPELLCAST_SUCCEEDED(event, unit, lineID, spellID)
    if IsPlayerSpell(spellID) then
        if spellID == 75 then return end -- Autoshot
        local index = self.iconpool.current
        local frame = self.iconpool[index]

        local texture = select(3,GetSpellInfo(spellID))
        frame.icon:SetTexture(texture)
        frame:Show()
        frame.ag:Play()

        self.iconpool.current = (index == #self.iconpool) and 1 or index+1
    end
end

function NugCastFeedback:SpawnIconLine(unit)
    self:CreateLastSpellIconLine()
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
    return self
end

function NugCastFeedback:CreateMirrorButton()
    local mirror = CreateFrame("Button", "NugCastFeedbackMirror", self, "ActionButtonTemplate")
    mirror:SetHeight(48)
    mirror:SetWidth(48)

    if MasqueGroup then
        MasqueGroup:AddButton(mirror)
    end
    mirror:Show()
    -- mirror:SetScale(1.3)
    mirror._elapsed = 0

    mirror:SetScript("OnUpdate", function(self, elapsed)
        self._elapsed = self._elapsed + elapsed

        local timePassed = self._elapsed
        if timePassed >= 1.5 then
            local alpha = 2 - timePassed
            self:SetAlpha(alpha)
            if alpha == 0 then self:Hide() end
        end
    end)

    local ActionButtonDown = function(actionSlot)
        local tex = GetActionTexture(actionSlot)
        mirror.icon:SetTexture(tex)
        mirror:Show()
        mirror:SetAlpha(1)
        mirror._elapsed = 0
        if mirror:GetButtonState() == "NORMAL" then
			mirror:SetButtonState("PUSHED");
		end
    end

    local ActionButtonUp = function(actionSlot)
        if mirror:GetButtonState() == "PUSHED" then
			mirror:SetButtonState("NORMAL");
		end
    end

    hooksecurefunc("ActionButtonDown", ActionButtonDown)
    hooksecurefunc("ActionButtonUp", ActionButtonUp)
    hooksecurefunc("MultiActionButtonDown", function(bar,id)
        local button = _G[bar.."Button"..id];
        return ActionButtonDown(button.action)
    end)
    hooksecurefunc("MultiActionButtonUp", ActionButtonUp)

    mirror:SetPoint("CENTER", self, "CENTER")

    return mirror
end

function NugCastFeedback:CreateLastSpellIconLine()
    -- local parent = self

    -- parent:SetHeight(40)
    -- parent:SetWidth(40)

    -- local self = CreateFrame("Frame", nil, parent)

    self.iconpool = {}
    self:SetHeight(40)
    self:SetWidth(40)

    -- local t = self:CreateTexture(nil, "ARTWORK")
    -- t:SetAllPoints(self)
    -- t:SetTexCoord(.1, .9, .1, .9)
    -- t:SetTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield") 

    for i=1,3 do
        local f = CreateFrame("Button", "NugCastFeedbackFrame"..i, self, "ActionButtonTemplate")

        f:SetHeight(40)
        f:SetWidth(40)
        f:SetPoint("RIGHT", self.mirror, "LEFT",0,0)
        -- f:SetAllPoints(self)
        -- local t = f:CreateTexture(nil, "ARTWORK")
        -- t:SetTexCoord(.1, .9, .1, .9)
        -- t:SetAllPoints(f)
        -- f.icon = t
        local t = f.icon
        f:SetAlpha(0)

        -- local backdrop = {
        --     bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        --     tile = true, tileSize = 0,
        --     insets = {left = -2, right = -2, top = -2, bottom = -2},
        -- }
        -- f:SetBackdrop(backdrop)
        -- f:SetBackdropColor(0, 0, 0, 0.7)

        -- MasqueGroup:AddButton(f, {Icon = t})
        if MasqueGroup then
            MasqueGroup:AddButton(f)
        end

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

