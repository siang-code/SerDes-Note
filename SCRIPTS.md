# SerDes 筆記自動化指令速查

## 主流程 process_note.ps1

| 指令 | 說明 |
|------|------|
| `.\process_note.ps1 L1.jpg` | 單張 → MD + HTML + Notion + Google Drive + GitHub |
| `.\process_note.ps1 -All` | 批次跑 images\ 全部（跳過已處理） |
| `.\process_note.ps1 -All -Force` | 批次強制重跑全部（覆蓋已存在） |
| `.\process_note.ps1 -Private` | 批次跑 images\private\ 全部（自動 Local 模式） |
| `.\process_note.ps1 IMG.jpg -Local` | 單張私密（只存本機，不上傳任何地方） |

### Flags 規格

| Flag | 說明 |
|------|------|
| `-All` | 掃 `images\`，不含 `images\private\` |
| `-Private` | 掃 `images\private\`，自動套用 `-Local` |
| `-Force` | 強制重新處理，覆蓋已存在的 MD / HTML |
| `-Local` | 跳過 Google Drive、Notion、GitHub push，只存本機 |

### -Local 模式跳過項目

- Google Drive 同步
- Notion 上傳
- GitHub push
- 仍會產生：MD、HTML、開啟瀏覽器預覽、更新 index.html

## 補充工具

| 指令 | 說明 |
|------|------|
| `.\regen_html.ps1 -NoteName PLL-L1-P1` | 從 MD 重新產 HTML（不重跑 Gemini） |
| `.\build_index.ps1` | 掃描 notes/*.md → 重建 index.html 首頁 |
| `.\ask_note.ps1 -Note "PLL-L1-P1" -Question "問題"` | Gemini 回答 → Append MD → 重產 HTML → 同步 Notion |
| `.\export_pdf.ps1 -NoteName PLL-L1-P1` | 單筆 → PDF（圖片 + MD，存至 pdf\） |
| `.\export_pdf.ps1 -All` | 全部筆記 → PDF |

## 輸出位置

| 類型 | 路徑 |
|------|------|
| 一般圖片 | `images\` |
| 私密圖片 | `images\private\` |
| Markdown | `notes\*.md` |
| HTML 筆記 | `notes\*.html` |
| 首頁 | `index.html` |
| PDF（供 NotebookLM） | `pdf\` |
| Google Drive | `G:\我的雲端硬碟\SerDes筆記\` |

## 命名規則

```
課程筆記：{科目}-L{堂}-P{頁}.jpg
例：PLL-L1-P1、TIA-L3-P2、EQ-L2-P1

自製投影片：{主題}-P{流水號}.jpg（Gemini 自動命名）
例：55nm-Vth-vs-Length-P1
```

## NotebookLM 匯入

1. 跑 `.\export_pdf.ps1 -All`
2. NotebookLM → 新增來源 → 電腦 → 選 `pdf\*.pdf`
