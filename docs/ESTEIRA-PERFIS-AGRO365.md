# Esteira de desenvolvimento por perfil — AGRO365 / GB CERNE

Referência funcional: `mapeamento_funcional_agro365_v2.md`, gravação de 16/08/2026.

## Objetivo

Separar a experiência de gestão da experiência de campo sem duplicar componentes ou regras.
O catálogo em `src/modules/fazendas/functionalCatalog.ts` é a fonte única das funcionalidades
mapeadas, do responsável por cada uma e do nível de fidelidade disponível no protótipo.

## Fronteira de responsabilidade

| Perfil | Pode fazer | Não pode fazer |
|---|---|---|
| Administração | Ler indicadores, filtrar análises, consultar cadastros, acompanhar processos e exportar auditoria | Criar lançamentos de campo |
| Operacional | Selecionar fazenda, cadastrar, lançar, operar hardware e sincronizar dados | Acessar dashboards e decisões gerenciais |

Filtros de dashboards não são considerados entrada operacional: eles apenas alteram a consulta.
A fazenda ativa, os estados offline e os componentes do design system continuam transversais.

## O que foi entregue nesta etapa

- Login demonstrativo com entradas independentes para **Administração** e **Operacional**.
- Identidade do ambiente persistente no shell durante a sessão.
- Navegação contextual por perfil: `Gestão` para administração e `Rotinas` para operação.
- Bloqueio de rotas cruzadas dentro do módulo Fazendas.
- Central administrativa com 12 acessos de decisão, consulta e auditoria.
- Central operacional com 41 acessos cobrindo Estoque, Misturador, Agricultura, Pecuária,
  Reprodução, Frota, OS e Sincronização.
- Formulários dirigidos por catálogo para campos observados e premissas frontend explicitamente sinalizadas.
- Estados honestos para itens cujo acesso foi mostrado sem campos internos.
- Identificação explícita das dependências nativas: Bluetooth, localização, balança, RFID e câmera.
- Dashboard financeiro/operacional ampliado com filtros, posição financeira, COE, COT,
  custeio, produção e resultados apurados.
- Dashboard pecuário ampliado com estoque por categoria, desempenho no intervalo e última pesagem.
- Pesagem e Nutrição/Arraçoamento aperfeiçoados com os campos observados no mapeamento.

## Execução da esteira frontend

### Onda A — concluída no protótipo

- **Áreas:** lista e cadastro operacional, validação obrigatória, detalhe e consulta administrativa
  alimentada pela mesma fonte em memória.
- **Formulações:** lista, criação, matérias-primas vinculadas, validação e confirmação.
- **Batidas:** lista, formulário de produção, destino, quantidade, itens vinculados e confirmação.
- **Apontamento agrícola:** lista, operação, área, data, recursos associados e confirmação.
- **Frota:** listas e formulários de Abastecimento e Manutenção, com campos operacionais,
  validação e detalhe do registro.
- **Motor reutilizável:** todas as rotinas acima percorrem lista → formulário → validação → sucesso
  → consulta, com estado frontend compartilhado durante a sessão e sem dependência de backend.

### Onda B — concluída no protótipo

- **Base pecuária:** Rebanho Inicial, Lotes e Animais agora possuem lista, criação, validação,
  confirmação e detalhe em memória.
- **Movimentação e manejo:** Transferência Lote/Área, Sanitário, Desmama e Pastagens passaram
  a registrar e consultar o histórico da sessão.
- **Reprodução:** Estação de Monta, Lotes/Reprodução, Material Reprodutivo, Protocolos,
  Monta Natural e Diagnóstico de Gestação ganharam jornadas frontend completas.
- **Premissas transparentes:** quando a gravação mostrou apenas o menu, os campos mínimos
  adotados para apresentação ficam informados na própria tela e aguardam validação de domínio.
- **Validação aprimorada:** campos obrigatórios e números inválidos apresentam mensagens junto
  ao controle após a tentativa de salvamento, sem depender apenas de botão desabilitado.

Com as Ondas A e B, o catálogo possui **34 funcionalidades prontas**, **12 mapeadas** e
**7 dependentes de hardware**.

### Onda C — simulações frontend concluídas

- **Conexão Bluetooth:** busca, descoberta, conexão e reinício simulados para balança e RFID.
- **Balança:** captura demonstrativa de peso estável com confirmação antes de prosseguir.
- **RFID:** leitura simulada preenche automaticamente a identificação em Transferência,
  Localização e Perdas, mantendo também a entrada manual.
- **Scanner SISBOV:** área de enquadramento, captura, reinício e confirmação do código.
- **Transferência de animal:** lista, leitura RFID, formulário, validação, sucesso e histórico.
- **Perdas:** lista e registro completo após identificação, com premissas posteriores sinalizadas.
- **Transparência:** os sete itens continuam com o selo `Hardware`, pois a Onda C valida a
  experiência frontend; Bluetooth, câmera, balança e RFID reais dependem do aplicativo mobile.

### Onda D — supervisão, auditoria e lacunas concluídas

- **Administração:** Saldo de Estoque e Processamentos Pecuários possuem consultas com
  registros, estados e detalhes demonstráveis.
- **Auditoria:** logs de Estoque e Pecuária podem ser filtrados por período e exportados
  localmente em CSV ou JSON, com confirmação de nome e quantidade de registros.
- **Misturador:** Carga, Descarga, Nota de Cocho e Configurações ganharam lista, formulário,
  validação, sucesso e histórico em memória.
- **Agricultura:** Marcação passou a registrar área, tipo, descrição e referência de localização.
- **Pecuária e operação:** Compra de Animais, Apartação e Minhas OS agora têm jornadas
  navegáveis e dados demonstrativos.
- **Cobertura:** não existem mais funcionalidades com selo `Mapeado`.

A cobertura funcional é de **46 funcionalidades prontas** e **7 com simulação funcional de
hardware**, totalizando as **53 entradas do catálogo**. A Onda E de endurecimento frontend
também foi concluída; integrações reais de produção permanecem como próximo ciclo do time mobile.

### Onda E — endurecimento frontend concluído

- **Sessão demonstrativa protegida:** rotas internas exigem a escolha explícita do perfil no login.
- **Logout efetivo:** sair encerra a sessão em memória e impede reentrada por URL sem novo login.
- **Proteção por responsabilidade:** a sessão protege o shell e o módulo Fazendas mantém o desvio
  de rotas cruzadas entre Administração e Operacional.
- **Gate automatizado:** `npm run quality:functional` valida as 53 entradas, a divisão 12/41,
  identificadores únicos, ausência de itens `Mapeado` e simulação para todo item `Hardware`.
- **Limite honesto:** RBAC de backend, telemetria de produção, integrações nativas e paridade Flutter
  são requisitos da implementação mobile, não promessas do protótipo frontend.

### Onda F — prontidão para apresentação concluída

- **Toque acessível:** botões pequenos, links, abas, seletores, checkbox, switch, stepper e paginação
  passaram a respeitar alvo mínimo de 44 px sem ampliar desnecessariamente seus elementos visuais.
- **Foco visível:** controles do catálogo deixaram de suprimir o foco global tokenizado.
- **Rótulos:** a conferência de itens no recebimento XML ganhou nome acessível contextual.
- **Validação real:** login, Administração, Operacional, formulário e onboarding foram auditados em
  viewport mobile de 390 × 844 px, sem overflow horizontal ou alvos abaixo do mínimo nas telas testadas.

### Onda G — conformidade Component-First concluída

- **Primitivo reutilizável:** `Pressable` concentra semântica, cursor, foco e alvo mínimo para
  superfícies interativas que não possuem aparência de botão convencional.
- **Migração integral:** navegação, atalhos, filtros, cards e seletores antigos deixaram de usar
  `<button>` diretamente fora de `src/components/ui/`.
- **Prevenção de regressão:** `npm run quality:functional` também rejeita elementos proibidos pelas
  Leis do projeto quando aparecem diretamente em telas ou componentes de módulo.

### Onda H — integridade de tokens concluída

- **Cores centralizadas:** a linha padrão e a variação sobre fundo escuro dos sparklines agora
  consomem `t.chart`, sem valores literais dentro dos componentes.
- **Interoperabilidade:** o novo token `chart.onDark` foi mapeado como `color` no exportador e
  propagado para `tokens/tokens.json` no padrão W3C DTCG.
- **Fonte única:** o gate confirma Outfit como tipografia global e rejeita famílias alternativas.
- **Prevenção de regressão:** cores hex/RGB literais e fontes não autorizadas em TSX passam a
  interromper `npm run quality:functional`.

## Convenção de maturidade no protótipo

| Selo | Significado | Próxima ação |
|---|---|---|
| Pronto | Há tela dedicada ou formulário navegável com os campos conhecidos | Contrato de API, regras finais e testes |
| Mapeado | A função está navegável, mas a fonte não mostrou todos os campos | Validar fluxo com especialista antes de detalhar |
| Hardware | Há simulação frontend funcional, mas a captura nativa ainda depende do dispositivo | Spike no app mobile e teste em dispositivo real |

`Mapeado` não significa esquecido. É uma trava contra a invenção de requisitos que não aparecem
na evidência fornecida.

## Cobertura do Markdown

| Área do mapeamento | Perfil | Cobertura no protótipo |
|---|---|---|
| Seleção de fazenda | Ambos | Contexto global e tela de fazendas |
| Painel financeiro e operacional | Administração | Dashboard detalhado |
| Áreas | Administração / Operacional | Consulta administrativa e entrada operacional separadas |
| Estoque | Administração / Operacional | Saldo e logs na gestão; Formulações e Batidas na operação |
| Misturador | Operacional | Conexão, Carga, Descarga, Balança, Nota de Cocho e Configurações |
| Agricultura | Operacional | Apontamento, Marcação e Colheita de Frutas |
| Pecuária | Administração / Operacional | Dashboard na gestão; todas as rotinas e dependências na operação |
| Reprodução | Operacional | Seis jornadas frontend completas, com premissas sinalizadas para validação de domínio |
| Gestão de Frota | Operacional | Abastecimento e Manutenção |
| Ordem de Serviço | Operacional | Minhas OS |
| Sincronização | Operacional | Fila offline já navegável |

## Esteira recomendada para o time mobile

### 1. Descoberta funcional

1. Selecionar um item `Mapeado` do catálogo.
2. Revisar a gravação e entrevistar um operador responsável pela rotina.
3. Fechar campos, validações, estados vazios e efeitos no restante do sistema.
4. Atualizar primeiro o catálogo e o protótipo; o mobile consome a decisão consolidada.

### 2. Contrato e risco

1. Definir DTO, permissões e escopo da fazenda no backend.
2. Identificar se o fluxo é offline e qual entidade entra na fila de sincronização.
3. Para hardware, executar um spike isolado de permissão, conexão, perda de sinal e retomada.
4. Registrar conflitos e estratégia de idempotência antes de liberar escrita.

### 3. Construção vertical

1. Reutilizar os componentes equivalentes do catálogo mobile.
2. Implementar uma fatia completa: lista/estado vazio → formulário → validação → sucesso → sync.
3. Respeitar o perfil na rota e também na autorização do backend; ocultar menu não é RBAC.
4. Instrumentar eventos mínimos: abertura, início, erro, salvamento local e sincronização.

### 4. Aceite

Uma funcionalidade só muda de `Mapeado` para `Pronto` quando possui:

- responsável e rota definidos;
- campos e validações aprovados por alguém do domínio;
- estados loading, vazio, erro, offline e sucesso quando aplicáveis;
- proteção de perfil e fazenda no frontend e no contrato;
- acessibilidade de toque, foco e rótulos;
- teste de sincronização e retomada quando houver escrita offline;
- teste em dispositivo real quando houver Bluetooth, RFID, câmera, localização ou balança;
- documentação de efeitos (estoque, financeiro, animal, nota fiscal ou ordem de serviço).

## Ordem sugerida de evolução

1. **Onda A — alto uso, baixo risco (concluída no frontend):** Áreas, Formulações, Batidas,
   Apontamento e Frota.
2. **Onda B — pecuária sem hardware (concluída no frontend):** Lotes, Animal, Transferência
   de Lote/Área, Sanitário, Desmama, Pastagens e Reprodução.
3. **Onda C — hardware (simulação frontend concluída):** Conexão, Balança, RFID,
   Scanner SISBOV, Localizar Animal e Perdas.
4. **Onda D — supervisão, auditoria e lacunas (concluída no frontend):** consultas,
   processamentos, exportações e as oito rotinas operacionais restantes.
5. **Onda E — endurecimento frontend (concluída):** sessão demonstrativa protegida, logout efetivo,
   gate automatizado do catálogo e documentação das fronteiras de produção.
6. **Onda F — prontidão para apresentação (concluída):** acessibilidade de toque, foco e rótulos,
   seguida de nova validação mobile dos ambientes e fluxos principais.
7. **Onda G — conformidade Component-First (concluída):** superfícies interativas migradas para
   o catálogo UI e regra incorporada ao gate automatizado.
8. **Onda H — integridade de tokens (concluída):** cores residuais migradas, exportação DTCG
   sincronizada e guardrails de cor e tipografia adicionados ao gate.

## Próximo ciclo de produção

- RBAC real validado no backend, com escopo de fazenda e permissões por ação.
- Telemetria conectada ao ambiente corporativo e política de dados aprovada.
- Testes unitários, de integração e E2E na stack escolhida pelo time mobile.
- Paridade Flutter e testes em dispositivo para Bluetooth, RFID, câmera, localização e balança.
