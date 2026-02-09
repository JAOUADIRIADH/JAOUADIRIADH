import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceWave extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double size;

  const VoiceWave({
    super.key,
    required this.isActive,
    required this.color,
    this.size = 100.0,
  });

  @override
  State<VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<VoiceWave> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];
  final int _barsCount = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Créer des animations pour chaque barre
    for (int i = 0; i < _barsCount; i++) {
      final start = 0.1 + 0.2 * (i / _barsCount);
      final end = start + 0.6;
      
      _animations.add(
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: start, end: end)
                .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: end, end: start)
                .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              i / _barsCount,
              (i + 1) / _barsCount,
              curve: Curves.linear,
            ),
          ),
        ),
      );
    }

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _barsCount,
              (index) => _buildBar(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBar(int index) {
    final height = widget.isActive
        ? _animations[index].value * (widget.size / 2)
        : (0.1 + 0.1 * math.sin(index * 0.5)) * (widget.size / 2);
    
    return Container(
      width: widget.size / (_barsCount * 3),
      height: height,
      decoration: BoxDecoration(
        color: widget.color.withOpacity(widget.isActive ? 1.0 : 0.5),
        borderRadius: BorderRadius.circular(widget.size / 20),
      ),
    );
  }
}
