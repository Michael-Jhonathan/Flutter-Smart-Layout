import 'package:flutter/material.dart';
import 'smart_animated_wrap.dart';
import 'responsive_collapse.dart';
import 'auto_element.dart';

// =============================================================================
// RESPONSIVE BOX — Layout responsivo standalone
// -----------------------------------------------------------------------------
// Como usar: copie este arquivo para o seu projeto e importe com:
//   import 'responsive_box.dart';
//
// Nenhuma dependencia externa necessaria.
// =============================================================================

// -----------------------------------------------------------------------------
// ENUMS E TIPOS
// -----------------------------------------------------------------------------

/// Define como os filhos serao organizados dentro do ResponsiveBox.
enum ResponsiveLayoutMode { row, column, stack }

/// Define o alinhamento de forma simplificada e unificada.
/// Pode ser usado globalmente para ambos os eixos ou separadamente usando Records.
enum SmartAlign {
  start,
  center,
  end,
  spaceBetween,
  spaceAround,
  spaceEvenly,
  stretch,
}

enum ResponsiveCollapsePosition { start, center, end }

// -----------------------------------------------------------------------------
// RESPONSIVE VALUE — valor que muda por breakpoint
// -----------------------------------------------------------------------------

/// Encapsula um valor que pode variar entre mobile, tablet e desktop.
///
/// Exemplo:
/// ```dart
/// final colunas = ResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 4);
/// // Dentro de um LayoutBuilder:
/// int n = colunas.getValue(constraints);
/// ```
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Retorna o valor correto baseado nas constraints do widget pai.
  T getValue(BoxConstraints constraints) {
    if (constraints.maxWidth >= 1200 && desktop != null) return desktop!;
    if (constraints.maxWidth >= 600 && tablet != null) return tablet!;
    return mobile;
  }
}

// -----------------------------------------------------------------------------
// UNIVERSAL RESPONSIVE VALUE BUILDER — builder por breakpoint
// -----------------------------------------------------------------------------

/// Widget que reconstroi com o valor certo para cada tamanho de tela.
///
/// Exemplo:
/// ```dart
/// UniversalResponsiveValueBuilder<int>(
///   value: ResponsiveValue(mobile: 1, tablet: 2, desktop: 4),
///   builder: (context, columns) => GridView(...),
/// )
/// ```
class UniversalResponsiveValueBuilder<T> extends StatelessWidget {
  final ResponsiveValue<T> value;
  final Widget Function(BuildContext context, T value) builder;

  const UniversalResponsiveValueBuilder({
    super.key,
    required this.value,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(context, value.getValue(constraints)),
    );
  }
}

// -----------------------------------------------------------------------------
// UNIVERSAL RESPONSIVE LAYOUT — layout diferente por breakpoint
// -----------------------------------------------------------------------------

/// Exibe um builder diferente para mobile, tablet e desktop.
///
/// Exemplo:
/// ```dart
/// UniversalResponsiveLayout(
///   mobileBuilder: (ctx) => MobileView(),
///   tabletBuilder: (ctx) => TabletView(),
///   desktopBuilder: (ctx) => DesktopView(),
/// )
/// ```
class UniversalResponsiveLayout extends StatelessWidget {
  final WidgetBuilder mobileBuilder;
  final WidgetBuilder? tabletBuilder;
  final WidgetBuilder? desktopBuilder;

  const UniversalResponsiveLayout({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200 && desktopBuilder != null) {
          return desktopBuilder!(context);
        } else if (constraints.maxWidth >= 600 && tabletBuilder != null) {
          return tabletBuilder!(context);
        } else {
          return mobileBuilder(context);
        }
      },
    );
  }
}

// -----------------------------------------------------------------------------
// RESPONSIVE GRID LAYOUT — grid com colunas adaptaveis
// -----------------------------------------------------------------------------

/// Grid que muda o numero de colunas automaticamente por breakpoint.
///
/// Exemplo:
/// ```dart
/// ResponsiveGridLayout(
///   mobileCrossAxisCount: 1,
///   tabletCrossAxisCount: 2,
///   desktopCrossAxisCount: 4,
///   children: cards,
/// )
/// ```
class ResponsiveGridLayout extends StatelessWidget {
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final List<Widget> children;

  const ResponsiveGridLayout({
    super.key,
    this.mobileCrossAxisCount = 1,
    this.tabletCrossAxisCount = 2,
    this.desktopCrossAxisCount = 4,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = desktopCrossAxisCount;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = tabletCrossAxisCount;
        } else {
          crossAxisCount = mobileCrossAxisCount;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// RESPONSIVE HIDE — Ocultação condicional rápida
// -----------------------------------------------------------------------------

/// Envolva qualquer widget para ocultá-lo rapidamente em breakpoints específicos.
/// Ex: ResponsiveHide(mobile: true, child: MeuBanner())
class ResponsiveHide extends StatelessWidget {
  final Widget child;
  final bool mobile;
  final bool tablet;
  final bool desktop;

  const ResponsiveHide({
    super.key,
    required this.child,
    this.mobile = false,
    this.tablet = false,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1200 && desktop) return const SizedBox.shrink();
    if (w >= 600 && w < 1200 && tablet) return const SizedBox.shrink();
    if (w < 600 && mobile) return const SizedBox.shrink();
    return child;
  }
}

// -----------------------------------------------------------------------------
// RESPONSIVE BOX — o widget principal
// -----------------------------------------------------------------------------

/// Substituto inteligente do Row/Column/Container com comportamento responsivo
/// embutido: quebra de linha automatica, encolhimento seguro, scroll, flex, e mais.
///
/// Exemplo basico:
/// ```dart
/// ResponsiveBox(
///   layoutMode: ResponsiveLayoutMode.row,
///   padding: EdgeInsets.all(16),
///   children: [CardA(), CardB(), CardC()],
/// )
/// ```
///
/// Com AutoElement (escala de conteudo + organizacao de layout):
/// ```dart
/// ResponsiveBox(
///   layoutMode: ResponsiveLayoutMode.row,
///   children: [
///     AutoElement(child: CardA()),
///     AutoElement(child: CardB()),
///   ],
/// )
/// ```
class ResponsiveBox extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;

  /// Margem externa. O tamanho do componente ja desconta esta margem.
  final EdgeInsetsGeometry margin;

  /// Define se os filhos serao organizados em linha, coluna ou stack.
  final ResponsiveLayoutMode layoutMode;

  /// Se null (padrao), ativa wrap automaticamente em linhas sem filhos expansiveis.
  /// Se true ou false, força o comportamento.
  final bool? wrap;

  /// Alinhamento simplificado dos filhos.
  /// Pode ser passado como String estilo CSS, Records, ou Enum.
  /// Ex: `align: 'mid, start'` ou `align: 'between'`
  /// Atalhos aceitos na String: start, mid, end, between, around, evenly, stretch.
  final dynamic align;

  /// Espaçamento entre os itens (Gap). Será ajustado dinamicamente proporcional à largura da tela.
  final double? gap;
  /// Largaura de referência para o scale do gap (padrão: 1000)
  final double gapReferenceWidth;

  /// Se true, permite rolagem caso o conteudo ultrapasse os limites.
  final bool scrollable;

  /// Se true, o conteudo escala para preencher o espaco (cresce e encolhe via FittedBox).
  final bool scaleToFit;

  /// Se true (padrao), encolhe via FittedBox.scaleDown para caber no espaco,
  /// impedindo overflow sem precisar de scroll.
  final bool shrinkOnOverflow;

  /// Controla a distribuicao dos itens no eixo principal.
  final MainAxisAlignment? mainAxisAlignment;

  /// Espacamento interno (como Padding).
  final EdgeInsetsGeometry? padding;

  /// Largura fixa em pixels logicos.
  final double? width;

  /// Altura fixa em pixels logicos.
  final double? height;

  /// Largura maxima em pixels logicos.
  final double? maxWidth;

  /// Largura minima em pixels logicos.
  final double? minWidth;

  /// Altura maxima em pixels logicos.
  final double? maxHeight;

  /// Altura minima em pixels logicos.
  final double? minHeight;

  /// Largura como fracao da tela (0.0 a 1.0). Ex: 0.5 = 50% da tela.
  final double? widthPercent;

  /// Altura como fracao da tela (0.0 a 1.0).
  final double? heightPercent;

  /// Largura maxima como fracao da tela.
  final double? maxWidthPercent;

  /// Altura maxima como fracao da tela.
  final double? maxHeightPercent;

  /// Fator flex para uso dentro de Row/Column/ResponsiveBox pai.
  final int? flex;

  /// Comportamento do flex: loose (como Flexible) ou tight (como Expanded).
  final FlexFit flexFit;

  /// Cor de fundo simples.
  final Color? backgroundColor;

  /// Decoracao completa (sobrepoe backgroundColor).
  final Decoration? decoration;

  /// Alinhamento absoluto dentro do espaco disponivel.
  final AlignmentGeometry? alignment;

  /// Se true, ocupa 100% da largura disponivel.
  final bool fullWidth;

  /// Se true, ocupa 100% da altura disponivel.
  final bool fullHeight;

  /// Se true (e shrinkOnOverflow tambem true), permite crescer alem do tamanho
  /// natural usando FittedBox.contain em vez de FittedBox.scaleDown.
  final bool scaleUp;

  /// Abaixo desta largura (em pixels), os filhos envelopados em 
  /// [ResponsiveCollapse] vao para o menu colapsado.
  final double collapseBreakpoint;

  /// Icone exibido quando itens sao colapsados (Padrao: Icons.menu)
  final Widget? collapseIcon;

  /// Posicao em que o icone de menu colapsado vai aparecer (start, center, end)
  final ResponsiveCollapsePosition collapseIconPosition;

  /// Personaliza a abertura do menu. Se `null`, abre um BottomSheet moderno.
  final void Function(BuildContext context, List<Widget> items)? onOpenCollapseMenu;

  /// Se true, transita suavemente as mudanças de tamanho causadas pelo layout.
  final bool animated;
  
  /// A duração da animação (padrão: 300ms)
  final Duration animationDuration;

  const ResponsiveBox({
    super.key,
    this.child,
    this.children,
    this.margin = EdgeInsets.zero,
    this.layoutMode = ResponsiveLayoutMode.column,
    this.wrap,
    this.align,
    this.gap,
    this.gapReferenceWidth = 1000.0,
    this.scrollable = false,
    this.scaleToFit = false,
    this.shrinkOnOverflow = true,
    this.mainAxisAlignment,
    this.padding,
    this.width,
    this.height,
    this.maxWidth,
    this.minWidth,
    this.maxHeight,
    this.minHeight,
    this.widthPercent,
    this.heightPercent,
    this.maxWidthPercent,
    this.maxHeightPercent,
    this.flex,
    this.flexFit = FlexFit.loose,
    this.backgroundColor,
    this.decoration,
    this.alignment,
    this.fullWidth = false,
    this.fullHeight = false,
    this.scaleUp = false,
    this.collapseBreakpoint = 600.0,
    this.collapseIcon,
    this.collapseIconPosition = ResponsiveCollapsePosition.end,
    this.onOpenCollapseMenu,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : assert(
          child == null || children == null,
          'Use child OU children, nao os dois ao mesmo tempo.',
        ),
       assert(
          align == null ||
          align is SmartAlign ||
          align is (SmartAlign, SmartAlign) ||
          align is String ||
          align is (String, String),
          'align deve ser uma String ("mid, start"), Record ou SmartAlign.',
        );

  // ---------------------------------------------------------------------------
  // Helpers internos
  // ---------------------------------------------------------------------------

  SmartAlign _parseAlign(String val) {
    final v = val.trim().toLowerCase();
    if (v == 'start' || v == 'top' || v == 'left') return SmartAlign.start;
    if (v == 'mid' || v == 'center') return SmartAlign.center;
    if (v == 'end' || v == 'bottom' || v == 'right') return SmartAlign.end;
    if (v == 'between' || v == 'spacebetween') return SmartAlign.spaceBetween;
    if (v == 'around' || v == 'spacearound') return SmartAlign.spaceAround;
    if (v == 'evenly' || v == 'spaceevenly') return SmartAlign.spaceEvenly;
    if (v == 'stretch') return SmartAlign.stretch;
    return SmartAlign.start; // fallback silencioso
  }

  SmartAlign get _alignMain {
    if (align == null) return SmartAlign.start;
    if (align is SmartAlign) return align as SmartAlign;
    if (align is (SmartAlign, SmartAlign)) return (align as (SmartAlign, SmartAlign)).$1;
    if (align is (String, String)) return _parseAlign((align as (String, String)).$1);
    if (align is String) return _parseAlign((align as String).split(',')[0]);
    return SmartAlign.start;
  }

  SmartAlign get _alignCross {
    if (align == null) return SmartAlign.start;
    if (align is SmartAlign) return align as SmartAlign;
    if (align is (SmartAlign, SmartAlign)) return (align as (SmartAlign, SmartAlign)).$2;
    if (align is (String, String)) return _parseAlign((align as (String, String)).$2);
    if (align is String) {
      final parts = (align as String).split(',');
      if (parts.length > 1) return _parseAlign(parts[1]);
      return _parseAlign(parts[0]);
    }
    return SmartAlign.start;
  }

  MainAxisAlignment _mapMainAlign(SmartAlign a) {
    switch (a) {
      case SmartAlign.start: return MainAxisAlignment.start;
      case SmartAlign.center: return MainAxisAlignment.center;
      case SmartAlign.end: return MainAxisAlignment.end;
      case SmartAlign.spaceBetween: return MainAxisAlignment.spaceBetween;
      case SmartAlign.spaceAround: return MainAxisAlignment.spaceAround;
      case SmartAlign.spaceEvenly: return MainAxisAlignment.spaceEvenly;
      case SmartAlign.stretch: return MainAxisAlignment.start;
      default: return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _mapCrossAlign(SmartAlign a) {
    switch (a) {
      case SmartAlign.start: return CrossAxisAlignment.start;
      case SmartAlign.center: return CrossAxisAlignment.center;
      case SmartAlign.end: return CrossAxisAlignment.end;
      case SmartAlign.stretch: return CrossAxisAlignment.stretch;
      default: return CrossAxisAlignment.center;
    }
  }

  WrapAlignment _mapWrapMainAlign(SmartAlign a) {
    switch (a) {
      case SmartAlign.start: return WrapAlignment.start;
      case SmartAlign.center: return WrapAlignment.center;
      case SmartAlign.end: return WrapAlignment.end;
      case SmartAlign.spaceBetween: return WrapAlignment.spaceBetween;
      case SmartAlign.spaceAround: return WrapAlignment.spaceAround;
      case SmartAlign.spaceEvenly: return WrapAlignment.spaceEvenly;
      case SmartAlign.stretch: return WrapAlignment.start;
      default: return WrapAlignment.start;
    }
  }

  WrapCrossAlignment _mapWrapCrossAlign(SmartAlign a) {
    switch (a) {
      case SmartAlign.start: return WrapCrossAlignment.start;
      case SmartAlign.center: return WrapCrossAlignment.center;
      case SmartAlign.end: return WrapCrossAlignment.end;
      default: return WrapCrossAlignment.center;
    }
  }

  AlignmentGeometry _getEffectiveAlignment() {
    if (alignment != null) return alignment!;
    
    double mainVal = -1.0;
    if (_alignMain == SmartAlign.center || _alignMain == SmartAlign.spaceAround || _alignMain == SmartAlign.spaceEvenly) {
      mainVal = 0.0;
    } else if (_alignMain == SmartAlign.end) {
      mainVal = 1.0;
    }

    double crossVal = -1.0;
    if (_alignCross == SmartAlign.center) {
      crossVal = 0.0;
    } else if (_alignCross == SmartAlign.end) {
      crossVal = 1.0;
    }

    if (layoutMode == ResponsiveLayoutMode.row) {
      return Alignment(mainVal, crossVal);
    } else { // column or stack
      return Alignment(crossVal, mainVal);
    }
  }



  bool _isFlexibleWidget(Widget w) {
    if (w is Expanded || w is Flexible || w is Spacer) return true;
    if (w is ResponsiveBox && w.flex != null && w.flex! > 0) return true;
    return false;
  }



  double _clamp(double val, double max) =>
      max == double.infinity ? val : (val > max ? max : val);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double autoScale = AutoScale.of(context);

    final double? resolvedWidth =
        width != null ? width! * autoScale : (widthPercent != null ? screenSize.width * widthPercent! : null);
    final double? resolvedHeight =
        height != null ? height! * autoScale : (heightPercent != null ? screenSize.height * heightPercent! : null);
    final double? resolvedMaxWidth =
        maxWidth != null ? maxWidth! * autoScale : (maxWidthPercent != null ? screenSize.width * maxWidthPercent! : null);
    final double? resolvedMaxHeight =
        maxHeight != null ? maxHeight! * autoScale : (maxHeightPercent != null ? screenSize.height * maxHeightPercent! : null);
    final double? resolvedMinWidth = minWidth != null ? minWidth! * autoScale : null;
    final double? resolvedMinHeight = minHeight != null ? minHeight! * autoScale : null;
    final EdgeInsetsGeometry? resolvedPadding = padding != null ? padding! * autoScale : null;
    final EdgeInsetsGeometry? resolvedMargin = margin != null ? margin! * autoScale : null;
    final double? resolvedGap = gap != null ? gap! * autoScale : null;
    final double resolvedCollapseBreakpoint = collapseBreakpoint * autoScale;

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        // Monta o conteudo interno
        Widget? resolvedChild = child;
        List<Widget>? resolvedChildren = children != null ? List.of(children!) : null;
        List<Widget> collapsedItems = [];

        final bool isCollapsed = constraints.maxWidth < resolvedCollapseBreakpoint;

        // Processa children (lista)
        if (children != null) {
          resolvedChildren = [];
          for (int i = 0; i < children!.length; i++) {
            var w = children![i];
            if (w is ResponsiveCollapse) {
              collapsedItems.add(w.collapsedChild ?? w.child);
              
              if (animated) {
                resolvedChildren.add(
                  AnimatedOpacity(
                    opacity: isCollapsed ? 0.0 : 1.0,
                    duration: animationDuration,
                    child: AnimatedSize(
                      duration: animationDuration,
                      curve: Curves.easeInOutCubic,
                      child: isCollapsed ? const SizedBox.shrink() : w,
                    ),
                  )
                );
              } else {
                if (!isCollapsed) resolvedChildren.add(w);
              }
            } else {
              resolvedChildren.add(w);
            }
          }
        } 
        // Processa child único
        else if (child != null) {
          if (child is ResponsiveCollapse) {
            final rc = child as ResponsiveCollapse;
            collapsedItems.add(rc.collapsedChild ?? rc.child);
            
            if (animated) {
              resolvedChild = AnimatedOpacity(
                opacity: isCollapsed ? 0.0 : 1.0,
                duration: animationDuration,
                child: AnimatedSize(
                  duration: animationDuration,
                  curve: Curves.easeInOutCubic,
                  child: isCollapsed ? const SizedBox.shrink() : rc,
                ),
              );
            } else {
              if (isCollapsed) resolvedChild = null;
            }
          }
        }

        if (collapsedItems.isNotEmpty) {
          final baseBtn = IconButton(
            icon: collapseIcon ?? const Icon(Icons.menu),
            onPressed: () {
              if (onOpenCollapseMenu != null) {
                onOpenCollapseMenu!(context, collapsedItems);
              } else {
                showDefaultCollapseMenu(context, collapsedItems);
              }
            },
          );

          Widget collapseBtn;
          if (animated) {
            collapseBtn = AnimatedSize(
              duration: animationDuration,
              curve: Curves.easeInOutCubic,
              child: AnimatedSwitcher(
                duration: animationDuration,
                transitionBuilder: (c, animation) => RotationTransition(
                  turns: animation, 
                  child: ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: c)),
                ),
                child: isCollapsed 
                    ? KeyedSubtree(key: const ValueKey('menu_btn'), child: baseBtn) 
                    : const SizedBox.shrink(key: ValueKey('menu_btn_empty')),
              ),
            );
          } else {
            collapseBtn = isCollapsed ? baseBtn : const SizedBox.shrink();
          }

          if (isCollapsed || animated) {
            if (resolvedChildren != null) {
              if (collapseIconPosition == ResponsiveCollapsePosition.start) {
                resolvedChildren.insert(0, collapseBtn);
              } else if (collapseIconPosition == ResponsiveCollapsePosition.center) {
                resolvedChildren.insert(resolvedChildren.length ~/ 2, collapseBtn);
              } else {
                resolvedChildren.add(collapseBtn);
              }
            } else if (resolvedChild != null) {
              if (collapseIconPosition == ResponsiveCollapsePosition.start) {
                resolvedChildren = [collapseBtn, resolvedChild!];
              } else {
                resolvedChildren = [resolvedChild!, collapseBtn];
              }
              resolvedChild = null;
            } else {
              resolvedChild = collapseBtn;
            }
          }
        }

        final bool hasFlexible = resolvedChild != null
            ? _isFlexibleWidget(resolvedChild)
            : (resolvedChildren?.any(_isFlexibleWidget) ?? false);

        Widget innerContent;
        if (resolvedChild != null) {
          innerContent = resolvedChild;
        } else if (resolvedChildren != null) {
          innerContent = _buildChildren(constraints, hasFlexible, resolvedChildren, autoScale);
        } else {
          innerContent = const SizedBox.shrink();
        }

        final bool isColumn = layoutMode == ResponsiveLayoutMode.column;
        final bool autoWrap = wrap ?? (!isColumn && !hasFlexible);
        
        // O SmartAnimatedWrap já possui seu próprio AnimatedSize internamente.
        // Envolver com outro AnimatedSize causa um loop de interpolação e trava a altura em 0.
        final bool isSmartWrap = autoWrap && animated && resolvedChildren != null && layoutMode != ResponsiveLayoutMode.stack;
        
        if (animated && !isSmartWrap) {
          innerContent = AnimatedSize(
            duration: animationDuration,
            curve: Curves.easeInOutCubic,
            alignment: _getEffectiveAlignment(),
            child: innerContent,
          );
        }

        // 1. Padding interno
        if (resolvedPadding != null) {
          innerContent = animated
              ? AnimatedPadding(duration: animationDuration, curve: Curves.easeInOutCubic, padding: resolvedPadding!, child: innerContent)
              : Padding(padding: resolvedPadding!, child: innerContent);
        }

        // 2. Fundo / decoracao
        if (backgroundColor != null || decoration != null) {
          innerContent = animated
              ? AnimatedContainer(
                  duration: animationDuration,
                  curve: Curves.easeInOutCubic,
                  decoration: decoration ?? BoxDecoration(color: backgroundColor),
                  child: innerContent,
                )
              : DecoratedBox(
                  decoration: decoration ?? BoxDecoration(color: backgroundColor),
                  child: innerContent,
                );
        }

        // 3. Estrategia de overflow
        if (scaleToFit && !hasFlexible) {
          // Cresce E encolhe para preencher o espaco exato
          innerContent = FittedBox(fit: BoxFit.contain, child: innerContent);
        } else if (scrollable) {
          final isColumn = layoutMode == ResponsiveLayoutMode.column;
          final bool autoWrap = wrap ?? (!isColumn && !hasFlexible);
          final scrollVertically = autoWrap ? !isColumn : isColumn;

          innerContent = SingleChildScrollView(
            scrollDirection: scrollVertically ? Axis.vertical : Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: scrollVertically && constraints.maxHeight != double.infinity
                    ? constraints.maxHeight
                    : 0.0,
                maxWidth: scrollVertically && constraints.maxWidth != double.infinity
                    ? constraints.maxWidth
                    : double.infinity,
                minWidth: !scrollVertically && constraints.maxWidth != double.infinity
                    ? constraints.maxWidth
                    : 0.0,
                maxHeight: !scrollVertically && constraints.maxHeight != double.infinity
                    ? constraints.maxHeight
                    : double.infinity,
              ),
              child: innerContent,
            ),
          );
        } else if (shrinkOnOverflow && !hasFlexible) {
          final isColumn = layoutMode == ResponsiveLayoutMode.column;
          final isStack = layoutMode == ResponsiveLayoutMode.stack;
          final bool autoWrap = wrap ?? (!isColumn && !isStack && !hasFlexible);
          final effectiveAlignment = _getEffectiveAlignment();

          final double? safeWidth = resolvedWidth != null
              ? _clamp(resolvedWidth, constraints.maxWidth)
              : null;
          final double? safeMaxWidth = resolvedMaxWidth != null
              ? _clamp(resolvedMaxWidth, constraints.maxWidth)
              : null;
          final double? safeHeight = resolvedHeight != null
              ? _clamp(resolvedHeight, constraints.maxHeight)
              : null;
          final double? safeMaxHeight = resolvedMaxHeight != null
              ? _clamp(resolvedMaxHeight, constraints.maxHeight)
              : null;

          innerContent = FittedBox(
            fit: scaleUp ? BoxFit.contain : BoxFit.scaleDown,
            alignment: effectiveAlignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: safeWidth ??
                    safeMaxWidth ??
                    ((isColumn || autoWrap || isStack)
                        ? constraints.maxWidth
                        : double.infinity),
                maxHeight: safeHeight ??
                    safeMaxHeight ??
                    ((isColumn || autoWrap) ? double.infinity : constraints.maxHeight),
                minWidth: safeWidth ??
                    (fullWidth
                        ? (safeMaxWidth ??
                            (constraints.maxWidth == double.infinity
                                ? 0.0
                                : constraints.maxWidth))
                        : (resolvedMinWidth ?? 0.0)),
                minHeight: safeHeight ??
                    (fullHeight
                        ? (safeMaxHeight ??
                            (constraints.maxHeight == double.infinity
                                ? 0.0
                                : constraints.maxHeight))
                        : (resolvedMinHeight ?? 0.0)),
              ),
              child: innerContent,
            ),
          );
        }

        // 4. Restricoes de tamanho externas (maxWidth, fullWidth, etc.)
        final bool hasConstraints = fullWidth ||
            fullHeight ||
            resolvedWidth != null ||
            resolvedHeight != null ||
            resolvedMaxWidth != null ||
            resolvedMinWidth != null ||
            resolvedMaxHeight != null ||
            resolvedMinHeight != null;

        if (hasConstraints) {
          innerContent = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: fullWidth
                  ? (constraints.maxWidth == double.infinity ? 0.0 : constraints.maxWidth)
                  : (scaleUp ? 0.0 : (resolvedWidth ?? resolvedMinWidth ?? 0.0)),
              maxWidth: fullWidth
                  ? (constraints.maxWidth == double.infinity
                      ? double.infinity
                      : constraints.maxWidth)
                  : (scaleUp ? double.infinity : (resolvedWidth ?? resolvedMaxWidth ?? double.infinity)),
              minHeight: fullHeight
                  ? (constraints.maxHeight == double.infinity ? 0.0 : constraints.maxHeight)
                  : (scaleUp ? 0.0 : (resolvedHeight ?? resolvedMinHeight ?? 0.0)),
              maxHeight: fullHeight
                  ? (constraints.maxHeight == double.infinity
                      ? double.infinity
                      : constraints.maxHeight)
                  : (scaleUp ? double.infinity : (resolvedHeight ?? resolvedMaxHeight ?? double.infinity)),
            ),
            child: innerContent,
          );
        }

        return innerContent;
      },
    );

    // Margem externa
    if (resolvedMargin != null && resolvedMargin != EdgeInsets.zero) {
      content = animated 
          ? AnimatedPadding(duration: animationDuration, curve: Curves.easeInOutCubic, padding: resolvedMargin, child: content) 
          : Padding(padding: resolvedMargin, child: content);
    }

    // Alinhamento absoluto
    if (alignment != null) {
      content = animated
          ? AnimatedAlign(duration: animationDuration, curve: Curves.easeInOutCubic, alignment: alignment!, child: content)
          : Align(alignment: alignment!, child: content);
    }

    // Flex (Flexible/Expanded)
    if (flex != null && flex! > 0) {
      content = Flexible(flex: flex!, fit: flexFit, child: content);
    }

    return content;
  }

  // ---------------------------------------------------------------------------
  // Constroi o layout dos filhos
  // ---------------------------------------------------------------------------

  Widget _buildChildren(BoxConstraints constraints, bool hasFlexible, List<Widget> resolvedChildren, double autoScale) {
    if (layoutMode == ResponsiveLayoutMode.stack) {
      return Stack(
        fit: StackFit.passthrough,
        alignment: _getEffectiveAlignment(),
        children: resolvedChildren,
      );
    }

    final isColumn = layoutMode == ResponsiveLayoutMode.column;
    final bool autoWrap = wrap ?? (!isColumn && !hasFlexible);

    final double actualGap = gap != null ? gap! * autoScale : 0.0;

    if (autoWrap) {
      if (animated) {
        return SmartAnimatedWrap(
          direction: isColumn ? Axis.vertical : Axis.horizontal,
          alignment: _mapWrapMainAlign(_alignMain),
          crossAxisAlignment: _mapWrapCrossAlign(_alignCross),
          spacing: actualGap,
          runSpacing: actualGap,
          duration: animationDuration,
          children: resolvedChildren,
        );
      } else {
        return Wrap(
          direction: isColumn ? Axis.vertical : Axis.horizontal,
          alignment: _mapWrapMainAlign(_alignMain),
          crossAxisAlignment: _mapWrapCrossAlign(_alignCross),
          spacing: actualGap,
          runSpacing: actualGap,
          children: resolvedChildren,
        );
      }
    }

    List<Widget> finalChildren = resolvedChildren;
    if (actualGap > 0 && resolvedChildren.length > 1) {
      finalChildren = [];
      for (int i = 0; i < resolvedChildren.length; i++) {
        finalChildren.add(resolvedChildren[i]);
        if (i < resolvedChildren.length - 1) {
          finalChildren.add(SizedBox(width: actualGap, height: actualGap));
        }
      }
    }

    return Flex(
      direction: isColumn ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: mainAxisAlignment ?? _mapMainAlign(_alignMain),
      crossAxisAlignment: _mapCrossAlign(_alignCross),
      mainAxisSize: scrollable
          ? MainAxisSize.min
          : (((fullWidth && !isColumn) || (fullHeight && isColumn))
              ? MainAxisSize.max
              : MainAxisSize.min),
      children: finalChildren,
    );
  }
}
