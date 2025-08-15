import 'package:flutter/material.dart';
import 'view/layout/app_shell.dart';
import 'themes/app_theme.dart';

void main() => runApp(const CitasApp());

class CitasApp extends StatelessWidget {
  const CitasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Citas',
  theme: AppTheme.theme(),
  home: const AppShell(),
    );
  }
}
