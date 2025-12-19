import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A reusable circular avatar widget for displaying user profile images
/// Shows user's profile image if available, otherwise displays a person icon
/// Handles loading and error states automatically
class UserAvatarWidget extends StatelessWidget {
  /// The URL of the user's profile image (can be null or empty)
  final String? imageUrl;

  /// The size of the avatar (width and height)
  final double size;

  /// Border width around the avatar
  final double borderWidth;

  /// Border color of the avatar
  final Color borderColor;

  /// Background color when showing placeholder icon
  final Color backgroundColor;

  /// Icon color for the placeholder person icon
  final Color iconColor;

  /// Icon size (relative to avatar size)
  final double? iconSize;

  const UserAvatarWidget({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.borderWidth = 2,
    this.borderColor = const Color(0xFFF3F4F6),
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.iconColor = const Color(0xFF9CA3AF),
    this.iconSize,
  });

  /// Check if the image URL is valid
  bool get _hasValidImage =>
      imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        color: backgroundColor,
      ),
      child: ClipOval(
        child: _hasValidImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildLoadingIndicator(),
                errorWidget: (context, url, error) => _buildPlaceholderIcon(),
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  /// Build loading indicator widget
  Widget _buildLoadingIndicator() {
    return Container(
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        ),
      ),
    );
  }

  /// Build placeholder icon widget
  Widget _buildPlaceholderIcon() {
    return Container(
      color: backgroundColor,
      child: Icon(
        Icons.person,
        color: iconColor,
        size: iconSize ?? size * 0.55,
      ),
    );
  }
}

/// Avatar widget with user's initials as fallback
/// Shows profile image if available, otherwise shows initials
class UserAvatarWithInitials extends StatelessWidget {
  /// The URL of the user's profile image (can be null or empty)
  final String? imageUrl;

  /// User's name to extract initials from
  final String userName;

  /// The size of the avatar (width and height)
  final double size;

  /// Border width around the avatar
  final double borderWidth;

  /// Border color of the avatar
  final Color borderColor;

  /// Background color when showing initials
  final Color backgroundColor;

  /// Text color for initials
  final Color textColor;

  const UserAvatarWithInitials({
    super.key,
    this.imageUrl,
    required this.userName,
    this.size = 48,
    this.borderWidth = 2,
    this.borderColor = const Color(0xFFF3F4F6),
    this.backgroundColor = const Color(0xFF3B82F6),
    this.textColor = Colors.white,
  });

  /// Check if the image URL is valid
  bool get _hasValidImage =>
      imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http');

  /// Extract initials from user name (max 2 characters)
  String get _initials {
    if (userName.isEmpty) return '?';
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        color: backgroundColor,
      ),
      child: ClipOval(
        child: _hasValidImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitials(),
                errorWidget: (context, url, error) => _buildInitials(),
              )
            : _buildInitials(),
      ),
    );
  }

  /// Build initials widget
  Widget _buildInitials() {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontFamily: 'Lato',
          ),
        ),
      ),
    );
  }
}

