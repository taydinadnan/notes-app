import 'package:animated_background/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/provider/firebase_authentication.dart';
import 'package:notes_app/view/auth/register_screen.dart';
import 'package:notes_app/view/auth/widgets/auth_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
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

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegisterScreen(),
          ),
        );
        _passwordController.clear();
        _emailController.clear();
      },
      child: const Text('Create an account'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      body: Stack(
        children: [
          Image.asset("assets/top.png"),
          buildLogin(),
          animatedBackGround(),
          Positioned(
            bottom: 1,
            child: RotatedBox(
              quarterTurns: 2,
              child: Image.asset(
                "assets/top.png",
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Opacity animatedBackGround() {
    return Opacity(
      opacity: 0.5,
      child: AnimatedBackground(
        vsync: this,
        behaviour: RandomParticleBehaviour(
            options: const ParticleOptions(
              spawnOpacity: 0.0,
              opacityChangeRate: 0.25,
              minOpacity: 0.1,
              maxOpacity: 0.4,
              spawnMinSpeed: 30.0,
              spawnMaxSpeed: 70.0,
              spawnMinRadius: 7.0,
              spawnMaxRadius: 15.0,
              particleCount: 40,
            ),
            paint: particlePaint),
        child: const SizedBox(),
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
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
}
