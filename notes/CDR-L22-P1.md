# CDR-L22-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L22-P1.jpg

---


---
## Frequency Acquisition in PLL-based CDR (Dual Loop Architecture)

### 數學推導
（推導 Lock Detector 如何將頻率誤差 ppm 轉換為計數器門檻值 Threshold）

1. 定義理想參考頻率為 $f_{ref}$，VCO 除頻後的頻率為 $f_{div} = \frac{f_{vco}}{M}$。
2. 將這兩個頻率送入混頻器 (Mixer / XOR) 與低通濾波器後，會產生拍頻（差頻，Beat Frequency）$f_b$：
   $f_b = |f_{ref} - f_{div}|$
3. 差頻的週期 $T_b$ 即為：
   $T_b = \frac{1}{f_b} = \frac{1}{|f_{ref} - f_{div}|}$
4. Lock Detector 內部的計數器 (Counter) 運作原理是：在一個差頻週期 $T_b$ 的時間內，用高速的 $f_{ref}$ 來當作刻度進行計數，計數值 $N$ 為：
   $N = T_b \times f_{ref} = \frac{f_{ref}}{|f_{ref} - f_{div}|}$
5. 在工程上，頻率誤差比例 (Frequency Error) 通常以 $\frac{\Delta f}{f}$ 表示：
   $\frac{\Delta f}{f} = \frac{|f_{ref} - f_{div}|}{f_{ref}}$
6. 結合步驟 4 與 5 可以發現，計數值 $N$ 剛好是頻率誤差比例的倒數：
   $N = \frac{1}{\frac{\Delta f}{f}}$
7. **結論**：若 CDR 系統設計要求頻率誤差必須拉近到 1000 ppm ($1000 \times 10^{-6} = 10^{-3}$) 以內才能切換給 PD 接手，則計數器門檻值 $Threshold$ 就必須設為 $N = \frac{1}{10^{-3}} = 1000$。當硬體計數到 $N > 1000$ 時，代表差頻週期夠長、頻率夠接近，即可發出 Lock 訊號。

### 單位解析
**公式單位消去：**
- $f_b$ [Hz] = $f_{ref}$ [Hz] - $f_{div}$ [Hz] = [Hz]
- $T_b$ [s] = $\frac{1}{f_b \text{ [Hz]}} = \frac{1}{\text{[1/s]}} = \text{[s]}$
- $N$ [無單位] = $T_b$ [s] $\times f_{ref}$ [1/s] = [s] $\times$ [1/s] = [無單位]
- $\frac{\Delta f}{f}$ [ppm] = $\frac{\text{[Hz]}}{\text{[Hz]}} \times 10^6$ = [無單位比例]

**圖表單位推斷：**
📈 圖表一：$f_b$ 與 $Ck_{ref}$ 時序波形圖
- **X 軸**：時間 Time [μs]，典型範圍約 1~10 μs（取決於幾千 ppm 誤差時的差頻週期）。
- **Y 軸**：電壓 Voltage [V]，典型範圍 0 ~ VDD（如 1.0V），代表數位邏輯準位。

📈 圖表二：Lock 狀態遲滯曲線圖 (Hysteresis)
- **X 軸**：頻率誤差 $\Delta f/f$ [ppm]，典型範圍 ±1500 ppm。
- **Y 軸**：鎖定狀態 Lock Status [邏輯準位 0 或 1]，1 代表 Locked，0 代表 Out of Lock。
- **物理意義**：圖中的紅綠線框展示了遲滯現象。頻率誤差必須縮小到 500ppm 以內才判定為 Lock；但一旦鎖定，必須等誤差惡化放大到 1000ppm 以外才會發出 Loss of Lock (LOL) 訊號。這確保了系統在邊界時不會反覆切換。

### 白話物理意義
因為處理隨機資料的「相位偵測器 (PD)」抓取頻率的能力非常弱，所以必須外掛一個「頻率迴路 (FD Loop)」當作粗調，先把 VCO 的頻率硬拉到跟參考時脈幾乎一模一樣（誤差 < 100ppm），再關掉 FD 交接給 PD 進行精密的相位對齊。

### 生活化比喻
想像你要在高速公路上從一台車跳到另一台並行的車上（相位鎖定）：
- **FD Loop（頻率迴路）**：就像是看著時速表踩油門，先把你的車速（VCO）強行加速到跟目標車（Ref Clock）幾乎一樣。因為要快速且強行拉抬速度，所以油門要踩大力一點（**筆記寫到 CP2 電流是 CP1 的 3~5倍**）。
- **Lock Detector（鎖定偵測器）**：就像是你的眼睛，盯著兩台車的「相對速度」（Beat frequency），當相對速度極小，車子看起來幾乎相對靜止時（計數值 N 大於設定門檻），眼睛就會發出「可以了！」的訊號。
- **PD Loop（相位迴路）**：眼睛說 OK，關閉大油門 (CP2 OFF) 後，你才開始微調方向盤，讓你的車門精準對齊目標車的車門，準備完美跳車。

### 面試必考點
1. **問題：為什麼 PLL-based CDR 需要 Dual Loop (FD + PD) 架構？單獨用 PD 不行嗎？**
   → **答案**：不行。因為 CDR 接收的是 Random Data，含有連續相同位元 (CID) 且沒有固定的 Clock Edge，導致 PD 的 Frequency Capture Range 非常窄。如果一開始頻率差太多，PD 會產生混亂的控制電壓（False Lock 或完全不鎖定）。因此必須用 FD Loop 負責「頻率粗調」(Coarse tuning)，再交由 PD 負責「相位微調」(Fine tuning)。
2. **問題：在 Dual loop 中，為什麼 FD Loop 的 Charge Pump (CP2) 電流通常要設計得比 PD 的 CP1 大 3 到 5 倍？**
   → **答案**：有兩個主要原因。第一，在頻率獲取 (Frequency Acquisition) 期間，PD 依然會因為輸入的隨機資料產生干擾雜訊 (Pattern noise)，CP2 的增益必須夠大，才能「強壓」過 CP1 的錯誤訊號，主導 Loop Filter 的電壓控制權。第二，較大的 Charge Pump 電流能提供較大的 Loop Bandwidth，大幅縮短頻率鎖定的時間。
3. **問題：Lock Detector 的遲滯 (Hysteresis) 設計（例如圖中的 500ppm 與 1000ppm）有何作用？如果不做會發生什麼事？**
   → **答案**：遲滯設計是為了防止系統在鎖定判定邊緣，因為 VCO Jitter 或雜訊而發生「頻繁切換 (Chattering)」的現象。若無遲滯，只要誤差稍微跳動，FD Loop 與 PD Loop 就會不斷互相搶奪控制權，導致 VCO 控制電壓劇烈震盪，系統永遠無法進入穩定的鎖定狀態。

**記憶口訣：**
「**雙迴路拉頻率：FD 粗調重油門 (CP2大)，計數差頻看遲滯，PD 微調對車門。**」
