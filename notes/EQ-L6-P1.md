# EQ-L6-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L6-P1.jpg

---


---
## Multi-Tap FIR Filter FFE with Zero-Forcing

### 數學推導
Zero-Forcing (迫零) FFE 的核心概念是透過線性組合，將特定取樣點的符元間干擾 (ISI) 強制消滅。

1. **定義系統與交換律**：
   根據線性非時變 (LTI) 系統的卷積交換律，筆記中點出一個關鍵：「先乘 $\alpha$ 再經過 channel = 先經過 channel 找出形狀，再乘上 $\alpha$」。
   這代表 TX 端的 FFE 可以等效為：先讓單一脈衝通過通道得到脈衝響應 $x(t)$，再將其延遲並乘上權重 $\alpha_i$ 進行疊加。

2. **建立疊加方程式**：
   等效的接收端脈衝響應 $y(t)$ 為各 Tap 的線性組合：
   $$ y(t) = \alpha_{-1} \cdot x(t+T_b) + \alpha_0 \cdot x(t) + \alpha_1 \cdot x(t-T_b) $$
   *(註：$\alpha_{-1}$ 乘上的是提早 $T_b$ 的訊號，用來補償前驅干擾 Pre-cursor；$\alpha_1$ 乘上延遲 $T_b$ 的訊號，用來補償後驅干擾 Post-cursor)*

3. **設定 Zero-Forcing 目標**：
   對於 3-tap FFE，我們有 3 個自由度，目標函數是 $y[k] = \begin{cases} 1, & k=0 \\ 0, & \text{else} \end{cases}$。我們強迫 $y[-1]=0, y[0]=1, y[1]=0$。
   代入取樣時間 $t = k T_b$：
   - $k=-1$: $y[-1] = \alpha_{-1} x(0) + \alpha_0 x(-T_b) + \alpha_1 x(-2T_b) = 0$
   - $k=0$: $y[0] = \alpha_{-1} x(T_b) + \alpha_0 x(0) + \alpha_1 x(-T_b) = 1$
   - $k=1$: $y[1] = \alpha_{-1} x(2T_b) + \alpha_0 x(T_b) + \alpha_1 x(0) = 0$

4. **代入數值解聯立方程式**：
   根據筆記上方的脈衝響應圖，讀取各個取樣點的數值：$x(0)=0.85,\ x(-T_b)=0.2,\ x(-2T_b)=0.05 \approx 0,\ x(T_b)=-0.2,\ x(2T_b)=0.1$。
   *(註：此處筆記將微小的 $x(-2T_b)=0.05$ 近似為 $0$ 以簡化計算)*
   轉化為矩陣形式：
   $$ \begin{bmatrix} x(0) & x(-T_b) & x(-2T_b) \\ x(T_b) & x(0) & x(-T_b) \\ x(2T_b) & x(T_b) & x(0) \end{bmatrix} \begin{bmatrix} \alpha_{-1} \\ \alpha_0 \\ \alpha_1 \end{bmatrix} = \begin{bmatrix} 0 \\ 1 \\ 0 \end{bmatrix} $$
   $$ \begin{bmatrix} 0.85 & 0.2 & 0 \\ -0.2 & 0.85 & 0.2 \\ 0.1 & -0.2 & 0.85 \end{bmatrix} \begin{bmatrix} \alpha_{-1} \\ \alpha_0 \\ \alpha_1 \end{bmatrix} = \begin{bmatrix} 0 \\ 1 \\ 0 \end{bmatrix} $$

5. **求得最佳係數**：
   解此反矩陣，可得 FFE 權重：
   $$ \begin{bmatrix} \alpha_{-1} \\ \alpha_0 \\ \alpha_1 \end{bmatrix} = \begin{bmatrix} -0.25 \\ 1.05 \\ 0.28 \end{bmatrix} $$

### 單位解析
**公式單位消去：**
- $y_k = \sum \alpha_j \cdot x_{k-j}$
  - $\alpha_j$: FFE Tap weights (係數)，物理意義為電壓增益，單位為 `[V/V]` (無因次)
  - $x_{k-j}$: 通道脈衝響應取樣值，物理意義為接收端電壓，單位為 `[V]`
  - $y_k$: 均衡後的取樣點電壓，單位為 `[V]`
  - 消去過程：`[V/V] × [V] = [V]`，等式兩邊單位一致，驗證無誤。

**圖表單位推斷：**
📈 通道脈衝響應圖 (上圖)
- X 軸：時間 `[Unit Interval (UI)]` 或 `[Tb]`，典型範圍 -2 UI ~ +3 UI
- Y 軸：脈衝電壓幅度 `[V]` 或 歸一化幅度 `[V/V]`，典型範圍 -0.2 ~ 0.85

📈 FFE 波形疊加圖 (下圖)
- X 軸：時間 `[Unit Interval (UI)]` 或 `[Tb]`，標示了 Pre-cursor, Main-cursor, Post-cursor 的相對位置
- Y 軸：加權後的電壓幅度 `[V]`，展示了三個乘上權重後的波形如何相加抵銷。

### 白話物理意義
Zero-Forcing FFE 就是在發射端故意送出幾個特定大小的「反向干擾波」，讓這些波在經過通道衰減和延遲後，剛好在接收端取樣的瞬間把原本的 ISI 干擾抵消得一乾二淨（強迫歸零）。

### 生活化比喻
這就像是在一個有嚴重回音的音樂廳演講。你預先測試知道「每喊一個字，前後0.5秒都會有回音干擾」。所以你學聰明了，在講每一個字的時候，都故意「提早」和「延後」發出一個反相的、小聲的聲音。雖然你自己講得比較吃力，但台下的聽眾在特定的瞬間，聽到的聲音剛好完美抵消了回音，變得無比清晰。這就是 Zero-Forcing (把回音逼近零)。

### 面試必考點
1. **問題：Zero-Forcing (ZF) FFE 在實際應用上有什麼致命缺點？**
   → 答案：**Noise Enhancement (雜訊放大)**。ZF 演算法的唯一目標是把特定點的 ISI 強制變成零，如果通道頻率響應有很深的 Null (嚴重衰減)，它會給予極高的增益來強硬補償，這會連帶把通道中的高頻雜訊 (Thermal noise, Crosstalk) 放大到蓋過訊號。實務上常改用 **MMSE (Minimum Mean Square Error)** 演算法。
2. **問題：筆記中強調「先乘 $\alpha$ 再經過 channel = 先經過 channel 再乘 $\alpha$」，這是基於什麼前提？如果前提不成立會怎樣？**
   → 答案：這是基於通道是一個 **LTI (線性非時變) 系統**的前提，符合卷積交換律。這意味著 TX FFE (Pre-emphasis) 和 RX FFE 在數學上是等效的。如果通道包含非線性效應 (例如 TX driver 的非線性或大訊號飽和)，這個等效就不成立，兩者的補償結果就會產生差異。
3. **問題：一個 N-tap 的 FFE，最多可以強迫消滅幾個 ISI 點？**
   → 答案：**(N-1) 個**。N 個 tap 代表有 N 個聯立方程式 (自由度)。其中 1 個自由度必須用來鎖定 Main cursor 的目標值 (例如 $y[0]=1$)，剩下的 (N-1) 個自由度才能用來 forcing 旁邊的 ISI 為 0。

**記憶口訣：**
ZF FFE 記住「**N缺1殺手**」：N個 Tap 只有 N-1 個能用來殺 ISI，1個要留給 Main cursor；但殺手只管殺 ISI，不管背景有多吵，容易造成 **Noise Enhancement (雜訊爆炸)**。
