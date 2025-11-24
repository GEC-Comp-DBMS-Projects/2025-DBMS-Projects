// widgets/custom_loader.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomLoader extends StatefulWidget {
  final Color primaryColor;
  final Color darkColor;
  final Color lightColor;
  final String? loadingText;

  const CustomLoader({
    Key? key,
    required this.primaryColor,
    required this.darkColor,
    required this.lightColor, 
    this.loadingText,
  }) : super(key: key);

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _dotsController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true); 

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 130, 
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              widget.primaryColor.withOpacity(0.0),
                              widget.primaryColor.withOpacity(0.8),
                              widget.darkColor.withOpacity(0.6),
                              widget.primaryColor.withOpacity(0.0), 
                            ],
                            stops: const [0.0, 0.3, 0.6, 1.0],
                          ),
                          border: Border.all(color: widget.primaryColor.withOpacity(0.1), width: 2),
                        ),
                        child: Align( 
                          alignment: FractionalOffset(
                            (_rotationAnimation.value * 2) % 1.0, 
                            (_rotationAnimation.value * 2) % 1.0,
                          ),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.primaryColor.withOpacity(0.7),
                              boxShadow: [BoxShadow(color: widget.primaryColor.withOpacity(0.5), blurRadius: 8)],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Inner circle (background for logo)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.lightColor, // Use lightColor for inner background
                    boxShadow: [
                      BoxShadow(
                        color: widget.darkColor.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                // Pulsing CampusNest logo
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Image.asset(
                          'assets/images/campusnest_logo.png', 
                          width: 70, // Slightly larger logo
                          height: 70,
                          color: widget.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Loading text with animated dots
          AnimatedBuilder(
            animation: _dotsController,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.loadingText ?? 'Loading CampusNest',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.darkColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildAnimatedDots(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotsController,
          builder: (context, child) {
            final delay = index * 0.2; // Stagger the animation of each dot
            final value = (_dotsController.value - delay);
            double opacity = 0.0;
            if (value >= 0 && value <= 0.5) {
              opacity = value * 2; // Fade in
            } else if (value > 0.5 && value <= 1.0) {
              opacity = (1 - value) * 2; // Fade out
            }
            
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0), // Ensure opacity stays between 0 and 1
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0), // Smaller gap between dots
                child: Text(
                  '.',
                  style: GoogleFonts.montserrat(
                    fontSize: 20, // Keep dots visually prominent
                    fontWeight: FontWeight.w800, // Make dots bolder
                    color: widget.primaryColor, // Use primaryColor for dots for emphasis
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}