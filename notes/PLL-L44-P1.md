# PLL-L44-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L44-P1.jpg

---


---
## All Digital PLLs (ADPLL) 基礎架構與轉換特性

### 數學推導
全數位鎖相迴路 (ADPLL) 將傳統類比元件數位化，其中 TDC (Time-to-Digital Converter) 負責取代傳統的 PFD+CP，將輸入參考時脈與回授時脈的「時間差 / 相位差」轉為「數位碼」。
從右下角的 TDC 轉換特性圖，我們可以推導其時間解析度（Time Resolution）$\Delta T$ 與參考時脈週期 $T$ 的關係：
1. 假設參考時脈週期為 $T \triangleq \frac{1}{f_{ref}}$，其對應的完整相位範圍為 $2\pi$。
2. 觀察 TDC 的階梯圖，在一個 $2\pi$ 的相位範圍內，TDC 的輸出數位碼從 $0$ 變化到 $N_p$（總共 $N_p$ 個量化階梯）。
3. 每一個數位碼階梯（1 LSB）對應的「相位差解析度」為： 
   $$ \Delta \phi_{step} = \frac{2\pi}{N_p} $$
4. 我們將相位差轉換回「時間差」，時間差解析度 $\Delta T$ 佔總週期 $T$ 的比例，必定等於相位差解析度佔完整相位 $2\pi$ 的比例：
   $$ \frac{\Delta T}{T} \cdot 2\pi = \Delta \phi_{step} = \frac{2\pi}{N_p} $$
5. 將方程式兩邊同除以 $2\pi$，移項整理可得核心關係式：
   $$ \frac{\Delta T}{T} = \frac{1}{N_p} \implies \Delta T \cdot N_p = T $$
這在數學上證明了一件事：如果我們希望 TDC 能夠分辨更微小的時間差（即 $\Delta T$ 越小），在固定的參考週期 $T$ 下，量化階數 $N_p$ 就必須大幅增加。這對應了筆記上寫的**「切的越多碎，要花更多功耗」**。

### 單位解析
**公式單位消去：**
針對 TDC 解析度核心公式：$\Delta T \cdot N_p = T$
- $\Delta T$：TDC 的時間解析度，單位為秒 [s]
- $N_p$：一個週期內的總量化階數，為數位計數，單位為 [Steps/Period] 或可視為純量 [無單位]
- $T$：參考時脈週期，單位為秒 [s]
單位消去推導：$[s] \times [無單位] = [s]$，左右兩邊皆為時間單位，物理意義成立。

**圖表單位推斷：**
📈 **圖表單位推斷 1：DCO 轉換特性圖 (右上)**
- **X 軸**：數位控制碼 $N_{ctrl}$ [LSB] 或 [Code]，典型範圍依 DCO 解析度而定（例如 10-bit DCO 為 0~1023）。
- **Y 軸**：振盪角頻率 $\omega_{DCO}$ [rad/s] 或 $f_{DCO}$ [Hz]，典型範圍為數 GHz（例如 5GHz ~ 6GHz）。
- **物理意義**：這是一個階梯狀函數，其總體斜率為 $K_{DCO}$ [Hz/LSB]，代表數位濾波器每改變一個 LSB 的輸出，DCO 的頻率會跳動多少 Hz。

📈 **圖表單位推斷 2：TDC 轉換特性圖 (右下)**
- **X 軸**：輸入相位差 $\Delta \phi$ [rad]，典型範圍 $-2\pi \sim 2\pi$（對應時間差 $-T \sim T$）。
- **Y 軸**：TDC 數位輸出碼 $N$ [LSB]，典型範圍 $-N_p \sim N_p$。
- **物理意義**：TDC 是一個量化器 (Quantizer)，將連續的相位差轉為離散的數位碼，其等效增益 $K_{TDC} \approx \frac{N_p}{2\pi}$ [LSB/rad]。

### 白話物理意義
ADPLL 就是把傳統 PLL 裡的「類比水龍頭（Charge Pump + 濾波電容）」換成「數位處理器（TDC + 數位濾波器）」。因為先進製程（如 5nm/3nm）的電壓太低，類比水龍頭很難微調；換成全數位的架構後，不僅體積能隨著製程大幅縮小，還能與電腦晶片（SoC）完美整合。

### 生活化比喻
想像你要控制車速（鎖相頻率）：
- **Analog PLL（類比）** 就像你踩著「無段變速」的油門，油門踩深淺對應電壓高低。但在先進製程下，油門踏板的總深度變得很淺（VDD 變小），你的腳稍微發抖（雜訊），車速就會跟著飄。
- **Digital PLL（數位）** 就像你把油門改成「鍵盤上的數字鍵 0~9」（DCO）。你用一個極度精準的「數位碼表」（TDC）算出你與前車的時間差，交給「行車電腦」（Digital Filter）去計算要按哪個數字鍵。碼表能算到奈秒還是皮秒（$\Delta T$），決定了車子開得有多平穩，但越精準的碼表造價越高、越耗電。

### 面試必考點
1. **問題：為什麼在先進製程（Advanced Tech Nodes）要將 Analog PLL 轉向 All-Digital PLL (ADPLL)？**
   → 答案：(1) **Scaling**：先進製程電源電壓 (VDD) 降低，類比電路 Voltage Headroom 嚴重不足，但數位電路卻能享受面積縮小與功耗降低的紅利。(2) **Integration**：ADPLL 大部分是數位邏輯，使用標準元件庫 (Standard Cell) 即可合成，極易與龐大的 Digital SoC 整合，且不受漏電 (Leakage) 與 PVT 變異的嚴重影響。
2. **問題：請說明 ADPLL 與傳統 Analog PLL 在方塊圖 (Block Diagram) 上的三大對應關係。**
   → 答案：
   - **Phase Frequency Detector (PFD) + Charge Pump (CP)** $\implies$ **Time-to-Digital Converter (TDC)**
   - **Analog Low-Pass Filter (LPF)** $\implies$ **Digital Filter (通常是 PI Controller)**
   - **Voltage-Controlled Oscillator (VCO)** $\implies$ **Digitally Controlled Oscillator (DCO)**
3. **問題：TDC 的核心 Trade-off 是什麼？為什麼筆記提到 ADPLL "Perfectly suitable for fractional-N"？**
   → 答案：TDC 的 Trade-off 是**「時間解析度 ($\Delta T$) vs. 功耗面積」**。為了降低量化雜訊 (Quantization Noise)，需要極小的 $\Delta T$（切得很碎），這會導致 TDC 級數暴增、功耗巨大。而 ADPLL 適合小數分頻 (Fractional-N)，是因為它可以在數位域輕鬆實作高階 Sigma-Delta Modulator ($\Sigma-\Delta$ Mod) 來進行雜訊整形 (Noise Shaping) 處理量化誤差，且不會像類比 Fractional-N PLL 那樣面臨 Charge Pump 非線性造成的折疊雜訊 (Noise Folding) 問題。

**記憶口訣：**
**「先進愛數位，TDC量時間，DCO調頻率，切越碎越噴電，小數分頻最速配。」**
