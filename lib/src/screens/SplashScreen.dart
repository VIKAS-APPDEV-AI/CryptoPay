import 'package:crypto_pay/src/screens/OnBoarding.dart';
import 'package:crypto_pay/src/screens/LoginScreen.dart';
import 'package:crypto_pay/src/models/OnboardingPageModel.dart';
import 'package:crypto_pay/src/utils/AnimatedWidget.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    try {
      // Wait for 3 seconds
      await Future.delayed(const Duration(seconds: 3));

      // Check if onboarding has been seen
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      print('hasSeenOnboarding: $hasSeenOnboarding'); // Debug log

      if (hasSeenOnboarding) {
        print('Navigating to LoginScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        print('Navigating to OnboardingPage');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingPage(
              pages: [
                OnboardingPageModel(
                  title: 'Get Started with Payment Links',
                  description:
                      'Easily generate payment links by entering your product name, optional description, and fiat amount in USD. Click "Create Now" to begin!.',
                  image: 'assets/images/onb1.png',
                  bgColor: Colors.indigo,
                  textColor: Colors.white,
                ),
                OnboardingPageModel(
                  title: 'Transactions List.',
                  description:
                      'View and manage your transaction history, including withdraw fees and status updates. Current transactions.',
                  image: 'assets/images/onb2.png',
                  bgColor: AppColors.ksecondary,
                  textColor: Colors.white,
                ),
                OnboardingPageModel(
                  title: 'Welcome to Your Crypto Dashboard',
                  description:
                      'Allows conversion between BTC and USD, with options to adjust the amount using "+" and "-" buttons for change and volume.',
                  image: 'assets/images/onb3.png',
                  bgColor: AppColors.kprimary,
                  textColor: Colors.white,
                ),
                OnboardingPageModel(
                  title: 'Generate Pay Link',
                  description:
                      'Easily create a payment link by entering your product name, optional description, and fiat amount in USD. Click "Create Now" to get started!.',
                  image: 'assets/images/onb4.png',
                  bgColor: AppColors.kthirdColor,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      print('Error during navigation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainerWidget(
              fadeCurve: Easing.legacy,
              child: Image.asset(
                'assets/images/logo1.png',
                height: 250,
              ),
            ),
            const SizedBox(height: 0),
            AnimatedContainerWidget(
              fadeCurve: Curves.linear,
              child: Text(
                'CryptoPay',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  letterSpacing: 2,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: <Color>[
                        Color(0xFFef4923),
                        Color(0xFF333333),
                      ],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  shadows: const [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black26,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}