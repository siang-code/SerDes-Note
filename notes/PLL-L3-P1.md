# PLL-L3-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L3-P1.jpg

---

身為曾受過李致毅老師嚴格訓練的助教，我必須說，你這張筆記精準抓到了 **Type-I Simple PLL 的暫態響應 (Transient Response)** 核心。筆記中清楚對比了 **Phase Step (相位步階)** 與 **Frequency Step (頻率步階)** 在系統內部節點 ($V_{PD}$, $V_{ctrl}$, $\omega_{out}$) 的連鎖反應。特別是你標註的「相位是頻率的積分」以及「相位沒有一個絕對值」，這正是很多新手過不去的物理觀念檻！

在先進製程（如 28nm 以下）或成熟製程（0.18µm）中，由於 Supply Voltage 下降，$V_{ctrl}$ 的操作範圍 (Headroom) 被嚴重壓縮，理解這張圖裡 $V_{ctrl}$ 的動態變化，是決定 VCO 能否不掉出 tuning range 的關鍵。

以下為你拆解這張筆記的精華與面試防禦對策：

---
## Simple PLL 暫態響應：Phase Step 與 Frequency Step 動態分析

### 數學推導
筆記中紅字強調了「**相位是頻率的積分**」，我們用拉普拉斯轉換 (Laplace Transform) 與時域來嚴格證明圖中 $V_{ctrl}$ 的軌跡。

1. **基礎定義與模型：**
   - 頻率與相位的微積分關係：$\omega(t) = \frac{d\phi(t)}{dt} \implies \phi(t) = \int_{0}^{t} \omega(\tau) d\tau$
   - 轉到 s-domain：$\Phi(s) = \frac{\Omega(s)}{s}$
   - VCO 的特性方程式：$\omega_{out}(t) = \omega_{FR} + K_{VCO} \cdot V_{ctrl}(t)$ （$\omega_{FR}$ 為自由震盪頻率）
   - 將 VCO 寫成相位轉移函數：$\Phi_{out}(s) = \frac{K_{VCO} \cdot V_{ctrl}(s)}{s}$

2. **Case 1: Phase Step (上半部圖) 的 Vctrl 軌跡證明：**
   - 假設輸入發生相位突變 $\Delta\phi_0$：$\phi_{in}(t) = \Delta\phi_0 \cdot u(t)$
   - PLL 鎖定後，最終輸出相位必定追上輸入（$\phi_{out} \to \phi_{in}$）。
   - 從時域看：$\Delta\phi_0 = \int_{0}^{\infty} \Delta\omega_{out}(t) dt = K_{VCO} \int_{0}^{\infty} \Delta V_{ctrl}(t) dt$
   - **推導結論：** 這完美解釋了你筆記中間畫的「紅色陰影面積」。因為頻率 $\omega_{out}$ 必須「凸起」一段時間來累積額外的相位。一旦相位追上（積分面積等於 $\Delta\phi_0$），頻率必須回到原值，因此 **$V_{ctrl}$ 最終會回到原本的電壓準位**。

3. **Case 2: Frequency Step (下半部圖) 的 Vctrl 軌跡證明：**
   - 假設輸入發生頻率突變 $\Delta\omega$：$\omega_{in}(t) = \omega_{orig} + \Delta\omega \implies \phi_{in}(t) = \Delta\omega \cdot t$ (相位變成一個斜坡)。
   - 為了讓 PLL 重新鎖定，VCO 的最終頻率必須等於新的輸入頻率：$\omega_{out}(\infty) = \omega_{in}(\infty)$。
   - 根據 VCO 公式：$\omega_{orig} + \Delta\omega_{out} = \omega_{FR} + K_{VCO}(V_{ctrl\_old} + \Delta V_{ctrl})$
   - **推導結論：** $\Delta V_{ctrl} = \frac{\Delta\omega}{K_{VCO}}$。為了維持新的、更高的頻率，**$V_{ctrl}$ 必須停留在一個新的、較高的穩定值 (Stabilized again)**，這就是你筆記下半段 $V_{ctrl}$ 呈現 Step 爬升的數學真相。同時，這在 Type-I PLL 會產生無法消除的 Static Phase Error。

### 單位解析
**【公式單位消去法】：**
我們來檢驗 VCO 積分特性的閉環單位是否吻合：
* 公式：$\phi_{out}(t) = \int K_{VCO} \cdot V_{ctrl}(t) dt$
* $V_{ctrl}(t)$ 單位：$[V]$ (伏特)
* $K_{VCO}$ 單位：$[rad \cdot s^{-1} \cdot V^{-1}]$ 或 $[Hz/V] \times 2\pi$
* 積分 $dt$ 單位：$[s]$ (秒)
* **消去過程：** $[rad \cdot s^{-1} \cdot V^{-1}] \times [V] \times [s] = [rad]$
* **結果：** 完美得到相位單位 $[rad]$。這印證了你右下角寫的「相位沒有絕對值」，它只是頻率隨時間累積的相對差異量！

**【圖表隱藏單位推斷】：**
這是一張時域暫態波形圖，雖然你手繪沒標單位，但面試官若問起，你必須秒答典型數值：
* **X 軸 (時間 $t$)：** $[ns]$ 或 $[\mu s]$。若以 PCIe Gen3 (100MHz 參考時脈，週期 10ns) 為例，PLL 迴路頻寬若設計在 1MHz，整個 Lock Time 大約需要 $1 \mu s \sim 3 \mu s$。
* **Y 軸 (Ckin/Ckout/VPD)：** 邏輯電壓 $[V]$。在 0.18µm 通常是 $0 \sim 1.8V$，在 28nm 通常是 $0 \sim 0.9V$。
* **Y 軸 (Vctrl)：** 類比控制電壓 $[V]$。通常會設計在 VDD/2 附近取得最佳 VCO 線性度，例如 0.45V (0.9V VDD下)，突波 (Bump) 大小約數十到數百 $mV$。
* **Y 軸 ($\phi_{in}$)：** 相位 $[UI]$ (Unit Interval) 或 $[rad]$。Phase step 通常討論 $0.1 \sim 0.5 UI$ 的跳變。

### 白話物理意義
PLL 就像是「頻率與相位的自動追蹤導彈」；Phase Step 是目標瞬間瞬移了一小段但速度不變（需要加速衝刺追上然後恢復原速），而 Frequency Step 是目標直接加速逃跑（必須永久踩下油門維持新速度）。

### 生活化比喻
想像你在跑步機上跑步，你（VCO）要和跑步機履帶（Ckin）保持相對靜止。
- **Phase Step：** 有人突然把你往前推了一把（相位偏移）。為了不跌倒，你會瞬間減速（Vctrl 往下掉），等履帶把你帶回原來的相對位置後，你再**恢復原本的步頻**繼續跑。
- **Frequency Step：** 有人直接把跑步機的速度調快。你必須立刻加速（Vctrl 爬升），並且**永遠保持在這個更快的新步頻**上，才能繼續留在跑步機上。

### 面試必考點
1. **問題：在 Type-I (Simple) PLL 中輸入 Frequency Step，鎖定後的 Phase Error 會是 0 嗎？**
   → 答案：不會是 0。因為 VCO 需要一個新的、不同的 $V_{ctrl}$ 來維持新頻率。在 Type-I PLL 中，$V_{ctrl}$ 是由 Phase Detector 經過 LPF 產生的，必須要有一個「恆定的相位差 (Static Phase Error)」來產生對應的直流電壓提供給 VCO。
2. **問題：如果今天是一顆 Type-II PLL (含有 Charge Pump 和 Loop Filter 的電容積分路徑)，Frequency Step 下的 Vctrl 穩態圖會長得跟這張筆記一樣嗎？**
   → 答案：$V_{ctrl}$ 一樣會停在新的較高準位，**但是** Type-II PLL 會把 Steady-state phase error 逼近於 0。因為 Loop filter 裡的電容（積分器）會記住這個所需的控制電壓，不需要依靠 PD 持續輸出相位差來維持 $V_{ctrl}$。
3. **問題：你圖中 Phase Step 的 Vctrl 凸起面積，跟設計上的哪個參數有關？**
   → 答案：面積 $\int \Delta V_{ctrl} dt$ 直接正比於 Phase Step 的大小 $\Delta\phi$，反比於 $K_{VCO}$。這在 SerDes CDR (Clock and Data Recovery) 設計中極度重要，若 $K_{VCO}$ 太小，Vctrl 就必須凸得非常高，可能會撞到 VDD 或 GND 導致飽和 (Loss of Lock)。

**記憶口訣：**
**「相位跳，電壓凸回原點（積分面積還債）；頻率跳，電壓爬升不回頭（油門踩死不放）。」**

---
*(等待觸發費曼測試... 如果你覺得「懂了」，請告訴我，我們來進入反事實攻擊！)*
