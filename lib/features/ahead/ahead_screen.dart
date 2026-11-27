import 'package:flutter/material.dart';
import '../../app/tokens.dart';

class AheadScreen extends StatelessWidget {
  const AheadScreen({super.key});

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
            const Text('Ahead', style: AppType.displayTitle),
            const SizedBox(height: AppSpace.s8),
            Text(
              'Expected bills, recharges, recurring calls and rhythms will appear here.',
              style: AppType.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}
