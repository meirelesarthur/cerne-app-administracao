# Pesquisa — Squircle (superellipse / continuous corners)

> Documento de apoio da leva "squircle". Ver [`00-ESTEIRA-SQUIRCLE.md`](00-ESTEIRA-SQUIRCLE.md)
> para o plano de execução derivado desta pesquisa.

## 1. O que é, matematicamente

Squircle é um caso particular de **superellipse** (curva de Lamé): `|x/a|ⁿ + |y/b|ⁿ = 1`. Com
semi-eixos iguais (`a = b`) e expoente `n = 4`, a equação vira `x⁴ + y⁴ = r⁴` — essa é a forma
"squircle" propriamente dita, algo entre um quadrado e um círculo.

A diferença que importa para UI não é estética abstrata, é **continuidade de curvatura**:

- Num retângulo com cantos arredondados comum (`border-radius` / `BorderRadius.circular`), a
  aresta reta encontra o arco circular do canto com um salto instantâneo de curvatura — de zero
  (reta) para um valor fixo (arco). Isso é continuidade **G¹** (tangente contínua, curvatura não).
- Numa squircle/superellipse, a transição é suave — a curvatura cresce e decresce
  continuamente, sem salto. Isso é continuidade **G²**. O olho humano percebe reflexos de luz e
  bordas como "mais orgânicos" nesse tipo de curva; é o mesmo princípio usado em lentes e no
  desenho de estradas (curvas de transição/clothoid) para evitar mudanças bruscas.

Fontes: [johndcook.com — Squircles, Apple design, and curvature](https://www.johndcook.com/blog/2018/02/13/squircle-curvature/),
[squircle.js.org — The Squircle Formula](https://squircle.js.org/blog/math-behind-squircles),
[grida.co — Superellipse Mathematical Reference](https://grida.co/docs/math/superellipse).

## 2. Como a Apple e o Figma parametrizam isso

Ninguém usa squircle "puro" (`n = 4`) diretamente em produto — usa-se uma **mistura** entre o
arco circular tradicional e a superellipse, controlada por um parâmetro de suavização:

- **iOS ("continuous corners")**: usa uma superellipse com suavização em torno de **60%**
  (`cornerSmoothing ≈ 0.6`). No ícone de app do iOS especificamente, o raio de canto é ~22,37%
  da largura do ícone combinado com essa suavização — é a mesma forma usada nos bezéis de
  hardware da Apple.
- **Figma ("corner smoothing")**: expõe um slider de 0% a 100% no painel de propriedades. Em 0%
  é um `border-radius` circular padrão; conforme sobe, a forma vai "puxando" para a superellipse.
  O algoritmo aproxima a curva via **segmentos de Bézier cúbicos** (uma curva de Lamé não tem
  representação exata em Bézier, mas com segmentos suficientes a diferença cai a uma fração de
  pixel). O valor default do Figma (~0,6) foi calibrado para bater com o que a Apple usa.

Fontes: [Figma Blog — Desperately seeking squircles](https://www.figma.com/blog/desperately-seeking-squircles/),
[squircle.js.org — Figma Corner Smoothing on the Web](https://squircle.js.org/blog/figma-corner-smoothing-on-the-web),
[Squircle.js — How Apple Uses Squircles in iOS Design](https://squircle.js.org/blog/squircles-in-apple-design).

### Relação raio × suavização × tamanho

- Suavização alta + raio pequeno → efeito sutil, quase imperceptível vs. arco circular comum.
- Suavização alta + raio grande → os lados vão "achatando" progressivamente perto dos cantos,
  mantendo a curva; no limite (raio = metade do lado menor) a forma vira um **stadium** (cápsula
  — dois semicírculos unidos por retas), momento em que squircle e círculo convergem para a
  mesma coisa porque não sobra mais "lado reto" para suavizar.
- **Implicação direta para este projeto**: elementos com `AppRadius.full` (pílula — botões,
  badges, toggle, tabs) **já são stadium**. Squircle não muda nada visualmente nesses casos — o
  esforço de aplicar lá é desperdiçado. Só vale a pena nos tokens que geram um retângulo
  arredondado "de verdade" (`sm` até `xl4`/`modal`).

## 3. Suporte nativo na Web (CSS)

Existe uma proposta de propriedade CSS `corner-shape` (valores `round`, `squircle`,
`superellipse(K)`, entre outros) rodando em spec ativa:

- `corner-shape: squircle` é atalho para `superellipse(2)`.
- Suporte real, em ago/2026: **só Chromium (Chrome/Edge 139+)**, sem cronograma público de
  Firefox/Safari — cobertura global de ~65-66%.
- Degrada graciosamente: navegador sem suporte simplesmente ignora a propriedade e volta ao
  `border-radius` comum.

Isso **não é relevante para este projeto** (Flutter renderiza no `<canvas>`/WebGL, não usa CSS
para forma de widget), mas confirma que a indústria inteira está convergindo para esse padrão
visual agora — inclusive no nível de spec do browser.

Fontes: [developer.chrome.com — The corner cases of implementing CSS corner-shape](https://developer.chrome.com/blog/implementing-corner-shape),
[squircle.js.org — Squircles in CSS](https://squircle.js.org/blog/squircles-in-css).

## 4. Opções de implementação em Flutter

| Opção | Origem | Veredito | Por quê |
|---|---|---|---|
| **`RoundedSuperellipseBorder`** | Flutter SDK 3.32+ (mai/2025) | **Recomendado** | Único shape com implementação nativa no engine (`Canvas.drawRSuperellipse`/`clipRSuperellipse`, `Path.addRSuperellipse`); sem dependência nova; mantém integridade em qualquer raio/aspect ratio; suporta `strokeAlign`, `copyWith`, `lerp` (interpolação em animações). |
| `figma_squircle` (pacote) | Comunidade (MIT, ~35k downloads) | Descartado como padrão | Geometria **degenera para arco circular comum** quando o raio passa de ~0,5× o raio de stadium — exatamente a faixa de raio grande onde a diferença visual mais importaria. Útil só como *fallback* temporário se a Onda 0 (abaixo) reprovar o nativo. |
| `ContinuousRectangleBorder` | Flutter SDK (antigo) | **Não usar** | Produz deformação visual conhecida como "TIE-fighter" em raios altos; `BorderSide`/`strokeAlign` sempre centralizado, ignora configuração. |
| `smooth_corner` (pacote) | Comunidade | Descartado | Sem `lerp` animado; mesma limitação de degenerar em raios altos. |

Fontes: [pub.dev/packages/figma_squircle](https://pub.dev/packages/figma_squircle),
[github.com/rydmike/squircle_study](https://github.com/rydmike/squircle_study) (estudo comparativo
visual das opções acima),
[api.flutter.dev — RoundedSuperellipseBorder](https://api.flutter.dev/flutter/painting/RoundedSuperellipseBorder-class.html),
[Flutter 3.32.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.32.0)
(PR [#166303](https://github.com/flutter/flutter/pull/166303) — `RoundedSuperellipseBorder`
aplicado primeiro ao `CupertinoActionSheet`).

### ⚠️ Risco não resolvido pela pesquisa: paridade em Flutter Web

As fontes secundárias **divergem**: uma indica que builds Web caem para retângulo arredondado
comum (sem squircle real) porque o primitivo teria sido validado só para engine mobile/desktop;
outra, mais recente, não menciona nenhuma restrição de plataforma e trata o primitivo como
suportado onde o Impeller/Skia roda — o que hoje inclui Web. A documentação oficial da classe
não afirma nem nega restrição de plataforma.

Este projeto **é Flutter Web** (`npm run dev` → Chrome; deploy final é Cloudflare Workers Static
Assets). Se o primitivo cair para fallback simples no build web de produção, o esforço de migrar
121 ocorrências não entrega o efeito visual pretendido. **Por isso a pesquisa não conclui essa
resposta — ela vira o gate bloqueante da Onda 0 da esteira**: build real deste projeto
(`flutter build web`, Flutter 3.44.6) verificado visualmente antes de qualquer migração em
massa.

## 5. Impacto em performance

- `RoundedSuperellipseBorder` é a única forma com **implementação GPU nativa** no SDK — a
  expectativa da própria comunidade Flutter é que não introduza degradação perceptível (ao
  contrário de soluções via `Path` customizado com Bézier, que exigem `clipPath`/`saveLayer` e
  são mais caras que um `clipRRect` simples).
- Nenhuma fonte consultada apresentou benchmark quantitativo próprio — a recomendação de todas é
  "validar no caso de uso real antes de rollout em escala". A Onda 0 cobre isso também (tela com
  grid denso de cards, ex. grupo de funcionalidades do módulo Fazendas).

## 6. Impacto nos testes visuais (goldens)

O projeto já mantém goldens em `apps/mobile/test/golden/goldens/ci/*.png` (variante CI) e
`goldens/windows/*.png` (variante local, já com divergência conhecida de fonte entre
Linux/Windows — ver commit `5d3057b`). Trocar a forma de canto de qualquer componente muda o
pixel do golden **por definição**, não é regressão — precisa de rebaseline deliberado por lote,
revisado visualmente (não só re-gerado às cegas).

## 7. Lacuna nos tokens de design

Hoje `design/tokens.ts` (fonte única, Lei 3/5) só exporta um **número de raio** (`AppRadius.*`).
Não existe conceito de "suavização" ou "forma" no pipeline DTCG. Introduzir squircle exige:

1. Um novo grupo de token (ex. `shape.smoothing`) com o valor de suavização (recomendação
   inicial: `0.6`, calibrado como Apple/Figma) — nunca um literal solto em Dart.
2. Um **único** helper compartilhado em `apps/mobile/lib/ui/` que decide "todo raio > 0 e < full
   vira squircle com essa suavização" — para que as 121 ocorrências espalhadas hoje em
   `BorderRadius.circular(AppRadius.*)` convirjam para uma única fonte de decisão (Lei 1/2:
   component-first, fonte única), em vez de cada arquivo decidir sozinho se usa
   `RoundedSuperellipseBorder` ou não.

## Fontes consultadas

- [squircle.js.org — The Squircle Formula: Superellipse Math Explained](https://squircle.js.org/blog/math-behind-squircles)
- [squircle.js.org — How Apple Uses Squircles in iOS Design](https://squircle.js.org/blog/squircles-in-apple-design)
- [squircle.js.org — Squircles in CSS: corner-shape, superellipse()](https://squircle.js.org/blog/squircles-in-css)
- [squircle.js.org — Figma Corner Smoothing on the Web](https://squircle.js.org/blog/figma-corner-smoothing-on-the-web)
- [Figma Blog — Desperately seeking squircles](https://www.figma.com/blog/desperately-seeking-squircles/)
- [johndcook.com — Squircles, Apple design, and curvature](https://www.johndcook.com/blog/2018/02/13/squircle-curvature/)
- [grida.co — Superellipse Mathematical Reference](https://grida.co/docs/math/superellipse)
- [developer.chrome.com — The corner cases of implementing CSS corner-shape in Blink](https://developer.chrome.com/blog/implementing-corner-shape)
- [pub.dev — figma_squircle](https://pub.dev/packages/figma_squircle)
- [github.com/rydmike/squircle_study](https://github.com/rydmike/squircle_study)
- [api.flutter.dev — RoundedSuperellipseBorder class](https://api.flutter.dev/flutter/painting/RoundedSuperellipseBorder-class.html)
- [Flutter 3.32.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.32.0)
