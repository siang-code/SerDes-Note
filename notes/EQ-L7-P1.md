# EQ-L7-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L7-P1.jpg

---


---
## Zero-Forcing FFE (ZFE) 與 Full-rate FFE 架構

### 數學推導
**1. Zero-Forcing Equalizer (ZFE) 權重矩陣：**
給定通道的脈衝響應取樣值為 $x_k$。我們希望透過 FFE 的 tap weights $\alpha_k$ 讓等化後的脈衝響應在 Main-cursor ($k=0$) 時為 1，而在其他 Pre-cursor 與 Post-cursor ($k \in [-M, M], k \neq 0$) 時強迫為 0。
其卷積關係可寫成矩陣形式：
$$
\begin{bmatrix} 
x_0 & x_{-1} & \cdots & x_{-2M} \\ 
x_1 & x_0 & \cdots & x_{-2M+1} \\ 
\vdots & \vdots & \ddots & \vdots \\ 
x_{2M} & x_{2M-1} & \cdots & x_0 
\end{bmatrix} 
\begin{bmatrix} 
\alpha_{-M} \\ 
\alpha_{-M+1} \\ 
\vdots \\ 
\alpha_M 
\end{bmatrix} 
= 
\begin{bmatrix} 
0 \\ 
\vdots \\ 
1 \\ 
\vdots \\ 
0 
\end{bmatrix}
$$
解這個反矩陣即可得到各個 tap weight $\alpha$ 的值。這就是筆記中所說的「Nulling M precursors & M postcursors, neglecting others」。
*限制：* 筆記中特別標註 "**Taking care of sampled points, can't deal with jitters.**" 代表這套數學解法只能保證在理想的「取樣點」上 ISI 為零，若出現 timing jitter 導致取樣偏差，原本沒被 forced to zero 的點就會貢獻嚴重的 ISI。

**2. Full-rate FFE 的時序與資料率推導：**
- 輸入端使用 2-to-1 MUX，將兩路 $10\text{ Gbps}$ 的資料 (Din1, Din2) 交錯合併。
- MUX 的選擇信號 (Ckin) 頻率為 $10\text{ GHz}$。因為在 Clock 的 High 和 Low 各選擇一個輸入（Dual-edge 取樣概念），合併後的資料率（Data Rate）為 $10\text{ GHz} \times 2 = 20\text{ Gbps}$。
- 合併後的 Dout 進入一系列的 DFF (Flip-Flops)。為了讓 DFF 每次剛好延遲一個 bit (UI = 50ps)，DFF 的 clock (ck) 頻率必須是 $1/50\text{ps} = 20\text{ GHz}$。

### 單位解析
**公式單位消去：**
- **資料率與週期轉換 (MUX 端)**：
  $$UI_{Din} = \frac{1}{\text{DataRate}_{Din}} = \frac{1}{10\text{ Gbps}} = 100\text{ [ps/bit]}$$
  $$UI_{Dout} = \frac{1}{2 \times 10\text{ Gbps}} = 50\text{ [ps/bit]}$$
- **FFE Delay 與 Clock 頻率 (FFE 端)**：
  $$T_{clk\_FFE} = \frac{1}{f_{clk\_FFE}} = \frac{1}{20\text{ GHz}} = \frac{1}{20 \times 10^9\text{ Hz}} = 50 \times 10^{-12}\text{ [s]} = 50\text{ [ps]}$$
  $$Delay_{DFF} = T_{clk\_FFE} = 50\text{ [ps]}$$
- **ZFE 輸出電壓**：
  $$y(t) = \sum_{k=-M}^{M} \alpha_k \cdot x(t - k \cdot T_d)$$
  $$[\text{V}] = \sum [\text{無單位}] \cdot [\text{V}]$$ （tap weight $\alpha$ 為比例常數，物理上代表電流導向比例，無單位）。

**圖表單位推斷：**
📈 **2:1 MUX 波形與時序圖：**
- **X 軸**：時間 [ps]。Din1/Din2 每格 UI 為 100ps，合併後的 Dout 每格 UI 為 50ps。典型繪圖範圍 0~300 ps。
- **Y 軸**：邏輯準位 [0/1] 或 差動電壓 [mV]。典型範圍 0V~Vdd 或差動 $\pm 300\text{mV}$。

### 白話物理意義
Zero-Forcing FFE (ZFE) 就像是「只管考試當天考100分，不管平時表現多爛」的硬塞法，它只保證在精準取樣那一瞬間沒有前/後眼圖的干擾，但如果時脈稍有抖動（jitter）偏離了中心點，干擾反而可能更大。

### 生活化比喻
Zero-Forcing 就像修圖軟體的「魔術棒去背工具」，你強制點擊了邊緣幾個像素讓它們變透明（消除前/後緣干擾），但在沒有點擊到的像素之間，邊緣可能還是會有毛邊或鋸齒，因為它只管你指定的「那些點」（sampled points），無法處理手抖（jitter）造成的偏移。
MUX 的運作就像是「拉鍊」，左邊齒輪（Din1，10Gbps）和右邊齒輪（Din2，10Gbps）由 10GHz 的拉鍊頭（Clock）上下交錯咬合，最後組合成一條緊密的 20Gbps 完整拉鍊（Dout）。

### 面試必考點
1. **問題：Zero-Forcing Equalizer (ZFE) 的數學優勢是什麼？在實際高速 SerDes 應用中有什麼致命缺點？**
   → **答案：** 優勢是數學解單純，能強迫 (Force) 在特定取樣點的 ISI 為零。缺點是（1）會導致對高頻雜訊的放大 (Noise Enhancement)；（2）無法處理時脈抖動 (can't deal with jitters)，一旦取樣點因 jitter 發生微小偏移，未被 constrained 的點就會貢獻極大的 ISI，導致眼圖邊界閉合。
2. **問題：在 2:1 MUX 中，要產生 20Gbps 的資料流，為什麼選擇信號 (Clock) 只需要 10GHz？**
   → **答案：** 因為 2:1 MUX 是利用 Clock 的 High / Low 兩個相位進行切換。High 的半週期（50ps）選 Din1，Low 的半週期（50ps）選 Din2。因此一個 100ps 的 10GHz 週期內可以送出 2 個 bit，有效資料率倍增為 20Gbps。
3. **問題：在圖中的 20Gbps Full-rate FFE 架構中，提供延遲的 DFF 它的 Clock 頻率必須是多少？為什麼？**
   → **答案：** DFF 的 clock 必須是 20GHz。因為在 Full-rate FFE 中，每個 tap 之間的延遲 (delay) 必須精確等於一個 UI (Unit Interval)。20Gbps 對應的 UI 是 50ps，因此需要週期為 50ps 的 20GHz 全速時脈來觸發 DFF 序列。

**記憶口訣：**
ZF硬壓點，雜訊抖動它不管；
十G拉鍊頭，交錯咬出二十G；
全速暫存器，五十皮秒推到底。
