# PLL-L4-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L4-P1.jpg

---

這張筆記非常經典，它點出了基本鎖相迴路（Type-I PLL）最致命的缺陷。如果你在面試聯發科或瑞昱時，連這個 Trade-off 都說不清楚，那就不用期待會有二面了。

作為這堂課的助教，我要求你不要只會背公式，**看懂公式背後的物理限制才是類比 IC 工程師的價值**。以下是針對你這張筆記的嚴格解析。

---
## [Simple PLL Model (基本鎖相迴路模型)]

### 數學推導
這頁筆記的核心在於建立整個 PLL 從輸入到輸出的閉迴路轉移函數（Closed-loop Transfer Function），並將其化為標準二階系統來分析。我們一步步來：

1. **VCO 的積分本質（最重要的一步）**：
   - 物理上，VCO 接收控制電壓 $V_{ctrl}$，輸出的是**頻率** $\omega_{out}$，關係式為 $\omega_{out} = K_{VCO} \cdot V_{ctrl}$。
   - 但是 PLL 迴路比對的是**相位** ($\Phi$)！頻率是相位的微商（$\omega = d\phi/dt$），反過來說，相位是頻率的積分。
   - $\phi_{out}(t) = \int_{-\infty}^{t} \omega_{out}(\tau) d\tau = \int_{-\infty}^{t} K_{VCO} V_{ctrl}(\tau) d\tau$。
   - 轉到 s-domain（Laplace Transform）：**$\Phi_{out}(s) = \frac{K_{VCO}}{s} V_{ctrl}(s)$**。這個 $\frac{1}{s}$ 代表 VCO 本身在系統中貢獻了一個極點（Pole）在原點，這是一個**理想積分器**。

2. **建立閉迴路等式**：
   - 利用回授系統基本公式：$H(s) = \frac{A(s)}{1 + A(s)\beta(s)}$，這裡 $\beta(s)=1$。
   - 開迴路增益 $A(s) = K_{PD} \cdot \left(\frac{1}{1 + s/\omega_{LPF}}\right) \cdot \left(\frac{K_{VCO}}{s}\right)$。
   - 閉迴路轉移函數：
     $$H(s)|_{closed} = \frac{\Phi_{out}}{\Phi_{in}} = \frac{\frac{K_{PD} \cdot K_{VCO}}{s(1 + s/\omega_{LPF})}}{1 + \frac{K_{PD} \cdot K_{VCO}}{s(1 + s/\omega_{LPF})}}$$
   - 分子分母同乘 $s(1 + s/\omega_{LPF})$ 並將分母的 $s/\omega_{LPF}$ 項整理：
     $$= \frac{K_{PD} K_{VCO}}{\frac{s^2}{\omega_{LPF}} + s + K_{PD} K_{VCO}}$$
   - 上下同乘 $\omega_{LPF}$ 化成標準多項式：
     **$$= \frac{K_{PD} K_{VCO} \omega_{LPF}}{s^2 + s \cdot \omega_{LPF} + K_{PD} K_{VCO} \omega_{LPF}}$$**

3. **對應標準二階系統參數**：
   - 標準二階低通轉移函數：$\frac{\omega_n^2}{s^2 + 2\zeta\omega_n s + \omega_n^2}$
   - 比較係數得出兩大關鍵參數：
     - 自然頻率（Natural Frequency）：**$\omega_n = \sqrt{K_{PD} K_{VCO} \omega_{LPF}}$**
     - 阻尼因數（Damping Factor）：$2\zeta\omega_n = \omega_{LPF} \Rightarrow$ **$\zeta = \frac{1}{2}\sqrt{\frac{\omega_{LPF}}{K_{PD} K_{VCO}}}$**

4. **極點分析與致命缺點**：
   - 系統極點公式：$P_{1,2} = (-\zeta \pm \sqrt{\zeta^2 - 1})\omega_n$
   - 注意極點的實部（Real part）：$-\zeta \cdot \omega_n = -\frac{1}{2}\omega_{LPF}$。
   - **這就是筆記最下方結論的由來**：在這種架構下，系統的收斂速度（Settling speed，由極點實部決定）被 Low Pass Filter 的頻寬（$\omega_{LPF}$）**完全綁死**。

### 單位解析
如果單位對不上，你的推導100%是錯的。給我養成隨時檢查單位的習慣！

**公式單位消去：**
- $K_{PD}$ (Phase Detector Gain)：輸入是相位差[rad]，輸出是電壓[V]。$\Rightarrow$ **[V/rad]**
- $K_{VCO}$ (VCO Gain)：輸入控制電壓[V]，輸出角頻率[rad/s]。$\Rightarrow$ **[(rad/s)/V]**
- 開迴路直流增益 $K = K_{PD} \times K_{VCO}$：$[V/rad] \times [(rad/s)/V] = [1/s] = [Hz]$（迴路頻寬的單位）。
- $\omega_n = \sqrt{K_{PD} K_{VCO} \omega_{LPF}}$：$\sqrt{[1/s] \times [rad/s]} \Rightarrow \sqrt{[1/s^2]} \Rightarrow$ **[rad/s]**（符合角頻率單位）。
- $\zeta = \frac{\omega_{LPF}}{2\omega_n}$：$[rad/s] / [rad/s] \Rightarrow$ **[無因次量/無單位]**。

**圖表單位推斷：**
你的筆記上有四張圖，沒標單位在實務上是大忌，我幫你補齊：
1. 📈 **PD 特性曲線（左一）**：
   - X 軸：相位差 $\Delta\phi$ **[rad]** 或 **[UI]**，典型範圍 $-\pi \sim +\pi$。
   - Y 軸：平均輸出電壓 $\bar{V}$ **[V]**，典型範圍 $0 \sim V_{DD}$ (如 0~1.2V)。
2. 📈 **LPF 頻率響應（中下）**：
   - X 軸：頻率 $\omega$ **[rad/s]**，Log scale。
   - Y 軸：增益振幅 $|H(j\omega)|$ **[V/V]** 或 **[dB]**。
3. 📈 **VCO 特性曲線（右一）**：
   - X 軸：控制電壓 $V_{ctrl}$ **[V]**，典型操作在線性區 (如 0.4V~0.8V)。
   - Y 軸：輸出角頻率 $\omega_{out}$ **[rad/s]** (或 $f_{out}$ [GHz])。
4. 📈 **S-plane 根軌跡圖（右下）**：
   - X 軸：實部 $\sigma$ **[rad/s]** 或 **[1/s]** (代表衰減率/鎖定速度)。
   - Y 軸：虛部 $j\omega$ **[rad/s]** (代表振盪/Ringing 頻率)。

### 白話物理意義
**基本 PLL 就像一個反應遲鈍的跟車系統，因為避震器（LPF）太軟導致你煞車反應慢半拍，想調快煞車反應，卻又會讓車子在遇到坑洞（Jitter）時劇烈晃動，兩者無法兼得。**

### 生活化比喻
想像你在淋浴時調水溫（PLL系統）。你的皮膚是 Phase Detector（感受目前水溫與目標水溫的差距），你的手轉動水龍頭是 VCO（改變出水溫度）。但水管很長，熱水傳過來需要時間，這就是系統的 Delay 與 Low Pass Filter。
在 Type-I PLL 中，你只有一種轉水龍頭的策略。如果你為了不被短暫的水溫波動干擾（想要小頻寬抗 Jitter），你手轉水龍頭的速度就必須很慢，結果就是你要在冷風中抖很久水才會熱（Settling Time 極長）。這就是為什麼我們後來需要發明 Charge Pump PLL (Type-II) 來打破這個僵局。

### 面試必考點
1. **問題：在 Simple PLL (Type-I) 的數學模型中，VCO 扮演什麼角色？為什麼？**
   - **答案：** VCO 扮演一個「理想積分器」，其轉移函數含有 $1/s$ 的項。因為 VCO 是「電壓控制頻率」，而 PLL 迴路比對的目標是「相位」。由於相位是頻率對時間的積分（$\phi = \int \omega dt$），所以在 s-domain 中，從控制電壓到輸出相位必須除以 $s$。
2. **問題：請解釋筆記最後一句話 "a severe tradeoff between settling speed & jitter" 在電路設計上的根本原因是什麼？**
   - **答案：** 從推導中可知，系統極點的實部 $-\zeta\omega_n$ 等於 $-\frac{1}{2}\omega_{LPF}$。極點的實部決定了系統的 Settling speed（鎖定時間）；而 $\omega_{LPF}$ 決定了系統抑制高頻雜訊（Jitter）的能力。這表示如果要過濾 Jitter 把 $\omega_{LPF}$ 變小，極點就會往虛軸靠攏，導致鎖定極慢。兩者被同一個變數綁死，無法獨立最佳化。
3. **問題：從 S-plane 圖中，$\zeta < 1$ 的物理現象是什麼？在 Eye Diagram 上看起來會怎樣？**
   - **答案：** $\zeta < 1$ 稱為 Underdamped（欠阻尼），極點為共軛複數，具有虛部。物理現象是系統在鎖定過程中會發生 Overshoot 和 Ringing。反映在 Eye Diagram 上，你會看到 Clock 的 edge 在鎖定到理想位置前，會在目標位置附近來回震盪（Phase ringing），導致短時間內的 Jitter 變差。

**記憶口訣：**
**「積分生相位，二階綁阻尼，抗雜必龜速」**
*(VCO積分產生相位；基本二階PLL的阻尼和頻寬綁在一起；要抗雜訊(小頻寬)就必定導致鎖定龜速)*

---
**助教的費曼測試（Feynman Test）**：
我看你抄得很認真，但你真的懂了嗎？現在立刻回答我：
*「如果我硬生生把這個 LPF 拿掉（變成 All-pass），這個系統的 Order 會變多少？它還能鎖定嗎？」*
想清楚再回答！
