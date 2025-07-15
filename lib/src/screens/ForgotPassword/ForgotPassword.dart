import 'dart:ui';
import 'package:crypto_pay/src/providers/Auth_Provider.dart';
import 'package:crypto_pay/src/screens/DashboardScreen.dart';
import 'package:crypto_pay/src/screens/ForgotPassword/ChangePassword.dart';
import 'package:crypto_pay/src/screens/ForgotPassword/OtpScreen.dart';
import 'package:crypto_pay/src/screens/HomeScreen.dart';
import 'package:crypto_pay/src/screens/InputCustomizado%20.dart';
import 'package:crypto_pay/src/screens/LoginScreen.dart';
import 'package:crypto_pay/src/screens/SignUp.dart';
import 'package:crypto_pay/src/screens/button.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animacaoBlur;
  Animation<double>? _animacaoSize;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
 // final _passwordController = TextEditingController();

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
    _emailController.dispose();
    //_passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) => Scaffold(
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
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24,
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
                SizedBox(height: 10,),
                Text('No Worries, We Will Send you Reset instructions.', style: TextStyle(fontFamily: 'Poppins', fontSize: 12),),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                                    controller: _emailController,
                                    hint: 'Enter Registered Email',
                                    obscure: false,
                                    icon: const Icon(Icons.email),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter Registered Email';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        if (authProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: authProvider.isLoading ? 60 : 300,
                            height: 45,
                            child: Center(
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: AppColors.kprimary,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Button(
                                      controller: _controller!,
                                      onTap: ()  {
                                       Navigator.push(context, CupertinoPageRoute(builder: (context) => OtpScreen(),));
                                      },
                                      text: 'Reset Password',
                                      textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white, // Text color
                letterSpacing: 0.5,
              ),
                                      backgroundColor: AppColors.kprimary,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Back To Login ? ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: AppColors.kprimary,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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