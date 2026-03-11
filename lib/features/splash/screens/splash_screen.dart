import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logos/cultiva_logo.png", width: 240),

            const SizedBox(height: 20),

            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.greenDark, AppColors.greenPrimary],
              ).createShader(bounds),
              child: const Text(
                "Cultiva+",
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
