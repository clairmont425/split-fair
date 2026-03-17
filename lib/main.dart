import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SplitFairApp());
}

class SplitFairApp extends StatelessWidget {
  const SplitFairApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Split Fair',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _Splash(),
      ),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }
  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.home_work_rounded, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Split Fair', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text('Fair rent for every room', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
