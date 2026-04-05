# 從 MD 重新解析並產生 HTML（不重新跑 Gemini）
param([string]$NoteName = "PLL-L1-P1")

$ProjectRoot  = $PSScriptRoot
$TemplatePath = Join-Path $ProjectRoot "notes\template.html"
$MdPath       = Join-Path $ProjectRoot "notes\$NoteName.md"
$HtmlPath     = Join-Path $ProjectRoot "notes\$NoteName.html"

if (-not (Test-Path $MdPath)) { Write-Error "找不到：$MdPath"; exit 1 }

$mdContent = [System.IO.File]::ReadAllText($MdPath, [System.Text.Encoding]::UTF8)

function Get-Section($text, $heading) {
    $m = [regex]::Match($text, "### $heading\s*\r?\n([\s\S]*?)(?=\r?\n### |\r?\n## |\*\*記憶|\z)")
    if ($m.Success) { return $m.Groups[1].Value.Trim() } else { return "" }
}

function Get-QuizItems($text) {
    $items = [System.Collections.Generic.List[hashtable]]::new()
    $blocks = [regex]::Matches($text, '(?ms)^\d+\.\s+\*\*(.+?)\*\*\s*\r?\n([\s\S]*?)(?=^\d+\.|\*\*記憶|\z)')
    foreach ($b in $blocks) {
        $q = $b.Groups[1].Value -replace '^問題[：:]?\s*', ''
        $aMatch = [regex]::Match($b.Groups[2].Value, '答案[：:]\s*([\s\S]+)')
        $a = if ($aMatch.Success) { $aMatch.Groups[1].Value.Trim() -replace '\*\*$','' } else { $b.Groups[2].Value.Trim() }
        $items.Add(@{ question = $q.Trim(); answer = $a.Trim() })
    }
    return $items
}

# Intro (## heading + body before first ###)
$h2Match    = [regex]::Match($mdContent, '(?m)## ([^\r\n]+)\r?\n([\s\S]*?)(?=\r?\n### |\z)')
$introTitle = if ($h2Match.Success) { $h2Match.Groups[1].Value.Trim() } else { "" }
$introBody  = if ($h2Match.Success) { $h2Match.Groups[2].Value.Trim() } else { "" }
$intro      = if ($introBody) { "$introTitle`n`n$introBody" } else { $introTitle }

# 記憶口訣
$mnMatch    = [regex]::Match($mdContent, '\*\*記憶口訣[：:]\*\*\s*\r?\n([\s\S]+?)(?=(\r?\n){1,3}---|\s*\r?\n### |\z)')
$mnemonic   = if ($mnMatch.Success) { $mnMatch.Groups[1].Value.Trim() } else { "" }

# 問題延伸
$qaItems   = [System.Collections.Generic.List[hashtable]]::new()
$qaMatches = [regex]::Matches($mdContent, '(?ms)#### Q：(.+?)\r?\n([\s\S]*?)(?=#### Q：|\z)')
foreach ($m in $qaMatches) {
    $qaItems.Add(@{ question = $m.Groups[1].Value.Trim(); answer = $m.Groups[2].Value.Trim() })
}

# 從 MD header 抓日期
$dateMatch = [regex]::Match($mdContent, '分析日期：(\d{4}-\d{2}-\d{2})')
$noteDate  = if ($dateMatch.Success) { $dateMatch.Groups[1].Value } else { (Get-Date -Format 'yyyy-MM-dd') }

# 已知 section 名稱對應 type
$knownTypes = @{
    '數學推導'     = 'math'
    '單位解析'     = 'units'
    '白話物理意義' = 'plain'
    '生活化比喻'   = 'analogy'
    '面試必考點'   = 'quiz'
}

# 自動抓所有 ### sections（排除「問題延伸」）
$allSections = [regex]::Matches($mdContent, "### ([^\r\n]+)\s*\r?\n([\s\S]*?)(?=\r?\n### |\r?\n## |\*\*記憶|\z)")
$sections = @( @{ type="intro"; content=$intro } )

foreach ($sec in $allSections) {
    $secTitle   = $sec.Groups[1].Value.Trim()
    $secContent = $sec.Groups[2].Value.Trim()
    if ($secTitle -eq '問題延伸') { continue }  # Q&A 另外處理

    $secType = if ($knownTypes.ContainsKey($secTitle)) { $knownTypes[$secTitle] } else { 'math' }

    if ($secType -eq 'quiz') {
        $quizItems = Get-QuizItems $secContent
        $sections += @{ type="quiz"; title=$secTitle; items=@($quizItems) }
    } else {
        $sections += @{ type=$secType; title=$secTitle; content=$secContent }
    }
}

# 口訣
if ($mnemonic) {
    $sections += @{ type="mnemonic"; content=$mnemonic }
}
# Q&A
if ($qaItems.Count -gt 0) {
    $sections += @{ type="qa"; title="問題延伸"; items=@($qaItems) }
}

$noteData = @{
    title    = $NoteName
    date     = $noteDate
    imageUrl = "../images/done/$NoteName.jpg"
    sections = $sections
}

$noteDataJson    = $noteData | ConvertTo-Json -Depth 8 -Compress
$templateContent = [System.IO.File]::ReadAllText($TemplatePath, [System.Text.Encoding]::UTF8)
$htmlContent     = $templateContent.Replace('/*INJECT_NOTE_DATA*/', "const NOTE_DATA = $noteDataJson;")
$utf8            = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($HtmlPath, $htmlContent, $utf8)
Write-Host "完成：notes\$NoteName.html" -ForegroundColor Green
