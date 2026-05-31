import 'package:flutter/material.dart';

class MemoryOSLogo extends StatelessWidget {
  const MemoryOSLogo({super.key, this.size = 24, this.color = Colors.black});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'MemoryOS logo',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _MemoryOSLogoPainter(color: color)),
      ),
    );
  }
}

class _MemoryOSLogoPainter extends CustomPainter {
  const _MemoryOSLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final outerPath = Path()
      ..moveTo(size.width * 32 / 64, size.height * 4 / 64)
      ..lineTo(size.width * 60 / 64, size.height * 32 / 64)
      ..lineTo(size.width * 32 / 64, size.height * 60 / 64)
      ..lineTo(size.width * 4 / 64, size.height * 32 / 64)
      ..close();

    final innerPath = Path()
      ..moveTo(size.width * 32 / 64, size.height * 18 / 64)
      ..lineTo(size.width * 46 / 64, size.height * 32 / 64)
      ..lineTo(size.width * 32 / 64, size.height * 46 / 64)
      ..lineTo(size.width * 18 / 64, size.height * 32 / 64)
      ..close();

    final centerPath = Path()
      ..moveTo(size.width * 32 / 64, size.height * 27 / 64)
      ..lineTo(size.width * 37 / 64, size.height * 32 / 64)
      ..lineTo(size.width * 32 / 64, size.height * 37 / 64)
      ..lineTo(size.width * 27 / 64, size.height * 32 / 64)
      ..close();

    canvas.drawPath(outerPath, paint);
    canvas.drawPath(innerPath, paint..color = Colors.white);
    canvas.drawPath(centerPath, paint..color = color);
  }

  @override
  bool shouldRepaint(covariant _MemoryOSLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
