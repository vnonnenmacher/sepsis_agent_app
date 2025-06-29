import 'package:flutter/material.dart';
import '../../core/widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(
        child: Text(
          'Configuration',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
