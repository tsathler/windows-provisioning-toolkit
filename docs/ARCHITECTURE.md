# WindowsProvisioningToolkit - Arquitetura

## Objetivo

O WindowsProvisioningToolkit é um toolkit modular em PowerShell para o provisionamento de estações de trabalho Windows. O projeto separa os padrões seguros para portfólio da configuração corporativa local, permitindo demonstrar o fluxo de automação sem expor dados internos.

## Ponto de entrada

```text
Main.ps1
```

`Main.ps1` importa o manifesto local de `src/WindowsProvisioningToolkit/WindowsProvisioningToolkit.psd1` e inicia a interface de menus com `Start-WPT`.

## Estrutura do módulo

```text
WindowsProvisioningToolkit/
|-- Main.ps1
|-- src/
|   `-- WindowsProvisioningToolkit/
|       |-- WindowsProvisioningToolkit.psd1
|       |-- WindowsProvisioningToolkit.psm1
|       |-- Config/
|       |   |-- Standard.json
|       |   `-- Corporate.example.json
|       |-- Core/
|       |-- Network/
|       |-- Public/
|       |-- Security/
|       |-- Software/
|       |-- System/
|       `-- UI/
|-- tests/
|   |-- Core/
|   `-- Network/
|-- docs/
|   |-- ARCHITECTURE.md
|   |-- ROADMAP.md
|   `-- USAGE.md
`-- installers/
```

## Áreas internas

- `Public`: pontos de entrada públicos do módulo; atualmente exporta `Start-WPT`.
- `Core`: carregamento de configuração, logs, estado do Dry Run, execução de tarefas, reinicialização e relatórios.
- `Software`: catálogo de softwares, instalação, detecção e criação de tarefas.
- `System`: configuração da estação, usuário, energia e informações do sistema.
- `Network`: verificações de conectividade e entrada opcional no domínio.
- `Security`: elevação, delegação de credenciais e auxiliares de senha.
- `UI`: menus de console, banner, perfis e seleção de execução.
- `Config`: padrões de portfólio e exemplo corporativo.

## Modelo de configuração

The default public profile is stored in:

```text
src/WindowsProvisioningToolkit/Config/Standard.json
```

Corporate values can be generated locally in:

```text
src/WindowsProvisioningToolkit/Config/Corporate.local.json
```

`Corporate.local.json` é ignorado pelo Git e não pode conter credenciais, usuários internos, servidores privados ou segredos de produção. O repositório inclui apenas `Corporate.example.json`, que usa `example.local` como valor seguro.

## Camadas v0.5.0

- `Health`: checks independentes com resultado `PASS`, `WARN` ou `FAIL`.
- `Core`: perfis, plano, dependências, checkpoint/resume, Dry Run e relatório.
- `Security`: assessment somente leitura e remediation explícita.
- `Public`: `Invoke-WPTProvision` para execução interativa ou unattended.

## Fluxo de execução

1. `Main.ps1` imports the module and calls `Start-WPT`.
2. `Start-WPT` checks elevation, initializes logging, and opens the main menu.
3. The user chooses a software, system, profile, dry run, or execution profile flow.
4. Each flow creates task objects and sends them to `Invoke-WPTTasks`.
5. The task runner records success, skipped, and failure counts.
6. Flows with summaries export a JSON report to the configured report path.

Para automação, `Invoke-WPTProvision` carrega o perfil, executa o Health Check, gera o plano e retorna códigos: `0` sucesso, `4` falha de tarefa e `5` reinicialização requerida. `Main.ps1` aceita `-Profile`, `-Unattended`, `-DryRun`, `-NoPause`, `-SkipHealthCheck`, `-Resume` e `-Config`.

## Segurança

- The project defaults to the `Portfolio` profile.
- Domain join is always optional and requires confirmation during execution.
- Dry Run simulates destructive operations before applying real changes.
- WindowsProvisioningToolkit does not restart the machine automatically after system changes.
- Local corporate configuration is kept outside version control.

## Validação

Automated validation is centralized in:

```powershell
.\scripts\validate.ps1
```

O script valida a sintaxe PowerShell e delega os testes Pester existentes. Se algum teste falhar, a validação termina com erro para que a verificação local e futuras execuções de CI detectem corretamente o problema.
