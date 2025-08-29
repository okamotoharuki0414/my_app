import 'package:flutter/material.dart';
import '../models/restaurant.dart';

/// Googleマップ風の店舗詳細画面
class GoogleMapsRestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const GoogleMapsRestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<GoogleMapsRestaurantDetailScreen> createState() => _GoogleMapsRestaurantDetailScreenState();
}

class _GoogleMapsRestaurantDetailScreenState extends State<GoogleMapsRestaurantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with hero image
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    // メニューアクション
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getCategoryColor(widget.restaurant.category).withOpacity(0.8),
                      _getCategoryColor(widget.restaurant.category),
                    ],
                  ),
                ),
                child: widget.restaurant.images.isNotEmpty
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              widget.restaurant.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: _getCategoryColor(widget.restaurant.category).withOpacity(0.1),
                                child: Icon(
                                  Icons.restaurant,
                                  size: 80,
                                  color: _getCategoryColor(widget.restaurant.category),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: _getCategoryColor(widget.restaurant.category).withOpacity(0.1),
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: _getCategoryColor(widget.restaurant.category),
                        ),
                      ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  _buildHeaderSection(),
                  const SizedBox(height: 24),

                  // Quick actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Details
                  _buildDetailsSection(),
                  const SizedBox(height: 24),

                  // Reviews section
                  _buildReviewsSection(),
                  const SizedBox(height: 24),

                  // Photos section
                  if (widget.restaurant.images.length > 1)
                    _buildPhotosSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and category
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.restaurant.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getCategoryColor(widget.restaurant.category).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      widget.restaurant.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getCategoryColor(widget.restaurant.category),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Rating
            if (widget.restaurant.overallRating != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.restaurant.overallRating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Price range and status
        Row(
          children: [
            if (widget.restaurant.priceRange.isNotEmpty) ...[
              Text(
                widget.restaurant.priceRange,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '営業中',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            Icons.directions,
            'ルート',
            Colors.blue,
            () {
              // ルート検索
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            Icons.phone,
            '電話',
            Colors.green,
            () {
              // 電話をかける
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            Icons.bookmark_border,
            '保存',
            Colors.grey[600]!,
            () {
              // 保存
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            Icons.share,
            '共有',
            Colors.grey[600]!,
            () {
              // 共有
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '詳細情報',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Address
        _buildDetailItem(
          Icons.location_on,
          '住所',
          widget.restaurant.address,
          onTap: () {
            // 地図で表示
          },
        ),

        // Phone
        if (widget.restaurant.phoneNumber.isNotEmpty)
          _buildDetailItem(
            Icons.phone,
            '電話番号',
            widget.restaurant.phoneNumber,
            onTap: () {
              // 電話をかける
            },
          ),

        // Hours
        if (widget.restaurant.openingHours.isNotEmpty)
          _buildDetailItem(
            Icons.access_time,
            '営業時間',
            widget.restaurant.openingHours,
          ),

        // Distance
        _buildDetailItem(
          Icons.directions_walk,
          '距離',
          '${widget.restaurant.distance.toStringAsFixed(1)} km',
        ),

        // Reviews count
        _buildDetailItem(
          Icons.rate_review,
          'レビュー数',
          '${widget.restaurant.reviewCount} 件',
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String content, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(width: 16),
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
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'レビュー',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // すべてのレビューを表示
              },
              child: const Text('すべて表示'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Review summary
        if (widget.restaurant.overallRating != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Text(
                  widget.restaurant.overallRating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.restaurant.overallRating!.floor()
                                ? Icons.star
                                : index < widget.restaurant.overallRating!
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.restaurant.reviewCount} 件のレビュー',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '写真',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // すべての写真を表示
              },
              child: const Text('すべて表示'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Photo grid
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.restaurant.images.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.restaurant.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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