local QBCore = exports['qb-core']:GetCoreObject()

-- Cache
local OriginalHandling = {}
local EditedVehicles = {}

local handlingFloats = {
    "fMass", "fInitialDragCoeff", "fPercentSubmerged", "fDriveBiasFront", "nInitialDriveGears",
    "fInitialDriveForce", "fDriveInertia", "fClutchChangeTimeScalePoint", "fDrivePointMaxAnglePoint",
    "fSteeringLock", "fTractionCurveMax", "fTractionCurveMin", "fTractionCurveLateral",
    "fTractionSpringDeltaMax", "fLowSpeedTractionLossMult", "fCamberStiffnesss",
    "fTractionBiasFront", "fTractionLossMult", "fSuspensionForce", "fSuspensionCompDamp",
    "fSuspensionReboundDamp", "fSuspensionUpperLimit", "fSuspensionLowerLimit", "fSuspensionRaise",
    "fSuspensionBiasFront", "fAntiRollBarForce", "fAntiRollBarBiasFront", "fRollCentreHeightFront",
    "fRollCentreHeightRear", "fCollisionDamageMult", "fWeaponDamageMult", "fDeformationDamageMult",
    "fEngineDamageMult", "fPetrolTankVolume", "fOilVolume", "fBrakeForce", "fBrakeBiasFront"
}

local function ForceVehicleUpdate(vehicle)
    local isEngineOn = GetIsVehicleEngineRunning(vehicle)
    SetVehicleEngineOn(vehicle, not isEngineOn, true, true)
    SetVehicleEngineOn(vehicle, isEngineOn, true, true)
    SetVehicleDirtLevel(vehicle, 0.0)
    
    -- Empurrãozinho se estiver parado
    local vel = GetEntityVelocity(vehicle)
    if #vel < 0.1 then
        ApplyForceToEntity(vehicle, 1, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
    end
end

RegisterCommand('handling', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle and vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        local handlingData = {}
        local originalData = {}

        if not OriginalHandling[plate] then
            local original = {}
            for _, field in ipairs(handlingFloats) do
                original[field] = GetVehicleHandlingFloat(vehicle, "CHandlingData", field)
            end
            OriginalHandling[plate] = original
        end

        if EditedVehicles[plate] then
            handlingData = EditedVehicles[plate]
        else
            handlingData = OriginalHandling[plate]
        end
        originalData = OriginalHandling[plate]

        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "open",
            data = handlingData,
            original = originalData
        })
    else
        QBCore.Functions.Notify("Entre em um veículo primeiro!", "error")
    end
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('applyChanges', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local newData = data.handlingData

    if vehicle and vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        for field, value in pairs(newData) do
            local val = tonumber(value)
            if val then
                SetVehicleHandlingFloat(vehicle, "CHandlingData", field, val)
            end
        end
        EditedVehicles[plate] = newData
        ForceVehicleUpdate(vehicle)
        SetNuiFocus(false, false)
        QBCore.Functions.Notify("Handling aplicado! Teste o veículo.", "success")
    end
    cb('ok')
end)

RegisterNUICallback('resetHandling', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        if OriginalHandling[plate] then
            for field, value in pairs(OriginalHandling[plate]) do
                SetVehicleHandlingFloat(vehicle, "CHandlingData", field, value)
            end
            EditedVehicles[plate] = nil
            ForceVehicleUpdate(vehicle)
            SetNuiFocus(false, false)
            QBCore.Functions.Notify("Valores padrão restaurados!", "primary")
        end
    end
    cb('ok')
end)

-- Coleta TUDO para Exportação XML
RegisterNUICallback('exportHandling', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle and vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        local modelHash = GetEntityModel(vehicle)
        local modelName = GetDisplayNameFromVehicleModel(modelHash)
        
        local exportData = {}
        
        -- Floats
        local allFloats = {
            "fMass", "fInitialDragCoeff", "fPercentSubmerged", "fDriveBiasFront", 
            "fInitialDriveForce", "fDriveInertia", "fInitialDriveMaxFlatVel", 
            "fBrakeForce", "fBrakeBiasFront", "fHandBrakeForce", "fSteeringLock", 
            "fTractionCurveMax", "fTractionCurveMin", "fTractionCurveLateral", 
            "fTractionSpringDeltaMax", "fLowSpeedTractionLossMult", "fCamberStiffnesss", 
            "fTractionBiasFront", "fTractionLossMult", "fSuspensionForce", "fSuspensionCompDamp", 
            "fSuspensionReboundDamp", "fSuspensionUpperLimit", "fSuspensionLowerLimit", 
            "fSuspensionRaise", "fSuspensionBiasFront", "fAntiRollBarForce", "fAntiRollBarBiasFront", 
            "fRollCentreHeightFront", "fRollCentreHeightRear", "fCollisionDamageMult", "fWeaponDamageMult", 
            "fDeformationDamageMult", "fEngineDamageMult", "fPetrolTankVolume", "fOilVolume", 
            "fSeatOffsetDistX", "fSeatOffsetDistY", "fSeatOffsetDistZ"
        }
        for _, field in ipairs(allFloats) do
            exportData[field] = GetVehicleHandlingFloat(vehicle, "CHandlingData", field)
        end
        
        -- Clutch mapping
        local clutch = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeTimeScalePoint")
        exportData["fClutchChangeRateScaleUpShift"] = clutch
        exportData["fClutchChangeRateScaleDownShift"] = clutch

        -- Ints & Vectors
        exportData["nInitialDriveGears"] = GetVehicleHandlingInt(vehicle, "CHandlingData", "nInitialDriveGears")
        exportData["nMonetaryValue"] = GetVehicleHandlingInt(vehicle, "CHandlingData", "nMonetaryValue")
        exportData["vecCentreOfMassOffset"] = GetVehicleHandlingVector(vehicle, "CHandlingData", "vecCentreOfMassOffset")
        exportData["vecInertiaMultiplier"] = GetVehicleHandlingVector(vehicle, "CHandlingData", "vecInertiaMultiplier")
        
        -- Flags
        exportData["strModelFlags"] = GetVehicleHandlingInt(vehicle, "CHandlingData", "strModelFlags")
        exportData["strHandlingFlags"] = GetVehicleHandlingInt(vehicle, "CHandlingData", "strHandlingFlags")
        exportData["strDamageFlags"] = GetVehicleHandlingInt(vehicle, "CHandlingData", "strDamageFlags")

        TriggerServerEvent('zs_handlingeditor:server:saveHandling', modelName, plate, exportData)
        QBCore.Functions.Notify("Handling XML exportado para a pasta output!", "success")
    end
    cb('ok')
end)