# Estimativa de Consumo — Migração Flutter no Plano Claude Pro

**Objetivo:** dimensionar a execução da esteira do [PLANO-MIGRACAO-FLUTTER.md](PLANO-MIGRACAO-FLUTTER.md)
em **tokens e janelas de uso do plano Claude Pro**, para planejar o calendário real da migração.

> **Como ler estes números:** estimativas de ordem de grandeza, calibradas pelo próprio histórico
> deste repo (protótipo React de ~10,3k LOC construído em <2 semanas no mesmo modelo de trabalho).
> Os limites de assinatura da Anthropic são medidos em **prompts/horas por janela de 5h + teto
> semanal**, variam com o tamanho do contexto e são ajustados periodicamente — trate as conversões
> como planejamento, não como garantia. Confira o consumo real em claude.ai/settings/usage.

---

## 1. Premissas de cálculo

| Premissa | Valor adotado |
|---|---|
| Código Dart gerado (Flutter é ~1,3–1,5× mais verboso que TSX) | ~14–16k LOC |
| Tokens de saída por LOC (geração + ajustes) | ~10–15 tokens |
| Multiplicador de iteração (leitura do fonte React, verificação, correções) | 3–5× sobre a saída |
| Modelo no Pro | Sonnet (suficiente: as decisões de design já estão tomadas — o trabalho é tradução guiada) |
| Janela Pro | ~10–40 prompts por janela de 5h (varia com contexto) + teto semanal |
| Prompt "pesado" de codegen | lote de 3–6 widgets ou 4–8 telas por prompt, com verificação em lote |

## 2. Orçamento de tokens por fase

| Fase | Saída (geração) | Total processado (entrada+saída, com iterações) | Janelas de 5h (Pro) |
|---|---|---|---|
| F0 Fundação (setup, assets, ADRs) | ~10–20k | ~100–200k | 0,5 |
| F1 Tokens → tema Dart | ~15–25k | ~150–300k | 0,5–1 |
| F2 Catálogo (43 widgets + galeria) | ~90–130k | ~1,2–1,8M | 3–4 |
| F3 Shell + navegação | ~30–50k | ~400–600k | 1–1,5 |
| F4 Módulos (67 telas) | ~150–220k | ~1,5–2,5M | 4–5 |
| Polimento (animações, charts, fidelidade) | ~30–60k | ~400–700k | 1–2 |
| **Total** | **~330–500k** | **~3,8–6M** | **~10–14 janelas** |

## 3. Conversão em calendário

| Cenário | Ritmo sustentável | Calendário até a paridade |
|---|---|---|
| **Pro** (1 janela de 5h/dia útil, respeitando teto semanal) | ~5 janelas/semana | **~2–3 semanas** |
| Pro intensivo (2 janelas/dia, risco de esbarrar no teto semanal) | ~7–8 janelas/semana | ~1,5–2 semanas |
| Max 5× (referência, se o prazo apertar) | sem gargalo prático p/ este volume | ~1–1,5 semana (os 6–8 dias do plano) |

**Leitura executiva:** o trabalho em si continua sendo ~6–8 dias de sessão; **no Pro, o teto de
janelas é o que estica o calendário para 2–3 semanas**. O plano dá conta da migração inteira —
o custo é ritmo, não viabilidade.

## 4. Como economizar tokens na prática (encurta o calendário no Pro)

1. **Batching agressivo:** 1 prompt = 1 lote da esteira (ex.: "gere o lote F2.2 completo"), nunca
   1 prompt por widget/tela. É a alavanca nº 1 — corta o nº de prompts por 4–6×.
2. **RTK já instalado:** o proxy corta 60–90% dos tokens de saída de comandos dev (git, build,
   test) — manter os hooks ativos durante toda a migração.
3. **Sessão nova por fase:** encerrar a sessão ao fechar cada gate (DoD) — evita arrastar contexto
   morto (re-leitura do histórico consome janela).
4. **Verificação em lote:** validar a galeria de widgets 1× por lote no emulador/web, não widget a
   widget; goldens/screenshots só nos críticos.
5. **Fonte como contrato, não como leitura contínua:** extrair 1× um "mapa de props" do catálogo
   React (arquivo curto) e referenciá-lo, em vez de reler os .tsx a cada lote.
6. **Horário de reset:** janelas de 5h renovam por relógio — alinhar os lotes pesados (F2/F4) ao
   início de janela.

## 5. Risco e plano B

| Risco | Sinal | Mitigação |
|---|---|---|
| Teto semanal do Pro no meio da F4 | aviso de limite na sessão | pausar no gate da fase (a esteira foi desenhada para parar limpo entre fases) |
| Contexto grande derrubando prompts/janela | janelas rendendo <10 prompts | aplicar §4.3 e §4.5 (sessão limpa + mapa de props) |
| Prazo de handoff fixo | calendário Pro não fecha | 1 mês de Max 5× só durante a migração, voltando ao Pro depois |
