# CDR-L28-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L28-P1.jpg

---


---
## Bang-Bang CDR 的 Jitter Tolerance (JTOL) 理論極限與轉折頻率分析

### 數學推導
這頁筆記推導了基於 PLL 架構的 Bang-Bang CDR (BB-CDR) 其 Jitter Tolerance (JTOL) 的頻率響應曲線，這在高速 SerDes 設計中是核心概念。我們不跳步驟，把筆記中隱藏的代數還原：

1. **定義失效條件：**
   當 Phase Detector (PD) 取樣到 Data 的轉態邊緣 (edge) 時，表示已經跨越了 Eye 空間的一半，即發生錯誤。因此定義最大容許相位誤差為半個 Unit Interval：
   $$|\phi_{in} - \phi_{out}|_{max} = 0.5 \text{ UI}$$

2. **建立相位追蹤方程式：**
   假設輸入 Jitter 是一個弦波：$\phi_{in}(t) = \phi_{inp} \cos(W_\phi t + \delta)$，其中 $W_\phi$ 是 Jitter 頻率。
   BB-CDR 是一個非線性系統，其輸出相位 $\phi_{out}(t)$ 的變化率 (Slew Rate) 受限於 Proportional Path 產生的瞬間頻偏：$\Delta f = I_p R_p K_{vco}$。
   在最大相位誤差發生點 $t_0 \approx T_\phi/4$ 附近，輸入相位的斜率大小會逼近系統的等效 Slew Rate。筆記中引入了一個常數 $\pi/2$ (通常來自將方波近似為基頻弦波的係數轉換)，得到斜率匹配方程式：
   $$\frac{\pi}{2} I_p R_p K_{vco} = \phi_{inp} W_\phi \cos(\delta)$$
   移項可得：
   $$\cos(\delta) = \frac{\pi I_p R_p K_{vco}}{2 \phi_{inp} W_\phi}$$

3. **利用三角恆等式求最大誤差：**
   利用 $\sin(\delta) = \sqrt{1 - \cos^2(\delta)}$，將上式代入：
   $$\sin(\delta) = \sqrt{1 - \left(\frac{\pi I_p R_p K_{vco}}{2 \phi_{inp} W_\phi}\right)^2} = \frac{\sqrt{4 W_\phi^2 \phi_{inp}^2 - \pi^2 I_p^2 R_p^2 K_{vco}^2}}{2 \phi_{inp} W_\phi}$$
   *(註：筆記中 $\delta = \tan^{-1}(...)$ 就是從 $\sin/\cos$ 整理而來)*

   最大相位誤差大約發生在 $t = T_\phi/4$，此時 $\phi_{in}(T_\phi/4) = \phi_{inp} \cos(\pi/2 + \delta) = -\phi_{inp} \sin(\delta)$。取絕對值並令其等於 $0.5$ UI：
   $$\Delta\phi_{max} = \phi_{inp} \sin(\delta) = \frac{\sqrt{4 W_\phi^2 \phi_{inp}^2 - \pi^2 I_p^2 R_p^2 K_{vco}^2}}{2 W_\phi} \triangleq 0.5 \text{ UI}$$

4. **推導 JTOL 最終公式：**
   將上式兩邊平方，開始孤立 $\phi_{inp}$ (即 JTOL)：
   $$4 W_\phi^2 \phi_{inp}^2 - \pi^2 I_p^2 R_p^2 K_{vco}^2 = (2 W_\phi \cdot 0.5)^2 = W_\phi^2$$
   $$4 W_\phi^2 \phi_{inp}^2 = W_\phi^2 + \pi^2 I_p^2 R_p^2 K_{vco}^2$$
   同除以 $4 W_\phi^2$：
   $$\phi_{inp}^2 = \frac{1}{4} + \frac{\pi^2 I_p^2 R_p^2 K_{vco}^2}{4 W_\phi^2} = 0.25 \left( 1 + \frac{\pi^2 I_p^2 R_p^2 K_{vco}^2}{W_\phi^2} \right)$$
   開根號，即得到高頻段 JTOL 公式：
   $$JTOL = \phi_{inp, max} = 0.5 \sqrt{ 1 + \frac{\pi^2 I_p^2 R_p^2 K_{vco}^2}{W_\phi^2} }$$
   若定義 Corner Frequency $W_1 = \pi I_p R_p K_{vco}$ (或依筆記近似為 $\frac{I_p R_p K_{vco}}{0.5}$)，當 $W_\phi \gg W_1$ 時，JTOL 趨近於 0.5 UI。

5. **低頻效應 (第二轉折點 $W_2$)：**
   當 Jitter 頻率夠低 ($W_\phi < W_2$)，Loop Filter 的電容 $C_p$ 充放電時間不再能被忽略，系統行為從「電阻主導的 Slew Rate Limited」轉為「電容主導的積分追蹤」。此轉折點即為 Loop Filter 的 Zero：
   $$W_2 \approx \omega_z = \frac{1}{R_p C_p}$$
   在此頻率以下，JTOL 曲線斜率會變陡，達到 -40 dB/dec。

### 單位解析
**公式單位消去：**
* **Slew Rate 核心項：** $\Delta\omega = I_p \times R_p \times K_{vco}$
  * $I_p$ [A] (Charge Pump 電流)
  * $R_p$ [$\Omega$] = [V/A] (Proportional 電阻)
  * $K_{vco}$ [rad/s/V] 或 [Hz/V] (VCO 增益)
  * 單位消去：[A] $\times$ [V/A] $\times$ [rad/s/V] = **[rad/s]**。這表示頻率的偏移量，積分後即決定了相位能追趕的速度。

**圖表單位推斷：**
* 📈 **圖一 (單轉折 JTOL 曲線)：**
  - X 軸：Jitter 頻率 $W_\phi$ [rad/s] 或 [Hz]，對數尺度。
  - Y 軸：Jitter Tolerance (JTOL) 振幅 [UI]，典型範圍從高頻極限 0.5 UI 到低頻無限大。
* 📈 **圖二 (雙轉折 JTOL 曲線)：**
  - X 軸：Jitter 頻率 $W_\phi$ [rad/s]，對數尺度。標示了 $W_2$ 與 $W_1$。
  - Y 軸：JTOL 振幅 [UI] (通常以 dB 或對數尺度表示)。
  - 斜率標示：介於 $W_2$ 與 $W_1$ 間為 -20 dB/dec；低於 $W_2$ 為 -40 dB/dec。

### 白話物理意義
Bang-Bang CDR 的追蹤速度被 $I_p R_p K_{vco}$ 這個「極速」給卡死，只要輸入的 Jitter 抖得太快（高頻），CDR 來不及轉向，誤差累積超過半個眼圖寬度 (0.5 UI)，就會吃錯 Data。

### 生活化比喻
想像你開著一台方向盤轉向速度有物理極限的碰碰車 (BB-CDR)。如果前方的車 (Input Data) 左右蛇行得很慢，你可以輕鬆跟上他的軌跡；但如果前面的車蛇行頻率變快 (高頻 Jitter)，即使你方向盤永遠打到底也跟不上。只要你落後超過半個車身 (0.5 UI 誤差)，就會發生追撞 (Bit Error)。

### 面試必考點
1. **問題：在 Bang-Bang CDR 中，高頻的 JTOL 理論極限是多少？為什麼不能再高？**
   * **答案：** 理論極限是 0.5 UI (實務上因 PD 延遲可能略寬但視為 0.5)。因為 BB-PD 是 early/late 的硬判決，當 Jitter 變化太快 CDR 追不上時，只要 Data 邊緣相對於 Clock 偏移達到半個週期 (0.5 UI)，Clock 就會採樣到隔壁的 Bit 造成誤碼。
2. **問題：如果要提升 BB-CDR 的高頻追蹤能力 (把 $W_1$ 往右推)，可以調整哪些參數？會帶來什麼致命副作用？**
   * **答案：** 必須增加 Slew Rate $\Delta f = I_p R_p K_{vco}$，所以可以加大 $I_p$、$R_p$ 或 $K_{vco}$。但副作用是 Proportional Path 的瞬間電壓跳變 $\Delta V = I_p R_p$ 會變大，導致穩態時的 Clock 產生巨大的 Ripple 與 Jitter Generation。
3. **問題：JTOL 曲線在極低頻為什麼會出現 -40 dB/dec 的斜率？轉折點跟什麼有關？**
   * **答案：** 當 Jitter 頻率低於 Loop filter 的 Zero ($W_2 = 1/R_p C_p$) 時，積分電容 $C_p$ 的充放電效應主導，提供系統額外的 $1/s$ 積分能力。這使得 CDR 對相位的追蹤從一階 (Slew Rate 決定, -20dB/dec) 變為二階行為，JTOL 因此獲得更陡峭的 -40 dB/dec 提升。

**記憶口訣：** 高頻死守 0.5，中頻轉折看 IRK ($I_p R_p K_{vco}$)，低頻靠 C 衝 40 (-40dB/dec)。
