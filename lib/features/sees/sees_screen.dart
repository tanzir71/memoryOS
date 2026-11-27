import 'package:flutter/material.dart';
import '../../app/tokens.dart';

class SeesScreen extends StatelessWidget {
  const SeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('What MemoryOS sees', style: AppType.titleMd)),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.screenHorizontal,
          vertical: AppSpace.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose what MemoryOS reads on this phone. Stored on this phone only. Nothing is uploaded.',
              style: AppType.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}
