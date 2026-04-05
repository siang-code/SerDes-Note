# CDR-L9-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L9-P1.jpg

---


---
## 相位偵測器比較與 Bang-Bang PD 特性分析 (Phase Detectors & BBPD Characteristics)

### 數學推導
1. **理想 BBPD (Bang-Bang Phase Detector) 的非線性行為**：
   在理想情況下，BBPD 的輸出電流 $I_{out}$ 僅根據相位差 $\Delta \phi$ 的極性來決定早或晚，呈現符號函數 (Signum Function) 的硬性非線性：
   $$I_{out} = I_p \cdot \text{sgn}(\Delta \phi)$$

2. **實際 SHA-based BBPD 的線性區推導**：
   由於真實高速資料信號有有限的轉態時間 (Data transition time, $t_r$)，信號邊緣並非垂直。
   當取樣時脈 (Clock) 的邊緣落在資料轉態的斜坡上時，Sample-and-Hold Amplifier (SHA) 取樣到的電壓 $V_{sample}$ 會與時間誤差 $\Delta t$ 近似成正比：
   $$V_{sample} \approx \text{Slew Rate} \times \Delta t = \left( \frac{V_{swing}}{t_r} \right) \cdot \Delta t$$
   將時間差換算為相位差 $\Delta \phi = \omega_{data} \cdot \Delta t$：
   $$V_{sample} \approx \frac{V_{swing}}{t_r \cdot \omega_{data}} \cdot \Delta \phi$$
   接著，取樣電壓經過增益為 $A$ 的放大器，以及跨導為 $g_m$ 的 V/I 轉換器 (Charge Pump)：
   $$I_{out} = g_m \cdot A \cdot V_{sample} = \left( g_m \cdot A \cdot \frac{V_{swing}}{t_r \cdot \omega_{data}} \right) \cdot \Delta \phi$$
   因此，在 $|\Delta \phi| < \phi_m$ （$\phi_m$ 對應於信號轉態時間所佔的相位寬度）區間內，PD 不再是非黑即白，而是表現出線性增益 $K_{PD}$：
   $$K_{PD} = \frac{\partial I_{out}}{\partial \Delta \phi} = g_m \cdot A \cdot \frac{V_{swing}}{t_r \cdot \omega_{data}}$$
   這在數學上嚴謹解釋了筆記中 "Linear Region $\approx$ Data transition time" 的物理現象。

### 單位解析
**公式單位消去：**
- $I_{out}$ 線性區推導：$g_m[\text{A/V}] \times A[\text{V/V}] \times V_{swing}[\text{V}] \times \frac{1}{t_r[\text{s}] \times \omega_{data}[\text{rad/s}]} \times \Delta \phi[\text{rad}]$
  $= [\text{A/V}] \times [1] \times [\text{V}] \times \frac{1}{[\text{rad}]} \times [\text{rad}]$
  $= [\text{A}]$
- 線性區 PD Gain ($K_{PD}$)：$K_{PD} = \frac{\Delta I_{out}}{\Delta \phi} = \frac{[\text{A}]}{[\text{rad}]} = [\text{A/rad}]$

**圖表單位推斷：**
📈 **圖表一 (SHA-based BBPD Transfer Curve 轉移曲線)**：
- X 軸：相位誤差 $\Delta \phi$ [UI] 或 [rad]，典型範圍 $\pm 0.5$ UI。線性區界線 $\pm \phi_m$ 對應資料的轉態時間，大約在 $\pm 0.1$ UI 到 $\pm 0.15$ UI 之間。
- Y 軸：平均輸出電流 $I_{out}$ [μA]，典型範圍如 $\pm 50\mu\text{A}$ ($I_P$ 與 $-I_P$)。

📈 **圖表二 (DFF-based BBPD Transfer Curve 轉移曲線與 Dead Zone)**：
- X 軸：相位誤差 $\Delta \phi$ [UI] 或 [rad]，典型範圍 $\pm 0.5$ UI。Dead zone 死區範圍取決於 DFF 速度，約 $\pm 0.05$ UI (對應幾皮秒的 setup/hold time 限制)。
- Y 軸：平均輸出電流 $I_{out}$ [μA]。當相位差太小落入死區時，DFF 進入亞穩態或無法判斷，輸出電流為 0 或呈隨機雜訊，無法正確給出控制方向。

### 白話物理意義
Bang-Bang PD 表面上是個「非黑即白」的二元開關，但因為現實世界的電壓沒辦法瞬間切換（具有轉態斜坡），當我們剛好在斜坡上取樣時，它就變成了一個「會看程度給分」的線性 PD；相反地，如果用一般 D 觸發器來做 BBPD，它反應不夠快，相位差太小時它會「眼殘」看不出來，這就形成了討人厭的死區 (Dead Zone)。

### 生活化比喻
BBPD 就像一個只會喊「太快！」或「太慢！」的粗魯田徑教練。
- **SHA-based BBPD**：這教練有稍微好一點的動態視力，如果你剛好在及格線前後一點點（信號轉態期間內），他會依據你差多少而微調口氣喊「快一點點」或「慢一點點」（這就是線性區）。
- **DFF-based BBPD**：這個教練反應比較遲鈍，只要你的誤差小於 0.1 秒（Setup/Hold time 極限），他就看不出差別，乾脆什麼都不說。這就是「死區 (Dead Zone)」，這時候你得不到任何回饋只能盲目瞎跑（導致 Jitter 變大）。

### 面試必考點
1. **問題：在高速 SerDes 中，為何常選擇 Bang-Bang PD 而非 Linear PD (如 Hogge)？有什麼系統層面的代價？**
   → **答案：** BBPD 為純數位化輸出，電路結構簡單，在極高頻 (High-speed) 運作下容易實現且耗電面積較小。代價是它屬於強非線性系統，行為分析困難（Jitter performance 是 Input-dependent 的），會產生特有的 pattern-dependent jitter 以及 limit cycle；且通常需要很大的 Loop Filter 電容（常需 off-chip），並必須額外搭配 Frequency Detector (FD) 才能順利鎖定頻率。
2. **問題：BBPD 轉移曲線上的 Linear Region 是怎麼來的？寬度由誰決定？**
   → **答案：** 來自於真實 Data 訊號具有非零的轉態時間 (Finite Transition Time)。當 Clock 取樣點恰好落在 Data 的轉態斜坡上時，取樣到的電壓值會與相位差成正比，經過後級放大與 V/I 轉換後，在巨觀平均下形成了一段線性區。此區間寬度 $\phi_m$ 大約等於 Data 的 transition time ($t_r$)。
3. **問題：用單純的 D-Flip Flop 實現 BBPD 時，為什麼會產生 Dead Zone？它對 CDR 的抖動 (Jitter) 表現有何影響？**
   → **答案：** Dead Zone 是由 DFF 內在的 Setup Time 與 Hold Time 限制，以及亞穩態 (Metastability) 引起的。當 Clock 與 Data 邊緣過於接近，DFF 無法解析出明確的高低電位。這會導致 CDR 迴路在相位誤差極小的時候失去增益 ($K_{PD}=0$)，迴路無法及時糾正相位微小漂移，進而大幅增加系統的 Deterministic Jitter (DJ) 甚至導致眼圖閉合。

**記憶口訣：**
BBPD 特性：「轉態生線性，Setup死區停；高速非線性，大C外掛行」
---
