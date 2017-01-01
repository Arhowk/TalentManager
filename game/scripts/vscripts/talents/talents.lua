if not Talents then
	Talents = {
      unitData={}, 
      gameKV= LoadKeyValues('scripts/npc/npc_heroes_custom.txt'),
      maxNumTalentFiles = 20,
      currTalentFile = 1,
      application_item = CreateItem("item_talent_modifier", nil,nil)
    }

	TalentsInit = true
else
	TalentsInit = false
end
-- Actual Code
function Talents.UnitPrototype_HasTalent(self, talentName)
	return Talents.unitData[self].learnedTalents[talentName]
end

function Talents.ApplyTalent(unit, talentName, talentTable)
    _G["desiredModifierName"] = unit:GetUnitName() .. "_talent_" .. talentName
    _G["modifierTable"] = talentTable

    Talents.currTalentFile = Talents.currTalentFile + 1
    if Talents.currTalentFile > Talents.maxNumTalentFiles then
        Talents.currTalentFile = 1
    end

    CustomNetTables:SetTableValue("talent_manager", "last_learned_talent_" .. Talents.currTalentFile, {v = desiredModifierName})
    CustomNetTables:SetTableValue("talent_manager", "server_to_lua_talent_properties_" ..  desiredModifierName, modifierTable)
    LinkLuaModifier(desiredModifierName, "talents/modifier_queue/modifier_talents_" .. Talents.currTalentFile .. ".lua", LUA_MODIFIER_MOTION_NONE)

    unit:AddNewModifier(unit, Talents.application_item, desiredModifierName, {})

    if talentTable.Ability then
        unit:AddAbility(talentTable.Ability)
    end
end

--Event Listeners

function Talents.OnLearnTalent(playerId, keys)
	local unit = EntIndexToHScript(keys.unit)
	local talentRow = keys.row
	local talentName = keys.index --0 = left, 1 = right
	local talentData = Talents.gameKV[unit:GetUnitName()]
    talentData = talentData["Talents"]
    talentData = talentData["" .. talentRow]
    talentData = talentData[talentName]

    Talents.unitData[unit].kv["Talents"][""..talentRow].selected = talentName

    CustomNetTables:SetTableValue("talent_manager", "unit_talent_data_" .. unit:GetUnitName(), {levels = Talents.unitData[unit].kv["TalentLevels"], data = Talents.unitData[unit].kv["Talents"]})
    Talents.ApplyTalent(PlayerResource:GetSelectedHeroEntity(0), talentData.name, talentData)

end

function Talents.OnUnitCreate(unit)
    unit.HasTalent = Talents.UnitPrototype_HasTalent
    Talents.unitData[unit] = {}
    Talents.unitData[unit].learnedTalents = {}
    Talents.unitData[unit].kv = Talents.gameKV[unit:GetUnitName()]
    CustomNetTables:SetTableValue("talent_manager", "unit_talent_data_" .. unit:GetUnitName(), {levels = Talents.unitData[unit].kv["TalentLevels"], data = Talents.unitData[unit].kv["Talents"]})
end

function Talents.OnRequestData(keys)
	--wth does this function even do it's all nettable data
end

if TalentsInit then
	--first time
	--CDota_BaseNPC.HasTalent = Talents.UnitPrototype_HasTalent
    CustomGameEventManager:RegisterListener("talent_manager_choose_talent", Dynamic_Wrap(Talents, "OnLearnTalent"))
else
	--reload
end

--Helper functions

function Talents:GetLevelIndex(string, lvl)

end
