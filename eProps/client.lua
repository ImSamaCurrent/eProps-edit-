if Config.Global.Framework == "esx" then
    ESX = nil
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent(Config.Global.SharedObject, function(obj) ESX = obj end)
            Citizen.Wait(100)
        end
        ESX.PlayerData = ESX.GetPlayerData()
    end)
elseif Config.Global.Framework == "newEsx" then 
    ESX = exports["es_extended"]:getSharedObject()
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	ESX.PlayerData.job = job  
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)  
	ESX.PlayerData.job2 = job2 
end)

local rotateSpeed, moveSpeed  = 0.5, 0.01
local object = {}

function MoveEntity(entity, direction, speed)
    local coords = GetEntityCoords(entity)
    local newCoords = coords + direction * speed
    SetEntityCoords(entity, newCoords)
end

function SpawnObj(obj)
    local playerPed = PlayerPedId()
    local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
    local objectCoords = (coords + forward * 2.0)
    local Ent = nil
    Ent = SpawnObject(obj, objectCoords)
    SetEntityHeading(Ent, GetEntityHeading(playerPed))
    PlaceObjectOnGroundProperly(Ent)
    SetEntityAlpha(Ent, 170, 170)
    SetEntityCollision(Ent, false, true)
    local placed = false
    
    exports['object_gizmo']:useGizmo(Ent)
    while not placed do
        Citizen.Wait(0)
        ESX.ShowHelpNotification("~INPUT_VEH_SHUFFLE~ - Tp sur le joueur\n~INPUT_PARACHUTE_DETACH~ - Gizmo\n~INPUT_SPRINT~ - tourner de 90°\n~INPUT_VEH_DROP_PROJECTILE~ - placer au sol\n~INPUT_CONTEXT~ - Placer\n~INPUT_FRONTEND_RRIGHT~ - Annuler")
        local CurrentHeading = GetEntityHeading(Ent)
        DisableControlAction(0, 245, true)  -- Chat
        DisableControlAction(0, 44, true)
        HudForceWeaponWheel(false)
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)

        if IsControlJustPressed(0, 194) then
            DeleteObject(Ent)
            placed = true
            EnableControlAction(0, 152, true)
            return false
        end


        if IsControlPressed(0, 104) then
            local coords = GetEntityCoords(GetPlayerPed(-1))
            SetEntityCoords(Ent, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, true)
        end

         if IsControlJustPressed(0, 145) then
              exports['object_gizmo']:useGizmo(Ent)
        end

        if IsControlJustPressed(0, 21) then
            CurrentHeading = CurrentHeading - 90.0
            SetEntityHeading(Ent, CurrentHeading)
        end

        if IsControlPressed(0, 105) then
            PlaceObjectOnGroundProperly(Ent)
        end
        if IsControlJustReleased(1, 38) then 
            placed = true
            FreezeEntityPosition(Ent, true)
            SetEntityCollision(Ent, true, true)
            SetEntityInvincible(Ent, true)
            ResetEntityAlpha(Ent)
            local NetId = NetworkGetNetworkIdFromEntity(Ent)
            table.insert(object, NetId)
            return true
        end
    end
end

function SpawnObject(model, coords)
    local model = GetHashKey(model)
    RequestModels(model)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    return obj
end

function RequestModels(modelHash)
    if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(1)
        end
    end
end



function RemoveObj(id, k)
    Citizen.CreateThread(function()
        SetNetworkIdCanMigrate(id, true)
        local entity = NetworkGetEntityFromNetworkId(id)
        NetworkRequestControlOfEntity(entity)
        local test = 0
        while test > 100 and not NetworkHasControlOfEntity(entity) do
            NetworkRequestControlOfEntity(entity)
            Wait(1)
            test = test + 1
        end
        SetEntityAsNoLongerNeeded(entity)

        local test = 0
        while test < 100 and DoesEntityExist(entity) do 
            SetEntityAsNoLongerNeeded(entity)
            TriggerServerEvent("DeleteEntity", NetworkGetNetworkIdFromEntity(entity))
            DeleteEntity(entity)
            DeleteObject(entity)
            if not DoesEntityExist(entity) then 
                table.remove(object, k)
            end
            SetEntityCoords(entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0)
            Wait(1)
            test = test + 1
        end
    end)
end

function GoodName(hash)
    for _,v in pairs (Config.Props) do
        if hash == GetHashKey(v.Model) then
            return v.Label
        else
            return hash
        end
    end
end

PropsPose = 0

function MenuProps()
    LProps = ""
    local selectedCategory = nil 
    local MenuProps = RageUI.CreateMenu("Props", Config.Global.TextColor.."Liste des props")
    local PropsSup = RageUI.CreateSubMenu(MenuProps, "Suppression", Config.Global.TextColor.."Suppression des props")
    local PropsList = RageUI.CreateSubMenu(MenuProps, "Props", Config.Global.TextColor.."Liste des props")
    MenuProps.Closed = function() 
         DeleteObject(ViewLocalPops)
    end 
    PropsSup.Closed = function() 
         DeleteObject(ViewLocalPops)
    end 
    PropsList.Closed = function() 
         DeleteObject(ViewLocalPops)
    end 
    MenuProps:SetRectangleBanner(0, 0, 0)
    PropsSup:SetRectangleBanner(0, 0, 0)
    PropsList:SetRectangleBanner(0, 0, 0)

    RageUI.Visible(MenuProps, not RageUI.Visible(MenuProps))
    while MenuProps do
        Citizen.Wait(0)

            RageUI.IsVisible(MenuProps, true, true, true, function()

                local coords  = GetEntityCoords(PlayerPedId())

                RageUI.Separator(Config.Global.TextColor.."Props posé : ~s~"..PropsPose..""..Config.Global.TextColor.."/~s~"..Config.Global.PropsMax)

                RageUI.Button(Config.Global.TextColor.."→~s~ Liste de mes props", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                end, PropsSup)

                RageUI.Separator("↓ "..Config.Global.TextColor.."Props~s~ ↓")

                for _, category in pairs(Config.Props) do
                    if (not category.job or (ESX.PlayerData.job and ESX.PlayerData.job.name == category.job)) and
                    (not category.job2 or (ESX.PlayerData.job2 and ESX.PlayerData.job2.name == category.job2)) then              
                        RageUI.Button(Config.Global.TextColor.."→~s~ "..category.name, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                            if Selected then
                                selectedCategory = category
                            end
                        end, PropsList)
                    end
                end

            end, function() 
            end)

            RageUI.IsVisible(PropsList, true, true, true, function()

                if Config.CustomProps then
                        RageUI.Button(Config.Global.TextColor.."→~s~ "..Config.Global.LabelCustomsProps, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                            if Active then
                                if DoesEntityExist(ViewLocalPops) and LProps ~= "" then
                                    LProps = ''
                                    DeleteEntity(ViewLocalPops)
                                end
                            end
                            if Selected then
                                local CustProps = lib.inputDialog(Config.Global.LabelCustomsProps, {'Props'})
                                if not CustProps then return end
                                if CustProps[1] == nil then
                                    ESX.ShowNotification("[~y~Attention~s~] Aucun ~r~Props~s~renseigné")
                                else
                                    if IsModelInCdimage(CustProps[1]) then 
                                        if SpawnObj(CustProps[1]) then
                                            local pid = PlayerPedId()
                                            RequestAnimDict("pickup_object")
                                            while (not HasAnimDictLoaded("pickup_object")) do Citizen.Wait(0) end
                                            TaskPlayAnim(pid,"pickup_object","pickup_low",1.0,-1.0, -1, 2, 1, true, true, true)
                                            FreezeEntityPosition(PlayerPedId(), true)
                                            Wait(1500)
                                            ClearPedTasks(PlayerPedId())
                                            FreezeEntityPosition(PlayerPedId(), false)
                                            PropsPose = PropsPose + 1
                                            ESX.ShowNotification("~r~Vous pouvez encore faire spawn ~g~x"..(Config.Global.PropsMax - PropsPose).." ~r~Props")
                                            RageUI.GoBack()
                                        end
                                    else
                                        ESX.ShowNotification("[~y~Attention~s~] Model inconnu")
                                    end
                                end
                            end
                        end)

                        RageUI.Separator()
                    end

                    if selectedCategory then
                        for _, prop in ipairs(selectedCategory.Props) do
                            RageUI.Button(Config.Global.TextColor.."→~s~ "..prop.Label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                                if Active then 
                                    if prop.Model ~= LProps then
                                        DeleteObject(ViewLocalPops)
                                        LProps = prop.Model
                                        local LPplayerPed = PlayerPedId()
                                        local LPcoords, LPforward = GetEntityCoords(LPplayerPed), GetEntityForwardVector(LPplayerPed)
                                        local LPobjectCoords = (LPcoords + LPforward * 2.0)
                                        ViewLocalPops = SpawnObject(LProps, LPobjectCoords)
                                        PlaceObjectOnGroundProperly(ViewLocalPops)
                                        SetEntityAlpha(ViewLocalPops, 170, 170)
                                        SetEntityCollision(ViewLocalPops, false, true)
                                    else
                                        local LPplayerPed2 = PlayerPedId()
                                        local LPcoords2, LPforward2 = GetEntityCoords(LPplayerPed2), GetEntityForwardVector(LPplayerPed2)
                                        local LPobjectCoords2 = (LPcoords2 + LPforward2 * 2.0)
                                        SetEntityCoords(ViewLocalPops, LPobjectCoords2, 0.0, 0.0, 0.0, true)
                                        SetEntityHeading(ViewLocalPops, GetEntityHeading(LPplayerPed2))
                                        PlaceObjectOnGroundProperly(ViewLocalPops)
                                    end
                                end
                                if Selected then
                                    LProps = ""
                                    DeleteObject(ViewLocalPops)
                                    if PropsPose == Config.Global.PropsMax then
                                        ESX.ShowNotification("~r~Vous avez fait spawn le maximum de props possible")
                                        return
                                    end
                                    if SpawnObj(prop.Model) then
                                        local pid = PlayerPedId()
                                        RequestAnimDict("pickup_object")
                                        while (not HasAnimDictLoaded("pickup_object")) do Citizen.Wait(0) end
                                        TaskPlayAnim(pid,"pickup_object","pickup_low",1.0,-1.0, -1, 2, 1, true, true, true)
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        Wait(1500)
                                        ClearPedTasks(PlayerPedId())
                                        FreezeEntityPosition(PlayerPedId(), false)
                                        PropsPose = PropsPose + 1
                                        ESX.ShowNotification("~r~Vous pouvez encore faire spawn ~g~x"..(Config.Global.PropsMax - PropsPose).." ~r~Props")
                                        RageUI.GoBack()
                                    end
                                end
                            end)
                        end
                    end

            end, function() 
            end)

            RageUI.IsVisible(PropsSup, true, true, true, function()

                local newObject = {}
                for k,v in pairs(object) do
                    local propName = GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v)))
                    if propName ~= 0 then 
                        RageUI.Button("[Props] = "..propName, nil, {RightLabel = "→ ~r~Supprimer"}, true, function(Hovered, Active, Selected)
                            if Active then
                                local entity = NetworkGetEntityFromNetworkId(v)
                                local ObjCoords = GetEntityCoords(entity)
                                DrawMarker(0, ObjCoords.x, ObjCoords.y, ObjCoords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, Config.Global.ColorMenuR, Config.Global.ColorMenuG, Config.Global.ColorMenuB, 170, 1, 0, 2, 1, nil, nil, 0)
                            end
                            if Selected then
                                RemoveObj(v)
                                PropsPose = PropsPose - 1
                                RageUI.GoBack()
                            else
                                table.insert(newObject, v)
                            end
                        end)
                    end
                end
                object = newObject
            
            end, function()
            end)

        if not 
        RageUI.Visible(MenuProps) and not 
        RageUI.Visible(PropsSup) and not  
        RageUI.Visible(PropsList) 
        then
            MenuProps = RMenu:DeleteType(MenuProps, true)
        end
    end
end

StatOpenMenu = true

RegisterCommand("props", function()
    if StatOpenMenu then
        MenuProps()
    end
end, false)

exports("PropsMenu", function()
    if StatOpenMenu then
        MenuProps()
    end
end)


RegisterNetEvent('eProps:enable')
AddEventHandler('eProps:enable', function(StatOpenMenu)  
    StatOpenMenu = StatOpenMenu  
end)
