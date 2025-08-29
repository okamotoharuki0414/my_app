import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantMapDetailOverlay extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onClose;

  const RestaurantMapDetailOverlay({
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
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onClose,
                            child: const Icon(Icons.close, size: 28),
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
                            // レストラン画像
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(restaurant.images.isNotEmpty 
                                      ? restaurant.images.first 
                                      : 'https://placehold.co/400x200'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // 評価と基本情報
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 24),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.overallRating?.toStringAsFixed(1) ?? '0.0',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${restaurant.reviewCount}件のレビュー)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  restaurant.priceRange,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // カテゴリと距離
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    restaurant.category,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${restaurant.distance.toStringAsFixed(1)}km',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // 店舗情報
                            _buildInfoSection('店舗情報'),
                            _buildInfoRow('住所', restaurant.address),
                            _buildInfoRow('電話番号', restaurant.phoneNumber),
                            _buildInfoRow('営業時間', restaurant.openingHours),
                            const SizedBox(height: 16),
                            
                            // 説明
                            if (restaurant.description.isNotEmpty) ...[
                              _buildInfoSection('店舗について'),
                              Text(
                                restaurant.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            // レビューセクション
                            _buildInfoSection('レビュー'),
                            _buildReviewsList(),
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

  Widget _buildInfoSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
      ),
    );
  }

  Widget _buildReviewsList() {
    // サンプルレビューデータ
    final List<ReviewItem> reviews = [
      ReviewItem(
        userName: 'タカシ',
        rating: 4.5,
        comment: '素晴らしいイタリアンレストランです。パスタが特に美味しく、サービスも丁寧でした。',
        date: '2週間前',
        avatarUrl: 'https://placehold.co/40x40',
      ),
      ReviewItem(
        userName: 'エミ',
        rating: 5.0,
        comment: '完璧な食事体験でした！雰囲気も良く、デートにおすすめです。',
        date: '1ヶ月前',
        avatarUrl: 'https://placehold.co/40x40',
      ),
      ReviewItem(
        userName: 'ユウジ',
        rating: 4.0,
        comment: '価格は少し高めですが、料理の質を考えると妥当だと思います。',
        date: '1ヶ月前',
        avatarUrl: 'https://placehold.co/40x40',
      ),
    ];

    return Column(
      children: reviews.map((review) => _buildReviewItem(review)).toList(),
    );
  }

  Widget _buildReviewItem(ReviewItem review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : index < review.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewItem {
  final String userName;
  final double rating;
  final String comment;
  final String date;
  final String avatarUrl;

  ReviewItem({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.avatarUrl,
  });
}