import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() {
  runApp(const ProviderScope(child: SepsisAgentApp()));
}

class SepsisAgentApp extends StatelessWidget {
  const SepsisAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Sepsis Agent',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
    );
  }
}
