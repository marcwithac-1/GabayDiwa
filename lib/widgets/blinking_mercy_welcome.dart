import 'dart:async';
import 'package:flutter/material.dart';

class BlinkingMercy extends StatefulWidget {
  final double? height;
  final double? width;
  final BoxFit fit;
  final String openAsset;
  final String closedAsset;

  const BlinkingMercy({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.openAsset = 'assets/images/mercy_mascot.png',
    this.closedAsset = 'assets/images/mercy_closed.png',
  });

  @override
  State<BlinkingMercy> createState() => _BlinkingMercyState();
}

class _BlinkingMercyState extends State<BlinkingMercy> {
  bool _isEyesClosed = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _startBlinkingLoop();
  }

  void _startBlinkingLoop() {
    // Triggers a blink every 3.5 seconds
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) async {
      if (!mounted) return;

      setState(() {
        _isEyesClosed = true;
      });

      // Keeps eyes closed for 180ms
      await Future.delayed(const Duration(milliseconds: 180));

      if (!mounted) return;

      setState(() {
        _isEyesClosed = false;
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const softPurple = Color(0xFF9D84EC);

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 60),
        child: Image.asset(
          _isEyesClosed ? widget.closedAsset : widget.openAsset,
          key: ValueKey<bool>(_isEyesClosed),
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          alignment: Alignment.bottomCenter,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.pets,
              size: 80,
              color: softPurple,
            );
          },
        ),
      ),
    );
  }
}