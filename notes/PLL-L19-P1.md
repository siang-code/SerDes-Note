# PLL-L19-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L19-P1.jpg

---


---
## [Leeson's Phase Noise Model (Linear Time-Invariant Feedback Approach)]

### 數學推導
這份筆記使用線性非時變 (LTI) 系統的迴授觀點，來推導振盪器中將元件白雜訊 (Device White Noise) 轉換為相位雜訊 (Phase Noise) 的轉移函數，這是 Leeson's Equation 的核心基礎。

1. **建立迴授模型：**
   將振盪器視為正迴授系統，閉迴路轉移函數為：
   $H(s) = \frac{Y}{X} = \frac{A}{1-A}$
   其中 $X$ 是輸入雜訊，$Y$ 是輸出，$A$ 是開迴路增益。

2. **泰勒級數展開 (Taylor Expansion)：**
   根據 Barkhausen Criterion，穩態振盪時 $\omega = \omega_o$，開迴路增益 $A(j\omega_o) = 1$。
   在中心頻率 $\omega_o$ 附近，對 $A(j\omega)$ 取一階泰勒展開（令頻率偏移 $\Delta\omega$ 極小）：
   $A(j\omega) \approx A(j\omega_o) + \frac{dA}{d\omega} \Delta\omega = 1 + \frac{dA}{d\omega} \Delta\omega$

3. **代入轉移函數：**
   將展開結果代入閉迴路轉移函數：
   $\frac{Y}{X} \approx \frac{A}{1 - (1 + \frac{dA}{d\omega}\Delta\omega)} \approx \frac{1}{-\frac{dA}{d\omega}\Delta\omega}$ 
   *(分子在 $\omega_o$ 附近近似為 $A \approx 1$)*

4. **取振幅平方 (Power Transfer Function)：**
   $|\frac{Y}{X}|^2 = \frac{1}{(\Delta\omega)^2 |\frac{dA}{d\omega}|^2}$

5. **解析 $\frac{dA}{d\omega}$ (將 $A$ 拆解為振幅與相位)：**
   令 $A = |A|e^{j\phi}$，對 $\omega$ 微分（Product Rule）：
   $\frac{dA}{d\omega} = \frac{d}{d\omega}(|A|e^{j\phi}) = e^{j\phi} \frac{d|A|}{d\omega} + |A| \cdot j \cdot e^{j\phi} \frac{d\phi}{d\omega}$
   
   **【代入中心頻率 $\omega_o$ 的邊界條件】**：
   - 相位為零：$\phi = 0 \implies e^{j\phi} = 1$
   - 振幅為一：$|A| = 1$
   - **振幅在共振點為峰值**，故其斜率（導數）為零：$\frac{d|A|}{d\omega} = 0$
   
   因此方程式大幅簡化為純虛數：
   $\frac{dA}{d\omega} = 0 + 1 \cdot j \cdot 1 \cdot \frac{d\phi}{d\omega} = j \frac{d\phi}{d\omega}$
   取絕對值平方：$|\frac{dA}{d\omega}|^2 = |\frac{d\phi}{d\omega}|^2$

6. **引入品質因數 $Q$：**
   定義諧振腔的品質因數 $Q$ 為相位對頻率變化的敏感度：
   $Q \triangleq \frac{\omega_o}{2} |\frac{d\phi}{d\omega}| \implies |\frac{d\phi}{d\omega}| = \frac{2Q}{\omega_o}$

7. **得出最終雜訊頻譜轉移函數：**
   代回第 4 步：
   $|\frac{Y}{X}|^2 = \frac{1}{(\Delta\omega)^2 (\frac{2Q}{\omega_o})^2} = \frac{\omega_o^2}{4Q^2 (\Delta\omega)^2}$
   這解釋了為何振盪器的雜訊頻譜在靠近 $\omega_o$ 時，會呈現與 $(\Delta\omega)^2$ 成反比的 $20\text{dB/decade}$ 衰減特性！

### 單位解析
**公式單位消去：**
- $\omega_o$ 與 $\Delta\omega$：角頻率 $[\text{rad/s}]$
- $\phi$：相位 $[\text{rad}]$
- $\frac{d\phi}{d\omega}$：相位對頻率的微分 $= \frac{[\text{rad}]}{[\text{rad/s}]} = [\text{s}]$
- $Q = \frac{\omega_o}{2} |\frac{d\phi}{d\omega}|$：$[\text{rad/s}] \times [\text{s}] = [\text{rad}]$ (實務上視為無因次純量 dimensionless ratio)
- $|\frac{Y}{X}|^2 = \frac{\omega_o^2}{4Q^2 (\Delta\omega)^2}$：$\frac{[\text{rad/s}]^2}{[\text{dimensionless}] \times [\text{rad/s}]^2} = [\text{dimensionless}]$ (電壓/電壓增益的平方)
- $S_Y(\omega) = |\frac{Y}{X}|^2 \cdot S_X(\omega)$：若輸入白雜訊為相位擾動 $[\text{rad}^2/\text{Hz}]$，乘上無因次轉移函數，輸出 Phase Noise 頻譜單位維持 $[\text{rad}^2/\text{Hz}]$。

**圖表單位推斷：**
📈 **Bode Plot of $A(j\omega)$ (中左圖)**
- **X 軸**：角頻率 $\omega$ $[\text{rad/s}]$
- **Y 軸 (上)**：開迴路振幅增益 $|A|$ $[\text{V/V}]$，在 $\omega_o$ 處峰值為 $1$
- **Y 軸 (下)**：開迴路相位 $\phi$ $[\text{Degree}]$，在 $\omega_o$ 處穿越 $0^\circ$（由 $+180^\circ$ 到 $-180^\circ$）

📈 **Noise Shaping Process (最下方三張小圖)**
- **圖一 (輸入元件雜訊 $S_X$)**：X 軸 $\omega$ $[\text{rad/s}]$，Y 軸 $S_X$ $[\text{rad}^2/\text{Hz}]$ (平坦的 White Noise，Flat Spectrum)
- **圖二 (轉移函數 $|\frac{Y}{X}|^2$)**：X 軸 $\omega$ $[\text{rad/s}]$，Y 軸 增益平方 $[\text{V}^2/\text{V}^2]$，呈現 $\frac{1}{\Delta\omega^2}$ 的帶通濾波形狀
- **圖三 (輸出 Phase Noise Spectrum)**：X 軸 $\omega$ $[\text{rad/s}]$，Y 軸 功率頻譜密度 $[\text{rad}^2/\text{Hz}]$ 或 $[\text{dBc/Hz}]$，為前兩圖相乘的結果，在 $\omega_o$ 兩側形成裙襬狀 (Skirt) 頻譜。

### 白話物理意義
振盪器就是一個「在中心頻率增益無限大」的濾波器，它會把平坦無聊的元件白雜訊，積分放大成圍繞在中心頻率兩側、隨頻率差平方 ($1/\Delta\omega^2$) 急劇衰減的「裙襬雜訊」(Phase Noise)。

### 生活化比喻
想像一個回音谷（高 Q 值的 LC Tank 共振腔），你在裡面發出各種頻率的白噪音（Device noise），但山谷只對特定的頻率 $\omega_o$ 產生共鳴。離這個共鳴點越近的雜音，被放大的倍數就越誇張；離共鳴點越遠（$\Delta\omega$ 變大），回音就依照距離的平方快速衰減。這就是為什麼輸出頻譜在中心點附近會長得像一件裙子。

### 面試必考點
1. **問題：在 LC VCO 中，為什麼靠近中心頻率的 Phase Noise 是以 20dB/dec ($1/f^2$) 的斜率衰減？**
   → 答案：因為振盪器在閉迴路中等效於一個「完美的積分器」。根據 Leeson's model 迴授推導，開迴路增益在中心頻率為 1，閉迴路轉移函數泰勒展開後會與頻率偏移的平方 $(\Delta\omega)^2$ 成反比，將平坦的白雜訊塑造成 $1/f^2$ 的形狀。
2. **問題：推導過程中，為什麼可以將 $\frac{d|A|}{d\omega}$ 視為 0？這在電路上代表什麼？**
   → 答案：因為在穩態振盪的共振頻率 $\omega_o$ 下，LC Tank 的並聯阻抗達到極大值，開迴路增益 $|A|$ 達到峰值。在數學上，極大值處的斜率（一階導數）必為零。這代表電路對振幅變化的敏感度降到最低。
3. **問題：根據這個推導公式，要如何降低 VCO 的 Phase Noise？**
   → 答案：由 $|\frac{Y}{X}|^2 = \frac{\omega_o^2}{4Q^2 (\Delta\omega)^2}$ 可知，Phase Noise 與 $Q^2$ 成反比。因此必須最大化諧振腔的品質因數 $Q$（例如使用更好的電感）。$Q$ 值越高，相位對頻率的斜率 $|\frac{d\phi}{d\omega}|$ 越陡峭，濾除雜訊的能力就越強，Phase noise 的裙襬也就越窄。

**記憶口訣：**
泰勒展開找斜率，振幅平坦微為零；
Q高相陡裙襬窄，白噪積分變頻偏。
