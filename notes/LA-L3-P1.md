# LA-L3-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L3-P1.jpg

---


---
## Offset Cancellation in Limiting Amplifier (LA)

### 數學推導
1. **直流偏移 (DC Offset) 消除推導**：
   * 假設 Limiting Amplifier (LA) 主放大器 $A(s)$ 存在等效輸入偏移電壓 $V_{os,in}$。
   * 在沒有交流輸入訊號 ($V_{in} = 0$) 的情況下，輸出端會產生直流偏移 $V_{os,out}$。
   * 這個 $V_{os,out}$ 會通過回授路徑上的低通濾波器 ($R_F, C_F$)。在直流 (DC) 時，低通濾波器等同於導通，因此回授訊號完全進入轉導放大器 $G_{mf}$。
   * $G_{mf}$ 將此電壓轉換為電流 $I_{fb} = V_{os,out} \cdot G_{mf}$，此電流流過第一級的負載電阻 $R_1$，產生回授電壓 $V_{fb} = V_{os,out} \cdot G_{mf} \cdot R_1$。
   * 此回授電壓會在主放大器的輸入端與原本的偏移電壓相減（構成負回授），因此主放大器實際「看到」的誤差輸入為：$V_{err} = V_{os,in} - V_{fb} = V_{os,in} - V_{os,out} \cdot G_{mf} \cdot R_1$。
   * 將誤差乘上總增益 $A_{tot}$ 即可得到輸出：$V_{os,out} = A_{tot} \cdot (V_{os,in} - V_{os,out} \cdot G_{mf} \cdot R_1)$
   * 移項並整理方程式求 $V_{os,out}$：
     $V_{os,out} \cdot (1 + A_{tot} \cdot G_{mf} \cdot R_1) = A_{tot} \cdot V_{os,in}$
     $\Rightarrow V_{os,out} = \frac{A_{tot} \cdot V_{os,in}}{1 + A_{tot} \cdot G_{mf} \cdot R_1}$
   * 當迴路增益足夠大（$A_{tot} \cdot G_{mf} \cdot R_1 \gg 1$）時，可近似為：$V_{os,out} \approx \frac{V_{os,in}}{G_{mf} R_1}$。
   * **等效輸入偏移 (Input-referred offset in closed-loop)**：
     推回輸入端，等效的閉迴路輸入偏移為 $V_{os,in(CL)} = \frac{V_{os,out}}{A_{tot}} \approx \frac{V_{os,in}}{A_{tot} \cdot G_{mf} \cdot R_1}$。
     **結論**：加上回授迴路後，等效輸入偏移電壓大幅縮小了 $A_{tot} \cdot G_{mf} \cdot R_1$ 倍。

2. **系統轉移函數 (Transfer Function) 推導**：
   * 前向路徑 (Forward Path) 增益：$H(s) = G_m \cdot R_1 \cdot A(s)$
   * 回授路徑 (Feedback Path) 傳遞函數：$\beta(s) = \frac{1}{1 + s R_F C_F} \cdot G_{mf} \cdot R_1$
   * 透過節點電壓法計算主放大器 $A(s)$ 前端的疊加結果：
     $V_{out} = A(s) \left[ G_m R_1 \cdot V_{in} - G_{mf} R_1 \cdot \frac{V_{out}}{1 + s R_F C_F} \right]$
   * 移項把 $V_{out}$ 提出來：
     $V_{out} \left( 1 + \frac{A(s) \cdot G_{mf} R_1}{1 + s R_F C_F} \right) = A(s) \cdot G_m R_1 \cdot V_{in}$
   * 最終得到完整的轉移函數：
     $\frac{V_{out}}{V_{in}} = \frac{A(s) \cdot G_m R_1}{1 + \frac{A(s) \cdot G_{mf} R_1}{1 + s R_F C_F}} = \frac{A(s) \cdot G_m R_1 \cdot (1 + s R_F C_F)}{1 + s R_F C_F + A(s) \cdot G_{mf} R_1}$

3. **頻率響應極限分析**：
   * **低頻 ($s \to 0$)**：電容 $C_F$ 視為開路，$A(s) \to A_{tot}$。
     增益 $\approx \frac{A_{tot} G_m R_1}{1 + A_{tot} G_{mf} R_1} \approx \frac{G_m}{G_{mf}}$（增益被大幅壓抑，專門用來消除 DC Offset）。
   * **中高頻 (Mid-high freq)**：對於高速資料頻段，$s$ 夠大使得 $s R_F C_F \gg A_{tot} G_{mf} R_1 \gg 1$。
     分母 $\approx s R_F C_F$，分子 $\approx A(s) \cdot G_m R_1 \cdot (s R_F C_F)$。
     增益 $\approx A(s) \cdot G_m R_1 = G_m R_1 \cdot \frac{A_{tot}}{(1 + s/\omega_0)^5}$（迴路形同斷開，回復開迴路最大增益以放大高頻訊號）。

### 單位解析
**公式單位消去：**
* **回授迴路增益 $A_{tot} \cdot G_{mf} \cdot R_1$：**
  $[V/V] \times [A/V] \times [\Omega] = [1] \times [A/V] \times [V/A] = [1]$ (無因次量，符合 Loop Gain 的純數值定義)
* **低頻閉迴路增益 $\frac{G_m}{G_{mf}}$：**
  $[A/V] \div [A/V] = [1] = [V/V]$ (代表電壓增益，無因次)
* **RC 極點頻率 $\frac{1}{R_F C_F}$：**
  $1 / ([\Omega] \times [F]) = 1 / ([V/A] \times [C/V]) = 1 / ([C/A]) = 1 / [s] = [Hz]$ (或 $[rad/s]$)

**圖表單位推斷：**
* **左下角 Bode Plot (波德圖)**：
  * **X 軸**：頻率 $f$ $[Hz]$ 或 $\omega$ $[rad/s]$ (對數刻度)。典型範圍：$1\text{Hz}$ 到 $>10\text{GHz}$。
  * **Y 軸**：電壓增益大小 $|V_{out}/V_{in}|$ $[V/V]$ 或 $[dB]$ (對數刻度)。典型範圍：低頻平坦區約 $0\text{dB}$，中頻平坦區（Mid-band）通常約 $30\sim 50\text{dB}$。
* **右側 Sinc 函數頻譜圖**：
  * **X 軸**：頻率 $f$ $[Hz]$ (線性刻度)。Null (零點) 發生在 Data Rate 的整數倍。
  * **Y 軸**：功率頻譜密度 (PSD) $[dBm/Hz]$。

### 白話物理意義
透過一個「反應超慢」的低通濾波器把輸出端長期累積的「直流偏差（DC Offset）」抓出來，反相扣回輸入端來自我修正；同時因為濾波器反應太慢，高速閃爍的 0 與 1 資料能毫無阻礙地通過放大器。

### 生活化比喻
就像開車時方向盤因為機械公差微微偏右（DC Offset），如果我們只死盯著遠方的高速路況（高頻訊號）猛踩油門，車子遲早偏離車道。所以我們安排了一個極度遲鈍的副駕駛（低通濾波器 $R_F C_F$），他完全不管眼前閃過的景色，只專心觀察車子「長期的平均軌跡」；一旦發現車子長期偏右，他就慢慢幫你把方向盤往左拉一點（負回授 $G_{mf}$），這樣你就能放心加速（放大高頻資料）而不會偏離中心線。

### 面試必考點
1. **問題：為什麼 Offset Cancellation 迴路中的低通極點 $\frac{1}{R_F C_F}$ 必須設計得非常低（例如筆記中標示的 $10\sim 100\text{Hz}$）？**
   → **答案**：為了容忍長串連績的 0 或 1 (Consecutive Identical Digits, CID)。例如 PRBS31 測試圖樣最長有 31 個連續相同位元。如果低通 Corner 頻率太高，迴路反應太快，會把這串連續的位元誤判為 DC Offset 並將其消除，導致訊號基準線漂移 (Baseline Wander)，進而使眼圖閉合並產生 Bit Error。

2. **問題：如果系統規定採用 8b/10b 編碼傳輸，對這套 Offset Cancellation 電路的規格有什麼幫助？**
   → **答案**：8b/10b 編碼強制達成了直流平衡 (DC Balance)，並限制了最長連續相同位元最多只有 5 個。這代表訊號頻譜在 DC 附近是「沒有能量」的（如筆記右側所指）。因此，我們可以將系統的 High-pass corner 設計得更高，進而允許使用較小的 $R_F$ 和 $C_F$。這在實際晶片設計中能大幅節省佈局 (Layout) 上最佔面積的被動元件。

3. **問題：請說明 Closed-loop 的 DC Gain 與 Mid-band Gain 的大小關係，並解釋為何需要這種差異？**
   → **答案**：DC Gain 僅為 $\frac{G_m}{G_{mf}}$，而 Mid-band Gain 高達 $A_{tot} G_m R_1$。這種巨大差異是為了「頻段分工」。在 DC 頻段，我們刻意讓負回授極強（壓低 Gain）以消滅硬體不匹配帶來的 Offset；但在 Mid-band（Data 實際存在的頻段），我們利用電容高頻短路的特性將回授切斷，讓放大器以滿血的開迴路增益去放大微弱的高速訊號。

**記憶口訣：**
「**低頻抓偏差，高頻放信號；RC 夠遲鈍，連零才不掉**」（低頻濾波專抓 Offset，高頻斷開回授放大 Data；RC 時間常數要夠大、反應夠慢，遇到長串連續 0 或 1 才不會漂移被吃掉）。
