import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSongCard extends StatelessWidget {
  const ShimmerSongCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
                    child: Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
                    child: Container(
                      height: 14,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Shimmer.fromColors(
                    baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
                    child: Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}