# LA-L6-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L6-P1.jpg

---


---
## 寬頻放大器技術：Shunt-Shunt 回授與 Darlington 降低米勒效應 (Broadband Amps & Miller Effect Reduction)

### 數學推導
本頁筆記探討如何利用特定的電路架構（如 Cherry-Hooper 或 Darlington 變形）來實現寬頻放大器 (Broadband Amp)，主要針對 **Shunt-Shunt Feedback (轉阻放大器 TIA 常見架構)** 進行分析。核心精神在於**打破高增益帶來的巨大米勒電容 (Miller Capacitance) 限制**。

**1. 轉壓增益 (Voltage Gain) 近似推導：**
觀察 Method IV 右側的 Darlington 變形架構（$Q_1$ 為 Emitter Follower，$Q_2$ 為 Common Emitter）：
*   **輸入端電壓 $V_{in}$**：
    令 $Q_1$ 基極交流小訊號電流為 $i$。則 $Q_1$ 射極電流為 $(1+\beta)i$。
    此電流全數灌入 $Q_2$ 基極，故 $Q_2$ 射極電流為 $(1+\beta)^2 i$。
    由歐姆定律，節點電壓等於電流乘上該處的等效電阻 (小訊號射極電阻 $r_e = 1/g_m$)：
    $V_{in} = v_{be1} + v_{be2} = (1+\beta)i \cdot \frac{1}{g_{m1}} + (1+\beta)^2 i \cdot \frac{1}{g_{m2}}$
    筆記中做了一個近似，若假設後級 $g_{m2}$ 的項為主導（或者 $\beta$ 很大時的簡化）：
    $V_{in} \approx (1+\beta)^2 \cdot i \cdot \frac{1}{g_{m2}}$  --- (Eq. 1)

*   **輸出節點 KCL (基爾霍夫電流定律)**：
    流出輸出節點的電流總和為零。流經 $R_C$ 的電流 + 流經 $R_F$ 的電流 + $Q_2$ 的集極電流 $I_{c2} = 0$。
    $I_{c2} \approx \beta I_{b2} = \beta (1+\beta)i \approx (1+\beta)^2 i$
    將 (Eq. 1) 代入，可得 $I_{c2} \approx g_{m2} V_{in}$。
    $\frac{V_{out}}{R_C} + \frac{V_{out} - V_{in}}{R_F} + g_{m2} V_{in} = 0$
    重新整理：
    $V_{out} \left( \frac{1}{R_C} + \frac{1}{R_F} \right) = V_{in} \left( \frac{1}{R_F} - g_{m2} \right)$
    在一般設計中，$g_{m2} \gg \frac{1}{R_F}$，故右式可近似為 $-g_{m2} V_{in}$：
    $V_{out} \left( \frac{R_F + R_C}{R_F R_C} \right) \approx -g_{m2} V_{in}$
    得電壓增益 $A_v$：
    $\frac{V_{out}}{V_{in}} \approx -g_{m2} (R_F // R_C)$

**2. 頻寬與極點 (Poles) 分析：**
*   **輸入等效電阻 $R_{in}$**：
    因 shunt-shunt 負回授，輸入阻抗被降低：
    $R_{in} \approx \frac{R_F}{1 - A_v} = \frac{R_F}{1 + g_{m2}(R_F // R_C)} \approx \frac{R_F}{g_{m2}(R_F // R_C)}$
*   **輸入極點 $W_{p1}$ (Input Pole)**：
    筆記核心在於：為何不用單一顆 CE 而要用 Darlington？
    如果是單級 CE，$C_{\mu}$ 會跨在輸入與輸出間，產生巨大的米勒電容 $C_{in} = C_\mu (1+|A_v|)$。此時輸入極點 $\tau_{in} = R_{in} \cdot C_{in} = \frac{R_F}{|A_v|} \cdot C_\mu |A_v| \approx R_F C_\mu$。頻寬被 $R_F C_\mu$ 寫死。
    **透過 Darlington (EF+CE) 架構：** $Q_1$ (EF) 的電壓增益接近 1，所以跨在 $Q_1$ 上的 $C_{\mu1}$ **沒有被米勒放大** (筆記云：電荷沒有充放電 $\Rightarrow C_{M1}$ negligible)。而高增益級 $Q_2$ 的米勒電容，則是看到前級 EF 極低的輸出阻抗 ($1/g_{m1}$)，使得該處的極點被推向極高頻。
    因此，打破了原本頻寬與增益的嚴重妥協，實現 **Broadband Amp**。
*   **輸出極點 $W_{p2}$ (Output Pole)**：
    由輸出節點的 RC 決定：
    $W_{p2} = \frac{1}{R_{out} \cdot C_L} = [ (R_F // R_C) \cdot C_L ]^{-1}$

### 單位解析
**公式單位消去：**
1.  **電壓增益 $A_v = -g_{m2} (R_F // R_C)$：**
    *   $g_{m2}$ (Transconductance): $[\text{A/V}]$
    *   $(R_F // R_C)$ (Resistance): $[\text{V/A}]$ 或 $[\Omega]$
    *   $A_v = [\text{A/V}] \times [\text{V/A}] = [1]$ (無因次，代表 $\text{V/V}$)
2.  **輸出極點 $\omega_{p2} = [ (R_F // R_C) \cdot C_L ]^{-1}$：**
    *   $R$ (Resistance): $[\text{V/A}]$
    *   $C_L$ (Capacitance): $[\text{F}] = [\text{C/V}] = [\text{A} \cdot \text{s/V}]$
    *   RC 時間常數 $\tau = [\text{V/A}] \times [\text{A} \cdot \text{s/V}] = [\text{s}]$ (秒)
    *   $\omega_p = 1/\tau = [1/\text{s}] = [\text{rad/s}]$ (角頻率單位)

**圖表單位推斷：**
*   本頁筆記為電路架構與數學推導，無 Y-X 關係圖表。

### 白話物理意義
在轉阻放大器中加入 Darlington (或緩衝級)，就像是在「輸入端」與「高增益輸出端」之間加了一道防火牆，隔離了原本會被無限放大的米勒寄生電容，讓電路能同時保有高增益與大頻寬。

### 生活化比喻
想像你要推動一扇極重的大門（高增益帶來的巨大米勒電容）。如果是單級放大器，就像你直接用手推，非常吃力且緩慢（頻寬低）。Darlington 架構就像是幫大門裝了「動力方向盤（緩衝級 $Q_1$）」，你輸入的手感變輕了（沒有米勒放大），而內部的機械結構幫你驅動沉重的大門，讓你推門的動作變得非常迅速（實現寬頻）。

### 面試必考點
1.  **問題：為什麼在高速 SerDes 的 TIA (Transimpedance Amp) 設計中，常看到 Cherry-Hooper 或 Darlington 架構？**
    *   **答案：** 單級 Shunt-Shunt TIA 的頻寬極限常被 $R_F \cdot C_\mu$ 限制（Pole-splitting 效應抵銷）。這類多級架構能提供阻抗隔離，將高增益節點的巨大米勒電容與高阻抗節點分開，顯著減輕輸入端的容性負載，推升整體頻寬 (Broadbanding)。
2.  **問題：請寫出 Shunt-Shunt 負回授放大器的輸入阻抗近似式，並說明其物理意義。**
    *   **答案：** $R_{in} \approx \frac{R_F}{1 + |A_{v, open-loop}|}$。物理意義是，因負回授機制的介入，任何灌入輸入端的電流都會被放大器瞬間抽走，使得該節點電壓變化極小，等效上看進去就是一個極低的阻抗。這對接收光電流等電流源訊號非常有利。
3.  **問題：在筆記的 Darlington 架構中，$C_{\mu1}$ 為何沒有嚴重的 Miller Effect？**
    *   **答案：** 因為 $Q_1$ 是射極隨耦器 (Emitter Follower) 配置，其電壓增益 $A_v \approx 1$。米勒等效電容 $C_{in,miller} = C_{\mu1}(1 - A_v) \approx 0$。雖然 $Q_2$ 有高增益與大米勒電容，但它看到的前級阻抗是 $Q_1$ 射極的低阻抗 ($1/g_{m1}$)，因此產生的極點頻率非常高。

**記憶口訣：**
**達林頓降米勒，一擋（阻抗隔離）二放（提供增益），頻寬跟著亮（Broadband）。**
