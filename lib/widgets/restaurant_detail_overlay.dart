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
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(restaurant.category).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  restaurant.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getCategoryColor(restaurant.category),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  
                  // 詳細情報
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 評価
                          if (restaurant.overallRating != null) 
                            _buildDetailRow(
                              Icons.star,
                              '評価',
                              '${restaurant.overallRating!.toStringAsFixed(1)} / 5.0',
                            ),
                          
                          if (restaurant.overallRating != null) 
                            const SizedBox(height: 16),
                          
                          // 住所
                          _buildDetailRow(
                            Icons.location_on,
                            '住所',
                            restaurant.address,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 電話番号
                          if (restaurant.phoneNumber.isNotEmpty)
                            _buildDetailRow(
                              Icons.phone,
                              '電話番号',
                              restaurant.phoneNumber,
                            ),
                          
                          if (restaurant.phoneNumber.isNotEmpty)
                            const SizedBox(height: 16),
                          
                          // 営業時間
                          if (restaurant.openingHours.isNotEmpty)
                            _buildDetailRow(
                              Icons.access_time,
                              '営業時間',
                              restaurant.openingHours,
                            ),
                          
                          if (restaurant.openingHours.isNotEmpty)
                            const SizedBox(height: 16),
                          
                          // 価格帯
                          if (restaurant.priceRange.isNotEmpty)
                            _buildDetailRow(
                              Icons.payment,
                              '価格帯',
                              restaurant.priceRange,
                            ),
                          
                          if (restaurant.priceRange.isNotEmpty)
                            const SizedBox(height: 16),
                          
                          // 説明
                          if (restaurant.description.isNotEmpty)
                            _buildDetailRow(
                              Icons.info_outline,
                              '店舗について',
                              restaurant.description,
                            ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String content, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'イタリアン':
      case 'italian':
        return Colors.orange;
      case '日本料理':
      case 'japanese':
        return Colors.red;
      case 'カフェ':
      case 'cafe':
        return Colors.brown;
      case 'ラーメン':
      case 'ramen':
        return Colors.amber;
      case 'フレンチ':
      case 'french':
        return Colors.purple;
      case '中華料理':
      case 'chinese':
        return Colors.red;
      case '韓国料理':
      case 'korean':
        return Colors.deepOrange;
      case 'インド料理':
      case 'indian':
        return Colors.orange;
      case 'タイ料理':
      case 'thai':
        return Colors.green;
      case 'メキシコ料理':
      case 'mexican':
        return Colors.lime;
      case 'アメリカ料理':
      case 'american':
        return Colors.blue;
      case 'バー':
      case 'bar':
        return Colors.indigo;
      case 'ファストフード':
      case 'fastfood':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}