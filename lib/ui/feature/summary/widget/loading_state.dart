import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Efeito de esqueleto (skeleton) para simular o carregamento dos dados.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton para os filtros
            Row(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Container(
                      width: 60,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skeleton para o card principal
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),

            // Skeleton para os cards secundários
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(width: 200, height: 20, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 50, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 50, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
