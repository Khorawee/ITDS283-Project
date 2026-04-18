/// lib/providers/theme_provider.dart
/// Riverpod state management for theme and UI state
///
/// Provides:
/// - isDarkModeProvider: Theme mode state
/// - localeProvider: Language/Locale state
/// - loadingProvider: Global loading state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Dark mode toggle provider
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Locale/Language provider
enum AppLocale { thai, english }

final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.thai);

/// Global loading provider for showing loading overlay
final globalLoadingProvider = StateProvider<bool>((ref) => false);

/// Global error message provider
final globalErrorProvider = StateProvider<String?>((ref) => null);

/// Helper to set loading state
void setLoading(WidgetRef ref, bool loading) {
  ref.read(globalLoadingProvider.notifier).state = loading;
}

/// Helper to show error
void showError(WidgetRef ref, String message) {
  ref.read(globalErrorProvider.notifier).state = message;
  // Auto-clear after 3 seconds
  Future.delayed(Duration(seconds: 3), () {
    ref.read(globalErrorProvider.notifier).state = null;
  });
}

/// Helper to clear error
void clearError(WidgetRef ref) {
  ref.read(globalErrorProvider.notifier).state = null;
}
