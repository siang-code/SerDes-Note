# TIA-L7-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/TIA-L7-P1.jpg

---


---
## Feedback TIA 頻率響應與二階效應分析

### 數學推導

本頁筆記分為兩大部分：第一部分是低頻（Low frequency）時 Feedback TIA 的基本小訊號模型分析；第二部分是高頻（Higher frequency）時，考慮放大器頻寬與輸入寄生電容所造成的二階系統（2nd-order system）效應。

#### 一、 低頻特性分析 (小訊號模型)
假設放大器具有有限轉導 $G_m$ 與輸出阻抗 $R_{out}$，回授電阻為 $R_F$。

**1. 跨阻增益 $R_T$ (Transimpedance Gain)**
在輸入節點 $V_{in}$ 列 KCL（克希荷夫電流定律）：
$$I_{in} + \frac{V_{out} - V_{in}}{R_F} = 0 \implies I_{in} = \frac{V_{in} - V_{out}}{R_F} \implies V_{in} = V_{out} + I_{in} R_F$$

在輸出節點 $V_{out}$ 列 KCL：
$$\frac{V_{out} - V_{in}}{R_F} + G_m V_{in} + \frac{V_{out}}{R_{out}} = 0$$
將上面得到的 $\frac{V_{out} - V_{in}}{R_F} = -I_{in}$ 與 $V_{in}$ 帶入：
$$-I_{in} + G_m(V_{out} + I_{in} R_F) + \frac{V_{out}}{R_{out}} = 0$$
$$V_{out} \left( G_m + \frac{1}{R_{out}} \right) = I_{in} (1 - G_m R_F)$$
同乘 $R_{out}$ 整理可得閉迴路跨阻增益：
$$R_T = \frac{V_{out}}{I_{in}} = \frac{-R_{out}(1 - G_m R_F)}{1 + G_m R_{out}}$$
在低頻且放大器增益極大時（$G_m R_F \gg 1, G_m R_{out} \gg 1$），可化簡為：
$$R_T \approx \frac{-R_{out}(-G_m R_F)}{G_m R_{out}} = -R_F$$

**2. 輸入阻抗 $R_{in}$**
$$R_{in} = \frac{V_{in}}{I_{in}} = \frac{V_{out} + I_{in} R_F}{I_{in}} = \frac{V_{out}}{I_{in}} + R_F = R_T + R_F$$
將 $R_T$ 確切公式帶入：
$$R_{in} = \frac{-R_{out} + G_m R_{out} R_F + R_F + G_m R_{out} R_F}{1 + G_m R_{out}} \quad (\text{筆記直接化簡形式：})$$
$$R_{in} = \frac{R_F(1 + \frac{R_{out}}{R_F})}{R_{out}(\frac{1}{R_{out}} + G_m)} \approx \frac{1}{G_m} \quad (\text{@ low f, 假設 } G_m \text{ 夠大})$$

**3. 輸出阻抗 $R_{out, closed}$**
將輸入端開路（Open），從輸出端打入測試電壓 $V_t$，量測流入電流 $I_t$。
因為輸入開路，沒有電流流過 $R_F$，所以 $V_{in} = V_t$。
在輸出節點列 KCL：
$$I_t = G_m V_{in} + \frac{V_t}{R_{out}} = G_m V_t + \frac{V_t}{R_{out}} = V_t \left( G_m + \frac{1}{R_{out}} \right)$$
$$R_{out, closed} = \frac{V_t}{I_t} = \frac{1}{G_m + \frac{1}{R_{out}}} = \frac{1}{G_m} || R_{out} \approx \frac{1}{G_m} \quad (\text{@ low f})$$

#### 二、 高頻二階效應分析 (考慮 $C_{in}$ 與 Op-amp 極點)
將輸入節點加上寄生電容 $C_{in}$，並將放大器模型改為單極點模型：$A(s) = \frac{A_0}{1 + s/\omega_0}$。
定義輸入端時間常數對應的頻率：$\omega_i \triangleq \frac{1}{C_{in} R_F}$（筆記註明：這只是單純定義，無實際物理意義，因為 $C_{in}$ 與 $R_F$ 並不是直接並聯）。

閉迴路增益經過 KCL 運算（如上文將 $1/R_F$ 擴充為 $1/R_F + sC_{in}$）可得：
$$R_T(s) = \frac{-R_F A_0 \omega_0 \omega_i}{s^2 + (\omega_0 + \omega_i)s + (A_0 + 1)\omega_0 \omega_i}$$

將其對應到標準二階系統轉移函數 $\frac{K_1}{s^2 + (\frac{\omega_n}{Q})s + \omega_n^2}$：
1. **自然共振頻率 $\omega_n$**：
   $$\omega_n^2 = (A_0 + 1)\omega_0 \omega_i \approx A_0 \omega_0 \omega_i$$
   因為增益頻寬積 $GBW = A_0 \omega_0$，所以：
   $$\omega_n^2 \approx GBW \cdot \omega_i \implies \omega_n = \sqrt{GBW \cdot \omega_i}$$
2. **品質因數 $Q$**：
   $$\frac{\omega_n}{Q} = \omega_0 + \omega_i \implies Q = \frac{\omega_n}{\omega_0 + \omega_i}$$
   由於通常放大器主極點 $\omega_0$ 遠小於 $\omega_i$，且 $\omega_i < GBW$，可近似 $\omega_0 + \omega_i \approx \omega_i$：
   $$Q \approx \frac{\sqrt{GBW \cdot \omega_i}}{\omega_i} = \sqrt{\frac{GBW}{\omega_i}}$$

**Peaking (頻率響應峰值) 分析：**
二階系統當 $Q > \frac{1}{\sqrt{2}} \approx 0.707$ 時，頻域會出現 Peaking。
- 峰值發生頻率：$\omega_{max} = \omega_n \sqrt{1 - \frac{1}{2Q^2}}$
- 峰值大小：$|R_T|_{peak} = \frac{R_F \cdot Q}{\sqrt{1 - \frac{1}{4Q^2}}}$
- **結論**：筆記中提到 "$Bandwidth \ extends \ in \ a \ cost \ of \ Peaking$"。也就是說，當我們選用極高 GBW 的放大器時，雖然能把 TIA 的整體頻寬 $\omega_n$ 推高，但因為 $Q \propto \sqrt{GBW}$，$Q$ 值也會跟著暴增，導致嚴重的 Peaking 與時域 Ringing。

### 單位解析
**公式單位消去：**
1. $\omega_i = \frac{1}{C_{in} R_F}$
   - $[\frac{1}{F \cdot \Omega}] = [\frac{1}{s}] = [\text{rad/s}]$（頻率）
2. $\omega_n^2 = GBW \cdot \omega_i$
   - $[rad/s] \times [rad/s] = [rad^2/s^2]$
   - 開根號後 $\omega_n$ 單位為 $[rad/s]$。
3. $Q = \sqrt{\frac{GBW}{\omega_i}}$
   - $\sqrt{\frac{[rad/s]}{[rad/s]}} = \sqrt{1} = \text{無因次 (Dimensionless)}$，符合 $Q$ 值的物理定義。

**圖表單位推斷：**
1. **Opamp 增益 Bode Plot (左中)**：
   - X 軸：頻率 $f$ 或 $\omega$ [rad/s]，對數尺度。典型範圍：$10^3 \sim 10^{10}$ rad/s。
   - Y 軸：增益大小 $|A|$ [dB]。標示了低頻增益 $A_0$ 與 $-20 \text{ dB/dec}$ 的滾降斜率，交點為 $GBW$。
2. **TIA 跨阻增益 Bode Plot (左下)**：
   - X 軸：頻率 $\omega$ [rad/s]，對數尺度。
   - Y 軸：跨阻大小 $|R_T|$ [dB$\Omega$] 或以對數表示的歐姆值。圖中清楚標示出在 $\omega_{max}$ 處產生 Peak Value，高頻處以 $-40 \text{ dB/dec}$ 衰減（因為是二階系統）。
3. **s-plane 極零點圖 (右中)**：
   - X 軸：實部 $\sigma$ [rad/s]。標示為 $-\frac{\omega_n}{2Q}$。
   - Y 軸：虛部 $j\omega$ [rad/s]。共軛複數極點距離原點的半徑為 $\omega_n$。

### 白話物理意義
Feedback TIA 在高頻時，因為「輸入端寄生電容」跟「放大器本身反應變慢（有限頻寬）」互相扯後腿，讓整個電路變成一個會「晃動」的二階系統；你想要讓 TIA 頻寬越寬，就必須用極高頻寬的放大器，但代價是系統會變得「欠阻尼（$Q$ 值過高）」，導致高頻訊號被過度放大（Peaking）。

### 生活化比喻
想像你在騎一台裝有避震器的越野腳踏車（TIA 電路）。
路面上的連續小碎石代表「高頻訊號與輸入電容效應」。為了追求最快的反應速度（延伸系統頻寬 $\omega_n$），你把避震器換成超級硬的彈簧（極高的 GBW）。結果就是：反應變快了，但只要輾過一個坑洞，車子就會劇烈上下彈跳好幾下無法立刻平息（這就是頻域的 Peaking / 時域的 Ringing）。「頻寬的延伸是拿彈跳（Peaking）換來的」。

### 面試必考點
1. **問題：在 Feedback TIA 中，輸入電容 $C_{in}$ 會導致什麼問題？系統變成幾階？**
   - **答案**：$C_{in}$ 會與 $R_F$ 及放大器的有限頻寬（單極點）交互作用，使 TIA 從理想的一階系統降級成「二階系統」。
2. **問題：TIA 的 $Q$ 值與放大器增益頻寬積 (GBW) 有何關係？會造成什麼現象？**
   - **答案**：$Q \approx \sqrt{GBW / \omega_i}$。GBW 越大，TIA 頻寬 $\omega_n$ 雖會增加，但 $Q$ 值也隨之變大。當 $Q > 1/\sqrt{2}$ 時，頻域會出現 Peaking，在時域會產生 Ringing（振鈴），嚴重影響眼圖的 ISI (Inter-Symbol Interference)。
3. **問題：請解釋 "Bandwidth extends in a cost of Peaking" 在 TIA 設計中的意義。**
   - **答案**：我們無法無限制地靠推高放大器的 GBW 來增加 TIA 頻寬。因為 $Q \propto \sqrt{GBW}$，追求過高頻寬的代價是系統阻尼不足（Peaking），通常需要額外加入回授電容 $C_F$ 來產生 Phantom Zero (虛零點) 進行補償，壓制 $Q$ 值。

**記憶口訣：**
「高頻變二階，GBW 換頻寬，代價是 Peaking，Q大就狂震」
