# EQ-L12-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L12-P1.jpg

---

---
## Rx Equalizer Adaptation (接收端等化器自適應機制)

### 數學推導
筆記中展示了 CTLE (Continuous Time Linear Equalizer) 的 Adaptation (自適應) 架構，核心依賴 **Power Detector (功率偵測器)** 來形成負回授迴路。為了理解其運作，我們推導這條 Adaptation Loop 的控制行為。

1. **CTLE 輸出訊號表示**：
   假設 CTLE 的轉移函數受控於一個控制電壓 $V_{ctrl}$，令其輸出電壓為 $y(t, V_{ctrl})$。
2. **功率偵測 (Power Detection)**：
   Power Detector 計算輸出訊號的平均功率（或均方根電壓）。
   $$P_{out} = K_{PD} \cdot \frac{1}{T} \int_{0}^{T} y^2(t, V_{ctrl}) dt$$
   其中 $K_{PD}$ 為偵測器的轉換增益。
3. **誤差產生 (Error Generation)**：
   Error Amplifier 將偵測到的功率 $P_{out}$ 與目標參考電壓 $V_{ref}$ 做比較，產生誤差訊號 $e(t)$。
   $$e(t) = V_{ref} - P_{out} = V_{ref} - K_{PD} \cdot \overline{y^2(t)}$$
4. **控制電壓更新 (Adaptation Integration)**：
   Adaptation block 透過積分器 (Integrator) 累積誤差，調整 CTLE 的控制電壓 $V_{ctrl}$ 以達到穩態 ($e(t)=0$)。
   $$V_{ctrl}(t) = \mu \int_{0}^{t} e(\tau) d\tau = \mu \int_{0}^{t} \left( V_{ref} - K_{PD} \cdot \overline{y^2(\tau)} \right) d\tau$$
   其中 $\mu$ 為積分器的增益（決定 Adaptation 迴路的速度與穩定度）。當迴路收斂時，$\frac{dV_{ctrl}}{dt} = 0$，即 $P_{out} = V_{ref}$，代表訊號振幅被自動校準到理想大小，避免訊號過小（SNR差）或過大（Non-linear distortion）。

### 單位解析
**公式單位消去法：**
針對上述推導的控制電壓積分公式：
$$V_{ctrl}[V] = \mu \int \left( V_{ref}[V] - K_{PD}[1/V] \cdot \overline{y^2}[V^2] \right) d\tau[s]$$
- $K_{PD} \cdot \overline{y^2} \Rightarrow [1/V] \times [V^2] = [V]$ (與 $V_{ref}$ 單位一致可相減)
- 積分項 $\int e(\tau) d\tau \Rightarrow [V] \times [s] = [V \cdot s]$
- 為了讓等號左邊為 $[V]$，積分器增益 $\mu$ 的單位必須是 $[1/s]$ (即頻率單位，代表 Loop Bandwidth)。
- 最終：$[1/s] \times [V \cdot s] = [V]$，單位完美消去！

**圖表單位推斷：**
📈 圖表一：Slicer 後的時域波形 (Time-domain waveforms)
- **X 軸**：時間 $[UI]$ (Unit Interval) 或 $[ps]$，典型範圍視 Data Rate 而定 (如 10Gbps 為 100ps)。
- **Y 軸**：電壓 $[V]$，典型範圍為 Slicer 的飽和電壓，例如 $0V$ 到 $V_{DD}$ (例如 $1.0V$)。

📈 圖表二：眼圖 (Eye Diagram - "只有 eye high 張開但 Jitter 很大")
- **X 軸**：時間 $[UI]$，典型範圍 $-0.5\ UI \sim +0.5\ UI$。
- **Y 軸**：差動電壓 $[mV]$，典型範圍 $\pm 200mV \sim \pm 500mV$。

📈 圖表三：Output Jitter vs Input Attn (V字型圖)
- **X 軸**：Input Attenuation (通道衰減量) $[dB]$，典型範圍 $-8 \sim +8\ dB$ (以最佳匹配點為 0 基準)。
- **Y 軸**：Output Jitter (輸出抖動) $[UI_{rms}]$ 或 $[ps]$，典型範圍 $> 0\ UI$。最低點代表等化器與通道衰減完美匹配 (Zero ISI)。

### 白話物理意義
Adaptation 就像是自動對焦系統，因為 Slicer（削波器）會把訊號壓成死板的 0 與 1，導致我們「看」不出振幅是否失真，所以必須在訊號進入 Slicer **「之前」** 偷接出來量能量，自動去轉前面的等化器旋鈕，確保眼圖的高度與寬度都達到完美。

### 生活化比喻
把 Slicer 想像成一個「過濾網」，只在乎水有沒有流過去，不在乎水流得順不順。如果你只看過濾網後面的水（時間域方波），覺得有水就好；但其實前面的水管可能已經亂流（Jitter 大）。Adaptation 就是在過濾網前裝一個「水壓計（Power Detector）」，自動去轉上游的「水龍頭（Gain/Boosting）」，確保水流又平穩又強勁（眼圖完全張開），這樣才不會漏判。

### 面試必考點
1. **問題：為什麼 Adaptation 的訊號擷取點 (Power Detector) 必須放在 Slicer「之前」而不是之後？**
   - **答案**：因為 Slicer 是一個嚴重的非線性元件 (Hard Limiter)，會消除所有的振幅資訊 (AM-to-PM conversion 效應暫且不論)。如果過度等化 (Over-equalization) 導致嚴重高頻突波，Slicer 切下去後看起來還是方波，但實際上會造成嚴重的 Deterministic Jitter (如筆記中所畫：振幅開但 Jitter 大)。在 Slicer 前取樣才能保留真實的類比波形資訊來做正確的頻率響應補償。
2. **問題：筆記中提到 CTLE 架構是 "Boosting & gain stage (interleaved)"，為何不把 Gain 全放前面，Boosting 全放後面？**
   - **答案**：這是為了在 **雜訊指數 (Noise Figure)、線性度 (Linearity) 與 頻寬 (Bandwidth)** 之間取得最佳平衡 (Trade-off)。若 Gain 全放前面，大訊號容易提早讓後級電晶體飽和 (Saturate)；若 Boosting 全放後面，會把前面累積的高頻雜訊 (Thermal noise & Crosstalk) 放大到無法接受，導致 SNR 劣化。交錯排列能維持較好的動態範圍 (Dynamic Range)。
3. **問題：解釋右下角 Output Jitter vs Input Attenuation 呈現 V 字型的物理意義。**
   - **答案**：這代表「等化器補償量」與「通道衰減量」的匹配程度。谷底 (0 dB處) 代表等化器的高頻增益完美抵銷了通道的高頻損耗，此時碼間干擾 (ISI) 最小，Jitter 最小。曲線左側代表 Under-equalization (補償不足)，右側代表 Over-equalization (過度補償)，兩者都會引入嚴重的 ISI 導致 Jitter 劇增。

**記憶口訣：**
> **切前取樣保振幅，交錯放大量雜訊，V型谷底最速配。**
