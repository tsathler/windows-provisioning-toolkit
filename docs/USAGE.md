# WindowsProvisioningToolkit v0.5.0 - Guia de Uso

## Como executar

Abra o PowerShell na pasta do projeto e execute:

```powershell
.\Main.ps1
```

O WindowsProvisioningToolkit carrega o modulo local em `src/WindowsProvisioningToolkit` e abre a interface de menu.

## Menu principal

```text
[1] Instalacao de Aplicativos
[2] Configuracao do Sistema
[3] Perfil e Configuracao
[4] Alternar Dry Run
[5] Perfis de Execucao
[6] Executar Health Check
[7] Avaliacao de Seguranca
[0] Sair
```

## Instalacao de Aplicativos

Use esta area para selecionar os aplicativos do MVP:

- Google Chrome
- Mozilla Firefox
- WinRAR
- AnyDesk
- PDFCreator
- Microsoft Teams

Aplicativos ja instalados sao marcados como ignorados no resumo final.

## Configuracao do Sistema

Use esta area para executar:

- Delegacao de credenciais RDP para `TERMSRV/*`
- Entrada opcional no dominio
- Configuracao do usuario atual
- Configuracao completa do sistema

A entrada no dominio nunca e aplicada automaticamente. Mesmo com perfil
Corporate configurado, o WindowsProvisioningToolkit pergunta se a maquina deve entrar no dominio.

## Perfil Portfolio e Corporate

O repositorio fica no perfil Portfolio por padrao e nao deve conter dados
internos de empresa.

Para configurar dados locais de ambiente corporativo, acesse:

```text
[3] Perfil e Configuracao
[2] Configurar Corporate local
```

Isso cria ou atualiza:

```text
src/WindowsProvisioningToolkit/Config/Corporate.local.json
```

Esse arquivo e ignorado pelo Git. Ele pode guardar valores como dominio
sugerido, mas nao deve armazenar credenciais.

Para limpar o perfil Corporate local:

```text
[3] Perfil e Configuracao
[3] Limpar Corporate local
```

Depois disso, o WindowsProvisioningToolkit volta a usar somente o perfil Portfolio.

## Dry Run

Use a opcao abaixo para alternar o modo de simulacao:

```text
[4] Alternar Dry Run
```

Com Dry Run ativo, o WindowsProvisioningToolkit registra o que faria sem aplicar mudancas
destrutivas no sistema, como instalacoes, entrada no dominio, alteracao de
usuario, senha ou reinicio.

## Perfis de Execucao

Use esta area para iniciar fluxos prontos:

```text
[1] Portfolio
[2] Corporate basico
[3] Corporate completo
[4] Somente aplicativos
[5] Somente sistema
```

Antes de executar, o WindowsProvisioningToolkit mostra:

- Perfil escolhido
- Perfil ativo
- Estado do Dry Run
- Lista de tarefas previstas

O perfil `Corporate basico` inclui delegacao RDP e entrada opcional no dominio.
O perfil `Corporate completo` inclui delegacao RDP, entrada opcional no dominio
e configuracao do usuario atual.

A entrada no dominio continua perguntando durante a execucao. Responder `N`
mantem a maquina fora do dominio.

## Logs e relatorios

Logs:

```text
C:\ProgramData\WindowsProvisioningToolkit\Logs
```

Relatorios JSON:

```text
C:\ProgramData\WindowsProvisioningToolkit\Reports
```

Os relatorios incluem perfil ativo, contexto executado, computador, usuario,
estado do Dry Run, resumo, detalhes das tarefas e reinicializacao pendente.

## Testes

Execute a validacao automatizada com:

```powershell
.\tests\Run-Tests.ps1
```

O script valida sintaxe PowerShell e executa os testes Pester.

## Cuidados

- Nao versionar `Corporate.local.json`.
- Nao inserir senhas, usuarios internos ou servidores sensiveis no repositorio.
- Testar alteracoes de sistema primeiro com Dry Run ativo.
