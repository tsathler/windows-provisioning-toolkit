# Testes no WindowsProvisioningToolkit

Fluxo obrigatório: alteracao -> analise de sintaxe -> testes Pester -> investigar/corrigir se falhar -> repetir.

- Execute `scripts/validate.ps1`, que valida scripts PowerShell e chama a suite em `tests`.
- Adicione ou adapte testes Pester quando o comportamento mudar.
- Use mocks para `Install-WPTSoftware`, `Start-Process`, `Invoke-WebRequest`, deteccao e chamadas ao sistema.
- Testes nunca devem instalar software real, baixar instaladores, alterar registro, reiniciar ou modificar configuracao do computador.
- Cubra catalogo, selecao, deteccao, `SKIPPED`, `SUCCESS` e erros de configuracao quando aplicavel.
