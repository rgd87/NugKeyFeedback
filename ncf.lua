local addonName, ns = ...


local NugCastFeedback = CreateFrame("Frame", "NugCastFeedback", UIParent)
NugCastFeedback:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

local NCFDB

local ICON_POOL_SIZE = 3

local Masque = LibStub("Masque", true)
local MasqueGroup
NugCastFeedback:RegisterEvent("ADDON_LOADED")

local defaults = {
    point = "CENTER",
    x = 0, y = 0,
    
}

local function SetupDefaults(t, defaults)
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            else
                SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
        end
    end
end
local function RemoveDefaults(t, defaults)
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end

function NugCastFeedback.ADDON_LOADED(self,event,arg1)
    if arg1 == addonName then
        
        _G.NugCastFeedbackDB = _G.NugCastFeedbackDB or {}
        NCFDB = _G.NugCastFeedbackDB
        SetupDefaults(NCFDB, defaults)

        if Masque then
            MasqueGroup = Masque:Group(addonName, "FeedbackButtons")
        end
        self.mirror = self:CreateMirrorButton()
        self:SpawnIconLine("player")
        self:SetSize(30, 30)

        self.anchor = self:CreateAnchor()
        self:SetPoint("BOTTOMLEFT", self.anchor, "TOPRIGHT", 0, 0)
        
        SLASH_NUGCASTFEEDBACK1= "/nugcastfeedback"
        SLASH_NUGCASTFEEDBACK2= "/ncf"
        SlashCmdList["NUGCASTFEEDBACK"] = self.SlashCmd
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

    local ActionButtonDown = function(action)
        local tex = GetActionTexture(action)
        if not tex then return end
        mirror.icon:SetTexture(tex)
        mirror:Show()
        mirror:SetAlpha(1)
        mirror._elapsed = 0
        if mirror:GetButtonState() == "NORMAL" then
			mirror:SetButtonState("PUSHED");
		end
    end

    local ActionButtonUp = function(action)
        if mirror:GetButtonState() == "PUSHED" then
			mirror:SetButtonState("NORMAL");
		end
    end

    local GetActionButtonForID = _G.GetActionButtonForID
    hooksecurefunc("ActionButtonDown", function(id)
        local button = GetActionButtonForID(id)
        return ActionButtonDown(button.action)
    end)
    hooksecurefunc("ActionButtonUp", ActionButtonUp)
    hooksecurefunc("MultiActionButtonDown", function(bar,id)
        local button = _G[bar.."Button"..id];
        return ActionButtonDown(button.action)
    end)
    hooksecurefunc("MultiActionButtonUp", ActionButtonUp)

    mirror:SetPoint("CENTER", self, "CENTER")

    mirror:Hide()

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

    for i=1,ICON_POOL_SIZE do
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
        local translateY = 0

        
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

        local t1 = ag:CreateAnimation("Translation")
        t1:SetOffset(translateX,translateY)
        t1:SetDuration(1.2)
        t1:SetSmoothing("IN")
        t1:SetOrder(2)

        local a2 = ag:CreateAnimation("Alpha")
        a2:SetFromAlpha(1)
        a2:SetToAlpha(0)
        a2:SetSmoothing("OUT")
        a2:SetDuration(0.5)
        a2:SetStartDelay(0.6)
        a2:SetOrder(2)

        ag.s1 = s1
        ag.s2 = s2
        ag.t1 = t1

        ag:SetScript("OnFinished", function(self)
            self:GetParent():Hide()
        end)

        table.insert(self.iconpool, f)
    end
    self:UpdateSettings()

    self.iconpool.current = 1
    
    return self
end

function NugCastFeedback:UpdateSettings()
    local scaleOrigin, revOrigin, translateX, translateY
    if NCFDB.direction == "RIGHT" then
        scaleOrigin = "LEFT"
        revOrigin = "RIGHT"
        translateX = 100
        translateY = 0
    elseif NCFDB.direction == "TOP" then
        scaleOrigin = "BOTTOM"
        revOrigin = "TOP"
        translateX = 0
        translateY = 100
    elseif NCFDB.direction == "BOTTOM" then
        scaleOrigin = "TOP"
        revOrigin = "BOTTOM"
        translateX = 0
        translateY = -100
    else
        scaleOrigin = "RIGHT"
        revOrigin = "LEFT"
        translateX = -100
        translateY = 0
    end
    for i, frame in ipairs(self.iconpool) do
        local ag = frame.ag
        ag.s1:SetOrigin(scaleOrigin, 0,0)
        ag.s2:SetOrigin(scaleOrigin, 0,0)
        ag.t1:SetOffset(translateX, translateY)
        frame:ClearAllPoints()
        frame:SetPoint(scaleOrigin, self.mirror, revOrigin, 0,0)
    end
end


function NugCastFeedback:CreateAnchor()
    local f = CreateFrame("Frame","NugThreatAnchor",UIParent)
    f:SetHeight(20)
    f:SetWidth(20)
    f:SetPoint("CENTER","UIParent","CENTER",NCFDB.x, NCFDB.y)

    f:RegisterForDrag("LeftButton")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:Hide()

    local t = f:CreateTexture(f:GetName().."Icon1","BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0,0.25,0,1)
    t:SetAllPoints(f)

    t = f:CreateTexture(f:GetName().."Icon","BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0.25,0.49,0,1)
    t:SetVertexColor(1, 0, 0)
    t:SetAllPoints(f)

    f:SetScript("OnDragStart",function(self) self:StartMoving() end)
    f:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        _,_, NCFDB.point, NCFDB.x, NCFDB.y = self:GetPoint(1)
    end)
    return f
end


local helpMessage = {
    "|cff00ff00/ncf lock|r",
    "|cff00ff00/ncf unlock|r",
    "|cff00ff00/ncf direction|r <TOP|LEFT||RIGHT|BOTTOM>",
}


NugCastFeedback.Commands = {
    ["unlock"] = function(v)
        NugCastFeedback.anchor:Show()
    end,
    ["lock"] = function(v)
        NugCastFeedback.anchor:Hide()
    end,
    ["direction"] = function(v)
        NCFDB.direction = string.upper(v)
        NugCastFeedback:UpdateSettings()
    end,
}

function NugCastFeedback.SlashCmd(msg)
    local k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then
        print("Usage:")
        for k,v in ipairs(helpMessage) do
            print(" - ",v)
        end
    end
    if NugCastFeedback.Commands[k] then
        NugCastFeedback.Commands[k](v)
    end
end