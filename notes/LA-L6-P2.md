# LA-L6-P2

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L6-P2.jpg

---


## 閉迴路增益的非理想效應與 Cherry-Hooper 轉阻分析

### 數學推導
**1. 實際閉迴路增益的一般式與一階近似**
系統的實際閉迴路增益 $H_{closed(actual)}$ 可由開迴路增益 $A$ 與回授因子 $\beta$ 表示：
$$H_{closed(actual)} = \frac{A}{1+A\beta}$$
為了分離出「理想增益」與「誤差項」，將分子分母同除以 $\beta$ 並引入迴路增益 $T = A\beta$：
$$H_{closed(actual)} = \frac{\frac{A\beta}{\beta}}{1+A\beta} = \frac{1}{\beta} \times \frac{A\beta}{1+A\beta} = \frac{1}{\beta} \times \frac{T}{1+T}$$
利用代數變換 $\frac{T}{1+T} = 1 - \frac{1}{1+T}$，當系統設計良好使得 $T \gg 1$ 時，$\frac{1}{1+T} \approx \frac{1}{T}$，可得到一階近似式（Taylor Expansion 近似）：
$$H_{closed(actual)} \approx \frac{1}{\beta} \left( 1 - \frac{1}{T} \right)$$
- **$\frac{1}{\beta}$**：理想的閉迴路增益（完全由外部被動元件決定）。
- **$\left( 1 - \frac{1}{T} \right)$**：非理想折扣因子（Error factor）。$T$ 越大，折扣因子越接近 1，系統越精準。

**2. Cherry-Hooper 放大器增益推導 (實際情況 vs 理想情況)**
針對由 $M_1$ (V-I 轉換) 與 $M_2$ + $R_F$ (TIA I-V 轉換) 組成的 Cherry-Hooper 結構：
- 第一級實際增益：$H_{1act} = -g_{m1}$ (將 $V_{in}$ 轉為電流 $I_{fb}$)
- 第二級迴路增益：$T_2 \approx g_{m2}R_F$
- 第二級實際增益：$H_{2act} = -R_F \left( 1 - \frac{1}{T_2} \right) = -R_F \left( 1 - \frac{1}{g_{m2}R_F} \right)$
將兩級增益相乘得到整體電壓增益：
$$\frac{V_{out}}{V_{in}} = H_{1act} \times H_{2act} = (-g_{m1}) \times \left[ -R_F \left( 1 - \frac{1}{g_{m2}R_F} \right) \right]$$
$$\frac{V_{out}}{V_{in}} = g_{m1}R_F - \frac{g_{m1}}{g_{m2}}$$
在此式中，$g_{m1}R_F$ 為理想電壓增益，$-\frac{g_{m1}}{g_{m2}}$ 則是因 $T_2$ 有限所造成的增益減損誤差 (Gain Error)。

**3. 虛擬接地與輸入阻抗 (Shunt Input)**
閉迴路輸入阻抗公式：
$$R_{in,closed} = \frac{R_{in,open}}{1+T_2}$$
- 在實際電路中 (左圖)，$R_{in,open} \approx R_F$ 且 $T_2 = g_{m2}R_F$，故 $R_{in,closed} \approx \frac{R_F}{g_{m2}R_F} = \frac{1}{g_{m2}}$。
- 在理想 Op-Amp TIA 中 (右圖)，$T_2 \to \infty$，故 $R_{in,closed} \to 0$（不用修正，完美虛擬接地）。

### 單位解析
**公式單位消去：**
- **迴路增益 $T = A \times \beta$ (以 TIA 為例)**
  $A$ 為轉阻增益 $[V/A]$，$\beta$ 為回授轉導 $[A/V]$
  $T = [V/A] \times [A/V] = [\text{Unitless}]$ (無單位，純粹的比例係數)
- **整體電壓增益 $\frac{V_{out}}{V_{in}} = g_{m1}R_F - \frac{g_{m1}}{g_{m2}}$**
  第一項 $g_{m1}R_F$：$[A/V] \times [\Omega] = [A/V] \times [V/A] = [V/V]$ (電壓增益，無單位)
  第二項 $\frac{g_{m1}}{g_{m2}}$：$[A/V] \div [A/V] = [V/V]$ (誤差項，亦為無單位)
  兩項物理單位完全一致，可合法相減。

**圖表單位推斷：**
本頁無圖表。（僅有電路拓樸示意圖）

### 白話物理意義
實際電路的增益永遠等於「SOP理想值」乘上一個「$(1 - 1/T)$ 的打折係數」；當系統糾錯能力 (Loop Gain, T) 不夠大時，虛擬接地就不夠完美，會產生無法完全吸收輸入電流的殘餘阻抗，導致最終增益被打折扣。

### 生活化比喻
- **開迴路增益 $A$**：基層員工的蠻力。會受天氣心情 (PVT) 影響，極不穩定。
- **回授因子 $\beta$**：公司的 SOP 制度。由被動元件決定，非常穩定且客觀。
- **迴路增益 $T$**：公司的糾錯與自省能力 ($A \times \beta$)。
理想上，公司產出完全按 SOP 走 ($1/\beta$)。但現實中糾錯能力 $T$ 是有限的，所以實際產出會打個折 $(1 - 1/T)$。如果公司糾錯能力無限大 ($T \to \infty$)，那員工就算再雷，最終產出也會跟完美 SOP 一模一樣（誤差項歸零，達到完美虛擬接地）。

### 面試必考點
1. **問題：在設計回授電路時，為什麼我們總是追求極大的 Loop Gain ($T$)？**
   → **答案：** 因為實際增益 $H_{actual} \approx \frac{1}{\beta}(1-\frac{1}{T})$。$T$ 越大，$(1-\frac{1}{T})$ 的打折誤差越小，閉迴路增益便能越精準地貼近由被動元件決定的 $\frac{1}{\beta}$，從而抵抗 PVT (製程、電壓、溫度) 變異。同時能使輸入阻抗趨近於 0，達成完美虛擬接地。
2. **問題：Cherry-Hooper 放大器的第二級 (TIA) 會對整體電壓增益造成什麼誤差？請寫出包含誤差的增益公式。**
   → **答案：** 誤差來自於第二級有限的轉導 $g_{m2}$ 導致 Loop Gain 不足。整體增益為 $g_{m1}R_F - \frac{g_{m1}}{g_{m2}}$。其中 $g_{m1}R_F$ 是理想增益，$-\frac{g_{m1}}{g_{m2}}$ 就是因第二級虛擬接地不完美 (閉迴路輸入阻抗為 $1/g_{m2}$)，無法完全吸收第一級轉導電流所流失的信號誤差。
3. **問題：Shunt-Shunt (並聯-並聯) 回授的物理意義是什麼？其終極目標為何？**
   → **答案：** Shunt 輸入代表回授網路在輸入端是以「並聯」形式交會，充當電流的混合與吸收中心。其終極目標是利用極大的 $T$ 將輸入阻抗降為 0 ($R_{in,closed} \to 0$)，形成完美的虛擬接地，使其具備理想電流計特性（吃盡所有電流而不改變節點電壓）。

**記憶口訣：**
「增益打折看 T，誤差減去一比一 (gm1/gm2)；Shunt並聯降阻抗，虛擬接地零殘留。」
