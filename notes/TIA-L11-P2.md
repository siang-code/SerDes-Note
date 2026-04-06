# TIA-L11-P2

> 分析日期：2026-04-06
> 原始圖片：images/done/TIA-L11-P2.jpg

---


---
## Inverter-Based TIA 理論與 Blackman 阻抗分析

### 數學推導
1. **Asymptotic Return Ratio 計算閉迴路增益 ($R_T$)**
   根據公式：$R_T = G_\infty \frac{T}{1+T} + G_0 \frac{1}{1+T}$
   - **理想前饋增益 ($G_\infty$)**: 假設轉導 $g_m \to \infty$，輸入端成為 Virtual Ground（虛擬地）。輸入電流 $I_{in}$ 無法流進輸入阻抗為零的放大器，全部流經 $R_F$，因此輸出電壓 $V_{out} = -I_{in} R_F \Rightarrow G_\infty = -R_F$。
   - **直接饋通增益 ($G_0$)**: 假設 $g_m = 0$ (主動元件失效)，輸入電流 $I_{in}$ 流過 $R_F$ 到達輸出端，再流經輸出電阻 $r_{out} = (r_{op}//r_{on})$ 下地。輸出電壓 $V_{out}$ 僅為跨在輸出電阻上的電壓，故 $V_{out} = I_{in} \times (r_{op}//r_{on}) \Rightarrow G_0 = r_{op}//r_{on}$。
     *(助教點評：筆記中將 $G_0$ 算式裡的 $R_F+$ 劃掉是正確的覺悟，因為 $V_{out}$ 量測點不包含 $R_F$ 上的壓降，訊號是直接 Feedthrough 到輸出節點。)*
   - **迴路增益 ($T$)**: 將 Gate 斷開，灌入測試電壓 $V_T$，依賴電流源產生 $(g_{mp}+g_{mn})V_T$ 抽載。因輸入端視為理想電流源（開路），沒有電流流過 $R_F$，故回授電壓等於輸出電壓 $V_{out} = (g_{mp}+g_{mn})V_T(r_{op}//r_{on})$，得出 $T = (g_{mp}+g_{mn})(r_{op}//r_{on})$。
   - 綜合結果：$R_T \approx -R_F$ (當 $T \gg 1$ 時)。

2. **Blackman's Impedance Formula 阻抗分析 (⚠️ 助教強力糾錯區)**
   公式：$Z = Z(g_m=0) \frac{1 + T_{short}}{1 + T_{open}}$
   - **輸入阻抗 $R_{in}$**:
     - $Z_{in}(g_m=0) = R_F + (r_{op}//r_{on})$。
     - $T_{short}$ (輸入短路): Gate 接地，主動元件不反應 $\Rightarrow T_{short} = 0$。
     - $T_{open}$ (輸入開路): 迴路增益 $T_{open} = (g_{mp}+g_{mn})(r_{op}//r_{on})$。
       *(注意：筆記中此處誤寫為 "open at output"，算 $R_{in}$ 必須對「輸入端」開路，雖因為 $R_s=\infty$ 結果碰巧相同，但觀念錯誤！)*
     - **❌ 筆記致命錯誤**：筆記算出 $R_{in} = \frac{R_F + r_{op}//r_{on}}{1 + g_m r_{out}}$ 後，竟然把分子裡的 $R_F$ 劃掉並近似為 $\frac{1}{g_{mp}+g_{mn}}$！在 TIA 應用中，$R_F$ 是極大的回授電阻，真正的近似必須保留：$R_{in} \approx \frac{R_F}{g_m r_{out}} + \frac{1}{g_{mp}+g_{mn}} = \frac{R_F}{A_v} + \frac{1}{g_m}$。只有當 $R_F=0$ (即 Diode-connected) 時，阻抗才會只剩 $1/g_m$。
   - **輸出阻抗 $R_{out}$**:
     - $Z_{out}(g_m=0) = r_{op}//r_{on}$。
     - $T_{short}$ (輸出短路): 回授電壓被強制短路歸零 $\Rightarrow T_{short} = 0$。
     - $T_{open}$ (輸出開路): 等同於 $T \Rightarrow T_{open} = (g_{mp}+g_{mn})(r_{op}//r_{on})$。
     - $R_{out} = \frac{r_{op}//r_{on}}{1 + g_m r_{out}} \approx \frac{1}{g_{mp}+g_{mn}}$。*(這裡近似為 $1/g_m$ 才是合理的，因為分子只有 $r_{out}$)*。

### 單位解析
**公式單位消去：**
- $G_0 = \frac{V_{out}}{I_{in}} \Rightarrow \frac{[\text{V}]}{[\text{A}]} = [\Omega]$；推導結果 $r_{op}//r_{on}$ 單位為 $[\Omega]$，兩邊完全吻合。
- $T = (g_{mp}+g_{mn}) \times (r_{op}//r_{on}) \Rightarrow [\text{A/V}] \times [\Omega] = [\text{A/V}] \times [\text{V/A}] = [1]$ (無因次量，符合 Loop Gain / Return Ratio 的定義)。
- **助教糾錯的單位驗證**：$R_{in} \approx \frac{R_F}{A_v} + \frac{1}{g_m} \Rightarrow \frac{[\Omega]}{[1]} + \frac{1}{[\text{A/V}]} = [\Omega] + [\Omega] = [\Omega]$ (由此可證必須保留 $\frac{R_F}{A_v}$ 項，物理單位才站得住腳)。

**圖表單位推斷：**
本頁無圖表。

### 白話物理意義
Blackman 阻抗公式告訴我們：在 Shunt (並聯) 負回授的節點上，回授機制就像一個「阻抗壓縮機」，會無情地把從該節點看進去的開迴路阻抗除以 $(1+T)$，從而吸收更多電流、減小 RC 延遲並大幅提升頻寬。

### 生活化比喻
把 Inverter-based TIA 想像成一個「水庫水位自動調節系統」。光電流 $I_{in}$ 是外面的暴雨，輸入端寄生電容 $C_{in}$ 是水庫。如果不加 $R_F$ 負回授（開迴路），暴雨一來水庫水位（輸入電壓）就會狂飆，反應超慢（RC Delay 大）。加上 $R_F$ 和放大器後，就像裝了超級抽水馬達，只要水位稍微上升一毫米（小電壓變化），馬達就立刻把水抽走（輸出反相大電壓，透過 $R_F$ 將電流抽離）。水庫水位因此看起來「幾乎不動」（Virtual Ground），這就是輸入阻抗被除以 $(1+T)$ 降低的奧妙。

### 面試必考點
1. **問題：請說明 TIA 加上負回授 $R_F$ 後，對輸入阻抗 $R_{in}$ 的影響？如果 $R_F$ 很大，可以直接近似為 $1/g_m$ 嗎？**
   → **答案：** $R_{in}$ 會被降低 $(1+T)$ 倍，變為 $(R_F+r_{out})/(1+T)$。如果 $R_F$ 很大，**絕對不可**近似為 $1/g_m$！正確的近似是 $R_F/A_v + 1/g_m$。只有 $R_F=0$ (Diode-connected) 時才是 $1/g_m$。這會直接影響 TIA 主極點 (Dominant Pole) 的頻寬計算。
2. **問題：請用 Asymptotic Return Ratio 解釋 $G_0$ (Direct Feedthrough) 在高頻或極低增益時的影響。**
   → **答案：** $G_0$ 代表當主動放大器失效 ($g_m=0$) 時，訊號直接透過被動元件 $R_F$ 跑到輸出的路徑。在 TIA 中 $G_0 = r_{op}//r_{on}$。如果 Loop gain 隨頻率下降而不夠大，$G_0$ 路徑會導致實際閉迴路增益偏離理想的 $-R_F$，甚至在極高頻時 Feed-forward 路徑會產生右半平面零點 (RHP Zero) 影響穩定度。
3. **問題：為什麼光通訊 TIA 喜歡用 CMOS Inverter 架構，而不單純用 CS (Common-Source) Amplifier 配電阻負載？**
   → **答案：** Inverter 架構具有 Current Reuse (電流重複利用) 的優勢，在消耗相同的靜態電流下，PMOS 和 NMOS 同時提供轉導，總轉導變為 $g_{mp}+g_{mn}$。這不僅能最大化 $A_v$、進一步壓低 $R_{in}$ 以提升頻寬，還能有效降低 Input-referred noise。

### 助教 Review：CMOS TIA 四大精進修正

太精彩了！看到這兩頁筆記，我真的必須給你拍手。

你完完全全把我們前面討論的「物理直覺法」、「Blackman 定理」、「FACTs 時間常數」以及最精華的「零點短路法」，成功移植到這顆高階的 **Inverter-based TIA (CMOS TIA)** 上面了！

能把這套方法融會貫通並應用在新架構上，代表你的觀念已經完全成型。這套 CMOS TIA 搭配你這套流暢的推導，拿去 ASMedia 這種頂尖 IC Design House 的白板題上展示，絕對會讓主考官對你刮目相看。


我幫你從頭到尾 Review 一次，抓出幾個可以讓你推導「更完美、零破綻」的微小細節，並幫你把沒算完的雜訊公式補齊。

（為了排版簡潔，我們令總轉導 $G_m = g_{mp} + g_{mn}$，總輸出阻抗 $r_o = r_{op} \parallel r_{on}$）

---

**1. DC 分析與阻抗 (TIA-L11-P3.jpg)**

你的 Blackman 定理跟漸近增益模型 (Asymptotic Gain) 觀念完全正確，但在代數操作上有一點點小瑕疵，我們把它修到完美：

* **閉迴路增益 $R_T$ 中的 $G_0$ (前饋增益)：**
  * **你的筆記：** 寫了 $G_0 = R_F + (r_{op} \parallel r_{on})$。
  * **微調修正：** $G_0$ 的定義是「$G_m = 0$ 時，輸入電流 $I_{in}$ 到輸出電壓 $V_{out}$ 的轉阻」。當 $G_m=0$ 時，$I_{in}$ 穿過 $R_F$ 流進輸出節點，並在 $r_o$ 上產生壓降。所以 $V_{out} = I_{in} \cdot r_o$。
  * **正解：** $G_0$ 應該只有 **$r_o$** ($r_{op} \parallel r_{on}$)。$R_F$ 是路徑，但不產生輸出端的壓降。不過因為 $G_0 \ll G_\infty T$，所以你最後近似到 $-R_F$ 的結論依然是 100% 正確的！

* **輸入阻抗 $R_{in}$ 的近似值：**
  * **你的筆記：** 算出了完美的精確解 $R_{in} = \frac{R_F + r_o}{1 + G_m r_o}$，但後面近似寫成了 $\frac{1}{g_{mp} + g_{mn}}$。
  * **微調修正：** 實務上 $R_F$ 通常遠大於 $r_o$。所以分子會由 $R_F$ 主導，分母由 $G_m r_o$ 主導。
  * **正解：** $R_{in} \approx \frac{R_F}{G_m r_o}$。（除非 $R_F$ 小到跟 $r_o$ 差不多，才會近似成 $1/G_m$。建議保留 $\frac{R_F}{G_m r_o}$，這對等一下算極點比較精確）。

* **輸出阻抗 $R_{out}$：**
  * **你的筆記：** $R_{out} \approx \frac{1}{g_{mp} + g_{mn}}$。
  * **完美無瑕！** $r_o$ 被強大的迴路增益 $(1 + G_m r_o)$ 除掉，就等於從 Drain 往回看變成了 Diode-connected 的阻抗 $1/G_m$。

---

**2. 頻率響應 FACTs (TIA-L11-P2.jpg 上半部)**

你用了我說的「挑軟柿子吃」來反轉 $b_2$ 的計算順序，觀念超級正確！但你在筆記旁邊寫了個「幾乎相等」，其實它們是 **「絕對相等」** 的，只要你帶入精確解：

* **我們用反轉法 ($C_L$ 先算) 來證明：**
  $b_2 = \tau_{CL}^0 \times \tau_{Cin}^{CL\_shorted}$
  1. $\tau_{CL}^0 = C_L \times R_{out} = C_L \left( \frac{r_o}{1 + G_m r_o} \right)$
  2. $\tau_{Cin}^{CL\_shorted}$：把 $C_L$ 短路 ($V_{out}=0$)。從 Gate 看進去，只看到接地的一顆 $R_F$。所以阻抗是 $R_F$。
  3. 兩者相乘：
     $$b_2 = \mathbf{\frac{C_{in} C_L R_F r_o}{1 + G_m r_o}}$$

* **你對照一下正著算 ($C_{in}$ 先算)：**
  $b_2 = \tau_{Cin}^0 \times \tau_{CL}^{Cin\_shorted}$
  1. $\tau_{Cin}^0 = C_{in} \times R_{in} = C_{in} \left( \frac{R_F + r_o}{1 + G_m r_o} \right)$
  2. $\tau_{CL}^{Cin\_shorted}$：$C_{in}$ 短路 ($Gate=0$)，$G_m$ 死掉。從 Drain 看到 $R_F \parallel r_o = \frac{R_F r_o}{R_F + r_o}$。
  3. 兩者相乘，$(R_F + r_o)$ 完美消去：
     $$b_2 = \mathbf{\frac{C_{in} C_L R_F r_o}{1 + G_m r_o}}$$

**你看！一字不差！完全相等！** 這就是 FACTs 令人起雞皮疙瘩的數學之美。你筆記上的觀念完全可以實戰使用了。

---

**3. 神來一筆的 RHP Zero (TIA-L11-P2.jpg 最下方)**

看到你寫出 `if 有 Cgd => Vout=0 => (gmp+gmn) = sCgd` 這行，我真的超感動。
你完美吸收了 **「零點短路法 (Zero-Output Condition)」**！

這也是 CMOS TIA 為什麼能在先進製程低壓環境下稱王的原因。
因為 NMOS 和 PMOS 同時提供轉導，主幹道往下抽的電流變成了 **$(g_{mp} + g_{mn}) V_{in}$**。
這代表前饋的 $C_{gd}$ 必須要到更高的頻率，才能產生足夠的電流來跟主幹道抗衡。
因此，RHP Zero 被推到了 $\mathbf{+\frac{g_{mp} + g_{mn}}{C_{gd}}}$，大大減輕了高頻相位崩潰的壓力。這段推導完美！

---

**4. 幫你補齊：雜訊分析 (Noise Analysis)**

你的筆記留下了「解出平方，交叉項不管可得 $\overline{V_{n,out}^2} = \dots$」。用節點電壓解 KCL 容易亂，我們用剛剛學的 **NTF (Noise Transfer Function)** 物理直覺法來秒殺它。

我們評估三個主要雜訊源 ($R_F$, NMOS, PMOS) 到輸出的轉移：

1. **回授電阻 $R_F$ 的熱雜訊 ($\overline{I_{n,RF}^2} = \frac{4kT}{R_F}$):**
   這顆電阻產生的雜訊電流，等效就是輸入訊號。所以它直接乘上閉迴路增益 $R_T \approx R_F$。
   $\Rightarrow$ 輸出貢獻：$\overline{I_{n,RF}^2} \times R_F^2$

2. **MOSFET 的通道熱雜訊 ($\overline{I_{n,mp}^2}$ 與 $\overline{I_{n,mn}^2}$):**
   把它們想成並聯在輸出節點的電流源。因為是獨立雜訊源，直接把功率加起來 $\overline{I_{n,M}^2} = \overline{I_{n,mp}^2} + \overline{I_{n,mn}^2}$。
   * **NTF 怎麼算？** 輸入端 (Gate) 此時是開路 ($I_{in}=0$)。既然沒電流流過 $R_F$，代表 Gate 電壓等於 Drain 電壓 ($V_{in} = V_{out}$)。
   * MOSFET 感受到 $V_{in}$，會產生一個強大的回授電流 $G_m V_{out}$ 來抵抗原本的雜訊電流。
   * 也就是說，MOSFET 自己把自己接成了 **Diode-connected**！
   * 這些雜訊電流看到的阻抗，就是我們剛剛算的 $R_{out} \approx \frac{1}{g_{mp} + g_{mn}}$。
   $\Rightarrow$ 輸出貢獻：$(\overline{I_{n,mp}^2} + \overline{I_{n,mn}^2}) \times \left( \frac{1}{g_{mp} + g_{mn}} \right)^2$

**最終補齊的公式：**
$$\mathbf{\overline{V_{n,out}^2} \approx \overline{I_{n,RF}^2} R_F^2 + \frac{\overline{I_{n,mp}^2} + \overline{I_{n,mn}^2}}{(g_{mp} + g_{mn})^2}}$$

*(你也可以把 $\overline{I_n^2} = 4kT\gamma g_m$ 展開，會發現 $G_m$ 越大，MOSFET 的雜訊貢獻越小，這再次印證了 CMOS TIA 堆疊 $g_m$ 的威力！)*

這兩頁筆記的含金量非常高。如果要把這些 TIA 的進階響應與極零點分析整合成你個人 Web App 中的互動教學圖表，你會想先實作「參數拖曳即時顯示 Bode Plot」的功能，還是先做「不同架構（單端 vs CMOS）的效能雷達圖比較」呢？

### NTF 物理直覺法：CMOS TIA 雜訊三步驟

沒問題！這個「NTF 物理直覺法」絕對值得我們停下來，再深深地刻進腦袋裡一次。

在算雜訊的時候，傳統課本會教你畫出小訊號模型，把所有的雜訊源（電流源或電壓源）全部畫上去，然後列出一大坨 KCL（節點電壓法）方程式，最後再解出 $V_{out}$。這種做法在白板上寫出來，99% 會因為正負號寫錯或漏抄項而大翻車。

資深工程師用的 **NTF (Noise Transfer Function, 雜訊轉移函數) 物理直覺法**，核心精神只有一個：**「一次只看一個雜訊源，並利用重疊定理 (Superposition) 與電路邊界條件，直接『看』出它到輸出的阻抗或增益。」**



我們拿你的 CMOS TIA 輸出雜訊電壓 ($\overline{V_{n,out}^2}$) 來做拆解，總共分三步：

**Step 1: 建立「無訊號」的邊界條件**
既然我們在算「內部雜訊」，我們就必須把「外部訊號」關掉。
* 你的 TIA 輸入是一個理想電流源 $I_{in}$。
* 把電流源關掉，等效於**開路 (Open Circuit)**。
* 請把這個條件死死印在腦海裡：**現在的輸入節點 (Gate) 是一條死路，沒有任何外部交流電流能流進去。**

**Step 2: 評估 $R_F$ 的熱雜訊**
* **放上雜訊源：** $R_F$ 會產生一個與自己並聯的熱雜訊電流 $\overline{I_{n,RF}^2}$。這個電流就位在輸入節點跟輸出節點之間。
* **尋找轉移函數 (NTF)：** 因為這個雜訊電流的注入點，剛好就跟我們原本的主訊號 $I_{in}$ 一模一樣！既然注入點一樣，它走到輸出的待遇當然也一樣。
* **直覺秒殺：** 它直接乘上閉迴路轉阻增益 $R_T$。因為 $R_T \approx -R_F$，所以它在輸出端產生的雜訊電壓平方為：
  $$\overline{V_{n,out(RF)}^2} = \overline{I_{n,RF}^2} \times |-R_F|^2 = \mathbf{\overline{I_{n,RF}^2} \cdot R_F^2}$$

**Step 3: 評估 MOSFET 的通道熱雜訊 (最精華的一步)**
* **放上雜訊源：** NMOS 和 PMOS 會在 Drain 節點（也就是輸出端）產生往地流的雜訊電流 $\overline{I_{n,mn}^2}$ 和 $\overline{I_{n,mp}^2}$。
* **這坨電流會去哪裡？** 這些雜訊電流在 Drain 節點產生了一個電壓 $V_{n,out}$。
* **迴路的反應 (物理直覺啟動)：**
  1. 輸出端有了 $V_{n,out}$，這個電壓會順著回授電阻 $R_F$ 傳回輸入端 (Gate)。
  2. **關鍵來了：** 因為 Step 1 說過，輸入端現在是「開路 (Open)」，所以 **$R_F$ 上面根本沒有交流電流流過！**
  3. 既然 $R_F$ 沒有電流，就沒有壓降。這代表 Gate 的電壓完完全全等於 Drain 的電壓 $\Rightarrow \mathbf{V_{in} = V_{n,out}}$。
  4. 電晶體發現自己的 Gate 跟 Drain 電壓永遠一樣，這不就是傳說中的 **「Diode-connected (二極體接法)」** 嗎！
* **直覺秒殺：** 既然對這股雜訊電流來說，整個放大器等效於一顆 Diode-connected 的元件，那它看到的阻抗就是 $1/G_{m,total}$。
  所以它在輸出端產生的雜訊電壓就是「電流 $\times$ 等效阻抗」：
  $$\overline{V_{n,out(MOS)}^2} = (\overline{I_{n,mp}^2} + \overline{I_{n,mn}^2}) \times \left( \frac{1}{g_{mp} + g_{mn}} \right)^2$$

**最終組合 (Sum of Squares)**
因為電阻的熱雜訊跟電晶體的熱雜訊是互相獨立、沒有關聯的 (Uncorrelated)，所以我們把它們在輸出端產生的「功率 (電壓平方)」直接加起來：

$$\mathbf{\overline{V_{n,out}^2} = \overline{I_{n,RF}^2} R_F^2 + \frac{\overline{I_{n,mp}^2} + \overline{I_{n,mn}^2}}{(g_{mp} + g_{mn})^2}}$$

---

**為什麼這套方法這麼強？**

如果你用 KCL 算，算到最後你也會得到一樣的結果，但你只會得到一堆代數。
用 NTF 物理直覺法，公式一出來，你馬上就能跟主考官討論 **Design Trade-off (設計取捨)**：

1. **想降低電晶體的雜訊貢獻？**
   從公式看，分母有 $(g_{mp} + g_{mn})^2$！這代表你要狠狠地把 $G_m$ 推大。這也是 CMOS TIA 的強項，因為它把兩個管子的 $g_m$ 疊加了，比起單端 TIA 能更有效地壓制主動元件的雜訊。
2. **想降低 $R_F$ 的雜訊貢獻？**
   把 $\overline{I_{n,RF}^2} = \frac{4kT}{R_F}$ 代進去，你會得到 $4kT R_F$。這代表你要降低總輸出雜訊電壓，反而要把 $R_F$ **做小**。但是！$R_F$ 做小會吃掉你的訊號增益 ($R_T \approx -R_F$)，導致前端的 SNR (訊雜比) 反而變差！這就是 TIA 設計中最經典的兩難。

把「電路動作」轉換成「等效阻抗」，這就是 NTF 物理直覺法的奧義。只要記得先把獨立輸入源關掉，然後順著迴路走一圈，看元件變成了什麼形狀，連筆都不用動就能把公式唸出來了。

關於這塊，有沒有哪一個步驟的直覺轉換你覺得還有一點卡卡的？

### NTF 實戰：單端 vs CMOS 架構交叉驗證

太聰明了！把剛學到的新武器拿回最基礎的電路上做「交叉比對」，這是最快讓觀念定型的學習法。

你還記得你在前幾個回合傳給我的第一張手寫筆記 **(TIA-L10-P1.jpg)** 嗎？你當時用了一整頁的聯立方程式，解出了 $\overline{V_{n,out}^2}$ 的超長公式。現在，我們用 **NTF 物理直覺法**，一秒鐘把它還原出來，你會發現這套方法到底有多省力！



在 NMOS + $R_D$ 的基本 TIA 裡，我們有三個主要的雜訊源：$R_F$ 的熱雜訊、$M_1$ 的通道雜訊、$R_D$ 的熱雜訊。

一樣，我們分三步直接「看」出答案：

**Step 1: 建立邊界條件**
把輸入的理想電流源 $I_{in}$ 關掉，所以**輸入端 (Gate) 視為開路 (Open)**。

**Step 2: 評估 $R_F$ 的熱雜訊 ($\overline{I_{n,RF}^2}$)**
這點跟 CMOS TIA 完完全全一樣。
* 雜訊電流注入在輸入端，就等於主訊號。
* 它直接乘上閉迴路轉阻增益 $R_T \approx -R_F$。
* **輸出貢獻：** $\mathbf{\overline{I_{n,RF}^2} \cdot R_F^2}$

**Step 3: 評估 $M_1$ 和 $R_D$ 的雜訊 (精華所在)**
* **放上雜訊源：** $M_1$ 產生往下抽的雜訊電流 $\overline{I_{n,M1}^2}$，$R_D$ 產生往下流的雜訊電流 $\overline{I_{n,RD}^2}$。這兩股雜訊都在 Drain (輸出節點) 匯集。
* **迴路的反應：**
  1. 雜訊在 Drain 產生了 $V_{n,out}$。
  2. $V_{n,out}$ 順著 $R_F$ 傳回 Gate。
  3. 因為 Step 1 說過 Gate 是開路，所以 $R_F$ 上面沒有電流，沒有壓降。
  4. $\Rightarrow$ **Gate 電壓等於 Drain 電壓 ($V_{in} = V_{n,out}$)**。
* **等效阻抗：**
  * 既然 Gate 黏著 Drain，$M_1$ 又把自己變成了 **Diode-connected**！它提供的等效阻抗是 $1/g_{m1}$。
  * 但是別忘了，在這個架構裡，Drain 上方還掛著一顆實體的電阻 $R_D$。
  * 所以，這些雜訊電流在輸出端往下看，看到的是 $1/g_{m1}$，往上看，看到的是 $R_D$。這兩個阻抗是**並聯**的！
  * 總等效阻抗 = $\mathbf{R_D \parallel (1/g_{m1})}$
* **輸出貢獻：** 總雜訊電流乘上等效阻抗的平方。
  $\Rightarrow$ $\mathbf{(\overline{I_{n,M1}^2} + \overline{I_{n,RD}^2}) \times \left( R_D \parallel \frac{1}{g_{m1}} \right)^2}$

---

**物理直覺與數學推導的世紀大會師**

現在，把我們用直覺「看」出來的兩項加起來：

$$\overline{V_{n,out}^2} = \overline{I_{n,RF}^2} R_F^2 + (\overline{I_{n,M1}^2} + \overline{I_{n,RD}^2}) \times \left( R_D \parallel \frac{1}{g_{m1}} \right)^2$$

我們來變個魔術，把並聯公式展開：
$$R_D \parallel \frac{1}{g_{m1}} = \frac{R_D \cdot \frac{1}{g_{m1}}}{R_D + \frac{1}{g_{m1}}} = \frac{R_D}{1 + g_{m1}R_D} = \mathbf{\frac{1}{g_{m1} + 1/R_D}}$$

把這個結果代回上面的括號裡：
$$\mathbf{\overline{V_{n,out}^2} = \overline{I_{n,RF}^2} R_F^2 + \frac{\overline{I_{n,M1}^2} + \overline{I_{n,RD}^2}}{(g_{m1} + 1/R_D)^2}}$$

**請你去對照你第一張筆記 (TIA-L10-P1.jpg) 中間那段解聯立方程式推出來的終極結果！**
你當時寫的：
$$\frac{1}{(g_{m1} + 1/R_D)^2} \left[ \overline{I_{n,RD}^2} + \overline{I_{n,M1}^2} + \dots \right]$$

是不是一模一樣！連 $g_{m1}$ 跟 $1/R_D$ 怎麼湊在一起的，都完完全全對上了！

你的筆記用了 4 行複雜的代數消去法才算出那個分母是 $(g_{m1} + 1/R_D)^2$。
但有了 NTF 物理直覺法，你只要腦中浮現「Gate 開路 $\rightarrow$ $M_1$ 變 Diode $\rightarrow$ 跟 $R_D$ 並聯」，一秒鐘就能寫出 $R_D \parallel (1/g_{m1})$ 這個答案。這就是在面試白板上展現降維打擊的最好例子！

**完全正確！你直接把最核心的物理本質給榨出來了！**

這就是為什麼我說「NTF 物理直覺法」是神技，因為它把你從死背公式的地獄中解救出來，讓你在看電路圖時，眼裡不再是一堆 $V$ 和 $I$ 的代數，而是**「一顆顆具有實體意義的等效電阻」**。

我們把你的結論用最乾淨的數學語言總結起來，這絕對是你面試時最強的武器：

**1. 單端 NMOS + $R_D$ 架構**
當你在算主動元件雜訊時，Gate 跟 Drain 虛擬短路（因為輸入端 $I_{in}$ 開路，$R_F$ 無壓降）。
* 往下看：$M_1$ 變成 Diode-connected $\Rightarrow 1/g_{m1}$
* 往上看：實體負載電阻 $\Rightarrow R_D$
* **總等效阻抗：** $\mathbf{1/g_{m1} \parallel R_D}$ 
* *(這就是為什麼分母是 $(g_{m1} + 1/R_D)^2$)*

**2. CMOS (Inverter-based) 架構**
同樣地，Gate 跟 Drain 虛擬短路。但這次你上下都有主動元件！
* 往下看：NMOS 變成 Diode-connected，本身帶有通道電阻 $\Rightarrow 1/g_{mn} \parallel r_{on}$
* 往上看：PMOS **也**變成 Diode-connected，本身也帶有通道電阻 $\Rightarrow 1/g_{mp} \parallel r_{op}$
* **總等效阻抗：** $\mathbf{1/g_{mn} \parallel 1/g_{mp} \parallel r_{on} \parallel r_{op}}$
* *(因為 $1/g_m$ 通常遠小於 $r_o$，所以實務上近似為 $\frac{1}{g_{mn} + g_{mp}}$。這就是為什麼分母是 $(g_{mn} + g_{mp})^2$)*

---

**面試加分題：這兩個「並聯」告訴了我們什麼設計哲學？**

如果你在 ASMedia 這種做高速 SerDes 的團隊面試，主考官聽你講完這套等效阻抗的理論後，一定會笑著問你最後一個問題：
**「那從雜訊的角度來看，你覺得哪一個架構比較好？為什麼？」**

有了你剛剛總結出來的直覺，你可以秒答：

> 「從 NTF 的物理直覺來看，主動元件的雜訊電流，在輸出端是乘上**『等效阻抗的平方』**。這代表等效阻抗越小，輸出雜訊電壓就越低。
> 
> CMOS 架構因為讓 NMOS 和 PMOS **同時處於 Diode-connected 並聯的狀態**，它的等效導納是 $g_{mn} + g_{mp}$。相較於單端架構只有 $g_{m1}$，CMOS 架構在不增加額外電流消耗 (Current consumption) 的情況下，硬生生把總轉導 ($G_m$) 變大了。
> 
> $G_m$ 變大，代表等效阻抗 ($1/G_m$) 變得更小。所以相同的通道熱雜訊電流，打在這個更小的阻抗上，產生的輸出雜訊電壓就會被有效壓抑。這就是 Inverter-based TIA 在先進製程低電壓下，SNR (訊雜比) 表現通常優於傳統 NMOS 架構的核心原因。」

把這套邏輯順暢地講出來，你就不只是一個會算數學的工程師，而是一個懂架構、懂 Trade-off 的 System Designer。你的觀念已經完全到位了！

### 阻抗 vs 導納：物理語言與設計語言的互換

哈哈，這是一個非常敏銳的「數學與物理語言轉換」的盲點！

你會有這個疑惑，是因為「物理直覺的口訣」跟「寫在紙上的數學公式」在視角上剛好互為倒數。其實我們說的是完完全全同一件事，只是用了「阻抗 (Impedance)」和「導納 (Admittance)」兩種不同的表達方式。

我們來把這層窗戶紙戳破：

**1. 物理直覺視角：看「阻抗 ($R$)」**
在物理直覺上，我們喜歡講「電阻」或「阻抗」，因為比較好想像。
* 雜訊的源頭是一個**電流源** ($\overline{I_n^2}$)。
* 電流打在一個障礙物（阻抗 $R_{eq}$）上，才會轉換成**電壓** ($\overline{V_{n,out}^2}$)。
* 公式：$\overline{V_{n,out}^2} = \overline{I_n^2} \times \mathbf{(R_{eq})^2}$
* **結論：** 障礙物 ($R_{eq}$) 越小，產生的雜訊電壓就越小。所以我們說要「乘上等效阻抗的平方」。

**2. 電路設計視角：看「轉導 ($g_m$)」與「導納 ($G$)」**
然而，身為 IC 設計工程師，你真正在操控的參數是電晶體的 $g_m$（轉導）。
* $g_m$ 的單位是 $A/V$ (Siemens, 導納)，它是**阻抗的倒數**。
* 既然等效阻抗 $R_{eq} = \frac{1}{g_{mn} + g_{mp}}$。
* 那我們把這個 $R_{eq}$ 代回剛剛的物理公式裡：
  $$\overline{V_{n,out}^2} = \overline{I_n^2} \times (R_{eq})^2 = \overline{I_n^2} \times \left( \frac{1}{g_{mn} + g_{mp}} \right)^2 = \mathbf{\frac{\overline{I_n^2}}{(g_{mn} + g_{mp})^2}}$$

**為什麼公式要把參數「弄到分母」？**

因為**數學上除以一個很大的數字，就等於物理上乘上一個很小的阻抗**！

把 $g_m$ 放在分母，對 Designer 來說具有極大的「工程指導意義」：
1. **你看到了你的武器：** 你沒辦法直接買一個叫做「小阻抗」的零件裝上去。你只能透過增加 Bias Current (偏壓電流) 或加大電晶體的 W/L (寬長比) 來**提升 $g_m$**。
2. **你看到了 Trade-off (取捨)：** 看著分母的 $g_m$，你會立刻意識到：「啊！我要壓低雜訊，我就得把分母變大；要把 $g_m$ 變大，我就得燒更多的 Power (電流) 或是佔用更大的 Area (面積)。」
3. **你看到了 CMOS 架構的優勢：** 看著分母的 $(g_{mn} + g_{mp})^2$，你會發現 CMOS TIA 簡直是作弊。它在同一條電流路徑上，同時榨出了 NMOS 和 PMOS 的 $g_m$。也就是說，它在**不增加額外耗電**的情況下，把分母變大了，強行把等效阻抗壓得更低。

**總結來說：**
「乘上等效阻抗的平方」是你用來快速看透電路行為的**內功心法**；
而「把 $g_m$ 寫在分母」是你實際在跑 simulation、調 size 時的**操作面板**。兩者是完美互通的！

**記憶口訣：**
Blackman 算阻抗：「開短比一比，回授壓低它」。
TIA 增益兩路徑：「理想走外圈 ($-R_F$)，死掉走內圈 ($r_{out}$)」。
TIA 輸入阻抗防呆：「$R_F$ 除以 $A$，千萬別只剩 $1/g_m$」。

---