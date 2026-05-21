# Define the source folder and destination root paths
$sourceFolder = "C:\Users\wlqlikservice.Test\wl-tlp-red-v2"
$destinationRoots = @(
    "\\swlall10\Daten\WLQlik\test\StaticContent\Extensions"
)

# Define theme names
$themeNames = @{
    "wl-tlp-red-v2" = "TLP:RED"
    "wl-tlp-amber-v2" = "TLP:AMBER"
    "wl-tlp-clear-v2" = "TLP:CLEAR"
    "wl-tlp-green-v2" = "TLP:GREEN"
    "wl-tlp-amber-strict-v2" = "TLP:AMBER STRICT"
}

# Function for safe text replacement in files
function Safe-Replace {
    param (
        [string]$FilePath,
        [string]$Pattern,
        [string]$Replacement
    )
    if (Test-Path $FilePath) {
        (Get-Content $FilePath -Raw) -replace $Pattern, $Replacement | Set-Content $FilePath
        Write-Host "Updated file: $FilePath" -ForegroundColor Green
    } else {
        Write-Host "File not found: $FilePath" -ForegroundColor Yellow
    }
}

# Loop through each destination root
foreach ($destinationRoot in $destinationRoots) {
    Write-Host "Processing destination root: $destinationRoot" -ForegroundColor Cyan

    # Loop through theme names to create folders and update files
    foreach ($newTheme in $themeNames.Keys) {
        $destinationFolder = Join-Path $destinationRoot $newTheme

        # If the destination folder exists, remove all contents to replace them
        if (Test-Path $destinationFolder) {
            Write-Host "Destination folder already exists: $destinationFolder" -ForegroundColor Yellow
            Write-Host "Removing existing contents..." -ForegroundColor Cyan
            Remove-Item -Path $destinationFolder\* -Recurse -Force
        } else {
            Write-Host "Creating destination folder: $destinationFolder" -ForegroundColor Green
            New-Item -Path $destinationFolder -ItemType Directory
        }

        # Copy the source folder contents to the destination
        Copy-Item -Path $sourceFolder\* -Destination $destinationFolder -Recurse -Force -Exclude @("ThemeDuplicator.ps1", ".git")
        Write-Host "Copied files to: $destinationFolder" -ForegroundColor Green

        # Update .qext file
        $qextFile = Join-Path $destinationFolder "wl-tlp-red-v2.qext"
        $newQextFile = Join-Path $destinationFolder "$newTheme.qext"
        if (Test-Path $qextFile) {
            Rename-Item -Path $qextFile -NewName $newQextFile
            $qextNamePattern = '"name":\s*".*?"'
            $qextNameReplacement = '"name": "' + $newTheme + '"'
            Safe-Replace -FilePath $newQextFile -Pattern $qextNamePattern -Replacement $qextNameReplacement
        } else {
            Write-Host "QEXT file not found for theme: $newTheme" -ForegroundColor Yellow
        }

        # Update theme.css file
        $cssFile = Join-Path $destinationFolder "theme.css"
        if (Test-Path $cssFile) {
            $cssContentPattern = '(content:\s*")([^"]*?)(";)' # Match 'content: "..."' in CSS
            $cssContentReplacement = '${1}' + $themeNames[$newTheme] + '${3}'
            Safe-Replace -FilePath $cssFile -Pattern $cssContentPattern -Replacement $cssContentReplacement
        } else {
            Write-Host "CSS file not found for theme: $newTheme" -ForegroundColor Yellow
        }
    }

    Write-Host "Completed processing for destination root: $destinationRoot" -ForegroundColor Green
}

Write-Host "Themes created and updated successfully for all destinations!" -ForegroundColor Green