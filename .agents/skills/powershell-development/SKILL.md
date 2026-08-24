# PowerShell development no WindowsProvisioningToolkit

- O modulo declara PowerShell 5.1 como requisito. Escreva sintaxe compatível com Windows PowerShell 5.1; nao use recursos exclusivos do PowerShell 7.
- Preserve a organizacao por areas em `src/WindowsProvisioningToolkit` e o carregamento modular do `WindowsProvisioningToolkit.psm1`.
- Reutilize `Write-WPTLog`, Dry Run, deteccao e TaskRunner antes de criar auxiliares.
- Funcoes de fluxo devem deixar erros subirem para o tratamento padrao e usar `-ErrorAction Stop` em operacoes que precisam falhar.
- Ao criar closures para `Condition` ou `Action`, capture dados por item com `GetNewClosure()`; nao dependa de variaveis mutaveis do loop.
- Nao execute alteracoes destrutivas durante testes e preserve a instalacao silenciosa configurada.
