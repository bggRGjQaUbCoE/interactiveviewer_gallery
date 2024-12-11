import 'package:flutter/material.dart';

/// A widget used to dismiss its [child].
///
/// Similar to [Dismissible] with some adjustments.
class CustomDismissible extends StatefulWidget {
  const CustomDismissible({
    required this.child,
    this.onDismissed,
    this.dismissThreshold = 0.2,
    this.enableDragToDismiss = true,
  });

  final Widget child;
  final double dismissThreshold;
  final VoidCallback? onDismissed;
  final bool enableDragToDismiss;

  @override
  State<CustomDismissible> createState() => _CustomDismissibleState();
}

class _CustomDismissibleState extends State<CustomDismissible>
    with SingleTickerProviderStateMixin {
  late AnimationController _animateController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Decoration> _opacityAnimation;

  Offset _offset = Offset.zero;
  bool _dragging = false;

  bool get _isActive => _dragging || _animateController.isAnimating;

  @override
  void initState() {
    super.initState();

    _animateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _updateMoveAnimation();
  }

  @override
  void dispose() {
    _animateController.dispose();

    super.dispose();
  }

  void _updateMoveAnimation() {
    final double endX = _offset.dx.sign * (_offset.dx.abs() / _offset.dy.abs());
    final double endY = _offset.dy.sign;

    _slideAnimation = _animateController.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: Offset(endX, endY),
      ),
    );

    _scaleAnimation = _animateController.drive(
      Tween<double>(
        begin: 1,
        end: 0.25,
      ),
    );

    _opacityAnimation = _animateController.drive(
      DecorationTween(
        begin: const BoxDecoration(
          color: Colors.black,
        ),
        end: const BoxDecoration(
          color: Colors.transparent,
        ),
      ),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;

    if (_animateController.isAnimating) {
      _animateController.stop();
    } else {
      _offset = Offset.zero;
      _animateController.value = 0.0;
    }
    setState(_updateMoveAnimation);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _animateController.isAnimating) {
      return;
    }

    _offset += details.delta;

    setState(_updateMoveAnimation);

    if (!_animateController.isAnimating) {
      _animateController.value = _offset.dy.abs() / context.size!.height;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isActive || _animateController.isAnimating) {
      return;
    }

    _dragging = false;

    if (_animateController.isCompleted) {
      return;
    }

    if (!_animateController.isDismissed) {
      // if the dragged value exceeded the dismissThreshold, call onDismissed
      // else animate back to initial position.
      if (_animateController.value > widget.dismissThreshold) {
        widget.onDismissed?.call();
      } else {
        _animateController.reverse();
      }
    }
  }

  Widget get content => DecoratedBoxTransition(
        decoration: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: widget.enableDragToDismiss ? _handleDragStart : null,
      onPanUpdate: widget.enableDragToDismiss ? _handleDragUpdate : null,
      onPanEnd: widget.enableDragToDismiss ? _handleDragEnd : null,
      child: content,
    );
  }
}
