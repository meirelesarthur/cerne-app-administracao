# Inventário de funcionalidades para criação de ícones

Base: código Flutter no commit `5aa73a4`, consultado em 17/09/2026.

Este documento reúne os itens do levantamento para orientar a criação de ícones. Cada linha descreve o significado que o desenho deve comunicar e identifica o ícone atual. Os nomes entre crases são identificadores de `AppIcons`, não especificações para o novo desenho.

## Orientações de uso

- As 55 funcionalidades de Fazendas estão separadas por perfil e grupo, com seus IDs para facilitar a implementação.
- Somente cinco funcionalidades têm ícone específico na grade atual; as outras 50 herdam o ícone do grupo. A repetição atual não obriga a repetir o novo desenho.
- Uma funcionalidade pode aparecer em vários lugares com ícones diferentes. As variações estão registradas na seção de atalhos.
- Diferenciar o ícone de um módulo, o de uma funcionalidade e o de uma ação compartilhada. Uma ação como salvar pode usar o mesmo desenho em várias telas.
- As descrições representam a finalidade das funções. O app é um protótipo frontend: integrações de hardware e serviços podem ser simuladas, e entradas do catálogo de apps podem ser apenas demonstrativas.
- Este inventário cobre as funcionalidades, navegação e controles do levantamento; não é uma contagem de todas as ocorrências decorativas, setas e estados visuais do código.

## Funcionalidades operacionais de Fazendas

### Agricultura

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Apontamento agrícola | Registrar uma operação agrícola e os recursos associados. | `sprout` | `apontamento` |
| Marcação | Acessar e registrar marcações agrícolas. | `sprout` | `marcacao` |

### Confinamento

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Trato diário | Distribuir uma batelada entre os currais elegíveis do dia. | `heartPulse` | `trato-diario` |
| Leitura de cocho | Avaliar sobras por curral e registrar ocorrências sanitárias, estruturais e ambientais. | `scanLine` | `leitura-cocho-confinamento` |
| Meus currais | Consultar a situação dos currais e acionar pesagem, sanitário e óbito. | `warehouse` | `meus-currais` |
| Produzir batelada | Registrar a produção física de uma mistura de dieta, ingrediente a ingrediente. | `misturador` | `producao-batelada` |
| Ordens pendentes | Confirmar a execução de transferências de lote e trocas de dieta criadas pelo ADM. | `clock` | `ordens-pendentes` |
| Configurações | Parametrizar recursos do misturador. | `confinamento` | `configuracoes-misturador` |
| Conexão de aparelhos | Conectar balança e equipamentos externos por Bluetooth. | `confinamento` | `conexao-aparelhos` |

### Consultas

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Lote de animais | Criar um lote em fluxo de múltiplas etapas. | `bookOpen` | `lote-animais` |
| Áreas | Cadastrar áreas usadas nos processos da fazenda. | `bookOpen` | `cadastrar-area` |
| Formulações | Criar formulações compostas por matérias-primas e percentuais. | `bookOpen` | `formulacoes` |
| Batida | Registrar a produção de uma formulação para um armazém de destino. | `bookOpen` | `batidas` |
| Estação de monta | Gerenciar períodos e ciclos de reprodução. | `bookOpen` | `estacao-monta` |
| Protocolos / estação | Gerenciar protocolos associados à estação reprodutiva. | `bookOpen` | `protocolos-estacao` |
| Touros / sêmen / embrião | Gerenciar material e recursos reprodutivos. | `bookOpen` | `material-reprodutivo` |

### Gestão de frota

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Abastecimentos | Consultar e registrar abastecimentos da frota. | `truck` | `abastecimentos` |
| Manutenção | Controlar manutenções da frota. | `truck` | `manutencao-frota` |

### Ordem de serviço

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Minhas OS | Consultar ordens de serviço vinculadas ao funcionário e à fazenda, e conduzir a execução (iniciar, pausar, entregar ou marcar como refeita). | `fileText` | `minhas-os` |

### Pecuária

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Pesagens | Consultar e registrar pesagens do rebanho. | `pecuaria` | `pesagem` |
| Sanitário | Criar um manejo sanitário por responsável e lote. | `pecuaria` | `sanitario` |
| Arraçoamento | Registrar produtos, quantidade, área, módulo e cocho. | `pecuaria` | `nutricoes` |
| Transferência animal / lote | Mover um animal para outro lote com identificação por brinco, RFID ou câmera. | `pecuaria` | `transferencia-animal` |
| Transferência lote / área | Alterar a localização de um lote entre área e módulo. | `pecuaria` | `transferencia-lote-area` |
| Localizar animal | Localizar um animal por brinco, ID, RFID ou câmera. | `pecuaria` | `localizar-animal` |
| Pastagens | Registrar recursos e serviços aplicados à pastagem. | `pecuaria` | `pastagens` |
| Apartação | Executar e registrar a apartação do rebanho. | `pecuaria` | `apartacao` |
| Nascimentos | Registrar nascimento de animais. | `pecuaria` | `nascimentos` |
| Desmama | Registrar desmama e identificar vacas paridas. | `pecuaria` | `desmama` |
| Mortes | Consultar e registrar mortes do rebanho. | `pecuaria` | `mortes` |
| Registrar animal | Cadastrar um animal individualmente. | `pecuaria` | `registrar-animal` |
| Perdas | Registrar perdas após identificar o animal. | `pecuaria` | `perdas` |
| Rebanho inicial | Estabelecer a composição inicial do rebanho. | `pecuaria` | `rebanho-inicial` |
| Scanner SISBOV | Capturar a identificação do animal usando a câmera. | `pecuaria` | `scanner-sisbov` |
| Conexão de aparelhos | Preparar balança e leitor RFID para as rotinas pecuárias. | `pecuaria` | `conexao-aparelhos-pecuaria` |

### Reprodução

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Acasalamento | Registrar operações de acasalamento. | `heartPulse` | `monta-natural` |
| Diagnóstico de gestação | Registrar e consultar diagnósticos de gestação. | `heartPulse` | `diagnostico-gestacao` |

### Sincronização

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Sincronização de dados | Enviar a fila local para a nuvem após operação offline. | `refreshCw` | `sincronizacao` |

## Funcionalidades administrativas de Fazendas

### Consultas e auditoria

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Consultas gerenciais | Consultar lotes, estoque e pesagens sem permitir alterações. | `search` | `consultas-gerenciais` |
| Saldo de estoque | Consultar o saldo disponível dos itens armazenados. | `search` | `saldo-estoque` |
| Produtos | Consultar e cadastrar o catálogo de produtos, categorias e custo médio. | `search` | `consulta-produtos` |
| Áreas cadastradas | Consultar as áreas usadas pelos processos da fazenda. | `search` | `areas` |
| Lotes / reprodução | Consultar lotes vinculados ao processo reprodutivo. | `search` | `lotes-reproducao` |
| Processamentos pecuários | Acompanhar rotinas pendentes e concluídas. | `search` | `processamentos` |
| Compra de animais | Consultar compras de animais registradas. | `search` | `compras-animais` |
| Vendas | Consultar vendas de animais registradas. | `search` | `vendas` |
| Exportar log de estoque | Exportar registros de auditoria relacionados ao estoque. | `search` | `exportar-log-estoque` |
| Exportar log da pecuária | Exportar o histórico de eventos e movimentações do rebanho. | `search` | `exportar-log-pecuaria` |
| Ordem de Serviço | Consultar todas as ordens de serviço da fazenda, avaliar o andamento ou cancelar uma OS ainda não encerrada pelo Operacional. | `search` | `consulta-os` |
| Apontamentos agrícolas | Consultar os apontamentos agrícolas lançados pelo Operacional, com identificação, dados da operação e os recursos/produção/ocorrências registrados. | `search` | `consulta-apontamentos` |

### Painéis de decisão

| Funcionalidade | Mini resumo | Ícone atual | ID |
|---|---|---|---|
| Resultado | Consolidar receita, custo, margem e posição financeira por período. | `layoutDashboard` | `painel-financeiro` |
| Rebanho e confinamento | Supervisionar ocupação, desempenho do lote (GMD) e alertas dos currais. | `layoutDashboard` | `lotacao-currais` |
| Suprimentos | Comparar cotações e apoiar decisões de compra. | `layoutDashboard` | `suprimentos` |
| Ativos e depreciação | Acompanhar patrimônio, manutenção e valor residual. | `layoutDashboard` | `ativos` |
| Adoção e governança | Supervisionar usuários ativos, utilização por fazenda e trilha de auditoria. | `layoutDashboard` | `analise-uso` |

## Grupos e navegação

| Item | Mini resumo | Ícone atual |
|---|---|---|
| Home / Início | Retornar à tela inicial e aos principais acessos. | `home` |
| Confinamento | Reunir currais, produção de dieta, trato e leitura de cocho. | `confinamento` |
| Pecuária | Reunir registros e manejos do rebanho. | `pecuaria` |
| Agricultura | Reunir operações e marcações agrícolas. | `sprout` na grade; `agricultura` na barra inferior |
| Reprodução | Reunir acasalamentos e diagnósticos de gestação. | `heartPulse` |
| Consultas de campo | Acessar lotes, áreas, formulações e referências reprodutivas. | `bookOpen` |
| Gestão de frota | Reunir abastecimentos e manutenções de veículos e máquinas. | `truck` |
| Ordem de serviço | Acessar tarefas atribuídas e acompanhar sua execução. | `fileText` |
| Sincronizar aplicativo | Enviar registros feitos sem conexão para a nuvem. | `refreshCw` |
| Painéis de decisão / Gestão | Acessar indicadores e acompanhamento gerencial da fazenda. | `layoutDashboard` |
| Consultas e auditoria / Consultas administrativas | Pesquisar registros e consultar históricos gerenciais. | `search` |
| Cadastros / Rotinas / Operacional | Acessar cadastros e rotinas de registro da operação. | `clipboardList` |
| Estoque | Consultar produtos e quantidades armazenadas. | `boxes` |
| Apps | Abrir o catálogo de aplicativos e serviços. | `layoutGrid` |
| Menu | Abrir a navegação e opções da conta. | `menu` |
| Mais | Acessar opções adicionais do contexto atual. | `moreHorizontal` |

## Atalhos de Fazendas e variações de ícones

Estes itens representam entradas adicionais ou variações visuais das funcionalidades, não necessariamente novas funções.

| Atalho | Mini resumo | Ícone atual |
|---|---|---|
| Resultado | Abrir indicadores financeiros de receita, custo e margem. | `wallet` |
| Rebanho / Rebanho & Confinamento | Acompanhar lotação, desempenho e situação dos currais. | `warehouse` |
| Compras / Suprimentos | Acompanhar cotações e decisões de compra. | `boxes` |
| Ativos | Consultar patrimônio e manutenção de bens. | `package` |
| Pesagem | Registrar o peso de animais e acompanhar pesagens. | `scale` |
| Ciclo rebanho | Registrar entradas e saídas no ciclo do rebanho. | `arrowLeftRight` |
| Arraçoamento | Registrar a distribuição de alimento aos animais. | `wheat` |
| Venda | Registrar venda de animais e informações de transporte. | `truck` |
| Entrada NF-e / Importar XML | Registrar recebimentos a partir do XML de uma nota fiscal. | `fileText` |
| Insumos | Registrar aplicações e retiradas de insumos. | `sprout` |
| Confinamento na busca | Acessar as rotinas de confinamento pelos resultados ou atalhos de busca. | `warehouse` |

## Demais módulos e serviços

| Área | Funcionalidade / item | Mini resumo | Ícone atual |
|---|---|---|---|
| Módulos | Fazendas | Acessar a gestão da fazenda e os lançamentos de campo. | `sprout` |
| Módulos | Bank / GB Bank | Acessar conta, pagamentos, transferências e cartões. | `landmark` |
| Módulos | Crédito | Acessar ofertas, simulações e propostas de crédito. | `handCoins` |
| Módulos | Marketplace | Acessar a compra de insumos, máquinas e serviços. | `shoppingBag` |
| Módulos | Armazém | Acessar estoque, unidades e movimentações de produtos. | `warehouse` |
| Financeiro | Carteira | Consultar saldo e informações financeiras da conta. | `wallet` |
| Financeiro | Pix | Enviar dinheiro por chave ou contato. | `zap` |
| Financeiro | Pagar / Pagar boleto | Pagar contas e boletos usando o código de pagamento. | `scanLine` |
| Financeiro | Transferir / Pagamentos | Mover valores entre contas e acessar operações de pagamento. | `arrowLeftRight` |
| Financeiro | Cobrar | Gerar uma cobrança Pix para receber um valor. | `handCoins` |
| Financeiro | Extrato / Transações | Consultar o histórico de entradas e saídas financeiras. | `receipt` |
| Financeiro | Cartões | Consultar e gerenciar cartões vinculados à conta. | `creditCard` |
| Financeiro | Limites | Consultar e ajustar limites financeiros disponíveis na interface. | `slidersHorizontal` |
| Financeiro | Open Finance | Representar o acesso a serviços de compartilhamento de dados financeiros. | `openFinance` |
| Financeiro | Autorizações | Acessar o contexto de autorização de operações financeiras. | `shieldCheck` |
| Crédito | Minhas Propostas | Acompanhar propostas de crédito e seus estados. | `fileText` |
| Crédito | Simular | Estimar condições de uma contratação de crédito. | `calculator` |
| Crédito | Contratos | Consultar os contratos de crédito. | `fileSignature` |
| Crédito | Custeio de safra | Representar financiamento das despesas de produção da safra. | `sprout` |
| Crédito | Investimento em máquinas | Representar crédito para aquisição de máquinas e equipamentos. | `tractor` |
| Crédito | CPR financeira | Representar a modalidade de crédito vinculada à Cédula de Produto Rural financeira. | `fileText` |
| Crédito | Consórcio agro | Representar aquisição planejada de bens para o agro por consórcio. | `users` |
| Crédito | Empréstimos e financiamentos | Acessar opções de crédito para necessidades de capital e investimento. | `handCoins` |
| Serviços | Seguros, consórcios e capitalização | Representar a categoria de proteção financeira e aquisição planejada. | `shieldCheck` |
| Marketplace | Categorias | Explorar produtos organizados por tipo. | `listOrdered` |
| Marketplace | Pedidos | Acompanhar compras realizadas e seu andamento. | `receipt` |
| Marketplace | Favoritos | Consultar produtos salvos para acessar depois. | `heart` |
| Armazém | Estoque | Consultar os itens e saldos armazenados. | `boxes` |
| Armazém | Movimentações | Consultar entradas e saídas de produtos. | `arrowLeftRight` |
| Armazém | Unidades | Consultar os locais de armazenamento e seus detalhes. | `warehouse` |
| Armazém | Relatórios | Acessar informações consolidadas do armazém. | `barChart3` |
| Catálogo de apps | Clima | Representar previsão do tempo localizada para a fazenda ou talhão. | `cloudSun` |
| Catálogo de apps | Cotações | Representar acompanhamento de preços de commodities agropecuárias. | `lineChart` |
| Catálogo de apps | Consultoria | Representar acesso a especialistas e orientação. | `headset` |
| Catálogo de apps | Seguros | Representar proteção da safra e do patrimônio. | `shieldCheck` |

## Conta e controles compartilhados

| Item | Mini resumo | Ícone atual |
|---|---|---|
| Informações pessoais | Consultar e atualizar os dados cadastrais do usuário. | `user` |
| Configurações da conta | Acessar preferências e opções do perfil. | `settings` |
| Notificações | Consultar avisos e atualizações. | `bell` |
| Tema / Modo GB | Alternar a aparência entre modo claro e escuro. | `moon` / `sun` |
| Conexão | Indicar ou simular disponibilidade de conexão. | `wifi` / `wifiOff` |
| Segurança | Representar opções de PIN, biometria e sessões. | `shieldCheck` |
| Ajuda / Central de ajuda | Acessar suporte e orientações de uso. | `helpCircle` |
| Atendimento por mensagem | Iniciar contato com o suporte por mensagem. | `messageCircle` |
| Sair | Encerrar a sessão atual. | `logOut` |
| Busca inteligente | Localizar funcionalidades e acessos do app. | `aiSearch` |
| Adicionar registro | Iniciar a inclusão de um novo registro ou item. | `plus` |
| Editar | Alterar informações de um registro existente. | `pencil` |
| Salvar | Confirmar e guardar as informações preenchidas. | `saveAll` |
| Exportar / Baixar | Obter um arquivo com dados ou registros. | `download` |
| Fotografar / Anexar foto | Capturar ou associar uma imagem ao registro. | `camera` |

## Referências para implementação

- `apps/mobile/lib/modules/fazendas/functional_catalog.dart`: nomes, IDs e objetivos das 55 funcionalidades.
- `apps/mobile/lib/modules/fazendas/group_icons.dart`: ícones por grupo e exceções por funcionalidade.
- `apps/mobile/lib/ui/app_icon.dart`: definições de `AppIcons`, Hugeicons e vetores próprios.
- `apps/mobile/lib/shell/module_config.dart`: módulos, abas e entradas de menu.
- `apps/mobile/lib/modules/fazendas/screens/fazendas_home.dart` e `busca_global_screen.dart`: atalhos e variações de ícones.
- `apps/mobile/lib/modules/hub/mocks/hub_apps.dart`: catálogo de apps e serviços.

Para cada novo desenho, registrar o nome do arquivo e o ID da funcionalidade correspondente. Itens repetidos podem compartilhar o mesmo ícone quando comunicarem o mesmo conceito.