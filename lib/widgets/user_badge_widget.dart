import 'package:flutter/material.dart';
import '../models/badge.dart' as user_badge;

class UserBadgeWidget extends StatelessWidget {
  final List<String> badgeIds;
  final double size;
  final int maxDisplay;

  const UserBadgeWidget({
    super.key,
    required this.badgeIds,
    this.size = 16.0,
    this.maxDisplay = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (badgeIds.isEmpty) return const SizedBox.shrink();

    final badges = badgeIds
        .map((id) => user_badge.BadgeRepository.getBadgeById(id))
        .where((badge) => badge != null)
        .cast<user_badge.Badge>()
        .take(maxDisplay)
        .toList();

    if (badges.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...badges.map((badge) => Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: badge.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Icon(
              badge.icon,
              size: size * 0.6,
              color: Colors.white,
            ),
          ),
        )),
      ],
    );
  }
}

class BadgeDisplayWidget extends StatelessWidget {
  final user_badge.Badge badge;
  final double size;
  final bool showName;

  const BadgeDisplayWidget({
    super.key,
    required this.badge,
    this.size = 60.0,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: badge.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            badge.icon,
            size: size * 0.5,
            color: Colors.white,
          ),
        ),
        if (showName) ...[
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}