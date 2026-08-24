# WindowsProvisioningToolkit - Roadmap

## v0.1.0 - Instalacao de Aplicativos

- [x] Menu de selecao de aplicativos
- [x] Instalacao dos aplicativos prioritarios do MVP
- [x] Verificacao antes da instalacao
- [x] Logs e resumo final

## v0.1.1 - Configuracao do Sistema

- [x] Delegacao de credenciais RDP para `TERMSRV/*`
- [x] Entrada opcional no dominio informado pelo usuario
- [x] Solicitacao segura de credenciais com `Get-Credential`
- [x] Deteccao do usuario atual
- [x] Alteracao opcional do nome de usuario local
- [x] Alteracao opcional da senha de usuario local
- [x] Menu de Configuracao do Sistema
- [x] Execucao completa das configuracoes de sistema
- [x] Resumo com indicacao de reinicializacao necessaria
- [x] Perfil Portfolio/Corporate local
- [x] Modo Dry Run
- [x] Testes automatizados iniciais
- [x] Script unico de validacao
- [x] Relatorio final em JSON
- [x] Guia de uso da v0.2.0
- [x] Perfis de execucao
- [x] Resumo pre-execucao

## v0.2.0 - Qualidade e segurança

- [x] Pipeline de CI com testes e análise estática
- [x] Validação da configuração antes da execução
- [x] Modo sem pausa para automações
- [x] Redação básica de dados sensíveis nos logs
- [x] Cobertura inicial da validação de configuração

## v0.2.1 - Health Check

- [x] Diagnóstico padronizado de sistema, hardware, rede e segurança
- [x] Resultado READY/READY_WITH_WARNINGS/NOT_READY
- [x] Opção manual no menu e seção no relatório

## v0.3.0 - Perfis declarativos

- [x] Geração de plano por perfil e dependências básicas
- [x] Dry Run e visualização do plano

## v0.3.1 - Reboot + Resume

- [x] Estado persistente e retomada sem reexecutar tarefas concluídas

## v0.4.0 - Security Baseline

- [x] Assessment separado de remediation
- [x] Remediações controladas por configuração e confirmação

## v0.5.0 - Unattended Mode

- [x] Entrada por parâmetros, logs, relatório e códigos de saída

## Próximas melhorias

- [ ] Expandir cobertura de testes para fluxos interativos
- [ ] v0.6.0 - Image Builder / ISO personalizada (fora deste ciclo)
