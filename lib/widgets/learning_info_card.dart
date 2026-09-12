import 'package:flutter/material.dart';

class LearningInfoCard extends StatelessWidget {
  const LearningInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'How it works',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Flutter\n   ↓\nBackend\n   ↓\nDaraja\n   ↓\nM-PESA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Flutter app sends the payment request to the backend. The backend communicates with Safaricom Daraja and handles the payment callback.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
