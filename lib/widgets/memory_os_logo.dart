import 'package:flutter/material.dart';

class MemoryOSLogo extends StatelessWidget {
  const MemoryOSLogo({
    super.key,
    this.size = 24,
    this.color = Colors.black,
    this.innerColor = Colors.white,
  });

  final double size;
  final Color color;
  final Color innerColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'MemoryOS logo',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _MemoryOSLogoPainter(color: color, innerColor: innerColor),
        ),
      ),
    );
  }
}

class _MemoryOSLogoPainter extends CustomPainter {
  const _MemoryOSLogoPainter({required this.color, required this.innerColor});

  final Color color;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    Path diamond(double inset) {
      return Path()
        ..moveTo(size.width / 2, inset)
        ..lineTo(size.width - inset, size.height / 2)
        ..lineTo(size.width / 2, size.height - inset)
        ..lineTo(inset, size.height / 2)
        ..close();
    }

    paint.color = color;
    canvas.drawPath(diamond(size.width * 4 / 64), paint);

    paint.color = innerColor;
    canvas.drawPath(diamond(size.width * 18 / 64), paint);

    paint.color = color;
    canvas.drawPath(diamond(size.width * 27 / 64), paint);
  }

  @override
  bool shouldRepaint(covariant _MemoryOSLogoPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.innerColor != innerColor;
  }
}
