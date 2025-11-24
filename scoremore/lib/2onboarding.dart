import 'dart:ui';
import 'package:flutter/material.dart';
import '3authentication.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final Color titleColor = Colors.white;
  final Color highlightBgColor = Colors.transparent;
  final Color skipColor = Colors.white;

  final List<_OnboardingData> pages = [
    _OnboardingData(
      image: 'assets/match.png',
      title: "Record",
      highlight: "Matches",
      color: const Color(0xFF056E53),
      desc: "Keep track of every match with real-time recording and scoring.",
    ),
    _OnboardingData(
      image: 'assets/discuss.png',
      title: "Manage",
      highlight: "Teams & Players",
      color: const Color(0xFF27AE60),
      desc: "Create and manage your teams and players in one place.",
    ),
    _OnboardingData(
      image: 'assets/stats.png',
      title: "Analyze",
      highlight: "Stats",
      color: const Color.fromARGB(255, 90, 214, 183),
      desc: "Dive into detailed match and player analytics.",
    ),
  ];

  void _next() {
    if (_current < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthPage()),
      );
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthPage()),
    );
  }

  Widget glassButton(String text, {VoidCallback? onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(35.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, i) {
          final d = pages[i];
          return Stack(
            fit: StackFit.expand,
            children: [
              /// Background image
              Image.asset(d.image, fit: BoxFit.cover),

              /// Overlay content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Skip button (always at top right)
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: _skip,
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                color: skipColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(blurRadius: 10, color: Colors.black26),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      /// Text positioning changes here
                      if (i == 0) ...[
                        /// -------- FIRST PAGE (top) --------
                        _buildTextBlock(d),
                        const Spacer(),
                      ] else if (i == 1) ...[
                        /// -------- SECOND PAGE (middle) --------
                        const Spacer(),
                        _buildTextBlock(d),
                        const Spacer(),
                      ] else ...[
                        /// -------- THIRD PAGE (bottom) --------
                        const Spacer(),
                        _buildTextBlock(d),
                      ],

                      /// Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (j) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              j == _current
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              size: 17,
                              color: j == _current
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Glass Button
                      glassButton(
                        _current < pages.length - 1 ? "Next" : "Continue",
                        onTap: _next,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextBlock(_OnboardingData d) {
    return Column(
      children: [
        /// Title + Highlight
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 38,
              color: titleColor,
              shadows: const [
                Shadow(blurRadius: 20, color: Color.fromARGB(223, 0, 0, 0)),
              ],
            ),
            children: [
              TextSpan(text: "${d.title} "),
              TextSpan(
                text: d.highlight,
                style: TextStyle(
                  //  color: const Color.fromARGB(255, 33, 52, 220),
                  backgroundColor: highlightBgColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        /// Description
        Text(
          d.desc,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(blurRadius: 10, color: Color.fromARGB(102, 0, 0, 0)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String highlight;
  final Color color;
  final String desc;

  _OnboardingData({
    required this.image,
    required this.title,
    required this.highlight,
    required this.color,
    required this.desc,
  });
}
