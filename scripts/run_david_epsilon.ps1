# Runs David's 10 epsilon-schedule experiments sequentially.
# Each CNN run at 500k timesteps takes ~25-35 min on CPU (~4-6 hours total).
# From repo root:  .\scripts\run_david_epsilon.ps1

$ErrorActionPreference = "Stop"
$Python = Join-Path $PSScriptRoot "..\.venv\Scripts\python.exe"
if (-not (Test-Path $Python)) {
    Write-Error "Missing .venv. Create it first: python -m venv .venv; .\.venv\Scripts\pip install -r requirements.txt"
}

$Base = @(
    $Python, "train.py",
    "--env", "ALE/Pong-v5",
    "--policy", "cnn",
    "--member", "david",
    "--lr", "0.0001",
    "--gamma", "0.99",
    "--batch-size", "32",
    "--timesteps", "500000"
)

$Runs = @(
    @{ Name = "david_eps_baseline";       Start = "1.0"; End = "0.05"; Fraction = "0.1" }
    @{ Name = "david_eps_fast_decay";     Start = "1.0"; End = "0.05"; Fraction = "0.05" }
    @{ Name = "david_eps_slow_decay";     Start = "1.0"; End = "0.05"; Fraction = "0.3" }
    @{ Name = "david_eps_very_slow";      Start = "1.0"; End = "0.05"; Fraction = "0.5" }
    @{ Name = "david_eps_low_end";        Start = "1.0"; End = "0.01"; Fraction = "0.1" }
    @{ Name = "david_eps_high_end";       Start = "1.0"; End = "0.1";  Fraction = "0.1" }
    @{ Name = "david_eps_mid_start";      Start = "0.5"; End = "0.05"; Fraction = "0.1" }
    @{ Name = "david_eps_low_start";      Start = "0.2"; End = "0.05"; Fraction = "0.1" }
    @{ Name = "david_eps_high_start_slow"; Start = "1.0"; End = "0.01"; Fraction = "0.4" }
    @{ Name = "david_eps_narrow";         Start = "0.5"; End = "0.1";  Fraction = "0.2" }
)

Set-Location (Join-Path $PSScriptRoot "..")
$i = 0
foreach ($run in $Runs) {
    $i++
    Write-Host "`n===== [$i/10] $($run.Name)  eps_start=$($run.Start) eps_end=$($run.End) eps_fraction=$($run.Fraction) =====`n" -ForegroundColor Cyan
    & @Base --name $run.Name --eps-start $run.Start --eps-end $run.End --eps-fraction $run.Fraction
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Run $($run.Name) failed with exit code $LASTEXITCODE"
    }
}

Write-Host "`nAll 10 epsilon experiments finished. Check experiments_log.csv for results." -ForegroundColor Green
