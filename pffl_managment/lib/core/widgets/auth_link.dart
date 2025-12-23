import 'package:flutter/material.dart';

class AuthLink extends StatelessWidget {
  final String text;
  final String linkText;
  final String routeName;
  
  const AuthLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, routeName),
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              TextSpan(
                text: text, 
                style: const TextStyle(color: Colors.black)
              ),
              TextSpan(
                text: linkText,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
