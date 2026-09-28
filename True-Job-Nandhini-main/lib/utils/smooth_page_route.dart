import 'package:flutter/material.dart';

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final int durationMs;

  SmoothPageRoute({required this.child, this.durationMs = 0})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: durationMs),
          reverseTransitionDuration: Duration(milliseconds: durationMs),
        );
}
