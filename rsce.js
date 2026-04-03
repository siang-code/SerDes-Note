// === RSCE 互動動畫 ===

const slider = document.getElementById("channelLength");
const lValueLabel = document.getElementById("lValue");
const infoText = document.getElementById("infoText");
const infoBox = document.getElementById("infoBox");

const mosfetCanvas = document.getElementById("mosfetCanvas");
const vthCanvas = document.getElementById("vthCanvas");
const mCtx = mosfetCanvas.getContext("2d");
const vCtx = vthCanvas.getContext("2d");

// --- 物理模型 ---
// Vth(L) 模型：RSCE 在短通道 Vth 上升，長通道趨近 Vth0
// Vth = Vth0 + deltaVth_RSCE(L) - deltaVth_SCE(L)
const VTH0 = 0.45; // 長通道 Vth (V)

function vthModel(L_nm) {
    // RSCE 項：Halo overlap 造成，短通道時顯著
    const rsce = 0.35 * Math.exp(-L_nm / 60);
    // SCE 項：傳統短通道效應，使 Vth 下降（但在 55nm Halo 工藝下被 RSCE 壓過）
    const sce = 0.08 * Math.exp(-L_nm / 35);
    return VTH0 + rsce - sce;
}

// Halo 摻雜濃度剖面（沿通道方向 x，歸一化）
function haloDoping(x_norm, L_nm) {
    // x_norm: 0~1 沿通道方向
    // 兩端 Halo 口袋，短通道時重疊
    const sigma = L_nm / 600; // 口袋寬度隨 L 縮放
    const leftPocket = Math.exp(-Math.pow(x_norm, 2) / (2 * sigma * sigma));
    const rightPocket = Math.exp(-Math.pow(1 - x_norm, 2) / (2 * sigma * sigma));
    const baseline = 0.15;
    return baseline + leftPocket + rightPocket;
}

// --- 繪製 MOSFET 截面 ---
function drawMOSFET(L_nm) {
    const W = mosfetCanvas.width;
    const H = mosfetCanvas.height;
    mCtx.clearRect(0, 0, W, H);

    // 比例計算
    const lFrac = (L_nm - 40) / (500 - 40); // 0(短) ~ 1(長)
    const gateWidth = 80 + lFrac * 200; // 像素寬度
    const centerX = W / 2;

    // 基板 (P-sub)
    mCtx.fillStyle = "#1a1a3e";
    mCtx.fillRect(0, 200, W, H - 200);
    mCtx.fillStyle = "#555";
    mCtx.font = "13px sans-serif";
    mCtx.textAlign = "center";
    mCtx.fillText("P-substrate", centerX, H - 16);

    // Source / Drain (N+)
    const sdWidth = 70;
    const sdTop = 180;
    const sdHeight = 70;

    // Source
    mCtx.fillStyle = "#1565c0";
    mCtx.fillRect(centerX - gateWidth / 2 - sdWidth, sdTop, sdWidth, sdHeight);
    mCtx.fillStyle = "#90caf9";
    mCtx.font = "bold 13px sans-serif";
    mCtx.fillText("N+ Source", centerX - gateWidth / 2 - sdWidth / 2, sdTop + 40);

    // Drain
    mCtx.fillStyle = "#1565c0";
    mCtx.fillRect(centerX + gateWidth / 2, sdTop, sdWidth, sdHeight);
    mCtx.fillStyle = "#90caf9";
    mCtx.fillText("N+ Drain", centerX + gateWidth / 2 + sdWidth / 2, sdTop + 40);

    // Halo Implant 口袋（關鍵視覺）
    const haloRadius = 35 + lFrac * 15;
    const haloOverlap = L_nm < 120;
    const haloAlpha = haloOverlap ? 0.8 : 0.5;

    // 左 Halo
    const grad1 = mCtx.createRadialGradient(
        centerX - gateWidth / 2 + 10, sdTop + sdHeight - 10, 5,
        centerX - gateWidth / 2 + 10, sdTop + sdHeight - 10, haloRadius
    );
    grad1.addColorStop(0, `rgba(255, 60, 60, ${haloAlpha})`);
    grad1.addColorStop(1, "rgba(255, 60, 60, 0)");
    mCtx.fillStyle = grad1;
    mCtx.fillRect(centerX - gateWidth / 2 - 20, sdTop + 10, gateWidth / 2 + 30, sdHeight + 30);

    // 右 Halo
    const grad2 = mCtx.createRadialGradient(
        centerX + gateWidth / 2 - 10, sdTop + sdHeight - 10, 5,
        centerX + gateWidth / 2 - 10, sdTop + sdHeight - 10, haloRadius
    );
    grad2.addColorStop(0, `rgba(255, 60, 60, ${haloAlpha})`);
    grad2.addColorStop(1, "rgba(255, 60, 60, 0)");
    mCtx.fillStyle = grad2;
    mCtx.fillRect(centerX - 10, sdTop + 10, gateWidth / 2 + 30, sdHeight + 30);

    // 重疊警示
    if (haloOverlap) {
        mCtx.fillStyle = "rgba(255, 200, 0, 0.15)";
        mCtx.fillRect(centerX - gateWidth / 2, sdTop + 20, gateWidth, sdHeight);
        mCtx.fillStyle = "#ffaa00";
        mCtx.font = "bold 11px sans-serif";
        mCtx.fillText("⚠ Halo 重疊！", centerX, sdTop + sdHeight + 24);
    }

    // Gate Oxide
    mCtx.fillStyle = "#4a4a6a";
    mCtx.fillRect(centerX - gateWidth / 2, sdTop - 12, gateWidth, 12);
    mCtx.fillStyle = "#888";
    mCtx.font = "10px sans-serif";
    mCtx.fillText("SiO₂", centerX, sdTop - 2);

    // Gate (Poly)
    mCtx.fillStyle = "#b71c1c";
    mCtx.fillRect(centerX - gateWidth / 2, sdTop - 50, gateWidth, 38);
    mCtx.fillStyle = "#fff";
    mCtx.font = "bold 14px sans-serif";
    mCtx.fillText("Gate", centerX, sdTop - 26);

    // Halo 標籤
    mCtx.fillStyle = "#ff6666";
    mCtx.font = "11px sans-serif";
    mCtx.fillText("Halo (P+)", centerX - gateWidth / 2 + 15, sdTop + sdHeight + 10);
    mCtx.fillText("Halo (P+)", centerX + gateWidth / 2 - 15, sdTop + sdHeight + 10);

    // L 標示
    mCtx.strokeStyle = "#00e5ff";
    mCtx.lineWidth = 2;
    mCtx.setLineDash([4, 4]);
    mCtx.beginPath();
    mCtx.moveTo(centerX - gateWidth / 2, sdTop - 60);
    mCtx.lineTo(centerX + gateWidth / 2, sdTop - 60);
    mCtx.stroke();
    mCtx.setLineDash([]);

    // 箭頭
    mCtx.beginPath();
    mCtx.moveTo(centerX - gateWidth / 2, sdTop - 65);
    mCtx.lineTo(centerX - gateWidth / 2, sdTop - 55);
    mCtx.stroke();
    mCtx.beginPath();
    mCtx.moveTo(centerX + gateWidth / 2, sdTop - 65);
    mCtx.lineTo(centerX + gateWidth / 2, sdTop - 55);
    mCtx.stroke();

    mCtx.fillStyle = "#00e5ff";
    mCtx.font = "bold 13px sans-serif";
    mCtx.fillText(`L = ${L_nm} nm`, centerX, sdTop - 70);

    // 摻雜濃度剖面（底部小圖）
    const profileY = 290;
    const profileH = 50;
    const profileLeft = centerX - gateWidth / 2;
    const profileRight = centerX + gateWidth / 2;

    mCtx.strokeStyle = "#444";
    mCtx.lineWidth = 1;
    mCtx.beginPath();
    mCtx.moveTo(profileLeft, profileY + profileH);
    mCtx.lineTo(profileRight, profileY + profileH);
    mCtx.stroke();

    mCtx.strokeStyle = "#ff4444";
    mCtx.lineWidth = 2;
    mCtx.beginPath();
    for (let px = 0; px <= 60; px++) {
        const xNorm = px / 60;
        const xCanvas = profileLeft + xNorm * (profileRight - profileLeft);
        const doping = haloDoping(xNorm, L_nm);
        const yCanvas = profileY + profileH - (doping / 2.5) * profileH;
        if (px === 0) mCtx.moveTo(xCanvas, yCanvas);
        else mCtx.lineTo(xCanvas, yCanvas);
    }
    mCtx.stroke();

    mCtx.fillStyle = "#ff8888";
    mCtx.font = "10px sans-serif";
    mCtx.fillText("摻雜濃度剖面", centerX, profileY + profileH + 14);
}

// --- 繪製 Vth vs L 曲線 ---
function drawVthCurve(currentL) {
    const W = vthCanvas.width;
    const H = vthCanvas.height;
    vCtx.clearRect(0, 0, W, H);

    const pad = { top: 30, bottom: 50, left: 65, right: 30 };
    const plotW = W - pad.left - pad.right;
    const plotH = H - pad.top - pad.bottom;

    // 計算 Vth 範圍
    const lMin = 40, lMax = 500;
    let vthMin = 1, vthMax = 0;
    const points = [];
    for (let l = lMin; l <= lMax; l += 2) {
        const v = vthModel(l);
        if (v < vthMin) vthMin = v;
        if (v > vthMax) vthMax = v;
        points.push({ l, v });
    }
    vthMin = Math.floor(vthMin * 20) / 20 - 0.02;
    vthMax = Math.ceil(vthMax * 20) / 20 + 0.02;

    function toX(l) { return pad.left + ((l - lMin) / (lMax - lMin)) * plotW; }
    function toY(v) { return pad.top + (1 - (v - vthMin) / (vthMax - vthMin)) * plotH; }

    // 網格
    vCtx.strokeStyle = "#1e293b";
    vCtx.lineWidth = 1;
    for (let v = Math.ceil(vthMin * 10) / 10; v <= vthMax; v += 0.05) {
        const y = toY(v);
        vCtx.beginPath();
        vCtx.moveTo(pad.left, y);
        vCtx.lineTo(W - pad.right, y);
        vCtx.stroke();
    }
    for (let l = 100; l <= 500; l += 100) {
        const x = toX(l);
        vCtx.beginPath();
        vCtx.moveTo(x, pad.top);
        vCtx.lineTo(x, H - pad.bottom);
        vCtx.stroke();
    }

    // 軸
    vCtx.strokeStyle = "#555";
    vCtx.lineWidth = 2;
    vCtx.beginPath();
    vCtx.moveTo(pad.left, pad.top);
    vCtx.lineTo(pad.left, H - pad.bottom);
    vCtx.lineTo(W - pad.right, H - pad.bottom);
    vCtx.stroke();

    // 軸標籤
    vCtx.fillStyle = "#888";
    vCtx.font = "12px sans-serif";
    vCtx.textAlign = "center";
    for (let l = 100; l <= 500; l += 100) {
        vCtx.fillText(l, toX(l), H - pad.bottom + 18);
    }
    vCtx.fillText("L (nm)", W / 2, H - 8);

    vCtx.textAlign = "right";
    for (let v = Math.ceil(vthMin * 10) / 10; v <= vthMax; v += 0.05) {
        vCtx.fillText(v.toFixed(2), pad.left - 8, toY(v) + 4);
    }

    vCtx.save();
    vCtx.translate(14, H / 2);
    vCtx.rotate(-Math.PI / 2);
    vCtx.textAlign = "center";
    vCtx.fillText("Vth (V)", 0, 0);
    vCtx.restore();

    // 傳統 SCE 預期（虛線）— Vth 隨 L 縮短而下降
    vCtx.strokeStyle = "#555";
    vCtx.lineWidth = 1.5;
    vCtx.setLineDash([6, 4]);
    vCtx.beginPath();
    for (let i = 0; i < points.length; i++) {
        const l = points[i].l;
        const vSce = VTH0 - 0.08 * Math.exp(-l / 35); // 只有 SCE，無 RSCE
        const x = toX(l);
        const y = toY(vSce);
        if (i === 0) vCtx.moveTo(x, y);
        else vCtx.lineTo(x, y);
    }
    vCtx.stroke();
    vCtx.setLineDash([]);

    // 圖例 - 虛線
    vCtx.strokeStyle = "#555";
    vCtx.setLineDash([6, 4]);
    vCtx.beginPath();
    vCtx.moveTo(W - pad.right - 160, pad.top + 10);
    vCtx.lineTo(W - pad.right - 130, pad.top + 10);
    vCtx.stroke();
    vCtx.setLineDash([]);
    vCtx.fillStyle = "#777";
    vCtx.font = "11px sans-serif";
    vCtx.textAlign = "left";
    vCtx.fillText("傳統 SCE 預期", W - pad.right - 125, pad.top + 14);

    // 實際 RSCE 曲線（實線）
    vCtx.strokeStyle = "#00e5ff";
    vCtx.lineWidth = 2.5;
    vCtx.beginPath();
    for (let i = 0; i < points.length; i++) {
        const x = toX(points[i].l);
        const y = toY(points[i].v);
        if (i === 0) vCtx.moveTo(x, y);
        else vCtx.lineTo(x, y);
    }
    vCtx.stroke();

    // 圖例 - 實線
    vCtx.strokeStyle = "#00e5ff";
    vCtx.lineWidth = 2.5;
    vCtx.beginPath();
    vCtx.moveTo(W - pad.right - 160, pad.top + 28);
    vCtx.lineTo(W - pad.right - 130, pad.top + 28);
    vCtx.stroke();
    vCtx.fillStyle = "#00e5ff";
    vCtx.fillText("55nm 實際 (RSCE)", W - pad.right - 125, pad.top + 32);

    // 當前位置標記
    const curVth = vthModel(currentL);
    const cx = toX(currentL);
    const cy = toY(curVth);

    // 光暈
    const glow = vCtx.createRadialGradient(cx, cy, 0, cx, cy, 18);
    glow.addColorStop(0, "rgba(0, 229, 255, 0.4)");
    glow.addColorStop(1, "rgba(0, 229, 255, 0)");
    vCtx.fillStyle = glow;
    vCtx.fillRect(cx - 18, cy - 18, 36, 36);

    // 圓點
    vCtx.fillStyle = "#00e5ff";
    vCtx.beginPath();
    vCtx.arc(cx, cy, 6, 0, Math.PI * 2);
    vCtx.fill();
    vCtx.strokeStyle = "#fff";
    vCtx.lineWidth = 2;
    vCtx.stroke();

    // 數值標示
    vCtx.fillStyle = "#fff";
    vCtx.font = "bold 13px sans-serif";
    vCtx.textAlign = "left";
    const labelX = cx + 12;
    const labelY = cy - 12;
    vCtx.fillText(`Vth = ${curVth.toFixed(3)} V`, labelX, labelY);
}

// --- 更新資訊 ---
function updateInfo(L_nm) {
    const vth = vthModel(L_nm);
    const vthLong = vthModel(500);
    const delta = vth - vthLong;

    let html = "";
    if (L_nm < 80) {
        html = `<strong>L = ${L_nm} nm</strong> — 極短通道！Halo 口袋嚴重重疊。<br>
                V<sub>th</sub> = ${vth.toFixed(3)} V（比長通道高 <strong style="color:#ff4444">+${(delta * 1000).toFixed(0)} mV</strong>）<br>
                摻雜濃度劇增，RSCE 效應極為顯著。類比設計在此區域面臨嚴峻挑戰。`;
        infoBox.className = "info-box warning";
    } else if (L_nm < 150) {
        html = `<strong>L = ${L_nm} nm</strong> — Halo 口袋開始明顯重疊。<br>
                V<sub>th</sub> = ${vth.toFixed(3)} V（比長通道高 <strong style="color:#ffaa00">+${(delta * 1000).toFixed(0)} mV</strong>）<br>
                RSCE 效應顯著，V<sub>th</sub> 反常上升中。`;
        infoBox.className = "info-box warning";
    } else {
        html = `<strong>L = ${L_nm} nm</strong> — Halo 口袋分離，RSCE 較不明顯。<br>
                V<sub>th</sub> = ${vth.toFixed(3)} V（接近長通道值 ${vthLong.toFixed(3)} V）<br>
                此區域行為接近傳統預期。`;
        infoBox.className = "info-box normal";
    }
    infoText.innerHTML = html;
}

// --- 事件 ---
function render() {
    const L = parseInt(slider.value);
    lValueLabel.textContent = L;
    drawMOSFET(L);
    drawVthCurve(L);
    updateInfo(L);
}

slider.addEventListener("input", render);

// 初始渲染
render();
