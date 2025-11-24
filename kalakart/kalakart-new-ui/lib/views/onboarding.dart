import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "icon": Icons.people_alt,
      "title": "Build Your Network",
      "subtitle": "Connect with Creative Professionals",
      "desc":
          "Showcase your portfolio, find collaborators, discover opportunities, and grow your professional network.",
      "color": Colors.orange,
      "color2": Colors.deepOrange,
    },
    {
      "icon": Icons.shopping_bag_outlined,
      "title": "Marketplace at Your Fingertips",
      "subtitle": "Rent, Buy, Sell Creative Equipment",
      "desc":
          "Access cameras, instruments, studios, costumes, and everything you need for your creative projects.",
      "color": Colors.orange.shade300,
      "color2": Colors.orange.shade600,
    },
    {
      "icon": Icons.work_outline,
      "title": "Manage Projects & Finances",
      "subtitle": "Professional Tools for Creatives",
      "desc":
          "Track projects, generate invoices, manage payments with our built-in Kalaakart Wallet and professional tools.",
      "color": Colors.amber,
      "color2": Colors.orange,
    },
    {
      "icon": Icons.flash_on,
      "title": "AI-Powered Assistance",
      "subtitle": "Smart Tools for Creative Work",
      "desc":
          "Generate budgets, scout locations, review contracts, and optimize your portfolio with our AI assistant.",
      "color": Colors.orange.shade100,
      "color2": Colors.deepOrange,
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() => _currentPage++);
    } else {
      // Navigate to login page when on the last page
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _skip() {
    // Navigate to login page when skip is pressed
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.brown),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [page["color"], page["color2"]],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(
                          page["icon"],
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        page["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page["subtitle"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        page["desc"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage ? Colors.brown : Colors.brown[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.brown),
                      onPressed: _currentPage == 0 ? null : _prevPage,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _nextPage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? "Get Started" : "Next",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Icon(isLast ? Icons.check : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}