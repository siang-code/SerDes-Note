# PLL-L20-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L20-P1.jpg

---


---
## 壓控振盪器控制線漣波與相位雜訊 (VCO Control Line Ripple & Phase Noise)

### 數學推導
本頁筆記主要涵蓋三個核心概念：控制線漣波 (Control Line Ripple) 對頻譜的影響（產生 Spurs）、相位雜訊 (Phase Noise) 的定義，以及振盪器效能指標 (Figure of Merit, FOM)。

**1. 控制線漣波導致的突波 (Reference Spurs 推導)**
假設 VCO 的控制電壓 $V_{ctrl}$ 受到一個頻率為 $\omega_m$ 的弦波雜訊干擾（在 PLL 中通常是 Charge Pump 的 current mismatch 或 leakage 導致的 Reference Ripple）：
$V_{ctrl}(t) = V_m \cos(\omega_m t)$

VCO 的輸出相位 $\phi_{out}$ 是頻率變化的積分（比例常數為 $K_{vco}$）：
$\phi_{out}(t) = \int K_{vco} V_{ctrl}(t) dt = \int K_{vco} V_m \cos(\omega_m t) dt = \frac{K_{vco} V_m}{\omega_m} \sin(\omega_m t)$

將此額外的相位代入 VCO 的理想輸出訊號 $y(t)$ 中（假設振幅為 $A_0$，中心頻率為 $\omega_0$）：
$y(t) = A_0 \cos(\omega_0 t + \phi_{out}(t)) = A_0 \cos\left[ \omega_0 t + \underbrace{\frac{K_{vco} V_m}{\omega_m} \sin(\omega_m t)}_{\text{調變指數 } \beta \text{，通常很小}} \right]$

利用和角公式 $\cos(A+B) = \cos A \cos B - \sin A \sin B$ 展開：
$y(t) = A_0 \left[ \cos(\omega_0 t)\cos(\beta \sin \omega_m t) - \sin(\omega_0 t)\sin(\beta \sin \omega_m t) \right]$

因為 $\beta = \frac{K_{vco} V_m}{\omega_m}$ 通常很小（Narrowband FM 近似），可用泰勒展開近似：$\cos\theta \approx 1$, $\sin\theta \approx \theta$：
$y(t) \approx A_0 \left[ \cos(\omega_0 t) - (\beta \sin \omega_m t)\sin(\omega_0 t) \right]$

利用積化和差公式 $\sin A \sin B = \frac{1}{2}[\cos(A-B) - \cos(A+B)]$，代入上式：
$y(t) \approx A_0 \cos(\omega_0 t) - \frac{A_0 K_{vco} V_m}{2\omega_m} \left[ \cos((\omega_0 - \omega_m)t) - \cos((\omega_0 + \omega_m)t) \right]$
*(註：筆記手稿中的符號分配略有不同，但物理意義一致)*

**結論：** 除了位於 $\omega_0$ 的主載波外，在 $\omega_0 \pm \omega_m$ 處會產生一對 Sidebands (Spurs)，其振幅比例為載波的 $\frac{K_{vco} V_m}{2\omega_m}$。

**2. 振盪器效能指標 (Figure of Merit, FOM)**
為了公平比較不同規格的振盪器，定義了 FOM 公式：
$FOM = \mathcal{L}(\Delta\omega) + 10 \log_{10} \left[ \left(\frac{\Delta\omega}{\omega_0}\right)^2 \right] + 10 \log_{10} \left[ \frac{P_{DC}}{1\text{mW}} \right]$
這公式將測得的相位雜訊 $\mathcal{L}(\Delta\omega)$，針對「操作頻率 $\omega_0$」與「直流功耗 $P_{DC}$」進行了正規化。數值越低（越負），代表電路設計的效率與本質越好。

**3. 頻譜儀量測換算 (右下角圖例)**
若在頻譜儀上看到在 offset $1\text{MHz}$ 處，雜訊相對於載波衰減了 $65\text{dB}$，且 Resolution Bandwidth (RBW) 為 $10\text{kHz}$。
需要將 $10\text{kHz}$ 的雜訊功率平移到 $1\text{Hz}$ 頻寬：
$10 \log_{10}(10\text{kHz}) = 40\text{dB}$
實際相位雜訊 $\mathcal{L}(1\text{MHz}) = -65\text{dB} - 40\text{dB} = -105\text{ dBc/Hz}$。

### 單位解析
**公式單位消去：**
1. **調變指數 $\beta$**：
   - $K_{vco}$: $[\text{Hz/V}]$ 或 $[\text{rad/s}\cdot\text{V}^{-1}]$
   - $V_m$: $[\text{V}]$
   - $\omega_m$: $[\text{rad/s}]$
   - $\beta = \frac{K_{vco} V_m}{\omega_m} \rightarrow \frac{[\text{rad}\cdot\text{s}^{-1}\cdot\text{V}^{-1}] \times [\text{V}]}{[\text{rad}\cdot\text{s}^{-1}]} = [1]$ （無因次，代表徑度 rad）。

2. **相位雜訊 $\mathcal{L}(\Delta\omega)$**：
   - $\mathcal{L}(\Delta\omega) = 10 \log_{10} \left( \frac{\text{Noise Power in 1Hz}}{\text{Carrier Power}} \right)$
   - $\frac{[\text{W/Hz}] \times [\text{Hz}]}{[\text{W}]} = [1]$。取對數後單位標記為 $[\text{dBc/Hz}]$ (Decibels relative to the carrier per Hertz)。

3. **FOM 頻率正規化項**：
   - $10 \log_{10} \left[ (\frac{\Delta\omega}{\omega_0})^2 \right] \rightarrow \frac{[\text{rad/s}]}{[\text{rad/s}]} = [1]$。取對數後為 $[\text{dB}]$。

**圖表單位推斷：**
📈 圖表單位推斷：
- **右上頻譜圖 (Sidebands/Spurs)**：
  - X 軸：角頻率 $\omega$ $[\text{rad/s}]$。
  - Y 軸：電壓振幅 $[\text{V}]$。標示了主頻振幅 $A_0$ 與 Spur 振幅 $\frac{A_0 K_{vco} V_m}{2\omega_m}$。
- **右中相位雜訊曲線 (Phase Noise vs Offset)**：
  - X 軸：頻率偏移 $\Delta\omega$ $[\text{rad/s}]$ (對數尺度)。
  - Y 軸：相位雜訊 $\mathcal{L}(\Delta\omega)$ $[\text{dBc/Hz}]$。顯示了 $1/f^3$ (Flicker) 與 $1/f^2$ (Thermal) 區段，以及平坦的 Noise floor。
- **左下頻譜儀量測圖**：
  - X 軸：頻率 $f$ $[\text{Hz}]$。
  - Y 軸：功率頻譜密度 $[\text{dBm/RBW}]$。顯示訊號與雜訊的高低差為 $65\text{dB}$。

### 白話物理意義
控制電壓上一點點規律的雜訊波浪，會讓 VCO 頻率產生週期性的「抖音」，進而在頻譜主峰的旁邊長出不需要的「小角 (Spurs)」；而 FOM 就是一個把頻率、功耗、雜訊放在同一個起跑線上的「綜合戰鬥力評分系統」。

### 生活化比喻
- **Control Line Ripple & Spurs**：想像你在專心拉小提琴（發出乾淨的主頻），旁邊有個人一直規律地抖動你的手肘（控制線 Ripple）。你的琴音就會不由自主地產生規律的「抖音」。台下聽眾除了聽到你原本的音階，還會聽到這個抖音產生的伴隨音，這就是 Spurs。
- **FOM**：比較兩台車誰的引擎技術好，不能只看極速（頻率）。A車極速 300km/h 但超級耗油（高功耗），B車極速 200km/h 但很省油。FOM 就像是一個公式，把「極速」、「油耗」和「引擎震動度 (Phase noise)」全部揉合在一起，算出一個綜合分數，這樣才能把法拉利和豐田放在同一個天平上比較誰的「技術力」最高。

### 面試必考點
1. **問題：在 PLL 架構中，Reference Spurs 是怎麼產生的？它與 VCO 的哪個參數成正比？**
   → **答案：** 主要由 Charge Pump 的 Current Mismatch 或 Leakage 造成控制電壓 $V_{ctrl}$ 產生頻率為 $f_{ref}$ 的週期性 Ripple。根據窄頻 FM 理論，這會在 $f_0 \pm f_{ref}$ 產生 Spurs。Spur 的大小與 $K_{vco}$ 成正比（$\text{Spur Level} \propto \frac{K_{vco} V_{ripple}}{f_{ref}}$），因此為了降低 Spurs，有時必須妥協縮小 $K_{vco}$。
2. **問題：為什麼我們在比較不同論文的 VCO 時，不能只看 Phase Noise，而一定要看 FOM？**
   → **答案：** 因為 Phase Noise 可以透過「硬砸功耗 (Power)」或「降低振盪頻率 (Frequency)」來輕易改善（Leeson's Equation 告訴我們雜訊與 $\omega_0^2$ 成正比，與訊號功率成反比）。FOM 將這兩個變因正規化，才能真正看出電路架構或佈局設計的優劣。
3. **問題：如果你在頻譜儀上看到在 1MHz offset 的 delta power 是 -70dB，且頻譜儀的 RBW 設定在 100kHz，請心算這顆 VCO 的 Phase Noise 是多少 dBc/Hz？**
   → **答案：** 需要將 100kHz 的功率正規化到 1Hz。$10\log_{10}(100\text{kHz}) = 50\text{dB}$。真正的 $\mathcal{L}(1\text{MHz}) = -70\text{dB} - 50\text{dB} = -120\text{ dBc/Hz}$。

**記憶口訣：**
- **Spur 來源：** 控電有波，頻率發抖，旁生小角 (Sidebands)。
- **FOM 三本柱：** 雜訊 (Noise)、頻率 (Freq)、功耗 (Power)，正規化後見真章。
- **量測換算：** 看到 RBW，先取 Log 乘十，向下扣除找單赫 (1Hz)。
