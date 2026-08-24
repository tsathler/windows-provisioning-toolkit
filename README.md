# WindowsProvisioningToolkit

## Português

O WindowsProvisioningToolkit é um toolkit modular em PowerShell para automatizar o provisionamento de estações de trabalho Windows e a configuração de ambientes corporativos.

Este repositório é a versão segura para portfólio. Ele demonstra menus, instalação de aplicativos, configuração do sistema, modo de simulação, logs, relatórios e testes sem versionar domínios, servidores, usuários, credenciais ou configurações internas.

### Status

Versão atual: `0.2.0` — MVP com validação, CI, instalação de aplicativos e configuração do sistema.

### Requisitos

- Windows
- PowerShell 5.1 ou superior
- Privilégios de administrador para fluxos reais
- Winget para a maioria das instalações
- Pester para os testes automatizados

Execute no PowerShell:

```powershell
.\Main.ps1
```

### Instalação de aplicativos

O MVP permite selecionar e instalar Google Chrome, Mozilla Firefox, WinRAR, AnyDesk, PDFCreator e Microsoft Teams. BurnInTest, CPU-Z e HWMonitor ficam disponíveis como softwares opcionais e podem ser selecionados individualmente no menu. Aplicativos já instalados são ignorados. Os logs são gravados em `C:\ProgramData\WindowsProvisioningToolkit\Logs` e um resumo é exibido ao final.

Chrome, Firefox, WinRAR, AnyDesk e PDFCreator usam Winget. O PDFCreator usa o pacote `PDFCreator-Free` com `/COMPONENTS="none"`. O Microsoft Teams usa `teamsbootstrapper.exe -p`.

Para adicionar outro software opcional, inclua uma entrada declarativa em `src/WindowsProvisioningToolkit/Software/software.config.json`, com `Optional: true`, nomes de detecção e uma origem confirmada. O pipeline de seleção, detecção e instalação é reutilizado automaticamente.

### Configuração do sistema

Os fluxos incluem delegação de credenciais RDP para `TERMSRV/*`, entrada opcional no domínio, configuração do usuário atual e configuração completa do sistema. O WindowsProvisioningToolkit nunca reinicia a máquina automaticamente; quando necessário, o resumo informa que uma reinicialização está pendente.

### Perfis e Dry Run

O perfil padrão é `Portfolio`. Dados corporativos locais devem ficar em `src/WindowsProvisioningToolkit/Config/Corporate.local.json`, arquivo ignorado pelo Git. A entrada no domínio sempre exige confirmação.

Os perfis de execução são Portfolio, Corporate básico, Corporate completo, Somente aplicativos e Somente sistema. O modo `Dry Run` simula instalações e alterações sem aplicar mudanças destrutivas.

### Testes e documentação

```powershell
.\scripts\validate.ps1
```

Para executar somente os testes diretamente:

```powershell
.\tests\Run-Tests.ps1
```

O script valida a sintaxe PowerShell e executa os testes Pester.

Para automações que não devem aguardar entrada no final de uma falha, use:

```powershell
.\Main.ps1 -NoPause
```

- [Guia de uso](docs/USAGE.md)
- [Arquitetura](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)

Relatórios JSON são salvos em `C:\ProgramData\WindowsProvisioningToolkit\Reports`.

## English

The WindowsProvisioningToolkit is a modular PowerShell toolkit for automating Windows workstation provisioning and corporate environment configuration.

This repository is the portfolio-safe version of the project. It demonstrates menus, application installation, system configuration, dry-run behavior, logging, reports, and tests without versioning internal domains, servers, users, credentials, or company configuration.

### Status

Current version: `0.2.0` — an MVP with validation, CI, application installation, and system configuration.

### Requirements

- Windows
- PowerShell 5.1 or newer
- Administrator privileges for real provisioning flows
- Winget for most application installs
- Pester for automated tests

Run from PowerShell:

```powershell
.\Main.ps1
```

### Application installation

The MVP can select and install Google Chrome, Mozilla Firefox, WinRAR, AnyDesk, PDFCreator, and Microsoft Teams. BurnInTest, CPU-Z, and HWMonitor are available as optional applications and can be selected individually. Already-installed applications are skipped. Logs are written to `C:\ProgramData\WindowsProvisioningToolkit\Logs`, and a final summary is displayed.

Chrome, Firefox, WinRAR, AnyDesk, and PDFCreator use Winget. PDFCreator uses the `PDFCreator-Free` package with `/COMPONENTS="none"`. Microsoft Teams uses `teamsbootstrapper.exe -p`.

To add another optional application, add a declarative entry to `src/WindowsProvisioningToolkit/Software/software.config.json` with `Optional: true`, confirmed detection names, and a confirmed source. The existing selection, detection, and installation pipeline is reused automatically.

### System configuration

The flows include RDP credential delegation for `TERMSRV/*`, optional domain join, current-user configuration, and complete system configuration. WindowsProvisioningToolkit never restarts the machine automatically; when required, the summary reports a pending restart.

### Profiles and Dry Run

The default profile is `Portfolio`. Local corporate data belongs in `src/WindowsProvisioningToolkit/Config/Corporate.local.json`, which is ignored by Git. Domain joining always requires confirmation.

Available execution profiles are Portfolio, Basic Corporate, Full Corporate, Applications Only, and System Only. `Dry Run` simulates installations and changes without applying destructive operations.

### Tests and documentation

```powershell
.\tests\Run-Tests.ps1
```

The script validates PowerShell syntax and runs the Pester suite. Additional documentation is available in the [usage guide](docs/USAGE.md), [architecture notes](docs/ARCHITECTURE.md), and [roadmap](docs/ROADMAP.md).

For automation that should not wait for input after a failure, use:

```powershell
.\Main.ps1 -NoPause
```

JSON reports are saved to `C:\ProgramData\WindowsProvisioningToolkit\Reports`.
