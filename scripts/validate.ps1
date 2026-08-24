$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Validando sintaxe PowerShell..." -ForegroundColor Cyan
$syntaxErrors = @()
Get-ChildItem -LiteralPath $projectRoot -Filter "*.ps1" -Recurse -File |
    ForEach-Object {
        $tokens = $null
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null
        if ($parseErrors) {
            $syntaxErrors += $parseErrors | ForEach-Object { "{0}: {1}" -f $_.Extent.File, $_.Message }
        }
    }

if ($syntaxErrors.Count -gt 0) {
    $syntaxErrors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
}

Write-Host "Sintaxe OK." -ForegroundColor Green
if (-not (Get-Command Invoke-Pester -ErrorAction SilentlyContinue)) {
    Write-Host "Pester nao esta disponivel; testes nao executados neste ambiente." -ForegroundColor Yellow
    exit 0
}

Write-Host "Executando testes Pester..." -ForegroundColor Cyan
& (Join-Path $projectRoot "tests\Run-Tests.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Validacao concluida com sucesso." -ForegroundColor Green
