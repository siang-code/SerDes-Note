# LA-L2-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L2-P1.jpg

---


---
## Limiting Amplifier (LA) 級數最佳化與雜訊分析

### 數學推導
1. **頻寬與增益的關係 (Bandwidth & Gain Relationship in Cascade):**
   - 假設每級放大器滿足增益頻寬積為常數：$A_0 \cdot W_0 = \text{GBW} = \text{Constant}$
   - 若串接 $n$ 級放大器，總直流增益為 $A_{tot} = A_0^n = \left(\frac{\text{GBW}}{W_0}\right)^n$
   - 串聯後的總頻寬公式為：$W_{3dB(tot)} = W_0 \sqrt{2^{1/n} - 1}$
   - 將 $W_0 = \frac{\text{GBW}}{A_{tot}^{1/n}}$ 代入總頻寬公式，得到：
     $$W_{3dB(tot)} = \frac{\text{GBW}}{A_{tot}^{1/n}} \sqrt{2^{1/n} - 1} \approx \frac{\text{GBW} \cdot 0.9}{\sqrt{n} \cdot A_{tot}^{1/n}}$$
     *(註：其中利用泰勒展開 $\sqrt{2^{1/n} - 1} \approx \sqrt{\frac{\ln 2}{n}} \approx \frac{0.83}{\sqrt{n}}$ 近似)*
   - 為了找出最大化總頻寬的最佳級數 $n_{opt}$，我們令微分 $\frac{\partial W_{3dB(tot)}}{\partial n} = 0$，可以推導出 $n_{opt} = 2 \ln(A_{tot})$。
   - 舉例：若規格要求總增益 $A_{tot} = 40\text{dB} = 100$ (V/V)，則 $n_{opt} = 2 \ln(100) \approx 9.2 \Rightarrow$ 理論最佳為 9 級。

2. **級數在實務上的限制 (Practical Limits of Stage Number):**
   - 雖然數學上 $n=9$ 可得最大頻寬，但這其實是「過度簡化的小訊號模型」。實務上，只有前面的 1~2 級訊號夠小，具備線性小訊號行為。
   - 後面的級數訊號已經被放大拉開，受限於電路的 Voltage Headroom (最大電壓差就是 $I \times R$)，訊號會被截波 (Clipping) 進入非線性區，導致後段級數的實際增益小得多。
   - 此外，級數越多，整體功耗越大，且整體 Input-referred noise 會變差。因此實務上通常限制級數 $n \le 5$，以平衡雜訊、功耗與頻寬。

3. **串接放大器的雜訊貢獻 (Noise Contribution):**
   - 每級放大器輸出的雜訊電壓平方（DC 值）：$\overline{V_{n,out}^2} = 2R_D^2 (\overline{I_{n,M1}^2} + \overline{I_{n,RD}^2}) \cdot BW_n$
   - 將後級雜訊等效回輸入端 (Input-referred) 時，必須除以前面所有級數的增益平方。
   - 假設每級增益 $A_0 = 10\text{dB}$ (功率/增益平方倍數為 10 倍)。則第 2 級貢獻到輸入端的雜訊只有第 1 級的 $1/10$；第 3 級只有 $1/100$。
   - **結論**：只有最前面的 1~2 級是主要的雜訊貢獻者 (noise contributors)。

4. **Tapered LA 頻寬最佳化推導 (Optimization of Cascade Stages):**
   - 考慮兩級 Tapered (漸變) 放大器，試圖決定參數 $\alpha$ 以最大化給定 $A_{tot}$ 下的總頻寬。
   - 假設第一級：增益 $A_0$、頻寬 $W_0$；第二級：增益 $A_0/\alpha$、頻寬 $\alpha W_0$。
   - 總增益為常數：$A_0 \cdot \frac{A_0}{\alpha} = A_{tot} \Rightarrow A_0 = \sqrt{\alpha A_{tot}}$
   - 系統轉移函數：$H(s) = \left( \frac{A_0}{1 + s/W_0} \right) \cdot \left( \frac{A_0/\alpha}{1 + s/(\alpha W_0)} \right)$
   - 令振幅平方在總頻寬 $W$ 處下降一半：
     $$|H(jW)|^2 = \frac{A_{tot}^2}{(1 + \frac{W^2}{W_0^2})(1 + \frac{W^2}{\alpha^2 W_0^2})} = \frac{A_{tot}^2}{2}$$
     $$\Rightarrow (1 + \frac{W^2}{W_0^2})(1 + \frac{W^2}{\alpha^2 W_0^2}) = 2$$
   - 展開後，對 $W$ 求 $\alpha$ 的偏微分 $\frac{\partial W}{\partial \alpha} = 0$，可以解出 $\alpha = 1$。
   - **結論**：在給定總增益與 GBW 的前提下，串接的每一級應具備**相等的增益與頻寬 (Equal gain & bandwidth)**，才是最佳化整體頻寬的唯一解。

### 單位解析
**公式單位消去：**
1. $\text{GBW} = A_0 \cdot W_0$
   - $A_0$ [V/V] (無因次)
   - $W_0$ [rad/s] 或 [Hz]
   - $\text{GBW} = [V/V] \times [\text{Hz}] = [\text{Hz}]$ (增益頻寬積，單位為頻率)
2. $\overline{V_{n,out}^2} = 2R_D^2 (\overline{I_{n,M1}^2} + \overline{I_{n,RD}^2}) \cdot BW_n$
   - $R_D$ [$\Omega$] = [V/A]
   - $\overline{I_n^2}$ (電流雜訊功率譜密度 PSD) [A$^2$/Hz]
   - $BW_n$ (等效雜訊頻寬) [Hz]
   - $R_D^2 \times \overline{I_n^2} \times BW_n = [\Omega^2] \times [\text{A}^2/\text{Hz}] \times [\text{Hz}] = [\text{V}^2/\text{A}^2] \times [\text{A}^2] = [\text{V}^2]$ (電壓平方，即雜訊功率)

**圖表單位推斷：**
📈 圖表單位推斷：
1. **$W_{3dB(tot)}$ vs. $n$ 關係圖 (左上角)**
   - X 軸：串接級數 $n$ [無單位]，典型範圍 1~15 (實體為離散整數，畫成連續曲線僅為顯示極值趨勢)
   - Y 軸：總頻寬 $W_{3dB(tot)}$ [GHz]，典型範圍根據不同製程通常落在數 GHz 到數十 GHz
   - 意義：總頻寬在 $n=n_{opt}$ 時達到最高點，無止盡地增加級數反而會讓頻寬退化。

### 白話物理意義
雖然數學算出串聯很多級放大器可以榨出最大頻寬，但現實中電晶體電壓空間有限，後面的級數會因為訊號太大而失去放大能力（Clipping），徒增耗電與雜訊；此外，數學證明「每一級的增益與頻寬都設計得一模一樣」就是串接系統頻寬最大的最佳解。

### 生活化比喻
這就像工廠的「輸送帶傳遞接力」：
1. **為什麼不能接力太多次（限制 $n \le 5$）？** 因為傳到最後幾站時，貨物體積已經太大了（訊號放大），機台裝不下（Voltage Headroom 限制 / Clipping），多加的機台不但沒效率，還白白浪費電（Power）且增加出錯率（Noise）。
2. **第一級最重要（雜訊貢獻）：** 第一個工人的手夠不夠乾淨決定了整個產品的底子。如果第一關就沾滿灰塵（第一級 Noise），後面的工人只會把灰塵跟產品一起放大。
3. **為什麼每個人分配的工作要一樣（$\alpha=1$）？** 如果你讓其中一個工人負責做超級多、另一個只負責做一點點，整體輸送帶的流暢度（頻寬）反而比「兩個人平分工作量」還要慢。

### 面試必考點
1. **問題：在設計 Limiting Amplifier 時，若公式算出的最佳級數為 9 級，實務上為何不會採用？** 
   → **答案：** 小訊號推導過度簡化。實務上只有前 1~2 級處於小訊號區。級數過多會導致後段訊號振幅過大受限於 Voltage Headroom ($I \times R$) 而進入非線性區 (Clipping)，增益大幅下降。同時，過多級數會增加功耗並惡化 Input-Referred Noise，故一般限制 $n \le 5$。
2. **問題：在多級串接放大器中，哪一級的雜訊對系統影響最大？該如何降低其影響？** 
   → **答案：** 最前面第一級。根據輸入參考雜訊計算（或 Friis 公式），後級的雜訊會被前面級數的「增益平方」除掉。因此只要第一級增益足夠且本身雜訊極低，後續級數的雜訊影響就可忽略。通常會給第一級分配較多電流以壓低雜訊。
3. **問題：若要設計兩級串接來達到特定增益，如何分配兩級的 Gain 和 Bandwidth 才能獲得最大總頻寬？** 
   → **答案：** 兩級必須設計成「Equal gain & equal bandwidth」。數學上透過轉移函數對比例因子求極值可知，當 $\alpha = 1$ 時（即完全 identical 的級別），整體的串聯頻寬最寬，不需要設計成 Tapered（漸變式）比例。

**記憶口訣：**
LA 級數不過五（五級以內防失真），雜訊全看第一級（前級擋掉後級噪），增益平分頻寬大（一視同仁最優化）。
