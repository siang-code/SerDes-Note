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

$h2Match    = [regex]::Match($mdContent, '(?m)## ([^\r\n]+)\r?\n([\s\S]*?)(?=\r?\n### |\z)')
$introTitle = if ($h2Match.Success) { $h2Match.Groups[1].Value.Trim() } else { "" }
$introBody  = if ($h2Match.Success) { $h2Match.Groups[2].Value.Trim() } else { "" }
$intro      = if ($introBody) { "$introTitle`n`n$introBody" } else { $introTitle }
$mathSec    = Get-Section $mdContent "數學推導"
$unitsSec   = Get-Section $mdContent "單位解析"
$plainSec   = Get-Section $mdContent "白話物理意義"
$analogySec = Get-Section $mdContent "生活化比喻"
$quizText   = Get-Section $mdContent "面試必考點"
$quizItems  = Get-QuizItems $quizText
$mnMatch    = [regex]::Match($mdContent, '\*\*記憶口訣[：:]\*\*\s*\r?\n([\s\S]+?)(?=\r?\n---|\z)')
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

$sections = @(
    @{ type="intro";    content=$intro }
    @{ type="math";     title="數學推導";     content=$mathSec }
    @{ type="units";    title="單位解析";     content=$unitsSec }
    @{ type="plain";    title="白話物理意義"; content=$plainSec }
    @{ type="analogy";  title="生活化比喻";   content=$analogySec }
    @{ type="quiz";     title="面試必考點";   items=@($quizItems) }
    @{ type="mnemonic"; content=$mnemonic }
)
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
