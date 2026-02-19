import 'package:flutter/material.dart';

class DrawingCanvas extends StatefulWidget {
  final ValueNotifier<List<List<Offset>>> strokesNotifier;

  const DrawingCanvas({super.key, required this.strokesNotifier});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: GestureDetector(
          onPanStart: (details) {
            final strokes = List<List<Offset>>.from(
              widget.strokesNotifier.value.map((s) => List<Offset>.from(s)),
            );
            strokes.add([details.localPosition]);
            widget.strokesNotifier.value = strokes;
          },
          onPanUpdate: (details) {
            final strokes = List<List<Offset>>.from(
              widget.strokesNotifier.value.map((s) => List<Offset>.from(s)),
            );
            if (strokes.isNotEmpty) {
              strokes.last.add(details.localPosition);
              widget.strokesNotifier.value = strokes;
            }
          },
          onPanEnd: (_) {},
          child: ValueListenableBuilder<List<List<Offset>>>(
            valueListenable: widget.strokesNotifier,
            builder: (context, strokes, _) {
              return CustomPaint(
                painter: _StrokePainter(strokes: strokes),
                size: Size.infinite,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _StrokePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) {
        if (stroke.length == 1) {
          canvas.drawCircle(stroke.first, 2.0, paint..style = PaintingStyle.fill);
          paint.style = PaintingStyle.stroke;
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
