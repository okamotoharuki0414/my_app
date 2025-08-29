import 'package:flutter/material.dart';
import 'dart:io';
import '../models/event.dart';

class EventInvitationCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onMaybe;
  final VoidCallback? onTap;
  final InvitationStatus? currentUserStatus;

  const EventInvitationCard({
    super.key,
    required this.event,
    this.onAccept,
    this.onDecline,
    this.onMaybe,
    this.onTap,
    this.currentUserStatus,
  });

  @override
  State<EventInvitationCard> createState() => _EventInvitationCardState();
}

class _EventInvitationCardState extends State<EventInvitationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7, // 画面の70%まで
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    _buildBackground(),
                    _buildContent(),
                    if (widget.currentUserStatus != null)
                      _buildStatusBadge(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 300,
        maxHeight: MediaQuery.of(context).size.height * 0.6, // 画面の60%まで
      ),
      decoration: BoxDecoration(
        gradient: _getGradientForType(widget.event.type),
      ),
      child: widget.event.imageUrl != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: widget.event.imageUrl!.startsWith('http')
                      ? Image.network(
                          widget.event.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(widget.event.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildContent() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Spacer(),
            _buildEventInfo(),
            const SizedBox(height: 16),
            _buildLocationInfo(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.event.type.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                widget.event.type.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (widget.event.availableSlots > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.4)),
            ),
            child: Text(
              '残り${widget.event.availableSlots}名',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          widget.event.description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        _buildDateTimeInfo(),
      ],
    );
  }

  Widget _buildDateTimeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.formattedDateTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.event.dayOfWeek,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.event.locationDetails.isNotEmpty)
                  Text(
                    widget.event.locationDetails,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.currentUserStatus != null) {
      return _buildStatusDisplay();
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            '参加する',
            Icons.check,
            Colors.green,
            widget.onAccept,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            '検討中',
            Icons.schedule,
            Colors.orange,
            widget.onMaybe,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            '不参加',
            Icons.close,
            Colors.red,
            widget.onDecline,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return _ActionButton(
      text: text,
      icon: icon,
      color: color,
      onPressed: onPressed,
    );
  }

  Widget _buildStatusDisplay() {
    final status = widget.currentUserStatus!;
    final (color, icon, text) = _getStatusDisplayInfo(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = widget.currentUserStatus!;
    final (color, icon, text) = _getStatusDisplayInfo(status);

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradientForType(EventType type) {
    switch (type) {
      case EventType.dining:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
        );
      case EventType.party:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        );
      case EventType.fan:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
        );
      case EventType.casual:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        );  
      case EventType.business:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF374151), Color(0xFF1F2937)],
        );
      case EventType.cultural:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDB2777), Color(0xFFC2185B)],
        );
      case EventType.sports:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case EventType.other:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        );
    }
  }

  (Color, IconData, String) _getStatusDisplayInfo(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.accepted:
        return (Colors.green, Icons.check_circle, '参加予定');
      case InvitationStatus.declined:
        return (Colors.red, Icons.cancel, '不参加');
      case InvitationStatus.maybe:
        return (Colors.orange, Icons.schedule, '検討中');
      case InvitationStatus.pending:
        return (Colors.grey, Icons.help_outline, '未回答');
    }
  }
}

class _ActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // スケールアニメーション（タップ時の縮小）
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // リップルエフェクト
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    // アイコンアニメーション
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));
    
    // カラーアニメーション
    _colorAnimation = ColorTween(
      begin: widget.color.withOpacity(0.2),
      end: widget.color.withOpacity(0.4),
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      // アニメーション開始
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      
      _rippleController.forward().then((_) {
        _rippleController.reverse();
      });
      
      _iconController.forward().then((_) {
        _iconController.reverse();
      });
      
      // 少し遅延してコールバック実行（エフェクトを見せるため）
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.onPressed!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _rippleAnimation,
          _iconScaleAnimation,
          _colorAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _colorAnimation.value ?? widget.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color.withOpacity(0.4)),
                boxShadow: _rippleAnimation.value > 0.1
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3 * _rippleAnimation.value),
                          blurRadius: 20 * _rippleAnimation.value,
                          spreadRadius: 5 * _rippleAnimation.value,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // リップルエフェクト
                  if (_rippleAnimation.value > 0.1)
                    Container(
                      width: 80 * _rippleAnimation.value,
                      height: 80 * _rippleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                          0.3 * (1 - _rippleAnimation.value),
                        ),
                      ),
                    ),
                  // メインコンテンツ
                  Column(
                    children: [
                      Transform.scale(
                        scale: _iconScaleAnimation.value,
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}