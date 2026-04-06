# LA-L12-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L12-P1.jpg

---


---
## Sub-rate PRBS Generator (次速率偽隨機二進位序列產生器)

### 數學推導
在超高速 SerDes（如 56Gbps 或 112Gbps）中，標準的 Flip-Flop (DFF) 無法在如此高的時脈下正常運作（Setup/Hold time 違例）。因此，我們必須降速（Sub-rate），使用 $n$ 組低速（$1/n$ 頻率）的平行電路來產生序列，最後再透過高速的多工器（MUX）將其交錯（Interleave）成高速訊號。這就是筆記中提到的 **"Use slow PRBS to realize high-speed data stream"**。

**核心問題：如何確保多工出來的結果，依然是一個完美的 PRBS 序列？**
假設目標高速 PRBS 序列為 $S[k]$，長度為 $L = 2^m - 1$。
我們使用 Quarter-Rate ($n=4$) 架構，需要 4 組低速序列 $D_0, D_1, D_2, D_3$。
經過 4:1 MUX 後，我們希望：
$S[4k] = D_0[k]$
$S[4k+1] = D_1[k]$
$S[4k+2] = D_2[k]$
$S[4k+3] = D_3[k]$

根據 PRBS 的抽取特性（Decimation property），只要抽取率 $n$ 與序列長度 $L$ 互質（$\gcd(n, L) = 1$），抽取出來的子序列 $D_i$ 依然是同一個 PRBS，只是**相位發生了偏移（Phase Shift）**。
現在來計算相鄰兩個低速 Lane 之間，到底需要相差多少個 bit 的 Delay（設為 $d$）：
我們需要 $D_1[k] = D_0[k+d]$
對應到高速序列：$S[4k+1] = S[4(k+d)] = S[4k + 4d]$
因此，相位的關係必須滿足：$4d \equiv 1 \pmod L$

**以筆記中的 PRBS-4 ($L = 2^4 - 1 = 15$) 為例：**
$4d \equiv 1 \pmod{15}$
解同餘方程式：$4 \times 4 = 16 = 15 \times 1 + 1$
因此 $d = 4$。
這完美印證了你筆記中寫的：**「錯開長度的 1/n，n=4 => 差 4 個 Delay」**。
更一般化的高級公式是：對於 Quarter-rate，所需的精準相位偏移量永遠是 **$d = \frac{L+1}{4}$** 個低速 bit。
*(助教鷹眼糾正：你筆記中的文字寫對了「差4個Delay」，但在畫波形圖時，$D_1$ 只比 $D_0$ 晚了 1 個 bit，這在畫法上是錯的喔！實際電路必須延遲 4 個 bit 才能 MUX 出正確的 PRBS4。)*

### 單位解析
**公式單位消去：**
- **Data Rate 轉換：** $f_{high} [\text{bps}] = n \times f_{low} [\text{bps}]$
  （例：$4 \times 14\text{Gbps} = 56\text{Gbps}$，其中倍數 $n$ 為無因次量）
- **時間偏移：** $\Delta T [\text{s}] = d \times T_{low} [\text{s}] = d \times (n \times T_{high} [\text{s}]) = d \times n \times \frac{1}{f_{high}} [\text{s}]$
  （證明了低速端的 bit shift $d$，對應到高速端是精確的相位控制）

**圖表單位推斷：**
📈 圖表單位推斷（D0~D3 波形圖）：
- X 軸：位元索引 (Bit Index) 或 低速時間 [UI_low]，典型範圍 $0 \sim 15 \text{ UI\_low}$。
- Y 軸：邏輯準位 Voltage [V]，典型範圍 $0 \sim V_{DD}$ (e.g., $0 \sim 0.9\text{V}$ 在 28nm 製程)。

### 白話物理意義
用四個「跑得慢但提早起跑」的跑者，透過交替接力的方式，在終點線組合出一個超高速的連續跑動畫面。

### 生活化比喻
**多鏡頭慢動作合成：** 想像你要拍一部每秒 120 幀的高速影片，但你只有 4 台每秒只能拍 30 幀的舊相機。只要讓這 4 台相機的快門時間精準「錯開」 $\frac{1}{120}$ 秒（這就是 Phase Shift），然後把它們拍的照片按順序交錯疊合（MUX），就能合成出完美的 120fps 高速影片！這就是 Sub-rate 降低硬體速度要求的精髓。

### 面試必考點
1. **問題：為什麼在高速 SerDes 中要使用 Sub-rate 架構來產生 PRBS？**
   → **答案：** 因為在 56G/112G 的頻率下，邏輯閘（Flip-flop）的 Setup/Hold time 無法滿足，且動態功耗 ($P \propto fCV^2$) 會過大。Sub-rate 允許核心邏輯在低頻運行，僅在最後一級使用 CML (Current Mode Logic) MUX 提速，大幅降低設計難度與功耗。
2. **問題：若要設計一個 Quarter-rate 的 PRBS-7 ($L=127$)，相鄰兩個 Lane 的 PRBS seed 應該錯開幾個 bit？**
   → **答案：** 代入公式 $d = (L+1)/n$。$d = (127+1)/4 = 128/4 = 32$ bits。
3. **問題：筆記右上角提到 Fibonacci 與 Galois 兩種 LFSR 架構，高速設計偏好哪一種？為什麼？**
   → **答案：** 偏好 **Galois**。因為 Fibonacci 架構的 XOR 閘都串在同一個 feedback path 上，critical path 較長（多個 XOR 延遲疊加）；而 Galois 架構將 XOR 閘打散插在 DFF 之間，critical path 只有一個 XOR 閘的延遲，更適合推動到最高極限頻率。

**記憶口訣：**
降速合體靠錯位，公式 L加一除以N，Galois 拆路徑飛上天。
