# Phoenix Flag Football League (PFFL) Management App

A comprehensive mobile application for managing Phoenix Flag Football League operations, built with Flutter.

## 📱 Features

### User Management
- **Multi-role Authentication**: Player, Captain, Referee, Stat Keeper, Free Agent, Admin
- **Profile Management**: Complete user profiles with image uploads
- **Team Management**: Create, join, and manage teams

### League Operations
- **League Creation**: Admins can create and configure leagues
- **Match Scheduling**: Automated round-robin tournament scheduling
- **Payment Processing**: Secure Stripe payment integration
- **PDF Receipts**: Professional payment receipts

### Real-time Features
- **Push Notifications**: Firebase-free local notifications
- **Email Notifications**: Backend-triggered email system
- **Live Match Updates**: Real-time match statistics

### Security & Performance
- **SSL Certificate Pinning**: Enhanced security
- **Input Validation**: Comprehensive data sanitization
- **Error Reporting**: Backend error logging
- **Offline Support**: Basic offline functionality

## 🚀 Quick Start

### Prerequisites
- Flutter 3.9.2 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code
- Android SDK (API 21+)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pffl_managment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure backend**
   ```bash
   # Update the backend URL in lib/config/app_config.dart
   # Default: http://192.168.18.32:3000/api
   ```

4. **Generate app icons** (Optional)
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing

### Run All Tests
```bash
# Run comprehensive test suite
chmod +x test_coverage.sh
./test_coverage.sh
```

### Run Specific Tests
```bash
# Unit tests
flutter test test/unit_tests/

# Integration tests
flutter test test/integration_tests/

# Widget tests
flutter test test/widget_test.dart
```

### Test Coverage
```bash
flutter test --coverage
# View coverage report in coverage/html/index.html
```

## 📦 Build & Deployment

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
# 1. Configure signing (see Production Setup below)
# 2. Build release APK
flutter build apk --release --split-per-architecture

# 3. Build App Bundle for Play Store
flutter build appbundle --release
```

## 🔧 Production Setup

### 1. App Signing Configuration
```bash
# Generate keystore
keytool -genkey -v -keystore pffl_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pffl

# Update android/local.properties
echo "storeFile=pffl_key.jks" >> android/local.properties
echo "storePassword=your_store_password" >> android/local.properties
echo "keyAlias=pffl" >> android/local.properties
echo "keyPassword=your_key_password" >> android/local.properties
```

### 2. Backend Configuration
- Ensure backend server is running on the configured IP/port
- Verify all API endpoints are accessible
- Configure SSL certificates for production

### 3. Environment Variables
```bash
# For production, update these in your deployment environment:
# - BACKEND_URL: Your production backend URL
# - STRIPE_PUBLISHABLE_KEY: Your Stripe public key
```

## 📱 App Architecture

### State Management
- **Provider Pattern**: Clean separation of business logic and UI
- **Stateless Widgets**: All UI components are stateless for better performance

### Services Layer
```
lib/core/services/
├── auth_service.dart          # Authentication & JWT handling
├── payment_service.dart       # Stripe payment processing
├── notification_service.dart  # Push & email notifications
├── device_service.dart        # Device token management
├── error_reporting_service.dart # Backend error logging
├── validation_service.dart    # Input validation & sanitization
└── performance_service.dart  # Player stats API calls
```

### Provider Layer
```
lib/core/providers/
├── auth_provider.dart         # User authentication state
├── payment_provider.dart      # Payment processing state
├── notification_provider.dart # Notification management
└── app_providers.dart         # Provider dependency injection
```

## 🔒 Security Features

- **Certificate Pinning**: SSL certificate validation
- **Input Sanitization**: All user inputs validated and sanitized
- **JWT Token Management**: Secure token storage and refresh
- **Error Logging**: Sensitive data filtered from error reports
- **ProGuard Obfuscation**: Code obfuscation in release builds

## 🧪 Quality Assurance

### Code Quality
- **Flutter Lints**: Strict code quality rules
- **Static Analysis**: Automated code analysis
- **Test Coverage**: Unit, integration, and widget tests
- **CI/CD Ready**: Automated testing pipeline

### Performance
- **Image Optimization**: Compressed uploads with caching
- **Lazy Loading**: Efficient list rendering
- **Memory Management**: Proper resource disposal
- **Network Optimization**: Request debouncing and caching

## 📊 API Endpoints

### Authentication
- `POST /login` - User login
- `POST /user` - User registration
- `GET /profile` - Get user profile

### Payments
- `POST /payments/process` - Process payment
- `GET /payments/my` - Get user payments
- `GET /payments/team` - Get team payments

### Notifications
- `POST /email/send-notification` - Send email
- `POST /notifications/send-push` - Send push notification
- `GET /notification/all` - Get notifications

### Matches & Leagues
- `POST /match` - Create match
- `GET /match/:id` - Get match details
- `POST /league` - Create league
- `GET /league` - Get leagues

## 🚨 Error Handling

### Backend Error Logging
- Automatic error reporting to `/error-report` endpoint
- User identification without sensitive data
- Device and app version information
- Stack traces for debugging

### User-Friendly Messages
- Network error handling with retry options
- Validation error display
- Loading states for all operations
- Offline mode indicators

## 📱 Supported Platforms

- **Android**: API 21+ (Android 5.0+)
- **iOS**: Planned (iOS 11.0+)
- **Screen Sizes**: Responsive design for all Android devices

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow Flutter best practices
- Write comprehensive tests
- Update documentation
- Maintain code coverage above 80%

## 📄 License

This project is proprietary software for Phoenix Flag Football League.

## 🆘 Support

For support and bug reports:
- **Email**: support@pffl.com
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check `/docs` folder for detailed guides

## 🎯 Roadmap

### Version 2.0 (Upcoming)
- [ ] iOS Support
- [ ] Advanced Statistics Dashboard
- [ ] Social Features (Player Profiles, Leaderboards)
- [ ] Live Match Streaming
- [ ] Tournament Bracket Generation

### Version 1.5 (Current)
- [x] Complete Backend Integration
- [x] Push Notifications
- [x] PDF Receipt Generation
- [x] Production Build Configuration
- [x] Comprehensive Testing Suite

---

**Built with ❤️ for Phoenix Flag Football League**
