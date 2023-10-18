import 'package:animated_background/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/provider/firebase_authentication.dart';
import 'package:notes_app/widget_tree.dart';
import 'package:notes_app/view/auth/widgets/auth_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  String? errorMessage = '';
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<String> createUserWithEmailAndPassword() async {
    final auth = ref.read(authProvider);
    setState(() {
      isLoading = true;
    });

    try {
      await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        isLoading = false;
      });
      return "success";
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.message;
      });
      return "error";
    }
  }

  void _navigateToHomeList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WidgetTree()),
    );
  }

  Widget _buildRegistrationButton() {
    final userData = ref.watch(userDataRepository);
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              createUserWithEmailAndPassword().then((result) {
                if (result == "success") {
                  userData.saveUserDataToFirestore(
                      _emailController.text, _usernameController.text);
                  _navigateToHomeList();
                }
              });
            },
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text('Register'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      body: Stack(
        children: [
          Image.asset("assets/top.png"),
          buildSignUp(context),
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

  Center buildSignUp(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Create a new account'),
            const SizedBox(height: 20),
            buildTextField(_emailController, 'Email', false),
            const SizedBox(height: 10),
            buildTextField(_passwordController, 'Password', true),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20),
            buildErrorMessage(errorMessage),
            _buildRegistrationButton(),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _emailController.clear();
                _passwordController.clear();
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
}
