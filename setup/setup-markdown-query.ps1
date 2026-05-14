# Minimal setup for the markdown-query Skill only.
# Installs `mdq` CLI into a local .venv.
[CmdletBinding()]
param(
    [switch]$CheckOnly,
    [switch]$ForceRecreateVenv,
    [switch]$WithWatch,
    [string]$From
)

$ErrorActionPreference = "Stop"
$script:WarningCount = 0

function Write-Step { param([string]$m) Write-Host "`n==> $m" }
function Write-W    { param([string]$m) $script:WarningCount++; Write-Warning $m }

function Invoke-Checked {
    param([string]$File, [string[]]$Args)
    Write-Host ("> {0} {1}" -f $File, ($Args -join " "))
    & $File @Args
    if ($LASTEXITCODE -ne 0) { throw "Command failed: $File $($Args -join ' ')" }
}
function Invoke-Probe {
    param([string]$File, [string[]]$Args)
    $prev = $ErrorActionPreference
    try { $ErrorActionPreference = "Continue"; & $File @Args *> $null; return $LASTEXITCODE }
    finally { $ErrorActionPreference = $prev }
}

function Get-PyInfo {
    param([string]$Exe, [string[]]$Args = @())
    $code = "import sys; print(sys.executable); print(f'{sys.version_info.major} {sys.version_info.minor}')"
    try {
        $out = & $Exe @Args -c $code 2>$null
        if ($LASTEXITCODE -ne 0 -or $out.Count -lt 2) { return $null }
        $v = ($out[1] -split " ") | ForEach-Object { [int]$_ }
        return [pscustomobject]@{ Exe=$Exe; Args=$Args; Executable=$out[0]; Major=$v[0]; Minor=$v[1] }
    } catch { return $null }
}
function Test-Py311 { param($i) return ($i -and ($i.Major -gt 3 -or ($i.Major -eq 3 -and $i.Minor -ge 11))) }

function Find-Py311 {
    $cands = @()
    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($py) { $cands += [pscustomobject]@{ Exe=$py.Source; Args=@("-3.11") } }
    foreach ($n in @("python","python3")) {
        $c = Get-Command $n -ErrorAction SilentlyContinue
        if ($c) { $cands += [pscustomobject]@{ Exe=$c.Source; Args=@() } }
    }
    foreach ($c in $cands) {
        $i = Get-PyInfo -Exe $c.Exe -Args $c.Args
        if (Test-Py311 $i) { return $i }
    }
    return $null
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Resolve-Path (Join-Path $scriptDir "..")
$venvDir   = Join-Path $repoRoot ".venv"
$venvPy    = Join-Path $venvDir "Scripts\python.exe"

Set-Location $repoRoot

Write-Step "Checking Python 3.11+"
$py = Find-Py311
if ($py) {
    Write-Host ("Python: {0} ({1}.{2})" -f $py.Executable, $py.Major, $py.Minor)
} else {
    Write-W "Python 3.11+ not found. Install it and rerun."
    if (-not $CheckOnly) { exit 1 }
}

Write-Step "Checking .venv"
if (Test-Path $venvPy) {
    $vi = Get-PyInfo -Exe $venvPy
    if (Test-Py311 $vi) {
        Write-Host "Existing .venv: OK"
    } elseif ($ForceRecreateVenv -and -not $CheckOnly) {
        Write-W ".venv is older than 3.11. Recreating."
        Remove-Item -Recurse -Force $venvDir
    } else {
        Write-W ".venv is older than 3.11. Rerun with -ForceRecreateVenv."
        if (-not $CheckOnly) { exit 1 }
    }
} elseif ($CheckOnly) {
    Write-W ".venv not found. Run without -CheckOnly to create it."
}

if (-not $CheckOnly -and -not (Test-Path $venvPy)) {
    if (-not $py) { throw "Python 3.11+ required." }
    Invoke-Checked -File $py.Exe -Args ($py.Args + @("-m","venv",$venvDir))
}

if ((Test-Path $venvPy) -and -not $CheckOnly) {
    Write-Step "Installing mdq"
    Invoke-Checked -File $venvPy -Args @("-m","pip","install","--upgrade","pip")
    if ($From) {
        Invoke-Checked -File $venvPy -Args @("-m","pip","install","-e",$From)
    } else {
        try {
            Invoke-Checked -File $venvPy -Args @("-m","pip","install","--upgrade","mdq")
        } catch {
            Write-W "Failed to install 'mdq' from PyPI. If not yet published, use: -From C:\path\to\mdq"
        }
    }
    if ($WithWatch) {
        Invoke-Checked -File $venvPy -Args @("-m","pip","install","--upgrade","watchdog")
    }
}

if (Test-Path $venvPy) {
    Write-Step "Verifying mdq"
    if ((Invoke-Probe -File $venvPy -Args @("-m","mdq","--help")) -eq 0) {
        Write-Host "mdq --help: OK"
    } else {
        Write-W "'python -m mdq --help' failed. mdq is not installed."
    }
    if ($WithWatch) {
        if ((Invoke-Probe -File $venvPy -Args @("-c","import watchdog")) -eq 0) {
            Write-Host "watchdog: OK"
        } else {
            Write-W "watchdog not importable."
        }
    }
}

Write-Step "Next steps"
if (Test-Path $venvPy) {
    Write-Host "  $venvPy -m mdq index"
    Write-Host "  $venvPy -m mdq stats"
    Write-Host "  $venvPy -m mdq search --q `"your query`" --top-k 5"
} else {
    Write-Host "Create .venv first (rerun without -CheckOnly)."
}

Write-Host ("`nCompleted with {0} warning(s)." -f $script:WarningCount)
