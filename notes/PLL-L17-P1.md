# PLL-L17-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L17-P1.jpg

---


---
## VCO & Important Details (LC Tank Amplitude & Spiral Inductors)

作為台大嚴格的助教，我必須先點出這頁筆記**有一個致命的觀念錯誤**。如果你在面試聯發科或瑞昱時把 $\frac{4}{\pi} I_{SS} R_p$ 說成是「單端」振幅，面試官會直接把你請出去。我們等下在數學推導來狠狠糾正這點。這頁的核心在講 LC VCO 的穩態振幅推導，以及螺旋電感 (Spiral Inductor) 的非理想效應與佈局策略。

### 數學推導
**1. LC Tank 穩態振幅推導 (糾正筆記錯誤)**
*   **Step 1: 定義切換電流。** 假設 Cross-coupled pair (M1, M2) 像理想開關，尾電流 $I_{SS}$ 會在左右兩邊 100% 切換 (Current Steering)。
*   **Step 2: 差動電流波形。** M1 電流為 0 到 $I_{SS}$ 的方波，M2 電流為 $I_{SS}$ 到 0 的方波。流入 LC Tank 的「差動電流」 $I_{diff} = I_{D1} - I_{D2}$ 是一個在 $+I_{SS}$ 與 $-I_{SS}$ 之間震盪的理想方波。
*   **Step 3: 傅立葉級數展開。** 振幅為 $I_{SS}$ 的方波，其基頻 (Fundamental) 成分的振幅為 $\frac{4}{\pi} I_{SS}$。
    $$I_{diff}(t) = \frac{4}{\pi} I_{SS} \left( \sin(\omega_0 t) + \frac{1}{3}\sin(3\omega_0 t) + \frac{1}{5}\sin(5\omega_0 t) + \dots \right)$$
*   **Step 4: LC Tank 濾波效應。** 在共振頻率 $\omega_0 = 1/\sqrt{LC}$ 時，理想 L 和 C 阻抗抵消，Tank 只剩下等效並聯阻抗 $R_p$。對於高頻諧波 ($3\omega_0, 5\omega_0$)，電容 C 會將其短路 (Short)。因此，只有基頻電流能乘上 $R_p$ 轉換成電壓。
*   **Step 5: 振幅計算。**
    *   **差動電壓振幅 (Differential Amplitude):** $V_{diff\_amp} = I_{fund\_amp} \times R_p = \mathbf{\frac{4}{\pi} I_{SS} R_p}$
    *   **單端電壓振幅 (Single-ended Amplitude):** $V_{SE\_amp} = V_{diff\_amp} / 2 = \mathbf{\frac{2}{\pi} I_{SS} R_p}$
    *   *(助教怒吼：筆記上寫 Amplitude = $\frac{4}{\pi} I_{SS} R_p$ 單端是錯的！請立刻拿紅筆改成差動！)*

**2. 堆疊式電感 (Stacked Inductor) 電感量**
*   筆記右下角的雙層電感，上下兩層為 $L_1$ 和 $L_2$，且兩者有互感 (Mutual Inductance) $M$。
*   總電感量 $L = L_1 + L_2 + 2M$ (因為電流同向，磁場疊加)。這能在極小的面積內換取大電感量，但代價是層間寄生電容極大，導致自共振頻率 ($f_{SR}$) 暴跌。

### 單位解析
**公式單位消去：**
*   **VCO 振幅：** $V_{diff\_amp} = \frac{4}{\pi} \times I_{SS} \times R_p$
    $$[V_{diff\_amp}] = [無單位] \times [A] \times [\Omega] = [A] \times [V/A] = [V]$$
*   **共振頻率：** $\omega_0 = \frac{1}{\sqrt{LC}}$
    $$[\omega_0] = \frac{1}{\sqrt{[H] \cdot [F]}} = \frac{1}{\sqrt{[V \cdot s / A] \cdot [A \cdot s / V]}} = \frac{1}{\sqrt{s^2}} = [s^{-1}] = [rad/s]$$

**圖表單位推斷：**
*   📈 **左側波形圖 (方波與弦波疊加)：**
    *   X 軸：時間 $t$ [ps]，典型範圍數十到數百皮秒 (取決於 VCO 頻率，若為 10GHz，週期為 100ps)。
    *   Y 軸：差動電流 $I_{diff}$ [mA] (方波，範圍 $\pm I_{SS}$) / 差動電壓 $V_{diff}$ [V] (弦波，範圍 $\pm \frac{4}{\pi} I_{SS} R_p$)。
*   📈 **電感佈局圖 (Square, Octagon 等)：**
    *   此為 Layout 俯視圖，X/Y 軸單位皆為物理尺寸 [$\mu m$]。右側筆記標示 Area 從 $500 \mu m^2$ 到 $8000 \mu m^2$ 不等。

### 白話物理意義
**LC VCO 就像推鞦韆**：Cross-coupled pair 就像是一個只會「用力推一下、然後放手」的粗魯大人（方波電流），但因為 LC Tank 這個鞦韆本身的物理特性（濾波），鞦韆最後搖擺的軌跡依然會是完美滑順的圓弧（弦波電壓）。

### 生活化比喻
**電感的非理想效應與佈局：**
1.  **Skin Effect (集膚效應)：** 高頻電流像是不喜歡擠在人群中的邊緣人，全都會擠到導線的最表面走，導致實際導電截面積變小、電阻變大。筆記中畫的「多層金屬打 Via (增加表面積)」就像是多開幾條小巷子讓邊緣人走，降低總阻力。
2.  **Eddy Current (渦電流)：** 電感產生的磁場打到下方的矽基板 (Substrate)，基板感應出反向電流，這會消耗掉電感的能量 (Q值下降)。筆記中間畫的 `poly substrate` (其實是指 Patterned Ground Shield, PGS) 就像是在地上鋪一層百葉窗，可以擋住電場，但切斷的迴路又不會讓磁場產生大渦電流。
3.  **Square vs Octagon：** 方形電感的 90 度轉角就像是急轉彎的賽道，電流全擠在內側（Current Crowding），造成局部高溫和高阻抗。八角形 (Octagon) 把急彎切平，電流走得更順，所以 Q 值從 13 提升到 15。

### 面試必考點
1.  **問題：在電流限制 (Current-limited) 區，如何提高 LC VCO 的相位雜訊 (Phase Noise) 表現？**
    *   **答案：** 提高振幅！因為振幅越大，信號雜訊比 (SNR) 越好。根據公式 $V_{diff} = \frac{4}{\pi}I_{SS}R_p$，可以藉由增加尾電流 $I_{SS}$，或是提高電感的 Q 值 (因為 $R_p = Q \cdot \omega L$) 來達到。
2.  **問題：為什麼高速 SerDes 的 VCO 幾乎都用差動八角形 (Differential Octagon) 或圓形電感，而不用方形？**
    *   **答案：** 方形電感在 90 度角有嚴重的 current crowding 效應，歐姆損耗大，導致 Q 值低。此外，差動佈局能保證 Virtual Ground 完美落在幾何中心，對共模雜訊免疫力更好，且面積利用率高於兩個獨立電感。
3.  **問題：Stacked Inductor (疊層電感) 的優缺點是什麼？適用於什麼場合？**
    *   **答案：** 優點是面積極小 ($L \propto N^2$，加上強互感 $M$)；缺點是層與層之間靠得很近，寄生電容 ($C_p$) 極大，導致自共振頻率 ($f_{SR} = 1/\sqrt{LC_p}$) 非常低，且 Q 值通常較差。適用於低頻、對面積極度敏感的應用，**不適用**於幾十 GHz 的高速 SerDes VCO。

**記憶口訣：**
「**四拍電流推電阻 (4/$\pi$ Iss Rp)，方波進去弦波出；方角太擠八角順，疊層面積小但頻率低。**」
