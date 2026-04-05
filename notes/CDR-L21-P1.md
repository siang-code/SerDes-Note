# CDR-L21-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L21-P1.jpg

---


---
## All-Digital BB-CDR 的 Capture Range 與 Loop Filter 階數分析

### 數學推導
本頁筆記探討全數位 Bang-Bang CDR 在面臨瞬間頻率跳變時的「鎖定範圍 (Capture Range)」，並比較了 DCO-based 與 PI-based 兩種架構下的數學差異。

**1. DCO-based All-Digital BB-CDR 的 Capture Range:**
- **架構特點：** 數位迴路濾波器 (DLF) 具有比例 ($k_1$) 與積分 ($k_2$) 路徑，兩者相加後的控制碼 $N_{ctrl}$ 直接控制 DCO 頻率。
- **數學推導：** 當發生瞬間的資料速率改變 (instant data-rate change) 時，積分器內的值來不及累積，系統的第一時間反擊 (instant boosting) 全靠比例路徑 $k_1$。
- **邊界條件：** BBPD 的最大輸出為 $\pm \frac{1}{2}$。要確保不發生 Cycle Slip，DCO 瞬間能跳變的最大頻率必須大於輸入的頻率誤差 $\Delta \omega$：
  $$|\Delta \omega| < \frac{1}{2} \cdot k_1 \cdot k_{DCO}$$

**2. PI-based CDR - 一階迴路 (1st-order DLF):**
- **架構特點：** PI (Phase Interpolator) 控制的是「相位」而非頻率。若 DLF 只有一個累加器 ($k_2$ 路徑)，迴路相當於對相位進行一階追蹤。
- **數學推導：** 每個 DLF 更新週期 ($T_{DLF}$) 內，累加器會增加 $\frac{1}{2} k_2$ (假設 BBPD 出 $+1/2$)。乘上 PI 的解析度 $k_{PI}$ 後，每個週期造成的相位變化為 $\Delta \phi = \frac{1}{2} \cdot k_2 \cdot k_{PI}$。
- **等效頻率：** 相位隨時間的變化率即為頻率 ($\Delta f = \Delta \phi / \Delta t$)，故等效頻率步階為：
  $$\Delta \omega_{eq} = \frac{\Delta \phi}{T_{DLF}} = \frac{k_2 \cdot k_{PI}}{2 T_{DLF}}$$
- **邊界條件：** 若要能「定速追上」頻率偏差，必須滿足：
  $$|\Delta \omega| < \frac{k_2 \cdot k_{PI}}{2 T_{DLF}}$$

**3. PI-based CDR - 二階迴路 (2nd-order DLF):**
- **架構特點：** 為了達到零穩態頻率誤差 (Zero Steady-State Error)，PI-based 架構必須使用含「兩個串聯累加器」的二階 DLF ($k_3$ 為一次累積，$k_4$ 為二次累積)。
- **連續時間近似 (Continuous-time approximation)：** 輸出的相位變化可寫成積分式：
  $$\phi_{out}(t) = k_{PI} \left[ \int \frac{k_3}{2 T_{DLF}} dt + \iint \frac{k_4}{T_{DLF}^2} dt dt \right]$$
- **多項式展開：**
  $$\phi_{out}(t) \approx \omega_0 t + \left( \frac{k_3 k_{PI}}{2 T_{DLF}} \right) t + \frac{1}{2} \left( \frac{k_4 k_{PI}}{T_{DLF}^2} \right) t^2$$
- **物理對應：**
  - **$t$ 的一次項 (速度)：** 由 $k_3$ 決定。在 $t \to 0$ 時，速度遠大於加速度，決定了「**能不能瞬間抓住**」而不掉失鎖定。
  - **$t^2$ 的二次項 (加速度/拋物線)：** 由 $k_4$ 決定。筆記強調「**若 $k_4$ 存在，才有拋物線，才能追上**」，這負責消除長期的穩態誤差。

### 單位解析
**公式單位消去：**
1. **DCO 瞬間跳變能力 $\Delta \omega_{boost} = \frac{1}{2} \cdot k_1 \cdot k_{DCO}$**
   - $k_1$: [LSB] (純數字，控制碼的變化量)
   - $k_{DCO}$: [rad/s / LSB] (DCO 的頻率增益)
   - $\frac{1}{2} \text{ [LSB]} \times k_1 \text{ [LSB]} \times k_{DCO} \text{ [rad/s / LSB]} = \text{[rad/s]}$ （吻合 $\Delta \omega$ 單位）

2. **PI 二階迴路相位方程式的拋物線項 $\frac{1}{2} \frac{k_4 k_{PI}}{T_{DLF}^2} t^2$**
   - $k_4$: [LSB]
   - $k_{PI}$: [rad / LSB] (PI 的相位階梯大小)
   - $T_{DLF}^2$: $[s^2]$
   - $t^2$: $[s^2]$
   - $\frac{\text{[LSB]} \times \text{[rad / LSB]}}{[s^2]} \times [s^2] = \text{[rad]}$ （精準吻合等式左邊 $\phi_{out}$ 的相位單位）

**圖表單位推斷：**
- 📈 **右上 DCO 轉移曲線圖：**
  - X 軸：控制碼 $N_{ctrl}$ [LSB]，典型範圍 0~1023 (10-bit)。
  - Y 軸：振盪頻率 $\omega_{DCO}$ [rad/s] 或 [GHz]，典型呈階梯狀 (Staircase)。
- 📈 **左下 1st-order DLF 追蹤圖：**
  - X 軸：時間 $t$ [s] 或 [UI]，以 $T_{DLF}$ 為更新步伐。
  - Y 軸：相位 $\phi(t)$ [rad] 或 [UI]。直線代表固定的頻率補償速度。
- 📈 **右下 2nd-order DLF 追蹤圖：**
  - X 軸：時間 $t$ [s] 或 [UI]。
  - Y 軸：相位 $\phi(t)$ [rad] 或 [UI]。紅色彎曲線表示具備 $t^2$ 項的拋物線加速度追蹤。

### 白話物理意義
DCO 天生會把頻率「積分」成相位，但 PI 不會；所以用 PI 做 CDR 時，如果 Loop Filter 只用一個累加器（一階），就像是「定速」去追前車，一開始落後太多就永遠追不到；必須用上兩個累加器（二階），才能給出「加速度」，只要時間夠長，拋物線追擊總能完美弭平頻率誤差。

### 生活化比喻
這就像是在國道上追捕超速的車輛（鎖定頻率）：
- **只有 Proportional ($k_1, k_3$)：** 看到目標瞬間，踩下一個固定深度的油門。如果對方沒有太快，你勉強咬得住距離；對方太快，你瞬間就被海放 (Cycle slip)。
- **一階迴路 (1st-order DLF, $k_2$)：** 定速巡航追趕。你設定時速 110 km/h 去追前車，如果前車開 120 km/h，你永遠追不到，這就是 Capture Range 受限。
- **二階迴路 (2nd-order DLF, $k_3+k_4$)：** 踩下油門 ($k_3$) 的同時，腳還「持續往下重踩」($k_4$)。這產生了加速度（拋物線），不管前車開多快，只要沒在第一時間讓你看不見車尾燈，你的速度不斷往上加，最終一定能精準地開在他旁邊（Zero Steady State Error）。

### 面試必考點
1. **問題：在 PI-based CDR 中，為什麼 Loop Filter 需要做到二階（兩個累加器），而 DCO-based 通常只需要一階？**
   - **答案：** 因為 DCO 輸出頻率，頻率對時間積分自然會變成相位，所以 DCO 本身自帶一階積分器效應；若加上一階 DLF 即可形成二階迴路。而 Phase Interpolator (PI) 輸出的是絕對相位，沒有積分效應，因此 Loop Filter 必須自己提供兩個累加器，才能建構出具備「頻率追蹤零穩態誤差」的二階相位迴路。
2. **問題：什麼參數決定了 All-Digital CDR 面對瞬間 Frequency Step 的 Capture Range？**
   - **答案：** 取決於比例路徑增益 (Proportional path, 筆記中的 $k_1$ 或 $k_3$) 以及 DCO/PI 的解析度。因為積分路徑在 $t=0$ 時來不及累積數值，防堵瞬間 Cycle Slip 全靠比例路徑的 instant boosting 能力。
3. **問題：在二階 PI-based CDR 的相位追蹤公式中，$k_3$ 和 $k_4$ 各扮演什麼數學與物理角色？**
   - **答案：** $k_3$（一次累加）對應 $t$ 的一次項，代表相位的「速度（頻率）」，主導 $t=0$ 瞬間的捕捉能力；$k_4$（二次累加）對應 $t^2$ 的二次項，代表相位的「加速度」，在穩態時主導拋物線追蹤，確保最終能消除頻率誤差 (Zero Steady-State Error)。

**記憶口訣：**
- **DCO 自帶一階、PI 缺水（積分）需自備兩階。**
- **瞬間咬住看 P (速度)，長遠零誤差靠 I (加速度)。**
- **$t$ 小看速度 ($k_3$)，$t$ 大看拋物線 ($k_4$)。**

---
*(※ 助教碎碎念：這裡的 PI (Phase Interpolator) 跟 PI 控制器 (Proportional-Integral) 縮寫一樣，面試時千萬不要搞混，講出來前要在腦中過一遍這個 PI 是在濾波器裡還是在輸出端！)*
