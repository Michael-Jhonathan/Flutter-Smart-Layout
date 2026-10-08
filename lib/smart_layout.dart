import 'package:flutter/material.dart';

export 'responsive_collapse.dart';
export 'smart_animated_wrap.dart';
export 'responsive_box.dart';
export 'auto_element.dart';

/// Um layout mestre para preencher a tela inteira com rolagem (se necessário)
/// e agrupar seções dentro dele.
class SmartPage extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;

  const SmartPage({super.key, required this.children, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Uma seção responsiva inteligente.
/// Ela automaticamente centraliza o conteúdo em monitores grandes,
/// limitando a largura a um "maxWidth" (ex: 1000px) e aplicando zoom (scaleUp)
/// para evitar bordas brancas gigantes em telas ultrawide ou 4K.
class SmartSection extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;
  final bool scaleUp;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const SmartSection({
    Key? key,
    required this.children,
    this.maxWidth = 1000,
    this.scaleUp = true,
    this.padding,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        // Se a tela for menor que o maxWidth, ela encolhe naturalmente.
        // Se for maior, ela trava em maxWidth e o FittedBox dará o Zoom.
        double safeMaxWidth = constraints.maxWidth > maxWidth ? maxWidth : constraints.maxWidth;

        Widget innerColumn = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: safeMaxWidth,
            minWidth: scaleUp ? safeMaxWidth : 0,
          ),
          child: Column(
            children: children,
          ),
        );

        if (scaleUp && constraints.maxWidth > maxWidth) {
          return FittedBox(
            fit: BoxFit.contain,
            child: innerColumn,
          );
        }

        return innerColumn;
      },
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (backgroundColor != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: content,
      );
    }

    return SizedBox(
      width: double.infinity, // Força a seção a preencher a tela horizontalmente
      child: content,
    );
  }
}

/// Um grid mágico que quebra a linha automaticamente (Wrap) 
/// mantendo todas as cartas (children) com espaços perfeitos (gap).
class SmartGrid extends StatelessWidget {
  final List<Widget> children;
  final double gap;
  final MainAxisAlignment alignment;

  const SmartGrid({
    Key? key,
    required this.children,
    this.gap = 24.0,
    this.alignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WrapAlignment wrapAlignment = WrapAlignment.center;
    if (alignment == MainAxisAlignment.start) wrapAlignment = WrapAlignment.start;
    if (alignment == MainAxisAlignment.end) wrapAlignment = WrapAlignment.end;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      alignment: wrapAlignment,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: children,
    );
  }
}

/// Uma carta responsiva simples.
/// Ela define uma largura limite para não esticar infinitamente em telas grandes
/// mas encolhe perfeitamente no mobile, preservando sua altura mínima para simetria.
class SmartCard extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double minHeight;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const SmartCard({
    Key? key,
    required this.child,
    this.maxWidth = 350,
    this.minHeight = 250,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minHeight: minHeight,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}

/// Um componente para separar elementos com espaçamento.
class SmartGap extends StatelessWidget {
  final double size;
  const SmartGap(this.size, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
  }
}

