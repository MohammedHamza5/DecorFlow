import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton loader for the dashboard screen.
/// Provides a smooth, premium loading experience that matches the actual UI layout.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: [
              // 1. Header Skeleton
              _skeletonBox(height: 64, borderRadius: 16),
              const SizedBox(height: 14),

              // 2. Stats Grid Skeleton (4 cards)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 700;
                  return isWide
                      ? Row(
                          children: List.generate(
                            4,
                            (i) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: i == 3 ? 0 : 6,
                                  right: i == 0 ? 0 : 6,
                                ),
                                child: _skeletonBox(
                                  height: 96,
                                  borderRadius: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _skeletonBox(
                                    height: 90,
                                    borderRadius: 14,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _skeletonBox(
                                    height: 90,
                                    borderRadius: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _skeletonBox(
                                    height: 90,
                                    borderRadius: 14,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _skeletonBox(
                                    height: 90,
                                    borderRadius: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 14),

              // 3. Quick Actions Skeleton
              _skeletonBox(height: 110, borderRadius: 18),
              const SizedBox(height: 14),

              // 4. Counter Search Bar Skeleton
              _skeletonBox(height: 120, borderRadius: 18),
              const SizedBox(height: 14),

              // 5. Activity Cards Skeleton
              _skeletonBox(height: 240, borderRadius: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeletonBox({required double height, required double borderRadius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
