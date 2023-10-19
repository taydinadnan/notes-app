import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes_app/app_style.dart';
import 'package:notes_app/provider/firebase_authentication.dart';
import 'package:notes_app/view/auth/register_screen.dart';
import 'package:notes_app/view/auth/widgets/animated_back_ground.dart';
import 'package:notes_app/view/auth/widgets/auth_widgets.dart';
import 'package:notes_app/view/auth/widgets/bottom_slide_animation.dart';
import 'package:notes_app/view/auth/widgets/top_slide_animation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  bool isAnimatingIn = false;
  String? errorMessage = '';
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    final auth = ref.read(authProvider);
    setState(() {
      isLoading = true;
    });

    try {
      await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    }

    if (isLoading) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : signInWithEmailAndPassword,
      child:
          isLoading ? const CircularProgressIndicator() : const Text('Login'),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        setState(() {
          isAnimatingIn = true;
        });
        await Future.delayed(const Duration(milliseconds: 100));
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const RegisterScreen();
            },
          ),
        );
        _passwordController.clear();
        _emailController.clear();
        setState(() {
          isAnimatingIn = false;
        });
      },
      child: const Text('Create an account'),
    );
  }

  void animateContainers() async {
    setState(() {
      isAnimatingIn = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isAnimatingIn = false;
    });
  }

  @override
  void initState() {
    super.initState();
    animateContainers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      body: Stack(
        children: [
          buildLogin(),
          const AnimatedBackGround(),
          TopSlideAnimation(isAnimatingIn: isAnimatingIn, context: context),
          BottomSlideAnimation(isAnimatingIn: isAnimatingIn, context: context),
        ],
      ),
    );
  }

  Center buildLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login to your account'),
            const SizedBox(height: 20),
            buildTextField(_emailController, 'Email', false),
            const SizedBox(height: 10),
            buildTextField(_passwordController, 'Password', true),
            const SizedBox(height: 20),
            _buildLoginButton(),
            const SizedBox(height: 20),
            buildErrorMessage(errorMessage),
            _buildRegisterButton(context),
          ],
        ),
      ),
    );
  }
}
