# EQ-L22-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L22-P1.jpg

---


---
## DFE Adaptation: Sign-Sign LMS 演算法

### 數學推導
在高速 SerDes 中，為了自動找出最佳的 DFE (Decision Feedback Equalizer) 權重 $\alpha_k$，我們需要一個自適應 (Adaptation) 機制。目標是最小化誤差的平方 $e^2$。

1. **定義 DFE 輸出與誤差：**
   DFE 的輸出方程式為輸入減去歷史判決的加權總和：
   $$y(t) = x(t) - \alpha_1\hat{y}[n-1] - \alpha_2\hat{y}[n-2] - \dots - \alpha_N\hat{y}[n-N]$$
   這裡 $y(t)$ 是一個包含多變數 $\{\alpha_1, \dots, \alpha_N\}$ 的函數。
   定義當下取樣點的誤差 $e$ 為等化後訊號 $y(t)$ 與理想判決值 $\hat{y}[n]$ 的差：
   $$e = y(t) - \hat{y}[n]$$

2. **尋找梯度 (Gradient)：**
   為了最小化代價函數 (Cost function) $e^2$，我們對特定的抽頭權重 $\alpha_k$ 偏微分，以找出誤差曲面的斜率：
   $$\frac{\partial e^2}{\partial \alpha_k} = 2 \cdot e \cdot \frac{\partial e}{\partial \alpha_k}$$
   將 $e$ 代入後面的偏微分項：
   $$\frac{\partial e}{\partial \alpha_k} = \frac{\partial (y(t) - \hat{y}[n])}{\partial \alpha_k} = \frac{\partial y(t)}{\partial \alpha_k}$$
   （因為理想判決 $\hat{y}[n]$ 與當前的權重 $\alpha_k$ 無關）
   再將 $y(t)$ 代入：
   $$\frac{\partial y(t)}{\partial \alpha_k} = \frac{\partial (x(t) - \dots - \alpha_k\hat{y}[n-k] - \dots)}{\partial \alpha_k} = -\hat{y}[n-k]$$
   綜合以上，得到梯度的精確值：
   $$\frac{\partial e^2}{\partial \alpha_k} = -2 \cdot e \cdot \hat{y}[n-k]$$

3. **最陡下降法 (Steepest Descent)：**
   要走向谷底，必須往梯度的「反方向」更新權重：
   - 如果 $\frac{\partial e^2}{\partial \alpha_k} > 0$（斜率為正），代表 $\alpha_k$ 太大了，需要減小：$\alpha_k[n+1] = \alpha_k[n] - \Delta$
   - 如果 $\frac{\partial e^2}{\partial \alpha_k} < 0$（斜率為負），代表 $\alpha_k$ 太小了，需要增加：$\alpha_k[n+1] = \alpha_k[n] + \Delta$
   其中 $\Delta$ 是一個正數的更新步長。

4. **簡化為 Sign-Sign LMS (Least Mean Square)：**
   在高頻電路中，精確計算乘法 $e \times \hat{y}$ 太過昂貴 ("Need a extremely simple/extreme cheap way")。因此，我們只提取梯度的「正負號 (Sign)」：
   $$\alpha_k[n+1] = \alpha_k[n] - \Delta \cdot \text{sign}\left\{ \frac{\partial e^2}{\partial \alpha_k} \right\}$$
   代入步驟 2 算出的梯度，並把常數 $-2$ 融進 sign 函數中（負號會讓 sign 反相）：
   $$\alpha_k[n+1] = \alpha_k[n] - \Delta \cdot \text{sign}\{ -2 \cdot e \cdot \hat{y}[n-k] \}$$
   $$\Rightarrow \alpha_k[n+1] = \alpha_k[n] + \Delta \cdot \text{sign}\{ e[n] \cdot \hat{y}[n-k] \}$$
   在硬體實現上，這變成只需判斷 $e$ 的正負（由 Error Comparator 提供）和 $\hat{y}$ 的正負（Data 本身），兩者做簡單的邏輯運算即可決定 $\alpha_k$ 要 $+1$ LSB 還是 $-1$ LSB。

### 單位解析

**公式單位消去：**
*   **$y(t) = x(t) - \alpha_k\hat{y}[n-k]$**：若 DFE 是電壓相加架構，$x(t)$ 與 $y(t)$ 為 $[V]$。$\hat{y}$ 是數位判決（通常視為無單位 $[1]$ 或 $\pm 1$），因此權重 $\alpha_k$ 必須等效為電壓單位 $[V]$，才能 $[V] - [V] \cdot [1] = [V]$。
*   **$e = y(t) - \hat{y}[n]$**：誤差電壓，單位為 $[V]$。
*   **$\frac{\partial e^2}{\partial \alpha_k}$**：$e^2$ 單位為 $[V^2]$，$\alpha_k$ 為 $[V]$。梯度單位為 $[V^2] / [V] = [V]$。
*   **$\alpha_k[n+1] = \alpha_k[n] + \Delta \cdot \text{sign}(...)$**：$\alpha_k$ 為 $[V]$，$\text{sign}()$ 輸出無單位 $[1]$，故更新步長 $\Delta$ 的單位也是 $[V]$，在數位控制中常對應到 DAC 的 $1\text{ LSB}$ 電壓值。單位吻合：$[V] = [V] + [V] \cdot [1]$。

**圖表單位推斷：**
*   📈 **右上角圖表（被劃掉的牛頓法）：**
    *   **X 軸**：任意權重 $\alpha$ 變數，單位 $[V]$ 或 $[LSB]$。
    *   **Y 軸**：函數值（可能是 Error $e$ 或 $y$），單位 $[V]$。
*   📈 **中間圖表（誤差平方與權重的拋物線關係）：**
    *   **X 軸**：第 $k$ 個 Tap 的權重 $\alpha_k$，單位 $[V]$ 或 DAC $[LSB]$，典型範圍可能是 $\pm 100\sim300\text{ mV}$。
    *   **Y 軸**：均方誤差 $e^2$，單位 $[V^2]$，必為正值。
    *   **圖中特徵**：展示了權重如何以固定步長 $\Delta$（標示為 $1\text{ LSB}$）逼近谷底。筆記中標示「最後一直跳」，代表在最佳點附近無法完全靜止，會產生 $\pm 1\text{ LSB}$ 的穩態漣波 (Steady-state ripple / Limit cycle)。

### 白話物理意義
為了解省晶片面積和功耗，晶片不精算誤差有多大，只透過 Error 比較器問「現在補償過頭還是不夠？」，搭配歷史資料的正負號，每次瞎子摸象般固定走一小步 ($\Delta$)，直到走到谷底來回震盪為止。

### 生活化比喻
這就像你在洗澡調熱水（Sign-Sign LMS）。你大腦算不出精確的「目前水溫與目標水溫差了 3.25 度，所以水龍頭要轉 15 度角」（這叫標準演算法，太耗腦力/硬體）。你只會依靠皮膚感覺「太燙了（Error 正負號）」，然後憑直覺把冷水轉開一點點（固定步長 $\Delta$）。等幾秒後如果還是燙，就再轉一點點。最後水溫會在你覺得舒服的溫度附近微調（谷底一直跳）。

### 面試必考點
1. **問題：在 56G/112G 高速 SerDes 中，為什麼 DFE Adaptation 幾乎都採用 Sign-Sign LMS 而不用標準 LMS？**
   * **答案：** 標準 LMS 的權重更新公式需要硬體乘法器來計算誤差 $e$ 與訊號 $\hat{y}$ 的精確乘積，在幾十 GHz 的頻率下，類比乘法器難以設計且極度耗能，數位乘法器則面積太大且有嚴重的 Timing closure 問題。Sign-Sign LMS 只需要提取極性，將乘法簡化為單純的 XOR 邏輯閘操作，再用數位計數器 (Accumulator) 累加即可，實現上 "extremely simple / extreme cheap"。
2. **問題：Sign-Sign LMS 收斂後的穩態行為是什麼？會有什麼副作用？**
   * **答案：** 因為它採用固定步長 $\Delta$ (通常對應 DAC 的 1 LSB)，當它逼近最佳點 (谷底) 時，永遠無法停在斜率為 0 的完美點，而是會在最佳點的兩側以 $\pm 1$ LSB 的幅度來回跳動 (筆記中寫的「最後一直跳」)。這種現象稱為 Limit cycle 或 Dither，會貢獻少許的穩態殘餘誤差 (Residual Error) 到系統的 Jitter 中。
3. **問題：請看筆記公式 $\alpha_k[n+1] = \alpha_k[n] + \Delta \cdot \text{sign}\{ e[n] \cdot \hat{y}[n-k] \}$，這裡面的 $e[n]$ 和 $\hat{y}[n-k]$ 在硬體上分別對應什麼電路？**
   * **答案：** $\hat{y}[n-k]$ 來自主路徑的 Data Slicer (判決器) 後方串接的 Shift Register (提供 delay)；而 $e[n]$ 來自一個與 Data Slicer 平行的 Error Slicer，它的參考電壓會被設定在理想訊號的準位 (Target level)，用來判斷當下類比訊號是高於還是低於理想值，只輸出 $1$ 或 $-1$ (即 $\text{sign}(e)$)。

**記憶口訣：**
> 「乘法太貴吃不消，只看正負最輕巧；XOR 決定加減號，谷底震盪一直跳。」
