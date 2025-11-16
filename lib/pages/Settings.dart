import 'package:flutter/material.dart';
import 'package:name_meaning/fontscale_provider.dart';
import 'package:provider/provider.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.watch<FontScaleProvider>().scale;

    return Scaffold(
      appBar: AppBar(title: const Text("Sazla")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Teks ululygy sazla"),
            Slider(
              value: scale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: scale.toStringAsFixed(1),
              onChanged: (value) {
                context.read<FontScaleProvider>().setScale(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
