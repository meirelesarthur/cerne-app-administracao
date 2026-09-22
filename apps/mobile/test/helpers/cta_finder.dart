import 'package:flutter_test/flutter_test.dart';

/// Localiza o botão de uma [AppActionBar] pelo rótulo em caixa natural.
///
/// A barra de ação do padrão global renderiza o rótulo em caixa alta — é o
/// único lugar do sistema onde a referência do Figma pede isso (`PRÓXIMO`,
/// `CANCELAR`, `FINALIZAR TRATO`, nós `54349:2075` e `54349:2096`). O rótulo
/// **acessível** continua em caixa natural, porque um leitor de tela soletra
/// palavras totalmente maiúsculas.
///
/// Este finder existe para que a suíte continue escrevendo o rótulo como ele é
/// no domínio ("Revisar") em vez de espalhar `'REVISAR'` por vários arquivos: a
/// caixa é decisão de apresentação e mora num lugar só, aqui e no componente.
Finder findCta(String label) => find.text(label.toUpperCase());
