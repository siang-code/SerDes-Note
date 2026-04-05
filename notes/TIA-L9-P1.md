# TIA-L9-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/TIA-L9-P1.jpg

---


### 數學推導
**1. 加入 $C_F$ 的頻率補償 (Modified FB TIA)**
- **目的**：減少頻率響應的峰值 (Peaking)。
- **定義特徵頻率**：
  - 輸入端極點對應頻率：$\omega_i \triangleq \frac{1}{R_F \cdot C_{in}}$
  - 回授端零點對應頻率：$\omega_f \triangleq \frac{1}{R_F \cdot C_F}$
- **效應**：加入 $C_F$ 後，$C_F$ 與 $R_F$ 並聯，在高頻時阻抗下降，增加了回授因子，從而壓抑了系統的 $Q$ 值。如筆記範例，當 $GBW = 100 \omega_i$ 時，若設計 $\omega_f = 10 \omega_i$，可使系統 $Q \approx 0.95$，Peaking 僅剩約 $0.9\text{ dB}$，有效提升穩定度。

**2. 高速 TIA 的簡化電路小訊號推導 (Common-Source + Source-Follower)**
為了突破傳統 OpAmp 的 GBW 限制，採用 M1 (CS) 提供增益，M2 (SF) 提供緩衝與回授。
- **步驟一：輸入節點 KCL**
  假設 M1 的 Gate 端無電流流入，所有輸入小訊號電流 $I_{in}$ 皆流經反饋電阻 $R_F$ 至輸出端。
  $$V_x - V_{out} = I_{in} \cdot R_F \implies V_{out} = V_x - I_{in} \cdot R_F \quad \text{--- (式1)}$$
- **步驟二：核心放大器增益**
  M1 的小訊號電壓增益為 $-g_{m1} R_D$，因此 M2 的 Gate 電壓為：
  $$V_{g2} = -g_{m1} R_D \cdot V_x$$
- **步驟三：Source Follower (M2) 輸出關係**
  M2 的 Source 端即為 $V_{out}$。流經 M2 的小訊號電流等於從 $R_F$ 流向 Source 的電流 $-I_{in}$。因此 M2 的 Gate-Source 電壓：
  $$V_{gs2} = \frac{-I_{in}}{g_{m2}}$$
  根據定義 $V_{gs2} = V_{g2} - V_{s2}$，代入前述結果：
  $$\frac{-I_{in}}{g_{m2}} = -g_{m1} R_D V_x - V_{out} \implies V_{out} = -g_{m1} R_D V_x + \frac{I_{in}}{g_{m2}} \quad \text{--- (式2)}$$
- **步驟四：求解輸入阻抗 $R_{in}$**
  將 (式1) 與 (式2) 等號兩邊連立：
  $$V_x - I_{in} R_F = -g_{m1} R_D V_x + \frac{I_{in}}{g_{m2}}$$
  整理收集 $V_x$ 與 $I_{in}$：
  $$V_x (1 + g_{m1} R_D) = I_{in} \left(R_F + \frac{1}{g_{m2}}\right)$$
  $$R_{in} = \frac{V_x}{I_{in}} = \frac{R_F + \frac{1}{g_{m2}}}{1 + g_{m1} R_D}$$
- **步驟五：求解轉阻增益 $R_T$**
  將 $V_x = I_{in} \cdot R_{in}$ 代回 (式1)：
  $$R_T = \frac{V_{out}}{I_{in}} = \frac{V_x - I_{in} R_F}{I_{in}} = R_{in} - R_F$$
  $$R_T = \frac{R_F + \frac{1}{g_{m2}}}{1 + g_{m1} R_D} - R_F = \frac{\frac{1}{g_{m2}} - g_{m1} R_D R_F}{1 + g_{m1} R_D}$$
  當核心增益極大 ($g_{m1} R_D \gg 1$) 時，上式可完美近似為理想的轉阻增益：
  $$R_T \approx \frac{-g_{m1} R_D R_F}{g_{m1} R_D} = -R_F$$

### 單位解析
**公式單位消去：**
- **極點頻率 $\omega_i$**：
  $$\omega_i = \frac{1}{R_F \cdot C_{in}} \implies [\Omega]^{-1} \cdot [\text{F}]^{-1} = \left[\frac{\text{V}}{\text{A}}\right]^{-1} \cdot \left[\frac{\text{C}}{\text{V}}\right]^{-1} = \left[\frac{\text{A}}{\text{V}}\right] \cdot \left[\frac{\text{V}}{\text{A} \cdot \text{s}}\right] = [\text{s}^{-1}] = [\text{rad/s}]$$
- **輸入阻抗 $R_{in}$**：
  $$R_{in} = \frac{R_F + \frac{1}{g_{m2}}}{1 + g_{m1} R_D}$$
  分子單位：$[\Omega] + \left[\frac{\text{A}}{\text{V}}\right]^{-1} = [\Omega] + [\Omega] = [\Omega]$
  分母單位：$1 + \left[\frac{\text{A}}{\text{V}}\right] \cdot [\Omega] = 1 + \left[\frac{\text{A}}{\text{V}}\right] \cdot \left[\frac{\text{V}}{\text{A}}\right] = 1 + 1 = \text{無因次 (Unitless)}$
  總單位：$[\Omega] / 1 = [\Omega]$
- **轉阻增益 $R_T$**：
  $$R_T = -R_F \implies [\Omega]$$，工程上常表示為 $[\text{V/A}]$ 或是 $[\text{dB}\Omega]$。

**圖表單位推斷：**
📈 圖表單位推斷：TIA 頻率響應波德圖 (Bode Plot)
- **X 軸**：對數頻率 $\omega$ $[\text{rad/s}]$，典型範圍依傳輸率而定，在高速 SerDes 中範圍約在 $10^6 \sim 10^{11} \text{ rad/s}$。
- **Y 軸**：轉阻增益大小 $|A|$ $[\text{dB}\Omega]$，典型範圍 40~80 $\text{dB}\Omega$。圖中呈現了加入 $C_F$ 後直流增益平穩延伸，壓抑了諧振峰值。

### 白話物理意義
加了 $C_F$ 的 TIA 就像給容易搖晃的彈簧裝上阻尼器，防止高頻信號過度震盪；而「拔掉 OpAmp 換成 CS+SF」則是為了極致速度，放棄層層通報的大企業體制，改用扁平化結構來達成超低延遲。

### 生活化比喻
- **加 $C_F$ 補償**：就像是在容易搖晃的吊橋上加裝了「減震索」($C_F$)。原本高頻強風吹來橋會狂晃 (Peaking)，有了減震索就能把多餘的能量吸收掉，讓橋面穩穩當當。
- **Remove OpAmp (High-Speed TIA)**：原本的理想 OpAmp 就像是一個層層通報的豪華大集團，雖然防護好且做事嚴謹，但決策超級慢 (頻寬受限)；為了追求極速，我們把它換成只有兩層階級的「扁平化新創團隊」(CS + Source Follower)，命令下達極快，但缺點是容錯率低 (Parasitics 敏感) 且需要較高的營運資金 (Larger Supply > 1.8V)。

### 面試必考點
1. **問題：在 TIA 回授電阻 $R_F$ 兩端並聯電容 $C_F$ 的目的為何？它如何影響系統的 Pole/Zero？**
   → 答案：目的是為了頻率補償，降低轉阻響應在高頻的 Peaking ($Q$ 值)。$C_F$ 會在回授網路上引入一個零點，這會在閉迴路響應中轉化為一個主導極點，提升系統的相位裕度。
2. **問題：為何在 10G/28G 以上的 SerDes TIA 設計中，常放棄標準 OpAmp 架構，改用簡單的 Inverter/CS + Source Follower？**
   → 答案：標準多級 OpAmp 內部節點多、寄生電容大，會產生多個低頻極點，導致 GBW 嚴重受限。採用單級 CS 加 SF 可以將內部節點數與迴路延遲減至最少，從而將頻寬推向製程極限。
3. **問題：筆記中提到在高速 TIA 使用 Source Follower 架構的缺點 (Drawbacks) 有哪些？**
   → 答案：(1) Source Follower 本身的寄生電容 (Parasitics) 會影響極高頻響應；(2) $V_{gs}$ 壓降會消耗大量的 Voltage Headroom，導致需要較高的電源電壓 (Larger supply, 例如 > 1.8V)；(3) $I_b$ 電流源不僅耗電，也會引入額外的熱雜訊。

**記憶口訣：**
TIA 求快拔 OP，單級放大加 SF；回授並 C 壓 Peaking，小心 Headroom 需高 V。
