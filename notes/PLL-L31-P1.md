# PLL-L31-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L31-P1.jpg

---


---
## 高速射頻除頻器 (Regenerative / Injection-Locked Divider) - 寄生電容消除與鎖定範圍擴展

### 數學推導
本頁筆記展示了兩種提升高頻除頻器 (Frequency Divider) 效能的進階電路技巧：**共振消除寄生電容**與**降低Q值擴展鎖定範圍**。

**1. 寄生電容共振消除 (Resonate out parasitic Cap)**
*   在電路圖 (中左) 中，輸入級 (M1, M2) 操作在輸入頻率 $\omega_{in}$，而交錯耦合對 (M3, M4) 操作在輸出頻率 $\omega_{out} = \omega_{in}/2$。
*   在 M1/M2 汲極與 M3/M4 源極的交界點，存在極大的寄生電容 $C_p$ (包含 M1的 $C_{gd}, C_{db}$ 及 M3的 $C_{gs}, C_{sb}$)。
*   在高頻下，注入電流 $I_{inj}$ 會大量流失到寄生電容中，導致混波效率下降。
*   加入差動電感 $L_3$ 跨接於兩節點之間。對於差動訊號，虛擬接地點在 $L_3$ 中心，等效單端電感為 $L_3/2$。
*   設計共振條件使之在輸入頻率 $\omega_{in}$ 發生共振：
    $$ \omega_{in} = \frac{1}{\sqrt{\frac{L_3}{2} \cdot C_p}} $$
*   在此頻率下，該節點的並聯阻抗趨近無限大，迫使高頻電流 $100\%$ 注入交錯耦合對 (M3, M4) 進行切換混波。

**2. 降低 Q 值以擴展鎖定範圍 (Q-degradation for wider locking range)**
*   在電路圖 (右下) 中，加入了 Diode-connected 的 M5, M6 並聯於 LC Tank。
*   根據 Adler's Equation，注入鎖定振盪器 (ILFD) 的鎖定範圍 $\Delta \omega$ 與 Tank Q 值成反比：
    $$ \Delta \omega \approx \frac{\omega_0}{2Q} \cdot \frac{I_{inj}}{I_{osc}} $$
*   LC Tank 原本的等效並聯電阻為 $R_p$。M5, M6 提供等效正電阻 $R_{diode} = \frac{1}{g_{m5,6}}$。
*   新的等效電阻 $R_p' = R_p // \frac{1}{g_{m5,6}}$。由於 $\frac{1}{g_m}$ 通常很小，$R_p'$ 會大幅下降。
*   因為 $Q = \frac{R_p'}{\omega_0 L}$，所以 Q 值下降，進而使鎖定範圍 $\Delta \omega$ 變寬 (enhance operating range)。
*   **自激振盪條件 (Self-resonance condition)：** 為了維持震盪，M3, M4 提供的負阻必須大於所有損耗。
    $$ |-g_{m3,4}| > \frac{1}{R_p'} = \frac{1}{R_p} + g_{m5,6} $$
    這解釋了筆記中強調的條件：**$\text{If } (W/L)_{3,4} > (W/L)_{5,6}$**，以確保負阻能力足夠。

### 單位解析
**公式單位消去：**
*   **LC 共振頻率：** $\omega = \frac{1}{\sqrt{L \cdot C}}$
    $$ \left[\text{rad/s}\right] = \frac{1}{\sqrt{[\text{H}] \cdot [\text{F}]}} = \frac{1}{\sqrt{\left[\frac{\text{V}\cdot\text{s}}{\text{A}}\right] \cdot \left[\frac{\text{A}\cdot\text{s}}{\text{V}}\right]}} = \frac{1}{\sqrt{[\text{s}^2]}} = [\text{s}^{-1}] \equiv [\text{rad/s}] $$
*   **Adler's 鎖定範圍：** $\Delta \omega = \frac{\omega_0}{2Q} \cdot \frac{I_{inj}}{I_{osc}}$
    $$ \left[\text{rad/s}\right] = \frac{[\text{rad/s}]}{[\text{無單位}]} \cdot \frac{[\text{A}]}{[\text{A}]} = [\text{rad/s}] $$

**圖表單位推斷：**
*   **左上角 Input Sensitivity (輸入靈敏度曲線)：**
    *   **X 軸：** 輸入頻率 $\omega_{in}$ [GHz]，典型範圍如 20 GHz ~ 60 GHz (視先進製程 SerDes 規格)。
    *   **Y 軸：** 輸入訊號振幅 Sensitivity [mVpp] 或 [dBm]，典型範圍 100~500 mVpp。
    *   **物理意義：** V字型曲線的谷底代表電路的自激振盪頻率，此處最容易被鎖定 (需要最小的輸入振幅)。曲線越寬，代表 Operating range (鎖定範圍) 越好。降低 Q 值會使這個 V 字型變得更平緩寬闊。

### 白話物理意義
**$L_3$ 的作用**就像是在塞車路段 (寄生電容) 上方建一座高頻專用高架橋，讓高速訊號 ($\omega_{in}$) 能順利抵達目的地；**M5/M6 Diode** 則是刻意把振盪器弄「笨」(降低 Q 值)，讓它不要太固執於自己的頻率，這樣外來的訊號才更容易牽著它走 (擴大鎖定範圍)。

### 生活化比喻
想像一個很有主見的固執歌手 (高 Q 值的振盪器)，你很難強迫他跟著你的節拍器 (注入訊號) 唱。如果你讓他喝點酒，降低他的固執程度 (加入 Diode 降低 Q 值)，他就比較容易被你的節拍帶走 (鎖定範圍變寬)。但是不能讓他喝太多 (必須確保 $(W/L)_{3,4} > (W/L)_{5,6}$)，否則他直接醉倒連聲音都發不出來了 (無法自激振盪)。

### 面試必考點
1.  **問題：在高速射頻除頻器中，為何常在 RF 輸入對與交錯耦合對之間加入電感 ($L_3$)？**
    *   **答案：** 為了在輸入頻率 $\omega_{in}$ 處與節點寄生電容產生 LC 共振 (Resonate out parasitic cap)。這能大幅提升該節點的阻抗，防止高頻注入電流被寄生電容旁路到地，從而最大化注入效率。注意：此處電感共振在 $\omega_{in}$，而上方的 LC Tank 共振在 $\omega_{in}/2$。
2.  **問題：為什麼 ILFD 為了擴大鎖定範圍，會刻意加入 Diode-connected MOS (M5, M6)？代價是什麼？**
    *   **答案：** Diode 提供 $1/g_m$ 的低阻抗，相當於在 Tank 並聯電阻以降低 Q 值 (Degradation)。根據 Adler's 方程式，低 Q 值能換取更寬的注入鎖定範圍。代價是 Phase Noise (相位雜訊) 會變差，且需要消耗更多電流來維持震盪。
3.  **問題：加入 M5, M6 降低 Q 值後，尺寸設計上有什麼嚴格限制？**
    *   **答案：** 必須確保核心交錯耦合對 (M3, M4) 產生的負電導 $g_{m3,4}$，足以抵銷 Tank 本身的損耗以及 M5, M6 帶來的正電導 $g_{m5,6}$。因此設計上必須滿足 $g_{m3,4} > g_{m5,6}$ (即 $(W/L)_{3,4} > (W/L)_{5,6}$)，以保證電路具備基本的自激振盪能力。

**記憶口訣：** 「加 L 消電容（高頻通），加 Diode 降 Q 擴範圍（寬頻通），負阻要比正阻大（才會動）。」
---
