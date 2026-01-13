import 'package:flutter/material.dart';

import '../../main.dart';

class CustomToast {
  static final List<OverlayEntry> _overlayEntries = <OverlayEntry>[];

  static void show(
      String message, {
        bool isSuccess = true,
        bool isWarning = false,
        Duration duration = const Duration(seconds: 3),
      }) {
    final context = navigatorKey.currentState?.overlay?.context;
    final overlay = navigatorKey.currentState?.overlay;

    Color backgroundColor;

    // Determine the background color
    if (isWarning) {
      backgroundColor = Colors.orange;
    } else {
      backgroundColor = isSuccess ? Colors.green : Color(0xFFE50914);
    }
    if (overlay == null || context == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 20,
        right: 10,
        child: _ToastWidget(
          message: message,
          backgroundColor: backgroundColor,
          textColor: Colors.white,
          isSuccess: isSuccess,
        ),
      ),
    );

    _overlayEntries.add(overlayEntry);
    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
      _overlayEntries.remove(overlayEntry);
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final bool isSuccess;

  const _ToastWidget({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.isSuccess,
  }) : super(key: key);

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSuccess ? Icons.check_circle : Icons.error,
                color: widget.textColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.message,
                style: TextStyle(color: widget.textColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
