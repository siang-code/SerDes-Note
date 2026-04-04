# TIA-L2-P1

> 分析日期：2026-04-04
> 原始圖片：images/TIA-L2-P1.jpg

---

這份筆記涵蓋了高速光通訊接收端（Optical Receiver）前端最核心的元件：**光電二極體（Photodiode, PD）的電氣與光學特性**。在做 TIA（Transimpedance Amplifier）設計時，PD 就是你的 source，你不懂 source 的特性，TIA 絕對做不好。我們直接進入嚴格的工程分析。

---
## [高速 TIA 輸入源：光電二極體 (Photodiode) 特性分析]

### 數學推導
這裡筆記列出了幾個關鍵定義，作為資深工程師，我們不能只背公式，要推導其背後的物理機制。

**1. 響應度 (Responsivity, $R$) 與波長的關係推導**
筆記中寫了 $R \triangleq \text{Induced } I / \text{Input light power}$，並舉例 1.55μm 的 R 大於 850nm 的 R。為什麼？
*   **Step 1:** 單一光子能量 $E_p$ 由普朗克常數 $h$、光速 $c$ 與波長 $\lambda$ 決定：
    $$E_p = h \nu = \frac{h c}{\lambda}$$
*   **Step 2:** 若輸入光功率為 $P_{in}$，每秒入射的光子數 $N_{ph}$ 為：
    $$N_{ph} = \frac{P_{in}}{E_p} = \frac{P_{in} \cdot \lambda}{h c}$$
*   **Step 3:** 假設量子效率為 $\eta$（多少比例的光子能成功激發出電子電洞對），產生的光電流 $I_p$（$q$ 為基本電荷）為：
    $$I_p = q \cdot (\eta \cdot N_{ph}) = q \cdot \eta \cdot \frac{P_{in} \cdot \lambda}{h c}$$
*   **Step 4:** 整理得到 Responsivity 的終極公式：
    $$R = \frac{I_p}{P_{in}} = \frac{\eta \cdot q \cdot \lambda}{h c}$$
    *(推導結論：在量子效率 $\eta$ 相似的情況下，Responsivity $R$ 與波長 $\lambda$ 成正比。這完美解釋了為何筆記中 $1.55\mu m$ 的 $0.9 A/W$ 會大於 $850nm$ 的 $0.5 A/W$。因為長波長光子能量低，同樣 1W 功率下光子數量更多，打出的電子也更多。)*

**2. 為什麼反向偏壓 ($V_{RB}$) 能提升頻寬 (f)？**
筆記左下角圖示 $V_{RB} = -4V$ 的頻寬優於 $V_{RB} = 0V$。
*   **Step 1:** PN 接面的空乏區寬度 $W_{dep}$ 與反向偏壓 $V_R$ 相關：
    $$W_{dep} \propto \sqrt{V_0 + V_R}$$ ($V_0$ 為內建電位)
*   **Step 2:** PD 的寄生接面電容 $C_j$ 視為平行板電容：
    $$C_j = \frac{\epsilon A}{W_{dep}} \propto \frac{1}{\sqrt{V_0 + V_R}}$$
    *(推導結論：反向偏壓 $V_R$ 越大，空乏區越寬，$C_j$ 越小。對於 TIA 而言，輸入極點 $f_{p,in} \approx \frac{1}{2\pi R_{in} (C_j + C_{pad} + C_{TIA})}$，降低 $C_j$ 直接推升了系統的 3dB 頻寬。)*

### 單位解析
**公式單位消去：**
1. **Responsivity ($R$)**:
   $$R = \frac{I_{induced}}{P_{optical}} \Rightarrow \frac{[A]}{[W]} = \mathbf{[A/W]}$$
   *(註：在光通訊中，光功率常以 dBm 表示，計算電流時需先轉回 Linear scale 的 Watt。)*

2. **Extinction Ratio ($ER$)**:
   $$ER = \frac{P_1}{P_0} \Rightarrow \frac{[W]}{[W]} = \mathbf{1 \ (無因次)}$$
   *(註：業界規格通常取 $\log$ 轉換為 $\mathbf{[dB]}$，即 $ER_{dB} = 10 \log_{10}(P_1/P_0)$。)*

**圖表單位推斷：**
📈 圖表單位推斷（右上：光電二極體 I-V 曲線）：
- **X 軸**：二極體跨壓 $V_D$ **[V]**，典型範圍 **-5V ~ +1V**（SerDes 應用主要操作在第三象限的反向偏壓區，如筆記標示的 -5V）。
- **Y 軸**：電流 $I$ **[μA] 或 [mA]**，典型範圍 **-2mA ~ 0**（取決於入射光功率，光電流方向與 forward current 相反）。

📈 圖表單位推斷（左下：頻率響應 Responsivity vs. f）：
- **X 軸**：頻率 $f$ **[GHz]**，典型範圍 **0 ~ 50 GHz**（視通訊協定如 25G/50G/112G PAM4 而定）。
- **Y 軸**：交流響應度 magnitude $|R(f)|$ **[A/W] 或正規化的 [dB]**，典型範圍 DC 處為 **0.5 ~ 0.9 A/W**，往高頻遞減。

### 白話物理意義
在 TIA 面前，Photodiode 加上反向偏壓後，就是一個**「帶有寄生電容的高速光控電流源」**；反壓催越大，電容就越小，高頻訊號才不會被電容吃掉。

### 生活化比喻
光電二極體就像是一座**「太陽能水塔」**。
光（Optical Power）就是驅動抽水馬達的能量，光越強，抽出來的水流（電流）就越大，這轉換效率就是 Responsivity。
而「反向偏壓」就像是水塔排水管的**斜率**。如果斜率是平的（$V_{RB}=0$），水流得慢（載子傳輸慢），且容易積水（寄生電容大）；如果你把排水管弄得很陡（$V_{RB}=-4V$），水一抽上來瞬間就流下去了，反應極快，高頻寬就這樣來了。

### 面試必考點
1. **問題：在 TIA 系統中，為什麼光電二極體 (PD) 必須施加足夠的反向偏壓 (Reverse Bias)？只加一點點不行嗎？**
   → **答案：** 有兩個致命原因。第一，反向偏壓能擴張空乏區，大幅降低 PD 的接面電容 ($C_j$)，這是提升 TIA 輸入端 RC 頻寬的關鍵。第二，強大的電場能讓光激發的電子電洞對以「飽和漂移速度 (Saturation velocity)」移動，縮短 Transit time。如果不夠大，高頻響應會立刻劣化，眼圖會直接閉合。

2. **問題：如果系統規定使用 1.55μm 而不是 850nm 波長的雷射，對你的 TIA 設計會有什麼好處或挑戰？**
   → **答案：** 好處是 1.55μm 的 Responsivity 較高（例如 0.9 A/W vs 0.5 A/W），同樣的光功率下能產生更大的光電流，提升了 SNR。挑戰在於 1.55μm 通常使用 InGaAs 材質，其寄生電容或暗電流 (Dark current) 可能與 850nm 的 Si/GaAs 系統不同，且較大的輸入電流會吃掉 TIA 更多的電壓餘裕 (Voltage Headroom)，必須注意 TIA 的 overload limit。

3. **問題：光通訊模組規格書上的 Extinction Ratio (ER) 如果太低（例如 $P_0$ 很大），對 TIA 電路設計有什麼毀滅性打擊？**
   → **答案：** ER 太低代表傳送 Logic 0 時仍有很強的背景光，這會產生一個巨大的直流光電流 (DC Photocurrent)。這個 DC 電流不僅不帶訊號資訊，還會佔用 TIA 寶貴的 Voltage Headroom，迫使 TIA 提早進入非線性區或飽和。同時，龐大的 DC 電流會帶來巨大的 Shot Noise，嚴重吃掉系統的 Sensitivity (靈敏度)。

**記憶口訣：**
**「逆壓降C提頻寬，長波光子電流大，消光太低吃餘裕。」**
（反向偏壓降低電容提升頻寬；長波長光子數多所以響應電流大；消光比太低會有過大DC電流佔用電壓餘裕）。
