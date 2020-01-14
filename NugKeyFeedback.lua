local addonName, ns = ...

local NugKeyFeedback = CreateFrame("Frame", "NugKeyFeedback", UIParent)
NugKeyFeedback:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

local NKFDB

local Masque = LibStub("Masque", true)
local MasqueGroup
NugKeyFeedback:RegisterEvent("PLAYER_LOGIN")
NugKeyFeedback:RegisterEvent("PLAYER_LOGOUT")

local defaults = {
    point = "CENTER",
    x = 0, y = 0,
    direction = "LEFT",
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

function NugKeyFeedback:PLAYER_LOGIN(event)

    _G.NugKeyFeedbackDB = _G.NugKeyFeedbackDB or {}
    NKFDB = _G.NugKeyFeedbackDB
    SetupDefaults(NKFDB, defaults)

    if Masque then
        MasqueGroup = Masque:Group(addonName, "FeedbackButtons")
    end
    self.mirror = self:CreateMirrorButton()

    -- self.flash = self:CreateFlashTexture(self.mirror)

    self.iconPool = self:CreateLastSpellIconLine(self.mirror)
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")

    -- self:SpawnIconLine("player")
    self:SetSize(30, 30)

    self.anchor = self:CreateAnchor()
    self:SetPoint("BOTTOMLEFT", self.anchor, "TOPRIGHT", 0, 0)

    SLASH_NUGKEYFEEDBACK1= "/nugkeyfeedback"
    SLASH_NUGKEYFEEDBACK2= "/nkf"
    SlashCmdList["NUGKEYFEEDBACK"] = self.SlashCmd
end
function NugKeyFeedback:PLAYER_LOGOUT(event)
    RemoveDefaults(NKFDB, defaults)
end


function NugKeyFeedback:UNIT_SPELLCAST_SUCCEEDED(event, unit, lineID, spellID)
    if IsPlayerSpell(spellID) then
        if spellID == 75 then return end -- Autoshot
        local frame, isNew = self.iconPool:Acquire()

        local texture = select(3,GetSpellInfo(spellID))
        frame.icon:SetTexture(texture)
        frame:Show()
        frame.ag:Play()
        -- self.flash.ag:Play()
    end
end

-- function NugKeyFeedback:SpawnIconLine(unit)
--     self:CreateLastSpellIconLine()
--     self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
--     return self
-- end

function NugKeyFeedback:CreateMirrorButton()
    local mirror = CreateFrame("Button", "NugKeyFeedbackMirror", self, "ActionButtonTemplate")
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

    mirror:EnableMouse(false)

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

local PoolIconCreationFunc = function(pool)
    local hdr = pool.parent
    local id = pool.idCounter
    pool.idCounter = pool.idCounter + 1
    local f
    -- if ns.MasqueGroup then
        f = CreateFrame("Button", "NugKeyFeedbackPoolIcon"..id, hdr, "ActionButtonTemplate")
    -- else
        -- f = CreateFrame("Frame", nil, hdr)
    -- end

    f:EnableMouse(false)
    f:SetHeight(40)
    f:SetWidth(40)
    f:SetPoint("BOTTOM", hdr, "BOTTOM",0, -0)

    local t = f.icon
    f:SetAlpha(0)

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
        local icon = self:GetParent()
        icon:Hide()
        pool:Release(icon)
    end)

    return f
end

local function PoolIconResetterFunc(pool, f)
    local db = NKFDB

    f:SetHeight(40)
    f:SetWidth(40)

    f.ag:Stop()

    local scaleOrigin, revOrigin, translateX, translateY
    -- local sx1, sx2, sy1, sy2
    if db.direction == "RIGHT" then
        scaleOrigin = "LEFT"
        revOrigin = "RIGHT"
        -- sx1, sx2, sy1, sy2 = 0.01, 100, 1, 1
        translateX = 100
        translateY = 0
    elseif db.direction == "TOP" then
        scaleOrigin = "BOTTOM"
        revOrigin = "TOP"
        -- sx1, sx2, sy1, sy2 = 1,1, 0.01, 100
        translateX = 0
        translateY = 100
    elseif db.direction == "BOTTOM" then
        scaleOrigin = "TOP"
        revOrigin = "BOTTOM"
        -- sx1, sx2, sy1, sy2 = 1,1, 0.01, 100
        translateX = 0
        translateY = -100
    else
        scaleOrigin = "RIGHT"
        revOrigin = "LEFT"
        -- sx1, sx2, sy1, sy2 = 0.01, 100, 1, 1
        translateX = -100
        translateY = 0
    end
    local ag = f.ag
    -- ag.s1:SetScale(sx1, sy1)
    ag.s1:SetOrigin(scaleOrigin, 0,0)

    -- ag.s1:SetScale(sx2, sy2)
    ag.s2:SetOrigin(scaleOrigin, 0,0)
    ag.t1:SetOffset(translateX, translateY)

    f:ClearAllPoints()
    local parent = pool.parent
    f:SetPoint(scaleOrigin, parent, revOrigin, 0,0)
end

function NugKeyFeedback:CreateLastSpellIconLine(parent)
    local template = nil
    local resetterFunc = PoolIconResetterFunc
    local iconPool = CreateFramePool("Frame", parent, template, resetterFunc)
    iconPool.creationFunc = PoolIconCreationFunc
    iconPool.idCounter = 1

    return iconPool
end

--[[
function NugKeyFeedback:CreateFlashTexture(parent)
    local flash = parent:CreateTexture(nil, "ARTWORK")
    flash:SetAtlas("collections-newglow")
    flash:SetVertexColor(1,1,0)
    -- flash:SetRotation(math.rad(90))
    flash:SetSize(85, 25)
    flash:SetPoint("CENTER", self.mirror, NKFDB.direction,0,0)
    flash:SetAlpha(0)

    local ag = flash:CreateAnimationGroup()

    local a1 = ag:CreateAnimation("Alpha")
    a1:SetFromAlpha(0)
    a1:SetToAlpha(1)
    a1:SetDuration(0.1)
    a1:SetOrder(1)

    local a2 = ag:CreateAnimation("Alpha")
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetSmoothing("OUT")
    a2:SetDuration(0.5)
    a2:SetStartDelay(0.6)
    a2:SetOrder(2)

    flash.ag = ag

    return flash
end
]]

function NugKeyFeedback:CreateAnchor()
    local f = CreateFrame("Frame","NugThreatAnchor",UIParent)
    f:SetHeight(20)
    f:SetWidth(20)
    f:SetPoint("CENTER","UIParent","CENTER",NKFDB.x, NKFDB.y)

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
        NKFDB.point, NKFDB.x, NKFDB.y = select(3, self:GetPoint(1)) -- skip first 2 values
    end)
    return f
end


local helpMessage = {
    "|cff00ff00/nkf lock|r",
    "|cff00ff00/nkf unlock|r",
    "|cff00ff00/nkf direction|r <TOP|LEFT||RIGHT|BOTTOM>",
}


NugKeyFeedback.Commands = {
    ["unlock"] = function(v)
        NugKeyFeedback.anchor:Show()
    end,
    ["lock"] = function(v)
        NugKeyFeedback.anchor:Hide()
    end,
    ["direction"] = function(v)
        NKFDB.direction = string.upper(v)
        local pool = NugKeyFeedback.iconPool
        pool:ReleaseAll()
        for i,f in pool:EnumerateInactive() do
            PoolIconResetterFunc(pool, f)
        end
    end,
}

function NugKeyFeedback.SlashCmd(msg)
    local k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then
        print("Usage:")
        for k,v in ipairs(helpMessage) do
            print(" - ",v)
        end
    end
    if NugKeyFeedback.Commands[k] then
        NugKeyFeedback.Commands[k](v)
    end
end