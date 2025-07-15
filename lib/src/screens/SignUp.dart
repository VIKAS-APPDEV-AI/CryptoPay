import 'dart:ui';
import 'package:crypto_pay/src/screens/InputCustomizado%20.dart';
import 'package:crypto_pay/src/screens/LoginScreen.dart';
import 'package:crypto_pay/src/screens/button.dart';
import 'package:crypto_pay/src/services/api_service.dart';
import 'package:crypto_pay/src/utils/Constants.dart'; // Add this import
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animacaoBlur;
  Animation<double>? _animacaoFade;
  Animation<double>? _animacaoSize;
  bool _isChecked = false;
  
  // Controllers for input fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // API Service instance
  final ApiService _apiService = ApiService();

  // URLs for Terms & Conditions and Privacy Policy
  final String termsUrl = 'https://yourwebsite.com/terms';
  final String privacyUrl = 'https://drive.google.com/file/d/1y2IWw7rWB6jkwmO0JC0UUrGzafNHPRa4/view?usp=sharing';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animacaoBlur = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.ease,
      ),
    );

    _animacaoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOutQuint,
      ),
    );

    _animacaoSize = Tween<double>(
      begin: 0,
      end: 500,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.decelerate,
      ),
    );

    _controller?.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Function to launch URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  // Function to handle sign up
  Future<void> _handleSignUp() async {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }

    if (_fullNameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await _apiService.registerApp(
        fullName: _fullNameController.text,
        emailId: _emailController.text,
      );

      // Handle successful response
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      
      // Navigate to Login screen after successful registration
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kwhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120),
            ClipPath(
              clipper: ArcClipper(),
              child: AnimatedBuilder(
                animation: _animacaoBlur!,
                builder: (context, widget) {
                  return Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo1.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _animacaoBlur!.value,
                        sigmaY: _animacaoBlur!.value,
                      ),
                      child: Container(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 10),
              child: Column(
                children: [
                  const Text(
                    'SIGN UP',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please Fill in the form below',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _animacaoSize!,
                    builder: (context, widget) {
                      return Container(
                        width: _animacaoSize?.value,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(240, 152, 70, 1),
                              blurRadius: 80,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            InputCustomizado(
                              hint: 'Your Full Name',
                              obscure: false,
                              icon: const Icon(Icons.person),
                              controller: _fullNameController, // Add controller
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 0.5,
                                    blurRadius: 0.5,
                                  ),
                                ],
                              ),
                            ),
                            InputCustomizado(
                              hint: 'Enter Email Address',
                              obscure: false,
                              icon: const Icon(Icons.email),
                              controller: _emailController, // Add controller
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.kprimary,
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'By creating an account you agree to the ',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: const TextStyle(
                                    color: AppColors.kprimary, fontSize: 12),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _launchUrl(termsUrl);
                                  },
                              ),
                              const TextSpan(
                                text: ' and our ',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                    color: AppColors.kprimary, fontSize: 12),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _launchUrl(privacyUrl);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Button(
                    controller: _controller!,
                    onTap: _handleSignUp, // Call the sign up handler
                    backgroundColor: AppColors.kprimary,
                    text: 'Sign Up',
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already Have an Account? ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => const Login()),
                          );
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: AppColors.kprimary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper for the arc shape
class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}