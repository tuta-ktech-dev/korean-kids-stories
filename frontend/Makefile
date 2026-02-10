# Makefile for Vita App
# Uses FVM (Flutter Version Management) for consistent Flutter versions

# Check if FVM is installed
FVM_CHECK := $(shell command -v fvm 2> /dev/null)

# If FVM is installed, use it; otherwise, fallback to system Flutter
ifdef FVM_CHECK
FLUTTER := fvm flutter
DART := fvm dart
else
FLUTTER := flutter
DART := dart
$(warning ⚠️  FVM not found. Using system Flutter. Install FVM: dart pub global activate fvm)
endif

.PHONY: help clean get build run test format lint fix_lint gen watch check

# Default target
help:
	@echo "🎯 Available commands:"
	@echo ""
	@echo "📦 Dependencies:"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make get            - Get dependencies"
	@echo "  make upgrade        - Upgrade dependencies"
	@echo ""
	@echo "🌍 i18n & Code Generation:"
	@echo "  make i18n           - Generate i18n translations only (fast)"
	@echo "  make gen            - Run build_runner (includes FlutterGen)"
	@echo "  make gen-clean      - Clean and regenerate everything"
	@echo "  make watch          - Watch for changes and auto-generate"
	@echo ""
	@echo "🎨 Icons:"
	@echo "  make icons          - Generate app launcher icons"
	@echo ""
	@echo "🚀 Running:"
	@echo "  make run-dev        - Run app in development mode (flavor: dev)"
	@echo "  make run-prod       - Run app in production mode (flavor: prod)"
	@echo ""
	@echo "🔨 Building:"
	@echo "  make build          - Build both APK and AAB for all flavors"
	@echo "  make build-dev      - Build APK and AAB for dev flavor"
	@echo "  make build-prod     - Build APK and AAB for prod flavor"
	@echo ""
	@echo "📱 Building APK:"
	@echo "  make build-apk-dev  - Build APK for dev flavor"
	@echo "  make build-apk-prod - Build APK for prod flavor"
	@echo ""
	@echo "📦 Building App Bundle:"
	@echo "  make build-aab-dev  - Build App Bundle for dev flavor"
	@echo "  make build-aab-prod - Build App Bundle for prod flavor"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@$(FLUTTER) clean
	@rm -rf build/
	@rm -rf .dart_tool/
	@rm -rf ios/Pods/
	@rm -rf ios/.symlinks/
	@rm -rf .flutter-plugins
	@rm -rf .flutter-plugins-dependencies
	@echo "✅ Clean complete!"

# Get dependencies
get:
	@echo "📦 Getting dependencies..."
	@$(FLUTTER) pub get
	@echo "✅ Dependencies installed!"

# Upgrade dependencies
upgrade:
	@echo "⬆️  Upgrading dependencies..."
	@$(FLUTTER) pub upgrade
	@echo "✅ Dependencies upgraded!"

# ============================================
# Icons & Flavors
# ============================================

# Generate app launcher icons
icons:
	@echo "🎨 Generating launcher icons..."
	@$(FLUTTER) pub run flutter_launcher_icons
	@echo "✅ Icons generated!"

# ============================================
# Running App
# ============================================

# Run app in development mode (flavor: dev)
run-dev: get
	@echo "🚀 Running app in development mode (flavor: dev)..."
	@$(FLUTTER) run --flavor dev -t lib/main_dev.dart

# Run app in production mode (flavor: prod)
run-prod: get
	@echo "🚀 Running app in production mode (flavor: prod)..."
	@$(FLUTTER) run --flavor prod -t lib/main_prod.dart


# Format code
format:
	@echo "✨ Formatting code..."
	@$(DART) format lib/ test/ -l 120
	@echo "✅ Code formatted!"


# Run linter
lint:
	@echo "🔍 Running linter..."
	@$(FLUTTER) analyze

# Fix linting issues
fix_lint:
	@echo "🔧 Fixing linting issues..."
	@$(DART) fix --apply
	@echo "✅ Linting issues fixed!"

# ============================================
# i18n & Code Generation
# ============================================

# Generate i18n translations ONLY (fast, ~1-2s)
i18n:
	@echo "🌍 Generating i18n translations..."
	@python3 scripts/merge_i18n.py
	@$(FLUTTER) pub run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/core/i18n -S assets/i18n
	@echo "✅ i18n generation complete!"

# Run build_runner (includes FlutterGen, freezed, json_serializable, retrofit, auto_route)
build:
	@echo "🔨 Running build_runner..."
	@$(FLUTTER) pub run build_runner build --delete-conflicting-outputs
	@echo "✅ Build complete!"


# Watch for changes and auto-generate
watch:
	@echo "👀 Watching for changes..."
	@$(FLUTTER) pub run build_runner watch --delete-conflicting-outputs

# ============================================
# Building APK
# ============================================

# Build APK for dev flavor (release)
build-apk-dev:
	@echo "📱 Building APK for dev flavor..."
	@$(FLUTTER) build apk --flavor dev -t lib/main_dev.dart
	@echo "✅ APK: build/app/outputs/flutter-apk/app-dev-release.apk"

# Build APK for prod flavor (release)
build-apk-prod:
	@echo "📱 Building APK for prod flavor..."
	@$(FLUTTER) build apk --flavor prod -t lib/main_prod.dart
	@echo "✅ APK: build/app/outputs/flutter-apk/app-prod-release.apk"

# Build APK for dev flavor (debug)
build-apk-dev-debug:
	@echo "📱 Building debug APK for dev flavor..."
	@$(FLUTTER) build apk --debug --flavor dev -t lib/main_dev.dart
	@echo "✅ APK: build/app/outputs/flutter-apk/app-dev-debug.apk"

# ============================================
# Building App Bundle (for Play Store)
# ============================================

# Build App Bundle for dev flavor
build-aab-dev:
	@echo "� Building App Bundle for dev flavor..."
	@$(FLUTTER) build appbundle --flavor dev -t lib/main_dev.dart
	@echo "✅ AAB: build/app/outputs/bundle/devRelease/app-dev-release.aab"

# Build App Bundle for prod flavor
build-aab-prod:
	@echo "📦 Building App Bundle for prod flavor..."
	@$(FLUTTER) build appbundle --flavor prod -t lib/main_prod.dart
	@echo "✅ AAB: build/app/outputs/bundle/prodRelease/app-prod-release.aab"

# ============================================
# Building iOS
# ============================================

# Build iOS for dev flavor
build-ios-dev:
	@echo "🍎 Building iOS for dev flavor..."
	@$(FLUTTER) build ios --flavor dev -t lib/main_dev.dart
	@echo "✅ iOS build complete!"

# Build iOS for prod flavor
build-ios-prod:
	@echo "🍎 Building iOS for prod flavor..."
	@$(FLUTTER) build ios --flavor prod -t lib/main_prod.dart
	@echo "✅ iOS build complete!"


check_ci:
	@$(FLUTTER) analyze --fatal-infos --fatal-warnings
	./scripts/check_functions.sh --changed-from=develop

