// Template customizado do bootstrap do Flutter Web — o `flutter build`/
// `flutter run` gera build/web/flutter_bootstrap.js a partir DESTE arquivo
// em vez do template padrão do SDK, substituindo os dois marcadores abaixo.
//
// A única customização real é o "hostElement" passado pra initializeEngine:
// por padrão o Flutter Web assume a viewport inteira via position: fixed,
// ignorando qualquer container — sem isso a moldura de celular do
// index.html (div com id flutter-target) não teria efeito nenhum.
//
// Atenção: os dois marcadores de substituição abaixo não podem aparecer em
// nenhum outro lugar deste arquivo (nem em comentários) — a substituição é
// um replace de texto literal, não um template engine de verdade.
{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.querySelector('#flutter-target'),
    });
    await appRunner.runApp();
  },
});
