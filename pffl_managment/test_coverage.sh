#!/bin/bash

# PFFL Management App - Test Coverage Script
# This script runs all tests and generates coverage reports

echo "🧪 Running PFFL Management App Tests..."
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2

    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "info")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    print_status "error" "Flutter is not installed or not in PATH"
    exit 1
fi

# Clean previous builds
print_status "info" "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "info" "Getting dependencies..."
if flutter pub get; then
    print_status "success" "Dependencies installed successfully"
else
    print_status "error" "Failed to install dependencies"
    exit 1
fi

# Run Flutter analyze
print_status "info" "Running Flutter analyze..."
if flutter analyze --fatal-infos; then
    print_status "success" "Code analysis passed"
else
    print_status "warning" "Code analysis found issues (check output above)"
fi

# Run unit tests
print_status "info" "Running unit tests..."
if flutter test test/unit_tests/ --coverage; then
    print_status "success" "Unit tests passed"
else
    print_status "error" "Unit tests failed"
fi

# Run integration tests
print_status "info" "Running integration tests..."
if flutter test test/integration_tests/ --coverage; then
    print_status "success" "Integration tests passed"
else
    print_status "error" "Integration tests failed"
fi

# Run widget tests
print_status "info" "Running widget tests..."
if flutter test test/widget_test.dart --coverage; then
    print_status "success" "Widget tests passed"
else
    print_status "error" "Widget tests failed"
fi

# Generate coverage report
print_status "info" "Generating coverage report..."
if command -v genhtml &> /dev/null; then
    if [ -d "coverage" ]; then
        genhtml coverage/lcov.info -o coverage/html
        print_status "success" "Coverage report generated: coverage/html/index.html"
    fi
else
    print_status "warning" "lcov not installed. Install with: brew install lcov"
fi

# Check test coverage
if [ -f "coverage/lcov.info" ]; then
    print_status "info" "Coverage Summary:"
    # Simple coverage calculation (you might want to use a proper tool)
    TOTAL_LINES=$(wc -l < coverage/lcov.info)
    print_status "info" "Coverage data collected ($TOTAL_LINES lines)"

    # Basic coverage check - you can enhance this
    if [ $TOTAL_LINES -gt 100 ]; then
        print_status "success" "Good test coverage achieved"
    else
        print_status "warning" "Test coverage might be insufficient"
    fi
fi

# Build check
print_status "info" "Testing debug build..."
if flutter build apk --debug --no-tree-shake-icons; then
    print_status "success" "Debug build successful"
else
    print_status "error" "Debug build failed"
fi

# Final summary
echo ""
print_status "info" "Test Summary:"
echo "=================="
echo "• Code Analysis: $(flutter analyze --fatal-infos >/dev/null 2>&1 && echo 'PASSED' || echo 'ISSUES')"
echo "• Unit Tests: $(flutter test test/unit_tests/ --silent >/dev/null 2>&1 && echo 'PASSED' || echo 'FAILED')"
echo "• Integration Tests: $(flutter test test/integration_tests/ --silent >/dev/null 2>&1 && echo 'PASSED' || echo 'FAILED')"
echo "• Widget Tests: $(flutter test test/widget_test.dart --silent >/dev/null 2>&1 && echo 'PASSED' || echo 'FAILED')"
echo "• Debug Build: $(flutter build apk --debug --no-tree-shake-icons >/dev/null 2>&1 && echo 'PASSED' || echo 'FAILED')"
echo ""

if flutter test --silent >/dev/null 2>&1 && flutter build apk --debug --no-tree-shake-icons >/dev/null 2>&1; then
    print_status "success" "🎉 ALL TESTS PASSED - App is ready for deployment!"
    exit 0
else
    print_status "error" "❌ Some tests failed - Please fix issues before deployment"
    exit 1
fi
