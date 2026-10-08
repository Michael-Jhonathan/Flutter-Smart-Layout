import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// RESPONSIVE COLLAPSE — Itens que vao para a gaveta no mobile
// -----------------------------------------------------------------------------

/// Envolva qualquer widget com [ResponsiveCollapse] dentro de um [ResponsiveBox].
/// Quando a tela ficar menor que o `collapseBreakpoint` configurado na caixa, 
/// este item saira da tela e ira automaticamente para um menu/drawer.
class ResponsiveCollapse extends StatelessWidget {
  /// O widget que sera exibido no Desktop
  final Widget child;
  
  /// Opcional: define como o item deve se parecer dentro da gaveta.
  /// Ideal para transformar botoes pequenos em itens de lista largos (ListTile).
  final Widget? collapsedChild;

  const ResponsiveCollapse({
    super.key,
    required this.child,
    this.collapsedChild,
  });

  @override
  Widget build(BuildContext context) => child;
}

// -----------------------------------------------------------------------------
// DRAWER FUNC
// -----------------------------------------------------------------------------

/// Exibe um menu elegante em formato de BottomSheet contendo os itens colapsados.
void showDefaultCollapseMenu(BuildContext context, List<Widget> items) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Align(alignment: Alignment.centerLeft, child: i),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
