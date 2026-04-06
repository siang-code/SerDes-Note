# TIA-L11-P2

> 分析日期：2026-04-06
> 原始圖片：images/done/TIA-L11-P2.jpg

---


---
## Inverter-Based TIA 理論與 Blackman 阻抗分析

### 數學推導
1. **Asymptotic Return Ratio 計算閉迴路增益 ($R_T$)**
   根據公式：$R_T = G_\infty \frac{T}{1+T} + G_0 \frac{1}{1+T}$
   - **理想前饋增益 ($G_\infty$)**: 假設轉導 $g_m \to \infty$，輸入端成為 Virtual Ground（虛擬地）。輸入電流 $I_{in}$ 無法流進輸入阻抗為零的放大器，全部流經 $R_F$，因此輸出電壓 $V_{out} = -I_{in} R_F \Rightarrow G_\infty = -R_F$。
   - **直接饋通增益 ($G_0$)**: 假設 $g_m = 0$ (主動元件失效)，輸入電流 $I_{in}$ 流過 $R_F$ 到達輸出端，再流經輸出電阻 $r_{out} = (r_{op}//r_{on})$ 下地。輸出電壓 $V_{out}$ 僅為跨在輸出電阻上的電壓，故 $V_{out} = I_{in} \times (r_{op}//r_{on}) \Rightarrow G_0 = r_{op}//r_{on}$。
     *(助教點評：筆記中將 $G_0$ 算式裡的 $R_F+$ 劃掉是正確的覺悟，因為 $V_{out}$ 量測點不包含 $R_F$ 上的壓降，訊號是直接 Feedthrough 到輸出節點。)*
   - **迴路增益 ($T$)**: 將 Gate 斷開，灌入測試電壓 $V_T$，依賴電流源產生 $(g_{mp}+g_{mn})V_T$ 抽載。因輸入端視為理想電流源（開路），沒有電流流過 $R_F$，故回授電壓等於輸出電壓 $V_{out} = (g_{mp}+g_{mn})V_T(r_{op}//r_{on})$，得出 $T = (g_{mp}+g_{mn})(r_{op}//r_{on})$。
   - 綜合結果：$R_T \approx -R_F$ (當 $T \gg 1$ 時)。

2. **Blackman's Impedance Formula 阻抗分析 (⚠️ 助教強力糾錯區)**
   公式：$Z = Z(g_m=0) \frac{1 + T_{short}}{1 + T_{open}}$
   - **輸入阻抗 $R_{in}$**:
     - $Z_{in}(g_m=0) = R_F + (r_{op}//r_{on})$。
     - $T_{short}$ (輸入短路): Gate 接地，主動元件不反應 $\Rightarrow T_{short} = 0$。
     - $T_{open}$ (輸入開路): 迴路增益 $T_{open} = (g_{mp}+g_{mn})(r_{op}//r_{on})$。
       *(注意：筆記中此處誤寫為 "open at output"，算 $R_{in}$ 必須對「輸入端」開路，雖因為 $R_s=\infty$ 結果碰巧相同，但觀念錯誤！)*
     - **❌ 筆記致命錯誤**：筆記算出 $R_{in} = \frac{R_F + r_{op}//r_{on}}{1 + g_m r_{out}}$ 後，竟然把分子裡的 $R_F$ 劃掉並近似為 $\frac{1}{g_{mp}+g_{mn}}$！在 TIA 應用中，$R_F$ 是極大的回授電阻，真正的近似必須保留：$R_{in} \approx \frac{R_F}{g_m r_{out}} + \frac{1}{g_{mp}+g_{mn}} = \frac{R_F}{A_v} + \frac{1}{g_m}$。只有當 $R_F=0$ (即 Diode-connected) 時，阻抗才會只剩 $1/g_m$。
   - **輸出阻抗 $R_{out}$**:
     - $Z_{out}(g_m=0) = r_{op}//r_{on}$。
     - $T_{short}$ (輸出短路): 回授電壓被強制短路歸零 $\Rightarrow T_{short} = 0$。
     - $T_{open}$ (輸出開路): 等同於 $T \Rightarrow T_{open} = (g_{mp}+g_{mn})(r_{op}//r_{on})$。
     - $R_{out} = \frac{r_{op}//r_{on}}{1 + g_m r_{out}} \approx \frac{1}{g_{mp}+g_{mn}}$。*(這裡近似為 $1/g_m$ 才是合理的，因為分子只有 $r_{out}$)*。

### 單位解析
**公式單位消去：**
- $G_0 = \frac{V_{out}}{I_{in}} \Rightarrow \frac{[\text{V}]}{[\text{A}]} = [\Omega]$；推導結果 $r_{op}//r_{on}$ 單位為 $[\Omega]$，兩邊完全吻合。
- $T = (g_{mp}+g_{mn}) \times (r_{op}//r_{on}) \Rightarrow [\text{A/V}] \times [\Omega] = [\text{A/V}] \times [\text{V/A}] = [1]$ (無因次量，符合 Loop Gain / Return Ratio 的定義)。
- **助教糾錯的單位驗證**：$R_{in} \approx \frac{R_F}{A_v} + \frac{1}{g_m} \Rightarrow \frac{[\Omega]}{[1]} + \frac{1}{[\text{A/V}]} = [\Omega] + [\Omega] = [\Omega]$ (由此可證必須保留 $\frac{R_F}{A_v}$ 項，物理單位才站得住腳)。

**圖表單位推斷：**
本頁無圖表。

### 白話物理意義
Blackman 阻抗公式告訴我們：在 Shunt (並聯) 負回授的節點上，回授機制就像一個「阻抗壓縮機」，會無情地把從該節點看進去的開迴路阻抗除以 $(1+T)$，從而吸收更多電流、減小 RC 延遲並大幅提升頻寬。

### 生活化比喻
把 Inverter-based TIA 想像成一個「水庫水位自動調節系統」。光電流 $I_{in}$ 是外面的暴雨，輸入端寄生電容 $C_{in}$ 是水庫。如果不加 $R_F$ 負回授（開迴路），暴雨一來水庫水位（輸入電壓）就會狂飆，反應超慢（RC Delay 大）。加上 $R_F$ 和放大器後，就像裝了超級抽水馬達，只要水位稍微上升一毫米（小電壓變化），馬達就立刻把水抽走（輸出反相大電壓，透過 $R_F$ 將電流抽離）。水庫水位因此看起來「幾乎不動」（Virtual Ground），這就是輸入阻抗被除以 $(1+T)$ 降低的奧妙。

### 面試必考點
1. **問題：請說明 TIA 加上負回授 $R_F$ 後，對輸入阻抗 $R_{in}$ 的影響？如果 $R_F$ 很大，可以直接近似為 $1/g_m$ 嗎？**
   → **答案：** $R_{in}$ 會被降低 $(1+T)$ 倍，變為 $(R_F+r_{out})/(1+T)$。如果 $R_F$ 很大，**絕對不可**近似為 $1/g_m$！正確的近似是 $R_F/A_v + 1/g_m$。只有 $R_F=0$ (Diode-connected) 時才是 $1/g_m$。這會直接影響 TIA 主極點 (Dominant Pole) 的頻寬計算。
2. **問題：請用 Asymptotic Return Ratio 解釋 $G_0$ (Direct Feedthrough) 在高頻或極低增益時的影響。**
   → **答案：** $G_0$ 代表當主動放大器失效 ($g_m=0$) 時，訊號直接透過被動元件 $R_F$ 跑到輸出的路徑。在 TIA 中 $G_0 = r_{op}//r_{on}$。如果 Loop gain 隨頻率下降而不夠大，$G_0$ 路徑會導致實際閉迴路增益偏離理想的 $-R_F$，甚至在極高頻時 Feed-forward 路徑會產生右半平面零點 (RHP Zero) 影響穩定度。
3. **問題：為什麼光通訊 TIA 喜歡用 CMOS Inverter 架構，而不單純用 CS (Common-Source) Amplifier 配電阻負載？**
   → **答案：** Inverter 架構具有 Current Reuse (電流重複利用) 的優勢，在消耗相同的靜態電流下，PMOS 和 NMOS 同時提供轉導，總轉導變為 $g_{mp}+g_{mn}$。這不僅能最大化 $A_v$、進一步壓低 $R_{in}$ 以提升頻寬，還能有效降低 Input-referred noise。

**記憶口訣：**
Blackman 算阻抗：「開短比一比，回授壓低它」。
TIA 增益兩路徑：「理想走外圈 ($-R_F$)，死掉走內圈 ($r_{out}$)」。
TIA 輸入阻抗防呆：「$R_F$ 除以 $A$，千萬別只剩 $1/g_m$」。
