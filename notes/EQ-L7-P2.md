# EQ-L7-P2

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L7-P2.jpg

---


### 數學推導
本圖展示了一個 **Half-Rate 3-tap Feed-Forward Equalizer (FFE)** 的架構。為了降低高速運作下的功耗與頻寬需求，資料被解多工（Demux）成偶數路（Din1）與奇數路（Din2）。
1. **資料與時脈關係定義**：
   - 假設全速資料傳輸率為 $20\text{ Gbps}$，則 1 個 Unit Interval (UI) 為 $T_{UI} = 50\text{ ps}$。
   - Half-rate 時脈 $Ckin_{1/2}$ 頻率為 $10\text{ GHz}$，週期 $T_{clk} = 100\text{ ps} = 2 T_{UI}$。
   - 由右上角時序圖可知，Din1 (偶數位元 $D_0, D_2, D_4$) 與時脈上升沿對齊；Din2 (奇數位元 $D_1, D_3, D_5$) 與時脈下降沿對齊。兩者之間本身就存在 $0.5 T_{clk} = 1\text{ UI}$ 的時間差。

2. **Shift Register (延遲線) 分析**：
   - **白色 Latch (無標記)**：Active-High，在 CLK=1 時透明 (Track)，CLK=0 時保持 (Hold)。
   - **紅色陰影 Latch (帶泡泡)**：Active-Low，在 CLK=0 時透明 (Track)，CLK=1 時保持 (Hold)。
   - **Top Path (Din1)**：經過 $L1$ (Active-High)，在 CLK=1 期間輸出當下的 $D_{even}$，並在 CLK=0 期間 Hold。接著進入 $L2$ (Active-Low)，製造出額外的半週期 (1 UI) 延遲。
   - **Bottom Path (Din2)**：經過 $L1$ (Active-Low)，在 CLK=0 期間輸出當下的 $D_{odd}$，並在 CLK=1 期間 Hold。接著進入 $L2$ (Active-High)，同樣製造出相對應的延遲。

3. **MUX 多工器與全速序列重建**：
   - MUX 負責將半速的並列訊號重新交錯（Interleave）成全速訊號。白色 MUX 在 CLK=1 選 Top，CLK=0 選 Bottom；紅色陰影 MUX 相反（CLK=1 選 Bottom，CLK=0 選 Top）。
   - **Left MUX ($\alpha_{-1}$, Pre-cursor)**：輸入直接接 Din1 與 Din2。在 CLK=1 輸出 Din1 ($D_2$)，CLK=0 輸出 Din2 ($D_3$)。序列為 $D_2, D_3, D_4 \dots$
   - **Middle MUX ($\alpha_0$, Main-cursor)**：紅色陰影。在 CLK=1 選 Bottom (來自 Bottom L1, 為 $D_1$)，CLK=0 選 Top (來自 Top L1, 為 $D_2$)。序列為 $D_1, D_2, D_3 \dots$
   - **Right MUX ($\alpha_1$, Post-cursor)**：在 CLK=1 選 Top (為 $D_0$)，CLK=0 選 Bottom (為 $D_1$)。序列為 $D_0, D_1, D_2 \dots$

4. **最終加總**：
   三個 MUX 的輸出在類比端直接乘上權重並相加，得到全速的等化結果：
   $y(t) = \alpha_{-1} \cdot D_{n+1} + \alpha_0 \cdot D_n + \alpha_1 \cdot D_{n-1}$

### 單位解析
**公式單位消去：**
- 資料傳輸率 $DR = 20 \text{ Gbps}$，對應位元週期 $T_{UI} = \frac{1}{DR} = \frac{1}{20 \times 10^9 \text{ [bits/s]}} = 50 \text{ [ps/bit]}$
- 半速率時脈頻率 $f_{clk} = \frac{DR}{2} = 10 \text{ GHz}$
- 時脈週期 $T_{clk} = \frac{1}{f_{clk}} = \frac{1}{10 \times 10^9 \text{ [Hz]}} = 100 \text{ [ps]} = 2 T_{UI}$
- FFE 輸出電流：$I_{out}[A] = \alpha_{-1}[A/V] \cdot V_{D+1}[V] + \alpha_0[A/V] \cdot V_{D}[V] + \alpha_1[A/V] \cdot V_{D-1}[V] = [A]$ （假設 MUX 輸出為電壓，乘上轉導權重轉換為電流相加）

**圖表單位推斷：**
📈 圖表單位推斷：
- **右上角時序圖 (Timing Diagram)**：
  - X 軸：時間 $\text{[ps]}$，典型範圍 $0 \sim 300\text{ ps}$ (展示 3 個 clock cycle)。
  - Y 軸：電壓 $\text{[V]}$ 或邏輯準位。
  - $Ckin_{1/2}$：$10\text{GHz}$ 方波，週期 $100\text{ps}$。
  - Din1 / Din2：Data Eye，每個 Eye 寬度為 $100\text{ps}$ ($2\text{ UI}$)，Din2 相比 Din1 延遲 $50\text{ps}$ ($1\text{ UI}$)。

### 白話物理意義
透過「降速分流」的技巧，讓大部分的暫存器只需在原本一半的速度（10GHz）下工作，最後一刻才用多工器（MUX）像拉鍊一樣把奇數和偶數資料「咬合」成全速（20Gbps）訊號，同時完成等化器的加權計算。

### 生活化比喻
想像一個高鐵驗票口（20Gbps）。如果只開一個閘門，機器會來不及處理。於是我們開兩個閘門（Half-rate），一個專收偶數車廂乘客（Din1），一個收奇數車廂乘客（Din2），驗票機只要用一半的速度運作就好。最後過完閘門，乘客走到手扶梯前，會有一個快速旋轉的擋板（MUX），左邊放一個、右邊放一個，瞬間把乘客重新排列成一條高速前進的單行道，並且在進入單行道的瞬間，給每個人發放不同顏色的手環（乘上 $\alpha$ 權重）。

### 面試必考點
1. **問題：Half-rate FFE 的主要優缺點是什麼？（筆記左下角重點）**
   → **答案：** 優點是 Lower power（時脈與大部分邏輯只需跑一半頻率）與 Less bandwidth required（降低電路頻寬要求）。缺點是會有 Pulse width distortion (PWD)（因為時脈的 Duty Cycle 誤差會直接轉化為輸出資料的脈波寬度失真）。
2. **問題：圖中紅色陰影（Shaded）的 Latch 和 MUX 代表什麼意思？為什麼必須這樣設計？**
   → **答案：** 代表「反相時脈觸發」（Active-Low 或選擇反相輸入）。為了讓全速輸出的三個 Tap 能夠提供 $D_{n-1}, D_n, D_{n+1}$ 連續相鄰的資料，偶數路與奇數路必須交錯取樣。中間 MUX 的反相確保了在同一個 Clock Phase 下，三個 MUX 輸出的資料會呈現「奇、偶、奇」或「偶、奇、偶」的嚴格順序。
3. **問題：如果 $Ckin_{1/2}$ 的 Duty Cycle 不是 50%（例如 45% High, 55% Low），會對系統造成什麼致命影響？**
   → **答案：** 由於最後一級的 MUX 是直接用這個 Clock 來切換奇偶資料，Clock High 決定了偶數位元的長度（45ps），Clock Low 決定了奇數位元的長度（55ps）。這會導致輸出的眼圖寬度不一致，產生嚴重的 Deterministic Jitter (DJ)，大幅降低 Receiver 的 Jitter Tolerance。

**記憶口訣：**
半速等化三部曲：「降頻省電寬度小、奇偶交錯延半拍、多工拉鍊拼全速、Duty不準眼就歪！」
