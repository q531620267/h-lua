hRuntime = {
    -- 注册runtime的数据
    register = {
        unit = function(json)
            hslk.id2Value.unit[json._id] = json
            hslk.name2Value.unit[json._name] = json
        end,
        item = function(json)
            hslk.id2Value.item[json._id] = json
            hslk.name2Value.item[json._name] = json
            if (json.cooldownID ~= nil) then
                hslk.item_cooldown_ids[json.cooldownID] = json.ITEM_ID
            end
            if (json.RING ~= nil) then
                json.RING.RING_ID = json.ITEM_ID
                json.RING.Name = json.Name
                hslk.id2Value.ring[json.ITEM_ID] = json.RING
                hslk.name2Value.ring[json.Name] = json.RING
            end
        end,
        ability = function(json)
            hslk.id2Value.ability[json._id] = json
            hslk.name2Value.ability[json._name] = json
            if (json.RING ~= nil) then
                json.RING.RING_ID = json.ABILITY_ID
                json.RING.Name = json.Name
                hslk.id2Value.ring[json._id] = json.RING
                hslk.name2Value.ring[json._name] = json.RING
            end
        end,
        technology = function(json)
            hslk.id2Value.technology[json._id] = json
            hslk.name2Value.technology[json._name] = json
        end,
        synthesis = function(json)
            -- 数据格式化
            -- 碎片名称转ID
            local jsonFragment = {}
            for k, v in ipairs(json.fragment) do
                json.fragment[k][2] = math.floor(v[2])
                local fragmentId = hslk.name2Value.item[v[1]]._id or nil
                if (fragmentId ~= nil) then
                    table.insert(jsonFragment, { fragmentId, v[2] })
                end
            end
            local profitId = hslk.name2Value.item[json.profit[1]]._id or nil
            if (profitId == nil) then
                return
            end
            if (hslk.synthesis.profit[profitId] == nil) then
                hslk.synthesis.profit[profitId] = {}
            end
            table.insert(hslk.synthesis.profit[profitId], {
                qty = json.profit[2],
                fragment = jsonFragment,
            })
            local profitIndex = #hslk.synthesis.profit[profitId]
            for _, f in ipairs(jsonFragment) do
                if (hslk.synthesis.fragment[f[1]] == nil) then
                    hslk.synthesis.fragment[f[1]] = {}
                end
                if (hslk.synthesis.fragment[f[1]][f[2]] == nil) then
                    hslk.synthesis.fragment[f[1]][f[2]] = {}
                end
                table.insert(hslk.synthesis.fragment[f[1]][f[2]], {
                    profit = profitId,
                    index = profitIndex,
                })
            end
        end,
    },
    env = {},
    event = {
        -- 核心注册
        register = {},
        -- 池
        pool = {},
    },
    textTag = {},
    rect = {},
    player = {},
    unit = {},
    group = {}, -- 单位选择器
    hero = {},
    unit_type_ids = { --单位类型ID集
        hero = {},
        courier_hero = {},
    },
    heroBuildSelection = {},
    skill = {
        silentUnits = {},
        silentTrigger = nil,
        unarmUnits = {},
        unarmTrigger = nil,
    },
    attributeGroup = {
        life_back = {},
        mana_back = {},
        punish = {}
    },
    item = {},
    itemPickPool = {},
    leaderBoard = {},
    multiBoard = {},
    dialog = {}
}

hRuntime.clear = function(handle)
    if (handle == nil) then
        return
    end
    if (hRuntime.env[handle] ~= nil) then
        hRuntime.env[handle] = nil
    end
    if (hRuntime.event[handle] ~= nil) then
        hRuntime.event[handle] = nil
    end
    if (hRuntime.event.register[handle] ~= nil) then
        hRuntime.event.register[handle] = nil
    end
    if (hRuntime.event.pool[handle] ~= nil) then
        for _, p in ipairs(hRuntime.event.pool[handle]) do
            local key = p.key
            local poolIndex = p.poolIndex
            hevent.POOL[key][poolIndex].stock = hevent.POOL[key][poolIndex].stock - 1
            -- 起码利用红线1/4允许归零
            if (hevent.POOL[key][poolIndex].stock == 0
                and hevent.POOL[key][poolIndex].count > 0.25 * hevent.POOL_RED_LINE) then
                cj.DisableTrigger(hevent.POOL[key][poolIndex].trigger)
                cj.DestroyTrigger(hevent.POOL[key][poolIndex].trigger)
                hevent.POOL[key][poolIndex] = -1
            end
            local e = 0
            for _, v in ipairs(hevent.POOL[key]) do
                if (v == -1) then
                    e = e + 1
                end
            end
            if (e == #hevent.POOL[key]) then
                hevent.POOL[key] = nil
            end
        end
        hRuntime.event.pool[handle] = nil
    end
    if (hRuntime.textTag[handle] ~= nil) then
        hRuntime.textTag[handle] = nil
    end
    if (hRuntime.rect[handle] ~= nil) then
        hRuntime.rect[handle] = nil
    end
    if (hRuntime.unit[handle] ~= nil) then
        hRuntime.unit[handle] = nil
    end
    if (table.includes(handle, hRuntime.group)) then
        table.delete(handle, hRuntime.group)
    end
    if (hRuntime.hero[handle] ~= nil) then
        hRuntime.hero[handle] = nil
    end
    if (hRuntime.heroBuildSelection[handle] ~= nil) then
        hRuntime.heroBuildSelection[handle] = nil
    end
    if (hRuntime.skill[handle] ~= nil) then
        hRuntime.skill[handle] = nil
        if (table.includes(handle, hRuntime.skill.silentUnits)) then
            table.delete(handle, hRuntime.skill.silentUnits)
        end
        if (table.includes(handle, hRuntime.skill.unarmUnits)) then
            table.delete(handle, hRuntime.skill.unarmUnits)
        end
    end
    if (hRuntime.item[handle] ~= nil) then
        hRuntime.item[handle] = nil
    end
    if (hRuntime.leaderBoard[handle] ~= nil) then
        hRuntime.leaderBoard[handle] = nil
    end
    if (hRuntime.multiBoard[handle] ~= nil) then
        hRuntime.multiBoard[handle] = nil
    end
    if (hRuntime.dialog[handle] ~= nil) then
        hRuntime.dialog[handle] = nil
    end
end

