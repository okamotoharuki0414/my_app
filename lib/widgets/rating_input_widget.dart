import 'package:flutter/material.dart';
import '../models/rating_input.dart';
import '../constants/app_colors.dart';

class RatingInputWidget extends StatefulWidget {
  final RatingInput rating;
  final Function(RatingInput) onRatingChanged;

  const RatingInputWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  State<RatingInputWidget> createState() => _RatingInputWidgetState();
}

class _RatingInputWidgetState extends State<RatingInputWidget> {
  late RatingInput _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '評価を入力',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRatingRow('総合', _rating.overall, (rating) {
            setState(() {
              _rating = _rating.copyWith(overall: rating);
            });
            widget.onRatingChanged(_rating);
          }),
          const SizedBox(height: 12),
          _buildRatingRow('味', _rating.food, (rating) {
            setState(() {
              _rating = _rating.copyWith(food: rating);
            });
            widget.onRatingChanged(_rating);
          }),
          const SizedBox(height: 12),
          _buildRatingRow('サービス', _rating.service, (rating) {
            setState(() {
              _rating = _rating.copyWith(service: rating);
            });
            widget.onRatingChanged(_rating);
          }),
          const SizedBox(height: 12),
          _buildRatingRow('コスパ', _rating.value, (rating) {
            setState(() {
              _rating = _rating.copyWith(value: rating);
            });
            widget.onRatingChanged(_rating);
          }),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double? currentRating, Function(double?) onTap) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: List.generate(5, (index) {
              final starValue = (index + 1).toDouble();
              final isFilled = currentRating != null && starValue <= currentRating;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    print('Star tapped: $starValue, current: $currentRating');
                    if (currentRating == starValue) {
                      // 同じ星をタップしたらクリア
                      onTap(null);
                    } else {
                      onTap(starValue);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isFilled ? Icons.star : Icons.star_border,
                      color: isFilled ? Colors.amber : Colors.grey[400],
                      size: 32,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}