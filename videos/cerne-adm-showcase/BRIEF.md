---
workflow: general-video
flow: companion
storyboard: yes
message: "Um só app organiza toda a decisão da fazenda"
destination: site-institucional
aspect: 1920x1080
language: pt-BR
audience: "produtores rurais e gestores do agronegócio, decisores B2B"
length: 45s
angle: product-tour
style_preset: apple-studio-white
---

## Intent

Vídeo showcase estilo lançamento Apple do CERNE ADM: fundo branco de estúdio,
tipografia limpa, telas reais do app flutuando como objetos sobre o fundo.
Tom confiante e precisas, sem narração falada — cortes seguem o ritmo da
música/tipografia. Mostra a experiência de entrar no app, ver a decisão em
gráficos, navegar entre os módulos do superapp, com foco total em Fazendas
(mais tempo de tela e mais detalhe que os demais módulos).

## Assets

- Screens reais capturados do app rodando localmente (`npm run dev`, Flutter
  Web, build/web servido em http://localhost:5173) — login, dashboard
  "Visão geral" com gráfico "Receita x custo", barra de navegação com 5
  módulos (Início, Fazendas, Bank, Crédito, Marketplace/Armazém), tela de
  Fazendas.

## Customizations

- Zoom / punch-in na animação da barra de navegação ao trocar de módulo
  (o "multiapps" pedido pelo usuário).
- Liberdade total de enquadramento, copy e transições — usuário não fixou
  frases nem cortes específicos.

## Notes

- Produto é 100% frontend/protótipo (ver CLAUDE.md do repo) — nenhuma
  informação sensível real deve aparecer nas capturas de tela.
- Foco total em Fazendas: essa seção recebe a maior fatia do tempo entre os
  módulos.
- Fundo branco de estúdio tipo keynote Apple — nunca usar o fundo de café
  (imagem de fazenda) do login como fundo do vídeo; ele deve ser cropado
  para dentro do "device frame" da tela capturada, não vazar para o vídeo.
