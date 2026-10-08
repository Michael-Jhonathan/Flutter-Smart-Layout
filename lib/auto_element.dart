import 'package:flutter/material.dart';

/// Largura de referencia padrao usada quando [AutoElement.referenceWidth] nao e informado
/// e [kGlobalReferenceWidth] nao esta definido.
///
/// Corresponde a largura da tela em que voce esta desenhando/desenvolvendo.
/// Neste ponto (scale = 1.0), todos os valores de fonte, padding e dimensao
/// serao exibidos exatamente como escritos no codigo.
///
/// Exemplos de valores comuns:
///   1280 → notebook comum
///   1440 → monitor padrao
///   1920 → Full HD
const double kDefaultReferenceWidth = 1000.0;

/// Override global de largura de referencia.
///
/// Quando definido (nao-null), tem PRIORIDADE ABSOLUTA sobre qualquer
/// [AutoElement.referenceWidth] individual em toda a aplicacao.
///
/// Use no inicio do app (ex: dentro do main() ou do initState da raiz)
/// para padronizar a escala de todo o projeto com um unico valor:
///
/// ```dart
/// void main() {
///   kGlobalReferenceWidth = 1920; // toda a app usa Full HD como referencia
///   runApp(const MyApp());
/// }
/// ```
///
/// Para desativar e voltar ao comportamento por-widget, atribua null:
/// ```dart
/// kGlobalReferenceWidth = null;
/// ```
double? kGlobalReferenceWidth;

/// Calcula o fator de escala dado a largura disponivel e a largura de referencia.
///
/// Regras:
/// - Abaixo de [referenceWidth]: aplica um "amortecedor de encolhimento" para que
///   textos muito pequenos ainda permaneçam legiveis. O texto nao encolhe na mesma
///   proporcao que a tela.
/// - Acima de [referenceWidth]: escala LINEAR e continua, sem nenhum limite superior.
///   Se a tela dobrar, o conteudo dobra. Sem limite para 4K, 8K ou qualquer resolucao.
double computeAutoScale(double availableWidth, {double referenceWidth = kDefaultReferenceWidth}) {
  // O override global tem prioridade absoluta sobre o referenceWidth por-widget.
  final double effectiveReference = kGlobalReferenceWidth ?? referenceWidth;
  final double rawScale = availableWidth / effectiveReference;

  if (rawScale < 1.0) {
    // MOBILE / TABLET: "Amortecedor de Encolhimento"
    // O texto diminui suavemente para manter a leitura confortavel.
    // Formula: combinacao de um piso (0.75) com variacao proporcional suave.
    return 0.75 + (rawScale * 0.25);
  }

  // TELAS GRANDES (Desktop, 4K, 8K, etc.): escala LINEAR pura.
  // Se a tela dobrar em relacao a referencia, o conteudo dobra.
  // Sem limites artificiais, sem travamento em qualquer resolucao.
  return rawScale;
}

/// Widget que aplica escala dinamica a todos os seus filhos.
///
/// Utiliza [MediaQuery.textScaler] e [IconTheme] para que fontes e icones
/// crescam ou encolham organicamente sem precisar de Transform.scale,
/// garantindo que o layout em volta reaja corretamente ao novo tamanho.
///
/// O parametro [referenceWidth] define a largura em que os seus valores de
/// fonte e padding ficam exatamente como escritos (scale = 1.0).
/// Configure-o para a largura da tela em que voce esta desenvolvendo.
///
/// Exemplo:
/// ```dart
/// // Desenvolvendo num monitor Full HD (1920px):
/// AutoElement(
///   referenceWidth: 1920,
///   padding: EdgeInsets.all(32),
///   child: Column(
///     children: [
///       Text('Titulo', style: TextStyle(fontSize: 48)),
///       Text('Subtitulo', style: TextStyle(fontSize: 24)),
///     ],
///   ),
/// )
/// ```
class AutoElement extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  /// Largura de referencia para calculo de escala.
  ///
  /// Defina como a largura da tela em que voce esta desenvolvendo/desenhando
  /// este bloco. Nesta largura exata, scale = 1.0 e nenhuma alteracao e feita.
  /// Em telas maiores, o conteudo cresce proporcionalmente.
  /// Em telas menores, o conteudo encolhe suavemente.
  ///
  /// Se nao informado, usa [kDefaultReferenceWidth] (1000px).
  final double referenceWidth;

  const AutoElement({
    super.key,
    required this.child,
    this.referenceWidth = kDefaultReferenceWidth,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Usa a largura real disponivel para este widget (constraints.maxWidth),
        // nao a largura da tela inteira. Isso garante escala correta dentro de
        // layouts divididos como paineis lado a lado ou grids com colunas.
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final double scale = computeAutoScale(availableWidth, referenceWidth: referenceWidth);

        return Padding(
          padding: margin != null ? margin! * scale : EdgeInsets.zero,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Escala todos os textos dentro deste componente
              textScaler: TextScaler.linear(scale),
            ),
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                // Escala todos os icones nativamente
                size: (IconTheme.of(context).size ?? 24.0) * scale,
              ),
              child: Builder(
                builder: (innerContext) {
                  Widget scaledContent = child;

                  if (padding != null) {
                    scaledContent = Padding(
                      padding: padding! * scale,
                      child: scaledContent,
                    );
                  }

                  if (width != null || height != null) {
                    scaledContent = SizedBox(
                      width: width != null ? width! * scale : null,
                      height: height != null ? height! * scale : null,
                      child: scaledContent,
                    );
                  }

                  if (backgroundColor != null) {
                    scaledContent = DecoratedBox(
                      decoration: BoxDecoration(color: backgroundColor),
                      child: scaledContent,
                    );
                  }

                  return AutoScale(
                    scale: scale,
                    child: scaledContent,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// FERRAMENTAS PARA ESCALAR WIDGETS MANUAIS
// -----------------------------------------------------------------------------

/// Fornece a escala atual calculada pelo [AutoElement] pai para os filhos.
class AutoScale extends InheritedWidget {
  final double scale;

  const AutoScale({
    super.key,
    required this.scale,
    required super.child,
  });

  /// Retorna o fator de escala do [AutoElement] mais proximo.
  /// Se nao houver nenhum na arvore, retorna 1.0 (sem escala).
  static double of(BuildContext context) {
    final AutoScale? inherited =
        context.dependOnInheritedWidgetOfExactType<AutoScale>();
    return inherited?.scale ?? 1.0;
  }

  @override
  bool updateShouldNotify(AutoScale oldWidget) => scale != oldWidget.scale;
}

/// Um espacador (SizedBox quadrado) que escala automaticamente junto com o [AutoElement].
/// 
/// Em vez de usar `SizedBox(height: 24)`, use `AutoGap(24)`.
/// O espaco crescera ou encolhera proporcionalmente a tela.
class AutoGap extends StatelessWidget {
  final double size;

  const AutoGap(this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    final double scale = AutoScale.of(context);
    return SizedBox(
      width: size * scale,
      height: size * scale,
    );
  }
}

/// Um SizedBox que escala largura e altura automaticamente junto com o [AutoElement].
/// 
/// Substitui o uso de `SizedBox(width: x, height: y)` quando voce precisa de
/// caixas exatas que mudem de tamanho dinamicamente na tela.
class AutoBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const AutoBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = AutoScale.of(context);
    return SizedBox(
      width: width != null ? width! * scale : null,
      height: height != null ? height! * scale : null,
      child: child,
    );
  }
}


