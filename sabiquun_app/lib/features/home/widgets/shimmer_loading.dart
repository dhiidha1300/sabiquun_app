import 'package:flutter/material.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Shimmer Loading Widget for skeleton screens
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.child,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                AppColors.greyLight,
                AppColors.white,
                AppColors.greyLight,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer Box for placeholder elements
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Statistics Card Shimmer
class StatisticsCardShimmer extends StatelessWidget {
  const StatisticsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ShimmerLoading(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(width: 150, height: 20),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ShimmerBox(
                          width: 60,
                          height: 60,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        const SizedBox(height: 12),
                        const ShimmerBox(width: 100, height: 12),
                        const SizedBox(height: 4),
                        const ShimmerBox(width: 60, height: 14),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        ShimmerBox(
                          width: 32,
                          height: 32,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        const SizedBox(height: 12),
                        const ShimmerBox(width: 80, height: 12),
                        const SizedBox(height: 4),
                        const ShimmerBox(width: 50, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const ShimmerBox(width: double.infinity, height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature Card Shimmer
class FeatureCardShimmer extends StatelessWidget {
  const FeatureCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ShimmerLoading(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerBox(
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(32),
              ),
              const SizedBox(height: 12),
              const ShimmerBox(width: 100, height: 14),
              const SizedBox(height: 4),
              const ShimmerBox(width: 80, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// Activity Card Shimmer
class ActivityCardShimmer extends StatelessWidget {
  const ActivityCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ShimmerLoading(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerBox(
                      width: 36,
                      height: 36,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    const Spacer(),
                    const ShimmerBox(width: 60, height: 20),
                  ],
                ),
                const SizedBox(height: 12),
                const ShimmerBox(width: 150, height: 14),
                const SizedBox(height: 8),
                const ShimmerBox(width: double.infinity, height: 10),
                const SizedBox(height: 4),
                const ShimmerBox(width: 200, height: 10),
                const Spacer(),
                const ShimmerBox(width: 80, height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
