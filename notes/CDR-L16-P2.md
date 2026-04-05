# CDR-L16-P2

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L16-P2.jpg

---


---
## 全數位 Bang-Bang CDR 與相位插值器 (All-Digital BBCDR w/ PI) 的 Slew Rate 與 Jitter Tolerance 解析

### 數學推導
這張筆記的核心在推導**當 Bang-Bang CDR (BBCDR) 配上 Phase Interpolator (PI) 時，因為 Slew Rate Limit 造成的 Jitter Tracking 物理限制**。我們不跳步驟，一步步拆解李老師的推導：

**1. 數位迴路濾波器 (DLF) 的轉移函數拆解**
觀察左上的 Block Diagram，輸入訊號為 $N_{in}$（BBPD 輸出的 Early/Late 訊號，值為 $\pm1$）。
*   **下層積分路徑 (Integral Path)：** 經過增益 $k_4$ 後，進入一個由加法器與 $z^{-1}$ 構成的累加器。其轉移函數為 $\frac{k_4 \cdot z^{-1}}{1 - z^{-1}}$。
*   **上層比例路徑 (Proportional Path)：** 經過增益 $k_3$。
*   **總累加輸出：** 上層與下層的結果相加後，再共同進入第二個累加器（外圍的加法器與上方的 $z^{-1}$）。
因此，總轉移函數為：
$$ \frac{N_{out}}{N_{in}} = \frac{z^{-1}}{1 - z^{-1}} \left( k_3 + \frac{k_4 \cdot z^{-1}}{1 - z^{-1}} \right) = \frac{k_3 \cdot z^{-1}}{1 - z^{-1}} + \frac{k_4 \cdot z^{-2}}{(1 - z^{-1})^2} $$

**2. 離散 (Z-domain) 轉 連續 (S-domain) 近似**
為了推導物理頻寬，我們將 Z 轉換用泰勒展開式退化為 S 轉換。假設取樣頻率很高（$sT_{DLF} \ll 1$）：
$$ z^{-1} = e^{-sT_{DLF}} \approx 1 - sT_{DLF} $$
$$ \Rightarrow 1 - z^{-1} \approx sT_{DLF} $$
代入轉移函數：
$$ \frac{N_{out}}{N_{in}} \approx \frac{k_3 (1-sT_{DLF})}{sT_{DLF}} + \frac{k_4 (1-sT_{DLF})^2}{(sT_{DLF})^2} \approx \frac{k_3}{sT_{DLF}} + \frac{k_4}{s^2 T_{DLF}^2} $$
**⚠️ 關鍵結論：** 在類比 PLL 中，Charge Pump + R 是一次積分 ($1/s$)，加上 VCO 內部相位積分 ($1/s$) 形成二階迴路。但在這裡，**PI (Phase Interpolator) 直接輸出相位，缺乏積分能力**。所以 DLF 必須自己負擔「雙重積分 ($1/s^2$)」的責任，才能維持二階迴路追頻率的能力。

**3. Slew Rate 限制與最大可追蹤相位振幅 ($\phi_{out,p}$)**
當輸入極大的弦波 Jitter 時，BBPD 追不上，會呈現「Slew Rate 限幅」，持續輸出 $+1$。我們計算這段連續 $+1$ 時間（半個 Jitter 週期 $T_p/2 = \pi/\omega_p$）內，CDR 能吐出的最大相位變化量 $\Delta \phi_{pp}$。
連續時間下的積分式：
$$ \phi_{out}(t) = K_{PI} \cdot N_{out}(t) = K_{PI} \left[ \int \frac{k_3}{T_{DLF}} dt + \iint \frac{k_4}{T_{DLF}^2} dt dt \right] $$
從 $0$ 積分到 $\pi/\omega_p$。而最大振幅 $\phi_{out,p}$ 是峰對峰值 $\Delta \phi_{pp}$ 的一半（筆記中前方的 $\frac{1}{2}$ 來源於此）：
$$ \phi_{out,p} = \frac{1}{2} K_{PI} \left[ \frac{k_3}{T_{DLF}} \left(\frac{\pi}{\omega_p}\right) + \frac{k_4}{2 T_{DLF}^2} \left(\frac{\pi}{\omega_p}\right)^2 \right] $$
$$ \Rightarrow \phi_{out,p} = \frac{\pi \cdot K_{PI} \cdot k_3}{4 \cdot \omega_p \cdot T_{DLF}} + \frac{\pi^2 \cdot K_{PI} \cdot k_4}{8 \cdot \omega_p^2 \cdot T_{DLF}^2} $$
這就是這張筆記最核心的 Jitter Tracking 邊界方程式！

**4. 轉角頻率 $\omega_1$ 與等效頻寬 $\omega_{-3dB}$**
*   **找零點 $\omega_1$：** 當比例路徑（$-20$dB/dec）與積分路徑（$-40$dB/dec）貢獻相等時，即為轉角頻率：
    $$ \frac{\pi K_{PI} k_3}{4 \omega_1 T_{DLF}} = \frac{\pi^2 K_{PI} k_4}{8 \omega_1^2 T_{DLF}^2} \Rightarrow \omega_1 = \frac{\pi \cdot k_4}{2 \cdot T_{DLF} \cdot k_3} $$
    對應類比的 $\omega_z = 1/RC$。
*   **找頻寬 $\omega_{-3dB}$（紅框處）：** 當處於低頻、積分路徑主導（$-40$dB/dec）且剛好達到輸入振幅極限 $\phi_{in,p}$ 時：
    $$ \phi_{in,p} \approx \frac{\pi^2 K_{PI} k_4}{8 \omega_{-3dB}^2 T_{DLF}^2} \Rightarrow \omega_{-3dB}^2 = \frac{\pi^2 K_{PI} k_4}{8 T_{DLF}^2 \phi_{in,p}} $$
    $$ \Rightarrow \omega_{-3dB} = \frac{\pi}{2 T_{DLF}} \sqrt{\frac{k_4 \cdot K_{PI}}{2 \phi_{in,p}}} $$

---

### 單位解析
**公式單位消去：**
以核心公式 $\phi_{out,p}$ 的第一項（比例路徑）為例進行檢驗：
$$ \text{Term}_1 = \frac{\pi \cdot K_{PI} \cdot k_3}{4 \cdot \omega_p \cdot T_{DLF}} $$
*   $\pi, 4$: 常數，無單位 [1]
*   $K_{PI}$: 相位插值器解析度，單位 [rad/LSB] 或 [UI/LSB]（這裡以 rad 為例）
*   $k_3$: 數位乘法器增益，單位 [LSB]
*   $\omega_p$: Jitter 頻率，單位 [rad/s]
*   $T_{DLF}$: DLF 更新週期，單位 [s]

代入消去：
$$ \frac{[1] \times [\text{rad/LSB}] \times [\text{LSB}]}{[\text{rad/s}] \times [\text{s}]} = \frac{[\text{rad}]}{[\text{rad}]} = [\text{無因次}] \text{ ?} $$
**嚴格糾正：** 這裡的 $\pi$ 其實隱含了角度的意義。更準確的看，$N_{in}$ 是純數字 $\pm1$。$\int dt$ 產生了 $[s]$。所以時間域積分出來的單位：
$ \left( \frac{k_3}{T_{DLF}} \cdot t \right) \rightarrow \frac{[\text{LSB}]}{[\text{s}]} \times [\text{s}] = [\text{LSB}]$
再乘上 $K_{PI} [\text{rad/LSB}]$：
$ [\text{rad/LSB}] \times [\text{LSB}] = [\text{rad}] $ 
單位完美吻合物理意義，證明等式成立！

**圖表單位推斷：**
📈 **Jitter Tolerance (或 Tracking 邊界) Bode Plot**
*   **X 軸：** Jitter 頻率 $\omega_p$ [rad/s] (對數刻度)，典型範圍約 $10^4 \sim 10^8$ rad/s (數十kHz ~ 數十MHz)。
*   **Y 軸：** 最大可追蹤相位振幅 $\phi_{out,p}$ [rad] 或 [UI] (對數刻度)，典型範圍 $0.1 \sim 10$ UI。這條線代表 CDR 的 Slew Rate Limit 邊界。

---

### 白話物理意義
全數位 Bang-Bang CDR 配上 PI 時，因為 PI 只給相位不給頻率，濾波器必須自己「算兩次積分」來補足二階迴路；而當輸入抖動太大時，濾波器「踩死油門（Slew Limit）」也追不上，導致它的追蹤能力在低頻呈現極陡峭的 -40dB/dec 下降。

---

### 生活化比喻
想像你用「方向盤（數位 BB 訊號）」遙控一台「沒有慣性的幽浮（PI）」。因為幽浮指哪飛哪（沒有像車子一樣有速度累積的物理慣性），為了讓它能平滑追蹤移動的目標，你的遙控器內部必須自己寫好「速度與加速度（雙重積分）」的計算程式。
當目標開始瘋狂左右橫跳（High Frequency Jitter），你方向盤打到底（Bang-Bang Slew Limit）幽浮也跟不上。而且目標跳得越遠（$\phi_{in,p}$ 變大），你越早就會開始追丟（有效頻寬 $\omega_{-3dB}$ 隨振幅變窄）。

---

### 面試必考點
1. **問題：在 All-Digital CDR 中，如果 DCO 是用 Phase Interpolator (PI)，Digital Loop Filter (DLF) 的架構跟用 VCO 有什麼決定性的不同？**
   → **答案：** VCO 本身具備 $1/s$ 的頻率對相位積分特性，所以 DLF 只需要一次積分就能構成二階 PLL。但 PI 是直接輸出相位，沒有積分特性，因此 DLF 必須設計成「雙重積分器 ($1/s^2$)」才能維持二階迴路追蹤頻率誤差的能力。
2. **問題：Bang-Bang CDR 的 Jitter Tolerance 在低頻與高頻的斜率各是多少？原因為何？**
   → **答案：** 低頻斜率是 -40 dB/dec，高頻是 -20 dB/dec。這是因為 BBPD 的非線性造成 Slew Rate Limit。高頻時由 DLF 的比例路徑主導（一次積分極限），低頻時由 DLF 的積分路徑主導（二次積分極限）。
3. **問題：線性 PLL 的頻寬是固定的，那 Bang-Bang CDR 的迴路頻寬（Loop Bandwidth）呢？**
   → **答案：** 是高度非線性的！BB-CDR 的等效頻寬 $\omega_{-3dB}$ 會隨輸入 Jitter 振幅的增加而**變窄**。從推導可知，在積分路徑主導區，頻寬與輸入振幅的平方根成反比 ($\propto 1/\sqrt{\phi_{in,p}}$)。

**記憶口訣：**
> 「**PI 缺積分，DLF 補雙層；BB 踩死油門，頻寬看振幅。**」

---
*TA 溫馨提醒：這張推導把離散、連續、非線性 Slew Rate 融合在一起考，是鑑別你究竟是背公式還是真懂物理意義的極佳考題。如果覺得自己懂了，請對我說「我懂了」，我會啟動費曼測試電爆你。*
