import 'dart:ui';
import 'package:flutter/material.dart';
import '4home.dart';
import '2onboarding.dart';
import 'auth_service.dart'; // Import the auth service

class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();

  bool showLoginForm = false;
  bool showSignupForm = false;
  bool isLoading = false;

  // Controllers for text fields
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController =
      TextEditingController();
  final TextEditingController _signupConfirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _showGlassDialog(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isError ? Colors.redAccent : Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: Size(100, 40),
                    ),
                    child: Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () async {
                      if (emailController.text.isEmpty) {
                        _showGlassDialog(
                          "Error",
                          "Please enter your email address.",
                          isError: true,
                        );
                        return;
                      }
                      Navigator.pop(context);
                      try {
                        await _authService.sendPasswordResetEmail(
                          emailController.text,
                        );
                        _showGlassDialog(
                          "Success",
                          "Password reset link sent to your email.",
                        );
                      } catch (e) {
                        _showGlassDialog(
                          "Error",
                          "Unable to send reset link. Check your email.",
                          isError: true,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: Size(double.infinity, 44),
                    ),
                    child: Text(
                      "Send Reset Link",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_loginEmailController.text.isEmpty ||
        _loginPasswordController.text.isEmpty) {
      _showGlassDialog("Error", "Please fill in all fields.", isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      await _authService.signInWithEmailPassword(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ScoreMoreHome()),
        );
      }
    } catch (e) {
      _showGlassDialog("Login Failed", e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    if (_signupEmailController.text.isEmpty ||
        _signupPasswordController.text.isEmpty ||
        _signupConfirmPasswordController.text.isEmpty ||
        _signupNameController.text.isEmpty) {
      _showGlassDialog("Error", "Please fill in all fields.", isError: true);
      return;
    }
    if (_signupPasswordController.text !=
        _signupConfirmPasswordController.text) {
      _showGlassDialog("Error", "Passwords do not match.", isError: true);
      return;
    }
    if (_signupPasswordController.text.length < 6) {
      _showGlassDialog(
        "Error",
        "Password must be at least 6 characters.",
        isError: true,
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      await _authService.signUpWithEmailPassword(
        _signupEmailController.text,
        _signupPasswordController.text,
        _signupNameController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ScoreMoreHome()),
        );
      }
    } catch (e) {
      _showGlassDialog("Signup Failed", e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => isLoading = true);
    try {
      await _authService.signInAsGuestLocally();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ScoreMoreHome()),
        );
      }
    } catch (e) {
      _showGlassDialog("Error", e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _loginForm() {
    return Column(
      children: [
        SizedBox(height: 20),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Colors.white),
          decoration: _inputDecoration("Email"),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _loginPasswordController,
          style: TextStyle(color: Colors.white),
          decoration: _inputDecoration("Password"),
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleForgotPassword,
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        _actionButton("Log in", _handleLogin),
      ],
    );
  }

  Widget _signupForm() {
    return Column(
      children: [
        SizedBox(height: 20),
        TextField(
          controller: _signupNameController,
          style: TextStyle(color: Colors.white),
          decoration: _inputDecoration("Name"),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _signupEmailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Colors.white),
          decoration: _inputDecoration("Email"),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _signupPasswordController,
          style: TextStyle(color: Colors.white),
          decoration: _inputDecoration("Password"),
          obscureText: true,
        ),
        SizedBox(height: 16),
        TextField(
          controller: _signupConfirmPasswordController,
          style: TextStyle(color: Colors.white),
          decoration: _inputDecoration("Confirm Password"),
          obscureText: true,
        ),
        SizedBox(height: 24),
        _actionButton("Sign up", _handleSignup),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 44),
        backgroundColor: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => OnboardingScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/batball.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient overlay to hide yellow/black line
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200, // adjust based on how much you want to fade
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),

          // Main content - FIXED: Wrapped in SingleChildScrollView
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.all(35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Text(
                        "scoremore",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 20,
                              color: Color.fromARGB(223, 0, 0, 0),
                            ),
                          ],
                          fontSize: 48,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Level Up Your Game.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Spacer(),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: showLoginForm
                            ? _loginForm()
                            : _actionButton("Log in", () {
                                setState(() {
                                  showLoginForm = !showLoginForm;
                                  showSignupForm = false;
                                });
                              }),
                      ),
                      SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: showSignupForm
                            ? _signupForm()
                            : OutlinedButton(
                                key: ValueKey("signup"),
                                onPressed: () {
                                  setState(() {
                                    showSignupForm = !showSignupForm;
                                    showLoginForm = false;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  minimumSize: Size(double.infinity, 44),
                                ),
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 18),
                      _actionButton("Continue as Guest", _handleGuestSignIn),
                      SizedBox(height: 35), // Extra padding at bottom
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
