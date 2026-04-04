# PLL-L22-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L22-P1.jpg

---


---
## Quadrature VCOs (QVCO) 與 Push-Push Oscillator

### 數學推導
本頁筆記主要推導正交壓控震盪器 (Quadrature VCO, QVCO) 的相位關係，以及 Push-Push 震盪器的倍頻原理。

**1. QVCO 的正交相位推導：**
假設有兩個完全相同的 VCO，輸出分別為 $X$ 與 $Y$。我們將 $Y$ 乘上 $-\alpha$ 的比例耦合進 $X$ 的迴路，並將 $X$ 乘上 $+\alpha$ 的比例耦合進 $Y$ 的迴路。
設震盪器核心的轉移函數為 $A(s)$：
1. 對於 $X$ 的迴路：$(X - \alpha Y) \cdot A = X$
2. 對於 $Y$ 的迴路：$(Y + \alpha X) \cdot A = Y$

將兩式中的 $A$ 提出來等價：
$$A = \frac{X}{X - \alpha Y} = \frac{Y}{Y + \alpha X}$$
交叉相乘：
$$X(Y + \alpha X) = Y(X - \alpha Y)$$
$$XY + \alpha X^2 = XY - \alpha Y^2$$
$$\alpha X^2 = -\alpha Y^2$$
$$X^2 + Y^2 = 0 \implies X^2 = -Y^2 \implies X = \pm jY$$
**結論：** $X$ 與 $Y$ 相差一個 $j$ (即 90° 相位差)，證明了這種互連架構能產生 Quadrature outputs。

**2. 頻率偏移與相位條件：**
將 $Y = -jX$ 代回第 1 式：
$$A = \frac{X}{X - \alpha(-jX)} = \frac{1}{1 + j\alpha}$$
要滿足巴克豪森準則 (Barkhausen Criterion)，迴路相移必須為 360° 的整數倍。觀察 $A$ 的相位：
$$\angle A(s) = -\tan^{-1}(\alpha)$$
同理，若代入 $Y = jX$，則 $\angle A(s) = +\tan^{-1}(\alpha)$。
這代表 LC Tank 必須提供 $\pm \tan^{-1}\alpha$ 的額外相位移，導致實際震盪頻率 $\omega$ 必須偏離 LC Tank 的自然共振頻率 $\omega_0$（如筆記中圖表所示）。

### 單位解析
**公式單位消去：**
- **轉移函數 $A(s) = -G_m \cdot Z(s)$**
  - $G_m$ (轉導) 單位：$[A/V]$
  - $Z(s)$ (阻抗) 單位：$[V/A]$ 或 $[\Omega]$
  - $A(s)$ 單位：$[A/V] \times [V/A] = [1]$ (無因次增益純量)
- **相位移 $\angle A(s) = \pm \tan^{-1}\alpha$**
  - $\alpha$ (耦合比例) 單位：$[1]$ (無因次)
  - $\angle A(s)$ 單位：$[rad]$ 或 $[^\circ]$ (角度)

**圖表單位推斷：**
📈 **圖表一：QVCO 頻率響應圖 (Bode Plot)**
- **X 軸**：角頻率 $\omega$ $[rad/s]$ 或 $[GHz]$，典型高速 SerDes 範圍為數十 GHz (例如 $2\pi \times 14$ GHz)。
- **Y 軸 (上)**：阻抗振幅 $|Z(j\omega)|$ $[\Omega]$，在 $\omega_0$ 時有最大值。
- **Y 軸 (下)**：相位移 $\angle A(s)$ $[^\circ]$，在 $\omega_0$ 時為 0°，偏離 $\omega_0$ 時產生 $\pm \tan^{-1}\alpha$ 的相移。

📈 **圖表二：Push-Push Oscillator 波形圖**
- **X 軸**：時間 $t$ $[ps]$，典型範圍 0~100 ps。
- **Y 軸**：電壓 $V$ $[V]$，展示了基頻 (Fundamental) 波形與 Tail node (節點 P) 的兩倍頻 (2nd Harmonic) 輸出。典型擺幅約 0~1V。

### 白話物理意義
- **QVCO**：把兩個震盪器「一正一反」互相牽拖，它們為了妥協只能以相差 90 度的姿勢一起震動，但代價是無法在最省力的自然頻率 ($\omega_0$) 下工作。
- **Push-Push Oscillator**：利用差動電路在尾巴 (Tail node) 經歷「左邊漏電一次、右邊漏電一次」的特性，直接從尾巴抽出兩倍頻率的訊號。

### 生活化比喻
- **QVCO**：就像兩人三腳跑步，A 往左拉 B，B 往右推 A，兩人為了不跌倒，步伐只能剛好差半拍 (90度)。但因為互相牽制，跑的速度（頻率）就不會是各自最自然的配速，跑起來會比較吃力 (Phase Noise 變差)。
- **Push-Push Osc**：想像一個蹺蹺板，左邊壓下去一次，右邊壓下去一次，雖然蹺蹺板兩端是一上一下 (基頻)，但蹺蹺板中間的支點 (Tail node) 會感受到「兩次」震動。我們直接去摸支點，就能得到兩倍的震動頻率。

### 面試必考點
1. **問題：為什麼傳統的 Parallel-coupled QVCO 的 Phase Noise 通常比較差？（對應筆記的 Not recommended）**
   - **答案：** 因為為了產生 $\pm \tan^{-1}\alpha$ 的相位移，震盪頻率 $\omega$ 必須偏離 LC Tank 的自然共振頻率 $\omega_0$。在偏離 $\omega_0$ 的地方，LC Tank 的等效並聯阻抗 $R_p$ 會下降，Quality Factor (Q 值) 降低，導致 Phase Noise 嚴重惡化。
2. **問題：Push-Push Oscillator 在 Tail node (節點 P) 萃取訊號有什麼優缺點？**
   - **答案：** 
     - 優點 (V)：能用極低的功耗達到頻率翻倍 (Freq. Doubled, Low Power)。
     - 缺點 (X)：輸出是單端 (Single-ended output)，極易受共模雜訊 (Common-mode noise) 和電源雜訊干擾，且 Phase Noise 表現通常較差。
3. **問題：在 Push-Push Oscillator 中，Tail node 的 Small signal 和 Large signal 行為有何不同？**
   - **答案：** 
     - 在小訊號 (Small signal) 分析下，Tail node 是虛擬接地 (Virtual ground)，沒有基頻訊號。
     - 在大訊號 (Large signal) 操作下，電晶體的非線性 (如開關切換) 會在 Tail node 產生強烈的偶數次諧波 (主要是 2nd harmonic)。

**記憶口訣：**
「QVCO 互拉差九十，偏離中心 Q 值失；Push-Push 尾巴取兩倍，單端雜訊要防備。」
