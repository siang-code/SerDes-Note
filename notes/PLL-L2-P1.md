# PLL-L2-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L2-P1.jpg

---

這張筆記非常經典，探討了最基礎的 Type-I PLL 架構以及 XOR 相位偵測器（Phase Detector, PD）的核心特性。這是理解後續更複雜的 Charge-Pump PLL (Type-II) 與 PFD 的基本功。身為李老師的助教，我必須說：**這張圖上的「Finite $\Delta\phi$」是面試最愛考的陷阱題！**

以下為你拆解這份筆記：

---
## XOR 邏輯閘相位偵測器與基本鎖相迴路 (XOR Phase Detector & Type-I PLL)

### 數學推導
筆記中畫出了 XOR 邏輯閘作為 PD 的輸入與輸出關係，我們來推導為什麼它會產生三角形的轉換特性（PD Characteristic），以及為什麼 Locked 狀態必定存在靜態相位誤差（Static Phase Error, Finite $\Delta\phi$）。

1. **XOR 相位偵測增益 ($K_{PD}$) 推導：**
   - 假設兩個輸入方波 $V_1, V_2$ 佔空比皆為 50%，邏輯高電位為 $V_{DD}$，低電位為 $0$。
   - 設兩者相位差為 $\Delta\phi$ (範圍落在 $0 \le \Delta\phi \le \pi$)。
   - 在一個完整週期 $2\pi$ 內，兩訊號有兩次轉態交錯。當 $V_1 \neq V_2$ 時，XOR 輸出高電位。
   - 每半個週期中，$V_1$ 與 $V_2$ 電壓不同的時間區間長度剛好等於 $\Delta\phi$。因此一個週期內，總高電位長度為 $2\times\Delta\phi$。
   - 平均輸出電壓 (也就是經由圖中 LPF 濾除高頻後的結果) 計算如下：
     $$\overline{V_{out}} = V_{DD} \times \frac{\text{High Time}}{\text{Total Period}} = V_{DD} \times \frac{2\Delta\phi}{2\pi} = V_{DD} \times \frac{\Delta\phi}{\pi}$$
   - 對 $\Delta\phi$ 微分求得 PD 增益：
     $$K_{PD} = \frac{\partial \overline{V_{out}}}{\partial \Delta\phi} = \frac{V_{DD}}{\pi}$$
   - *（當 $\Delta\phi$ 超過 $\pi$ 時，重疊區域反向減少，因此形成筆記圖中的三角波週期特性）*

2. **Lock 條件與 Static Phase Error (圖右下方結論推導)：**
   - 根據筆記，在鎖定 (Locked) 狀態下，頻率必須完全一致：$\omega_{in} = \omega_{out} = \omega_1$。
   - 假設 VCO 的自由震盪頻率 (Free-running frequency, $V_{ctrl}=0$ 時的頻率) 為 $\omega_0$。
   - 為了讓 VCO 產生 $\omega_1$，它需要一個非零的控制電壓 $V_1$。由 VCO 公式推導：
     $$\omega_1 = \omega_0 + K_{VCO} \times V_{1} \implies V_1 = \frac{\omega_1 - \omega_0}{K_{VCO}}$$
   - 在 Type-I PLL 中，這個 $V_1$ **只能**由 PD 的平均輸出提供，也就是 $V_1 = \overline{V_{out}}$。
   - 將 $V_1$ 帶回 PD 公式：
     $$V_1 = K_{PD} \times \Delta\phi_{lock} \implies \Delta\phi_{lock} = \frac{V_1}{K_{PD}} = \frac{\omega_1 - \omega_0}{K_{VCO} \cdot K_{PD}}$$
   - **結論：** 因為 $\omega_1$ 通常不等於 $\omega_0$，所以必需要有一個 **有限的、非零的相位差 (Finite $\Delta\phi$)**，這就是筆記右下角紅字所強調的現象。

### 單位解析
**公式單位消去：**
- **$K_{PD}$ 單位：** $\overline{V_{out}}[V] \div \Delta\phi[rad] \implies \mathbf{[V/rad]}$
- **$K_{VCO}$ 單位：** $\Delta\omega[rad/s] \div \Delta V_{ctrl}[V] \implies \mathbf{[rad/(s \cdot V)]}$ （業界常簡寫為 $[Hz/V]$，請注意 $2\pi$ 轉換）
- **迴路增益 (Loop Gain) 靜態推導：** $\Delta\phi_{lock}[rad] = \frac{\Delta\omega[rad/s]}{K_{VCO}[rad/(s \cdot V)] \times K_{PD}[V/rad]} = \frac{[rad/s]}{[rad/s]} \implies$ **單位完全消去，留下純角度 [rad]！**

**圖表單位推斷：**
📈 圖一：時間波形圖 ($V_1, V_2, V_{out}$ vs $t$)
- X 軸：時間 $t$ $[ps]$ 或 $[ns]$，典型高速範圍 $100ps \sim 10ns$
- Y 軸：電壓 $V$ $[V]$，典型邏輯準位 $0 \sim 1.0V$

📈 圖二：PD 轉換特性 ($\overline{V_{out}}$ vs $\Delta\phi$)
- X 軸：相位差 $\Delta\phi$ $[rad]$，週期範圍 $-\pi \sim \pi \sim 2\pi$
- Y 軸：平均電壓 $\overline{V_{out}}$ $[V]$，典型範圍 $0 \sim 1.0V$

📈 圖三：VCO 轉換特性 ($\omega_{out}$ vs $V_{ctrl}$)
- X 軸：控制電壓 $V_{ctrl}$ $[V]$，典型範圍 $0 \sim 1.0V$
- Y 軸：輸出角頻率 $\omega_{out}$ $[rad/s]$ (或頻率 $[GHz]$)，例如 $2\pi \times 5GHz$

📈 圖四：鎖定狀態工作點 (左下角局部圖)
- X 軸：穩態相位差 $\Delta\phi$ $[rad]$ (典型如 $0.2 \sim 0.5$ rad)
- Y 軸：穩態控制電壓 $V_1$ $[V]$

### 白話物理意義
XOR 相位偵測器就像一個「算兩人步伐差異的計時器」；而在這種基本 PLL 中，因為馬達 (VCO) 必須要一直含著油門 (非零的 $V_{ctrl}$) 才能維持速度，所以你永遠必須和前車保持一個「固定的距離」($\Delta\phi$)，這叫靜態相位誤差。

### 生活化比喻
把 PLL 想像成「高速公路上的 ACC 自動跟車系統」。
- **PD (XOR)** 是車頭的**測距雷達**，計算你和前車的距離。
- **VCO** 是你的**引擎**。
- 前車以時速 100km/h 巡航 (Ckin)。你要跟上，代表你的車速也要是 100km/h (**Frequency Locked, $\omega_{in} = \omega_{out}$**)。
- 但你的車子如果不踩油門，滑行速度只有 60km/h (Free-running frequency $\omega_0$)。為了維持 100km/h，油門踏板必須踩下 40% 的深度 ($V_{ctrl}$)。
- 雷達系統的邏輯是：「距離越遠，油門踩越深」。所以為了讓油門維持在 40%，你的車子**絕對不可能**跟前車保險桿貼齊 ($\Delta\phi=0$)，你必須永遠落後前車 20 公尺 (**Finite $\Delta\phi$**)，系統才會幫你踩出那 40% 的油門！

### 面試必考點
1. **問題：如果今天溫度變動，VCO 的 free-running frequency $\omega_0$ 變慢了，這個 PLL 在鎖定時會有什麼變化？**
   - **答案：** 根據推導 $\Delta\phi = \frac{\omega_1 - \omega_0}{K_{VCO} K_{PD}}$，若 $\omega_0$ 變小，分子變大，為了產生更大的 $V_{ctrl}$ 去補償變慢的 VCO，**穩態相位誤差 $\Delta\phi$ 會變大！** 這就是筆記寫 `subject to variation` 的原因。PVT 變異會讓每個晶片的穩態相差都不同。
2. **問題：為什麼筆記特別標註 "Operation Range is limited (Capture)"？如果兩頻率一開始差很多會怎樣？**
   - **答案：** XOR 的轉移曲線是週期的。如果初始頻率差太大，相位差會快速累積轉圈 ($\Delta\phi$ 隨時間斜率變化大)，使得 $\overline{V_{out}}$ 變成一個高頻的交流弦波狀信號。這個高頻信號會被後面的 LPF (低通濾波器) 濾掉，導致 $V_{ctrl}$ 變成 0 附近，VCO 根本拉不動。這稱為「Capture Range 過小」，頻寬小的 LPF 會導致系統無法抓到 (Lock) 頻率差太遠的訊號。
3. **問題：為什麼現在的 SerDes 幾乎不用單純的 XOR 當 PD，而改用 PFD + Charge Pump？**
   - **答案：** 三大死穴：(1) XOR 沒有頻率偵測能力，容易 False Lock 到諧波。(2) 依賴佔空比 (Duty Cycle)，如果輸入不是完美的 50%，PD Gain 會嚴重劣化。(3) Type-I 會有前述的 Static Phase Error。Charge Pump 引入了一個完美積分器 (1/s)，把系統變成 Type-II，DC gain 趨近無限大，使得穩態相位誤差可降為零 ($\Delta\phi \to 0$)。

**記憶口訣：**
**「Type-I 靠壓擠、死抱靜差不分離；XOR 怕變 Duty、頻差太大抓不進！」**
