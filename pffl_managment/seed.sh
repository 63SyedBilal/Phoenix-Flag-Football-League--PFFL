#!/bin/bash

# PFFL Backend Seeding Script Runner
# This script provides an easy way to run the seeding operations

echo "🌱 PFFL Backend Database Seeding Tool"
echo "======================================"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "❌ package.json not found. Please run this script from the correct directory."
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies."
        exit 1
    fi
fi

# Show menu
echo ""
echo "Select an option:"
echo "1) Seed database with test users"
echo "2) Cleanup test users"
echo "3) Show help"
echo "4) Exit"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "🌱 Seeding database with test users..."
        npm run seed
        ;;
    2)
        echo "🧹 Cleaning up test users..."
        read -p "Are you sure you want to remove all test users? (y/N): " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            npm run cleanup
        else
            echo "Cleanup cancelled."
        fi
        ;;
    3)
        npm run help
        ;;
    4)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option. Please choose 1-4."
        exit 1
        ;;
esac

echo ""
echo "✅ Operation completed!"