local addonName, ns = ...

local NugKeyFeedback = CreateFrame("Frame", "NugKeyFeedback", UIParent)
NugKeyFeedback:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

NugKeyFeedback:RegisterEvent("PLAYER_LOGIN")
NugKeyFeedback:RegisterEvent("PLAYER_LOGOUT")

local defaults = {
    point = "CENTER",
    x = 0, y = 0,
    enableCastLine = true,
    enableCooldown = true,
    lineIconSize = 38,
    mirrorSize = 50,
    lineDirection = "LEFT",
}

local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local dummy = function() end
local IsInPetBattle = isClassic and dummy or C_PetBattles.IsInBattle

local firstTimeUse = false

function NugKeyFeedback:PLAYER_LOGIN(event)

    if not _G.NugKeyFeedbackDB then
        _G.NugKeyFeedbackDB = {}
        firstTimeUse = true
    end
    -- Create a DB using defaults and using a shared default profile
    -- self.db = LibStub("AceDB-3.0"):New("NugKeyFeedbackDB", defaults, true)
    self.db = _G.NugKeyFeedbackDB
    ns.SetupDefaults(self.db, defaults)

    self.mirror = self:CreateFeedbackButton()

    self.mirror.UpdateAction = function(self, fullUpdate)
        local action = self.action
        if not action then return end

        local tex = GetActionTexture(action)
        if not tex then return end
        self.icon:SetTexture(tex)

        if fullUpdate and NugKeyFeedback.db.enableCooldown then
            local start, duration, enable, modRate = GetActionCooldown(action);
            local charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetActionCharges(action);
            CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate);
        end
    end
    self:HookDefaultBindings(self.mirror)

    -- self.flash = self:CreateFlashTexture(self.mirror)

    self:SetSize(30, 30)

    self.anchor = self:CreateAnchor()
    self:SetPoint("BOTTOMLEFT", self.anchor, "TOPRIGHT", 0, 0)
    if firstTimeUse then self.anchor:Show() end

    self:RefreshSettings()

    self:HookOptionsFrame()

    SLASH_NUGKEYFEEDBACK1= "/nugkeyfeedback"
    SLASH_NUGKEYFEEDBACK2= "/nkf"
    SlashCmdList["NUGKEYFEEDBACK"] = self.SlashCmd
end
function NugKeyFeedback:PLAYER_LOGOUT(event)
    ns.RemoveDefaults(self.db, defaults)
end


function NugKeyFeedback:SPELL_UPDATE_COOLDOWN(event)
    self.mirror:UpdateAction(true)
end

function NugKeyFeedback:HookDefaultBindings(mirror)
    local ActionButtonDown = function(action)
        if not HasAction(action) then return end
        if IsInPetBattle() then return end

        if mirror.action ~= action then
            mirror.action = action
            mirror:UpdateAction(true)
        else
            mirror:UpdateAction()
        end

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

function NugKeyFeedback:RefreshSettings()
    local db = self.db
    self.mirror:SetSize(db.mirrorSize, db.mirrorSize)
    if self.mirror.masqueGroup then
        self.mirror.masqueGroup:ReSkin()
    end

    if db.enableCastLine then
        self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
        if not self.iconPool then
            self.iconPool = self:CreateLastSpellIconLine(self.mirror)
        end

        local pool = self.iconPool
        pool:ReleaseAll()
        for i,f in pool:EnumerateInactive() do
            -- f:SetHeight(db.lineIconSize)
            -- f:SetWidth(db.lineIconSize)
            pool:resetterFunc(f)
        end
        if pool.masqueGroup then
            pool.masqueGroup:ReSkin()
        end
    else
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end

    if db.enableCooldown then
        self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self.mirror.cooldown:Show()
    else
        self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
        self.mirror.cooldown:Hide()
    end
end


function NugKeyFeedback.SlashCmd(msg)
    if not NugKeyFeedback.optionsPanel then
        NugKeyFeedback.optionsPanel = NugKeyFeedback:CreateGUI()
    end
    InterfaceOptionsFrame_OpenToCategory("NugKeyFeedback")
    InterfaceOptionsFrame_OpenToCategory("NugKeyFeedback")
end


function ns.SetupDefaults(t, defaults)
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            else
                ns.SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
        end
    end
end
function ns.RemoveDefaults(t, defaults)
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            ns.RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end
