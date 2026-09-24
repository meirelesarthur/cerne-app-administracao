---
format: 1920x1080
duration: 45s
message: "Um só app organiza toda a decisão da fazenda"
arc: Brand_Outro-Hook → Product_Intro (login) → Key_Feature (decisão) → Product_Intro (multiapp) → Key_Feature (tour) → Benefits (Fazendas) → CTA
audience: "produtores rurais e gestores do agronegócio, decisores B2B"
mode: collaborative
---

## Frame 1 — Abertura de marca

- scene: Wordmark CERNE se monta no centro de um fundo branco de estúdio
- duration: 3.5s
- transition_in: cut
- status: outline
- extra.blueprint: logo-assemble-lockup

Fundo branco liso (leve textura de estúdio). O símbolo da folha CERNE e o
wordmark "CERNE" se montam a partir de partículas/elementos soltos e
resolvem no lockup central. Abaixo, uma linha fina de assinatura sobe em
fade: **"O agro inteiro em um só app."** Sem trilha falada — corte no beat
da música.

## Frame 2 — Login fácil

- scene: iPhone flutuante mostra a tela de login; um toque abre o app
- duration: 6s
- transition_in: crossfade
- status: outline
- extra.blueprint: device-surface-showcase (mecânica: static tour → tap)

Câmera de estúdio: um device frame (moldura de celular fina, sem marca)
flutua levemente sobre o branco, com sombra suave no chão. Dentro dele, a
tela real de login do CERNE ADM (campo de e-mail/senha, botão "ENTRAR").
Um cursor/toque único aparece, encosta em "ENTRAR" — a partícula de
transição do app real dispara e o app abre. Texto de apoio lateral:
**"Acesso simples, em um toque."** Enquadramento: plano fechado no device,
levemente inclinado em 3D (perspectiva sutil, não flat).

## Frame 3 — Gráficos de decisão

- scene: Push-in no dashboard "Visão geral"; o gráfico Receita × Custo se desenha e um número sobe
- duration: 6.5s
- transition_in: crossfade
- status: outline
- extra.blueprint: dataviz-countup

Corte para o dashboard real (tela "Visão geral", card "Receita x custo").
Câmera empurra através da tela até o gráfico, que se autodesenha
(`svg-path-draw`) enquanto um KPI lateral conta (`counting-dynamic-scale`)
até o valor final. Texto: **"Decisão com números, não com achismo."**
Mantém o device frame nas bordas para nunca perder o contexto de "é o
app real".

## Frame 4 — Multiapp: um só lugar

- scene: Zoom/punch-in na barra de navegação inferior enquanto o cursor troca de módulo
- duration: 6s
- transition_in: crossfade
- status: outline
- extra.blueprint: cursor-ui-demo (câmera com coordinate-target-zoom na nav bar)

A câmera recua para mostrar o app inteiro, depois um punch-in centra a
barra de navegação inferior (5 ícones: Início, Fazendas, Bank, Crédito,
Marketplace). Um cursor único toca cada ícone em sequência rápida; a cada
toque, o ícone ativo faz o pill verde deslizar e a tela muda de conteúdo
por trás (crossfade rápido, sem recarregar a cena toda). Texto:
**"Fazendas, banco, crédito e mercado — um só app."**

## Frame 5 — Passada pelos módulos

- scene: Device fixo no centro, telas trocam em corte seco a cada módulo secundário
- duration: 7s
- transition_in: cut
- status: outline
- extra.blueprint: fixed-anchor-cycle

O device frame fica PARADO no centro (âncora fixa); apenas a tela interna
troca em cortes secos e rápidos (~1s cada) passando por Início, Bank,
Crédito e Marketplace/Armazém — cada troca acompanhada por um rótulo
minúsculo no rodapé nomeando o módulo. Ritmo acelerando levemente até a
última troca, que resolve parada — preparando a entrada em Fazendas.

## Frame 6 — Fazendas (foco total)

- scene: Tour mais longo e detalhado da tela de Fazendas — visão geral, painel, gráfico
- duration: 12s
- transition_in: crossfade
- status: outline
- extra.blueprint: device-surface-showcase (stepwise-flow) + camera-journey (sub-shape B, push final)

O coração do vídeo. A última troca do Frame 5 resolve em Fazendas com um
leve zoom-in de chegada. Aqui o app respira mais: mostra a "Visão geral"
da fazenda, o card de receita x custo em detalhe, e um painel/OS abrindo
(`anchored-layout-expand`). Câmera com pequenos pushes motivados entre
cada estado (não corte seco). Texto de apoio, discreto, no canto:
**"Fazendas — o centro da operação."** Esta cena recebe o dobro de tempo
de tela de qualquer outro módulo, conforme pedido.

## Frame 7 — Encerramento

- scene: App recua e se junta ao wordmark CERNE num card final branco
- duration: 4s
- transition_in: crossfade
- status: outline
- extra.blueprint: titlecard-reveal

O device recua suavemente e desaparece (fade + scale down); no branco
limpo, o wordmark CERNE reaparece junto da assinatura final:
**"CERNE — Administração inteira do agro, num só lugar."** Hold final de
1.5s no logo, sem CTA de clique (é um showcase institucional, não um
anúncio direto).
