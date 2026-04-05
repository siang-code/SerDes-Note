# CDR-L6-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L6-P1.jpg

---


---
## Hogge Phase Detector (線性相位偵測器) 的架構與非理想效應

### 數學推導
Hogge PD 的核心概念是產生兩個脈衝：一個與相位誤差成正比的脈衝 (X)，以及一個固定寬度的參考脈衝 (Y)。我們來推導其轉移函數與增益 $K_{pd}$。

1. **定義變數：**
   - 假設系統為 Full-Rate (全速率)，時脈週期為 $T_{clk}$，即 1 UI = $T_{clk}$。
   - 最佳取樣點：時脈上升沿對準 Data Eye 的正中央。此時，Data 轉態到 Clock 上升沿的時間差 $\Delta t = T_{clk}/2$。
   - $X$ 脈衝 (Up)：寬度 $W_X = \Delta t$（Data 轉態到 Clock 上升沿）。
   - $Y$ 脈衝 (Down)：寬度 $W_Y = T_{clk}/2$（Clock 上升沿到下降沿，由 DFF2 的 falling-edge 觸發決定）。

2. **電荷幫浦 (Charge Pump) 充放電推導：**
   - 每發生一次 Data 轉態，CP 注入 Loop Filter 的淨電荷為：
     $Q_{net} = I_{cp} \cdot W_X - I_{cp} \cdot W_Y$
     $Q_{net} = I_{cp} \cdot (\Delta t - \frac{T_{clk}}{2})$
   - 定義相位誤差 $\Delta \theta$ (以弧度表示)：完整週期 $T_{clk}$ 對應 $2\pi$。
     $\Delta \theta = (\Delta t - \frac{T_{clk}}{2}) \cdot \frac{2\pi}{T_{clk}}$
     可推得：$(\Delta t - \frac{T_{clk}}{2}) = \Delta \theta \cdot \frac{T_{clk}}{2\pi}$
   - 代入淨電荷公式：
     $Q_{net} = I_{cp} \cdot \left( \Delta \theta \cdot \frac{T_{clk}}{2\pi} \right)$

3. **平均電流與 PD 增益 ($K_{pd}$) 推導：**
   - 輸出平均電流 $I_{avg}$ 取決於 Data 轉態密度 (Transition Density, $D_T$)。假設 Data Data Rate 為 $R_b = 1/T_{clk}$，每秒平均有 $D_T \cdot R_b$ 次轉態。
   - $I_{avg} = Q_{net} \cdot (D_T \cdot R_b) = Q_{net} \cdot \frac{D_T}{T_{clk}}$
   - 將 $Q_{net}$ 代入：
     $I_{avg} = \left( I_{cp} \cdot \Delta \theta \cdot \frac{T_{clk}}{2\pi} \right) \cdot \frac{D_T}{T_{clk}} = \frac{I_{cp} \cdot D_T}{2\pi} \cdot \Delta \theta$
   - 得到 Hogge PD 的增益 $K_{pd}$：
     $K_{pd} = \frac{I_{avg}}{\Delta \theta} = \frac{I_{cp} \cdot D_T}{2\pi}$

### 單位解析
**公式單位消去：**
- $Q_{net} = I_{cp}[A] \cdot W_X[s] = [C]$ (庫侖)
- $I_{avg} = Q_{net}[C] \cdot D_T[\text{無單位}] / T_{clk}[s] = [C/s] = [A]$ (安培)
- $K_{pd} = I_{avg}[A] / \Delta \theta[rad] = [A/rad]$ (安培/弧度)
*(助教碎碎念：不要小看 $D_T$，這代表 Linear PD 的頻寬會跟著你送進來的 Data Pattern 變動！這是系統穩定度的隱患！)*

**圖表單位推斷：**
1. **波形圖 (右上)：**
   - X 軸：時間 $t$ [$ps$]
   - Y 軸：邏輯電壓 [$V$] 或 $V_{ctrl}$ 電壓 [$V$]
2. **PD Char. (左下轉移曲線)：**
   - X 軸：相位誤差 $\Delta \phi$ [$rad$]，典型範圍 $-\pi$ 到 $\pi$ (對應 $\pm 0.5$ UI)
   - Y 軸：輸出平均電流 $I_{avg}$ [$A$]
   - *(紅線為理想線性，藍線在原點處塌陷，對應筆記的「pulse 沒辦法產生那麼小」)*
3. **Hogge PD Op. Range (右下頻寬/範圍圖)：**
   - X 軸：Data Rate [$Gbps$]，典型範圍 10~20 Gbps。
   - Y 軸：可運作的線性相位範圍 [$rad$]，最高為 $2\pi$。隨著速度提升，邏輯閘延遲佔 UI 比例變大，線性區間急遽縮小。

### 白話物理意義
Hogge PD 利用「Data 變換到 Clock 邊緣的時間差」當作變動的充電(X)，和「半個 Clock 週期」當作固定的放電(Y)，藉由這兩者的拔河來判斷 Clock 現在是太快還是太慢。

### 生活化比喻
這就像是計件打工的「彈性工時扣款系統」。
- **X 脈衝 (Up)：** 代表你「提早到的時間（每次不同）」，老闆會給你加薪。
- **Y 脈衝 (Down)：** 代表公司規定的「固定休息時間（固定半小時）」，會扣你薪水。
如果提早到的時間剛好等於休息時間，你的總薪水不變（系統 Lock）。但如果你太晚到（提早的時間太短，對應 $\Delta \phi \approx 0$），因為打卡系統太老舊反應不過來（邏輯閘 Rise/Fall time 限制，無法產生極窄脈衝），老闆連算錢都懶得算，這就是筆記中提到的高速下「死區 (Dead Zone)」問題。

### 面試必考點
1. **問題：為什麼在高速 (如 10Gbps+) SerDes 中，Hogge PD 容易失效而被 Bang-Bang PD 取代？**
   → **答案：** Hogge PD 需要產生寬度與相位誤差成正比的脈衝 (X)。在高速下 1 UI 很小（例如 10Gbps 下 1 UI = 100ps），而一般邏輯閘的 FO4 rise/fall time 就佔了 20~30ps。當相位誤差接近 0 時，要求產生幾 ps 的極窄脈衝，電路根本推不到 Full Swing 就掉下來了（即筆記中的 "Impossible to produce very narrow pulses"），這會造成嚴重的非線性與 Dead Zone。

2. **問題：筆記中提到 "$V_{ctrl}$ 上有 ripple"，這是怎麼產生的？對 VCO 有何影響？**
   → **答案：** 即使在 Phase Lock 狀態下（淨電荷為 0），Hogge PD 的 X (Up) 和 Y (Down) 脈衝是在時間上**依序**發生的，而不是同時發生互相抵消。這會導致 Charge Pump 先對 Loop Filter 充電再放電，在 $V_{ctrl}$ 上形成三角波漣波 (Triwave Ripple)。高頻的 Ripple 會被 Filter 濾除，但 Data-dependent 的低頻成分會調變 VCO，產生 Data-dependent Jitter (或 Spurs)。

3. **問題：Hogge PD 的增益 ($K_{pd}$) 受到什麼因素影響？對 CDR 架構設計有什麼挑戰？**
   → **答案：** $K_{pd}$ 與資料轉態密度 (Transition Density, $D_T$) 成正比。這代表如果輸入的 Data 出現連續的 0 或 1 (長 0/1)，$K_{pd}$ 會下降，導致整個 CDR Loop Bandwidth 變窄，Damping Factor 也會改變，嚴重影響系統的穩定度。

**記憶口訣：**
Hogge 的痛：**窄脈生不出**（高頻死區）、**先後充放有漣波**（Ripple/Jitter）、**增益吃傳輸密度**（$K_{pd} \propto D_T$）。
