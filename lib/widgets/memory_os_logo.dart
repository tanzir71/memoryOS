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

    final path = Path()
      ..moveTo(size.width * 32 / 64, size.height * 4 / 64)
      ..lineTo(size.width * 60 / 64, size.height * 32 / 64)
      ..lineTo(size.width * 32 / 64, size.height * 60 / 64)
      ..lineTo(size.width * 4 / 64, size.height * 32 / 64)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MemoryOSLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
