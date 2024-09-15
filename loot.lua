local lootEvent = {}

function lootEvent.onKill(player, target)
    local corpse = target:getCorpse()
    if not corpse then
        return true
    end

    -- Sprawdzanie, czy stawka lootu jest włączona
    if configManager.getNumber(configKeys.RATE_LOOT) == 0 then
        return true
    end

    local mType = target:getType()

    -- Sprawdzanie, czy gracz ma powyżej 14 godzin staminy (840 minut)
    if player:getStamina() > 840 then
        local monsterLoot = mType:getLoot()
        for i = 1, #monsterLoot do
            local item = corpse:createLootItem(monsterLoot[i])
            if not item then
                print('[Warning] DropLoot:', 'Could not add loot item to corpse.')
            end
        end

        -- Tworzenie opisu lootu
        local text = ("Loot of %s: %s"):format(mType:getNameDescription(), corpse:getContentDescription())
        local party = player:getParty()

        -- Jeśli gracz jest w party, rozsyła loot do członków party
        if party then
            party:broadcastPartyLoot(text)
            for _, member in ipairs(party:getMembers()) do
                member:sendChannelMessage("", text, TALKTYPE_CHANNEL_Y, 21) -- Poprawione do TALKTYPE_CHANNEL_Y
            end
        else
            -- Jeśli gracz nie jest w party, wysyła loot tylko do siebie
            player:sendTextMessage(MESSAGE_INFO_DESCR, text)
            player:sendChannelMessage("", text, TALKTYPE_CHANNEL_Y, 21) -- TALKTYPE_CHANNEL_Y dla kanału loot
        end
    end

    return true
end

-- Funkcja główna onKill
function onKill(player, target)
    return lootEvent.onKill(player, target)
end
