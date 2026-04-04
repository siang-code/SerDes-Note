# PLL-L39-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L39-P1.jpg

---


---
## Fractional-N PLL 系統中的 $\Sigma\Delta$ 雜訊整型 (Noise Shaping) 與頻譜推導

### 數學推導
筆記中推導了 Fractional-N PLL 中，因為 $\Sigma\Delta$ (Sigma-Delta) 調變器不斷切換除頻比而產生的等效相位雜訊 PSD ($S_{\Phi,\Sigma\Delta}$)。作者極具巧思地將複雜的公式拆解為具有直觀漸近線（Asymptote）物理意義的三個乘積項與除頻比的平方：
$S_{\Phi,\Sigma\Delta} = \text{Term}_1 \times \text{Term}_2 \times \text{Term}_3 \times (M+\alpha)^2$

**1. Term 1：一階 $\Sigma\Delta$ 基礎相噪（包含 ZOH 與積分效應）**
$\text{Term}_1 = \frac{1}{12T} \left[ \frac{\sin(\omega T/2)}{\omega/2} \right]^2$
- $\Sigma\Delta$ 輸出的量化雜訊變異數為 $1/12$。
- 數位訊號控制類比電路，等同於經過零階保持 (Zero-Order Hold, ZOH)，產生 $\text{sinc}$ 函數。
- 頻率變動要轉換為相位變動，需要經過積分，在頻域上對應除以 $\omega^2$。
- 分母的 $(\omega/2)^2$ 巧妙地將 ZOH 的 $\text{sinc}$ 函數與積分的 $1/\omega^2$ 結合。在極低頻 ($\omega \to 0$) 時，利用羅必達法則可得極限值為 $\frac{T}{12}$，即低頻是平坦的。

**2. Term 2：高階 $\Sigma\Delta$ 的雜訊整型 (Noise Shaping) 貢獻**
$\text{Term}_2 = \left[ 2\sin\left(\frac{\omega T}{2}\right) \right]^{2m-2}$
- $m$ 代表 $\Sigma\Delta$ 調變器的階數 (MASH order)。
- 在低頻區段 ($\omega \ll \frac{2\pi}{T}$)，$2\sin(\frac{\omega T}{2}) \approx \omega T$。
- 因此該項正比於 $\omega^{2m-2}$。轉換為對數頻譜 (dB) 時，斜率為 $10 \log_{10}(\omega^{2m-2}) = 20(m-1)$ dB/dec。
  - 當 $m=2$ (二階 SDM)：斜率為 $+20$ dB/dec。
  - 當 $m=3$ (三階 SDM)：斜率為 $+40$ dB/dec。

**3. Term 3：閉迴路低通濾波 (Type-II PLL LPF 效應)**
$\text{Term}_3 = \frac{4\xi^2\omega_n^2}{\omega^2 + 4\xi^2\omega_n^2}$
- 這是 Type-II PLL 對除頻器雜訊的閉迴路轉移函數 $|H_{closed}(j\omega)|^2$ 的高頻漸近線簡化模型。
- 低頻時 ($\omega \to 0$)，值為 1 (0 dB)。
- 轉折頻率發生在迴路頻寬 $\omega_{BW} \approx 2\xi\omega_n$。
- 高頻時 ($\omega \gg \omega_{BW}$)，該項近似為 $\frac{4\xi^2\omega_n^2}{\omega^2}$，以 $1/\omega^2$ 衰減，在功率頻譜上對應 $-20$ dB/dec 的下降斜率。

**4. $(M+\alpha)^2$：**
- $M+\alpha$ 是平均除頻比 $N$。因為雜訊是從回授除頻器注入，對應到輸出相位時會乘上 $N^2$。

### 單位解析
**公式單位消去：**
針對 $S_{\Phi,\Sigma\Delta}$ (相位雜訊 PSD，單位 $[\text{UI}^2/\text{Hz}]$ 或 $[\text{cycles}^2/\text{Hz}]$)：
- $\frac{1}{12T}$：$1/12$ 為量化變異數 (無單位)，$T$ 為週期 $[\text{s}]$。$\frac{1}{12T}$ 單位為 $[1/\text{s}] = [\text{Hz}]$。
- $\left[ \frac{\sin(\omega T/2)}{\omega/2} \right]^2$：分子 $\sin$ 無單位，分母 $\omega$ 單位為 $[\text{rad/s}]$ (在此常數化簡忽略 rad)。整體單位為 $[\text{s}^2]$。
- $\text{Term}_1$ 總單位 = $[\text{Hz}] \times [\text{s}^2] = [\text{s}]$ (時間抖動平方密度，轉換為週期比例即 $[\text{UI}^2/\text{Hz}]$)。
- $\text{Term}_2$：$\sin$ 函數，無單位 $[1]$。
- $\text{Term}_3$：$\frac{\omega_n^2}{\omega^2}$ 單位相消，無單位 $[1]$。
- $(M+\alpha)^2$：除頻比，無單位 $[1]$。
- 最終消去結果：符合相位雜訊的 PSD 單位要求。

**圖表單位推斷：**
📈 **圖 1 (Term 1, ZOH+積分效應)：**
- X 軸：角頻率 $\omega$ $[\text{rad/s}]$，關鍵點 $\frac{2\pi}{T}$ (參考頻率)
- Y 軸：相位雜訊 PSD，平坦區峰值為 $\frac{T}{12}$。

📈 **圖 2 (Term 2, Noise Shaping 斜率)：**
- X 軸：角頻率 $\omega$ $[\text{rad/s}]$ (對數尺度)
- Y 軸：Magnitude $[\text{dB}]$，斜率為 $+20$ dB/dec 或 $+40$ dB/dec。

📈 **圖 3 (Term 3, 閉迴路 LPF)：**
- X 軸：角頻率 $\omega$ $[\text{rad/s}]$ (對數尺度)
- Y 軸：Magnitude $[\text{dB}]$，低頻 0 dB，高頻轉折點 $\omega_{BW}$ 後以 $-20$ dB/dec 下降。

📈 **圖 4 & 圖 5 (綜合相位雜訊 $S_{\Phi,\Sigma\Delta}$ 對比 VCO)：**
- X 軸：角頻率 $\omega$ $[\text{rad/s}]$ (對數尺度)
- Y 軸：相位雜訊 PSD $[\text{dBc/Hz}]$
- **$m=2$**：低頻 $+20$ dB/dec，高頻遇上 $-20$ dB/dec 的濾波器，相互抵銷變為 **平坦 (0 dB/dec)**。
- **$m=3$**：低頻 $+40$ dB/dec，高頻遇上 $-20$ dB/dec 的濾波器，扣除後仍 **持續上升 (+20 dB/dec)**。

### 白話物理意義
使用高階 $\Sigma\Delta$ (如三階) 雖然能把低頻的突波雜訊掃得很乾淨，但會把雜訊全部往高頻堆積（形成高頻海嘯）；如果 PLL 的迴路濾波器高頻擋板不夠高（衰減不夠快），這些高頻雜訊就會蓋過 VCO 本身的雜訊，讓整顆晶片的 Jitter 爆表。

### 生活化比喻
想像你在房間裡掃地（$\Sigma\Delta$ 雜訊整型）：
$m=2$（二階）像是用一般掃把把灰塵從腳邊（低頻）掃到牆角（高頻），牆角剛好有一塊擋板（Loop Filter 的 -20dB/dec 衰減）可以把灰塵蓋平。
$m=3$（三階）像是用了超強吹風機，腳邊一塵不染，但灰塵被吹到半空中狂飆（+40 dB/dec），原來的擋板根本擋不住，灰塵飛得比天花板（VCO 雜訊）還要高。這時你必須把擋板加高（增加 Loop Filter 的階數）才能壓制住漫天飛舞的灰塵。

### 面試必考點
1. **問題：在 Fractional-N PLL 中，如果決定從 2 階 MASH 改為 3 階 MASH 以降低 In-band Fractional Spur，迴路濾波器 (Loop Filter) 必須做什麼對應的修改？為什麼？**
   - 答案：必須在 Loop Filter 增加額外的高頻極點（例如將迴路從 3rd-order 升級為 4th-order）。因為 3 階 SDM 會產生高頻 $+40$ dB/dec 的相位雜訊斜率，若迴路只提供基本的 $-20$ dB/dec 衰減，帶外雜訊仍會以 $+20$ dB/dec 上升並蓋過 VCO，導致 High-frequency Integrated Jitter 嚴重惡化。
2. **問題：為什麼 Type-II PLL 的高頻閉迴路衰減斜率通常只有 -20 dB/dec（如筆記中 Term 3 所示），而不是理想的 -40 dB/dec？**
   - 答案：為了維持 Type-II PLL 的系統穩定性（Phase Margin），必須在 Loop Filter 中加入一個零點 ($\omega_z$)。這個零點會抵銷掉原本 VCO 積分器帶來的一個極點的高頻衰減能力，使得原本理想的 $-40$ dB/dec 衰減退化成 $-20$ dB/dec。
3. **問題：在一個設計優良的 Fractional-N PLL 中，輸出頻譜不同頻段的雜訊瓶頸 (Dominant Noise Source) 分別應該是誰？**
   - 答案：帶內 (In-band) 應由 Charge Pump、PFD 或 Reference Clock 的雜訊主導；帶外 (Out-of-band) 應由 VCO 本身的 Phase Noise 主導。如同筆記強調：「For a good design, $S_{\Phi,\Sigma\Delta}$ never dominates @ any freq.」 SDM 的量化雜訊在任何頻段都必須被妥善壓制在主導雜訊之下。

**記憶口訣：**
「二階平、三階翹，高階 MASH 極點要加罩。」
（2階 SDM 雜訊過濾波器後變平坦，3階會往上翹，使用高階 MASH 必須增加濾波器極點來罩住高頻雜訊。）
