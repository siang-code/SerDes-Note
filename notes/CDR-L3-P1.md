# CDR-L3-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L3-P1.jpg

---


---
## [主題名稱] PLL-based CDR 架構與 Single-FF 相位偵測器之限制

### 數學推導
筆記中探討了為何傳統 PLL 的 PFD 無法直接用於 CDR。我們從相位誤差的更新方程式來推導這件事：
在傳統 PLL 中，兩輸入皆為週期性 Clock，PFD 的輸出誤差信號 $e(t)$ 與相位差 $\Delta\phi$ 成正比：
$$ \overline{e(t)} = K_{PD} \cdot (\phi_{ref} - \phi_{vco}) $$

但在 CDR 系統中，輸入為隨機數據 (Random Data)，其轉態 (Transition) 的機率密度為 $P_T \le 1$（例如 PRBS31 的 $P_T \approx 0.5$）。
若使用如筆記中的 Single-FF PD，當沒有轉態時（Long runs，例如連續的 1111 或 0000），FF 的輸出 $Q$ 會維持在上一筆資料的狀態：
$$ Q[n] = Q[n-1] \quad \text{if no data transition} $$
這會導致 Charge Pump (CP) 失去比較基準，產生一個與當前實際相位差無關的恆定電流 $I_{CP}$（或 $-I_{CP}$），不斷對 Loop Filter 的電容 $C$ 積分：
$$ V_{ctrl}(t) = V_{ctrl}(t_0) \pm \frac{I_{CP}}{C} \cdot \Delta t_{run} $$
也就是說，在沒有轉態的期間，控制電壓會失控地往單一方向狂飆，導致 VCO 頻率大幅飄移。這正是筆記中強調「**Not transition, no comparison, no adjustment**」的原因，必須要有 Tri-state（三態：不充也不放）的設計才能避免「larger jitter」。

### 單位解析
**公式單位消去：**
- 控制電壓積分：$V_{ctrl} = \frac{1}{C} \int I_{CP} \, dt$
  $[V] = \frac{1}{[F]} \times [A] \times [s] = \frac{[V]}{[C]} \times [\frac{C}{s}] \times [s] = [V]$
  *(註：法拉 $F = C/V$ (庫侖/伏特)，安培 $A = C/s$)*
- 頻率偏移量：$\Delta f_{VCO} = K_{VCO} \cdot \Delta V_{ctrl}$
  $[Hz] = [\frac{Hz}{V}] \times [V] = [Hz]$

**圖表單位推斷：**
1. 📈 **Din 與 ck 波形圖 (左側)**
   - X 軸：時間 $t$ [$ps$]，典型範圍依資料率而定，例如 10 Gbps 系統約為 0~500 ps。
   - Y 軸：電壓幅度 $V$ [$V$]，典型邏輯準位範圍 0 ~ 1.0V (CMOS) 或更小擺幅 (CML)。
2. 📈 **Hysteresis (遲滯現象) 曲線圖 (右下角)**
   - X 軸：時間差 $\Delta t$ [$ps$] (Clock Edge 與 Data Edge 的相對時間差)，典型範圍 $\pm 10$ ps。
   - Y 軸：判決電壓或邏輯狀態，典型範圍 0 或 1。
   *(物理意義：當 clock edge 掃過 data edge 時，D-FF 由 0 翻轉到 1 的時機點，與由 1 翻轉回 0 的時機點不一致，形成遲滯區間，這等效於引入了 Phase Error)*

### 白話物理意義
CDR 就像瞎子摸象，只有在資料有「變化（0變1或1變0）」時，才知道時鐘是快還是慢；如果資料一直不變（長連續 0 或 1），系統就必須「裝死（Tri-state）」，不對時鐘做任何充放電調整，否則亂調一通只會讓 Jitter 爆表。

### 生活化比喻
想像你在黑夜中開車跟著前車（Data），但前車只有在踩煞車亮燈（Data Transition）時你才看得到他與你的距離。
**理想的 CDR (有 Tri-state)：** 看到前車煞車燈亮，你判斷太近就減速、太遠就加速。沒看到燈時，你就**維持定速**（Tri-state, 不踩油門也不踩煞車）。
**筆記中的 Single FF PD (無 Tri-state)：** 沒看到煞車燈時，你的腳會卡在油門（或煞車）上死踩不放！結果就是車速狂飆或急停（VCO 頻率亂飄，產生巨大 Jitter），等你下次看到燈亮時，早就偏離原本該有的距離了。

### 面試必考點
1. **問題：為什麼傳統 PLL 的 Type-IV PFD 不能直接用在 CDR 系統？**
   → 答案：Type-IV PFD 設計給兩個連續週期的 Clock 使用。CDR 的輸入是隨機資料 (Random Data)，缺乏規律的轉態邊緣 (Missing edges)。若資料長時間無轉態，PFD 會誤判為嚴重的頻率或相位誤差，導致迴路將 VCO 頻率推向極端值。
2. **問題：Single-FF PD 在面對長連續相同位元 (Long Runs) 時會發生什麼事？最大缺點是什麼？**
   → 答案：因為沒有 Tri-state 機制。當數據無轉態時，Single-FF 會保持前一個狀態，迫使 Charge Pump 持續單向對 Loop Filter 充放電。這會造成極大的 Control Voltage Ripple，進而產生巨大的 Jitter。
3. **問題：筆記中提到 D-FF 的 Hysteresis 會造成 Larger Jitter，其機制為何？**
   → 答案：Hysteresis 代表 D-FF 在判斷 0->1 與 1->0 時的 Setup/Hold 時間（或觸發門檻）不對稱。這會造成 Phase Detector 對「相位領先」與「相位落後」的決策邊界模糊，產生盲區 (Dead Zone) 或取樣點飄移，這些誤差最終都會直接轉換為 VCO 輸出的 Phase Jitter。

**記憶口訣：**
**CDR 沒轉態就裝死！** （無 Transition -> 必須 Tri-state -> 否則 Control Voltage 亂飆 -> Jitter 爆表）
