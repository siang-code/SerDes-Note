# CDR-L14-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L14-P1.jpg

---


---
## DLL & PI-Based CDRs (基於延遲鎖定迴路與相位內插器之時脈資料回覆)

### 數學推導
本頁筆記主要分析兩種無振盪器（以參考時脈為基準）的 CDR 架構：**DLL-based CDR** 與 **PI-based CDR**。兩者的小訊號模型與轉移函數推導過程極為相似。

**1. DLL-based CDR 轉移函數推導：**
*   **Step 1：定義各方塊的小訊號行為**
    *   Phase Detector (PD) 與 Charge Pump (CP) 產生電流：$I_{CP} = (\phi_{in} - \phi_{out}) \cdot \frac{I_p}{2\pi}$
    *   Loop Filter (電容 C) 將電流轉為控制電壓：$V_{ctrl} = I_{CP} \cdot \frac{1}{sC} = (\phi_{in} - \phi_{out}) \cdot \frac{I_p}{2\pi sC}$
    *   Voltage-Controlled Delay Line (VCDL) 根據電壓調整輸出相位：$\phi_{out} = \phi_0 + K_{VCDL} \cdot V_{ctrl}$
*   **Step 2：閉迴路方程式代入**
    *   將 $V_{ctrl}$ 代入 VCDL 方程式中：
        $\phi_{out} = \phi_0 + (\phi_{in} - \phi_{out}) \cdot \frac{I_p \cdot K_{VCDL}}{2\pi sC}$
*   **Step 3：整理轉移函數**
    *   在小訊號分析中，將常數起始相位 $\phi_0$ 視為 0（或只看變動量 $\Delta\phi$）：
        $\phi_{out} = (\phi_{in} - \phi_{out}) \cdot \frac{I_p \cdot K_{VCDL}}{2\pi sC}$
    *   將含 $\phi_{out}$ 的項移到等式左邊並提出公因式：
        $\phi_{out} \cdot \left(1 + \frac{I_p \cdot K_{VCDL}}{2\pi sC}\right) = \phi_{in} \cdot \frac{I_p \cdot K_{VCDL}}{2\pi sC}$
    *   求得閉迴路轉移函數 $H(s)$：
        $\frac{\phi_{out}}{\phi_{in}} = \frac{\frac{I_p K_{VCDL}}{2\pi sC}}{1 + \frac{I_p K_{VCDL}}{2\pi sC}} = \frac{1}{1 + \frac{2\pi sC}{I_p K_{VCDL}}}$
    *   定義迴路頻寬 $\omega_{3dB} = \frac{I_p \cdot K_{VCDL}}{2\pi C}$，代入上式即得標準一階低通濾波器形式：
        $\frac{\phi_{out}}{\phi_{in}} = \frac{1}{1 + \frac{s}{\omega_{3dB}}}$

**2. PI-based CDR 轉移函數推導：**
*   推導過程完全相同 ("Same loop analysis")。只需將 VCDL 的增益 $K_{VCDL}$ 替換為 Phase Interpolator (PI) 的增益 $K_{PI}$。
*   轉移函數同樣為：$\frac{\phi_{out}}{\phi_{in}} = \frac{1}{1 + \frac{s}{\omega_{3dB}}}$，其中迴路頻寬 $\omega_{3dB} = \frac{I_p \cdot K_{PI}}{2\pi C}$。
*   這兩種架構在數學上都是「一階迴路 (First-order loop)」，因此具有「無條件穩定 (Unconditionally stable)」的特性。

### 單位解析
**公式單位消去：**
*   **Loop Bandwidth $\omega_{3dB}$：** $\omega_{3dB} = \frac{I_p \cdot K_{VCDL}}{2\pi C}$
    *   $I_p$ [A] (Charge Pump 峰值電流)
    *   $K_{VCDL}$ [rad/V] (VCDL 增益，每伏特產生多少弧度的相位平移)
    *   $C$ [F] = [A·s/V] (濾波電容)
    *   $2\pi$ [rad]
    *   代入單位：$\frac{[A] \times [rad/V]}{[rad] \times [A \cdot s/V]} = \frac{[A \cdot rad/V]}{[A \cdot s \cdot rad/V]} = \frac{1}{[s]} = [rad/s]$。成功消去得到角頻率單位。

**圖表單位推斷：**
*   📈 PD Transfer Curve (左下圖)：
    *   X 軸：輸入與輸出相位差 $\Delta\phi$ [rad]，典型範圍 $-2\pi$ ~ $+2\pi$
    *   Y 軸：平均輸出電流 $I_{av}$ [A] 或 [μA]，典型範圍 $-I_p$ ~ $+I_p$
*   📈 VCDL Transfer Curve (中圖)：
    *   X 軸：控制電壓 $V_{ctrl}$ [V]，典型範圍 0 ~ $V_{DD}$
    *   Y 軸：輸出相位平移 $\Delta\phi$ [rad] 或延遲時間 [ps]
*   📈 PI Transfer Curve (右下圖)：
    *   X 軸：控制電壓 $V_{ctrl}$ [V]（若是類比控制）或 Digital Code（數位 PI 控制碼）
    *   Y 軸：輸出相位平移 $\Delta\phi$ [rad] 或 [UI]（可以無限延伸旋轉）

### 白話物理意義
DLL-based CDR 是用一根「長度有限的伸縮桿」去對齊資料邊緣；而 PI-based CDR 是用一個「可以無限旋轉的羅盤」去對齊資料邊緣，因此 PI 能透過不斷旋轉來吃掉（追蹤）頻率誤差。

### 生活化比喻
*   **DLL-based CDR (牽繩溜狗)：** 想像你牽著一隻狗，狗（資料相位）往前跑，你就伸長手臂（Delay line）去配合牠。如果狗只是前後晃動（Phase Jitter），你手臂伸縮一下還能應付；但如果狗跑得比你走路的速度快（有 Frequency Error），你的手臂很快就會伸到極限（Tuning range 耗盡），狗就跑了（失去鎖定）。
*   **PI-based CDR (跑步機履帶)：** 想像你和狗站在一個沒有盡頭的跑步機履帶上（PI phase rotation）。如果狗跑得比較快，你可以讓履帶一直往後轉來抵銷速度差。只要履帶能一直轉（無限相位旋轉能力），就算有一點速度差（頻率誤差），你也永遠抓得住狗。

### 面試必考點
1. **問題：為什麼 DLL-based CDR 難以通過 SSC (Spread Spectrum Clocking) 測試？**
   → **答案：** DLL-based 的核心是 VCDL (Delay Line)，其延遲範圍是有限的（通常設計為涵蓋 > 1 bit period）。SSC 本質上是一種頻率調變（Frequency Error），會造成相位誤差隨時間不斷累積。當累積的相位差超過 VCDL 的物理調變極限時，迴路就會飽和並失去鎖定 (SSC fail -> EMI 很大)。

2. **問題：相對於 DLL，PI-based CDR 如何解決頻率誤差 (Frequency Error) 的問題？**
   → **答案：** PI (Phase Interpolator) 利用多個固定相位的參考時脈（如 I, Q 相位）進行內插。透過改變內插的權重，PI 的輸出相位可以「無限次數地旋轉 (Phase Rotation)」。相位的連續旋轉在物理意義上就等同於頻率偏移（$d\phi/dt = \Delta\omega$），因此 PI-based CDR 可以藉由持續旋轉來追蹤並容忍一定程度的頻率誤差（如 SSC）。

3. **問題：這兩種 CDR (僅有電容作為 Loop Filter) 在穩定性上的表現如何？為什麼？**
   → **答案：** 兩者都是「無條件穩定 (Unconditionally stable)」。從推導的轉移函數 $\frac{1}{1 + s/\omega_{3dB}}$ 可以看出，這是一個標準的「一階系統 (First-order loop)」。系統中只有一個極點，最大相位延遲只有 90 度，相位裕度 (Phase Margin) 極大，因此不會有震盪不穩定的問題。

**記憶口訣：**
「**延遲線有盡頭 (DLL)，內插器轉不休 (PI)；一階系統穩如狗。**」
