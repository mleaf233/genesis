param(
    [string]$DestinationRoot = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Balatro\Mods')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$CurrentDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $CurrentDir

$Source = Get-Item -LiteralPath $CurrentDir
$SourceName = $Source.Name
$Destination = Join-Path $DestinationRoot $SourceName
$LogFile = Join-Path $CurrentDir 'copy_log.txt'

$ExcludedDirectoryNames = @(
    'Libs',
    'smods',
    'game',
    '.venv',
    '.git',
    '.idea',
    '.agents',
    '.codex'
)

$ExcludedRelativeRoots = @(
    'impl\upstream',
    'impl\backup',
    'impl\todo'
)

$ExcludedFileNames = @(
    'release.ps1',
    'copy_log.txt'
)

function Write-Log {
    param([string]$Message)

    $Time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $Entry = "[$Time] $Message"
    Write-Output $Entry
    $Entry | Out-File -FilePath $LogFile -Append -Encoding utf8
}

function Get-NormalizedRelativePath {
    param(
        [string]$BasePath,
        [string]$FullPath
    )

    $RelativePath = $FullPath.Substring($BasePath.Length).TrimStart([char[]]@('\', '/'))
    return ($RelativePath -replace '/', '\')
}

function Test-IsExcluded {
    param([System.IO.FileSystemInfo]$Item)

    $RelativePath = Get-NormalizedRelativePath -BasePath $Source.FullName -FullPath $Item.FullName

    foreach ($Root in $ExcludedRelativeRoots) {
        if ($RelativePath -ieq $Root -or $RelativePath -ilike ($Root + '\*')) {
            return $true
        }
    }

    foreach ($Segment in ($RelativePath -split '[\\/]')) {
        if ($ExcludedDirectoryNames -icontains $Segment) {
            return $true
        }
    }

    if (-not $Item.PSIsContainer -and $ExcludedFileNames -icontains $Item.Name) {
        return $true
    }

    return $false
}

Write-Log "==== Start copy: $SourceName ===="
Write-Log "Source: $($Source.FullName)"
Write-Log "Destination: $Destination"

try {
    if (-not (Test-Path -LiteralPath $DestinationRoot)) {
        New-Item -ItemType Directory -Path $DestinationRoot | Out-Null
        Write-Log "Created destination root: $DestinationRoot"
    }

    $Items = Get-ChildItem -LiteralPath $Source.FullName -Recurse -Force |
        Where-Object { -not (Test-IsExcluded $_) }

    foreach ($Item in $Items) {
        $TargetPath = $Item.FullName.Replace($Source.FullName, $Destination)

        if ($Item.PSIsContainer) {
            if (-not (Test-Path -LiteralPath $TargetPath)) {
                New-Item -ItemType Directory -Path $TargetPath | Out-Null
            }
            continue
        }

        $TargetDir = Split-Path $TargetPath -Parent
        if (-not (Test-Path -LiteralPath $TargetDir)) {
            New-Item -ItemType Directory -Path $TargetDir | Out-Null
        }

        Copy-Item -LiteralPath $Item.FullName -Destination $TargetPath -Force
    }

    $ExcludedSummary = ($ExcludedDirectoryNames + $ExcludedRelativeRoots + $ExcludedFileNames) -join ', '
    Write-Log "Copy complete. Excluded: $ExcludedSummary"
}
catch {
    Write-Log "Copy failed: $($_.Exception.Message)"
    throw
}
finally {
    Write-Log "Log file: $LogFile"
    Write-Log "=============================="
}
