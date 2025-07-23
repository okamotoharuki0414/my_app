import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantCarouselCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isCenter;
  final VoidCallback onTap;

  const RestaurantCarouselCard({
    super.key,
    required this.restaurant,
    required this.isCenter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Center card is larger than side cards
    final double cardWidth = isCenter ? 280 : 240;
    final double cardHeight = isCenter ? 340 : 300;
    final double imageHeight = isCenter ? 180 : 150;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isCenter ? 0.15 : 0.08),
              blurRadius: isCenter ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            Container(
              width: double.infinity,
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(restaurant.images.isNotEmpty 
                      ? restaurant.images.first 
                      : 'https://placehold.co/280x180'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Restaurant info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        fontSize: isCenter ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Rating and review count
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: isCenter ? 18 : 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.overallRating?.toStringAsFixed(1) ?? '0.0',
                          style: TextStyle(
                            fontSize: isCenter ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${restaurant.reviewCount})',
                          style: TextStyle(
                            fontSize: isCenter ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Distance and price range
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: isCenter ? 16 : 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${restaurant.distance.toStringAsFixed(1)}km',
                          style: TextStyle(
                            fontSize: isCenter ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          restaurant.priceRange,
                          style: TextStyle(
                            fontSize: isCenter ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        restaurant.category,
                        style: TextStyle(
                          fontSize: isCenter ? 12 : 11,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}