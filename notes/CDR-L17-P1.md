# CDR-L17-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L17-P1.jpg

---

---
## Phase Interpolator 與 Oversampling CDR 架構

### 數學推導
**1. Phase Interpolator (PI) 相位內插：**
PI 的輸出訊號為兩個相鄰輸入相位訊號（$\phi_A$ 與 $\phi_B$）的加權總和。
假設輸入為理想正弦波：
$V_A(t) = \sin(\omega t + \phi_A)$
$V_B(t) = \sin(\omega t + \phi_B)$
透過 5~6 bit DAC 控制的尾電流（Tail Current）決定權重 $W_A$ 與 $W_B$，為保持振幅穩定，通常設計為 $W_A + W_B = 1$。
輸出電壓為：
$V_{out}(t) = W_A \cdot \sin(\omega t + \phi_A) + W_B \cdot \sin(\omega t + \phi_B)$
利用和差化積與三角恆等式展開，當 $\phi_A$ 與 $\phi_B$ 差距不大時（例如相差 $45^\circ$），輸出訊號的等效相位 $\phi_{out}$ 可近似為這兩個相位的線性內插（Linear Interpolation）：
$\phi_{out} \approx \frac{W_A \phi_A + W_B \phi_B}{W_A + W_B}$

**2. Oversampling (過取樣) 條件：**
Nyquist Sampling 要求每 bit 至少 2 個取樣點才能還原波形：
$f_{sample} \ge 2 \cdot f_{data\_Nyquist}$ （1個取樣在 Edge，1個在 Center）。
圖中的 Oversampling 則是每 bit 取樣大於 2 次（圖中眼圖內畫了多個箭頭 $S_0, S_1 \dots S_4$）：
$M = \frac{T_{bit}}{T_{sample}} > 2$ （M 為過取樣率）。

### 單位解析
**公式單位消去：**
- **PI 輸出電壓公式：**
  $V_{out}[V] = (I_{tail,A}[A] \cdot R_L[\Omega]) \cdot \sin(\omega t + \phi_A) + (I_{tail,B}[A] \cdot R_L[\Omega]) \cdot \sin(\omega t + \phi_B)$
  單位消去：$[A] \times [\Omega] = [V]$，正弦函數本身無單位，最終得到輸出電壓振幅單位為 $[V]$。
- **DAC 權重控制尾電流：**
  $I_{tail,A}[A] = I_{total}[A] \cdot \frac{Code[無單位]}{2^N-1[無單位]}$
  單位消去：$[A] \times [1] = [A]$。

**圖表單位推斷：**
📈 圖表單位推斷：
- **左上 I-Q Constellation 圓形圖：**
  - X 軸：I (In-phase) 訊號振幅 [V] 或 [mA]，典型範圍 ±500 mV
  - Y 軸：Q (Quadrature) 訊號振幅 [V] 或 [mA]，典型範圍 ±500 mV
  - 角度：相位 [degree] 或 [rad]，範圍 $0^\circ \sim 360^\circ$
- **中間 Oversampling 眼圖：**
  - X 軸：時間 [UI (Unit Interval)]，典型範圍 1~2 UI (若 10Gbps 則 1 UI = 100 ps)
  - Y 軸：訊號電壓振幅 [V]，典型範圍 ±200 mV
- **右下 Phase 取樣圓盤 (Clock too fast/slow)：**
  - 圓周位置：相位角 [rad] 或 相對時間 [UI]，走完 1 圈代表經過 1 UI 的時間長度。

### 白話物理意義
- **Phase Interpolator**: 就是個「訊號調色盤」，按比例混合兩種相鄰的相位，無中生有地「調」出中間無限多種微調的新相位。
- **Oversampling CDR**: 不靠迴路去精確預測中心點，而是用「機關槍掃射」的暴力法，在一個 bit 裡面連續多拍幾張照，事後再用數位邏輯（DSP）挑出沒有轉態的「最清楚那張」當作正確 Data。

### 生活化比喻
- **Phase Interpolator**: 就像浴室裡的「冷熱水混合龍頭」。左邊冷水($\phi_A$)、右邊熱水($\phi_B$)，透過旋鈕（DAC）控制兩邊水管的開口大小（權重），你就能調出任何你想要的溫水（$\phi_{out}$）。
- **Oversampling CDR**: 就像你要拍賽車衝過終點線的瞬間。與其精確計算它何時抵達（傳統 PLL 的做法），不如直接拿高速連拍相機「一秒鐘狂拍幾十張（Oversampling）」，事後總能從照片庫裡挑出一張剛好在終點線上的完美照片。

### 面試必考點
1. **問題：Phase Interpolator 為什麼常採用圖中左下的 "Two-Step" (先 MUX 再 PI) 架構？**
   → 答案：為了減少負載與寄生電容。先用粗調 MUX 從多個相位（如 8 個）選出相鄰的兩個（$\phi_A, \phi_B$），再送進 PI 進行細調。這樣 PI 只需要兩組差動對，而不是 8 組全接在一起，能大幅降低高頻下的輸出端電容負載，提升頻寬並節省功耗。
2. **問題：Oversampling CDR 的最大優點與致命缺點分別是什麼？**
   → 答案：
   - **優點**：因為「不需要回授迴路 (Need no feedback loop)」，所以沒有穩定度問題，且鎖定速度極快 (Fast acquisition)。
   - **缺點**：高硬體成本與「高功耗 (High Power)」。因為需要多相位 Clock，且後端的 DSP 與長 FIFO (Need long FIFO Regs) 在高速運作下會消耗大量面積與 Power，同時因為是開迴路，可能會有有限的頻率誤差 (Finite freq error)。
3. **問題：在 Oversampling 架構中，如何從取樣圓盤判斷 Clock 是過快還是過慢？**
   → 答案：觀察 Data Edge (Transition) 在取樣點（如 $S_0 \sim S_4$ 圓盤）上的移動方向。如果連續觀察下來，Edge 發生的位置順著 $S_0 \to S_1 \to S_2$ 的方向漂移，代表 Clock 週期比 Data 短（跑得比 Data 快，Clock too fast）；反之若向後退，就是 Clock too slow。

**記憶口訣：**
PI 兩步走，先 MUX 選鄰再微調，冷熱水龍頭最好喬。
過取樣是機關槍，盲目狂掃免迴路，鎖定快但很吃電。
