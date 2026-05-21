# =========================
# Dynamic Qlik Theme Generator & Zipper - AUTO FONT HANDLING
# with robust share->local fallback
# =========================

# ---- CONFIG ----
$sourceFolder    = "C:\Users\wlqlikservice.Test\wl-tlp-red-v2"            # master theme folder (will fallback if missing)
$destinationRoot = "\\swlall10\Daten\WLQlik\test\StaticContent\Extensions" # preferred output (share)
# Use a cross-platform local fallback under the script directory
$fallbackRoot    = Join-Path $PSScriptRoot "GeneratedThemes" # local fallback

# Prefer a local source folder if the configured one does not exist (cross-platform support)
if (-not (Test-Path -LiteralPath $sourceFolder)) {
    $localSource = Join-Path $PSScriptRoot "wl-tlp-red-v2"
    if (Test-Path -LiteralPath $localSource) {
        Write-Host "↪️  Using local source: $localSource" -ForegroundColor Yellow
        $sourceFolder = $localSource
    } else {
        Write-Host "⚠️ Source folder not found: $sourceFolder (no local alternative). Proceeding with minimal files." -ForegroundColor Yellow
    }
}

# Determine central fonts path safely (prefer existing source, otherwise local fonts next to script)
if (Test-Path -LiteralPath $sourceFolder) {
    $centralFontPath = Join-Path $sourceFolder "fonts"
} else {
    $centralFontPath = Join-Path $PSScriptRoot "fonts"
}

$fontFiles = @(
    "4577388c-510f-4366-addb-8b663bcc762a.ttf",
    "aaf11848-aac2-4d09-9a9c-aac5ff7b8ff4.ttf",
    "d1dc54b2-878d-4693-8d6e-b442e99fef68.ttf"
)

$themeDefs = @{
    "wl-tlp-red-v2"          = @{ Label = "TLP:RED";          Gradient = "#E24848" }
    "wl-tlp-amber-v2"        = @{ Label = "TLP:AMBER";        Gradient = "#FFBF00" }
    "wl-tlp-clear-v2"        = @{ Label = "TLP:CLEAR";        Gradient = "#232942 " }
    "wl-tlp-green-v2"        = @{ Label = "TLP:GREEN";        Gradient = "#00A651" }
    "wl-tlp-amber-strict-v2" = @{ Label = "TLP:AMBER STRICT"; Gradient = "#FF9900" }
}

# ---- HELPERS ----
function New-SafeDirectory {
    param([string]$Path)
    try {
        if (-not (Test-Path -LiteralPath $Path)) {
            New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
        }
        return $true
    } catch {
        Write-Host "❌ Failed to create directory: $Path`n   $_" -ForegroundColor Red
        return $false
    }
}

function Copy-FontsToTheme {
    param([string]$ThemeFolder)

    $fontDest = Join-Path $ThemeFolder "fonts"
    if (-not (New-SafeDirectory -Path $fontDest)) { return $false }

    foreach ($font in $fontFiles) {
        $src  = Join-Path $centralFontPath $font
        $dest = Join-Path $fontDest $font

        if (-not (Test-Path -LiteralPath $src)) {
            Write-Host "⚠️ Missing font (source): $src" -ForegroundColor Yellow
            continue
        }

        try {
            Copy-Item -LiteralPath $src -Destination $dest -Force -ErrorAction Stop
            Write-Host "✅ Copied font: $font" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to copy font to $dest`n   $_" -ForegroundColor Red
            return $false
        }
    }
    return $true
}

function Safe-Replace {
    param (
        [string]$FilePath,
        [string]$Pattern,
        [string]$Replacement
    )
    if (Test-Path -LiteralPath $FilePath) {
        try {
            (Get-Content -LiteralPath $FilePath -Raw) -replace $Pattern, $Replacement |
                Set-Content -LiteralPath $FilePath -Encoding UTF8 -ErrorAction Stop
            Write-Host "✅ Updated file: $FilePath" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed updating $FilePath`n   $_" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️ File not found: $FilePath" -ForegroundColor Yellow
    }
}

function Get-OutputThemePath {
    param([string]$ThemeName)

    # try network share
    $shareThemePath = Join-Path $destinationRoot $ThemeName
    if (New-SafeDirectory -Path $destinationRoot -and (New-SafeDirectory -Path $shareThemePath)) {
        return $shareThemePath
    }

    # fallback to local
    Write-Host "↪️  Falling back to local output: $fallbackRoot" -ForegroundColor Yellow
    New-SafeDirectory -Path $fallbackRoot | Out-Null
    $localThemePath = Join-Path $fallbackRoot $ThemeName
    if (New-SafeDirectory -Path $localThemePath) {
        return $localThemePath
    } else {
        throw "Cannot create theme directory in share or fallback location."
    }
}

# ---- PRECHECKS ----
if (Test-Path -LiteralPath $centralFontPath) {
    Write-Host "✅ Default theme fonts folder exists: $centralFontPath" -ForegroundColor Green
} else {
    Write-Host "❌ Fonts folder not found; creating: $centralFontPath" -ForegroundColor Red
    if (-not (New-SafeDirectory -Path $centralFontPath)) { throw "Cannot create central fonts folder." }
}

foreach ($f in $fontFiles) {
    if (Test-Path -LiteralPath (Join-Path $centralFontPath $f)) {
        Write-Host "✅ Found font: $f" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Missing font in default theme: $f" -ForegroundColor Yellow
    }
}

# ---- MAIN ----
foreach ($themeName in $themeDefs.Keys) {
    $def = $themeDefs[$themeName]
    Write-Host "`n=== Building theme: $themeName ===" -ForegroundColor Cyan

    # Resolve output folder (share or fallback)
    $themePath = Get-OutputThemePath -ThemeName $themeName

    # Reset folder contents
    if (Test-Path -LiteralPath $themePath) {
        try { Remove-Item -LiteralPath $themePath -Recurse -Force -ErrorAction Stop } catch {}
        New-SafeDirectory -Path $themePath | Out-Null
    }

    # Copy template (excluding fonts) if source exists; otherwise continue with minimal files
    if (Test-Path -LiteralPath $sourceFolder) {
        try {
            Copy-Item -Path (Join-Path $sourceFolder '*') `
                      -Destination $themePath `
                      -Recurse -Force -ErrorAction Stop `
                      -Exclude @("ThemeDuplicator.ps1", ".git", "fonts")
            Write-Host "📦 Template copied to $themePath" -ForegroundColor Green
        } catch {
            Write-Host "❌ Copy from template failed: $sourceFolder -> $themePath`n   $_" -ForegroundColor Red
            # If this was the share path, try once more into fallback
            if ($themePath -like "$destinationRoot*") {
                $themePath = Get-OutputThemePath -ThemeName $themeName  # will choose fallback if share failed
                try {
                    Copy-Item -Path (Join-Path $sourceFolder '*') -Destination $themePath -Recurse -Force -ErrorAction Stop -Exclude @("ThemeDuplicator.ps1", ".git", "fonts")
                    Write-Host "📦 Template copied to fallback $themePath" -ForegroundColor Green
                } catch {
                    Write-Host "⚠️ Copy still failed; proceeding with minimal theme structure." -ForegroundColor Yellow
                }
            }
        }
    } else {
        Write-Host "⚠️ Source folder not found; creating minimal theme structure." -ForegroundColor Yellow
    }

    # Fonts
    if (-not (Copy-FontsToTheme -ThemeFolder $themePath)) {
        Write-Host "⚠️ Font copy encountered issues for $themeName (continuing)" -ForegroundColor Yellow
    }

    # QEXT: rename or create
    $oldQext = Join-Path $themePath "wl-tlp-red-v2.qext"
    $newQext = Join-Path $themePath "$themeName.qext"
    if (Test-Path -LiteralPath $oldQext) {
        try {
            Rename-Item -LiteralPath $oldQext -NewName (Split-Path $newQext -Leaf) -Force -ErrorAction Stop
        } catch {
            Write-Host "❌ Failed to rename qext; will recreate: $newQext" -ForegroundColor Yellow
            Remove-Item -LiteralPath $oldQext -Force -ErrorAction SilentlyContinue
        }
    }
    if (-not (Test-Path -LiteralPath $newQext)) {
        # minimal valid qext
        $qextObj = [ordered]@{
            name        = $themeName
            type        = "theme"
            author      = "Auto-Generated"
            version     = "1.0.0"
            description = "Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        } | ConvertTo-Json
        $qextObj | Set-Content -LiteralPath $newQext -Encoding UTF8
    } else {
        Safe-Replace -FilePath $newQext -Pattern '"name":\s*".*?"' -Replacement ('"name": "' + $themeName + '"')
    }

    # CSS
    $cssFile = Join-Path $themePath "theme.css"
    if (Test-Path -LiteralPath $cssFile) {
        $pattern     = '(content:\s*")([^"]*?)(";)'
        $replacement = '${1}' + $def.Label + '${3}'
        Safe-Replace -FilePath $cssFile -Pattern $pattern -Replacement $replacement

        @"
/* Theme-specific sheet title background */
.qv-panel-sheet .sheet-title-container {
    background-color: $($def.Gradient) !important;
    background-image: none !important;
}
.qv-panel-sheet .sheet-title-container .sheet-title {
    color: #FFFFFF !important;
    text-shadow: none !important;
}
"@ | Add-Content -LiteralPath $cssFile -Encoding UTF8
        Write-Host "🎨 CSS updated for $themeName" -ForegroundColor Cyan
    } else {
        @"
/* Minimal CSS for theme label and background */
.qv-panel-sheet .sheet-title-container {
    background-color: $($def.Gradient) !important;
    background-image: none !important;
}
.qv-panel-sheet .sheet-title-container .sheet-title {
    color: #FFFFFF !important;
    text-shadow: none !important;
}
.qv-panel-sheet .sheet-title-container .sheet-title::after {
    content: "$($def.Label)";
    margin-left: 8px;
}
"@ | Set-Content -LiteralPath $cssFile -Encoding UTF8
        Write-Host "🆕 Created minimal CSS: $cssFile" -ForegroundColor Green
    }

    # JSON
    $jsonFile = Join-Path $themePath "theme.json"
    if (Test-Path -LiteralPath $jsonFile) {
        try {
            $json = Get-Content -LiteralPath $jsonFile -Raw | ConvertFrom-Json
            foreach ($scope in "private","approved","published") {
                if (-not $json.sheet) { $json | Add-Member -NotePropertyName sheet -NotePropertyValue @{ title = @{} } -Force }
                if (-not $json.sheet.title) { $json.sheet | Add-Member -NotePropertyName title -NotePropertyValue @{} -Force }
                if (-not $json.sheet.title.$scope) { $json.sheet.title | Add-Member -NotePropertyName $scope -NotePropertyValue @{} -Force }
                $json.sheet.title.$scope.titleBackgroundColor         = $def.Gradient
                $json.sheet.title.$scope.titleBackgroundGradientColor = $null
                $json.sheet.title.$scope.titleColor                   = "#FFFFFF"
            }
            $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $jsonFile -Encoding UTF8
            Write-Host "🎨 theme.json updated for $themeName" -ForegroundColor Cyan
        } catch {
            Write-Host "❌ Failed to update theme.json: $jsonFile`n   $_" -ForegroundColor Red
        }
    } else {
        $json = [ordered]@{
            type = "theme"
            sheet = @{ title = @{
                private   = @{ titleBackgroundColor = $def.Gradient; titleBackgroundGradientColor = $null; titleColor = "#FFFFFF" }
                approved  = @{ titleBackgroundColor = $def.Gradient; titleBackgroundGradientColor = $null; titleColor = "#FFFFFF" }
                published = @{ titleBackgroundColor = $def.Gradient; titleBackgroundGradientColor = $null; titleColor = "#FFFFFF" }
            } }
        }
        $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $jsonFile -Encoding UTF8
        Write-Host "🆕 Created minimal theme.json: $jsonFile" -ForegroundColor Green
    }

    # ZIP (next to actual theme folder root)
    $zipRoot = Split-Path $themePath -Parent
    $zipPath = Join-Path $zipRoot "$themeName.zip"
    try {
        if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force -ErrorAction Stop }
        Compress-Archive -Path (Join-Path $themePath '*') -DestinationPath $zipPath -Force -ErrorAction Stop
        Write-Host "✅ Theme '$themeName' packaged at $zipPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to zip theme '$themeName'`n   $_" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Done."
Write-Host "📂 Preferred output root: $destinationRoot"
Write-Host "📂 Fallback output root:  $fallbackRoot"
Write-Host "📂 Fonts source:          $centralFontPath"
