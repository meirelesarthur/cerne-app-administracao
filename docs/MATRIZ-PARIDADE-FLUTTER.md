# Matriz de paridade — React congelado → Flutter oficial

Data-base: 16/08/2026. Fonte funcional: `mapeamento_funcional_agro365_v2.md`, normalizado em `src/modules/fazendas/functionalCatalog.ts`.

Desde M1, o contrato equivalente está portado para `apps/mobile/lib/modules/fazendas/functional_catalog.dart` e passa a ser a fonte funcional do Flutter. As linhas abaixo continuam como **Legado** ou **Ausente** até que suas jornadas visuais sejam efetivamente integradas nas ondas M2–M11.

Checkpoint M3: os 12 itens administrativos aparecem na Central de gestão e os 41 operacionais na Central de rotinas. Sessão, menus, abas e deep links já respeitam o perfil; os estados **Legado/Ausente** abaixo permanecem até a implementação integral das jornadas nas ondas M4–M7.

## Regra de leitura

- **React:** referência funcional congelada até o corte; não recebe funcionalidades novas.
- **Legado Flutter:** existe uma tela anterior às ondas de perfil, mas ela ainda precisa ser integrada ao catálogo Dart, à sessão e às proteções novas.
- **Ausente Flutter:** será criado na onda indicada.
- **Hardware:** representa somente simulação frontend até existir integração nativa validada em aparelho.
- Uma linha só muda para **Portado** depois de rota, perfil, jornada, testes e estados aplicáveis estarem aprovados.

## Resumo auditável

| Métrica | Contrato de corte |
|---|---:|
| Funcionalidades totais | 53 |
| Administração | 12 |
| Operacional | 41 |
| Prontas no React congelado | 46 |
| Hardware simulado no React congelado | 7 |
| Apenas mapeadas | 0 |

## Administração — 12 itens

| ID | Grupo | Funcionalidade | Maturidade React | Flutter no baseline | Destino Flutter | Onda |
|---|---|---|---|---|---|---|
| `painel-financeiro` | Painéis | Financeiro e operacional | Pronto | Portado: dashboard dedicado | `/fazendas/dashboards/financeiro` protegido | M3/M7 |
| `painel-pecuario` | Painéis | Dashboard pecuário | Pronto | Portado: dashboard dedicado | `/fazendas/dashboards/pecuaria` protegido | M3/M7 |
| `lotacao-currais` | Painéis | Lotação de currais | Pronto | Portado: dashboard dedicado | `/fazendas/dashboards/confinamento` protegido | M3 |
| `ativos` | Painéis | Ativos e depreciação | Pronto | Portado: dashboard dedicado | `/fazendas/dashboards/ativos` protegido | M3 |
| `suprimentos` | Painéis | Suprimentos | Pronto | Portado: dashboard dedicado | `/fazendas/dashboards/suprimentos` protegido | M3 |
| `analise-uso` | Painéis | Análise de uso | Pronto | Portado: dashboard dedicado | `/fazendas/dashboards/uso` protegido | M3 |
| `consultas-gerenciais` | Consultas | Consultas gerenciais | Pronto | Portado: consulta dedicada | `/fazendas/dashboards/consultas` protegido | M3 |
| `areas` | Consultas | Áreas cadastradas | Pronto | Portado: consulta compartilhada | `/fazendas/administracao/areas` lendo `cadastrar-area` | M4/A |
| `saldo-estoque` | Consultas | Saldo de estoque | Pronto | Portado: consulta com dados demonstrativos | `/fazendas/administracao/saldo-estoque` | M7/D |
| `processamentos` | Consultas | Processamentos pecuários | Pronto | Portado: consulta com estados | `/fazendas/administracao/processamentos` | M7/D |
| `exportar-log-estoque` | Auditoria | Exportar log de estoque | Pronto | Portado: CSV/JSON e download web | `/fazendas/administracao/exportar-log-estoque` | M7/D |
| `exportar-log-pecuaria` | Auditoria | Exportar log da pecuária | Pronto | Portado: CSV/JSON e download web | `/fazendas/administracao/exportar-log-pecuaria` | M7/D |

## Operacional — 41 itens

| ID | Grupo | Funcionalidade | Maturidade React | Flutter no baseline | Destino Flutter | Onda |
|---|---|---|---|---|---|---|
| `cadastrar-area` | Cadastros | Áreas | Pronto | Portado: lista e formulário | `/fazendas/operacional/cadastrar-area` | M4/A |
| `formulacoes` | Estoque | Formulações | Pronto | Portado: lista e formulário | `/fazendas/operacional/formulacoes` | M4/A |
| `batidas` | Estoque | Batida | Pronto | Portado: lista e formulário | `/fazendas/operacional/batidas` | M4/A |
| `conexao-aparelhos` | Misturador | Conexão de aparelhos | Hardware | Portado: descoberta e conexão simuladas | `/fazendas/operacional/conexao-aparelhos` | M6/C |
| `carga` | Misturador | Carga | Pronto | Portado: lista e formulário | `/fazendas/operacional/carga` | M7/D |
| `descarga` | Misturador | Descarga | Pronto | Portado: lista e formulário | `/fazendas/operacional/descarga` | M7/D |
| `balanca` | Misturador | Balança | Hardware | Portado: captura de peso simulada | `/fazendas/operacional/balanca` | M6/C |
| `nota-cocho` | Misturador | Nota de cocho | Pronto | Portado: lista e formulário | `/fazendas/operacional/nota-cocho` | M7/D |
| `configuracoes-misturador` | Misturador | Configurações | Pronto | Portado: lista e formulário | `/fazendas/operacional/configuracoes-misturador` | M7/D |
| `apontamento` | Agricultura | Apontamento agrícola | Pronto | Portado: lista e formulário | `/fazendas/operacional/apontamento` | M4/A |
| `marcacao` | Agricultura | Marcação | Pronto | Portado: lista e formulário | `/fazendas/operacional/marcacao` | M7/D |
| `colheita-frutas` | Agricultura | Colheita de frutas | Pronto | Portado: formulário e caixas vinculadas | `/fazendas/operacional/colheita-frutas` | M7/D |
| `rebanho-inicial` | Pecuária | Rebanho inicial | Pronto | Portado: lista e formulário | `/fazendas/operacional/rebanho-inicial` | M5/B |
| `conexao-aparelhos-pecuaria` | Pecuária | Conexão de aparelhos | Hardware | Portado: descoberta e conexão simuladas | `/fazendas/operacional/conexao-aparelhos-pecuaria` | M6/C |
| `lote-animais` | Pecuária | Lote de animais | Pronto | Portado: lista e formulário | `/fazendas/operacional/lote-animais` | M5/B |
| `registrar-animal` | Pecuária | Registrar animal | Pronto | Portado: lista e formulário | `/fazendas/operacional/registrar-animal` | M5/B |
| `pesagem` | Pecuária | Pesagens | Pronto | Portado: fluxo dedicado | `/fazendas/campo/pesagem` sob perfil operacional | M3/M7 |
| `transferencia-animal` | Pecuária | Transferência animal/lote | Hardware | Portado: RFID ou identificação manual | `/fazendas/operacional/transferencia-animal` | M6/C |
| `scanner-sisbov` | Pecuária | Scanner SISBOV | Hardware | Portado: enquadramento e captura simulados | `/fazendas/operacional/scanner-sisbov` | M6/C |
| `transferencia-lote-area` | Pecuária | Transferência lote/área | Pronto | Portado: lista e formulário | `/fazendas/operacional/transferencia-lote-area` | M5/B |
| `nascimentos` | Pecuária | Nascimentos | Pronto | Portado: fluxo compartilhado de ciclo | `/fazendas/campo/ciclo` sob perfil operacional | M3/M7 |
| `mortes` | Pecuária | Mortes | Pronto | Portado: fluxo compartilhado de ciclo | `/fazendas/campo/ciclo` sob perfil operacional | M3/M7 |
| `perdas` | Pecuária | Perdas | Hardware | Portado: RFID ou identificação manual | `/fazendas/operacional/perdas` | M6/C |
| `compras-animais` | Pecuária | Compra de animais | Pronto | Portado: lista e formulário | `/fazendas/operacional/compras-animais` | M7/D |
| `vendas` | Pecuária | Vendas | Pronto | Portado: fluxo dedicado | `/fazendas/campo/venda` sob perfil operacional | M3/M7 |
| `nutricoes` | Pecuária | Nutrições | Pronto | Portado: arraçoamento dedicado | `/fazendas/campo/arracoamento` sob perfil operacional | M3/M7 |
| `sanitario` | Pecuária | Sanitário | Pronto | Portado: lista e formulário | `/fazendas/operacional/sanitario` | M5/B |
| `desmama` | Pecuária | Desmama | Pronto | Portado: lista e formulário | `/fazendas/operacional/desmama` | M5/B |
| `apartacao` | Pecuária | Apartação | Pronto | Portado: lista e formulário | `/fazendas/operacional/apartacao` | M7/D |
| `localizar-animal` | Pecuária | Localizar animal | Hardware | Portado: RFID ou identificação manual | `/fazendas/operacional/localizar-animal` | M6/C |
| `pastagens` | Pecuária | Pastagens | Pronto | Portado: formulário e grupos | `/fazendas/operacional/pastagens` | M5/B |
| `estacao-monta` | Reprodução | Estação de monta | Pronto | Portado: período validado | `/fazendas/operacional/estacao-monta` | M5/B |
| `lotes-reproducao` | Reprodução | Lotes/reprodução | Pronto | Portado: lista e formulário | `/fazendas/operacional/lotes-reproducao` | M5/B |
| `material-reprodutivo` | Reprodução | Touros/sêmen/embrião | Pronto | Portado: lista e formulário | `/fazendas/operacional/material-reprodutivo` | M5/B |
| `protocolos-estacao` | Reprodução | Protocolos/estação | Pronto | Portado: formulário e grupos | `/fazendas/operacional/protocolos-estacao` | M5/B |
| `monta-natural` | Reprodução | Monta natural | Pronto | Portado: lista e formulário | `/fazendas/operacional/monta-natural` | M5/B |
| `diagnostico-gestacao` | Reprodução | Diagnóstico de gestação | Pronto | Portado: lista e formulário | `/fazendas/operacional/diagnostico-gestacao` | M5/B |
| `abastecimentos` | Frota | Abastecimentos | Pronto | Portado: lista e formulário | `/fazendas/operacional/abastecimentos` | M4/A |
| `manutencao-frota` | Frota | Manutenção | Pronto | Portado: lista e formulário | `/fazendas/operacional/manutencao-frota` | M4/A |
| `minhas-os` | Ordem de serviço | Minhas OS | Pronto | Portado: consulta com dados demonstrativos | `/fazendas/operacional/minhas-os` | M7/D |
| `sincronizacao` | Sincronização | Sincronização de dados | Pronto | Portado: fila de sincronização | `/fazendas/mais/sync` sob perfil operacional | M3/M8 |

## Contrato que acompanha cada linha na porta Dart

Os detalhes não são inferidos desta tabela. Para cada ID, a porta deve copiar semanticamente do catálogo congelado:

- objetivo e grupo;
- campos, tipo, opções e obrigatoriedade;
- seções e capacidades;
- texto de ação primária, estado vazio e sucesso;
- campos usados no título e descrição do registro;
- `dataSourceId` para consultas administrativas;
- tipo de simulação e campo-alvo para hardware;
- tipo de exportação de auditoria;
- premissas explícitas registradas em `sourceDetail`.

M1 só termina quando um teste Dart provar que todos esses contratos foram representados, e não apenas os IDs da tabela.

## Jornadas críticas de aceite

1. Login → Administração → central de gestão → dashboard → filtros → retorno.
2. Login → Administração → Áreas cadastradas → detalhe de registro criado no Operacional.
3. Login → Administração → auditoria → período → exportação CSV/JSON → confirmação.
4. Login → Operacional → central de rotinas → lista vazia → novo registro → erro de validação → sucesso → detalhe.
5. Login → Operacional → rotina offline → fila de sincronização → sincronizar.
6. Login → Operacional → hardware simulado → descoberta/captura → alternativa manual → confirmação.
7. Administrador tentando rota operacional e operador tentando dashboard, ambos com redirecionamento seguro.
8. Logout → tentativa de deep link → retorno ao login.

Cada jornada deve ser validada em tema claro e GB Mode, viewport 390×844, layout largo adaptativo e navegação por teclado na versão web.

## Critério de remoção do React

Esta matriz precisa estar integralmente marcada como **Portado**, os gates descritos em `MEMORIA-MIGRACAO-FLUTTER.md` precisam estar verdes e o preview Cloudflare Flutter precisa ser aprovado antes de remover qualquer runtime React.
