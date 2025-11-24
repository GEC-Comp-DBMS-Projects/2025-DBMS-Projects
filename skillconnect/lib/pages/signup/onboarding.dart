import 'package:flutter/material.dart';
import 'package:skillconnect/pages/signup/signup.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF666666);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const UserTypeSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // --- Page 1: SkillConnect ---
                  _buildPage(
                    title: "SkillConnect",
                    subtitle:
                        "SkillConnect at your service. One app for all your home repair and handyman needs.",
                    isLogo: true,
                  ),

                  // --- Page 2: Easy Process ---
                  _buildPage(
                    title: "Easy Process",
                    subtitle:
                        "Booking made effortless. Find and hire the right handyman in just a few taps.",
                    imageWidget: Image.asset(
                      'assets/images/1.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Easy Process',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // --- Page 3: Fast Transportation ---
                  _buildPage(
                    title: "Fast Transportation",
                    subtitle:
                        "Faster transport, quicker service. Your handyman arrives on time, every time.",
                    imageWidget: Image.asset(
                      'assets/images/2.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Fast Transportation',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // --- Page 4: Expert People ---
                  _buildPage(
                    title: "Expert People",
                    subtitle:
                        "Skilled hands, trusted service. Get help from trained and verified experts.",
                    imageWidget: Image.asset(
                      'assets/images/3.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Expert People',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 30.0),
              child: Column(
                children: [
                  _buildPageIndicator(),
                  const SizedBox(height: 40),
                  _buildBottomButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    Widget? imageWidget,
    bool isLogo = false,
  }) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 10,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.nunito(
                        color: grayBlue.withAlpha(200),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: isLogo
                      ? Container(
                          width: 220, // Logo size
                          height: 220,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Image.asset(
                            'assets/images/skillconnect_logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.build_circle,
                                color: Colors.white,
                                size: 80,
                              );
                            },
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(30.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: imageWidget,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    color: textLight,
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: _currentPage == index ? darkBlue : paleBlue,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButton() {
    bool isLastPage = _currentPage == 3;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLastPage
            ? _completeOnboarding // Go to home/signup
            : () {
                // Go to next page
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Text(
          isLastPage ? 'Get Started' : 'Next',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
