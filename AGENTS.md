# WindowsProvisioningToolkit - Contexto do projeto

## Projeto

Toolkit modular em PowerShell para provisionamento de estacoes Windows, com menus, tarefas de sistema/rede/seguranca e instalacao declarativa de softwares.

## Arquitetura

- `src/WindowsProvisioningToolkit` e o modulo; `Core` concentra configuracao, logging, Dry Run, relatorios e TaskRunner.
- `Software` carrega `software.config.json`, detecta, instala e gera tarefas.
- `System`, `Network`, `Security` e `UI` contem os fluxos especializados. `Public/Start-WPT.ps1` coordena a aplicacao.
- `tests` contem testes Pester; `scripts/validate.ps1` e o ponto unico de validacao.

## Regras de implementacao

- Analise a implementacao existente e reutilize funcoes/padroes antes de criar algo novo.
- Prefira configuracao a condicoes especificas por aplicativo e evite dependencias desnecessarias.
- Preserve o pipeline de tarefas e os estados `SUCCESS`, `SKIPPED` e `FAILURE`.
- Mantenha compatibilidade obrigatoria com Windows PowerShell 5.1: evite recursos exclusivos do PowerShell 7.
- Preserve logging, Dry Run e comportamento existente; alteracoes de comportamento devem ter testes Pester.
- O catalogo de software e `Software/software.config.json`, nao `software.json`.
- O TaskRunner executa tarefas sequencialmente, avalia `Condition`, executa `Action` e registra o resultado.
- Nao considere uma alteracao concluida sem executar `scripts/validate.ps1` e revisar o diff.

## Comandos

```powershell
.\scripts\validate.ps1
.\tests\Run-Tests.ps1
```
