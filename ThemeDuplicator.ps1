# =========================
# Qlik TLP Theme Generator - Single Source, 5 Variants
# Uses master files from source folder (theme.css, theme.json, wl-tlp-red-v2.qext, fonts/)
# Only swaps: label in CSS, gradient color in JSON, name in QEXT
# =========================

# ---- CONFIG ----
$masterRoot      = "C:\Users\wlqlikservice.Test\WL_Theme_v2"
$destinationRoot = "\\swlall10\Daten\WLQlik\test\StaticContent\Extensions"
$fallbackRoot    = Join-Path $PSScriptRoot "GeneratedThemes"

$themeDefs = [ordered]@{
    "wl-tlp-red-v2"          = @{ Label = "TLP Red";          Gradient = "#E24848" }
    "wl-tlp-amber-v2"        = @{ Label = "TLP Amber";        Gradient = "#FFBF00" }
    "wl-tlp-clear-v2"        = @{ Label = "TLP Clear";        Gradient = "#232942" }
    "wl-tlp-green-v2"        = @{ Label = "TLP Green";        Gradient = "#00A651" }
    "wl-tlp-amber-strict-v2" = @{ Label = "TLP Amber Strict"; Gradient = "#FF9900" }
}

# Resolve output: try share first, fallback to local
if (Test-Path -LiteralPath $destinationRoot) {
    $outputRoot = $destinationRoot
    Write-Host "Output: $destinationRoot (share)" -ForegroundColor Green
} else {
    $outputRoot = $fallbackRoot
    Write-Host "Share unreachable, using local: $fallbackRoot" -ForegroundColor Yellow
}

# ---- MAIN ----
Write-Host "`n== Qlik TLP Theme Generator ==" -ForegroundColor Cyan
Write-Host "Master source: $masterRoot`n" -ForegroundColor Gray

foreach ($themeName in $themeDefs.Keys) {
    $def = $themeDefs[$themeName]
    Write-Host "=== Building: $themeName ===" -ForegroundColor Cyan

    $themePath = Join-Path $outputRoot $themeName
    if (Test-Path -LiteralPath $themePath) { Remove-Item -LiteralPath $themePath -Recurse -Force }
    New-Item -ItemType Directory -Path $themePath -Force | Out-Null

    # -- Copy master files (fonts) --
    if (Test-Path (Join-Path $masterRoot "fonts")) {
        Copy-Item -Path (Join-Path $masterRoot "fonts") -Destination $themePath -Recurse -Force
        Write-Host "  fonts: copied" -ForegroundColor Green
    }

    # -- Copy and patch CSS (replace label) --
    $masterCss = Join-Path $masterRoot "theme.css"
    if (Test-Path -LiteralPath $masterCss) {
        $css = Get-Content -LiteralPath $masterCss -Raw
        $css = $css -replace 'content:\s*"TLP Red"', "content: `"$($def.Label)`""
        $css | Set-Content -LiteralPath (Join-Path $themePath "theme.css") -Encoding UTF8
        Write-Host "  css:  theme.css (label -> $($def.Label))" -ForegroundColor Green
    } else {
        Write-Host "  css:  master not found" -ForegroundColor Red
    }

    # -- Copy and patch JSON (replace gradient color variable) --
    $masterJson = Join-Path $masterRoot "theme.json"
    if (Test-Path -LiteralPath $masterJson) {
        $json = Get-Content -LiteralPath $masterJson -Raw
        $json = $json -replace '"@ColourWLRedMid"\s*:\s*"#e24848"', "`"@ColourWLRedMid`":`"$($def.Gradient)`""
        $json | Set-Content -LiteralPath (Join-Path $themePath "theme.json") -Encoding UTF8
        Write-Host "  json: theme.json (gradient -> $($def.Gradient))" -ForegroundColor Green
    } else {
        Write-Host "  json: master not found" -ForegroundColor Red
    }

    # -- Create QEXT from master template (replace name) --
    $masterQext = Join-Path $masterRoot "wl-tlp-red-v2.qext"
    if (Test-Path -LiteralPath $masterQext) {
        $qext = Get-Content -LiteralPath $masterQext -Raw
        $qext = $qext -replace '"wl-tlp-red-v2"', "`"$themeName`""
        $qext | Set-Content -LiteralPath (Join-Path $themePath "$themeName.qext") -Encoding UTF8
        Write-Host "  qext: $themeName.qext" -ForegroundColor Green
    } else {
        Write-Host "  qext: master not found" -ForegroundColor Red
    }

    # -- ZIP --
    $zipPath = Join-Path $outputRoot "$themeName.zip"
    if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
    Compress-Archive -Path (Join-Path $themePath '*') -DestinationPath $zipPath -Force
    Write-Host "  zip:  $themeName.zip" -ForegroundColor Green
}

Write-Host "`nDone. 5 themes created in: $outputRoot" -ForegroundColor Cyan
