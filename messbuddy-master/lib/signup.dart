import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Extra fields
  final _nameController = TextEditingController();
  final _rollNoController = TextEditingController();
  String? _selectedDept;
  final _hostelNoController = TextEditingController();
  final _roomNoController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _pulseController;
  
  // Matching the color palette from the other pages
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardBackgroundColor = const Color(0xFF161616);
  final Color _cardBackgroundAltColor = const Color(0xFF1A1A1A);
  final Color _primaryColor = const Color(0xFFFF2D55); // Hot pink
  final Color _accentColor = const Color(0xFF04E9CC); // Refined mint
  final Color _secondaryAccent = const Color(0xFF7F5AF7); // Purple
  final Color _tertiaryAccent = const Color(0xFFFFD60A); // Gold accent
  final Color _textColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;
  
  // Department options
  final List<String> _departments = [
    "computer",
    "it",
    "etc",
    "ene",
    "mechanical",
    "civil",
    "mining",
    "vlsi",
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _rollNoController.dispose();
    _hostelNoController.dispose();
    _roomNoController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create auth account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Save extra details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'roll_no': _rollNoController.text.trim(),
        'dept': _selectedDept,
        'hostel_no': _hostelNoController.text.trim(),
        'room_no': _roomNoController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "signup successful! please login.",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _cardBackgroundAltColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'ok',
              textColor: _accentColor,
              onPressed: () {},
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "signup failed";
      
      // Provide more user-friendly error messages
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "email already in use, try logging in instead";
          break;
        case 'invalid-email':
          errorMessage = "please enter a valid email address";
          break;
        case 'weak-password':
          errorMessage = "password is too weak, try a stronger password";
          break;
        default:
          errorMessage = e.message ?? "an error occurred during signup";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "an unexpected error occurred",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  _backgroundColor.withOpacity(0.9),
                  _backgroundColor,
                ],
              ),
            ),
          ),
          
          // Background accent circles
          Positioned(
            top: -50,
            right: -30,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_primaryColor, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_accentColor, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Logo with animated border
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                _primaryColor,
                                _accentColor,
                                _secondaryAccent,
                                _primaryColor,
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                              startAngle: _pulseController.value * 3.14 * 2,
                              endAngle: (1 + _pulseController.value) * 3.14 * 2,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _cardBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: Image.asset(
                                'assets/logo.jpg',
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.restaurant_rounded, 
                                  size: 42, 
                                  color: _accentColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Welcome text
                    Text(
                      'create your account',
                      style: GoogleFonts.poppins(
                        color: _textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'join the messbuddy community ✨',
                      style: GoogleFonts.poppins(
                        color: _textSecondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    
                    // Signup form
                    Container(
                      decoration: BoxDecoration(
                        color: _cardBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Card header
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [_primaryColor, _accentColor],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'signup',
                                    style: GoogleFonts.poppins(
                                      color: _textColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Personal Information Section
                              _buildSectionTitle('personal information', Icons.person_outline_rounded),
                              const SizedBox(height: 16),
                              
                              // Name Field
                              _buildTextField(
                                controller: _nameController,
                                hint: 'full name',
                                icon: Icons.badge_outlined,
                                validator: (value) => value == null || value.isEmpty ? "name is required" : null,
                              ),
                              const SizedBox(height: 16),
                              
                              // Email Field
                              _buildTextField(
                                controller: _emailController,
                                hint: 'email address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "email is required";
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return "enter a valid email";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Roll No Field
                              _buildTextField(
                                controller: _rollNoController,
                                hint: 'roll number',
                                icon: Icons.assignment_ind_outlined,
                                validator: (value) => value == null || value.isEmpty ? "roll number is required" : null,
                              ),
                              const SizedBox(height: 24),
                              
                              // College Information Section
                              _buildSectionTitle('college information', Icons.school_outlined),
                              const SizedBox(height: 16),
                              
                              // Department Dropdown
                              _buildDropdown(
                                value: _selectedDept,
                                hint: 'select department',
                                icon: Icons.business_outlined,
                                items: _departments,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDept = value;
                                  });
                                },
                                validator: (value) => value == null || value.isEmpty ? "department is required" : null,
                              ),
                              const SizedBox(height: 16),
                              
                              // Hostel & Room Row
                              Row(
                                children: [
                                  // Hostel Number
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _hostelNoController,
                                      hint: 'hostel no',
                                      icon: Icons.apartment_rounded,
                                      validator: (value) => value == null || value.isEmpty ? "required" : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Room Number
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _roomNoController,
                                      hint: 'room no',
                                      icon: Icons.door_front_door_outlined,
                                      validator: (value) => value == null || value.isEmpty ? "required" : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Password Section
                              _buildSectionTitle('security', Icons.lock_outline_rounded),
                              const SizedBox(height: 16),
                              
                              // Password Field
                              _buildTextField(
                                controller: _passwordController,
                                hint: 'password',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                toggleObscureText: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "password is required";
                                  }
                                  if (value.length < 6) {
                                    return "password must be at least 6 characters";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Confirm Password Field
                              _buildTextField(
                                controller: _confirmPasswordController,
                                hint: 'confirm password',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                obscureText: _obscureConfirmPassword,
                                toggleObscureText: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "please confirm your password";
                                  }
                                  if (value != _passwordController.text) {
                                    return "passwords do not match";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              
                              // Signup button with animation
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      gradient: LinearGradient(
                                        colors: [
                                          _primaryColor,
                                          _secondaryAccent,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _primaryColor.withOpacity(0.2 + (_pulseController.value * 0.1)),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _signup,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        disabledBackgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: _isLoading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: _textColor,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'create account',
                                            style: GoogleFonts.poppins(
                                              color: _textColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Login link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'already have an account? ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: _textSecondaryColor,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                      );
                                    },
                                    child: Text(
                                      'login',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: _accentColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Section title builder
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _secondaryAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _secondaryAccent,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  // Custom text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? toggleObscureText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _cardBackgroundAltColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.poppins(
              color: _textColor,
              fontSize: 15,
            ),
            obscureText: isPassword && obscureText != null ? obscureText : false,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: _textSecondaryColor.withOpacity(0.7),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: _textSecondaryColor,
                size: 20,
              ),
              suffixIcon: isPassword && toggleObscureText != null
                ? IconButton(
                    icon: Icon(
                      obscureText! ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: _textSecondaryColor,
                      size: 20,
                    ),
                    onPressed: toggleObscureText,
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              errorStyle: GoogleFonts.poppins(
                color: _primaryColor,
                fontSize: 12,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
  
  // Custom dropdown builder
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackgroundAltColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSecondaryColor),
          iconSize: 24,
          elevation: 16,
          dropdownColor: _cardBackgroundAltColor,
          style: GoogleFonts.poppins(
            color: _textColor,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: _textSecondaryColor.withOpacity(0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: _textSecondaryColor,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            errorStyle: GoogleFonts.poppins(
              color: _primaryColor,
              fontSize: 12,
            ),
          ),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(
                  color: _textColor,
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
        ),
      ),
    );
  }
}