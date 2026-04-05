# CDR-L16-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L16-P1.jpg

---


---
## [全數位 Bang-Bang CDR 與相量內插器 (PI) 的迴路頻寬推導]

### 數學推導
本頁筆記主要推導「全數位 Bang-Bang CDR (搭配 Phase Interpolator, PI)」的等效迴路頻寬，並證明其與類比一階 Bang-Bang CDR 具有完美的數學等效性。

**Step 1: 定義相位變化率 (Phase Slew Rate)**
*   在全數位架構中，Bang-Bang Phase Detector (BBPD) 的平均輸出可視為 $N_{av} = \pm 1/2$。
*   數位迴路濾波器 (DLF) 每隔 $T_{DLF}$ 的時間更新一次。它將 $N_{av}$ 乘上增益 $k_2$ 並累加到暫存器中。因此，控制碼 $N_{ctr}$ 的變化率為 $\frac{\Delta N_{ctr}}{\Delta t} = \frac{1/2 \cdot k_2}{T_{DLF}}$。
*   相量內插器 (PI) 負責將數位控制碼轉換為輸出相位，其解析度為 $K_{PI}$。
*   綜合以上，系統輸出的最大相位追蹤斜率 (Phase Slew Rate) 為：
    $$slope = \frac{d\phi_{out}}{dt} = \frac{1/2 \cdot k_2}{T_{DLF}} \cdot K_{PI} = \frac{k_2 \cdot K_{PI}}{2 \cdot T_{DLF}}$$

**Step 2: 在弦波抖動 (Sinusoidal Jitter) 下的最大相位輸出**
*   當輸入存在頻率為 $\omega_\phi$、振幅為 $\phi_{in,p}$ 的弦波抖動時，若頻率夠快或振幅夠大，迴路會進入 Slew-Rate Limiting 狀態，輸出 $\phi_{out}$ 無法完美追隨弦波，而變成**三角波** (如左下圖示)。
*   三角波從 0 爬升到波峰所需的時間，剛好是輸入弦波週期的四分之一，即 $t = \frac{T_\phi}{4} = \frac{2\pi}{4\omega_\phi}$。
*   因此，數位迴路能產生的輸出相位峰值為：
    $$\phi_{out,p} = slope \times time = \left( \frac{k_2 \cdot K_{PI}}{2 \cdot T_{DLF}} \right) \times \left( \frac{2\pi}{4\omega_\phi} \right) = \frac{\pi \cdot k_2 \cdot K_{PI}}{4 \cdot \omega_\phi \cdot T_{DLF}}$$

**Step 3: 推導等效迴路頻寬 $\omega_{-3dB}$**
*   迴路頻寬 $\omega_{-3dB}$ 定義為「輸出相位峰值剛好等於輸入相位峰值」的邊界頻率，亦即 $\left|\frac{\phi_{out,p}}{\phi_{in,p}}\right| = 1$。
*   將 $\phi_{out,p}$ 代入並解出 $\omega_{-3dB}$：
    $$\left|\frac{\phi_{out,p}}{\phi_{in,p}}\right| = \frac{\pi \cdot k_2 \cdot K_{PI}}{4 \cdot \omega_\phi \cdot T_{DLF} \cdot \phi_{in,p}}$$
    $$\Rightarrow \omega_{-3dB} = \frac{\pi \cdot k_2 \cdot K_{PI}}{4 \cdot T_{DLF} \cdot \phi_{in,p}}$$

**Step 4: 類比與數位等效性映射 (Analog-Digital Equivalence)**
*   對於搭配 PI 的**類比一階 Bang-Bang 迴路**，其 Phase Slew Rate 為 $\frac{I_p \cdot K_{PI}}{C}$，其頻寬公式為 $\omega_{-3dB(analog)} = \frac{\pi \cdot I_p \cdot K_{PI}}{2 \cdot C \cdot \phi_{in,p}}$。
*   將數位的 Slew Rate $\frac{0.5 \cdot k_2}{T_{DLF}} \cdot K_{PI}$ 與類比比較，可得完美映射關係：
    令充放電電流 $I_p = 0.5$ ， 等效電容 $C = \frac{T_{DLF}}{k_2}$
*   將此映射代入類比公式驗證：
    $$\frac{\pi \cdot (0.5) \cdot K_{PI}}{2 \cdot \omega_\phi \cdot \left(\frac{T_{DLF}}{k_2}\right) \cdot \phi_{in,p}} = \frac{\pi \cdot k_2 \cdot K_{PI}}{4 \cdot \omega_\phi \cdot T_{DLF} \cdot \phi_{in,p}}$$
    證明兩者在數學行為上完全一致！

### 單位解析
**公式單位消去：**
*   以頻寬公式 $\omega_{-3dB} = \frac{\pi \cdot k_2 \cdot K_{PI}}{4 \cdot T_{DLF} \cdot \phi_{in,p}}$ 為例進行單位消去：
    *   $k_2$：數位濾波器增益，單位為 $[LSB/LSB]$ (無因次)
    *   $K_{PI}$：PI 解析度，單位為 $[rad/LSB]$ 或 $[UI/LSB]$
    *   $T_{DLF}$：數位濾波器更新週期，單位為 $[s]$
    *   $\phi_{in,p}$：輸入抖動振幅，單位為 $[rad]$ 或 $[UI]$
    *   $\pi$ 與 $4$：常數 (無因次)
    *   **消去過程**：$\frac{[1] \cdot [rad/LSB]}{[s] \cdot [rad]} = \frac{[rad]}{[LSB] \cdot [s] \cdot [rad]} \times [LSB \text{ (隱含於 } N_{av} \text{ 內)}] = \left[\frac{1}{s}\right] = [rad/s]$ (角頻率單位，正確無誤！)

**圖表單位推斷：**
*   📈 **圖一 (左中)：BBPD 轉移曲線 $N_{av}$ vs $\Delta\phi$**
    *   X 軸：相位誤差 $\Delta\phi$ $[UI]$ 或 $[rad]$，典型範圍 $\pm 0.5$ UI
    *   Y 軸：平均數位輸出 $N_{av}$ $[LSB]$，數值為 $+0.5$ 或 $-0.5$
*   📈 **圖二 (右中)：相位累加階梯圖 $\Delta\phi$ vs $t$**
    *   X 軸：時間 $t$ $[s]$ 或 更新次數 $[Step]$
    *   Y 軸：累積相位 $\Delta\phi$ $[UI]$ 或 $[rad]$，斜率為 $K_{PI}$
*   📈 **圖三 (左下)：Sinusoidal Jitter 追蹤圖 (Low speed / Fast)**
    *   X 軸：時間 $t$ $[s]$，典型範圍為抖動週期 $T_\phi$
    *   Y 軸：輸入與輸出相位 $\phi_{in}, \phi_{out}$ $[UI]$ 或 $[rad]$
    *   *現象*：在 High speed 時，$\phi_{out}$ 受限於 Slew Rate，無法維持弦波而變成三角波。
*   📈 **圖四 (中下)：Jitter Transfer (Bode Plot)**
    *   X 軸：抖動頻率 $\omega_\phi$ $[rad/s]$ 或 $[Hz]$ (Log Scale)
    *   Y 軸：相位轉移函數增益 $\left|\frac{\phi_{out}}{\phi_{in}}\right|$ $[dB]$
    *   *現象*：在 $\omega_{-3dB}$ 之後以 $-20$ dB/dec 斜率下降 (正比於 $1/\omega_\phi$)。

### 白話物理意義
全數位 Bang-Bang CDR 的「追蹤能力（頻寬）」受限於它每次只能跨出固定大小的步伐（Slew Rate Limit）；當目標（Jitter）晃動的幅度越大，CDR 就越容易追不上，導致能夠完美追隨的有效頻寬跟著縮小。

### 生活化比喻
想像你在玩「鬼抓人」，你被硬體設定成只能以「固定的跨步大小 ($K_{PI}$)」和「固定的步伐頻率 ($1/T_{DLF}$)」去追鬼。
如果鬼在小範圍內慢慢繞圈 (Low speed/small)，你可以輕鬆沿著他的軌跡跑，隨時緊跟；但如果鬼跑的圈子超大、速度又快 (Fast/large)，你因為有「最高跑速限制 (Slew Rate Limit)」，根本來不及畫圓，只能跑出一個折返跑的「三角形路線」。這個「最高跑速限制」決定了你能追上鬼的「極限頻寬」，且鬼跑的圈越大，你的頻寬就越小。

### 面試必考點
1. **問題：Bang-Bang CDR 的迴路頻寬是固定的嗎？為什麼？** 
   $\rightarrow$ 答案：不是。從公式 $\omega_{-3dB} \propto \frac{1}{\phi_{in,p}}$ 可知，頻寬與輸入抖動振幅成反比。這是因為 Bang-Bang Phase Detector 具有非線性（Slew Rate Limiting）特徵，輸入振幅越大，迴路越容易進入 Slew Rate 受限區，導致有效頻寬下降。
2. **問題：在 All-Digital 架構中，如何提升迴路頻寬？會付出什麼代價？** 
   $\rightarrow$ 答案：可以透過提升 DLF 增益 ($k_2$)、加大 PI 解析度步長 ($K_{PI}$)、或提高更新頻率 (降低 $T_{DLF}$) 來提升頻寬。代價是增加 $k_2$ 或 $K_{PI}$ 會讓每次追蹤的步伐變大，導致穩態鎖定時的相位誤差（Jitter Generation / Quantization Noise）變大。
3. **問題：如何將數位 BB-CDR 對應回傳統類比 Charge-Pump PLL 的分析模型？** 
   $\rightarrow$ 答案：類比的充放電電流 $I_p$ 可精準映射為數位的固定平均輸出（$0.5$）；類比的濾波電容 $C$ 則可對應為數位的 $\frac{T_{DLF}}{k_2}$。建立這個等效模型後，就能直接套用傳統類比 PLL 的線性化理論來評估數位 CDR 的穩定度與頻寬特性。

**記憶口訣：**
> **BB頻寬不固定，輸入越大頻寬縮；數位類比可等效，電容就是T除K。**

---
💡 **【費曼測試（自我驗證）】**
（當你覺得「我懂了」的時候，請嘗試回答以下攻擊問題）
- **反事實**：「如果把架構中的 PI (Phase Interpolator) 換成傳統的 DCO (Digital Controlled Oscillator)，這個推導的階數會發生什麼變化？還會是一階迴路嗎？」
- **情境遷移**：「這個 $1/\phi_{in,p}$ 導致頻寬下降的現象，在 PCIe Gen5 (32Gbps) 測試 Jitter Tolerance 時，會如何影響測試曲線（JTOL Curve）的形狀？」
- **禁語令**：「不准用『Slew Rate』和『非線性』這兩個詞，重新向文組主管解釋為什麼 Jitter 變大時 CDR 會追不上？」
