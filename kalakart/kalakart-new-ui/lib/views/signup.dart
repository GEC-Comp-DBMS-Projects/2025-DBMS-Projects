import 'package:flutter/material.dart';
import 'package:kart_app/controllers/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo - Using the new Kalaakart logo
                    const KalaakartLogo(size: 48, showText: true),
                    const SizedBox(height: 32),

                    // Welcome Text
                    Text(
                      "Create your account!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Card Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Login/Sign Up Toggle
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(26),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Social Login Buttons
                         // _socialButton("Continue with Google", icon: Icons.public),
                          //const SizedBox(height: 12),
                          //_socialButton("Continue with Apple", icon: Icons.apple),
                          //const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text("or", style: TextStyle(color: Colors.grey.shade600)),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Full Name Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                                hintText: "Full Name",
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Name cannot be empty.";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade600),
                                hintText: "Email Address",
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email cannot be empty.";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 8) {
                                  return "Password should have at least 8 characters.";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  AuthService()
                                      .createAccountWithEmail(
                                          _nameController.text, _emailController.text, _passwordController.text)
                                      .then((value) {
                                    if (value == "Account Created") {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Account Created")));
                                      Navigator.restorablePushNamedAndRemoveUntil(context, "/home", (route) => false);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(value, style: const TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.red.shade400,
                                      ));
                                    }
                                  });
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(color: Colors.grey.shade700)),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text("Login", style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String text, {required IconData icon}) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// Logo widget
class KalaakartLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const KalaakartLogo({Key? key, this.size = 48, this.showText = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: CustomPaint(painter: _KalaakartTreePainter()),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Kalaakart", style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.bold, color: Colors.brown.shade800)),
              Text("CREATIVE HUB", style: TextStyle(fontSize: size * 0.23, fontWeight: FontWeight.w500, color: Colors.brown.shade600, letterSpacing: 1.2)),
            ],
          ),
        ],
      ],
    );
  }
}

class _KalaakartTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final trunkPaint = Paint()..color = const Color(0xFF8B4513)..style = PaintingStyle.fill;
    final trunkPath = Path()
      ..moveTo(center.dx - size.width * 0.08, center.dy + size.height * 0.15)
      ..lineTo(center.dx - size.width * 0.05, center.dy - size.height * 0.05)
      ..lineTo(center.dx + size.width * 0.05, center.dy - size.height * 0.05)
      ..lineTo(center.dx + size.width * 0.08, center.dy + size.height * 0.15)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final leafColors = [
      const Color(0xFFFF6B6B), const Color(0xFFFF9F43), const Color(0xFFFECA57), const Color(0xFF48C9B0),
      const Color(0xFF5F27CD), const Color(0xFFEE5A6F), const Color(0xFF00D2D3), const Color(0xFFFFA502),
    ];

    final leafPositions = [
      Offset(center.dx, center.dy - size.height * 0.25),
      Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.2),
      Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.2),
      Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.1),
      Offset(center.dx + size.width * 0.2, center.dy - size.height * 0.1),
      Offset(center.dx - size.width * 0.15, center.dy),
      Offset(center.dx + size.width * 0.15, center.dy),
      Offset(center.dx - size.width * 0.1, center.dy + size.height * 0.05),
      Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.05),
    ];

    for (int i = 0; i < leafPositions.length; i++) {
      final leafPaint = Paint()..color = leafColors[i % leafColors.length]..style = PaintingStyle.fill;
      final leafPath = Path();
      final pos = leafPositions[i];
      final leafSize = size.width * 0.08;
      leafPath.moveTo(pos.dx, pos.dy - leafSize);
      leafPath.quadraticBezierTo(pos.dx + leafSize * 0.7, pos.dy - leafSize * 0.5, pos.dx + leafSize * 0.3, pos.dy + leafSize * 0.3);
      leafPath.quadraticBezierTo(pos.dx, pos.dy + leafSize * 0.5, pos.dx - leafSize * 0.3, pos.dy + leafSize * 0.3);
      leafPath.quadraticBezierTo(pos.dx - leafSize * 0.7, pos.dy - leafSize * 0.5, pos.dx, pos.dy - leafSize);
      canvas.drawPath(leafPath, leafPaint);
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      dotPaint.color = leafColors[(i * 2) % leafColors.length].withOpacity(0.6);
      canvas.drawCircle(Offset(center.dx + (i - 2) * size.width * 0.08, center.dy - size.height * 0.15 + (i % 2) * size.height * 0.05), size.width * 0.02, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}