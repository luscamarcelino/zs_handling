const app = document.getElementById('app');
const container = document.getElementById('fieldsContainer');
const header = document.querySelector('.header');
const tabs = document.querySelectorAll('.tab-btn');

let currentHandlingData = {};
let originalHandlingData = {};
let currentTab = 'motor';

const categories = {
    motor: [
        "fInitialDriveForce", "fDriveInertia", "nInitialDriveGears", "fClutchChangeTimeScalePoint", 
        "fInitialDragCoeff", "fDriveBiasFront", "fDrivePointMaxAnglePoint", "fInitialDriveMaxFlatVel"
    ],
    tracao: [
        "fBrakeForce", "fBrakeBiasFront", "fSteeringLock", "fTractionCurveMax", 
        "fTractionCurveMin", "fTractionCurveLateral", "fTractionSpringDeltaMax", 
        "fLowSpeedTractionLossMult", "fTractionBiasFront", "fTractionLossMult", "fCamberStiffnesss"
    ],
    suspensao: [
        "fSuspensionForce", "fSuspensionCompDamp", "fSuspensionReboundDamp", 
        "fSuspensionUpperLimit", "fSuspensionLowerLimit", "fSuspensionRaise", 
        "fSuspensionBiasFront", "fAntiRollBarForce", "fAntiRollBarBiasFront", 
        "fRollCentreHeightFront", "fRollCentreHeightRear"
    ],
    outros: [
        "fMass", "fCollisionDamageMult", "fWeaponDamageMult", "fDeformationDamageMult", 
        "fEngineDamageMult", "fPetrolTankVolume", "fOilVolume", "fPercentSubmerged"
    ]
};

const handlingDescriptions = {
    fInitialDriveForce: "Potência do motor (Torque). Aumente para arrancar mais rápido (0.1 a 0.5 geralmente).",
    fDriveInertia: "Inércia do motor. Valores MENORES fazem o giro subir mais rápido (motor mais esperto).",
    nInitialDriveGears: "Número total de marchas do veículo (Ex: 5 ou 6).",
    fClutchChangeTimeScalePoint: "Velocidade da troca de marcha. Quanto maior, mais rápida a troca.",
    fInitialDragCoeff: "Aerodinâmica (Resistência do ar). Diminua para aumentar a velocidade final (Top Speed).",
    fDriveBiasFront: "Tração: 0.0 = Traseira | 1.0 = Dianteira | 0.5 = 4x4 (Integral).",
    fDrivePointMaxAnglePoint: "Ângulo máximo que o carro consegue derrapar antes de perder o controle.",
    fInitialDriveMaxFlatVel: "Velocidade máxima teórica em km/h (define o limite final do carro).",

    // --- FREIOS & DIREÇÃO ---
    fBrakeForce: "Força da frenagem. Valores muito altos travam a roda (0.5 a 1.2 é o ideal).",
    fBrakeBiasFront: "Equilíbrio do freio: Mais perto de 1.0 = Freia mais a frente (estável). Mais perto de 0.0 = Freia a trás (drift).",
    fSteeringLock: "O ângulo máximo que as rodas viram (em graus). Geralmente entre 35 e 45.",
    
    // --- TRAÇÃO & ADERÊNCIA ---
    fTractionCurveMax: "Aderência máxima nas curvas. Aumente para o carro grudar mais no chão.",
    fTractionCurveMin: "Aderência mínima. Define o quanto o carro escorrega quando perde tração.",
    fTractionCurveLateral: "Aderência lateral. Ajuda a não sair de traseira nas curvas fechadas.",
    fTractionSpringDeltaMax: "Distância da mola de tração. Afeta o quanto o pneu 'dobra' no limite.",
    fLowSpeedTractionLossMult: "Perda de tração em baixa velocidade (Burnout). Aumente para destracionar mais na saída.",
    fTractionBiasFront: "Balanço da tração: Mais perto de 1.0 = Mais aderência na frente (sai menos de frente).",
    fTractionLossMult: "Multiplicador de perda de aderência em terrenos ruins (terra, chuva).",
    fCamberStiffnesss: "Rigidez da cambagem. Aumentar ajuda a manter o pneu no chão em curvas fortes.",

    // --- SUSPENSÃO ---
    fSuspensionForce: "Dureza da suspensão. Valor alto = carro firme (esportivo). Valor baixo = carro mole (banheira).",
    fSuspensionCompDamp: "Amortecimento na compressão. Define o quanto a suspensão resiste ao descer (passar num buraco).",
    fSuspensionReboundDamp: "Amortecimento no retorno. Define o quão rápido a suspensão volta ao normal após o buraco.",
    fSuspensionUpperLimit: "Limite superior do curso da suspensão (o quanto ela sobe).",
    fSuspensionLowerLimit: "Limite inferior do curso da suspensão (o quanto ela desce).",
    fSuspensionRaise: "Altura do veículo em relação à suspensão. Use para rebaixar ou levantar o carro.",
    fSuspensionBiasFront: "Balanço da suspensão: Mais perto de 1.0 = Frente mais dura que a traseira.",
    fAntiRollBarForce: "Barra estabilizadora. Evita que a carroceria incline muito nas curvas (rolagem).",
    fAntiRollBarBiasFront: "Balanço da barra estabilizadora entre frente e trás.",
    fRollCentreHeightFront: "Altura do centro de rolagem dianteiro. Afeta a transferência de peso na curva.",
    fRollCentreHeightRear: "Altura do centro de rolagem traseiro.",

    // --- FÍSICA & DANOS ---
    fMass: "Peso do veículo em Quilogramas. Afeta colisões e inércia.",
    fCollisionDamageMult: "Multiplicador de dano na lataria ao bater (0.0 = indestrutível).",
    fWeaponDamageMult: "Multiplicador de dano recebido por tiros.",
    fDeformationDamageMult: "O quanto o carro amassa visualmente ao bater.",
    fEngineDamageMult: "O quanto o motor estraga ao bater (resistência do motor).",
    fPetrolTankVolume: "Capacidade do tanque de combustível em litros.",
    fOilVolume: "Volume de óleo do motor.",
    fPercentSubmerged: "Porcentagem do carro que precisa estar na água para afogar o motor (Ex: 0.85 = 85%)."
};

tabs.forEach(btn => {
    btn.addEventListener('click', () => {
        tabs.forEach(t => t.classList.remove('active'));
        btn.classList.add('active');
        currentTab = btn.getAttribute('data-tab');
        buildForm(currentHandlingData, originalHandlingData);
    });
});

window.addEventListener('message', function(event) {
    if (event.data.type === "open") {
        currentHandlingData = event.data.data;
        originalHandlingData = event.data.original || {};
        buildForm(currentHandlingData, originalHandlingData);
        app.style.display = 'flex';
        if (!app.style.top) { app.style.top = '10%'; app.style.left = '10%'; }
    }
});

function buildForm(data, originalData) {
    container.innerHTML = '';
    const fields = categories[currentTab] || [];

    fields.forEach(key => {
        if (data[key] === undefined) return;
        
        const div = document.createElement('div');
        div.className = 'input-group';
        
        const labelArea = document.createElement('div');
        labelArea.className = 'label-area';

        const label = document.createElement('label');
        label.innerText = key;

        const origLabel = document.createElement('span');
        origLabel.className = 'original-val';
        if (originalData[key] !== undefined) {
            origLabel.innerText = `(Orig: ${Number(originalData[key]).toFixed(6)})`;
            if (data[key] !== originalData[key]) origLabel.style.color = '#e74c3c';
        }

        const icon = document.createElement('div');
        icon.className = 'info-icon';
        icon.innerText = 'i';
        
        const tooltip = document.createElement('span');
        tooltip.className = 'tooltip-text';
        tooltip.innerText = handlingDescriptions[key] || "Sem descrição.";

        labelArea.append(label, origLabel, icon, tooltip);

        const input = document.createElement('input');
        input.type = 'number';
        
        input.step = '0.000001'; 
        
        if (key === 'nInitialDriveGears' || key.startsWith('n')) {
             input.step = '1';
             input.value = data[key];
        } else {
             input.value = data[key].toFixed(6);
        }
        
        input.addEventListener('change', (e) => {
            currentHandlingData[key] = parseFloat(e.target.value);
            
            // Verifica diferença com precisão
            if (currentHandlingData[key] !== originalData[key]) {
                origLabel.style.color = '#e74c3c';
            } else {
                origLabel.style.color = '#777';
            }
        });

        div.append(labelArea, input);
        container.append(div);
    });
}

document.getElementById('applyBtn').onclick = () => {
    fetch(`https://${GetParentResourceName()}/applyChanges`, {
        method: 'POST', headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: JSON.stringify({ handlingData: currentHandlingData })
    });
    app.style.display = 'none';
};
document.getElementById('resetBtn').onclick = () => {
    fetch(`https://${GetParentResourceName()}/resetHandling`, { method: 'POST' });
    app.style.display = 'none';
};
document.getElementById('exportBtn').onclick = () => {
    fetch(`https://${GetParentResourceName()}/exportHandling`, { method: 'POST' });
};
document.getElementById('closeBtn').onclick = () => {
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
    app.style.display = 'none';
};
document.onkeyup = (e) => { if (e.which == 27) document.getElementById('closeBtn').click(); };

let isDragging = false, startX, startY, initLeft, initTop;
header.onmousedown = (e) => {
    isDragging = true; startX = e.clientX; startY = e.clientY;
    const rect = app.getBoundingClientRect(); initLeft = rect.left; initTop = rect.top;
    header.style.cursor = 'grabbing';
};
document.onmousemove = (e) => {
    if (!isDragging) return;
    app.style.left = `${initLeft + e.clientX - startX}px`;
    app.style.top = `${initTop + e.clientY - startY}px`;
};
document.onmouseup = () => { isDragging = false; header.style.cursor = 'grab'; };