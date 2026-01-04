local QBCore = exports['qb-core']:GetCoreObject()

-- Cache
local OriginalHandling = {}
local EditedVehicles = {}

local integerFields = {
    nInitialDriveGears = true,
    nMonetaryValue = true,
    strModelFlags = true,
    strHandlingFlags = true,
    strDamageFlags = true
}

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
    local currentTrans = GetVehicleMod(vehicle, 13)
    SetVehicleMod(vehicle, 13, -1, false)
    SetVehicleMod(vehicle, 13, currentTrans, false)

    local currentEngine = GetVehicleMod(vehicle, 11)
    SetVehicleMod(vehicle, 11, -1, false)
    SetVehicleMod(vehicle, 11, currentEngine, false)
    
    SetVehicleDirtLevel(vehicle, 0.0)
    
    if GetEntitySpeed(vehicle) < 0.1 then
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
                if integerFields[field] then
                    original[field] = GetVehicleHandlingInt(vehicle, "CHandlingData", field)
                else
                    original[field] = GetVehicleHandlingFloat(vehicle, "CHandlingData", field)
                end
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
                if integerFields[field] then
                    SetVehicleHandlingInt(vehicle, "CHandlingData", field, math.floor(val))
                else
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", field, val + 0.0)
                end
            end
        end
        
        EditedVehicles[plate] = newData
        ForceVehicleUpdate(vehicle) 
        
        SetNuiFocus(false, false)
        QBCore.Functions.Notify("Handling aplicado com sucesso!", "success")
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
                if integerFields[field] then
                    SetVehicleHandlingInt(vehicle, "CHandlingData", field, math.floor(value))
                else
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", field, value + 0.0)
                end
            end
            
            EditedVehicles[plate] = nil
            ForceVehicleUpdate(vehicle)
            
            SetNuiFocus(false, false)
            QBCore.Functions.Notify("Valores originais restaurados!", "primary")
        else
            QBCore.Functions.Notify("Original não encontrado.", "error")
        end
    end
    cb('ok')
end)

-- Exportação XML Completa
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
        
        QBCore.Functions.Notify("XML Exportado com sucesso!", "success")
    end
    cb('ok')
end)