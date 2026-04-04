# PLL-L23-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L23-P1.jpg

---


---
## Push-Push 振盪器與 VCO 功耗-相位雜訊折衷 (Power-Phase Noise Trade-off)

### 數學推導
**1. Push-Push 倍頻原理 (共模節點二次諧波提取)**
在差動振盪器（如 Cross-Coupled 或 Differential Colpitts）中，假設兩端震盪電壓為：
$V_1(t) = V_0 \cos(\omega_0 t)$
$V_2(t) = -V_0 \cos(\omega_0 t) = V_0 \cos(\omega_0 t - \pi)$
差動對的共模節點（Common-mode node，如 Tail current 節點）的電流或電壓會受到兩端信號的偶數次非線性（例如電晶體的平方律特性）影響：
$I_{tail} \propto V_1^2(t) + V_2^2(t)$
$I_{tail} \propto V_0^2 \cos^2(\omega_0 t) + V_0^2 \cos^2(\omega_0 t - \pi) = 2 V_0^2 \cos^2(\omega_0 t)$
利用三角恆等式 $\cos^2(\theta) = \frac{1 + \cos(2\theta)}{2}$ 展開：
$I_{tail} \propto 2 V_0^2 \left( \frac{1 + \cos(2\omega_0 t)}{2} \right) = V_0^2 + V_0^2 \cos(2\omega_0 t)$
**推導結論：** 基頻 $\omega_0$ 在共模節點完美抵消，但二次諧波 $2\omega_0$ 同相疊加。將此節點接出，即可得到兩倍頻的時脈（Push-Push）。

**2. VCO 功耗與 Phase Noise 折衷 (N 個 VCO 並聯)**
假設單一 VCO 的偏壓電流為 $I_{ss}$，等效並聯負載阻抗為 $R_p$。
- **載波功率 ($P_{carrier}$)**：振幅 $V_{swing} = I_{ss} \cdot R_p$，故 $P_{carrier\_old} \propto V_{swing}^2 = I_{ss}^2 R_p^2$。
- **雜訊功率 ($P_{noise}$)**：等效雜訊電流變異數為 $i_n^2$，故 $P_{noise\_old} \propto i_n^2 R_p^2$。

將 $N$ 個完全相同的 VCO 同步並聯輸出（將電流注入相同的等效負載 $R_p$）：
- **信號完全相關 (Coherent)**：電流振幅線性相加，總電流 $I_{total} = N \cdot I_{ss}$。
  新載波功率 $P_{carrier\_new} \propto (N \cdot I_{ss} \cdot R_p)^2 = N^2 \cdot P_{carrier\_old}$ （**載波功率變 $N^2$ 倍**）
- **雜訊互不相關 (Incoherent)**：雜訊電流變異數相加，總變異數 $i_{n,total}^2 = N \cdot i_n^2$。
  新雜訊功率 $P_{noise\_new} \propto (N \cdot i_n^2) R_p^2 = N \cdot P_{noise\_old}$ （**雜訊功率僅變 $N$ 倍**）
- **訊噪比 (SNR)**：$SNR_{new} = \frac{P_{carrier\_new}}{P_{noise\_new}} = \frac{N^2}{N} \cdot SNR_{old} = N \cdot SNR_{old}$
**推導結論：** 當 $N=2$（功耗變 2 倍），SNR 提升 2 倍，Phase Noise 改善 $10 \log_{10}(2) \approx 3\text{ dB}$。

### 單位解析
**公式單位消去：**
- **載波功率計算：** $P_{carrier} = \frac{V_{swing}^2}{2 R_p} \Rightarrow \frac{[\text{V}]^2}{[\Omega]} = \left[\frac{\text{J/C}}{\text{V/A}}\right] \times [\text{V}] = [\text{V} \cdot \text{A}] = [\text{W}]$
- **相位雜訊 (Phase Noise)：** $\mathcal{L}(\Delta\omega) = 10 \log_{10}\left(\frac{P_{noise\_density}}{P_{carrier}}\right) \Rightarrow 10 \log_{10}\left(\frac{[\text{W/Hz}]}{[\text{W}]}\right) = 10 \log_{10}([\text{Hz}^{-1}]) = [\text{dBc/Hz}]$
- **短路傳輸線阻抗 (提供 Tail 端高阻抗)：** $Z_{in} = j Z_0 \tan(\beta l) \Rightarrow [j] \times [\Omega] \times \tan\left(\frac{[\text{rad/m}] \times [\text{m}]}{\text{dimensionless}}\right) = [\Omega]$

**圖表單位推斷：**
- 📈 **傳輸線駐波示意圖 (左中，繪有波形與 open 字樣)：**
  - X 軸：傳輸線物理位置 $x$ [m] 或 電氣長度 [$\lambda$]
  - Y 軸：電壓振幅 $|V(x)|$ [V]，短路端電壓為 0，看入端呈現開路 (Open) 狀態，電壓極大化。
- 📈 **VCO 頻譜相加示意圖 (右下，兩個波形相加)：**
  - X 軸：頻率 $f$ [GHz] 或 角頻率 $\omega$ [rad/s]，中心點為 $\omega_0$。
  - Y 軸：功率頻譜密度 (PSD) [dBm/Hz] 或 [$V^2/\text{Hz}$]，展示信號峰值大幅拉高，但周圍雜訊裙擺 (Skirt) 增加較少。

### 白話物理意義
- **Push-Push VCO：** 巧妙利用差動電路「基頻互相抵消、倍頻同相疊加」的特性，從尾巴（共模節點）偷接出兩倍快的時脈，用低頻的命操出高頻的效能。
- **VCO Trade-off：** 把多個 VCO 綁在一起震盪，因為訊號會完美疊加產生平方效應，而雜訊是亂數只會線性增加，所以「用 N 倍的電費（功耗），可以換到 $10\log(N)$ dB 的訊號純淨度」。

### 生活化比喻
- **Push-Push VCO：** 想像兩個人在玩蹺蹺板（差動振盪）。雖然每個人一秒鐘只上下一次（基頻），但中間的支點（共模節點）每一秒鐘會承受兩次往下的重力（兩個人各往下壓一次）。只要我們在支點裝個壓力感測器，就能量到兩倍頻率的訊號！
- **VCO 功耗與雜訊折衷：** 就像啦啦隊喊口號。如果 2 個人默契完美一起喊，口號聲（訊號）的威力會變成 4 倍（指數疊加）；但他們各自不小心發出的咳嗽聲（雜訊）因為時間錯開，能量只會變 2 倍（線性疊加）。所以人越多（功耗越大），口號越能蓋過雜訊，音質越好。

### 面試必考點
1. **問題：在 Push-Push Oscillator 中，訊號是從哪裡取出的？為什麼那裡會有高頻訊號？**
   → **答案：** 從差動對的「共模節點」（例如 Tail Current 端）。因為差動的基頻訊號在共模節點會反相抵消，但經過電晶體的非線性（平方律）轉換後，產生的二次諧波（$2\omega_0$）是同相的，因此會在此節點強烈疊加。
2. **問題：筆記中 Tail 端接了一段標示為 $\frac{\lambda}{4} @ 2\omega_{osc}$ 的傳輸線，其物理作用為何？**
   → **答案：** 作為阻抗轉換。若這是一段遠端短路的傳輸線，長度為 $2\omega_{osc}$ 的四分之一波長時，從 Tail 端看進去的阻抗會變成無限大（開路，Open）。這能迫使二次諧波的能量無法流失到地，從而最大化該節點的 $2\omega_{osc}$ 電壓擺幅，方便將 ckout 萃取出來。
3. **問題：假設客戶要求你的 PLL Phase Noise 必須再降 3dB，但在不改電路架構的前提下，你要付出什麼代價？**
   → **答案：** 必須將 VCO 的功耗（電流）提高 2 倍。將兩個相同的 VCO 並聯，載波功率會增加 4 倍（電壓同相疊加的平方），而雜訊功率只增加 2 倍（不相關雜訊的功率疊加），SNR 提升 2 倍，剛好改善 3dB 的 Phase Noise。

**記憶口訣：**
**「Push-Push 抓尾巴(Tail)拿倍頻，VCO 並聯訊號平方、雜訊加倍」**
