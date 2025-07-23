import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double? rating;
  final String label;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    required this.label,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Icon(
            index < rating!.floor()
                ? Icons.star
                : index < rating!
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: size,
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating!.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}