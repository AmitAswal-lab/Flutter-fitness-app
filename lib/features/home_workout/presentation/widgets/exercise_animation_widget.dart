import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:flutter/material.dart';

/// Widget to display exercise animation/GIF during active workout
/// Shows GIF from URL if available, otherwise shows animated placeholder
class ExerciseAnimationWidget extends StatefulWidget {
  final Exercise exercise;
  final double size;

  const ExerciseAnimationWidget({
    super.key,
    required this.exercise,
    this.size = 200,
  });

  @override
  State<ExerciseAnimationWidget> createState() =>
      _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gifUrl = widget.exercise.imageUrl;
    final hasGif = gifUrl != null && gifUrl.isNotEmpty && !_imageError;

    return Container(
      height: widget.size,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _getCategoryColor(
          widget.exercise.category,
        ).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getCategoryColor(
            widget.exercise.category,
          ).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: hasGif ? _buildGifDisplay(gifUrl!) : _buildAnimatedPlaceholder(),
      ),
    );
  }

  Widget _buildGifDisplay(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getCategoryColor(
                  widget.exercise.category,
                ).withValues(alpha: 0.1),
                _getCategoryColor(
                  widget.exercise.category,
                ).withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
        // GIF image
        Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: _getCategoryColor(widget.exercise.category),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fall back to placeholder on error
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _imageError = true);
            });
            return _buildAnimatedPlaceholder();
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedPlaceholder() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing background circles
            ...List.generate(3, (index) {
              final delay = index * 0.2;
              final pulseValue = ((_pulseAnimation.value + delay) % 1.0);
              return Container(
                width: widget.size * (0.3 + pulseValue * 0.4),
                height: widget.size * (0.3 + pulseValue * 0.4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getCategoryColor(
                    widget.exercise.category,
                  ).withValues(alpha: 0.1 * (1 - pulseValue)),
                ),
              );
            }),
            // Main icon with scale animation
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getCategoryColor(
                    widget.exercise.category,
                  ).withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: _getCategoryColor(
                        widget.exercise.category,
                      ).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.exercise.category.icon,
                    style: TextStyle(fontSize: widget.size * 0.15),
                  ),
                ),
              ),
            ),
            // Exercise type indicator
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.exercise.isTimeBased ? Icons.timer : Icons.repeat,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.exercise.isTimeBased ? 'TIME BASED' : 'REP BASED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.cardio:
        return Colors.orange;
      case ExerciseCategory.strength:
        return AppColors.primary;
      case ExerciseCategory.hiit:
        return Colors.red;
      case ExerciseCategory.yoga:
        return Colors.purple;
      case ExerciseCategory.stretching:
        return Colors.teal;
      case ExerciseCategory.calisthenics:
        return AppColors.success;
    }
  }
}
