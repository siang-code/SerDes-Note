# CDR-L2-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L2-P1.jpg

---


---
## NRZ 邊緣偵測與時脈萃取 (Clock Recovery via Edge Detection)

### 數學推導
1. **NRZ 頻譜特性**：
   原始 NRZ 資料 $D_{in}(t)$ 的功率頻譜密度 (PSD) 正比於 $\text{sinc}^2(\pi f T_b)$。當頻率等於資料率 (Data Rate) $f = 1/T_b$ 時，$\text{sinc}(\pi) = 0$。因此，NRZ 訊號在資料率上沒有能量，無法直接用帶通濾波器 (Bandpass Filter) 取出時脈。
2. **邊緣偵測 (Delay & XOR)**：
   為了「無中生有」創造時脈成分，利用延遲 $\Delta T$ 與 XOR 閘來偵測資料邊緣：
   $V_{out}(t) = D_{in}(t) \oplus D_{in}(t - \Delta T)$
   每次 $D_{in}$ 發生 0→1 或 1→0 轉態時，$V_{out}$ 就會產生一個脈衝寬度為 $\Delta T$ 的方波。
3. **頻譜重塑與傅立葉級數 (Fourier Series)**：
   若輸入為最密集的 1010... 轉態序列，產生的 $V_{out}$ 將是週期為 $T_b$、脈寬為 $\Delta T$ 的週期性脈衝序列 (Pulse Train)。
   其第 $n$ 次諧波的振幅係數為：
   $A_n = \frac{\sin(n \pi \Delta T / T_b)}{n \pi}$
4. **不同 $\Delta T$ 的頻譜響應**：
   - **當 $\Delta T = T_b / 2$**：
     - 第一諧波 ($f = 1/T_b, n=1$)：$A_1 = \frac{\sin(\pi/2)}{\pi} = \frac{1}{\pi}$
     - 第二諧波 ($f = 2/T_b, n=2$)：$A_2 = \frac{\sin(\pi)}{2\pi} = 0$
     - 第三諧波 ($f = 3/T_b, n=3$)：$A_3 = \frac{\sin(3\pi/2)}{3\pi} = \frac{-1}{3\pi}$，大小為 $\frac{1}{3\pi}$
   - **當 $\Delta T = T_b / 4$**：
     - 第一諧波 ($f = 1/T_b, n=1$)：$A_1 = \frac{\sin(\pi/4)}{\pi} = \frac{1}{\sqrt{2}\pi}$
     - 第二諧波 ($f = 2/T_b, n=2$)：$A_2 = \frac{\sin(\pi/2)}{2\pi} = \frac{1}{2\pi}$
     - 第三諧波 ($f = 3/T_b, n=3$)：$A_3 = \frac{\sin(3\pi/4)}{3\pi} = \frac{1}{3\sqrt{2}\pi}$
   推導證明了 Delay+XOR 成功在 $f = 1/T_b$ 處創造了離散的時脈能量 (Clock Tones)，且 $\Delta T$ 決定了頻譜 Sinc 包絡線 (Envelope) 的形狀與零點位置。

### 單位解析
**公式單位消去：**
- **Data Rate 頻率 $f$**：$1 / T_b \Rightarrow 1 / [\text{s}] = [\text{Hz}]$
- **諧波振幅 $A_n$**：$\frac{\sin(n \pi \Delta T / T_b)}{n \pi}$ 中括號內時間相除：$[\text{s}] / [\text{s}] = [\text{無單位}]$。若乘上實際邏輯準位電壓 $V_{DD}$，則單位為 $[\text{V}]$。
- **延遲時間 $\Delta T$**：通常單位為 $[\text{ps}]$。在 20Gbps 系統中，$T_b = 50\text{ ps}$，若 $\Delta T = T_b/2$，則為 $25\text{ ps}$。

**圖表單位推斷：**
📈 圖表單位推斷：
- **$D_{in}$ 與 $V_{out}$ 波形圖：**
  - X 軸：時間 [ps]，對於 20Gbps，典型顯示範圍約 0 ~ 200 ps ($4 T_b$)。
  - Y 軸：電壓 [V]，典型範圍 0 ~ 1 V (或差動 $\pm 300$ mV)。
- **$S_X(f)$ 頻譜圖 (NRZ Data)：**
  - X 軸：頻率 [GHz]，典型範圍 0 ~ 60 GHz。
  - Y 軸：頻譜振幅 (Magnitude)，無單位或 $[\text{V}/\sqrt{\text{Hz}}]$。
- **$S_V(f)$ 頻譜圖 (Edge Extracted Data)：**
  - X 軸：頻率 [GHz]，以 $1/T_b$ 為刻度 (20GHz, 40GHz...)。
  - Y 軸：頻譜振幅 (Magnitude)，正規化無單位。

### 白話物理意義
NRZ 訊號就像是一段沒有固定鼓聲節拍的音樂，Delay+XOR 電路就是一個「邊緣打擊樂手」，只要聽到音高改變（資料從0變1或1變0），他就敲一下鈸，藉此從原本沒有節奏的音樂中，硬是打出一個固定頻率的節拍（Clock）。

### 生活化比喻
想像一條筆直平坦的高速公路（連續的 1 或 0），坐在車上你感覺不到速度節奏。現在有人在路上每隔一段距離畫上減速條（轉態邊緣），車子每次壓過減速條（Delay+XOR 偵測邊緣）就會「喀隆」震動一下。你憑藉著這個規律的震動聲，就能「萃取」出車速的節奏（時脈）。但如果遇到超長一段沒有減速條的路面（連續的 0 或 1），震動聲就會消失，所以我們還需要一個「內建節拍器」（PLL）來維持這個節奏。

### 面試必考點
1. **問題：為什麼一般的 NRZ 訊號不能直接用 Bandpass Filter 取出時脈？**
   → 答案：因為 NRZ (Non-Return-to-Zero) 的頻譜形狀是 Sinc 函數，其第一個 Null (零點) 剛好落在 Data Rate ($1/T_b$) 上，能量為零，濾波器無法濾出不存在的能量。
2. **問題：在實務上，使用 Delay + XOR 來產生 Clock 有什麼致命缺點？**
   → 答案：第一，產生的脈波極窄 ($\Delta T$)，XOR 閘必須具備超大頻寬 (Large BW) 才能完整輸出；第二，真實資料有長連續相同位元 (Long CID)，此時 XOR 不會產生脈波（Clock 消失），因此後端必須搭配具備追蹤與維持能力 (Flywheel) 的 PLL (Phase-Locked Loop) 才能確保鎖定。
3. **問題：Delay 量 $\Delta T$ 的大小會如何影響頻譜？如何選擇？**
   → 答案：$\Delta T$ 會決定頻譜 Sinc 包絡線 (Envelope) 的寬度。$\Delta T$ 越小，包絡線越寬，但對電路頻寬要求極高；通常會選擇 $\Delta T = T_b / 2$，因為在 $f = 1/T_b$ 處能獲得最大的第一諧波能量振幅 ($1/\pi$)，最有利於後續 PLL 鎖定。

**記憶口訣：**
NRZ 無能量，延遲 XOR 找邊緣；
造出脈波現頻譜，長零長一靠 PLL。
