# SerDes 筆記自動化指令速查

## 主流程

| 指令 | 說明 |
|------|------|
| `.\process_note.ps1 L1.jpg` | 單張圖片 → MD + HTML + Notion + Google Drive |
| `.\process_note.ps1 -All` | 批次跑所有圖片（跳過已處理） |
| `.\process_note.ps1 -Force L1.jpg` | 強制重跑（覆蓋已存在的筆記） |

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
| 原始圖片 | `images\` |
| Markdown | `notes\*.md` |
| HTML 筆記 | `notes\*.html` |
| 首頁 | `index.html` |
| PDF（供 NotebookLM） | `pdf\` |
| Google Drive | `G:\我的雲端硬碟\SerDes筆記\` |

## 命名規則

```
{科目}-L{堂}-P{頁}.jpg
例：PLL-L1-P1、TIA-L3-P2、EQ-L2-P1
```

## NotebookLM 匯入

1. 跑 `.\export_pdf.ps1 -All`
2. NotebookLM → 新增來源 → 電腦 → 選 `pdf\*.pdf`
