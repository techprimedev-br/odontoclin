<#
  definir-nome.ps1
  Troca o nome provisorio ("Sua Clinica") pelo nome real da clinica em todos os .html.

  Uso:
    powershell -ExecutionPolicy Bypass -File .\definir-nome.ps1 -Nome "Odonto Sorriso"
    powershell -ExecutionPolicy Bypass -File .\definir-nome.ps1 -Nome "Odonto Sorriso" -Dominio "odontosorriso.com.br"

  -Nome     nome da clinica (obrigatorio)
  -Dominio  troca tambem o dominio dos e-mails de exemplo (admin@exemplo.com.br) - opcional
#>
param(
    [Parameter(Mandatory = $true)][string]$Nome,
    [string]$Dominio = ""
)
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$utf8   = New-Object System.Text.UTF8Encoding($false)
$enc    = [System.Net.WebUtility]::HtmlEncode($Nome)
$upper  = [System.Net.WebUtility]::HtmlEncode($Nome.ToUpper())
$urlEnc = [System.Uri]::EscapeDataString($Nome)

# Os tokens abaixo sao os textos provisorios usados nas paginas.
$tokUp  = "SUA CL" + [char]0x00CD + "NICA"      # SUA CLINICA (com acento)
$tokTit = "Sua Cl" + [char]0x00ED + "nica"      # Sua Clinica (com acento)
$tokUrl = "Sua%20Cl%C3%ADnica"

$total = 0
foreach ($f in Get-ChildItem -Path . -Filter *.html -File) {
    $t = [System.IO.File]::ReadAllText($f.FullName, $utf8)
    $n = $t.Replace($tokUp, $upper).Replace($tokTit, $enc).Replace($tokUrl, $urlEnc)
    if ($Dominio) { $n = $n.Replace("exemplo.com.br", $Dominio) }
    if ($n -ne $t) {
        [System.IO.File]::WriteAllText($f.FullName, $n, $utf8)
        Write-Host ("Atualizado: " + $f.Name) -ForegroundColor Green
        $total++
    }
}
if ($total -eq 0) { Write-Host "Nada para trocar (o nome provisorio ja foi substituido?)." -ForegroundColor Yellow }
else { Write-Host "Pronto: $total arquivo(s) atualizado(s)." -ForegroundColor Cyan }
