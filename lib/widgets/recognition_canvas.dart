import 'package:flutter/material.dart';

class TimedPoint {
  final double x;
  final double y;
  final int t;

  const TimedPoint({required this.x, required this.y, required this.t});
}

class RecognitionCanvas extends StatefulWidget {
  final ValueNotifier<List<List<TimedPoint>>> strokesNotifier;

  const RecognitionCanvas({super.key, required this.strokesNotifier});

  @override
  State<RecognitionCanvas> createState() => _RecognitionCanvasState();
}

class _RecognitionCanvasState extends State<RecognitionCanvas> {
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
            final strokes = List<List<TimedPoint>>.from(
              widget.strokesNotifier.value.map((s) => List<TimedPoint>.from(s)),
            );
            strokes.add([
              TimedPoint(
                x: details.localPosition.dx,
                y: details.localPosition.dy,
                t: DateTime.now().millisecondsSinceEpoch,
              ),
            ]);
            widget.strokesNotifier.value = strokes;
          },
          onPanUpdate: (details) {
            final strokes = List<List<TimedPoint>>.from(
              widget.strokesNotifier.value.map((s) => List<TimedPoint>.from(s)),
            );
            if (strokes.isNotEmpty) {
              strokes.last.add(TimedPoint(
                x: details.localPosition.dx,
                y: details.localPosition.dy,
                t: DateTime.now().millisecondsSinceEpoch,
              ));
              widget.strokesNotifier.value = strokes;
            }
          },
          onPanEnd: (_) {},
          child: ValueListenableBuilder<List<List<TimedPoint>>>(
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
  final List<List<TimedPoint>> strokes;

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
          canvas.drawCircle(
            Offset(stroke.first.x, stroke.first.y),
            2.0,
            paint..style = PaintingStyle.fill,
          );
          paint.style = PaintingStyle.stroke;
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.x, stroke.first.y);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].x, stroke[i].y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
