# PLL-L9-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L9-P1.jpg

---

---
## Reference Spur 與 Charge Pump 非理想效應 (Internal Skew & Current Mismatch)

### 數學推導
在一個鎖相迴路 (PLL) 中，若 Charge Pump (CP) 存在電流不匹配 (Current Mismatch, $\Delta I$)，為了維持鎖定狀態，迴路必須強迫產生一個靜態相位誤差 (Static Phase Error, $\Delta \phi$) 來補償。

1. **定義變數**：
   假設 UP 電流 $I_P = I_{CP} + \Delta I$，DOWN 電流 $I_N = I_{CP}$。
   PFD 的重置延遲時間 (Reset Delay) 為 $t_{reset}$。
2. **重置期間的錯誤電荷量 ($Q_{err}$)**：
   在 $t_{reset}$ 期間，UP 和 DOWN 開關同時導通，此時注入 Loop Filter 的淨電流為 $\Delta I$。
   每個週期產生的錯誤電荷量： 
   $$Q_{err} = (I_P - I_N) \times t_{reset} = \Delta I \times t_{reset}$$
3. **迴路補償機制的觸發**：
   為了讓穩態時的淨電荷量為零，迴路會逼迫 PFD 產生一個時間差 $\Delta t_{offset}$，讓 DOWN 信號比 UP 信號多開啟這段時間，以抽取等量的電荷。
   補償電荷量：
   $$Q_{comp} = -I_N \times \Delta t_{offset} = -I_{CP} \times \Delta t_{offset}$$
4. **穩態平衡方程式**：
   $$Q_{err} + Q_{comp} = 0$$
   $$\Delta I \times t_{reset} - I_{CP} \times \Delta t_{offset} = 0$$
   因此，靜態相位誤差的時間差為：
   $$\Delta t_{offset} = t_{reset} \times \frac{\Delta I}{I_{CP}}$$
5. **轉換為相位誤差 ($\Delta \phi$)**：
   $$\Delta \phi = 2\pi \times \frac{\Delta t_{offset}}{T_{ref}} = 2\pi \times f_{ref} \times t_{reset} \times \frac{\Delta I}{I_{CP}}$$
6. **Vctrl Ripple 產生**：
   這段額外的 $\Delta t_{offset}$ 充放電會經過 Loop Filter 的電阻 $R$ 與電容 $C_P$。若忽略 $C_P$ 積分效應，瞬間會在電阻上產生巨大的電壓突波 (Voltage Jump)：
   $$\Delta V_{ctrl} \approx I_{CP} \times R$$
   （若只考慮單純電容 $C_P$ 積分，則為 $\Delta V_{ctrl} = \frac{I_{CP} \times \Delta t_{offset}}{C_P}$）
   這個週期性的電壓漣波會調變 VCO，產生 Reference Spur。

### 單位解析
**公式單位消去：**
- **$Q_{err} = \Delta I \times t_{reset}$**
  $[C] = [A] \times [s]$
- **$\Delta t_{offset} = t_{reset} \times \left( \frac{\Delta I}{I_{CP}} \right)$**
  $[s] = [s] \times \left( \frac{[A]}{[A]} \right) = [s]$
- **$\Delta \phi = 2\pi \times f_{ref} \times \Delta t_{offset}$**
  $[rad] = [rad] \times [Hz] \times [s] = [rad] \times \left[\frac{1}{s}\right] \times [s] = [rad]$
- **$\Delta V_{ctrl} = I_{CP} \times R$**
  $[V] = [A] \times [\Omega] = [V]$

**圖表單位推斷：**
- 📈 **左上波形圖 ($QA, QB, V_{ctrl}$)**：
  - X 軸：時間 $[ns]$ 或 $[ps]$，典型範圍取決於 $f_{ref}$ (若 25MHz，週期為 $40ns$)。
  - Y 軸：邏輯電壓 $[V]$ (QA/QB)，控制電壓 $[V]$ ($V_{ctrl}$)，典型範圍 $0 \sim 1.2V$。
  - 另一 Y 軸：電流 $[\mu A]$ ($I_{out}$)，典型範圍 $\pm 100 \mu A$。
- 📈 **左中頻譜圖 (Spectrum)**：
  - X 軸：頻率 $[GHz]$ 或 $[MHz]$，中心為 $f_c$ (例如 10GHz)，兩側突波位於 $f_c \pm f_{ref}$ (例如 $10GHz \pm 25MHz$)。
  - Y 軸：相對功率密度 $[dBc]$ (相對於 Carrier 的分貝數)，典型範圍 $-40 \text{ dBc} \sim -80 \text{ dBc}$。
- 📈 **右下波形圖 (Current Mismatch)**：
  - X 軸：時間 $[ns]$ 或 $[ps]$。
  - Y 軸：邏輯電壓 $[V]$ (QA/QB)，電流 $[\mu A]$ ($I_{out}$)，控制電壓 $[V]$ ($V_{ctrl}$)。綠色與紅色斜線區塊代表電荷量 $[C]$（電流對時間的積分面積）。

### 白話物理意義
因為 Charge Pump 電流給得不平均或訊號有延遲，導致 PLL 每次在對位時都會「偷漏一滴電」，這滴電讓 VCO 頻率跟著週期性地抖一下，在頻譜上就長出了跟著參考時脈頻率出現的鬼影 (Spur)。

### 生活化比喻
想像你閉著眼睛開車 (VCO)，副駕 (PFD/CP) 每秒鐘看一次導航告訴你修正方向。但副駕是個結巴 (Mismatch/Skew)，每次講「直走」之前都會先不小心發出一個極短促的「左...」音。雖然你長期大方向是走直線的 (Phase Locked)，但方向盤每秒都會被你跟著扯一下，這個規律的抖動，讓你的車痕在主線道兩側留下了規律的蛇行軌跡，這就是 Reference Spur，而且還會吃線影響到旁邊車道的人 (影響隔壁通道 / Adjacent Channel Interference)。

### 面試必考點
1. **問題：Reference Spur 的三大成因是什麼？** 
   → **答案：** 1. Charge Pump 電流不匹配 (Current Mismatch) 導致的靜態相位誤差；2. PFD 到 CP 之間路徑延遲不一致 (Internal Skew)；3. 開關的 Clock Feedthrough 與 Charge Injection。以及 Loop Filter 的漏電流 (Leakage Current)。
2. **問題：如果把 PFD 的 Reset Delay Time 調短，對系統有什麼影響？** 
   → **答案：** Reset Delay 是為了消除 Dead Zone。如果調短，雖然可以減小 $\Delta t_{offset}$ 帶來的 $Q_{err}$ (因為 $Q_{err} = \Delta I \times t_{reset}$，時間越短漏的電越少，Spur 會改善)，但如果調太短導致 Dead Zone 重新出現，PLL 在相位誤差極小的時候會失去控制力，導致 VCO 的 Phase Noise 在低頻段大幅惡化。這是一個 Trade-off。
3. **問題：如何從電路架構上降低 Current Mismatch 導致的 Ref Spur？** 
   → **答案：** 筆記上寫了 "Channel-length mod." 是主因，代表 $V_{ctrl}$ 變動時會改變電流源的 $V_{DS}$。解法是：1. 增加電流源電晶體的長度 (L) 以提高輸出阻抗；2. 使用 Cascode 架構；3. 使用 Active Amplifier (OPA) 來強迫 UP 和 DOWN 電流源的 Drain 端電壓相等 (Active current matching)。

**記憶口訣：**
**「漏偏遲饋」 (老婆吃虧)**：**漏**電 (Leakage)、**偏**差 (Mismatch)、延**遲** (Skew)、回**饋** (Feedthrough) → 只要有這四個，PLL 的頻譜就會長出 Spur 讓你吃虧。
