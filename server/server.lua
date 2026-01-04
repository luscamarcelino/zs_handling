local function ToHex(decimal)
    return string.format("%X", decimal)
end

RegisterNetEvent('zs_handlingeditor:server:saveHandling', function(modelName, plate, data)
    local src = source
    
    -- Montagem do XML (Template handling.meta)
    local xmlContent = string.format([[
<HandlingData>
  <Item type="CHandlingData">
      <handlingName>%s</handlingName>
      <fMass value="%s" />
      <fInitialDragCoeff value="%s" />
      <fPercentSubmerged value="%s" />
      <vecCentreOfMassOffset x="%s" y="%s" z="%s" />
      <vecInertiaMultiplier x="%s" y="%s" z="%s" />
      <fDriveBiasFront value="%s" />
      <nInitialDriveGears value="%d" />
      <fInitialDriveForce value="%s" />
      <fDriveInertia value="%s" />
      <fClutchChangeRateScaleUpShift value="%s" />
      <fClutchChangeRateScaleDownShift value="%s" />
      <fInitialDriveMaxFlatVel value="%s" />
      <fBrakeForce value="%s" />
      <fBrakeBiasFront value="%s" />
      <fHandBrakeForce value="%s" />
      <fSteeringLock value="%s" />
      <fTractionCurveMax value="%s" />
      <fTractionCurveMin value="%s" />
      <fTractionCurveLateral value="%s" />
      <fTractionSpringDeltaMax value="%s" />
      <fLowSpeedTractionLossMult value="%s" />
      <fCamberStiffnesss value="%s" />
      <fTractionBiasFront value="%s" />
      <fTractionLossMult value="%s" />
      <fSuspensionForce value="%s" />
      <fSuspensionCompDamp value="%s" />
      <fSuspensionReboundDamp value="%s" />
      <fSuspensionUpperLimit value="%s" />
      <fSuspensionLowerLimit value="%s" />
      <fSuspensionRaise value="%s" />
      <fSuspensionBiasFront value="%s" />
      <fAntiRollBarForce value="%s" />
      <fAntiRollBarBiasFront value="%s" />
      <fRollCentreHeightFront value="%s" />
      <fRollCentreHeightRear value="%s" />
      <fCollisionDamageMult value="%s" />
      <fWeaponDamageMult value="%s" />
      <fDeformationDamageMult value="%s" />
      <fEngineDamageMult value="%s" />
      <fPetrolTankVolume value="%s" />
      <fOilVolume value="%s" />
      <fSeatOffsetDistX value="%s" />
      <fSeatOffsetDistY value="%s" />
      <fSeatOffsetDistZ value="%s" />
      <nMonetaryValue value="%d" />
      <strModelFlags>%s</strModelFlags>
      <strHandlingFlags>%s</strHandlingFlags>
      <strDamageFlags>%s</strDamageFlags>
      <AIHandling>AVERAGE</AIHandling>
      <SubHandlingData>
        <Item type="CCarHandlingData">
        </Item>
      </SubHandlingData>
  </Item>
</HandlingData>]],
    modelName,
    string.format("%.6f", data.fMass),
    string.format("%.6f", data.fInitialDragCoeff),
    string.format("%.6f", data.fPercentSubmerged),
    string.format("%.6f", data.vecCentreOfMassOffset.x), string.format("%.6f", data.vecCentreOfMassOffset.y), string.format("%.6f", data.vecCentreOfMassOffset.z),
    string.format("%.6f", data.vecInertiaMultiplier.x), string.format("%.6f", data.vecInertiaMultiplier.y), string.format("%.6f", data.vecInertiaMultiplier.z),
    string.format("%.6f", data.fDriveBiasFront),
    math.floor(data.nInitialDriveGears),
    string.format("%.6f", data.fInitialDriveForce),
    string.format("%.6f", data.fDriveInertia),
    string.format("%.6f", data.fClutchChangeRateScaleUpShift),
    string.format("%.6f", data.fClutchChangeRateScaleDownShift),
    string.format("%.6f", data.fInitialDriveMaxFlatVel),
    string.format("%.6f", data.fBrakeForce),
    string.format("%.6f", data.fBrakeBiasFront),
    string.format("%.6f", data.fHandBrakeForce),
    string.format("%.6f", data.fSteeringLock),
    string.format("%.6f", data.fTractionCurveMax),
    string.format("%.6f", data.fTractionCurveMin),
    string.format("%.6f", data.fTractionCurveLateral),
    string.format("%.6f", data.fTractionSpringDeltaMax),
    string.format("%.6f", data.fLowSpeedTractionLossMult),
    string.format("%.6f", data.fCamberStiffnesss),
    string.format("%.6f", data.fTractionBiasFront),
    string.format("%.6f", data.fTractionLossMult),
    string.format("%.6f", data.fSuspensionForce),
    string.format("%.6f", data.fSuspensionCompDamp),
    string.format("%.6f", data.fSuspensionReboundDamp),
    string.format("%.6f", data.fSuspensionUpperLimit),
    string.format("%.6f", data.fSuspensionLowerLimit),
    string.format("%.6f", data.fSuspensionRaise),
    string.format("%.6f", data.fSuspensionBiasFront),
    string.format("%.6f", data.fAntiRollBarForce),
    string.format("%.6f", data.fAntiRollBarBiasFront),
    string.format("%.6f", data.fRollCentreHeightFront),
    string.format("%.6f", data.fRollCentreHeightRear),
    string.format("%.6f", data.fCollisionDamageMult),
    string.format("%.6f", data.fWeaponDamageMult),
    string.format("%.6f", data.fDeformationDamageMult),
    string.format("%.6f", data.fEngineDamageMult),
    string.format("%.6f", data.fPetrolTankVolume),
    string.format("%.6f", data.fOilVolume),
    string.format("%.6f", data.fSeatOffsetDistX),
    string.format("%.6f", data.fSeatOffsetDistY),
    string.format("%.6f", data.fSeatOffsetDistZ),
    math.floor(data.nMonetaryValue),
    ToHex(data.strModelFlags),
    ToHex(data.strHandlingFlags),
    ToHex(data.strDamageFlags)
    )

    -- Salva na pasta output com nome unico e não virar bagunça
    local fileName = "handling_" .. modelName .. "_" .. os.time() .. ".meta"
    SaveResourceFile(GetCurrentResourceName(), "output/" .. fileName, xmlContent, -1)
    
    print("^2[zs_handlingeditor] XML Exportado: output/" .. fileName .. "^0")
end)