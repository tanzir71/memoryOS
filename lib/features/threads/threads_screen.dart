import 'package:flutter/material.dart';
import '../../app/tokens.dart';

class ThreadsScreen extends StatelessWidget {
  const ThreadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.screenHorizontal,
          vertical: AppSpace.s20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Threads', style: AppType.displayTitle),
            const SizedBox(height: AppSpace.s8),
            Text(
              'Related calls, messages, emails and meetings will be grouped here.',
              style: AppType.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}
