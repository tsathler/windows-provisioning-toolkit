# Changelog

## v0.5.0 - 2026-08-24

- Adicionado modo unattended com `-Profile`, `-Unattended`, `-DryRun`, `-NoPause`, `-SkipHealthCheck`, `-Resume` e `-Config`.
- Adicionados códigos de saída para sucesso, falha de tarefa e reinicialização requerida.

## v0.4.0 - 2026-08-24

- Adicionados Security Assessment e Security Remediation separados.
- Adicionadas verificações de TPM, Secure Boot, Firewall, Defender, BitLocker e SMBv1.

## v0.3.1 - 2026-08-24

- Adicionado checkpoint persistente em `C:\ProgramData\WindowsProvisioningToolkit\State`.
- Adicionada retomada sem reexecutar tarefas concluídas.

## v0.3.0 - 2026-08-24

- Adicionados perfis declarativos e geração de planos de provisionamento.
- Adicionadas dependências básicas entre tarefas e visualização do plano.

## v0.2.1 - 2026-08-24

- Adicionado Health Check pré-provisionamento com estados `PASS`, `WARN` e `FAIL`.
- Adicionada integração do Health Check ao menu e ao relatório JSON.

## v0.2.0 - 2026-08-22

### Adicionado

- Pipeline de CI para PowerShell 5.1 e PowerShell 7.
- Análise estática com PSScriptAnalyzer no CI.
- Validação das seções e caminhos obrigatórios da configuração.
- Opção `-NoPause` para execução automatizada.
- Redação básica de valores sensíveis nos logs.
- Testes automatizados de validação de configuração.

### Alterado

- Descrição do módulo alinhada às funcionalidades atuais.
- Versão do módulo, configuração e banner atualizados para `0.2.0`.
# v0.5.0 - Unattended Provisioning

- Added declarative provisioning plans, checkpoint/resume, security assessment and unattended entry points.
- Added health diagnostics and report sections for health/security.
