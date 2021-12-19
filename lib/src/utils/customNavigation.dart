import 'package:flutter/material.dart';

class CustomPageRouteAnimation extends PageRouteBuilder {
  final Widget child;
  CustomPageRouteAnimation({required this.child})
      : super(
          transitionDuration: Duration(milliseconds: 150),
          reverseTransitionDuration: Duration(milliseconds: 150),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      FadeTransition(
        opacity: animation,
        child: child,
      );
      
}