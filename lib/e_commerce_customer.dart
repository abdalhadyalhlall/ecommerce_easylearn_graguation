
import 'package:clean_arch_session/core/routes/app_router.dart';
import 'package:clean_arch_session/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متجر',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter().generateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('تعذر العثور على الصفحة')),
        ),
      ),
    );
  }
}
