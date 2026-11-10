<#
  iniciar-git.ps1
  Cria o repositorio git, faz o commit inicial e (opcional) envia para o GitHub.

  Como rodar (qualquer um):
    1) Duplo clique em  iniciar-git.bat            (ja ignora a politica de execucao)
    2) PowerShell na pasta:
         powershell -ExecutionPolicy Bypass -File .\iniciar-git.ps1
         powershell -ExecutionPolicy Bypass -File .\iniciar-git.ps1 -RemoteUrl "https://github.com/USUARIO/REPO.git"

  Parametros:
    -RemoteUrl  URL do repositorio vazio no GitHub (se omitido, o script pergunta)
    -Branch     nome da branch (padrao: main)
    -Message    mensagem do commit
    -NoPause    nao espera Enter no final (uso em automacao)
#>
param(
    [string]$RemoteUrl = "",
    [string]$Branch    = "main",
    [string]$Message   = "Site odontologico: pagina inicial e painel admin",
    [switch]$NoPause
)

# IMPORTANTE: nao usar "Stop" aqui. No Windows PowerShell 5.1, qualquer linha que o git
# escreva em stderr (avisos de CRLF, dicas, progresso do push) viraria erro fatal.
$ErrorActionPreference = "Continue"
Set-Location -Path $PSScriptRoot

function Write-Step($msg, $color = "Green") { Write-Host $msg -ForegroundColor $color }

function Find-Git {
    $cmd = Get-Command git -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($p in @("$env:ProgramFiles\Git\cmd\git.exe",
                     "${env:ProgramFiles(x86)}\Git\cmd\git.exe",
                     "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe")) {
        if ($p -and (Test-Path $p)) { return $p }
    }
    return $null
}

# Executa o git, junta stdout+stderr em texto e devolve codigo de saida + saida.
function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)
    $out  = & $script:GitExe @GitArgs 2>&1 | ForEach-Object { "$_" }
    $code = $LASTEXITCODE
    return [pscustomobject]@{ Code = $code; Output = (($out | Out-String).Trim()) }
}

function Assert-Git($result, $what) {
    if ($result.Code -ne 0) { throw "$what falhou (codigo $($result.Code)):`n$($result.Output)" }
}

try {
    $script:GitExe = Find-Git
    if (-not $script:GitExe) {
        throw "Git nao encontrado. Instale em https://git-scm.com/download/win e rode de novo."
    }
    Write-Step ("Usando: " + $script:GitExe) "DarkGray"

    # 1) repositorio
    if (-not (Test-Path ".git")) {
        Assert-Git (Invoke-Git init -q) "git init"
        Write-Step "Repositorio criado."
    } else {
        Write-Step "Repositorio ja existe, seguindo." "Yellow"
    }

    # branch (funciona em qualquer versao do git; so muda se ainda nao ha commits)
    $head = Invoke-Git rev-parse --verify HEAD
    if ($head.Code -ne 0) {
        Assert-Git (Invoke-Git symbolic-ref HEAD "refs/heads/$Branch") "definir branch $Branch"
    }

    # evita avisos de quebra de linha (CRLF/LF) que poluem a saida
    [void](Invoke-Git config core.autocrlf false)
    [void](Invoke-Git config core.safecrlf false)

    # 2) identidade (so pergunta se ainda nao estiver configurada)
    if (-not (Invoke-Git config user.name).Output) {
        $n = Read-Host "Seu nome para os commits"
        Assert-Git (Invoke-Git config user.name $n) "git config user.name"
    }
    if (-not (Invoke-Git config user.email).Output) {
        $e = Read-Host "Seu e-mail para os commits"
        Assert-Git (Invoke-Git config user.email $e) "git config user.email"
    }

    # 3) commit
    Assert-Git (Invoke-Git add -A) "git add"
    $status = Invoke-Git status --porcelain
    if ($status.Output) {
        Assert-Git (Invoke-Git commit -q -m $Message) "git commit"
        Write-Step "Commit criado."
    } else {
        Write-Step "Nada novo para commitar." "Yellow"
    }

    # 4) GitHub
    $hasOrigin = (Invoke-Git remote).Output -split "\s+" -contains "origin"
    if (-not $RemoteUrl -and $hasOrigin) {
        # atualizacao: reaproveita o remote que ja foi configurado na primeira vez
        $RemoteUrl = (Invoke-Git remote get-url origin).Output
        Write-Step "Usando o remote ja configurado: $RemoteUrl" "DarkGray"
    }
    elseif (-not $RemoteUrl -and -not $NoPause) {
        $RemoteUrl = Read-Host "URL do repositorio no GitHub (Enter para pular)"
    }
    if ($RemoteUrl) {
        if ($hasOrigin) { Assert-Git (Invoke-Git remote set-url origin $RemoteUrl) "git remote set-url" }
        else            { Assert-Git (Invoke-Git remote add origin $RemoteUrl)     "git remote add" }

        Write-Step "Enviando para $RemoteUrl ..." "Cyan"
        $push = Invoke-Git push -u origin $Branch
        if ($push.Code -ne 0) {
            throw ("git push falhou:`
" + $push.Output +
                   "`
`
Confira: o repositorio existe e esta vazio? Voce esta logado no GitHub (navegador/Git Credential Manager)?")
        }
        Write-Step "Enviado com sucesso."
    } else {
        Write-Step "Sem URL: repositorio ficou so local. Rode de novo com -RemoteUrl quando criar o repositorio no GitHub." "Yellow"
    }

    Write-Host ""
    Write-Step "Pronto. Para ver o site, de dois cliques em index.html" "Cyan"
    $exit = 0
}
catch {
    Write-Host ""
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    $exit = 1
}

if (-not $NoPause) { Read-Host "Pressione Enter para fechar" | Out-Null }
exit $exit
