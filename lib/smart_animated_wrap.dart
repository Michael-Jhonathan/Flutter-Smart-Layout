import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// -----------------------------------------------------------------------------
// SMART ANIMATED WRAP — O motor de quebra de linha animado
// -----------------------------------------------------------------------------

/// Um substituto para o [Wrap] nativo que anima as posições de seus filhos
/// automaticamente quando a largura da tela muda e eles quebram de linha.
class SmartAnimatedWrap extends StatefulWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final Duration duration;
  final Axis direction;

  const SmartAnimatedWrap({
    super.key,
    required this.children,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.duration = const Duration(milliseconds: 300),
    this.direction = Axis.horizontal,
  });

  @override
  State<SmartAnimatedWrap> createState() => _SmartAnimatedWrapState();
}

class _SmartAnimatedWrapState extends State<SmartAnimatedWrap> {
  final Map<int, Size> _sizes = {};
  double _totalHeight = 0.0;
  List<Offset> _positions = [];
  double _lastMaxWidth = 0.0;

  void _onChildSize(int index, Size size, double maxWidth) {
    if (_sizes[index] == size) return;
    _sizes[index] = size;
    if (_sizes.length == widget.children.length) {
      _calculateLayout(maxWidth);
    }
  }

  void _calculateLayout(double maxWidth) {
    if (_sizes.length != widget.children.length) return;

    List<List<int>> runs = [];
    List<double> runWidths = [];
    List<double> runHeights = [];

    List<int> currentRun = [];
    double currentRunWidth = 0;
    double currentRunHeight = 0;

    for (int i = 0; i < widget.children.length; i++) {
      Size s = _sizes[i] ?? Size.zero;
      
      if (currentRunWidth + s.width > maxWidth && currentRun.isNotEmpty) {
        runs.add(currentRun);
        runWidths.add(currentRunWidth - widget.spacing);
        runHeights.add(currentRunHeight);
        currentRun = [];
        currentRunWidth = 0;
        currentRunHeight = 0;
      }
      
      currentRun.add(i);
      currentRunWidth += s.width + widget.spacing;
      currentRunHeight = math.max(currentRunHeight, s.height);
    }
    
    if (currentRun.isNotEmpty) {
      runs.add(currentRun);
      runWidths.add(currentRunWidth - widget.spacing);
      runHeights.add(currentRunHeight);
    }

    double y = 0;
    List<Offset> newPositions = List.filled(widget.children.length, Offset.zero);
    
    for (int r = 0; r < runs.length; r++) {
      double x = 0;
      if (widget.alignment == WrapAlignment.center) {
        x = (maxWidth - runWidths[r]) / 2;
        x = math.max(0, x);
      } else if (widget.alignment == WrapAlignment.end) {
        x = maxWidth - runWidths[r];
        x = math.max(0, x);
      } else if (widget.alignment == WrapAlignment.spaceAround) {
         x = (maxWidth - runWidths[r]) / (runs[r].length + 1);
      } else if (widget.alignment == WrapAlignment.spaceBetween) {
         x = 0;
      }

      for (int i in runs[r]) {
        Size s = _sizes[i] ?? Size.zero;
        double childY = y;
        if (widget.crossAxisAlignment == WrapCrossAlignment.center) {
          childY += (runHeights[r] - s.height) / 2;
        } else if (widget.crossAxisAlignment == WrapCrossAlignment.end) {
          childY += (runHeights[r] - s.height);
        }
        newPositions[i] = Offset(x, childY);
        
        double extraSpace = 0;
        if (widget.alignment == WrapAlignment.spaceBetween && runs[r].length > 1) {
            extraSpace = (maxWidth - runWidths[r]) / (runs[r].length - 1);
        } else if (widget.alignment == WrapAlignment.spaceAround) {
            extraSpace = (maxWidth - runWidths[r]) / (runs[r].length + 1);
        }

        x += s.width + widget.spacing + extraSpace;
      }
      y += runHeights[r] + widget.runSpacing;
    }

    final newTotalHeight = y - (runs.isEmpty ? 0 : widget.runSpacing);

    setState(() {
      _positions = newPositions;
      _totalHeight = newTotalHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if ((constraints.maxWidth - _lastMaxWidth).abs() > 1.0) {
          _lastMaxWidth = constraints.maxWidth;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _calculateLayout(constraints.maxWidth);
          });
        }

        return AnimatedSize(
          duration: widget.duration,
          curve: Curves.easeInOutCubic,
          child: SizedBox(
            width: constraints.maxWidth == double.infinity ? null : constraints.maxWidth,
            height: _totalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(widget.children.length, (index) {
                final isMeasured = _positions.length == widget.children.length;
                final pos = isMeasured ? _positions[index] : Offset.zero;

                return AnimatedPositioned(
                  key: ValueKey(index),
                  duration: widget.duration,
                  curve: Curves.easeInOutCubic,
                  left: pos.dx,
                  top: pos.dy,
                  child: _MeasureSize(
                    onChange: (size) => _onChildSize(index, size, constraints.maxWidth),
                    child: Opacity(
                      opacity: isMeasured ? 1.0 : 0.0,
                      child: widget.children[index],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER PARA MEDIR OS FILHOS
// -----------------------------------------------------------------------------
typedef _OnWidgetSizeChange = void Function(Size size);

class _MeasureSize extends SingleChildRenderObjectWidget {
  final _OnWidgetSizeChange onChange;

  const _MeasureSize({
    required this.onChange,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final _OnWidgetSizeChange onChange;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    Size newSize = child!.size;
    if (oldSize == newSize) return;
    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}
