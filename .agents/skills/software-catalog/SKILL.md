# Manutencao do catalogo de software

1. Leia `src/WindowsProvisioningToolkit/Software/software.config.json` e o fluxo `Get-WPTSoftware`, `Get-WPTSoftwareTasks`, `Test-WPTSoftwareInstalled` e `Install-WPTSoftware`.
2. Defina um nome estável e `DetectionNames` baseados no DisplayName real; inclua `AppxNames` somente quando necessario.
3. Marque `Optional: true` para software que nao deve entrar na selecao padrao. Nao crie `if` por nome.
4. Prefira `Source.Type: Winget` com `PackageId` confirmado no catalogo oficial/confiavel. Para download, confirme URL oficial, tipo e argumentos silenciosos.
5. Mantenha `InstallerType`, `Arguments` e a instalacao silenciosa coerentes com a origem. Nao invente IDs, URLs ou switches.
6. Confirme que a deteccao ocorre antes e depois da instalacao; ja instalado deve resultar em `SKIPPED`.
7. Adicione testes com mocks para carregamento, obrigatorio/opcional, selecao, deteccao e garantia de que instalacao real nao ocorre.
8. Execute `scripts/validate.ps1` e revise o diff.
