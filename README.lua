# esx_convertisseur_item_props
# code qui vous permettra que convertir un item en props et un props en item  directement dans ox_inventory sans script externe full configurable et open source :
# bien suivre les instruction plusieurs etapes !
# c'est un projet en cours car je suit pas satisfait manque quelque correction par exemple l'item transformer en props et visible mais c'est pas un props libre
# si vous voyez ceux que je veut dire 
# en gros tu ta dedans a pieds il bouge la c'est pas le cas -__- je suit dessus 

#####  coter client dans votre ox_inventory :

local spawnedProps = {}

RegisterNetEvent('ox_inventory:createdrop', function(drop)
    if not drop or not drop.coords or not drop.items or #drop.items == 0 then return end

local propNames = {
    ['bouteille_vide'] = 'prop_water_bottle',
    ['water'] = 'prop_ld_flow_bottle',

}

    local model = propNames[item.name]
    if not model then return end

    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end

    local obj = CreateObject(hash, drop.coords.x, drop.coords.y, drop.coords.z - 1.0, true, false, true)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)
    spawnedProps[drop.id] = obj

    exports.ox_target:addLocalEntity(obj, {
        {
            name = 'pickup_' .. drop.id,
            label = 'Ramasser',
            icon = 'fas fa-hand',
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent('ox_inventory:pickup', drop.id)
                DeleteEntity(obj)
            end
        }
    })

    SetTimeout(30 * 60 * 1000, function()
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
            spawnedProps[drop.id] = nil
        end
    end)
end)

AddEventHandler('ox_inventory:removedrop', function(id)
    local prop = spawnedProps[id]
    if prop and DoesEntityExist(prop) then
        DeleteEntity(prop)
    end
    spawnedProps[id] = nil
end)



# COTER SERVER de ox_inventory :


local itemProps = {
    ['bouteille_vide']     = 'prop_water_bottle',
    ['water']                = 'prop_ld_flow_bottle',
   
}

local function getDropModel(itemName)
    return itemProps[itemName] and GetHashKey(itemProps[itemName]) or nil
end

exports.ox_inventory:registerHook('swapItems', function(payload)
    if payload.toInventory ~= 'newdrop' then return end
    local item = payload.fromSlot
    local count = payload.count or 1
    local coords = GetEntityCoords(GetPlayerPed(payload.source))

    local dropItems = { { item.name, count, item.metadata } }
    local model = getDropModel(item.name)

    if not model then return end

    local dropId = exports.ox_inventory:CustomDrop(item.label, dropItems, coords, 1, item.weight or 0, nil, model)
    if not dropId then return end

    CreateThread(function()
        exports.ox_inventory:RemoveItem(payload.source, item.name, count, nil, item.slot)
        Wait(0)
        exports.ox_inventory:forceOpenInventory(payload.source, 'drop', dropId)
    end)

    return false
end, {
    typeFilter = { player = true }
})


## si sa fonctionne toujours pas suivre les indication suivantes 
## va dans init.lua dans ox_inventory  
## vous devait avoir c'est lignes : 

dropprops = GetConvarInt('inventory:dropprops', 1) == 1,
dropmodel = joaat(GetConvar('inventory:dropmodel', 'prop_med_bag_01b')),



# dans votre cfg 
# vous devrait mettre  sa  : 

setr inventory:dropprops false
setr inventory:dropmodel ""


# j'espere sa vous aurra bien aidez pour tout question rejoingnez mon discords : https://discord.gg/3sUuFGVq 


