# Site de agendamento odontológico

Cópia estática das telas do projeto: **somente odontologia**, **sem preços de serviços** e com o **nome da clínica em aberto** (provisório: "Sua Clínica").

## Como abrir

Dê dois cliques em `index.html`. Os botões **Agendar** e **Meu agendamento** abrem as telas do cliente; o link **Admin** leva ao painel e a barra lateral navega entre as telas. Não precisa de servidor nem de internet.

## Definir o nome da clínica

```powershell
powershell -ExecutionPolicy Bypass -File .\definir-nome.ps1 -Nome "Nome da Clínica"
# opcional: troca também o domínio dos e-mails de exemplo
powershell -ExecutionPolicy Bypass -File .\definir-nome.ps1 -Nome "Nome da Clínica" -Dominio "dominio.com.br"
```

## Subir para o git

**Primeira vez:** dê dois cliques em `iniciar-git.bat` (ou `powershell -ExecutionPolicy Bypass -File .\iniciar-git.ps1`). Ele cria o repositório, faz o commit e, se você colar a URL de um repositório vazio no GitHub, envia.

**Atualizar depois:** apague tudo da pasta **exceto a pasta oculta `.git`**, extraia o zip novo ali dentro e rode `iniciar-git.bat` de novo. Ele detecta o repositório, commita só o que mudou (inclusive arquivos apagados) e envia para o mesmo GitHub, sem pedir a URL. Para dar uma mensagem ao commit:
```powershell
powershell -ExecutionPolicy Bypass -File .\iniciar-git.ps1 -Message "Adiciona telas de agendamento"
```

## Telas

| Arquivo | Tela |
|---|---|
| `index.html` | Página inicial (cliente) |
| `admin.html` | Visão Geral |
| `agenda.html` | Controle de Agenda |
| `lembretes.html` | Lembretes da véspera |
| `servicos.html` | Gestão de Serviços (sem coluna de preço) |
| `profissionais.html` | Profissionais |
| `financeiro.html` | Módulo Financeiro |
| `configuracoes.html` | Configurações & WhatsApp |
| `agendar.html` | Agendar consulta (etapa 1: escolha do procedimento, sem preços) |
| `meu-agendamento.html` | Meu agendamento (consultar/remarcar/cancelar por protocolo) |
| `nao-exportada.html` | Destino dos links de telas que não foram exportadas (login e etapas seguintes do agendamento) |

## Observações

- São capturas estáticas: o JavaScript do app original não está incluído, então botões e formulários são só visuais.
- Os valores do painel são de demonstração. No Financeiro, os cartões "do ano" subtraem só as receitas de advocacia de novembro; os meses de setembro e outubro não puderam ser separados.
- `configuracoes.html` e `agenda.html` contêm telefone e e-mail reais de teste. Mantenha o repositório **privado** ou troque esses dados.
