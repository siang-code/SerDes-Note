# EQ-L1-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L1-P1.jpg

---


---
## [主題名稱]
Sources of Loss in High-Speed Channels (通道損耗來源：Skin Effect 與 Dielectric Loss)

### 數學推導
筆記中給出了通道損耗（Channel Loss）的通用頻域轉移函數模型：
$C(f) = \exp\left[ -k_s \cdot l \cdot (1+j)\sqrt{f} - k_d \cdot l \cdot f \right]$

這個公式描述了訊號在傳輸線（如 Coaxial cables 或 PCB Backplane trace）中傳播時的頻率響應。我們可以將指數內部拆解為兩大項：
1. **Skin Effect (集膚效應) 項：** $-k_s \cdot l \cdot (1+j)\sqrt{f}$
   - 此項描述高頻時電流集中在導體表面流動的現象。
   - 衰減量與頻率的平方根 $\sqrt{f}$ 成正比。
   - $k_s$ 是與導體幾何結構與材料特性（如銅的電導率、磁導率）相關的常數。
   - $(1+j)$ 是一個極度重要的因子：它表示 Skin effect 不僅造成訊號振幅的衰減（實部），同時也引入了與衰減量大小完全相同的相位偏移（虛部）。這個隨頻率變化的相位會導致訊號各頻率成分到達時間不同，產生嚴重的色散（Dispersion）。
2. **Dielectric Loss (介電損耗) 項：** $-k_d \cdot l \cdot f$
   - 此項描述訊號周圍的絕緣介質（Substrate/Dielectric）因為高頻電場交替變化，偶極子翻轉摩擦生熱所消耗的能量（即筆記中的 `substrate dissipate energy`）。
   - 衰減量與頻率 $f$ 成正比。
   - $k_d$ 是與介電材料的損耗正切（Loss Tangent, $\tan \delta$）及介電常數相關的常數。

### 單位解析
**公式單位消去：**
針對公式 $C(f) = \exp\left[ -k_s \cdot l \cdot (1+j)\sqrt{f} - k_d \cdot l \cdot f \right]$
指數函數 $\exp(x)$ 內的 $x$ 必須是**無因次（Dimensionless）**，或表示為奈培（Neper, 衰減）與弧度（Radian, 相位）。我們以 SI 基礎單位來推導常數的單位：
- $l$ (長度) 單位：$[m]$
- $f$ (頻率) 單位：$[Hz] = [s^{-1}]$
- $\sqrt{f}$ 單位：$[s^{-0.5}]$

1. **推導 $k_s$ 的單位：**
   $k_s \cdot l \cdot \sqrt{f} = \text{Dimensionless}$
   $[k_s] \cdot [m] \cdot [s^{-0.5}] = 1$
   $\Rightarrow [k_s] = [m^{-1} \cdot s^{0.5}]$
   （實務工程上，常表示為 $dB / (inch \cdot \sqrt{GHz})$）

2. **推導 $k_d$ 的單位：**
   $k_d \cdot l \cdot f = \text{Dimensionless}$
   $[k_d] \cdot [m] \cdot [s^{-1}] = 1$
   $\Rightarrow [k_d] = [m^{-1} \cdot s]$
   （實務工程上，常表示為 $dB / (inch \cdot GHz)$）

通道響應 $C(f)$ 本身是輸出與輸入的電壓比值（$V_{out}/V_{in}$），為無因次量。

**圖表單位推斷：**
本頁無圖表。（筆記中僅有導體截面電場分佈圖與背板系統架構示意圖，無座標軸與數據）。

### 白話物理意義
頻率越高，導體裡的電子就越不想走中間、全擠到表面（集膚效應），同時旁邊的絕緣板也會因為電場快速切換而發熱吃掉能量（介電損耗），導致高頻訊號在通道中越傳越小聲且變形。

### 生活化比喻
**把傳輸線想像成一條高速公路：**
- **Skin Effect（集膚效應）**：就像高速公路上車速極快（高頻）時，所有車子不知為何都只敢貼著最外側的護欄（表面）開，導致明明有六線道卻只用到兩線道，路變得很擠（等效電阻增加），訊號就耗損了。
- **Dielectric Loss（介電損耗）**：就像這條公路兩旁的風景區（介電質），車子開越快，風景區的吸血攤販（偶極子）就越活躍，不斷把你車上的物資（能量）以發熱的形式吸走。

### 面試必考點
1. **問題：在極高頻（例如 112Gbps PAM4）下，Channel Loss 主要由哪一種效應主導？**
   → **答案：** Dielectric Loss（介電損耗）。因為 Skin effect 的衰減與 $\sqrt{f}$ 成正比，而 Dielectric loss 與 $f$ 成線性正比。在低頻時 $\sqrt{f}$ 較大，由 Skin effect 主導；但當頻率上升跨過某個轉折點（交越頻率）後，$f$ 的成長速度會超越 $\sqrt{f}$，此時介電損耗將成為吞噬訊號的主要殺手。這也是為何先進封裝與背板要不斷追求 Ultra-low loss (Megtron 7/8) 板材的原因。
2. **問題：公式中 Skin Effect 項目的 $(1+j)$ 代表什麼物理意義？對接收端 (RX) 有什麼影響？**
   → **答案：** 它代表 Skin effect 不僅造成振幅衰減（實部 $1$），還會產生與衰減量呈正比的相位落後（虛部 $j$）。這代表通道不是線性相位的（Non-linear phase），會導致群集延遲（Group Delay）隨頻率變化，也就是高頻和低頻成分傳送的速度不同。這會嚴重破壞波形，產生嚴重的符元間干擾（ISI），是 RX 端的 CTLE 與 DFE 必須花費極大代價去等化的主因。
3. **問題：筆記提到 "Backplane trace suffers from skin effect more seriously"，為什麼 PCB Trace 的 Skin effect 會比 Coaxial cable 嚴重？**
   → **答案：** 除了幾何形狀（方形 vs 圓形）的邊緣效應外，最關鍵的是 **表面粗糙度（Surface Roughness）**。為了讓銅箔能緊緊黏在 PCB 樹脂基板上，製造時會故意把銅表面做得很粗糙。當高頻電流因為 Skin effect 只能貼著表面走時，粗糙的表面會讓電流被迫跟著高低起伏走「冤枉路」，實際路徑變長，等效電阻與損耗就大幅增加了。

**記憶口訣：**
**「集膚看根號，介電看線性；低頻擠表面，高頻烤基板。」**
