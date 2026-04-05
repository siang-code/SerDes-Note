# CDR-L30-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L30-P1.jpg

---


身為李致毅老師課程的嚴格助教，我必須先稱讚這頁筆記的推導邏輯十分清晰，抓到了從 Phase Noise 頻譜積分反推 Jitter 規格的精髓。但是！**同學，你的數值計算差了一個數量級啊！** 面試時如果當場算錯數量級，面試官會懷疑你的 engineering sense。讓我們來一條一條把這頁筆記拆解清楚。

---
## Jitter Generation (JG) for PLL-based linear CDR

### 數學推導
這頁筆記的核心目的是：「已知 CDR 的頻寬 ($f_{BW}$) 與系統容忍的最大抖動 ($J_{rms}$)，如何反推壓控振盪器 (VCO) 需要符合什麼樣的 Phase Noise 規格？」

1.  **系統轉移函數降階假設：**
    *   筆記起手式：`Noise from PD/CP Negligible => Most noise comes from VCO`。這在評估 Jitter Generation (JG) 時是標準起手式，假設參考輸入無雜訊，僅看 VCO 自身發散的雜訊如何傳遞到輸出。
    *   VCO 雜訊到輸出的轉移函數為高通 (High-Pass)：$\frac{\phi_{out}}{\phi_{vco}}(s)$。
    *   標準二階系統為 $\frac{s^2}{s^2 + 2\zeta\omega_n s + \omega_n^2}$。筆記中為了方便手算積分，做了一個強力的**一階近似**：$\frac{\phi_{out}}{\phi_{vco}} \approx \frac{s}{s + \omega_{BW}}$。對應的震幅平方轉移函數為 $\left| \frac{\phi_{out}}{\phi_{vco}} \right|^2 \approx \frac{\omega^2}{\omega^2 + \omega_{BW}^2}$ 或 $\frac{f^2}{f^2 + f_{BW}^2}$。

2.  **VCO Phase Noise 模型建立：**
    *   假設 VCO 雜訊主要由 $1/f^2$ (Thermal noise causing random walk phase) 貢獻。
    *   建立模型：$S_{\phi,vco}(f) = S_{\phi,vco}(f_{offset}) \cdot (\frac{f_{offset}}{f})^2$。
    *   **⚠️ 助教抓漏：** 筆記裡面的 $f_0$ 指的是 **Offset Frequency (偏移頻率)**，而非 Carrier Frequency (載波頻率)，這個符號極易混淆！我們底下用 $f_0$ 繼續推導以對應你的筆記，但心裡要知道它是 offset frequency。

3.  **積分計算 RMS Jitter：**
    *   總輸出相位雜訊的功率頻譜密度 (PSD) 為：$S_{\phi,out}(f) = S_{\phi,vco}(f) \cdot \left| \frac{\phi_{out}}{\phi_{vco}} \right|^2$
    *   將模型代入：$S_{\phi,out}(f) = \left[ S_{\phi,vco}(f_0) \frac{f_0^2}{f^2} \right] \cdot \left[ \frac{f^2}{f^2 + f_{BW}^2} \right] = S_{\phi,vco}(f_0) \frac{f_0^2}{f^2 + f_{BW}^2}$
    *   Jitter 積分公式 ($UI$ 單位)：$J_{rms} = \frac{1}{2\pi} \left[ 2 \int_{f_1}^{f_2} S_{\phi,out}(f) df \right]^{1/2}$ (乘以 2 是因為通常 $S_\phi$ 以單邊帶定義，需計算總能量)。
    *   將 $S_{\phi,out}$ 提出常數項：$J_{rms} = \frac{1}{2\pi} \left[ 2 \cdot S_{\phi,vco}(f_0) \cdot f_0^2 \int_{f_1}^{f_2} \frac{1}{f^2 + f_{BW}^2} df \right]^{1/2}$
    *   套用微積分基本公式 $\int \frac{1}{x^2+a^2} dx = \frac{1}{a}\tan^{-1}(\frac{x}{a})$：
        積分項 $= \frac{1}{f_{BW}} \left[ \tan^{-1}\left(\frac{f_2}{f_{BW}}\right) - \tan^{-1}\left(\frac{f_1}{f_{BW}}\right) \right]$
    *   **全頻譜積分 (Whole spectrum integration)：** 設 $f_1 \to 0$, $f_2 \to \infty$。
        $\tan^{-1}(\infty) = \pi/2$；$\tan^{-1}(0) = 0$。括號內變為 $\frac{\pi}{2 f_{BW}}$。
    *   化簡得到最終神之公式：
        $J_{rms} (UI) = \frac{f_0}{2\pi} \left[ 2 \cdot S_{\phi,vco}(f_0) \cdot \frac{\pi}{2 f_{BW}} \right]^{1/2} = \frac{f_0}{2\pi} \sqrt{\frac{\pi \cdot S_{\phi,vco}(f_0)}{f_{BW}}} = \mathbf{\frac{f_0}{2} \sqrt{\frac{S_{\phi,vco}(f_0)}{\pi \cdot f_{BW}}}}$

4.  **數值代入與「抓漏」：**
    *   條件：$f_{BW} = 1\text{ MHz}$, 目標 $J_{rms} = 0.01\text{ UI}$, 評估點 $f_0 = 1\text{ MHz}$。
    *   $0.01 = \frac{10^6}{2} \sqrt{\frac{S_{\phi,vco}}{\pi \cdot 10^6}} \Rightarrow 10^{-2} = 5 \times 10^5 \cdot \sqrt{\frac{S_{\phi,vco}}{\pi \cdot 10^6}}$
    *   移項：$\frac{10^{-2}}{5 \times 10^5} = 2 \times 10^{-8} = \sqrt{\frac{S_{\phi,vco}}{\pi \cdot 10^6}}$
    *   兩邊平方：$4 \times 10^{-16} = \frac{S_{\phi,vco}}{\pi \cdot 10^6} \Rightarrow S_{\phi,vco} = 4\pi \times 10^{-10} \approx \mathbf{1.256 \times 10^{-9} \text{ [rad}^2\text{/Hz]}}$
    *   **⚠️ 助教開噴：** 你的筆記寫 $S_{\phi,vco} = 1.25 \times 10^{-8}$，整整差了 10 倍！面試時算錯這個，VCO 設計難度直接放寬一個數量級，晶片做出來會動不起來！
    *   正確的 Phase Noise 應為：$\mathcal{L}(1\text{MHz}) \approx 10 \log_{10}(S_{\phi,vco}/2) = 10 \log_{10}(6.28 \times 10^{-10}) \approx \mathbf{-92\text{ dBc/Hz}}$ (你的筆記寫 -79 dBc/Hz 是基於算錯的數值且未除以2)。

### 單位解析
**公式單位消去：**
我們要驗證最終公式 $J_{rms} = \frac{f_0}{2\pi} \sqrt{\frac{\pi \cdot S_{\phi,vco}}{f_{BW}}}$ 的單位是否為 UI (Unit Interval，為無因次量或純量)。
*   $S_{\phi,vco}$ 的單位：$\text{[rad}^2\text{/Hz]}$ (註：rad 為輔助單位，物理因次為 $\text{[1/Hz]}$)
*   積分結果 $\int S(f) df$ 的單位：$\text{[rad}^2\text{/Hz]} \times \text{[Hz]} = \text{[rad}^2\text{]}$
*   開根號後：$\text{[rad]}$
*   除以 $2\pi$：因為 $1\text{ UI} = 2\pi\text{ rad}$，所以 $\text{[rad]} / \text{[rad/UI]} = \mathbf{[UI]}$。單位完美契合！

**圖表單位推斷：**
1.  📈 **左側 PD/CP 轉移曲線圖：**
    *   X 軸：相位誤差 $\Delta\phi \mathbf{\text{ [rad]}}$，典型範圍 $-2\pi \sim 2\pi$ (Linear phase detector)。
    *   Y 軸：平均輸出電流 $I_{av} \mathbf{\text{ [A]}}$，典型範圍 $-I_p \sim I_p$ (Charge pump current)。
    *   斜率即為增益：$I_p/2\pi \mathbf{\text{ [A/rad]}}$。
2.  📈 **右側 VCO Phase Noise 頻譜圖：**
    *   X 軸：偏移頻率 $\omega$ 或 $f \mathbf{\text{ [Hz] 或 [rad/s]}}$ (Log 尺度)，典型範圍 $10\text{kHz} \sim 100\text{MHz}$。
    *   Y 軸：相位雜訊功率頻譜密度 $S_{\phi,vco} \mathbf{\text{ [rad}^2\text{/Hz]}}$ 或 $\mathcal{L} \mathbf{\text{ [dBc/Hz]}}$ (Log 尺度)。圖中斜直線代表 $-20\text{dB/dec}$ 的 $1/f^2$ 衰減區間。

### 白話物理意義
我們利用 CDR 環路的「高通濾波」特性，計算出 VCO 高頻雜訊「漏」到最終輸出的總能量，藉此反推你的 VCO 體質 (Phase Noise) 要多乾淨，才能符合系統的 Jitter 規範。

### 生活化比喻
VCO 就像一個**手會一直抖的攝影師**，CDR 環路就像**防手震穩定器 (Gimbal)**。
穩定器只能抵消「緩慢的晃動」(低頻)，如果你手抖得太快 (高頻雜訊)，穩定器來不及反應，這抖動就會直接留在影片上 (Jitter Generation)。這張筆記的計算就是在評估：如果客戶要求影片看起來幾乎不能晃 (0.01 UI)，且穩定器的反應速度固定 ($1\text{MHz}$)，那我們必須要求攝影師的手本身「抖動的劇烈程度」(Phase Noise) 必須低於某個標準。

### 面試必考點
1.  **問題：為什麼 VCO Noise 到輸出的轉移函數是 High-Pass，而 Reference Noise 是 Low-Pass？**
    → 答案：因為 Reference 是從輸入端進入環路（順著走），低頻能被追蹤；而 VCO 是在迴路內部產生的誤差源，CDR 是一個負回授系統，會自動「修正」VCO 的低頻飄移，但對於變化太快（超過頻寬 $f_{BW}$）的高頻雜訊來不及修正，因此高頻雜訊會直接漏出，呈現高通特性。
2.  **問題：如果想降低 VCO 貢獻的 Jitter (JG)，從系統層面可以怎麼調整？有什麼代價？**
    → 答案：從公式 $J_{rms} \propto 1/\sqrt{f_{BW}}$ 可知，**提高環路頻寬 ($f_{BW}$)** 可以壓抑更多 VCO 雜訊。代價是：Jitter Transfer (JT) 的頻寬也會變大，會放進更多來自前級或 Reference 的雜訊；同時也可能影響環路穩定度 (Phase Margin)。
3.  **問題：你的積分公式用到 $\tan^{-1}(\infty) = \pi/2$，這代表積分到無窮大。實務上高頻雜訊會無限大嗎？**
    → 答案：不會。實務上 VCO 的寬頻雜訊 (Thermal noise floor) 最終會被系統的寄生電容 (Parasitic poles) 或 Buffer 的頻寬給自然濾除（Rolloff），所以積分上限 $f_2$ 其實是被真實電路的頻寬所限制，並不會真的積分到無窮大。

**記憶口訣：**
**VCO 雜訊看高通，積分 $\arctan$ 算從容；頻寬越大抖越鬆 (Jitter小)，計算數量級別發瘋！**


### 問題延伸

#### Q：你在移項：
1
0
−
2
5
×
1
0
5
=
2
×
1
0
−
8
=
S
ϕ
,
v
c
o
π
⋅
1
0
6
5×10 
5
 
10 
−2
 
​
 =2×10 
−8
 = 
π⋅10 
6
 
S 
ϕ,vco
​
 
​
 
​
 你自己移項有問題怪我?
> 提問時間：2026-04-05 12:09

1. **直接回答問題：助教的移項沒有錯，是你誤解了運算順序與基本代數。**
助教原本寫的是一個完整的「分數」，分母為 $5 \times 10^5$。正確的移項計算是 $10^{-2} \div (5 \times 10^5) = 2 \times 10^{-8}$。
你如果把它看成 `10^-2 / 5 * 10^5` 並用計算機由左至右按，會算出 $(10^{-2} \div 5) \times 10^5 = 200$，這是經典的先後運算順序錯誤（Order of Operations），助教的移項完全正確。

此外，你筆記上算出的 $1.25 \times 10^{-8}$，很可能是你在計算 $(2 \times 10^{-8})^2$ 時粗心少算了一個零，錯算成 $4 \times 10^{-15}$，導致後續乘上 $\pi \cdot 10^6$ 時剛好得出 $1.256 \times 10^{-8}$（差了整整 10 倍）。若把你的答案代回公式，系統的 Jitter 會是 0.0316 UI，晶片直接規格不符 (Fail)。

2. **物理意義與電路設計考量：相噪差 10 倍，等同於功耗差 10 倍。**
在類比 IC 設計中，$10$ 倍的 Phase Noise 差距等同於 $10\text{ dBc/Hz}$ 的惡化。根據 VCO 的 Figure of Merit (FoM)，在相同的震盪頻率與 Offset 頻率下，Phase Noise 與功耗 ($P_{DC}$) 成反比。
為了彌補這算錯的 $10\text{ dB}$，你在電路實作上必須把 VCO 的核心功耗暴力放大 $10$ 倍！在先進製程（如 55nm 及以下）中，VDD 通常很低（例如 1.2V 甚至 0.8V），電流拉大 10 倍會需要極大的電晶體尺寸 (W/L)，這不僅導致寄生電容暴增、嚴重壓縮可調頻率範圍 (Tuning Range)，還會面臨嚴格的金屬線電遷移 (Electromigration, EM) 限制，甚至直接吃掉整顆晶片的 Power Budget。

3. **如果跟面試有關，面試官可能會追問的方向：**
如果你在白板題發生這種數量級失誤，面試官一定會立刻進行壓力測試，看你怎麼用 Engineering Sense 補救：
*   **追問一（電路層次）：**「如果 VCO 真的差了 10dB 才達標，除了加 10 倍功耗，還有什麼方法？」
    *   *破解方向：* 提到更換架構（例如從 Ring VCO 換成 LC VCO，利用高 Q 值電感降低雜訊，代價是面積變極大）、或者優化 LC tank 的 Q 值（例如採用最上層的厚金屬層 (Thick Metal) 繞製電感）。
*   **追問二（系統層次）：**「如果 VCO 已經逼近物理與功耗極限無法再優化，從 CDR 系統 (Loop) 視角能怎麼救？」
    *   *破解方向：* 根據助教推導的公式 $J_{rms} \propto 1/\sqrt{f_{BW}}$，可以嘗試**提高迴路頻寬 ($f_{BW}$)**，讓 CDR 的高通濾波特性切除更多 VCO 的低頻雜訊。但必須主動補充代價：這會導致 Jitter Transfer (JT) 頻寬變大，放大來自前級或 Reference 的輸入雜訊，且需重新評估 Phase Margin 確保迴路穩定度。
*   **追問三（先進製程特性）：**「在先進製程 (如 28nm 以下) 設計 VCO 時，為什麼不能無腦加大電晶體來降 Phase Noise？」
    *   *破解方向：* 點出 Voltage Headroom 變小的問題。大電流需要極大的 W，這會使得電晶體更容易掉進 Triode region (線性區)，反而讓等效 $g_m$ 變差，且先進製程的閃爍雜訊 ($1/f$ noise) corner 頻率極高，大尺寸元件的雜訊升頻 (Up-conversion) 會讓 VCO 的 Close-in Phase Noise 嚴重惡化。
