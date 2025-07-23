import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantDetailOverlay extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onClose;

  const RestaurantDetailOverlay({
    super.key,
    required this.restaurant,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {}, // 内部のタップでは閉じない
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // ハンドル
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // ヘッダー
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onClose,
                            child: const Icon(Icons.close, size: 24),
                          ),
                        ],
                      ),
                    ),
                    // 内容
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 評価
                            if (restaurant.overallRating != null) ...[
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      index < restaurant.overallRating!.floor()
                                          ? Icons.star
                                          : index < restaurant.overallRating!
                                              ? Icons.star_half
                                              : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    restaurant.overallRating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            // カテゴリ
                            _buildInfoRow('カテゴリ', restaurant.category),
                            const SizedBox(height: 12),
                            // 住所
                            _buildInfoRow('住所', restaurant.address),
                            const SizedBox(height: 12),
                            // 電話番号
                            _buildInfoRow('電話番号', restaurant.phoneNumber),
                            const SizedBox(height: 12),
                            // 営業時間
                            _buildInfoRow('営業時間', restaurant.openingHours),
                            const SizedBox(height: 16),
                            // 説明
                            if (restaurant.description.isNotEmpty) ...[
                              const Text(
                                '店舗について',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                restaurant.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}