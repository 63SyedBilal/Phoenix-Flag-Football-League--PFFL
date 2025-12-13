import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final double? size;
  final Color? color;
  final bool fullscreen;

  const CustomLoader({
    super.key,
    this.size,
    this.color,
    this.fullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final loader = Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? theme.primaryColor,
          ),
          strokeWidth: 3,
        ),
      ),
    );

    if (fullscreen) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: loader,
      );
    }

    return loader;
  }
}