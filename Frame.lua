local addonName, ns = ...

local Masque = LibStub("Masque", true)

function NugKeyFeedback:CreateFeedbackButton()
    local db = self.db

    local mirror = CreateFrame("Button", "NugKeyFeedbackMirror", self, "ActionButtonTemplate")
    mirror:SetHeight(db.mirrorSize)
    mirror:SetWidth(db.mirrorSize)

    mirror.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge");
    mirror.cooldown:SetSwipeColor(0, 0, 0);
    mirror.cooldown:SetHideCountdownNumbers(false);

    if Masque then
        local mg = Masque:Group(addonName, "Feedback Button")
        mg:AddButton(mirror)
        mirror.masqueGroup = mg
    end
    mirror:Show()
    mirror._elapsed = 0

    mirror:SetScript("OnUpdate", function(self, elapsed)
        self._elapsed = self._elapsed + elapsed

        local timePassed = self._elapsed
        if timePassed >= 1.5 then
            local alpha = 2 - timePassed
            if alpha <= 0 then
                alpha = 0
                self:Hide()
            end
            self:SetAlpha(alpha)
        end
    end)

    mirror:EnableMouse(false)

    mirror:SetPoint("CENTER", self, "CENTER")

    mirror:Hide()

    return mirror
end

local PoolIconCreationFunc = function(pool)
    local db = NugKeyFeedback.db

    local hdr = pool.parent
    local id = pool.idCounter
    pool.idCounter = pool.idCounter + 1
    local f = CreateFrame("Button", "NugKeyFeedbackPoolIcon"..id, hdr, "ActionButtonTemplate")

    if pool.masqueGroup then
        pool.masqueGroup:AddButton(f)
    end

    f:EnableMouse(false)
    f:SetHeight(db.lineIconSize)
    f:SetWidth(db.lineIconSize)
    f:SetPoint("BOTTOM", hdr, "BOTTOM",0, -0)

    local t = f.icon
    f:SetAlpha(0)

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
    local db = NugKeyFeedback.db

    f:SetHeight(db.lineIconSize)
    f:SetWidth(db.lineIconSize)

    f.ag:Stop()

    local scaleOrigin, revOrigin, translateX, translateY
    -- local sx1, sx2, sy1, sy2
    if db.lineDirection == "RIGHT" then
        scaleOrigin = "LEFT"
        revOrigin = "RIGHT"
        -- sx1, sx2, sy1, sy2 = 0.01, 100, 1, 1
        translateX = 100
        translateY = 0
    elseif db.lineDirection == "TOP" then
        scaleOrigin = "BOTTOM"
        revOrigin = "TOP"
        -- sx1, sx2, sy1, sy2 = 1,1, 0.01, 100
        translateX = 0
        translateY = 100
    elseif db.lineDirection == "BOTTOM" then
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
    iconPool.resetterFunc  = PoolIconResetterFunc
    iconPool.idCounter = 1

    if Masque then
        iconPool.masqueGroup = Masque:Group(addonName, "Spell Line Icons")
    end

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
    f:SetPoint(NugKeyFeedback.db.point,"UIParent",NugKeyFeedback.db.point, NugKeyFeedback.db.x, NugKeyFeedback.db.y)

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
        local db = NugKeyFeedback.db
        db.point, db.x, db.y = select(3, self:GetPoint(1)) -- skip first 2 values
    end)
    return f
end
