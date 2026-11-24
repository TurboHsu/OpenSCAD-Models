<#
.SYNOPSIS
    Render OpenSCAD models into STL files and PNG preview images (Windows PowerShell).
.EXAMPLE
    .\scripts\render.ps1 sony_xm4_desk_hanger
    .\scripts\render.ps1 -All
    .\scripts\render.ps1 sony_xm4_desk_hanger -StlOnly
    .\scripts\render.ps1 sony_xm4_desk_hanger -PreviewOnly
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Models,
    [switch]$All,
    [switch]$StlOnly,
    [switch]$PreviewOnly,
    [string]$OpenScad
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot

function Load-DotEnv {
    param([string]$EnvPath)
    $map = @{}
    if (-not (Test-Path $EnvPath)) { return $map }
    foreach ($raw in Get-Content $EnvPath -Encoding UTF8) {
        $line = $raw.Trim()
        if (-not $line -or $line.StartsWith("#") -or -not $line.Contains("=")) { continue }
        $idx = $line.IndexOf("=")
        $k = $line.Substring(0, $idx).Trim()
        $v = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
        $map[$k] = $v
    }
    return $map
}

function Find-OpenScad {
    param([string]$Explicit)
    $candidates = @()
    if ($Explicit) { $candidates += $Explicit }
    if ($env:OPENSCAD_CLI) { $candidates += $env:OPENSCAD_CLI }
    if ($env:OPENSCAD) { $candidates += $env:OPENSCAD }

    $dotenv = Load-DotEnv (Join-Path $RepoRoot ".env")
    if ($dotenv.ContainsKey("OPENSCAD_CLI") -and $dotenv["OPENSCAD_CLI"]) {
        $candidates += $dotenv["OPENSCAD_CLI"]
    }
    if ($dotenv.ContainsKey("OPENSCAD") -and $dotenv["OPENSCAD"]) {
        $candidates += $dotenv["OPENSCAD"]
    }

    $candidates += @(
        "C:\Program Files\OpenSCAD\openscad.com",
        "C:\Program Files\OpenSCAD (Nightly)\openscad.com",
        "openscad.com",
        "openscad"
    )

    foreach ($c in $candidates) {
        if (Test-Path $c) { return (Resolve-Path $c).Path }
        $cmd = Get-Command $c -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    throw "OpenSCAD CLI not found. Set OPENSCAD_CLI in .env or pass -OpenScad."
}

function Format-Define {
    param([string]$Key, $Val)
    if ($Val -is [bool]) {
        return "$Key=$($Val.ToString().ToLower())"
    }
    if ($Val -is [int] -or $Val -is [double] -or $Val -is [decimal]) {
        return "$Key=$Val"
    }
    # Windows PowerShell 5.1 strips unescaped quotes when invoking native EXEs;
    # escape them as \" so OpenSCAD receives -D key="value".
    $escaped = ($Val.ToString()).Replace('\', '\\').Replace('"', '\"')
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        return "$Key=\`"$escaped\`""
    }
    return "$Key=`"$escaped`""
}

function Invoke-OpenScad {
    param([string]$Exe, [string[]]$ScadArgs)
    Write-Host "  > $Exe $($ScadArgs -join ' ')"
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $Exe @ScadArgs 2>&1
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prevPref
    }
    foreach ($line in $output) {
        $s = $line.ToString()
        if ($s -match 'Status:|Facets:|Vertices:|WARNING|ERROR') {
            Write-Host "    $s"
        }
    }
    if ($code -ne 0) {
        $output | ForEach-Object { Write-Host $_.ToString() -ForegroundColor Red }
        throw "OpenSCAD exited with code $code"
    }
}

if (-not $All -and (-not $Models -or $Models.Count -eq 0)) {
    throw "Specify one or more model directories, or pass -All."
}
if ($StlOnly -and $PreviewOnly) {
    throw "Cannot combine -StlOnly and -PreviewOnly."
}

$ScadExe = Find-OpenScad -Explicit $OpenScad
Write-Host "Using OpenSCAD: $ScadExe"

$Targets = @()
if ($All) {
    Get-ChildItem $RepoRoot -Directory | Where-Object {
        -not $_.Name.StartsWith(".") -and $_.Name -ne "scripts" -and (Get-ChildItem $_.FullName -Filter "*.scad")
    } | ForEach-Object { $Targets += $_.FullName }
} else {
    foreach ($m in $Models) {
        $p = Join-Path $RepoRoot $m
        if (-not (Test-Path $p -PathType Container)) { throw "Model directory not found: $p" }
        $Targets += $p
    }
}

$DoStl = -not $PreviewOnly
$DoPreview = -not $StlOnly

$DefaultPreviews = @(
    @{ output = "preview/iso.png";   camera = "130,-95,115,0,0,0"; imgsize = "900,700" },
    @{ output = "preview/side.png";  camera = "0,0,200,0,0,0";     projection = "ortho"; imgsize = "900,700" },
    @{ output = "preview/front.png"; camera = "200,0,0,0,0,0";     projection = "ortho"; imgsize = "900,700" }
)

foreach ($dir in $Targets) {
    $name = Split-Path -Leaf $dir
    Write-Host "`n=== $name ==="
    $manifest = Join-Path $dir "render.json"

    if (Test-Path $manifest) {
        $cfg = Get-Content $manifest -Raw -Encoding UTF8 | ConvertFrom-Json
        $defaultScad = $cfg.scad
        $stls = if ($cfg.PSObject.Properties.Name -contains "stls") { $cfg.stls } else { @() }
        $previews = if ($cfg.PSObject.Properties.Name -contains "previews") { $cfg.previews } else { @() }
    } else {
        $scads = @(Get-ChildItem $dir -Filter "*.scad" | Sort-Object Name)
        if ($scads.Count -eq 0) { throw "No .scad files found in $dir" }
        $preferred = Join-Path $dir "$name.scad"
        $defaultScad = if (Test-Path $preferred) { "$name.scad" } else { $scads[0].Name }
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($defaultScad)
        $stls = @([PSCustomObject]@{ output = "stl/$stem.stl" })
        $previews = $DefaultPreviews | ForEach-Object { [PSCustomObject]$_ }
    }

    if ($DoStl) {
        foreach ($item in $stls) {
            $scadName = if ($item.PSObject.Properties.Name -contains "scad" -and $item.scad) { $item.scad } else { $defaultScad }
            $scadPath = Join-Path $dir $scadName
            $outPath = Join-Path $dir $item.output
            $outDir = Split-Path -Parent $outPath
            if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

            $scadArgs = @()
            if ($item.PSObject.Properties.Name -contains "defines" -and $item.defines) {
                foreach ($prop in $item.defines.PSObject.Properties) {
                    $scadArgs += @("-D", (Format-Define $prop.Name $prop.Value))
                }
            }
            $scadArgs += @("-o", $outPath, $scadPath)
            Invoke-OpenScad -Exe $ScadExe -ScadArgs $scadArgs
        }
    }

    if ($DoPreview) {
        foreach ($item in $previews) {
            $scadName = if ($item.PSObject.Properties.Name -contains "scad" -and $item.scad) { $item.scad } else { $defaultScad }
            $scadPath = Join-Path $dir $scadName
            $outPath = Join-Path $dir $item.output
            $outDir = Split-Path -Parent $outPath
            if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

            $imgSize = if ($item.PSObject.Properties.Name -contains "imgsize" -and $item.imgsize) { $item.imgsize } else { "900,700" }
            $scadArgs = @("--autocenter", "--viewall", "--imgsize=$imgSize")
            if ($item.PSObject.Properties.Name -contains "camera" -and $item.camera) {
                $scadArgs += "--camera=$($item.camera)"
            }
            if ($item.PSObject.Properties.Name -contains "projection" -and $item.projection) {
                $scadArgs += "--projection=$($item.projection)"
            }
            if ($item.PSObject.Properties.Name -contains "defines" -and $item.defines) {
                foreach ($prop in $item.defines.PSObject.Properties) {
                    $scadArgs += @("-D", (Format-Define $prop.Name $prop.Value))
                }
            }
            $scadArgs += @("-o", $outPath, $scadPath)
            Invoke-OpenScad -Exe $ScadExe -ScadArgs $scadArgs
        }
    }
}

Write-Host "`nDone."
