# ADR 0003 — Troca de `lucide_icons` por `lucide_icons_flutter`

**Status:** aceito · 2026-07-19

## Contexto

O ADR 0001 escolheu `lucide_icons` (^0.257.0) para espelhar `lucide-react`. Durante o F2 (catálogo
de widgets), `flutter test` passou a falhar na compilação de qualquer arquivo que importasse o
pacote:

```
Error: The class 'IconData' can't be extended outside of its library because it's a final class.
class LucideIconData extends IconData {
```

`flutter analyze` não acusava o erro (o analisador estático não aplica a mesma checagem de
modificador de classe que o compilador do `flutter test`), então o problema só apareceu ao rodar os
testes — depois que 32 componentes já usavam o pacote.

## Causa raiz

`lucide_icons` 0.257.0 (publicado há ~3 anos, sem atualização desde então) declara
`class LucideIconData extends IconData`. Versões recentes do Flutter (SDK 3.44.6 instalado, ver ADR
0001) marcaram `IconData` como `final class`, proibindo herança fora do pacote `flutter/material`.
Não há versão mais nova de `lucide_icons` no pub.dev que corrija isso.

## Decisão

Trocado para `lucide_icons_flutter` (^3.1.15, publicado há poucos dias — mantido ativamente). Esse
pacote usa `const IconData(...)` diretamente (sem subclasse), compatível com o modificador `final`.

- **Import:** `package:lucide_icons_flutter/lucide_icons.dart` (antes: `package:lucide_icons/lucide_icons.dart`).
- **Classe e nomes de ícone:** idênticos (`LucideIcons.xxx`, mesmo camelCase) — troca é apenas no
  caminho do import, sem alterar nenhuma linha de código que usa `LucideIcons`.
- Verificados manualmente todos os ~24 ícones em uso no catálogo (`arrowRight`, `check`, `landmark`,
  `eye`, `eyeOff`, `wallet`, `send`, `qrCode`, `arrowDownLeft`, `arrowUpRight`, `alertCircle`,
  `chevronDown`, `search`, `uploadCloud`, `fileCheck2`, `minus`, `plus`, `sprout`, `bell`, `logOut`,
  `settings`, `shield`, `user`, `x`) — todos existem com o mesmo nome no novo pacote.

## Consequências

- Nenhuma mudança de API nos 19 arquivos de `lib/ui/`/`test/ui/` que usam ícones — apenas o import.
- `flutter analyze` limpo não é suficiente para pegar esse tipo de incompatibilidade; **`flutter
  test` (ou `flutter build`) deve rodar antes de qualquer commit que adicione uma dependência nova**,
  não só `analyze`.
- Se o pacote `lucide_icons` original for atualizado no futuro corrigindo isso, não há motivo para
  reverter — `lucide_icons_flutter` está mais ativo.
