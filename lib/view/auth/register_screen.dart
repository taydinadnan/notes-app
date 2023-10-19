import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/provider/firebase_authentication.dart';
import 'package:notes_app/view/auth/login_screen.dart';
import 'package:notes_app/view/auth/widgets/animated_back_ground.dart';
import 'package:notes_app/view/auth/widgets/bottom_slide_animation.dart';
import 'package:notes_app/view/auth/widgets/top_slide_animation.dart';
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
  bool isAnimatingIn = true;
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

  Widget _buildLoginButton() {
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
              return const LoginScreen();
            },
          ),
        );
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          isAnimatingIn = false;
        });
      },
      child: const Text('Already have an account? Login'),
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
          buildSignUp(context),
          const AnimatedBackGround(),
          TopSlideAnimation(isAnimatingIn: isAnimatingIn, context: context),
          BottomSlideAnimation(isAnimatingIn: isAnimatingIn, context: context),
        ],
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
            _buildLoginButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
