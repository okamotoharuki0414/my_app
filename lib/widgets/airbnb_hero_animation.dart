import 'package:flutter/material.dart';

class AirbnbHeroAnimation extends StatelessWidget {
  final Widget child;
  final String heroTag;
  final VoidCallback? onTap;
  final Widget Function(BuildContext context)? detailBuilder;

  const AirbnbHeroAnimation({
    super.key,
    required this.child,
    required this.heroTag,
    this.onTap,
    this.detailBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (detailBuilder != null) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return detailBuilder!(context);
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Airbnb風のスケールとフェードアニメーション
                const begin = 0.8;
                const end = 1.0;
                const curve = Curves.easeOutCubic;

                var scaleTween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );
                var fadeInTween = Tween(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: curve),
                );

                return ScaleTransition(
                  scale: animation.drive(scaleTween),
                  child: FadeTransition(
                    opacity: animation.drive(fadeInTween),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
              reverseTransitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else if (onTap != null) {
          onTap!();
        }
      },
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}

class AirbnbExpandAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const AirbnbExpandAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<AirbnbExpandAnimation> createState() => _AirbnbExpandAnimationState();
}

class _AirbnbExpandAnimationState extends State<AirbnbExpandAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shadowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _shadowController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // Airbnb風の軽い拡大
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _shadowAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0, // シャドウの強化
    ).animate(CurvedAnimation(
      parent: _shadowController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
    _shadowController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    _shadowController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
    _shadowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _shadowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: _shadowAnimation.value,
                    offset: Offset(0, _shadowAnimation.value / 2),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}