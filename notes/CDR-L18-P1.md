# CDR-L18-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L18-P1.jpg

---


---
## Burst Mode CDR 與 Gated-VCO 架構

### 數學推導
在 Burst Mode (例如 PON 系統) 中，資料是突發性的 (Burst)，CDR 沒有足夠的時間慢慢鎖定，必須實現「瞬間鎖相與鎖頻」。Gated-VCO 將這個問題拆成兩個數學/邏輯條件：

**1. 頻率複製 (Frequency Tracking via Replica PLL)：**
參考端使用一個標準的 PLL (包含 VCO2) 來鎖定外部的 Reference Clock ($f_{ref}$)。
$$ f_{VCO2} = N \cdot f_{ref} $$
透過 OpAmp Buffer，將 Loop Filter 上的控制電壓 $V_{ctrl}$ 無損複製給 VCO1：
$$ V_{ctrl1} = V_{ctrl2} $$
假設 VCO1 與 VCO2 匹配 (Matched Replica)，則：
$$ f_{VCO1}(free\_running) \approx f_{VCO2} = N \cdot f_{ref} $$
這確保了 VCO1 即使不看資料，其振盪頻率也已經是對的。

**2. 相位強制重置 (Phase Alignment via Gating)：**
輸入資料 $D_{in}$ 經過延遲 $\Delta T$ 與 XOR (此處邏輯上等同於產生 Active-Low 脈衝)，產生邊緣偵測訊號 $V_{xOR}$。
當資料發生轉態 (Transition) 時，$V_{xOR} = 0$：
VCO1 內部的 NAND Gate 強制輸出 1，經過兩個 Inverter 後 $ckout = 1$。
$$ \Phi_{ckout} \to \text{Reset Phase (強制對齊)} $$
當 $V_{xOR} = 1$ 時，NAND Gate 恢復為 Inverter 功能，VCO1 開始以 $f_{VCO1}$ 振盪：
$$ \Phi_{ckout}(t) = 2\pi f_{VCO1} t + \Phi_0 $$
透過每次轉態強迫重啟振盪器，相位誤差 $\Delta \Phi$ 在邊緣處被瞬間歸零。

### 單位解析
**公式單位消去：**
VCO 頻率控制方程式：
$$ f_{VCO1} = f_0 + K_{vco} \cdot V_{ctrl} $$
- $f_0$, $f_{VCO1}$：[Hz] 或 [1/s]
- $K_{vco}$：VCO 增益 [Hz/V]
- $V_{ctrl}$：控制電壓 [V]
消去過程：[Hz] + [Hz/V] × [V] = [Hz] + [Hz] = [Hz]

**圖表單位推斷：**
📈 **Gated-VCO Timing Diagram (右側波形圖)**
- **X 軸**：時間 $t$ [UI] (Unit Interval) 或 [ns]。依據筆記 1~2 GHz 規格，典型 1 UI = 0.5 ~ 1 ns。
- **Y 軸**：電壓 [V]。波形為數位邏輯準位，典型範圍 0V ~ VDD (例如 1.0V)。

### 白話物理意義
利用「替身 PLL」預先抓準頻率，再透過「強制打斷 (Gating)」在每次資料邊緣瞬間對齊相位，實現不需要等待的「0 秒鎖相」。

### 生活化比喻
想像一個樂隊（CDR）裡的鼓手（VCO1）。
一般 CDR 的鼓手（BB CDR）需要聽主唱（Data）唱好幾句，慢慢調整自己的節奏（因為 Loop Filter 電容太大，反應慢）。
但 Burst Mode 的鼓手（Gated-VCO）很極端：他平常在後台跟著節拍器（Replica PLL / VCO2）練就了精準的 BPM。一上台，只要聽到主唱一開口（資料邊緣），他瞬間「中斷並重置」自己揮下鼓棍的動作，馬上跟上主唱，完全不需要暖身時間！

### 面試必考點
1. **問題：在 PON 等非對稱系統為何不能用傳統 BB CDR？** 
   → **答案：** 傳統 BB CDR 的 Loop Filter 為了穩定度會接大電容 (nF~μF)，導致鎖定時間極長，無法滿足 Burst Mode 系統要求的「微秒級 (μs)」立即鎖定反應時間。
2. **問題：Gated-VCO 架構如何同時搞定「頻率」與「相位」？** 
   → **答案：** 頻率靠 Replica PLL 鎖住 Reference Clock 並透過 Buffer 複製控制電壓 ($V_{ctrl}$) 給 VCO1；相位靠邊緣偵測器產生脈衝，在每次資料轉態時強制重啟 (Reset) VCO1 的振盪相位，達成瞬間對齊。
3. **問題：Gated-VCO 有哪兩大致命缺點？** 
   → **答案：** (1) 必須使用 Ring Oscillator（為了能被 Gate），導致雜訊高、速度上限低 (約 1~2GHz)。(2) 頻繁的 Gating 會造成電路內部節點電壓劇烈波動，使得恢復出來的時鐘 (Recovered Clock) 產生較大 Jitter，並加劇 ISI (Intersymbol Interference)。

**記憶口訣：**
「替身抓頻、邊緣重啟；快是快，但 Ring OSC 雜訊大！」
