import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/features/splash/widgets/fade_in_widget.dart';
import '../../dashboard/screen/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3 seconds delay then go to DashboardScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: FadeInWidget(
          delay: 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/notes_icon.png',
                height: 100,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(height: 10),
              const Text(
                "Notes App",
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
