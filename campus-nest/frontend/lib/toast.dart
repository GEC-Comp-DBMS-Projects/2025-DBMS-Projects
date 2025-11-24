import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ToastType {
  success,
  error,
}

class AppToast {
  static OverlayEntry? _overlayEntry;
  static final _key = GlobalKey<_ToastWidgetState>();

  AppToast._();

  static void success(BuildContext context, String message) {
    _show(context, message, ToastType.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, ToastType.error);
  }

  static void _show(BuildContext context, String message, ToastType type) {
    if (_overlayEntry != null) {
      _dismiss();
    }

    final overlay = Overlay.of(context);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        key: _key,
        message: message,
        type: type,
        onDismissed: () => _dismiss(),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void _dismiss() {
    _key.currentState?.dismiss();
  }

  static void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required Key key,
    required this.message,
    required this.type,
    required this.onDismissed,
  }) : super(key: key);

  final String message;
  final ToastType type;
  final VoidCallback onDismissed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        AppToast._removeOverlay();
      }
    });

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dismiss() {
    if (mounted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color iconColor;
    final IconData icon;

    switch (widget.type) {
      case ToastType.success:
        backgroundColor = const Color(0xFF5D9493); 
        iconColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        backgroundColor = Colors.red.shade700;
        iconColor = Colors.white;
        icon = Icons.highlight_off;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _controller,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(50),
            color: backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
}