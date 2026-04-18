/// lib/providers/auth_provider.dart
/// Riverpod state management for authentication
///
/// Providers:
/// - authStateProvider: Current Firebase user state
/// - userProfileProvider: Cached user profile data
/// - loginProvider: Handle login state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Stream provider for Firebase auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Future provider for user profile
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Watch auth state to invalidate when user logs out
  final user = await ref.watch(authStateProvider.future);
  
  if (user == null) return null;
  
  // Fetch user profile from API
  // return await ProfileService.getProfile(user.uid);
  return null;
});

// Simple state provider for login loading state
final isLoginLoadingProvider = StateProvider<bool>((ref) => false);

// Error state provider
final authErrorProvider = StateProvider<String?>((ref) => null);
