# PLL-L49-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L49-P1.jpg

---


---
## Delay Locked Loops (DLL) 架構與雜訊分析

### 數學推導
本頁筆記主要推導 DLL 的 **輸入相位轉移函數** 以及 **延遲線(VCDL)的雜訊轉移函數**。

**1. DLL 輸入相位轉移函數 (Input Phase Transfer Function)：**
*   **目標**：找出 $\phi_{out}$ 與 $\phi_{in}$ 的關係。
*   **步驟**：
    *   從方塊圖可知，VCDL 的輸出相位 $\phi_{out}$ 等於輸入相位 $\phi_{in}$ 加上 VCDL 貢獻的相位延遲 $\Delta\phi_{VCDL}$：
        $$\phi_{out} = \phi_{in} + \Delta\phi_{VCDL}$$
    *   VCDL 的延遲量由控制電壓 $V_{ctrl}$ 決定：
        $$\Delta\phi_{VCDL} = V_{ctrl} \cdot K_{DL}$$
    *   控制電壓 $V_{ctrl}$ 是由 Phase Detector (PD)、Charge Pump (CP) 和迴路濾波電容 ($C$) 共同產生。PD 比較 $\phi_{in}$ 和 $\phi_{out}$ 的相位差，產生電流向電容充電：
        $$V_{ctrl} = (\phi_{in} - \phi_{out}) \cdot \frac{I_p}{2\pi} \cdot \frac{1}{sC}$$
    *   將 $V_{ctrl}$ 代回 $\phi_{out}$ 的方程式：
        $$\phi_{out} = \phi_{in} + (\phi_{in} - \phi_{out}) \cdot \frac{I_p}{2\pi} \cdot \frac{1}{sC} \cdot K_{DL}$$
    *   移項整理，將 $\phi_{in}$ 與 $\phi_{out}$ 集中：
        $$(\phi_{out} - \phi_{in}) = (\phi_{in} - \phi_{out}) \cdot \frac{I_p \cdot K_{DL}}{2\pi sC}$$
        $$(\phi_{out} - \phi_{in}) \left[ 1 + \frac{I_p \cdot K_{DL}}{2\pi sC} \right] = 0$$
    *   因為括號內不為 0，所以必然有：
        $$\phi_{out} = \phi_{in} \Rightarrow \frac{\phi_{out}}{\phi_{in}} = 1$$
    *   **結論**：對於輸入相位而言，DLL 是一個 All-pass filter（增益為 1），能完美追蹤輸入相位。

**2. VCDL 雜訊轉移函數 (VCDL Noise Transfer Function)：**
*   **目標**：評估 VCDL 本身產生的雜訊 $\phi_{DL}$ 如何影響輸出 $\phi_{out}$。
*   **步驟**：
    *   分析雜訊時，將輸入訊號設為 0 ($\phi_{in} = 0$)，並在 VCDL 引入加性雜訊 $\phi_{DL}$。
    *   新的迴路方程式變為：
        $$\phi_{out} = (0 - \phi_{out}) \cdot \frac{I_p}{2\pi} \cdot \frac{1}{sC} \cdot K_{DL} + \phi_{DL}$$
    *   移項整理提取 $\phi_{out}$：
        $$\phi_{out} \left( 1 + \frac{I_p \cdot K_{DL}}{2\pi sC} \right) = \phi_{DL}$$
    *   求得雜訊轉移函數：
        $$\frac{\phi_{out}}{\phi_{DL}} = \frac{1}{1 + \frac{I_p \cdot K_{DL}}{2\pi sC}} = \frac{sC}{sC + \frac{I_p \cdot K_{DL}}{2\pi}}$$
    *   上下同除以 $C$，整理成標準高通濾波器形式：
        $$\frac{\phi_{out}}{\phi_{DL}} = \frac{s}{s + \frac{I_p \cdot K_{DL}}{2\pi C}}$$
    *   定義迴路頻寬極點 $\omega_p = \frac{I_p \cdot K_{DL}}{2\pi C}$，則：
        $$\frac{\phi_{out}}{\phi_{DL}} = \frac{s}{s + \omega_p}$$
    *   **結論**：VCDL 雜訊呈現 **高通 (High-pass)** 特性。低頻雜訊會被迴路追蹤並消除，高頻雜訊則會直接傳遞到輸出。為了壓抑更多 VCDL 雜訊，必須提高轉折頻率 $\omega_p$。推導得知 $\omega_p \uparrow \Rightarrow C \downarrow, I_p \uparrow, K_{DL} \uparrow$。

### 單位解析
**公式單位消去：**
*   **控制電壓 $V_{ctrl}$ 單位消去：**
    $$V_{ctrl} = (\phi_{in} - \phi_{out}) \times K_{PD} \times Z_{filter}$$
    $$[V] = [\text{rad}] \times \left[\frac{\text{A}}{\text{rad}}\right] \times [\Omega]$$
    *(註：$K_{PD} = \frac{I_p}{2\pi}$，阻抗 $Z = \frac{1}{sC}$，電流 $\times$ 電阻/阻抗 = 電壓)*
*   **轉折頻率 $\omega_p$ 單位消去：**
    $$\omega_p = \frac{I_p \cdot K_{DL}}{2\pi C}$$
    $$[\text{rad/s}] = \frac{[\text{A}] \cdot [\text{rad/V}]}{[\text{rad}] \cdot [\text{F}]}$$
    由於法拉 $[\text{F}] = [\text{A \cdot s / V}]$，代入分母：
    $$= \frac{[\text{A/V}]}{[\text{A \cdot s / V}]} = \left[\frac{1}{\text{s}}\right] = [\text{rad/s}]$$

**圖表單位推斷：**
1. 📈 **CKin / CKout 時序波形圖 (左上)**：
   - X 軸：時間 $t$ [ns]，典型範圍 0~10 ns (依傳輸速率而定)
   - Y 軸：電壓 $V$ [V]，典型範圍 0~1V (數位邏輯準位)
2. 📈 **PD/CP 特性圖 $I_{out}$ vs $\Delta\phi$ (左下)**：
   - X 軸：相位差 $\Delta\phi$ [rad]，範圍 $-2\pi \sim 2\pi$
   - Y 軸：Charge Pump 輸出電流 $I_{out}$ [$\mu\text{A}$]，典型範圍 $\pm 100 \mu\text{A}$
3. 📈 **VCDL 特性圖 $\Delta\phi$ vs $V_{ctrl}$ (中上)**：
   - X 軸：控制電壓 $V_{ctrl}$ [V]，典型範圍 0~1V
   - Y 軸：延遲相位差 $\Delta\phi$ [rad]，斜率為 $K_{DL}$ [rad/V]
4. 📈 **輸入相位轉移函數圖 $|\frac{\phi_{out}}{\phi_{in}}|$ vs $\omega$ (中右)**：
   - X 軸：頻率 $\omega$ [rad/s] (對數尺度)
   - Y 軸：振幅增益比 [無單位]，數值恆為 1 (0 dB，水平直線)
5. 📈 **VCDL 雜訊轉移函數圖 $|\frac{\phi_{out}}{\phi_{DL}}|$ vs $\omega$ (右下)**：
   - X 軸：頻率 $\omega$ [rad/s] (對數尺度)
   - Y 軸：雜訊增益大小 [dB] 或 [無單位]，高通曲線，轉折點在 $\omega_p$

### 白話物理意義
DLL 是一個「只調延遲、不調頻率」的追蹤系統，它會強制把輸入時脈延遲「剛好一整個週期 (1 period)」，讓輸出看起來和輸入完全同相；因為它自己不主動產生頻率，所以其內部延遲線(VCDL)的雜訊只要變化不快（低頻），迴路就能馬上拉回來抵銷掉（呈現高通特性）。

### 生活化比喻
DLL 就像是一個「影子跟班（CKout）」跟著「大哥（CKin）」在操場跑步。
跟班**沒有自己的起步頻率**（無法倍頻），他只能調整自己的「起跑延遲時間（VCDL）」。迴路機制會強迫跟班不斷調整，直到他剛好「落後大哥整整一圈」，此時兩人經過起點的腳步看起來又是完全同步的。
如果跟班自己偶爾腿軟拖慢了腳步（VCDL Noise），只要腿軟是漸進式的（低頻），他馬上就會被大哥揪著耳朵拉回正確的相對位置；但如果是突然瞬間絆倒（高頻雜訊），大哥來不及反應，這種失誤就會直接表現出來。

### 面試必考點
1. **問題：DLL 與 PLL 最大的功能性與架構差異是什麼？**
   - 答案：DLL 使用 VCDL (電壓控制延遲線)，只能改變訊號的相位/延遲，無法改變頻率（即**不能做倍頻 Multiply Freq**）。PLL 使用 VCO (壓控振盪器)，會自己產生頻率並不斷累積相位，因此可以達成倍頻合成。此外，DLL 是一階系統，穩定度極高，不會有 PLL 常見的二階不穩定問題。
2. **問題：筆記中提到 DLL 可能遭遇 False Locking，這是什麼意思？**
   - 答案：因為時脈訊號是週期性的，DLL 迴路的目標只是讓「輸入和輸出相位對齊」。除了正確鎖定在 $1T$（一個週期延遲）之外，如果初始延遲範圍沒設好，它也有可能錯誤鎖定在延遲 $2T, 3T...$ 甚至是 $0.5T$（若 PD 設計不良）的狀態，這就是 False Locking。
3. **問題：在設計 DLL 時，如果發現 VCDL 貢獻的抖動 (Jitter) 太大，該如何調整迴路參數？**
   - 答案：VCDL 雜訊對輸出的轉移函數是高通濾波 $\frac{s}{s + \omega_p}$。要壓抑這項雜訊，必須把濾波器的阻擋範圍擴大，也就是**提高轉折頻率 $\omega_p$**。具體做法包含：減小濾波電容 ($C \downarrow$)、增加 Charge pump 電流 ($I_p \uparrow$) 或提高 VCDL 的增益 ($K_{DL} \uparrow$)。

**記憶口訣：**
> **DLL 像跟班：調相不調頻，一圈剛剛好 (1 period delay)。**
> **VCDL 雜訊是高通：要壓抑就得「寬」 (加大 $\omega_p$)，C 小 I 大 K 也要大！**
