import 'package:flutter/material.dart';

class RollingTicker extends StatefulWidget {
  final List<String> items;

  const RollingTicker({super.key, required this.items});

  @override
  State<RollingTicker> createState() => _RollingTickerState();
}

class _RollingTickerState extends State<RollingTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late String _segment;
  double _segmentWidth = 0;

  @override
  void initState() {
    super.initState();
    _segment = '${widget.items.join('   ···   ')}   ···   ';
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void didUpdateWidget(RollingTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _segment = '${widget.items.join('   ···   ')}   ···   ';
    _segmentWidth = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _measureIfNeeded() {
    if (_segmentWidth == 0) {
      final tp = TextPainter(
        text: TextSpan(
          text: _segment,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      _segmentWidth = tp.width;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.05, 0.95, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Container(
          height: 36,
          color: Colors.black26,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _measureIfNeeded();
              final screenWidth = constraints.maxWidth;
              final repeatCount =
                  _segmentWidth > 0 ? (screenWidth / _segmentWidth).ceil() + 2 : 3;
              final fullText = _segment * repeatCount;

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final offset = _controller.value * _segmentWidth;
                  return Transform.translate(
                    offset: Offset(-offset, 0),
                    child: child,
                  );
                },
                child: SizedBox(
                  height: 36,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      fullText,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
