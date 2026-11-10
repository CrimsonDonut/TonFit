import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class TonFitApp extends StatelessWidget {
  const TonFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TonFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
