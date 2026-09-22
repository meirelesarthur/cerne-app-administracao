<p align="center">
  <img src="assets/images/Logo.svg" alt="GB CERNE" width="200" />
</p>

# GB CERNE ADM — app Flutter

Código-fonte do app (Flutter 3.44.6 + Dart 3, Riverpod, go_router, Widgetbook). Para a descrição de
funcionalidades e fluxos do produto, veja o [README na raiz do repositório](../../README.md).

## Comandos locais

```bash
flutter pub get
flutter run -d chrome     # roda o app
flutter analyze --fatal-infos
flutter test
```

Estrutura principal em `lib/`: `design/` (temas e tokens gerados), `ui/` (catálogo component-first),
`router/` (rotas e política de acesso), `shell/` (shell global e sessão demonstrativa),
`modules/` (Início, Fazendas, Bank, Crédito, Marketplace, Armazém).
