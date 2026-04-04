# PLL-L5-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L5-P1.jpg

---

這是一份關於 **Type I PLL 頻率步階響應（Frequency Step Response）以及迴路頻寬與穩定度 Trade-off** 的精華筆記。以下為您進行詳細的工程與物理拆解：

---
## Type I PLL 頻率步階響應與迴路頻寬的 Trade-off

### 數學推導
筆記中探討了一個基本的 Type I PLL 面對輸入頻率發生步階跳變 (Step function in $\omega_{in}$) 時的系統暫態響應。

1. **定義系統特徵與 LPF 的關聯：** 筆記開頭給定了這個 Simple PLL 的阻尼因數 ($\zeta$)、自然頻率 ($\omega_n$) 和低通濾波器頻寬 ($\omega_{LPF}$) 之間存在以下關聯性：
   $$ \zeta \omega_n = \frac{1}{2} \omega_{LPF} $$
   *(這表示系統的阻尼衰減能力直接受限於 LPF 的頻寬。)*
2. **輸入訊號的拉普拉斯轉換：** 當輸入頻率突然改變（例如頻道切換），時域函數可表示為 $\omega_{in}(t) = \Delta\omega \cdot u(t)$。轉換到 s-domain：
   $$ \Omega_{in}(s) = \mathcal{L}[u(t)] = \frac{1}{s} $$ (以單位步階為例)
3. **輸出訊號求解：** 透過閉迴路轉移函數 $H(s)$，輸出的 s-domain 響應為：
   $$ \Omega_{out}(s) = \Omega_{in}(s) \cdot H(s) = \frac{1}{s} \cdot H(s) $$
4. **時域反轉換與阻尼特性分析：** 對 $\Omega_{out}(s)$ 做反拉氏轉換 $\mathcal{L}^{-1}$ 得到時域響應 $\omega_{out}(t)$。這是一個標準的二階系統暫態響應：
   - 當 **$\zeta < 1$ (Underdamped, 欠阻尼)**：系統會產生過衝與震盪 (Ringing)，其震盪的包絡線 (Envelope) 衰減項為 $e^{-\zeta \omega_n t}$。
   - 將第一步的關係式代入，包絡線衰減項變成 $e^{-\frac{1}{2} \omega_{LPF} t}$。
   - **推導結論：** 這在數學上證明了 $\omega_{LPF}$ 越大，指數衰減得越快，系統達到穩態的時間 (Settling Time) 就越短。

### 單位解析
**公式單位消去：**
- **拉氏轉換變數 $s$**：代表 $j\omega$，單位為 $[rad/s]$。
- **步階輸入 $\Omega_{in}(s) = \frac{1}{s}$**：若 $\omega_{in}$ 的物理量單位為 $[rad/s]$，經過拉氏積分轉換後，$\frac{1}{s}$ 的運算會使單位變成 $\frac{[rad/s]}{[rad/s]} = [無因次純量]$。
- **包絡線指數項 $e^{-\zeta \omega_n t}$**：
  - $\zeta$：阻尼因數，$[無因次]$
  - $\omega_n$：自然頻率，$[rad/s]$
  - $t$：時間，$[s]$
  - 指數的次冪運算：$[無因次] \times [rad/s] \times [s] = [rad]$，結果為無因次純量，完美符合指數函數的數學要求。

**圖表單位推斷：**
📈 **頻率步階響應波形圖（圖左下，包含 $\zeta < 1$ 與 $\zeta > 1$ 兩種情況）**
- **X 軸**：時間 $t$ $[s]$。在高速 SerDes 或 RF 系統中，典型範圍為 $[ns]$ 到 $[\mu s]$ 等級（例如 PLL Lock time 約在 $1 \sim 100 \mu s$ 區間）。
- **Y 軸**：輸出頻率 $\omega_{out}$ $[rad/s]$ 或實務上用 $[GHz], [MHz]$。典型範圍代表 VCO 鎖定的目標頻率跳變量（例如從 $2.4GHz$ 跳至 $2.45GHz$）。

### 白話物理意義
Type I PLL 的「低通濾波器頻寬 ($\omega_{LPF}$)」就是控制系統反應的油門：油門踩到底（$\omega_{LPF}$ 大），追頻率很快但雜訊會直接灌進來讓 VCO 狂抖；油門踩太輕（$\omega_{LPF}$ 小），雜訊被濾得很乾淨，但追頻率的速度慢如牛車。這是一個無解的緊密權衡（Tight tradeoff）。

### 生活化比喻
把 PLL 想像成「汽車的自動跟車系統（ACC）」，$\omega_{in}$ 是前車車速，$\omega_{out}$ 是你的車速。
- **$\omega_{LPF} \uparrow$ (大頻寬)**：你對前車速度變化的反應超神經質。前車一加速你馬上猛踩油門。結果是：你能**很快跟上 (Settle quickly)**，但車子會一直頓挫暴衝，乘客很不舒服，這就是控制電壓 $V_{ctrl}$ 上的 **Ripple** 和 **Jitter**。
- **$\omega_{LPF} \downarrow$ (小頻寬)**：你反應很遲鈍。前車加速了，你慢吞吞地才把速度拉上來。結果是：開得很平穩乾淨，但是**要花很久時間才跟上 (Long settling time)**。
- **$\zeta < 1$ (無線通訊 RF 適用)**：像警車追捕，寧願車頭急煞晃動幾下 (Rings to settle)，也要在最短時間內硬切到目標車道（Need to hop from channel to another）。
- **$\zeta > 1$ (有線通訊 Wireline 適用)**：像高鐵，絕對不能有任何震盪，寧願慢慢加速到穩態，追求極致的平穩與低抖動。

### 面試必考點
1. **問題：在設計 Charge Pump PLL 時，如果無限制地拉大 Loop Bandwidth ($\omega_{LPF}$) 會產生什麼致命缺點？**
   → **答案：** 雖然 Settling time 會變短（鎖定變快），但 LPF 會壓不住來自 Phase Detector/Charge Pump 的高頻切換雜訊，導致大量的 Ripple 殘留在 $V_{ctrl}$ 上。這會直接 modulate VCO，讓輸出的 Jitter 劇烈惡化（如筆記所述：large ripple left on $V_{ctrl} \Rightarrow$ jittery）。
2. **問題：為什麼 RF/Wireless 系統的 PLL 有時能容忍 $\zeta < 1$（Underdamped），而高速 SerDes (Wireline) 通常要求 $\zeta \ge 1$？**
   → **答案：** RF 系統（如 Wi-Fi, 藍牙）常需要做 Channel Hopping（頻段快速跳換），規範要求在極短的 $\mu s$ 等級內切換完畢，因此容許頻率有稍微的 Ringing 以換取極快的 Settling Time；反之，Wireline SerDes 傳輸是連續且對時序極度敏感的，更看重 Jitter 效能，不能容忍 Ringing 造成的相位誤差與 Bit Error Rate (BER) 上升。
3. **問題：如果我覺得 Settling time 太慢，可以直接把阻尼係數 $\zeta$ 降低來爭取更快的 initial rise time 嗎？**
   → **答案：** 不行。如筆記最下方強調，單純 reducing $\zeta$ 會導致嚴重的 Ringing，甚至引發 Stability issue（系統發散不穩定），這是錯誤的 Trade-off 方向。

**記憶口訣：**
**「頻寬大就快但抖，頻寬小就穩但慢。無線愛快帶點甩（$\zeta<1$），有線求穩慢慢來（$\zeta>1$）。」**
