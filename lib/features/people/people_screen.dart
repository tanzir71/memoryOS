import 'package:flutter/material.dart';
import '../../app/tokens.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

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
            const Text('People', style: AppType.displayTitle),
            const SizedBox(height: AppSpace.s8),
            Text(
              'Contacts and people you exchange calls, messages and emails with will appear here.',
              style: AppType.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}
